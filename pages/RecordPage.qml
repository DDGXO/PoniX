import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../components"
import "../services"

Item {
    id: root
    implicitWidth: 540
    implicitHeight: 460

    property bool isRecording: false
    property int recordSeconds: 0
    property string recordMode: "screen"
    property bool includeMic: true
    property string activeFilePath: ""

    Timer {
        id: recordTimer
        interval: 1000
        running: root.isRecording
        repeat: true
        onTriggered: root.recordSeconds += 1
    }

    Process {
        id: recordProc
        onExited: {
            root.isRecording = false;
            root.recordSeconds = 0;
            PoniNotices.post("Recording saved", root.activeFilePath);
        }
    }

    function formatTime(s) {
        var m = Math.floor(s / 60);
        var sec = s % 60;
        return (m < 10 ? "0" + m : m) + ":" + (sec < 10 ? "0" + sec : sec);
    }

    function toggleRecord() {
        if (root.isRecording) {
            recordProc.signal(2);
            root.isRecording = false;
        } else {
            var filename = "recording_" + Date.now() + ".mp4";
            var targetDir = PoniConfig.homePath + "/Videos/PoniX";
            root.activeFilePath = targetDir + "/" + filename;

            var cmd = "mkdir -p " + targetDir + " && ";
            if (root.recordMode === "region") {
                cmd += "slurp | wf-recorder " + (root.includeMic ? "-a " : "") + "-g - -f " + root.activeFilePath;
            } else {
                cmd += "wf-recorder " + (root.includeMic ? "-a " : "") + "-f " + root.activeFilePath;
            }
            recordProc.command = ["bash", "-c", cmd];
            recordProc.running = true;
            root.isRecording = true;
            root.recordSeconds = 0;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Screen Recorder"
                color: "#ffffff"
                font.pixelSize: 15
                font.family: "Outfit"
                font.weight: Font.DemiBold
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: root.isRecording ? "#e04f4f" : Qt.rgba(1, 1, 1, 0.2)
                SequentialAnimation on opacity {
                    running: root.isRecording
                    loops: Animation.Infinite
                    PropertyAnimation { from: 1.0; to: 0.2; duration: 500 }
                    PropertyAnimation { from: 0.2; to: 1.0; duration: 500 }
                }
            }

            Text {
                text: root.isRecording ? formatTime(root.recordSeconds) : "Ready"
                color: root.isRecording ? "#e04f4f" : Qt.rgba(1, 1, 1, 0.4)
                font.pixelSize: 13
                font.family: "Outfit"
                font.weight: Font.DemiBold
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    { id: "screen", label: "Full Screen", icon: "monitor" },
                    { id: "region", label: "Region Area", icon: "crop" }
                ]

                Rectangle {
                    Layout.fillWidth: true
                    height: 54
                    radius: 10
                    color: root.recordMode === modelData.id ? Qt.rgba(240/255, 130/255, 54/255, 0.18) : Qt.rgba(1, 1, 1, 0.05)
                    border.color: root.recordMode === modelData.id ? "#f08236" : Qt.rgba(1, 1, 1, 0.08)

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        PoniIcon {
                            name: modelData.icon
                            size: 16
                            color: root.recordMode === modelData.id ? "#f08236" : "#ffffff"
                        }
                        Text {
                            text: modelData.label
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.family: "Outfit"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.recordMode = modelData.id
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 50
            radius: 10
            color: Qt.rgba(1, 1, 1, 0.05)
            border.color: Qt.rgba(1, 1, 1, 0.08)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                PoniIcon {
                    name: "mic"
                    size: 18
                    color: root.includeMic ? "#50e3c2" : Qt.rgba(1, 1, 1, 0.3)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "Record Audio Microphone"
                        color: "#ffffff"
                        font.pixelSize: 13
                        font.family: "Outfit"
                    }
                    Text {
                        text: "Captures default ALSA / PipeWire microphone stream"
                        color: Qt.rgba(1, 1, 1, 0.4)
                        font.pixelSize: 10
                        font.family: "Outfit"
                    }
                }

                Switch {
                    checked: root.includeMic
                    onToggled: root.includeMic = checked
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 10
            color: Qt.rgba(0, 0, 0, 0.25)
            border.color: Qt.rgba(1, 1, 1, 0.06)

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10

                PoniIcon {
                    Layout.alignment: Qt.AlignHCenter
                    name: "video"
                    size: 32
                    color: root.isRecording ? "#e04f4f" : Qt.rgba(1, 1, 1, 0.3)
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.isRecording ? ("Recording in progress... " + formatTime(root.recordSeconds)) : "Output: ~/Videos/PoniX/"
                    color: root.isRecording ? "#ffffff" : Qt.rgba(1, 1, 1, 0.5)
                    font.pixelSize: 12
                    font.family: "Outfit"
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 44
            radius: 10
            color: root.isRecording ? "#e04f4f" : "#f08236"

            RowLayout {
                anchors.centerIn: parent
                spacing: 8
                PoniIcon {
                    name: root.isRecording ? "square" : "video"
                    size: 16
                    color: "#ffffff"
                }
                Text {
                    text: root.isRecording ? "Stop Recording" : "Start Recording"
                    color: "#ffffff"
                    font.pixelSize: 14
                    font.family: "Outfit"
                    font.weight: Font.DemiBold
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggleRecord()
            }
        }
    }
}
