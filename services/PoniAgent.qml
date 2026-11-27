pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool hasAgy: false
    property bool hasClaude: false
    property bool isInstalling: false
    property string installStatus: ""

    property string engine: "agy" // "agy" | "claude"
    property string mode: "normal" // "normal" | "plan" | "yolo"
    property bool continueLast: false
    property string workDir: Quickshell.env("HOME") || "/home"

    property bool isRunning: false
    property var screenLines: []

    readonly property string bridgePath: Quickshell.shellDir + "/scripts/pty_bridge.py"

    Component.onCompleted: detectBinaries()

    function detectBinaries() {
        if (!detectProc.running) detectProc.running = true;
    }

    Process {
        id: detectProc
        command: ["sh", "-c", "a=$(command -v agy 2>/dev/null); c=$(command -v claude 2>/dev/null); echo \"${a:+1}|${c:+1}\""]
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split("|");
                root.hasAgy = (parts[0] === "1");
                root.hasClaude = (parts[1] === "1");
                if (!root.hasAgy && root.hasClaude) root.engine = "claude";
            }
        }
    }

    function installEngine(eng) {
        if (root.isInstalling) return;
        root.isInstalling = true;
        root.installStatus = "Installing " + eng + "...";
        var installCmd = (eng === "claude")
            ? "npm install -g @anthropic-ai/claude-code || curl -fsSL https://claude.ai/install.sh | bash"
            : "npm install -g @google/antigravity || curl -fsSL https://antigravity.google/install.sh | bash";
        installProc.command = [
            "sh", "-c",
            "for term in \"$TERMINAL\" kitty alacritty foot wezterm ghostty gnome-terminal xterm; do if [ -n \"$term\" ] && command -v \"$term\" >/dev/null 2>&1; then \"$term\" -e sh -c \"" + installCmd + "; echo 'Done. Press Enter...'; read _\"; exit 0; fi; done; " + installCmd
        ];
        installProc.running = true;
    }

    Process {
        id: installProc
        onExited: {
            root.isInstalling = false;
            root.installStatus = "";
            root.detectBinaries();
        }
    }

    function startSession() {
        if (root.isRunning) return;
        var args = ["python3", "-u", root.bridgePath, "78", "15", root.workDir || (Quickshell.env("HOME") || "/home")];

        if (root.engine === "claude") {
            args.push("claude");
            if (root.mode === "plan") {
                args.push("--permission-mode");
                args.push("plan");
            } else if (root.mode === "yolo") {
                args.push("--dangerously-skip-permissions");
            }
            if (root.continueLast) args.push("-c");
        } else {
            args.push("agy");
            if (root.mode === "plan") {
                args.push("--mode");
                args.push("plan");
            } else if (root.mode === "yolo") {
                args.push("--dangerously-skip-permissions");
            }
            if (root.continueLast) args.push("-c");
        }

        root.screenLines = ["Starting " + root.engine + " (" + root.mode + ")..."];
        root.isRunning = true;
        ptyProc.command = args;
        ptyProc.running = true;
    }

    function sendInput(data) {
        if (!root.isRunning || !ptyProc.running) return;
        ptyProc.write(JSON.stringify({ type: "input", data: data }) + "\n");
    }

    function stopSession() {
        if (ptyProc.running) {
            ptyProc.write(JSON.stringify({ type: "quit" }) + "\n");
            ptyProc.signal(15);
        }
        root.isRunning = false;
        root.screenLines = [];
    }

    Process {
        id: ptyProc
        stdout: SplitParser {
            onRead: line => {
                try {
                    var msg = JSON.parse(line);
                    if (msg.lines) root.screenLines = msg.lines;
                    if (msg.running === false) {
                        root.isRunning = false;
                    }
                } catch(e) {}
            }
        }
        onExited: {
            root.isRunning = false;
        }
    }
}
