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

        // Left Column: Step count dial & stats (45%)
        Column {
            width: parent.width * 0.45
            height: parent.height
            spacing: 6

            Text {
                text: "Daily Activity (Sehat)"
                font.family: "Outfit, sans-serif"
                font.pixelSize: 13
                font.weight: Font.Bold
                color: PoniConfig.colText
            }

            Rectangle {
                width: parent.width
                height: 80
                radius: 10
                color: PoniConfig.colCard
                border.color: PoniConfig.colSurface
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 12

                    // Step Ring
                    Rectangle {
                        width: 50
                        height: 50
                        radius: 25
                        color: "transparent"
                        border.color: PoniConfig.colSurface
                        border.width: 4
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width: parent.width - 4
                            height: parent.height - 4
                            radius: (parent.width - 4) / 2
                            color: "transparent"
                            border.color: PoniConfig.colOrange
                            border.width: 3
                            anchors.centerIn: parent
                        }

                        PoniIcon {
                            anchors.centerIn: parent
                            name: "steps"
                            size: 16
                            color: PoniConfig.colOrange
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: "7,842 / 10,000"
                            font.family: "Outfit, sans-serif"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: PoniConfig.colText
                        }

                        Text {
                            text: "5.4 km · 420 kcal"
                            font.family: "Outfit, sans-serif"
                            font.pixelSize: 11
                            color: PoniConfig.colTextDim
                        }
                    }
                }
            }

            Text {
                text: "Synced from phone via PoniX"
                font.family: "Outfit, sans-serif"
                font.pixelSize: 9
                color: PoniConfig.colTextFaint
            }
        }

        // Divider
        Rectangle {
            width: 1
            height: parent.height - 10
            anchors.verticalCenter: parent.verticalCenter
            color: PoniConfig.colSurface
        }

        // Right Column: 7 Days Step Bar Chart (50%)
        Item {
            width: parent.width * 0.48
            height: parent.height

            Text {
                anchors.top: parent.top
                anchors.left: parent.left
                text: "Last 7 Days Steps"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: PoniConfig.colTextDim
            }

            Row {
                width: parent.width
                height: 70
                spacing: (parent.width - 7 * 18) / 6
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10

                Repeater {
                    model: [
                        { day: "Mon", val: 8200 },
                        { day: "Tue", val: 6400 },
                        { day: "Wed", val: 10500 },
                        { day: "Thu", val: 9100 },
                        { day: "Fri", val: 7842 },
                        { day: "Sat", val: 4200 },
                        { day: "Sun", val: 6800 }
                    ]
                    Column {
                        required property var modelData
                        width: 18
                        height: parent.height
                        spacing: 4

                        Item {
                            width: parent.width
                            height: parent.height - 16

                            Rectangle {
                                width: parent.width
                                height: (modelData.val / 11000.0) * parent.height
                                radius: 3
                                color: modelData.val >= 10000 ? PoniConfig.colGreen : PoniConfig.colOrange
                                anchors.bottom: parent.bottom
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.day
                            font.family: "Outfit, sans-serif"
                            font.pixelSize: 9
                            color: PoniConfig.colTextFaint
                        }
                    }
                }
            }
        }
    }
}
