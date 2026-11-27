pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var entries: [] // [{ id, text, preview }]

    function refresh() {
        listProc.running = true;
    }

    Process {
        id: listProc
        command: ["sh", "-c", "cliphist list 2>/dev/null | head -n 30"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                var lines = data.trim().split("\n");
                var list = [];
                for (var i = 0; i < lines.length; i++) {
                    var l = lines[i];
                    var tabIdx = l.indexOf("\t");
                    if (tabIdx > 0) {
                        var id = l.substring(0, tabIdx);
                        var text = l.substring(tabIdx + 1);
                        list.push({ id: id, text: text, preview: text.slice(0, 100) });
                    }
                }
                root.entries = list;
            }
        }
    }

    function copyEntry(id) {
        if (!id) return;
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "_", id.toString()]);
        PoniNotices.showHud("Copied to clipboard", "clipboard");
    }

    function wipe() {
        Quickshell.execDetached(["cliphist", "wipe"]);
        root.entries = [];
    }

    Component.onCompleted: refresh()
}
