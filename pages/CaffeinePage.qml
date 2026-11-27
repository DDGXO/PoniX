import QtQuick
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 154

    Row {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 16

        // Left Column: Current Caffeine & Last Call (45%)
        Column {
            width: parent.width * 0.45
            height: parent.height
            spacing: 8

            Text {
                text: "Caffeine Metabolism"
                font.family: "Outfit, sans-serif"
                font.pixelSize: 13
                font.weight: Font.Bold
                color: PoniConfig.colText
            }

            Rectangle {
                width: parent.width
                height: 52
                radius: 8
                color: PoniConfig.colCard
                border.color: PoniConfig.colSurface
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "In System Now"
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 10
                        color: PoniConfig.colTextDim
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: PoniCaffeine.currentCaffeineMg + " mg"
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        color: PoniConfig.colOrange
                    }
                }
            }

            // Last call notice
            Row {
                spacing: 6
                PoniIcon {
                    name: "coffee"
                    size: 13
                    color: PoniConfig.colTextDim
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Last Call: " + PoniCaffeine.lastCallTime + " (" + (PoniCaffeine.minutesToLastCall > 0 ? (PoniCaffeine.minutesToLastCall + "m left") : "Passed") + ")"
                    font.family: "Outfit, sans-serif"
                    font.pixelSize: 10
                    color: PoniCaffeine.minutesToLastCall <= 30 ? PoniConfig.colRed : PoniConfig.colTextDim
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Quick add coffee button
            Rectangle {
                width: parent.width
                height: 24
                radius: 6
                color: PoniConfig.colSurface

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    PoniIcon { name: "plus"; size: 11; color: PoniConfig.colAccent }
                    Text {
                        text: "Log Espresso (60mg)"
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: PoniConfig.colText
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: PoniCaffeine.addDrink("Espresso", 60)
                }
            }
        }

        // Divider
        Rectangle {
            width: 1
            height: parent.height - 10
            anchors.verticalCenter: parent.verticalCenter
            color: PoniConfig.colSurface
        }

        // Right Column: Drinks Log Today (51%)
        Column {
            width: parent.width * 0.51
            height: parent.height
            spacing: 6

            Text {
                text: "Drinks Logged Today"
                font.family: "Outfit, sans-serif"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: PoniConfig.colTextDim
            }

            ListView {
                id: drinkList
                width: parent.width
                height: parent.height - 24
                clip: true
                spacing: 4
                model: PoniCaffeine.drinks

                delegate: Rectangle {
                    width: drinkList.width
                    height: 26
                    radius: 6
                    color: PoniConfig.colCard

                    Item {
                        anchors.fill: parent
                        anchors.margins: 6

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.name
                            font.family: "Outfit, sans-serif"
                            font.pixelSize: 11
                            color: PoniConfig.colText
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                text: modelData.time + " · " + modelData.mg + "mg"
                                font.family: "Outfit, sans-serif"
                                font.pixelSize: 10
                                color: PoniConfig.colTextDim
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            PoniIcon {
                                name: "close"
                                size: 11
                                color: PoniConfig.colTextFaint
                                anchors.verticalCenter: parent.verticalCenter
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: PoniCaffeine.removeDrink(modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
