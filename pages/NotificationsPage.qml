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

            Text {
                text: "Notifications History"
                color: "#ffffff"
                font.pixelSize: 15
                font.family: "Outfit"
                font.weight: Font.DemiBold
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 70
                height: 28
                radius: 6
                color: Qt.rgba(1, 1, 1, 0.08)

                Text {
                    anchors.centerIn: parent
                    text: "Clear All"
                    color: Qt.rgba(1, 1, 1, 0.7)
                    font.pixelSize: 11
                    font.family: "Outfit"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PoniNotices.clearHistory()
                }
            }
        }

        ListView {
            id: noticeList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: PoniNotices.history

            delegate: Rectangle {
                width: noticeList.width
                height: 58
                radius: 10
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: Qt.rgba(1, 1, 1, 0.08)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Rectangle {
                        width: 34
                        height: 34
                        radius: 8
                        color: Qt.rgba(240/255, 130/255, 54/255, 0.15)

                        PoniIcon {
                            anchors.centerIn: parent
                            name: "bell"
                            size: 16
                            color: "#f08236"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: modelData.title || "Notification"
                                color: "#ffffff"
                                font.pixelSize: 13
                                font.family: "Outfit"
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: modelData.time || ""
                                color: Qt.rgba(1, 1, 1, 0.35)
                                font.pixelSize: 10
                                font.family: "Outfit"
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.body || ""
                            color: Qt.rgba(1, 1, 1, 0.6)
                            font.pixelSize: 11
                            font.family: "Outfit"
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            Rectangle {
                anchors.centerIn: parent
                visible: noticeList.count === 0
                width: 200
                height: 100
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    PoniIcon {
                        Layout.alignment: Qt.AlignHCenter
                        name: "bell"
                        size: 32
                        color: Qt.rgba(1, 1, 1, 0.2)
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No notifications"
                        color: Qt.rgba(1, 1, 1, 0.35)
                        font.pixelSize: 13
                        font.family: "Outfit"
                    }
                }
            }
        }
    }
}
