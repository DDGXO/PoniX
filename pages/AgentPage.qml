import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 340

    Process {
        id: dirPickerProc
        command: ["sh", "-c", "zenity --file-selection --directory 2>/dev/null || kdialog --getexistingdirectory ~ 2>/dev/null || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                var p = text.trim();
                if (p.length > 0) PoniAgent.workDir = p;
            }
        }
    }

    // ==================== 1. LAUNCHER STATE ====================
    Column {
        visible: !PoniAgent.isRunning
        anchors.fill: parent
        spacing: 12

        // Header
        Item {
            width: parent.width
            height: 22

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Agent Terminal"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 13
                font.weight: Font.Bold
                color: PoniConfig.colText
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: PoniAgent.installStatus.length > 0 ? PoniAgent.installStatus : "Refresh check"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 10
                color: PoniConfig.colAccent
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PoniAgent.detectBinaries()
                }
            }
        }

        // Engine Selector Cards
        Row {
            width: parent.width
            height: 70
            spacing: 10

            Repeater {
                model: [
                    { id: "agy", label: "Antigravity (agy)", logo: "../assets/antigravity.png", installed: PoniAgent.hasAgy },
                    { id: "claude", label: "Claude Code (claude)", logo: "../assets/claude.png", installed: PoniAgent.hasClaude }
                ]

                Rectangle {
                    required property var modelData
                    property bool selected: PoniAgent.engine === modelData.id
                    width: (parent.width - 10) / 2
                    height: 70
                    radius: PoniConfig.theme === "pixel" ? 2 : 10
                    color: selected ? PoniConfig.colSurfaceHover : PoniConfig.colCard
                    border.color: selected ? PoniConfig.colAccent : PoniConfig.colSurface
                    border.width: selected ? 1.5 : 1

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PoniAgent.engine = parent.modelData.id
                    }

                    Item {
                        anchors.fill: parent
                        anchors.margins: 10

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            Image {
                                width: 32
                                height: 32
                                source: modelData.logo
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4

                                Text {
                                    text: modelData.label
                                    font.family: PoniConfig.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    color: PoniConfig.colText
                                }

                                Row {
                                    spacing: 5
                                    Rectangle {
                                        width: 7
                                        height: 7
                                        radius: 3.5
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: modelData.installed ? PoniConfig.colGreen : PoniConfig.colRed
                                    }
                                    Text {
                                        text: modelData.installed ? "Installed" : "Not installed"
                                        font.family: PoniConfig.fontFamily
                                        font.pixelSize: 10
                                        color: modelData.installed ? PoniConfig.colGreen : PoniConfig.colRed
                                    }
                                }
                            }
                        }

                        Rectangle {
                            visible: !modelData.installed
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 58
                            height: 24
                            radius: PoniConfig.theme === "pixel" ? 2 : 6
                            color: PoniConfig.colAccent

                            Text {
                                anchors.centerIn: parent
                                text: "Install"
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: "#ffffff"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PoniAgent.installEngine(modelData.id)
                            }
                        }
                    }
                }
            }
        }

        // Mode Selector (Normal / Plan / Dangerously)
        Column {
            width: parent.width
            spacing: 6

            Text {
                text: "Execution Mode"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 11
                color: PoniConfig.colTextDim
            }

            Row {
                width: parent.width
                spacing: 8

                Repeater {
                    model: [
                        { id: "normal", label: "Normal", sub: "Ask permissions" },
                        { id: "plan", label: "Plan", sub: "Read-only / plan" },
                        { id: "yolo", label: "Dangerously", sub: "Skip permissions" }
                    ]

                    Rectangle {
                        required property var modelData
                        property bool sel: PoniAgent.mode === modelData.id
                        width: (parent.width - 16) / 3
                        height: 46
                        radius: PoniConfig.theme === "pixel" ? 2 : 8
                        color: sel ? (modelData.id === "yolo" ? Qt.rgba(255/255, 69/255, 58/255, 0.22) : PoniConfig.colSurfaceHover) : PoniConfig.colSurface
                        border.color: sel ? (modelData.id === "yolo" ? PoniConfig.colRed : PoniConfig.colAccent) : "transparent"
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 1
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.label
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: (sel && modelData.id === "yolo") ? PoniConfig.colRed : PoniConfig.colText
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.sub
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 9
                                color: PoniConfig.colTextFaint
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PoniAgent.mode = modelData.id
                        }
                    }
                }
            }
        }

        // Workspace Directory + Continue Flag
        Row {
            width: parent.width
            height: 32
            spacing: 8

            Rectangle {
                width: parent.width - 118
                height: 32
                radius: PoniConfig.theme === "pixel" ? 2 : 8
                color: PoniConfig.colSurface

                TextInput {
                    id: cwdInput
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.right: browseBtn.left
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    text: PoniAgent.workDir
                    onTextChanged: PoniAgent.workDir = text
                    font.family: "monospace"
                    font.pixelSize: 11
                    color: PoniConfig.colText
                    clip: true
                }

                Rectangle {
                    id: browseBtn
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    width: 52
                    height: 24
                    radius: PoniConfig.theme === "pixel" ? 2 : 6
                    color: PoniConfig.colCard
                    Text {
                        anchors.centerIn: parent
                        text: "Folder"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        color: PoniConfig.colTextDim
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { if (!dirPickerProc.running) dirPickerProc.running = true; }
                    }
                }
            }

            Rectangle {
                width: 110
                height: 32
                radius: PoniConfig.theme === "pixel" ? 2 : 8
                color: PoniAgent.continueLast ? PoniConfig.colSurfaceHover : PoniConfig.colSurface
                border.color: PoniAgent.continueLast ? PoniConfig.colAccent : "transparent"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: PoniAgent.continueLast ? "Continue: ON" : "Continue: OFF"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    color: PoniAgent.continueLast ? PoniConfig.colAccent : PoniConfig.colTextDim
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PoniAgent.continueLast = !PoniAgent.continueLast
                }
            }
        }

        // Launch Button
        readonly property bool selectedInstalled: (PoniAgent.engine === "agy" ? PoniAgent.hasAgy : PoniAgent.hasClaude)
        Rectangle {
            width: parent.width
            height: 38
            radius: PoniConfig.theme === "pixel" ? 2 : 10
            color: parent.selectedInstalled ? PoniConfig.colAccent : PoniConfig.colSurface
            opacity: parent.selectedInstalled ? 1.0 : 0.6

            Text {
                anchors.centerIn: parent
                text: parent.parent.selectedInstalled
                    ? ("Start " + (PoniAgent.engine === "agy" ? "Antigravity" : "Claude Code") + " (" + PoniAgent.mode + ")")
                    : ("Install " + PoniAgent.engine + " first")
                font.family: PoniConfig.fontFamily
                font.pixelSize: 12
                font.weight: Font.Bold
                color: parent.parent.selectedInstalled ? "#ffffff" : PoniConfig.colTextDim
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (parent.parent.selectedInstalled) {
                        PoniAgent.startSession();
                        termFocus.forceActiveFocus();
                    } else {
                        PoniAgent.installEngine(PoniAgent.engine);
                    }
                }
            }
        }
    }

    // ==================== 2. EMBEDDED TERMINAL STATE ====================
    Column {
        visible: PoniAgent.isRunning
        anchors.fill: parent
        spacing: 8

        // Terminal Header + Quick Keys + Exit Button
        Item {
            width: parent.width
            height: 26

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Image {
                    width: 15
                    height: 15
                    source: PoniAgent.engine === "agy" ? "../assets/antigravity.png" : "../assets/claude.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: PoniConfig.colGreen
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: (PoniAgent.engine === "agy" ? "agy" : "claude") + " · " + PoniAgent.mode
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: PoniConfig.colText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                Repeater {
                    model: [
                        { label: "/resume", data: "/resume\r" },
                        { label: "!", data: "!" },
                        { label: "Tab", data: "\t" },
                        { label: "Esc", data: "\x1b" },
                        { label: "Ctrl+C", data: "\x03" }
                    ]

                    Rectangle {
                        required property var modelData
                        height: 22
                        width: qLbl.width + 12
                        radius: PoniConfig.theme === "pixel" ? 2 : 6
                        color: PoniConfig.colSurface
                        Text {
                            id: qLbl
                            anchors.centerIn: parent
                            text: modelData.label
                            font.family: "monospace"
                            font.pixelSize: 10
                            color: PoniConfig.colTextDim
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                PoniAgent.sendInput(modelData.data);
                                termFocus.forceActiveFocus();
                            }
                        }
                    }
                }

                // Exit Button
                Rectangle {
                    height: 22
                    width: 48
                    radius: PoniConfig.theme === "pixel" ? 2 : 6
                    color: Qt.rgba(255/255, 69/255, 58/255, 0.24)
                    border.color: PoniConfig.colRed
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Exit"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: PoniConfig.colRed
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PoniAgent.stopSession()
                    }
                }
            }
        }

        // Terminal Viewport
        Rectangle {
            id: termBox
            width: parent.width
            height: parent.height - 64
            radius: PoniConfig.theme === "pixel" ? 2 : 8
            color: "#090b0f"
            border.color: termFocus.activeFocus ? PoniConfig.colAccent : PoniConfig.colSurface
            border.width: 1
            clip: true

            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 1

                Repeater {
                    model: PoniAgent.screenLines
                    Text {
                        required property string modelData
                        width: parent.width
                        height: 14
                        textFormat: Text.RichText
                        text: modelData
                        font.family: "monospace"
                        font.pixelSize: 11
                        color: "#e5e7eb"
                        clip: true
                    }
                }
            }

            FocusScope {
                id: termFocus
                anchors.fill: parent
                focus: PoniAgent.isRunning

                Keys.onPressed: event => {
                    var ctrl = (event.modifiers & Qt.ControlModifier) !== 0;
                    if (ctrl && event.key === Qt.Key_C) {
                        PoniAgent.sendInput("\x03");
                    } else if (ctrl && event.key === Qt.Key_D) {
                        PoniAgent.sendInput("\x04");
                    } else if (ctrl && event.key === Qt.Key_L) {
                        PoniAgent.sendInput("\x0c");
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        PoniAgent.sendInput("\r");
                    } else if (event.key === Qt.Key_Backspace) {
                        PoniAgent.sendInput("\x7f");
                    } else if (event.key === Qt.Key_Tab) {
                        PoniAgent.sendInput("\t");
                    } else if (event.key === Qt.Key_Escape) {
                        PoniAgent.sendInput("\x1b");
                    } else if (event.key === Qt.Key_Up) {
                        PoniAgent.sendInput("\x1b[A");
                    } else if (event.key === Qt.Key_Down) {
                        PoniAgent.sendInput("\x1b[B");
                    } else if (event.key === Qt.Key_Right) {
                        PoniAgent.sendInput("\x1b[C");
                    } else if (event.key === Qt.Key_Left) {
                        PoniAgent.sendInput("\x1b[D");
                    } else if (event.text && event.text.length > 0) {
                        PoniAgent.sendInput(event.text);
                    }
                    event.accepted = true;
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                onClicked: termFocus.forceActiveFocus()
            }
        }

        // Quick Line Input Bar (for paste / fast prompt / slash commands)
        Rectangle {
            width: parent.width
            height: 26
            radius: PoniConfig.theme === "pixel" ? 2 : 6
            color: PoniConfig.colSurface

            TextInput {
                id: quickCmd
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.right: sendBtn.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                font.family: "monospace"
                font.pixelSize: 11
                color: PoniConfig.colText
                clip: true
                onAccepted: {
                    if (text.length > 0) {
                        PoniAgent.sendInput(text + "\r");
                        text = "";
                    } else {
                        PoniAgent.sendInput("\r");
                    }
                    termFocus.forceActiveFocus();
                }
                Text {
                    visible: !quickCmd.text && !quickCmd.activeFocus
                    text: "Click terminal to type directly, or enter command / ! / /resume here..."
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 10
                    color: PoniConfig.colTextFaint
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                id: sendBtn
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                width: 44
                height: 20
                radius: 4
                color: PoniConfig.colAccent
                Text {
                    anchors.centerIn: parent
                    text: "Send"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: "#ffffff"
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        PoniAgent.sendInput(quickCmd.text + "\r");
                        quickCmd.text = "";
                        termFocus.forceActiveFocus();
                    }
                }
            }
        }
    }
}
