import QtQuick
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 256

    Column {
        anchors.fill: parent
        spacing: 12

        // Header
        Item {
            width: parent.width
            height: 22

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Audio & Device Mixer"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 13
                font.weight: Font.Bold
                color: PoniConfig.colText
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "Refresh"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 10
                color: PoniConfig.colAccent
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PoniAudio.refresh()
                }
            }
        }

        // Volume Sliders Row (Output + Mic)
        Row {
            width: parent.width
            height: 64
            spacing: 10

            // Output Slider Card
            Rectangle {
                width: (parent.width - 10) / 2
                height: 64
                radius: PoniConfig.theme === "pixel" ? 2 : 10
                color: PoniConfig.colCard
                border.color: PoniConfig.colSurface
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Item {
                        width: parent.width
                        height: 18

                        Text {
                            anchors.left: parent.left
                            anchors.right: muteOutBtn.left
                            anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Output: " + PoniAudio.sinkName
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: PoniConfig.colText
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            id: muteOutBtn
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 44
                            height: 18
                            radius: PoniConfig.theme === "pixel" ? 2 : 9
                            color: PoniAudio.sinkMuted ? Qt.rgba(255/255, 69/255, 58/255, 0.22) : PoniConfig.colSurface

                            Text {
                                anchors.centerIn: parent
                                text: PoniAudio.sinkMuted ? "Muted" : (PoniAudio.sinkVolume + "%")
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                color: PoniAudio.sinkMuted ? PoniConfig.colRed : PoniConfig.colAccent
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PoniAudio.toggleSinkMute()
                            }
                        }
                    }

                    // Slider track
                    Item {
                        width: parent.width
                        height: 16
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 6
                            radius: PoniConfig.theme === "pixel" ? 1 : 3
                            color: PoniConfig.colSurface
                            Rectangle {
                                width: Math.min(1, PoniAudio.sinkVolume / 100.0) * parent.width
                                height: parent.height
                                radius: parent.radius
                                color: PoniAudio.sinkMuted ? PoniConfig.colRed : PoniConfig.colAccent
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPressed: mouse => PoniAudio.setSinkVolume((mouse.x / width) * 100)
                            onPositionChanged: mouse => { if (pressed) PoniAudio.setSinkVolume((mouse.x / width) * 100); }
                        }
                    }
                }
            }

            // Mic Slider Card
            Rectangle {
                width: (parent.width - 10) / 2
                height: 64
                radius: PoniConfig.theme === "pixel" ? 2 : 10
                color: PoniConfig.colCard
                border.color: PoniConfig.colSurface
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Item {
                        width: parent.width
                        height: 18

                        Text {
                            anchors.left: parent.left
                            anchors.right: muteMicBtn.left
                            anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Mic: " + PoniAudio.sourceName
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: PoniConfig.colText
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            id: muteMicBtn
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 44
                            height: 18
                            radius: PoniConfig.theme === "pixel" ? 2 : 9
                            color: PoniAudio.sourceMuted ? Qt.rgba(255/255, 69/255, 58/255, 0.22) : PoniConfig.colSurface

                            Text {
                                anchors.centerIn: parent
                                text: PoniAudio.sourceMuted ? "Muted" : (PoniAudio.sourceVolume + "%")
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                color: PoniAudio.sourceMuted ? PoniConfig.colRed : PoniConfig.colGreen
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PoniAudio.toggleSourceMute()
                            }
                        }
                    }

                    Item {
                        width: parent.width
                        height: 16
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 6
                            radius: PoniConfig.theme === "pixel" ? 1 : 3
                            color: PoniConfig.colSurface
                            Rectangle {
                                width: Math.min(1, PoniAudio.sourceVolume / 100.0) * parent.width
                                height: parent.height
                                radius: parent.radius
                                color: PoniAudio.sourceMuted ? PoniConfig.colRed : PoniConfig.colGreen
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPressed: mouse => PoniAudio.setSourceVolume((mouse.x / width) * 100)
                            onPositionChanged: mouse => { if (pressed) PoniAudio.setSourceVolume((mouse.x / width) * 100); }
                        }
                    }
                }
            }
        }

        // Device Switchers (Sinks + Sources)
        Row {
            width: parent.width
            height: parent.height - 108
            spacing: 10

            Column {
                width: (parent.width - 10) / 2
                height: parent.height
                spacing: 4

                Text {
                    text: "Output Devices"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 10
                    color: PoniConfig.colTextDim
                }

                ListView {
                    width: parent.width
                    height: parent.height - 18
                    clip: true
                    spacing: 4
                    model: PoniAudio.sinks
                    delegate: Rectangle {
                        required property var modelData
                        width: ListView.view.width
                        height: 28
                        radius: PoniConfig.theme === "pixel" ? 2 : 6
                        color: modelData.active ? PoniConfig.colSurfaceHover : PoniConfig.colSurface
                        border.color: modelData.active ? PoniConfig.colAccent : "transparent"
                        border.width: 1

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: Text.AlignVCenter
                            text: modelData.name
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            font.weight: modelData.active ? Font.Bold : Font.Normal
                            color: modelData.active ? PoniConfig.colText : PoniConfig.colTextDim
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PoniAudio.setDefaultSink(parent.modelData.id)
                        }
                    }
                }
            }

            Column {
                width: (parent.width - 10) / 2
                height: parent.height
                spacing: 4

                Text {
                    text: "Input Devices"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 10
                    color: PoniConfig.colTextDim
                }

                ListView {
                    width: parent.width
                    height: parent.height - 18
                    clip: true
                    spacing: 4
                    model: PoniAudio.sources
                    delegate: Rectangle {
                        required property var modelData
                        width: ListView.view.width
                        height: 28
                        radius: PoniConfig.theme === "pixel" ? 2 : 6
                        color: modelData.active ? PoniConfig.colSurfaceHover : PoniConfig.colSurface
                        border.color: modelData.active ? PoniConfig.colGreen : "transparent"
                        border.width: 1

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: Text.AlignVCenter
                            text: modelData.name
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            font.weight: modelData.active ? Font.Bold : Font.Normal
                            color: modelData.active ? PoniConfig.colText : PoniConfig.colTextDim
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PoniAudio.setDefaultSource(parent.modelData.id)
                        }
                    }
                }
            }
        }
    }
}
