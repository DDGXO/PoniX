pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int sinkVolume: 50
    property bool sinkMuted: false
    property int sourceVolume: 50
    property bool sourceMuted: false
    property string sinkName: "Default Output"
    property string sourceName: "Default Mic"
    property var sinks: []   // [{ id, name, active }]
    property var sources: [] // [{ id, name, active }]

    Timer {
        interval: 2500
        repeat: true
        running: !!PoniConfig.addons["audio"]
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    function refresh() {
        if (!volProc.running) volProc.running = true;
        if (!devProc.running) devProc.running = true;
    }

    Process {
        id: volProc
        command: [
            "sh", "-c",
            "if command -v wpctl >/dev/null 2>&1; then " +
            "s=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null); " +
            "m=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null); " +
            "echo \"WP|$s|$m\"; " +
            "elif command -v pactl >/dev/null 2>&1; then " +
            "sv=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -o '[0-9]*%' | head -n1 | tr -d '%'); " +
            "sm=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}'); " +
            "mv=$(pactl get-source-volume @DEFAULT_SOURCE@ 2>/dev/null | grep -o '[0-9]*%' | head -n1 | tr -d '%'); " +
            "mm=$(pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $2}'); " +
            "echo \"PA|$sv|$sm|$mv|$mm\"; " +
            "fi"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = text.trim();
                if (!raw) return;
                var parts = raw.split("|");
                if (parts[0] === "WP") {
                    var sStr = parts[1] || "";
                    var mStr = parts[2] || "";
                    var svMatch = sStr.match(/Volume:\s*([0-9.]+)/);
                    if (svMatch) root.sinkVolume = Math.round(parseFloat(svMatch[1]) * 100);
                    root.sinkMuted = sStr.indexOf("MUTED") >= 0;
                    var mvMatch = mStr.match(/Volume:\s*([0-9.]+)/);
                    if (mvMatch) root.sourceVolume = Math.round(parseFloat(mvMatch[1]) * 100);
                    root.sourceMuted = mStr.indexOf("MUTED") >= 0;
                } else if (parts[0] === "PA") {
                    if (parts[1]) root.sinkVolume = parseInt(parts[1], 10) || 0;
                    root.sinkMuted = (parts[2] === "yes");
                    if (parts[3]) root.sourceVolume = parseInt(parts[3], 10) || 0;
                    root.sourceMuted = (parts[4] === "yes");
                }
            }
        }
    }

    Process {
        id: devProc
        command: [
            "sh", "-c",
            "if command -v pactl >/dev/null 2>&1; then " +
            "ds=$(pactl get-default-sink 2>/dev/null); " +
            "dm=$(pactl get-default-source 2>/dev/null); " +
            "pactl list short sinks 2>/dev/null | awk -v d=\"$ds\" '{print \"SINK|\"$1\"|\"$2\"|\"($2==d?1:0)}'; " +
            "pactl list short sources 2>/dev/null | grep -v '\\.monitor' | awk -v d=\"$dm\" '{print \"SRC|\"$1\"|\"$2\"|\"($2==d?1:0)}'; " +
            "fi"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n");
                var outSinks = [];
                var outSrcs = [];
                for (var i = 0; i < lines.length; i++) {
                    var p = lines[i].split("|");
                    if (p.length < 4) continue;
                    var cleanName = p[2].replace(/^alsa_output\./, "").replace(/^alsa_input\./, "").replace(/^bluez_output\./, "BT: ").replace(/\.(analog-stereo|iec958-stereo|a2dp-sink)$/, "").replace(/_/g, " ");
                    var obj = { id: p[2], name: cleanName, active: p[3] === "1" };
                    if (p[0] === "SINK") {
                        outSinks.push(obj);
                        if (obj.active) root.sinkName = obj.name;
                    } else if (p[0] === "SRC") {
                        outSrcs.push(obj);
                        if (obj.active) root.sourceName = obj.name;
                    }
                }
                root.sinks = outSinks;
                root.sources = outSrcs;
            }
        }
    }

    function setSinkVolume(pct) {
        var v = Math.max(0, Math.min(150, Math.round(pct)));
        root.sinkVolume = v;
        cmdProc.command = ["sh", "-c", "if command -v wpctl >/dev/null 2>&1; then wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (v / 100.0).toFixed(2) + "; else pactl set-sink-volume @DEFAULT_SINK@ " + v + "%; fi"];
        cmdProc.running = true;
    }

    function toggleSinkMute() {
        root.sinkMuted = !root.sinkMuted;
        cmdProc.command = ["sh", "-c", "if command -v wpctl >/dev/null 2>&1; then wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; else pactl set-sink-mute @DEFAULT_SINK@ toggle; fi"];
        cmdProc.running = true;
    }

    function setSourceVolume(pct) {
        var v = Math.max(0, Math.min(150, Math.round(pct)));
        root.sourceVolume = v;
        cmdProc.command = ["sh", "-c", "if command -v wpctl >/dev/null 2>&1; then wpctl set-volume @DEFAULT_AUDIO_SOURCE@ " + (v / 100.0).toFixed(2) + "; else pactl set-source-volume @DEFAULT_SOURCE@ " + v + "%; fi"];
        cmdProc.running = true;
    }

    function toggleSourceMute() {
        root.sourceMuted = !root.sourceMuted;
        cmdProc.command = ["sh", "-c", "if command -v wpctl >/dev/null 2>&1; then wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle; else pactl set-source-mute @DEFAULT_SOURCE@ toggle; fi"];
        cmdProc.running = true;
    }

    function setDefaultSink(sinkId) {
        cmdProc.command = ["pactl", "set-default-sink", sinkId];
        cmdProc.running = true;
        refreshTimer.restart();
    }

    function setDefaultSource(srcId) {
        cmdProc.command = ["pactl", "set-default-source", srcId];
        cmdProc.running = true;
        refreshTimer.restart();
    }

    Timer {
        id: refreshTimer
        interval: 250
        repeat: false
        onTriggered: root.refresh()
    }

    Process { id: cmdProc }
}
