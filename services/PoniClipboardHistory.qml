pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var items: [] // [{ id, text, pinned, source }]
    property bool hasCliphist: false
    property string lastClipText: ""

    Timer {
        interval: 1500
        repeat: true
        running: !!PoniConfig.addons["clipboard"]
        triggeredOnStart: true
        onTriggered: root.poll()
    }

    function poll() {
        if (!pollProc.running) pollProc.running = true;
    }

    Process {
        id: pollProc
        command: [
            "sh", "-c",
            "if command -v cliphist >/dev/null 2>&1; then echo 'MODE:CH'; cliphist list 2>/dev/null | head -n 30; " +
            "else echo 'MODE:WL'; wl-paste -n 2>/dev/null || xclip -o -selection clipboard 2>/dev/null || true; fi"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = text;
                if (raw.indexOf("MODE:CH\n") === 0) {
                    root.hasCliphist = true;
                    var lines = raw.substring(8).trim().split("\n");
                    var pinnedMap = {};
                    for (var p = 0; p < root.items.length; p++) {
                        if (root.items[p].pinned) pinnedMap[root.items[p].text] = true;
                    }
                    var out = [];
                    for (var i = 0; i < lines.length; i++) {
                        var ln = lines[i];
                        if (!ln) continue;
                        var tabIdx = ln.indexOf("\t");
                        var cid = tabIdx > 0 ? ln.substring(0, tabIdx) : String(i);
                        var txt = tabIdx > 0 ? ln.substring(tabIdx + 1) : ln;
                        out.push({ id: cid, text: txt, pinned: !!pinnedMap[txt], source: "cliphist" });
                    }
                    root.items = out;
                } else if (raw.indexOf("MODE:WL\n") === 0) {
                    root.hasCliphist = false;
                    var cur = raw.substring(8).trim();
                    if (cur.length > 0 && cur !== root.lastClipText) {
                        root.lastClipText = cur;
                        var list = root.items.filter(function(x) { return x.text !== cur; });
                        list.unshift({ id: String(Date.now()), text: cur, pinned: false, source: "wl" });
                        if (list.length > 30) list = list.slice(0, 30);
                        root.items = list;
                    }
                }
            }
        }
    }

    function copyItem(item) {
        if (!item) return;
        if (item.source === "cliphist") {
            copyProc.command = ["sh", "-c", "printf '%s\\t%s' \"$1\" \"$2\" | cliphist decode | wl-copy", "_", item.id, item.text];
        } else {
            copyProc.command = ["sh", "-c", "printf '%s' \"$1\" | wl-copy 2>/dev/null || printf '%s' \"$1\" | xclip -selection clipboard 2>/dev/null", "_", item.text];
        }
        copyProc.running = true;
        PoniNotices.post("Clipboard", "Copied to clipboard");
    }

    function togglePin(item) {
        var list = root.items.slice();
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === item.id) {
                list[i] = Object.assign({}, list[i], { pinned: !list[i].pinned });
                break;
            }
        }
        root.items = list;
    }

    function clearAll() {
        if (root.hasCliphist) {
            copyProc.command = ["cliphist", "wipe"];
            copyProc.running = true;
        }
        root.items = root.items.filter(function(x) { return x.pinned; });
    }

    Process { id: copyProc }
}
