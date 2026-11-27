import QtQuick
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 154

    Row {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 20

        // Left Column: Circular Timer Display (45%)
        Item {
            width: parent.width * 0.42
            height: parent.height

            // Large Circular Timer
            Rectangle {
                width: 104
                height: 104
                radius: 52
                color: PoniConfig.colCard
                border.color: PoniConfig.colSurface
                border.width: 4
                anchors.centerIn: parent

                // Progress Indicator Ring
                Rectangle {
                    width: parent.width - 8
                    height: parent.height - 8
                    radius: (parent.width - 8) / 2
                    color: "transparent"
                    border.color: PoniFocus.phase === "work" ? PoniConfig.colOrange : PoniConfig.colGreen
                    border.width: 3
                    opacity: 0.9
                    anchors.centerIn: parent
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            var m = Math.floor(PoniFocus.remainingSec / 60);
                            var s = PoniFocus.remainingSec % 60;
                            return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
                        }
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 22
                        font.weight: Font.Bold
                        color: PoniConfig.colText
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            if (PoniFocus.phase === "work") return "Focus";
                            if (PoniFocus.phase === "short_break") return "Short Break";
                            return "Long Break";
                        }
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: PoniFocus.phase === "work" ? PoniConfig.colOrange : PoniConfig.colGreen
                    }
                }
            }
        }

        // Right Column: Controls, Phases, Sessions (55%)
        Column {
            width: parent.width * 0.54
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            // Phase selector chips
            Row {
                spacing: 8
                Repeater {
                    model: [
                        { id: "work", label: "25m Work" },
                        { id: "short_break", label: "5m Break" },
                        { id: "long_break", label: "15m Rest" }
                    ]
                    Rectangle {
                        required property var modelData
                        width: 72
                        height: 26
                        radius: 13
                        color: PoniFocus.phase === modelData.id ? PoniConfig.colSurfaceHover : PoniConfig.colSurface

                        Text {
                            anchors.centerIn: parent
                            text: parent.modelData.label
                            font.family: "Outfit, sans-serif"
                            font.pixelSize: 10
                            font.weight: PoniFocus.phase === parent.modelData.id ? Font.Bold : Font.Normal
                            color: PoniFocus.phase === parent.modelData.id ? PoniConfig.colText : PoniConfig.colTextDim
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: PoniFocus.setPhase(parent.modelData.id)
                        }
                    }
                }
            }

            // Transport Control Buttons
            Row {
                spacing: 12

                Rectangle {
                    width: 90
                    height: 32
                    radius: 8
                    color: PoniConfig.colAccent

                    Text {
                        anchors.centerIn: parent
                        text: PoniFocus.running ? "Pause" : "Start"
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: PoniFocus.toggle()
                    }
                }

                Rectangle {
                    width: 70
                    height: 32
                    radius: 8
                    color: PoniConfig.colSurface

                    Text {
                        anchors.centerIn: parent
                        text: "Reset"
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 12
                        color: PoniConfig.colText
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: PoniFocus.reset()
                    }
                }
            }

            // Completed Sessions Tally
            Row {
                spacing: 6
                Text {
                    text: "Completed Sessions Today:"
                    font.family: "Outfit, sans-serif"
                    font.pixelSize: 11
                    color: PoniConfig.colTextDim
                }
                Text {
                    text: PoniFocus.completedSessions.toString()
                    font.family: "Outfit, sans-serif"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: PoniConfig.colOrange
                }
            }
        }
    }
}
