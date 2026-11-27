pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Map of server id -> { status: "up"|"down"|"checking"|"unknown", latencyMs: int, detail: string, lastChecked: string }
    property var statuses: ({})
    property bool isChecking: false
    property int _queueIndex: 0
    property var _queue: []

    readonly property int upCount: {
        var list = PoniConfig.serversList || [];
        var c = 0;
        for (var i = 0; i < list.length; i++) {
            var st = statuses[String(list[i].id)];
            if (st && st.status === "up") c++;
        }
        return c;
    }

    readonly property int downCount: {
        var list = PoniConfig.serversList || [];
        var c = 0;
        for (var i = 0; i < list.length; i++) {
            var st = statuses[String(list[i].id)];
            if (st && st.status === "down") c++;
        }
        return c;
    }

    Timer {
        id: pollTimer
        interval: 20000
        repeat: true
        running: !!PoniConfig.addons["servers"]
        triggeredOnStart: true
        onTriggered: root.checkAll()
    }

    function statusFor(id) {
        return statuses[String(id)] || { status: "unknown", latencyMs: -1, detail: "Pending", lastChecked: "" };
    }

    function checkAll() {
        var list = PoniConfig.serversList || [];
        if (list.length === 0 || root.isChecking) return;
        root._queue = list.slice();
        root._queueIndex = 0;
        root.isChecking = true;
        runNextCheck();
    }

    function runNextCheck() {
        if (root._queueIndex >= root._queue.length) {
            root.isChecking = false;
            return;
        }
        var srv = root._queue[root._queueIndex];
        if (!srv) {
            root._queueIndex++;
            runNextCheck();
            return;
        }

        var nextMap = Object.assign({}, root.statuses);
        var prev = nextMap[String(srv.id)] || {};
        nextMap[String(srv.id)] = {
            status: prev.status || "checking",
            latencyMs: prev.latencyMs !== undefined ? prev.latencyMs : -1,
            detail: prev.detail || "Checking...",
            lastChecked: prev.lastChecked || ""
        };
        root.statuses = nextMap;

        var ctype = (srv.checkType || "tcp").toLowerCase();
        var host = String(srv.host || "").trim();
        var port = String(srv.port || 22);

        probeProc.currentServerId = String(srv.id);
        probeProc.currentCheckType = ctype;

        if (ctype === "http") {
            var url = (host.indexOf("http://") === 0 || host.indexOf("https://") === 0) ? host : ("https://" + host);
            probeProc.command = [
                "sh", "-c",
                "out=$(curl -s -o /dev/null -w '%{http_code} %{time_total}' --max-time 3 \"$1\" 2>/dev/null); echo \"$out\"",
                "_", url
            ];
        } else if (ctype === "ping") {
            probeProc.command = [
                "sh", "-c",
                "ping -c 1 -W 2 \"$1\" 2>/dev/null | sed -n 's/.*time=\\([0-9.]*\\).*/\\1/p'",
                "_", host
            ];
        } else {
            probeProc.command = [
                "bash", "-c",
                "t0=$(date +%s%3N); if command -v nc >/dev/null 2>&1; then nc -z -w 2 \"$1\" \"$2\" >/dev/null 2>&1; rc=$?; else timeout 2 bash -c \"exec 3<>/dev/tcp/$1/$2\" >/dev/null 2>&1; rc=$?; fi; t1=$(date +%s%3N); echo \"$rc $((t1-t0))\"",
                "_", host, port
            ];
        }
        probeProc.running = true;
    }

    Process {
        id: probeProc
        property string currentServerId: ""
        property string currentCheckType: "tcp"
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = text.trim();
                var now = new Date();
                var hh = (now.getHours() < 10 ? "0" : "") + now.getHours();
                var mm = (now.getMinutes() < 10 ? "0" : "") + now.getMinutes();
                var stamp = hh + ":" + mm;

                var isUp = false;
                var lat = -1;
                var detail = "Offline";

                if (probeProc.currentCheckType === "http") {
                    var parts = raw.split(/\s+/);
                    var code = parseInt(parts[0], 10);
                    var sec = parseFloat(parts[1]);
                    if (!isNaN(code) && code >= 200 && code < 500) {
                        isUp = true;
                        lat = !isNaN(sec) ? Math.round(sec * 1000) : 0;
                        detail = "HTTP " + code;
                    } else {
                        detail = (!isNaN(code) && code > 0) ? ("HTTP " + code) : "Unreachable";
                    }
                } else if (probeProc.currentCheckType === "ping") {
                    var ms = parseFloat(raw);
                    if (!isNaN(ms)) {
                        isUp = true;
                        lat = Math.round(ms);
                        detail = "ICMP OK";
                    }
                } else {
                    var tparts = raw.split(/\s+/);
                    var rc = parseInt(tparts[0], 10);
                    var msTcp = parseInt(tparts[1], 10);
                    if (rc === 0) {
                        isUp = true;
                        lat = !isNaN(msTcp) ? msTcp : 0;
                        detail = "Port open";
                    } else {
                        detail = "Closed";
                    }
                }

                var prev = root.statuses[probeProc.currentServerId] || {};
                var total = (prev.totalChecks || 0) + 1;
                var ok = (prev.upChecks || 0) + (isUp ? 1 : 0);
                var pct = Math.round((ok / total) * 100);

                var nextMap = Object.assign({}, root.statuses);
                nextMap[probeProc.currentServerId] = {
                    status: isUp ? "up" : "down",
                    latencyMs: lat,
                    detail: detail,
                    lastChecked: stamp,
                    totalChecks: total,
                    upChecks: ok,
                    uptimePct: pct
                };
                root.statuses = nextMap;

                root._queueIndex++;
                root.runNextCheck();
            }
        }
    }

    function addServer(name, host, port, user, checkType) {
        var cleanHost = (host || "").trim();
        if (cleanHost.length === 0) return;
        var cleanName = (name || "").trim();
        if (cleanName.length === 0) cleanName = cleanHost;
        var p = parseInt(port, 10);
        if (isNaN(p) || p <= 0 || p > 65535) p = (checkType === "http") ? 443 : 22;

        var list = (PoniConfig.serversList || []).slice();
        list.push({
            id: Date.now(),
            name: cleanName,
            host: cleanHost,
            port: p,
            user: (user || "").trim(),
            checkType: checkType || "tcp"
        });
        PoniConfig.serversList = list;
        PoniConfig.saveData();
        checkAll();
    }

    function removeServer(id) {
        var list = (PoniConfig.serversList || []).filter(function(item) {
            return String(item.id) !== String(id);
        });
        PoniConfig.serversList = list;
        PoniConfig.saveData();
    }

    function sshCommandFor(srv) {
        if (!srv) return "";
        var host = String(srv.host || "").replace(/^https?:\/\//, "").split("/")[0];
        var user = (srv.user && srv.user.trim().length > 0) ? (srv.user.trim() + "@") : "";
        var port = (srv.port && parseInt(srv.port, 10) !== 22) ? (" -p " + srv.port) : "";
        return "ssh" + port + " " + user + host;
    }

    function launchSsh(srv) {
        var cmd = sshCommandFor(srv);
        if (cmd.length === 0) return;
        sshProc.command = [
            "sh", "-c",
            "for term in \"$TERMINAL\" kitty alacritty foot wezterm ghostty gnome-terminal xterm; do if [ -n \"$term\" ] && command -v \"$term\" >/dev/null 2>&1; then nohup \"$term\" -e sh -c \"$1\" >/dev/null 2>&1 & exit 0; fi; done",
            "_", cmd
        ];
        sshProc.running = true;
    }

    function copySsh(srv) {
        var textToCopy = (srv.checkType === "http") ? String(srv.host) : sshCommandFor(srv);
        copyProc.command = ["sh", "-c", "printf '%s' \"$1\" | wl-copy 2>/dev/null || printf '%s' \"$1\" | xclip -selection clipboard 2>/dev/null", "_", textToCopy];
        copyProc.running = true;
        PoniNotices.post("Copied", textToCopy);
    }

    function openUrl(srv) {
        if (!srv || !srv.host) return;
        var h = String(srv.host).trim();
        var url = (h.indexOf("http://") === 0 || h.indexOf("https://") === 0) ? h : ("https://" + h);
        openProc.command = ["sh", "-c", "nohup xdg-open \"$1\" >/dev/null 2>&1 &", "_", url];
        openProc.running = true;
    }

    Process { id: sshProc }
    Process { id: copyProc }
    Process { id: openProc }
}
