import QtQuick
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 256

    Column {
        anchors.fill: parent
        spacing: 10

        // Header + City Search
        Item {
            width: parent.width
            height: 26

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: PoniWeather.locationLabel
                font.family: PoniConfig.fontFamily
                font.pixelSize: 13
                font.weight: Font.Bold
                color: PoniConfig.colText
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Rectangle {
                    width: 120
                    height: 24
                    radius: PoniConfig.theme === "pixel" ? 2 : 6
                    color: PoniConfig.colSurface
                    TextInput {
                        id: cityInput
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: TextInput.AlignVCenter
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        color: PoniConfig.colText
                        onAccepted: PoniWeather.refresh(text)
                        Text {
                            visible: !cityInput.text && !cityInput.activeFocus
                            text: "City (or Auto)"
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            color: PoniConfig.colTextFaint
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Rectangle {
                    width: 56
                    height: 24
                    radius: PoniConfig.theme === "pixel" ? 2 : 6
                    color: PoniConfig.colAccent
                    Text {
                        anchors.centerIn: parent
                        text: PoniWeather.isLoading ? "..." : "Update"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PoniWeather.refresh(cityInput.text)
                    }
                }
            }
        }

        // Main Current Card
        Rectangle {
            width: parent.width
            height: 92
            radius: PoniConfig.theme === "pixel" ? 2 : 12
            color: PoniConfig.colCard
            border.color: PoniConfig.colSurface
            border.width: 1

            Row {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 20

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: PoniWeather.tempC + "°C"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 34
                    font.weight: Font.Bold
                    color: PoniConfig.colAccent
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3
                    Text {
                        text: PoniWeather.condition
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: PoniConfig.colText
                    }
                    Text {
                        text: "Feels like " + PoniWeather.feelsLikeC + "°C · Humidity " + PoniWeather.humidity + "% · Wind " + PoniWeather.windKmh + " km/h"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        color: PoniConfig.colTextDim
                    }
                    Text {
                        text: "Rain chance: " + PoniWeather.rainChance + "%"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: parseInt(PoniWeather.rainChance, 10) >= 50 ? PoniConfig.colOrange : PoniConfig.colGreen
                    }
                }
            }
        }

        // Hourly Forecast Cards
        Row {
            width: parent.width
            height: parent.height - 138
            spacing: 8

            Repeater {
                model: PoniWeather.forecast
                Rectangle {
                    required property var modelData
                    width: (parent.width - 24) / 4
                    height: parent.height
                    radius: PoniConfig.theme === "pixel" ? 2 : 10
                    color: PoniConfig.colSurface

                    Column {
                        anchors.centerIn: parent
                        spacing: 3
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.time
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            color: PoniConfig.colTextDim
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.tempC
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: PoniConfig.colText
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Rain " + modelData.rain
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 9
                            color: PoniConfig.colAccent
                        }
                    }
                }
            }
        }
    }
}
