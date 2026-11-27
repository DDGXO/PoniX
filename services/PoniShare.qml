pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string qrText: ""
    property string qrImagePath: ""
    property bool serverRunning: false
    property string serverDir: Quickshell.env("HOME") + "/Downloads"
    property string serverUrl: ""
    property int serverPort: 8787

    function generateQr(txt) {
        var t = (txt || "").trim();
        if (t.length === 0) return;
        root.qrText = t;
        var outPath = "/tmp/ponix_qr_" + Date.now() + ".png";
        qrProc.outPath = outPath;
        qrProc.command = [
            "sh", "-c",
            "if command -v qrencode >/dev/null 2>&1; then qrencode -s 6 -m 2 -o \"$1\" \"$2\"; " +
            "else curl -s --max-time 6 -o \"$1\" \"https://api.qrserver.com/v1/create-qr-code/?size=160x160&data=$3\"; fi",
            "_", outPath, t, encodeURIComponent(t)
        ];
        qrProc.running = true;
    }

    Process {
        id: qrProc
        property string outPath: ""
        onExited: (code) => {
            if (code === 0) {
                root.qrImagePath = "file://" + qrProc.outPath;
            }
        }
    }

    function toggleServer(dirPath) {
        if (root.serverRunning) {
            if (httpProc.running) httpProc.signal(15);
            root.serverRunning = false;
            root.serverUrl = "";
            return;
        }
        if (dirPath && dirPath.trim().length > 0) root.serverDir = dirPath.trim();
        ipProc.running = true;
    }

    Process {
        id: ipProc
        command: ["sh", "-c", "ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i==\"src\") print $(i+1)}' | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: {
                var ip = text.trim() || "127.0.0.1";
                var url = "http://" + ip + ":" + root.serverPort;
                root.serverUrl = url;
                root.serverRunning = true;
                httpProc.command = ["python3", "-m", "http.server", String(root.serverPort), "--directory", root.serverDir];
                httpProc.running = true;
                root.generateQr(url);
            }
        }
    }

    Process {
        id: httpProc
        onExited: {
            root.serverRunning = false;
        }
    }
}
