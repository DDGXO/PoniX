import QtQuick
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 256

    Row {
        anchors.fill: parent
        spacing: 14

        // Left: Controls (QR input + LAN HTTP File Server)
        Column {
            width: parent.width * 0.56
            height: parent.height
            spacing: 10

            Text {
                text: "QR & Local File Share"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 13
                font.weight: Font.Bold
                color: PoniConfig.colText
            }

            // QR Text Input
            Row {
                width: parent.width
                height: 30
                spacing: 6

                Rectangle {
                    width: parent.width - 68
                    height: 30
                    radius: PoniConfig.theme === "pixel" ? 2 : 8
                    color: PoniConfig.colSurface
                    TextInput {
                        id: qrInput
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: TextInput.AlignVCenter
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 11
                        color: PoniConfig.colText
                        onAccepted: PoniShare.generateQr(text)
                        Text {
                            visible: !qrInput.text && !qrInput.activeFocus
                            text: "Text or URL for QR code..."
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            color: PoniConfig.colTextFaint
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Rectangle {
                    width: 62
                    height: 30
                    radius: PoniConfig.theme === "pixel" ? 2 : 8
                    color: PoniConfig.colAccent
                    Text {
                        anchors.centerIn: parent
                        text: "Make QR"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PoniShare.generateQr(qrInput.text)
                    }
                }
            }

            // Paste Clipboard -> QR
            Rectangle {
                width: parent.width
                height: 28
                radius: PoniConfig.theme === "pixel" ? 2 : 6
                color: PoniConfig.colSurface
                Text {
                    anchors.centerIn: parent
                    text: "Generate QR from Clipboard"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    color: PoniConfig.colAccent
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        PoniClipboard.fetchCurrent(function(val) {
                            if (val && val.length > 0) {
                                qrInput.text = val;
                                PoniShare.generateQr(val);
                            }
                        });
                    }
                }
            }

            // LAN HTTP File Server Card
            Rectangle {
                width: parent.width
                height: parent.height - 110
                radius: PoniConfig.theme === "pixel" ? 2 : 10
                color: PoniConfig.colCard
                border.color: PoniShare.serverRunning ? PoniConfig.colGreen : PoniConfig.colSurface
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    Text {
                        text: PoniShare.serverRunning ? ("Sharing: " + PoniShare.serverUrl) : "LAN File Server (Port 8787)"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: PoniShare.serverRunning ? PoniConfig.colGreen : PoniConfig.colText
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Rectangle {
                        width: parent.width
                        height: 26
                        radius: PoniConfig.theme === "pixel" ? 2 : 6
                        color: PoniConfig.colSurface
                        TextInput {
                            id: dirInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: TextInput.AlignVCenter
                            text: PoniShare.serverDir
                            font.family: "monospace"
                            font.pixelSize: 10
                            color: PoniConfig.colTextDim
                            clip: true
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 28
                        radius: PoniConfig.theme === "pixel" ? 2 : 6
                        color: PoniShare.serverRunning ? Qt.rgba(255/255, 69/255, 58/255, 0.22) : PoniConfig.colAccent
                        Text {
                            anchors.centerIn: parent
                            text: PoniShare.serverRunning ? "Stop File Server" : "Start LAN File Server + QR"
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: PoniShare.serverRunning ? PoniConfig.colRed : "#ffffff"
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PoniShare.toggleServer(dirInput.text)
                        }
                    }
                }
            }
        }

        // Right: QR Preview
        Rectangle {
            width: parent.width * 0.41
            height: parent.height
            radius: PoniConfig.theme === "pixel" ? 2 : 10
            color: PoniConfig.colCard
            border.color: PoniConfig.colSurface
            border.width: 1

            Image {
                anchors.centerIn: parent
                width: 170
                height: 170
                source: PoniShare.qrImagePath
                fillMode: Image.PreserveAspectFit
                smooth: false
                visible: PoniShare.qrImagePath.length > 0
            }

            Text {
                anchors.centerIn: parent
                visible: PoniShare.qrImagePath.length === 0
                text: "Scan QR from phone"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 11
                color: PoniConfig.colTextFaint
            }
        }
    }
}
