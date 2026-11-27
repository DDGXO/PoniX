import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 150

    Process {
        id: filePickerProc
        command: ["sh", "-c", "zenity --file-selection --multiple --separator='\n' 2>/dev/null || kdialog --getopenfilename ~ 2>/dev/null || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n");
                for (var i = 0; i < lines.length; i++) {
                    if (lines[i].trim().length > 0) {
                        PoniShelf.addFile(lines[i].trim());
                    }
                }
            }
        }
    }

    Row {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // Left Column: Shelf File List (60%)
        Column {
            width: parent.width * 0.60
            height: parent.height
            spacing: 8

            Item {
                width: parent.width
                height: 18

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Temporary Shelf (" + PoniShelf.files.length + ")"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: PoniConfig.colText
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Text {
                        text: "+ Add file"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: PoniConfig.colAccent

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!filePickerProc.running) filePickerProc.running = true;
                            }
                        }
                    }

                    Text {
                        visible: PoniShelf.files.length > 0
                        text: "Clear all"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 11
                        color: PoniConfig.colRed

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PoniShelf.clearAll()
                        }
                    }
                }
            }

            // Dropzone & File List
            ListView {
                id: shelfList
                width: parent.width
                height: parent.height - 30
                clip: true
                spacing: 6
                model: PoniShelf.files

                delegate: Rectangle {
                    id: shelfItem
                    required property var modelData
                    width: shelfList.width
                    height: 36
                    radius: 8
                    color: PoniConfig.colCard
                    border.color: dragMouse.containsMouse ? PoniConfig.colAccent : PoniConfig.colSurface
                    border.width: 1

                    Drag.active: dragMouse.drag.active
                    Drag.dragType: Drag.Automatic
                    Drag.supportedActions: Qt.CopyAction
                    Drag.mimeData: ({ "text/uri-list": "file://" + shelfItem.modelData.path })

                    MouseArea {
                        id: dragMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                        drag.target: dragProxy
                        onPressed: {
                            dragProxy.x = 0;
                            dragProxy.y = 0;
                        }
                    }

                    Item {
                        id: dragProxy
                        width: 1; height: 1
                        Drag.active: dragMouse.drag.active
                        Drag.dragType: Drag.Automatic
                        Drag.supportedActions: Qt.CopyAction
                        Drag.mimeData: ({ "text/uri-list": "file://" + shelfItem.modelData.path })
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 8

                        Rectangle {
                            width: 22
                            height: 22
                            radius: 4
                            color: PoniConfig.colSurface
                            clip: true
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.fill: parent
                                source: shelfItem.modelData.isImage ? ("file://" + shelfItem.modelData.path) : ""
                                fillMode: Image.PreserveAspectCrop
                                visible: shelfItem.modelData.isImage
                            }

                            PoniIcon {
                                anchors.centerIn: parent
                                name: shelfItem.modelData.icon === "image" ? "tray" : "file"
                                size: 14
                                color: PoniConfig.colAccent
                                visible: !shelfItem.modelData.isImage
                            }
                        }

                        Text {
                            width: parent.width - 148
                            text: shelfItem.modelData.name
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            color: PoniConfig.colText
                            elide: Text.ElideMiddle
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6

                            Rectangle {
                                width: 38
                                height: 22
                                radius: 6
                                color: PoniConfig.colSurface
                                Text {
                                    anchors.centerIn: parent
                                    text: "Copy"
                                    font.family: PoniConfig.fontFamily
                                    font.pixelSize: 10
                                    color: PoniConfig.colAccent
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: PoniShelf.copyFile(shelfItem.modelData.path)
                                }
                            }

                            Rectangle {
                                width: 38
                                height: 22
                                radius: 6
                                color: PoniConfig.colSurface
                                Text {
                                    anchors.centerIn: parent
                                    text: "Open"
                                    font.family: PoniConfig.fontFamily
                                    font.pixelSize: 10
                                    color: PoniConfig.colText
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: PoniShelf.openFile(shelfItem.modelData.path)
                                }
                            }

                            PoniIcon {
                                name: "close"
                                size: 14
                                color: PoniConfig.colTextFaint
                                anchors.verticalCenter: parent.verticalCenter
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: PoniShelf.removeFile(shelfItem.modelData.path)
                                }
                            }
                        }
                    }
                }

                // Empty state
                Rectangle {
                    visible: PoniShelf.files.length === 0
                    anchors.fill: parent
                    radius: 8
                    color: PoniConfig.colCard
                    border.color: dropArea.containsDrag ? PoniConfig.colAccent : PoniConfig.colSurface
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        PoniIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "tray"
                            size: 24
                            color: PoniConfig.colTextDim
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Drag files here or click + Add file"
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            color: PoniConfig.colTextFaint
                        }
                    }
                }

                // Full-area DropArea (always active even when files exist)
                DropArea {
                    id: dropArea
                    anchors.fill: parent
                    onEntered: drag => {
                        drag.acceptProposedAction();
                    }
                    onDropped: drop => {
                        drop.acceptProposedAction();
                        if (drop.hasUrls) {
                            for (var i = 0; i < drop.urls.length; i++) {
                                PoniShelf.addFile(drop.urls[i]);
                            }
                        } else if (drop.hasText) {
                            PoniShelf.addFile(drop.text);
                        }
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

        // Right Column: Phone Drop via LAN (40%)
        Column {
            width: parent.width * 0.36
            height: parent.height
            spacing: 8

            Text {
                text: "Phone Drop"
                font.family: "Outfit, sans-serif"
                font.pixelSize: 13
                font.weight: Font.Bold
                color: PoniConfig.colText
            }

            Rectangle {
                width: parent.width
                height: parent.height - 30
                radius: 10
                color: PoniConfig.colCard
                border.color: PoniConfig.colSurface
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        width: 54
                        height: 54
                        radius: 8
                        color: "#ffffff"
                        anchors.horizontalCenter: parent.horizontalCenter

                        // QR icon placeholder
                        PoniIcon {
                            anchors.centerIn: parent
                            name: "phone"
                            size: 28
                            color: "#1c1c1c"
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Scan with Phone Camera"
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: PoniConfig.colText
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: PoniShelf.qrUrl
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 9
                        color: PoniConfig.colTextFaint
                    }
                }
            }
        }
    }
}
