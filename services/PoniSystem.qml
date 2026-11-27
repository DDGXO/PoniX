pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int cpu: 0
    property int cpuTemp: 45
    property real cpuClockGhz: 3.2
    property var cpuCores: [0, 0, 0, 0]

    property real memUsedGb: 0
    property real memTotalGb: 16
    property int memPct: 0
    property real swapUsedGb: 0
    property real swapTotalGb: 8

    property int diskPct: 0
    property string diskFreeGb: "0"

    property real netDownKb: 0
    property real netUpKb: 0

    property int batteryPct: 100
    property bool batteryCharging: false
    property bool hasBattery: true

    property int gpuLoad: 0
    property int gpuTemp: 0
    property bool hasGpu: false

    property var topProcesses: []
    property var cpuHistory: [] // 60 samples
    property var memHistory: [] // 60 samples

    property var prevCpuStat: null
    property var prevNetDev: null

    function sample() {
        sysProc.running = true;
    }

    Process {
        id: sysProc
        command: [
            "sh", "-c",
            "cat /proc/stat | grep -E '^cpu'; " +
            "echo '===MEM'; " +
            "cat /proc/meminfo | grep -E '^(MemTotal|MemAvailable|SwapTotal|SwapFree):'; " +
            "echo '===NET'; " +
            "cat /proc/net/dev | grep -v 'lo:'; " +
            "echo '===DISK'; " +
            "df -h / | tail -n 1; " +
            "echo '===BATT'; " +
            "if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1; cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1; else echo 'NONE'; fi; " +
            "echo '===TEMP'; " +
            "cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 45000; " +
            "echo '===TOP'; " +
            "ps -eo comm,%cpu,%mem --sort=-%cpu | head -n 6 | tail -n 5"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = text;
                if (!raw) return;
                var parts = raw.split("===");
                if (parts.length < 6) return;

                // CPU
                var cpuLines = parts[0].trim().split("\n");
                if (cpuLines.length > 0) {
                    var totalFields = cpuLines[0].trim().split(/\s+/).slice(1).map(Number);
                    var idle = totalFields[3] + (totalFields[4] || 0);
                    var total = totalFields.reduce((a, b) => a + b, 0);
                    if (root.prevCpuStat) {
                        var diffIdle = idle - root.prevCpuStat.idle;
                        var diffTotal = total - root.prevCpuStat.total;
                        if (diffTotal > 0) {
                            root.cpu = Math.min(100, Math.max(0, Math.round(100 * (1 - diffIdle / diffTotal))));
                        }
                    }
                    root.prevCpuStat = { idle: idle, total: total };

                    // History
                    var hist = root.cpuHistory.slice();
                    hist.push(root.cpu);
                    if (hist.length > 60) hist.shift();
                    root.cpuHistory = hist;
                }

                // Memory, Net, Disk, Battery, Temp, Top
                for (var p = 1; p < parts.length; p++) {
                    var chunk = parts[p];
                    if (chunk.indexOf("MEM") === 0) {
                        var memLines = chunk.substring(3).trim().split("\n");
                        var mTot = 0, mAvail = 0, sTot = 0, sFree = 0;
                        for (var mi = 0; mi < memLines.length; mi++) {
                            var ml = memLines[mi].split(":");
                            if (ml.length < 2) continue;
                            var k = ml[0].trim();
                            var v = parseInt(ml[1].trim().split(/\s+/)[0], 10);
                            if (k === "MemTotal") mTot = v;
                            if (k === "MemAvailable") mAvail = v;
                            if (k === "SwapTotal") sTot = v;
                            if (k === "SwapFree") sFree = v;
                        }
                        if (mTot > 0) {
                            root.memTotalGb = (mTot / 1048576);
                            var used = mTot - mAvail;
                            root.memUsedGb = (used / 1048576);
                            root.memPct = Math.round(100 * used / mTot);
                            var mHist = root.memHistory.slice();
                            mHist.push(root.memPct);
                            if (mHist.length > 60) mHist.shift();
                            root.memHistory = mHist;
                        }
                        if (sTot > 0) {
                            root.swapTotalGb = (sTot / 1048576);
                            root.swapUsedGb = ((sTot - sFree) / 1048576);
                        }
                    } else if (chunk.indexOf("NET") === 0) {
                        var netLines = chunk.substring(3).trim().split("\n");
                        var rx = 0, tx = 0;
                        for (var ni = 0; ni < netLines.length; ni++) {
                            var nCols = netLines[ni].trim().split(/\s+/);
                            if (nCols.length >= 10 && nCols[0].indexOf(":") >= 0) {
                                rx += parseInt(nCols[1], 10) || 0;
                                tx += parseInt(nCols[9], 10) || 0;
                            }
                        }
                        if (root.prevNetDev) {
                            root.netDownKb = Math.max(0, Math.round((rx - root.prevNetDev.rx) / 1024));
                            root.netUpKb = Math.max(0, Math.round((tx - root.prevNetDev.tx) / 1024));
                        }
                        root.prevNetDev = { rx: rx, tx: tx };
                    } else if (chunk.indexOf("DISK") === 0) {
                        var diskLine = chunk.substring(4).trim();
                        var dCols = diskLine.split(/\s+/);
                        if (dCols.length >= 5) {
                            root.diskFreeGb = dCols[3];
                            root.diskPct = parseInt(dCols[4].replace("%", ""), 10) || 0;
                        }
                    } else if (chunk.indexOf("BATT") === 0) {
                        var bLines = chunk.substring(4).trim().split("\n");
                        if (bLines[0] !== "NONE") {
                            root.hasBattery = true;
                            root.batteryPct = parseInt(bLines[0], 10) || 100;
                            root.batteryCharging = (bLines[1] || "").toLowerCase().indexOf("charg") >= 0;
                        } else {
                            root.hasBattery = false;
                        }
                    } else if (chunk.indexOf("TEMP") === 0) {
                        var tempRaw = chunk.substring(4).trim();
                        var tVal = parseInt(tempRaw, 10);
                        if (tVal > 1000) tVal = Math.round(tVal / 1000);
                        root.cpuTemp = tVal || 45;
                    } else if (chunk.indexOf("TOP") === 0) {
                        var topLines = chunk.substring(3).trim().split("\n");
                        var procs = [];
                        for (var ti = 0; ti < topLines.length; ti++) {
                            var tCols = topLines[ti].trim().split(/\s+/);
                            if (tCols.length >= 3) {
                                procs.push({
                                    name: tCols[0],
                                    cpu: parseFloat(tCols[1]) || 0,
                                    mem: parseFloat(tCols[2]) || 0
                                });
                            }
                        }
                        root.topProcesses = procs;
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.sample()
    }

    Component.onCompleted: sample()
}
