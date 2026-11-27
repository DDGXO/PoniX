import QtQuick
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 154
    property string activeStock: "BBCA"
    property string timeRange: "1D" // 1D, 1M, 6M, 1Y

    Row {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14

        // Left Column: Watchlist (45%)
        Column {
            width: parent.width * 0.45
            height: parent.height
            spacing: 6

            Item {
                width: parent.width
                height: 18

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "IHSG · 7,248.50"
                    font.family: "Outfit, sans-serif"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: PoniConfig.colGreen
                }
                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "+0.45%"
                    font.family: "Outfit, sans-serif"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: PoniConfig.colGreen
                }
            }

            ListView {
                id: stockList
                width: parent.width
                height: parent.height - 24
                clip: true
                spacing: 4
                model: [
                    { symbol: "BBCA", price: "10,250", change: "+1.25%", isUp: true },
                    { symbol: "BBRI", price: "5,150", change: "+0.80%", isUp: true },
                    { symbol: "TLKM", price: "3,820", change: "-0.52%", isUp: false },
                    { symbol: "ASII", price: "5,400", change: "+0.00%", isUp: true },
                    { symbol: "GOTO", price: "84", change: "-2.32%", isUp: false }
                ]

                delegate: Rectangle {
                    width: stockList.width
                    height: 22
                    radius: 4
                    color: root.activeStock === modelData.symbol ? PoniConfig.colSurfaceHover : "transparent"

                    Item {
                        anchors.fill: parent
                        anchors.margins: 4

                        Text {
                            text: modelData.symbol
                            font.family: "Outfit, sans-serif"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: PoniConfig.colText
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6

                            Text {
                                text: modelData.price
                                font.family: "Outfit, sans-serif"
                                font.pixelSize: 10
                                color: PoniConfig.colTextDim
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 44
                                height: 16
                                radius: 3
                                color: modelData.isUp ? Qt.rgba(48/255, 209/255, 88/255, 0.2) : Qt.rgba(255/255, 69/255, 58/255, 0.2)
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.change
                                    font.family: "Outfit, sans-serif"
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                    color: modelData.isUp ? PoniConfig.colGreen : PoniConfig.colRed
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.activeStock = modelData.symbol
                    }
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

        // Right Column: Chart & Timeframe (51%)
        Column {
            width: parent.width * 0.51
            height: parent.height
            spacing: 6

            Item {
                width: parent.width
                height: 18

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.activeStock + " Performance"
                    font.family: "Outfit, sans-serif"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: PoniConfig.colText
                }

                Row {
                    spacing: 4
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    Repeater {
                        model: ["1D", "1M", "6M", "1Y"]
                        Rectangle {
                            required property var modelData
                            width: 22
                            height: 16
                            radius: 3
                            color: root.timeRange === modelData ? PoniConfig.colAccent : PoniConfig.colSurface

                            Text {
                                anchors.centerIn: parent
                                text: parent.modelData
                                font.family: "Outfit, sans-serif"
                                font.pixelSize: 8
                                font.weight: Font.Bold
                                color: root.timeRange === parent.modelData ? "#ffffff" : PoniConfig.colTextDim
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.timeRange = parent.modelData
                            }
                        }
                    }
                }
            }

            // Interactive Chart Canvas
            Rectangle {
                width: parent.width
                height: 80
                radius: 6
                color: PoniConfig.colCard

                Canvas {
                    anchors.fill: parent
                    anchors.margins: 8
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        ctx.strokeStyle = PoniConfig.colGreen;
                        ctx.lineWidth = 2;
                        ctx.beginPath();
                        ctx.moveTo(0, height * 0.7);
                        ctx.bezierCurveTo(width * 0.3, height * 0.8, width * 0.6, height * 0.3, width, height * 0.2);
                        ctx.stroke();

                        // Fill gradient below curve
                        var grad = ctx.createLinearGradient(0, 0, 0, height);
                        grad.addColorStop(0, "rgba(48, 209, 88, 0.25)");
                        grad.addColorStop(1, "rgba(48, 209, 88, 0.0)");
                        ctx.fillStyle = grad;
                        ctx.lineTo(width, height);
                        ctx.lineTo(0, height);
                        ctx.closePath();
                        ctx.fill();
                    }
                }
            }

            Text {
                text: "Live updates during market hours (IDX)"
                font.family: "Outfit, sans-serif"
                font.pixelSize: 9
                color: PoniConfig.colTextFaint
            }
        }
    }
}
