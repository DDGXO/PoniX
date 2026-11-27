import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 256

    property string pickedColor: "#0a84ff"
    property var colorHistory: ["#0a84ff", "#f08236", "#30d158", "#bf5af2"]
    property string lastShotPath: ""
    property string statusMsg: "Ready"

    function pickColor() {
        root.statusMsg = "Pick a pixel on screen...";
        colorProc.running = true;
    }

    function takeShot(region) {
        var dir = (Quickshell.env("HOME") || "/home") + "/Pictures/PoniX";
        var outPath = dir + "/shot_" + Date.now() + ".png";
        shotProc.outPath = outPath;
        root.statusMsg = region ? "Select region..." : "Capturing screen...";
        if (region) {
            shotProc.command = ["sh", "-c", "mkdir -p \"$1\" && geom=$(slurp 2>/dev/null) && [ -n \"$geom\" ] && grim -g \"$geom\" \"$2\" && wl-copy < \"$2\" 2>/dev/null || true", "_", dir, outPath];
        } else {
            shotProc.command = ["sh", "-c", "mkdir -p \"$1\" && grim \"$2\" && wl-copy < \"$2\" 2>/dev/null || true", "_", dir, outPath];
        }
        shotProc.running = true;
    }

    Process {
        id: colorProc
        command: ["sh", "-c", "hyprpicker -a -n 2>/dev/null || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                var hex = text.trim();
                if (/^#[0-9A-Fa-f]{6}$/.test(hex)) {
                    root.pickedColor = hex;
                    var hist = root.colorHistory.filter(function(c) { return c.toLowerCase() !== hex.toLowerCase(); });
                    hist.unshift(hex);
                    if (hist.length > 8) hist = hist.slice(0, 8);
                    root.colorHistory = hist;
                    root.statusMsg = "Copied " + hex;
                } else {
                    root.statusMsg = "hyprpicker cancelled or missing";
                }
            }
        }
    }

    Process {
        id: shotProc
        property string outPath: ""
        onExited: {
            checkShotProc.command = ["sh", "-c", "test -f \"$1\" && echo OK || echo NO", "_", shotProc.outPath];
            checkShotProc.running = true;
        }
    }

    Process {
        id: checkShotProc
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim() === "OK") {
                    root.lastShotPath = "file://" + shotProc.outPath;
                    root.statusMsg = "Saved & copied to clipboard";
                } else {
                    root.statusMsg = "Capture cancelled";
                }
            }
        }
    }

    Process { id: copyColProc }

    Row {
        anchors.fill: parent
        spacing: 14

        // Left Column: Color Picker + Screenshot Actions
        Column {
            width: parent.width * 0.48
            height: parent.height
            spacing: 10

            Text {
                text: "Color Picker & Capture"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 13
                font.weight: Font.Bold
                color: PoniConfig.colText
            }

            // Color Picker Card
            Rectangle {
                width: parent.width
                height: 92
                radius: PoniConfig.theme === "pixel" ? 2 : 10
                color: PoniConfig.colCard
                border.color: PoniConfig.colSurface
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Row {
                        width: parent.width
                        spacing: 10

                        Rectangle {
                            width: 32
                            height: 32
                            radius: PoniConfig.theme === "pixel" ? 2 : 8
                            color: root.pickedColor
                            border.color: "#ffffff"
                            border.width: 1
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1
                            Text {
                                text: root.pickedColor.toUpperCase()
                                font.family: "monospace"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: PoniConfig.colText
                            }
                            Text {
                                text: root.statusMsg
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 9
                                color: PoniConfig.colTextFaint
                            }
                        }

                        Item { width: 10; height: 1 }

                        Rectangle {
                            width: 70
                            height: 26
                            radius: PoniConfig.theme === "pixel" ? 2 : 6
                            color: PoniConfig.colAccent
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                text: "Pick"
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: "#ffffff"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.pickColor()
                            }
                        }
                    }

                    // Recent Swatches
                    Row {
                        spacing: 6
                        Repeater {
                            model: root.colorHistory
                            Rectangle {
                                required property string modelData
                                width: 20
                                height: 20
                                radius: PoniConfig.theme === "pixel" ? 2 : 5
                                color: modelData
                                border.color: Qt.rgba(1,1,1,0.3)
                                border.width: 1
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.pickedColor = parent.modelData;
                                        copyColProc.command = ["sh", "-c", "printf '%s' \"$1\" | wl-copy", "_", parent.modelData];
                                        copyColProc.running = true;
                                        root.statusMsg = "Copied " + parent.modelData;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Screenshot Buttons
            Row {
                width: parent.width
                spacing: 8

                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 36
                    radius: PoniConfig.theme === "pixel" ? 2 : 8
                    color: PoniConfig.colSurface
                    Text {
                        anchors.centerIn: parent
                        text: "Region Shot"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: PoniConfig.colText
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.takeShot(true)
                    }
                }

                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 36
                    radius: PoniConfig.theme === "pixel" ? 2 : 8
                    color: PoniConfig.colSurface
                    Text {
                        anchors.centerIn: parent
                        text: "Full Screen"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: PoniConfig.colText
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.takeShot(false)
                    }
                }
            }
        }

        // Right Column: Screenshot Preview
        Rectangle {
            width: parent.width * 0.49
            height: parent.height
            radius: PoniConfig.theme === "pixel" ? 2 : 10
            color: PoniConfig.colCard
            border.color: PoniConfig.colSurface
            border.width: 1
            clip: true

            Image {
                anchors.fill: parent
                anchors.margins: 6
                source: root.lastShotPath
                fillMode: Image.PreserveAspectFit
                visible: root.lastShotPath.length > 0
            }

            Text {
                anchors.centerIn: parent
                visible: root.lastShotPath.length === 0
                text: "Screenshot preview\n(saved to ~/Pictures/PoniX)"
                horizontalAlignment: Text.AlignHCenter
                font.family: PoniConfig.fontFamily
                font.pixelSize: 11
                color: PoniConfig.colTextFaint
            }
        }
    }
}
