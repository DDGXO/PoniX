pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string inboxDir: Quickshell.env("HOME") + "/Downloads/PoniX"
    property var files: [] // [{ path, name, size, icon, isImage }]

    // Phone drop state
    property bool phoneDropOpen: false
    property string localIp: "192.168.1.100"
    property int serverPort: 7890
    property string qrUrl: "http://" + localIp + ":" + serverPort

    function addFile(path) {
        if (!path) return;
        var raw = String(path).trim();
        if (raw.length === 0) return;
        var p = raw.replace("file://", "");
        var name = p.split("/").pop();
        var ext = name.split(".").pop().toLowerCase();
        var isImg = ["png", "jpg", "jpeg", "webp", "gif", "svg"].indexOf(ext) >= 0;

        var list = root.files.filter(function(f) { return f.path !== p; });
        list.unshift({
            path: p,
            name: name,
            size: "File",
            icon: isImg ? "image" : "file",
            isImage: isImg
        });
        root.files = list;
        PoniConfig.shelfFiles = list.map(function(f) { return f.path; });
        PoniConfig.saveData();
    }

    function removeFile(path) {
        var list = root.files.filter(function(f) { return f.path !== path; });
        root.files = list;
        PoniConfig.shelfFiles = list.map(function(f) { return f.path; });
        PoniConfig.saveData();
    }

    function clearAll() {
        root.files = [];
        PoniConfig.shelfFiles = [];
        PoniConfig.saveData();
    }

    function openFile(path) {
        Quickshell.execDetached(["xdg-open", path]);
    }

    function copyFile(path) {
        Quickshell.execDetached(["sh", "-c", "printf 'file://%s\\r\\n' \"$1\" | wl-copy -t text/uri-list", "_", path]);
    }

    function syncFromConfig() {
        if (!PoniConfig.shelfFiles) return;
        var out = [];
        for (var i = 0; i < PoniConfig.shelfFiles.length; i++) {
            var p = String(PoniConfig.shelfFiles[i]).trim().replace("file://", "");
            if (p.length === 0) continue;
            var name = p.split("/").pop();
            var ext = name.split(".").pop().toLowerCase();
            var isImg = ["png", "jpg", "jpeg", "webp", "gif", "svg"].indexOf(ext) >= 0;
            out.push({ path: p, name: name, size: "File", icon: isImg ? "image" : "file", isImage: isImg });
        }
        root.files = out;
    }

    Connections {
        target: PoniConfig
        function onShelfFilesChanged() {
            if (root.files.length === 0 && PoniConfig.shelfFiles.length > 0) {
                root.syncFromConfig();
            }
        }
    }

    function togglePhoneDrop() {
        root.phoneDropOpen = !root.phoneDropOpen;
        if (root.phoneDropOpen) {
            getIpProc.running = true;
        }
    }

    Process {
        id: getIpProc
        command: ["sh", "-c", "ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' | head -n 1"]
        stdout: SplitParser {
            onRead: ip => {
                if (ip && ip.trim().length > 0) {
                    root.localIp = ip.trim();
                    root.qrUrl = "http://" + root.localIp + ":" + root.serverPort;
                }
            }
        }
    }

    Component.onCompleted: {
        syncFromConfig();
    }
}
