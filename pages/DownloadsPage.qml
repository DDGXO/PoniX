import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../services"

Item {
    id: root
    implicitWidth: 540
    implicitHeight: 460

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                height: 38
                radius: 10
                color: Qt.rgba(1, 1, 1, 0.06)
                border.color: urlInput.activeFocus ? "#f08236" : Qt.rgba(1, 1, 1, 0.12)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 8
                    spacing: 6

                    PoniIcon {
                        name: "download"
                        size: 16
                        color: "#999999"
                    }

                    TextInput {
                        id: urlInput
                        Layout.fillWidth: true
                        color: "#ffffff"
                        font.pixelSize: 13
                        font.family: "Outfit"
                        clip: true
                        selectByMouse: true

                        Text {
                            anchors.fill: parent
                            visible: !urlInput.text && !urlInput.activeFocus
                            text: "Paste video or audio URL (YouTube, TikTok, etc)..."
                            color: Qt.rgba(1, 1, 1, 0.35)
                            font.pixelSize: 13
                            font.family: "Outfit"
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Rectangle {
                        width: 26
                        height: 26
                        radius: 6
                        color: pasteArea.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.08)

                        PoniIcon {
                            anchors.centerIn: parent
                            name: "clipboard"
                            size: 14
                            color: "#dddddd"
                        }

                        MouseArea {
                            id: pasteArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                PoniClipboard.fetchCurrent(function(val) {
                                    if (val && val.length > 0) {
                                        urlInput.text = val;
                                    }
                                });
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: 90
                height: 38
                radius: 10
                color: "#f08236"
                opacity: (urlInput.text.trim().length > 0 && !startArea.pressed) ? 1.0 : 0.6

                Text {
                    anchors.centerIn: parent
                    text: "Download"
                    color: "#ffffff"
                    font.pixelSize: 13
                    font.family: "Outfit"
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    id: startArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var target = urlInput.text.trim();
                        if (target.length > 0) {
                            PoniDownloader.startDownload(target, formatSwitch.isVideo ? "video" : "audio", qualitySelect.currentQuality);
                            urlInput.text = "";
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                id: formatSwitch
                property bool isVideo: true
                width: 130
                height: 30
                radius: 8
                color: Qt.rgba(1, 1, 1, 0.07)

                Row {
                    anchors.fill: parent
                    Rectangle {
                        width: 65
                        height: 30
                        radius: 8
                        color: formatSwitch.isVideo ? Qt.rgba(1, 1, 1, 0.18) : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "Video"
                            color: formatSwitch.isVideo ? "#ffffff" : Qt.rgba(1, 1, 1, 0.5)
                            font.pixelSize: 12
                            font.family: "Outfit"
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: formatSwitch.isVideo = true
                        }
                    }
                    Rectangle {
                        width: 65
                        height: 30
                        radius: 8
                        color: !formatSwitch.isVideo ? Qt.rgba(1, 1, 1, 0.18) : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "Audio"
                            color: !formatSwitch.isVideo ? "#ffffff" : Qt.rgba(1, 1, 1, 0.5)
                            font.pixelSize: 12
                            font.family: "Outfit"
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: formatSwitch.isVideo = false
                        }
                    }
                }
            }

            RowLayout {
                id: qualitySelect
                property string currentQuality: "best"
                spacing: 6

                Repeater {
                    model: ["best", "1080p", "720p", "audio"]
                    Rectangle {
                        width: 58
                        height: 28
                        radius: 6
                        color: qualitySelect.currentQuality === modelData ? "#f08236" : Qt.rgba(1, 1, 1, 0.08)

                        Text {
                            anchors.centerIn: parent
                            text: modelData.toUpperCase()
                            color: qualitySelect.currentQuality === modelData ? "#ffffff" : Qt.rgba(1, 1, 1, 0.6)
                            font.pixelSize: 11
                            font.family: "Outfit"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: qualitySelect.currentQuality = modelData
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "Storage: ~/Downloads"
                color: Qt.rgba(1, 1, 1, 0.4)
                font.pixelSize: 11
                font.family: "Outfit"
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(1, 1, 1, 0.08)
        }

        ListView {
            id: downloadList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: PoniDownloader.activeDownloads

            delegate: Rectangle {
                width: downloadList.width
                height: 64
                radius: 10
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 8
                        color: Qt.rgba(240/255, 130/255, 54/255, 0.15)

                        PoniIcon {
                            anchors.centerIn: parent
                            name: modelData.status === "finished" ? "check" : "download"
                            size: 18
                            color: "#f08236"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                Layout.fillWidth: true
                                text: modelData.title || modelData.url
                                color: "#ffffff"
                                font.pixelSize: 13
                                font.family: "Outfit"
                                elide: Text.ElideRight
                            }
                            Text {
                                text: modelData.status === "finished" ? "Done" : (modelData.progress + "%")
                                color: modelData.status === "finished" ? "#50e3c2" : "#f08236"
                                font.pixelSize: 12
                                font.family: "Outfit"
                                font.weight: Font.DemiBold
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 4
                            radius: 2
                            color: Qt.rgba(1, 1, 1, 0.1)

                            Rectangle {
                                width: parent.width * (modelData.progress / 100.0)
                                height: parent.height
                                radius: 2
                                color: modelData.status === "finished" ? "#50e3c2" : "#f08236"
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: modelData.speed || "Starting..."
                                color: Qt.rgba(1, 1, 1, 0.4)
                                font.pixelSize: 10
                                font.family: "Outfit"
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: modelData.eta ? ("ETA " + modelData.eta) : ""
                                color: Qt.rgba(1, 1, 1, 0.4)
                                font.pixelSize: 10
                                font.family: "Outfit"
                            }
                        }
                    }

                    RowLayout {
                        spacing: 6
                        visible: modelData.status === "finished"

                        Rectangle {
                            width: 28
                            height: 28
                            radius: 6
                            color: Qt.rgba(1, 1, 1, 0.1)
                            PoniIcon {
                                anchors.centerIn: parent
                                name: "folder"
                                size: 14
                                color: "#ffffff"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PoniDownloader.openFolder(modelData.path)
                            }
                        }

                        Rectangle {
                            width: 28
                            height: 28
                            radius: 6
                            color: Qt.rgba(1, 1, 1, 0.1)
                            PoniIcon {
                                anchors.centerIn: parent
                                name: "play"
                                size: 14
                                color: "#ffffff"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PoniDownloader.openFile(modelData.path)
                            }
                        }
                    }

                    Rectangle {
                        visible: modelData.status !== "finished"
                        width: 28
                        height: 28
                        radius: 6
                        color: Qt.rgba(1, 1, 1, 0.08)
                        PoniIcon {
                            anchors.centerIn: parent
                            name: "x"
                            size: 14
                            color: Qt.rgba(1, 1, 1, 0.6)
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PoniDownloader.cancelDownload(modelData.id)
                        }
                    }
                }
            }

            Rectangle {
                anchors.centerIn: parent
                visible: downloadList.count === 0
                width: 220
                height: 100
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    PoniIcon {
                        Layout.alignment: Qt.AlignHCenter
                        name: "download"
                        size: 32
                        color: Qt.rgba(1, 1, 1, 0.2)
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No active downloads"
                        color: Qt.rgba(1, 1, 1, 0.35)
                        font.pixelSize: 13
                        font.family: "Outfit"
                    }
                }
            }
        }
    }
}
