import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root
    implicitWidth: 540
    implicitHeight: 460

    property bool isPlaying: false
    property real scrollSpeed: 1.0
    property int fontSize: 18
    property bool isEditing: false

    Timer {
        id: scrollTimer
        interval: Math.max(16, 50 / root.scrollSpeed)
        running: root.isPlaying && !root.isEditing
        repeat: true
        onTriggered: {
            if (flick.contentY + flick.height < scriptText.height + 40) {
                flick.contentY += 1.0;
            } else {
                root.isPlaying = false;
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Teleprompter"
                color: "#ffffff"
                font.pixelSize: 15
                font.family: "Outfit"
                font.weight: Font.DemiBold
            }

            Text {
                text: "Center script directly under camera"
                color: Qt.rgba(1, 1, 1, 0.4)
                font.pixelSize: 12
                font.family: "Outfit"
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 70
                height: 28
                radius: 6
                color: root.isEditing ? "#f08236" : Qt.rgba(1, 1, 1, 0.08)

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    PoniIcon {
                        name: "edit"
                        size: 13
                        color: root.isEditing ? "#ffffff" : Qt.rgba(1, 1, 1, 0.7)
                    }
                    Text {
                        text: root.isEditing ? "Done" : "Edit"
                        color: root.isEditing ? "#ffffff" : Qt.rgba(1, 1, 1, 0.8)
                        font.pixelSize: 12
                        font.family: "Outfit"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.isEditing) {
                            scriptText.text = scriptEditor.text;
                        } else {
                            scriptEditor.text = scriptText.text;
                            root.isPlaying = false;
                        }
                        root.isEditing = !root.isEditing;
                    }
                }
            }

            Rectangle {
                width: 28
                height: 28
                radius: 6
                color: Qt.rgba(1, 1, 1, 0.08)

                PoniIcon {
                    anchors.centerIn: parent
                    name: "rotate-ccw"
                    size: 14
                    color: Qt.rgba(1, 1, 1, 0.7)
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        flick.contentY = 0;
                        root.isPlaying = false;
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: Qt.rgba(0, 0, 0, 0.35)
            border.color: Qt.rgba(1, 1, 1, 0.08)
            clip: true

            Flickable {
                id: flick
                anchors.fill: parent
                anchors.margins: 14
                visible: !root.isEditing
                contentWidth: width
                contentHeight: scriptText.height + 80
                boundsBehavior: Flickable.StopAtBounds

                Text {
                    id: scriptText
                    width: flick.width
                    wrapMode: Text.WordWrap
                    color: "#ffffff"
                    font.pixelSize: root.fontSize
                    font.family: "Outfit"
                    lineHeight: 1.45
                    text: "Welcome to PoniX for Linux.\n\nKeep your eyes focused near the top notch of your display while delivering presentations or recording videos.\n\nAdjust the scroll speed using the controls below, and toggle play or pause with spacebar or the floating island button.\n\nYour natural eye line aligns right at your webcam lens, making remote interviews, tutorials, and speeches completely natural."
                }
            }

            ScrollView {
                anchors.fill: parent
                anchors.margins: 12
                visible: root.isEditing

                TextArea {
                    id: scriptEditor
                    color: "#ffffff"
                    font.pixelSize: 14
                    font.family: "Outfit"
                    wrapMode: Text.WordWrap
                    background: null
                    selectByMouse: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                width: 80
                height: 34
                radius: 8
                color: root.isPlaying ? Qt.rgba(240/255, 130/255, 54/255, 0.2) : "#f08236"
                border.color: root.isPlaying ? "#f08236" : "transparent"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    PoniIcon {
                        name: root.isPlaying ? "pause" : "play"
                        size: 14
                        color: "#ffffff"
                    }
                    Text {
                        text: root.isPlaying ? "Pause" : "Play"
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.family: "Outfit"
                        font.weight: Font.DemiBold
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!root.isEditing) {
                            root.isPlaying = !root.isPlaying;
                        }
                    }
                }
            }

            Text {
                text: "Speed"
                color: Qt.rgba(1, 1, 1, 0.5)
                font.pixelSize: 12
                font.family: "Outfit"
            }

            RowLayout {
                spacing: 4
                Repeater {
                    model: [0.5, 1.0, 1.5, 2.0]
                    Rectangle {
                        width: 38
                        height: 28
                        radius: 6
                        color: root.scrollSpeed === modelData ? Qt.rgba(240/255, 130/255, 54/255, 0.25) : Qt.rgba(1, 1, 1, 0.08)
                        border.color: root.scrollSpeed === modelData ? "#f08236" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: modelData + "x"
                            color: root.scrollSpeed === modelData ? "#ffffff" : Qt.rgba(1, 1, 1, 0.6)
                            font.pixelSize: 11
                            font.family: "Outfit"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.scrollSpeed = modelData
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "Size"
                color: Qt.rgba(1, 1, 1, 0.5)
                font.pixelSize: 12
                font.family: "Outfit"
            }

            RowLayout {
                spacing: 4
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: Qt.rgba(1, 1, 1, 0.08)
                    Text {
                        anchors.centerIn: parent
                        text: "A-"
                        color: "#ffffff"
                        font.pixelSize: 11
                        font.family: "Outfit"
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.fontSize = Math.max(14, root.fontSize - 2)
                    }
                }
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: Qt.rgba(1, 1, 1, 0.08)
                    Text {
                        anchors.centerIn: parent
                        text: "A+"
                        color: "#ffffff"
                        font.pixelSize: 11
                        font.family: "Outfit"
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.fontSize = Math.min(32, root.fontSize + 2)
                    }
                }
            }
        }
    }
}
