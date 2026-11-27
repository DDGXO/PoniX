import QtQuick
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 256

    property bool adding: false
    property string newCheckType: "http"

    function submitServer() {
        var host = hostInput.text.trim();
        if (host.length === 0) return;
        PoniServers.addServer(nameInput.text, host, portInput.text, userInput.text, root.newCheckType);
        nameInput.text = "";
        hostInput.text = "";
        portInput.text = "";
        userInput.text = "";
        root.adding = false;
    }

    Column {
        anchors.fill: parent
        spacing: 10

        // Header Row
        Item {
            width: parent.width
            height: 24

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Servers & Homelab"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: PoniConfig.colText
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    height: 18
                    width: summaryLbl.width + 12
                    radius: PoniConfig.theme === "pixel" ? 2 : 9
                    color: PoniServers.downCount > 0 ? Qt.rgba(255/255, 69/255, 58/255, 0.18) : Qt.rgba(48/255, 209/255, 88/255, 0.16)

                    Text {
                        id: summaryLbl
                        anchors.centerIn: parent
                        text: PoniServers.upCount + " up · " + PoniServers.downCount + " down"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: PoniServers.downCount > 0 ? PoniConfig.colRed : PoniConfig.colGreen
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    height: 24
                    width: refreshLbl.width + 16
                    radius: PoniConfig.theme === "pixel" ? 2 : 12
                    color: refreshArea.containsMouse ? PoniConfig.colSurfaceHover : PoniConfig.colSurface

                    Text {
                        id: refreshLbl
                        anchors.centerIn: parent
                        text: PoniServers.isChecking ? "Checking..." : "Refresh"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: PoniConfig.colTextDim
                    }

                    MouseArea {
                        id: refreshArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PoniServers.checkAll()
                    }
                }

                Rectangle {
                    height: 24
                    width: addBtnLbl.width + 16
                    radius: PoniConfig.theme === "pixel" ? 2 : 12
                    color: root.adding ? PoniConfig.colAccent : PoniConfig.colSurface

                    Text {
                        id: addBtnLbl
                        anchors.centerIn: parent
                        text: root.adding ? "Cancel" : "+ Add"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: root.adding ? "#ffffff" : PoniConfig.colAccent
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.adding = !root.adding
                    }
                }
            }
        }

        // Inline Add Server Form
        Rectangle {
            visible: root.adding
            width: parent.width
            height: 76
            radius: PoniConfig.theme === "pixel" ? 2 : 10
            color: PoniConfig.colCard
            border.color: PoniConfig.colSurfaceHover
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                Row {
                    width: parent.width
                    height: 26
                    spacing: 6

                    Rectangle {
                        width: (parent.width - 18) * 0.28
                        height: 26
                        radius: PoniConfig.theme === "pixel" ? 2 : 6
                        color: PoniConfig.colSurface
                        TextInput {
                            id: nameInput
                            anchors.fill: parent
                            anchors.margins: 6
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            color: PoniConfig.colText
                            clip: true
                            Text {
                                visible: !nameInput.text && !nameInput.activeFocus
                                text: "Name (e.g. VPS)"
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 11
                                color: PoniConfig.colTextFaint
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - (root.newCheckType === "tcp" ? 18 : 6)) * (root.newCheckType === "tcp" ? 0.42 : 0.72)
                        height: 26
                        radius: PoniConfig.theme === "pixel" ? 2 : 6
                        color: PoniConfig.colSurface
                        TextInput {
                            id: hostInput
                            anchors.fill: parent
                            anchors.margins: 6
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            color: PoniConfig.colText
                            clip: true
                            onAccepted: root.submitServer()
                            Text {
                                visible: !hostInput.text && !hostInput.activeFocus
                                text: root.newCheckType === "http" ? "URL (e.g. dgxo.my.id)" : "Host / IP"
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 11
                                color: PoniConfig.colTextFaint
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Rectangle {
                        visible: root.newCheckType === "tcp"
                        width: (parent.width - 18) * 0.14
                        height: 26
                        radius: PoniConfig.theme === "pixel" ? 2 : 6
                        color: PoniConfig.colSurface
                        TextInput {
                            id: portInput
                            anchors.fill: parent
                            anchors.margins: 6
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            color: PoniConfig.colText
                            clip: true
                            Text {
                                visible: !portInput.text && !portInput.activeFocus
                                text: "22"
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 11
                                color: PoniConfig.colTextFaint
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Rectangle {
                        visible: root.newCheckType === "tcp"
                        width: (parent.width - 18) * 0.16
                        height: 26
                        radius: PoniConfig.theme === "pixel" ? 2 : 6
                        color: PoniConfig.colSurface
                        TextInput {
                            id: userInput
                            anchors.fill: parent
                            anchors.margins: 6
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            color: PoniConfig.colText
                            clip: true
                            Text {
                                visible: !userInput.text && !userInput.activeFocus
                                text: "user"
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 11
                                color: PoniConfig.colTextFaint
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 24

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        Repeater {
                            model: ["http", "tcp", "ping"]
                            Rectangle {
                                required property string modelData
                                width: 46
                                height: 22
                                radius: PoniConfig.theme === "pixel" ? 2 : 6
                                color: root.newCheckType === modelData ? PoniConfig.colAccent : PoniConfig.colSurface
                                Text {
                                    anchors.centerIn: parent
                                    text: parent.modelData.toUpperCase()
                                    font.family: PoniConfig.fontFamily
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    color: root.newCheckType === parent.modelData ? "#ffffff" : PoniConfig.colTextDim
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.newCheckType = parent.modelData
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 68
                        height: 22
                        radius: PoniConfig.theme === "pixel" ? 2 : 6
                        color: PoniConfig.colAccent
                        Text {
                            anchors.centerIn: parent
                            text: "Save"
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: "#ffffff"
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.submitServer()
                        }
                    }
                }
            }
        }

        // Server List
        ListView {
            id: serverList
            width: parent.width
            height: root.adding ? (parent.height - 120) : (parent.height - 34)
            clip: true
            spacing: 6
            model: PoniConfig.serversList

            delegate: Rectangle {
                id: srvRow
                required property var modelData
                width: serverList.width
                height: 44
                radius: PoniConfig.theme === "pixel" ? 2 : 10
                color: PoniConfig.colCard
                border.color: PoniConfig.colSurface
                border.width: 1

                readonly property var st: PoniServers.statusFor(modelData.id)

                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10

                    // Left: Status dot + Name + Host
                    Row {
                        anchors.left: parent.left
                        anchors.right: rightPart.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            anchors.verticalCenter: parent.verticalCenter
                            color: {
                                if (srvRow.st.status === "up") return PoniConfig.colGreen;
                                if (srvRow.st.status === "down") return PoniConfig.colRed;
                                return PoniConfig.colOrange;
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Row {
                                spacing: 6
                                Text {
                                    text: srvRow.modelData.name
                                    font.family: PoniConfig.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                    color: PoniConfig.colText
                                }
                                Rectangle {
                                    height: 14
                                    width: typeLbl.width + 8
                                    radius: 3
                                    color: PoniConfig.colSurface
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: typeLbl
                                        anchors.centerIn: parent
                                        text: (srvRow.modelData.checkType || "tcp").toUpperCase()
                                        font.family: PoniConfig.fontFamily
                                        font.pixelSize: 8
                                        font.weight: Font.Bold
                                        color: PoniConfig.colTextDim
                                    }
                                }
                            }

                            Text {
                                text: srvRow.modelData.host + (srvRow.modelData.checkType === "tcp" ? (":" + (srvRow.modelData.port || 22)) : "")
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 10
                                color: PoniConfig.colTextFaint
                                elide: Text.ElideRight
                            }
                        }
                    }

                    // Right: Latency + Actions
                    Row {
                        id: rightPart
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 86
                            Text {
                                anchors.right: parent.right
                                text: {
                                    if (srvRow.st.status === "up" && srvRow.st.latencyMs >= 0) return srvRow.st.latencyMs + " ms";
                                    if (srvRow.st.status === "down") return "OFFLINE";
                                    return "...";
                                }
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: srvRow.st.status === "up" ? PoniConfig.colGreen : (srvRow.st.status === "down" ? PoniConfig.colRed : PoniConfig.colTextDim)
                            }
                            Text {
                                anchors.right: parent.right
                                text: srvRow.st.detail + (srvRow.st.uptimePct !== undefined ? (" · " + srvRow.st.uptimePct + "%") : "")
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 9
                                color: PoniConfig.colTextFaint
                            }
                        }

                        Rectangle {
                            visible: srvRow.modelData.checkType === "http"
                            width: 38
                            height: 24
                            radius: PoniConfig.theme === "pixel" ? 2 : 6
                            color: openArea.containsMouse ? PoniConfig.colSurfaceHover : PoniConfig.colSurface
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                text: "Open"
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: PoniConfig.colAccent
                            }
                            MouseArea {
                                id: openArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PoniServers.openUrl(srvRow.modelData)
                            }
                        }

                        Rectangle {
                            visible: srvRow.modelData.checkType !== "http"
                            width: 34
                            height: 24
                            radius: PoniConfig.theme === "pixel" ? 2 : 6
                            color: sshArea.containsMouse ? PoniConfig.colSurfaceHover : PoniConfig.colSurface
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                text: "SSH"
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: PoniConfig.colAccent
                            }
                            MouseArea {
                                id: sshArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PoniServers.launchSsh(srvRow.modelData)
                            }
                        }

                        Rectangle {
                            width: 38
                            height: 24
                            radius: PoniConfig.theme === "pixel" ? 2 : 6
                            color: copyArea.containsMouse ? PoniConfig.colSurfaceHover : PoniConfig.colSurface
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                text: "Copy"
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 10
                                color: PoniConfig.colTextDim
                            }
                            MouseArea {
                                id: copyArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PoniServers.copySsh(srvRow.modelData)
                            }
                        }

                        Rectangle {
                            width: 24
                            height: 24
                            radius: PoniConfig.theme === "pixel" ? 2 : 6
                            color: delArea.containsMouse ? Qt.rgba(255/255, 69/255, 58/255, 0.2) : "transparent"
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                text: "x"
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: delArea.containsMouse ? PoniConfig.colRed : PoniConfig.colTextFaint
                            }
                            MouseArea {
                                id: delArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PoniServers.removeServer(srvRow.modelData.id)
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: (PoniConfig.serversList || []).length === 0
                text: "No servers configured. Click + Add to monitor a host."
                font.family: PoniConfig.fontFamily
                font.pixelSize: 11
                color: PoniConfig.colTextFaint
            }
        }
    }
}
