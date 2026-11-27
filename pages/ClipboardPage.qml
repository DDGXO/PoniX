import QtQuick
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 256
    property string searchQuery: ""

    readonly property var filteredItems: {
        var q = searchQuery.trim().toLowerCase();
        var list = PoniClipboardHistory.items || [];
        var pinned = [];
        var normal = [];
        for (var i = 0; i < list.length; i++) {
            var it = list[i];
            if (q.length > 0 && it.text.toLowerCase().indexOf(q) < 0) continue;
            if (it.pinned) pinned.push(it);
            else normal.push(it);
        }
        return pinned.concat(normal);
    }

    Column {
        anchors.fill: parent
        spacing: 10

        Item {
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Clipboard History (" + root.filteredItems.length + ")"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 13
                font.weight: Font.Bold
                color: PoniConfig.colText
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text {
                    text: "Refresh"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 10
                    color: PoniConfig.colAccent
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PoniClipboardHistory.poll()
                    }
                }

                Text {
                    text: "Clear"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 10
                    color: PoniConfig.colRed
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PoniClipboardHistory.clearAll()
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 30
            radius: PoniConfig.theme === "pixel" ? 2 : 8
            color: PoniConfig.colSurface

            TextInput {
                id: searchInput
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                verticalAlignment: TextInput.AlignVCenter
                font.family: PoniConfig.fontFamily
                font.pixelSize: 11
                color: PoniConfig.colText
                onTextChanged: root.searchQuery = text

                Text {
                    visible: !searchInput.text && !searchInput.activeFocus
                    text: "Search clipboard items..."
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 11
                    color: PoniConfig.colTextFaint
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        ListView {
            width: parent.width
            height: parent.height - 74
            clip: true
            spacing: 5
            model: root.filteredItems

            delegate: Rectangle {
                required property var modelData
                width: ListView.view.width
                height: 34
                radius: PoniConfig.theme === "pixel" ? 2 : 8
                color: itemArea.containsMouse ? PoniConfig.colSurfaceHover : PoniConfig.colCard
                border.color: modelData.pinned ? PoniConfig.colAccent : PoniConfig.colSurface
                border.width: 1

                MouseArea {
                    id: itemArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PoniClipboardHistory.copyItem(parent.modelData)
                }

                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 8

                    Text {
                        anchors.left: parent.left
                        anchors.right: pinBtn.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.text.replace(/\s+/g, " ")
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 11
                        color: PoniConfig.colText
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        id: pinBtn
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24
                        height: 22
                        radius: 5
                        color: modelData.pinned ? Qt.rgba(10/255, 132/255, 255/255, 0.2) : "transparent"

                        PoniIcon {
                            anchors.centerIn: parent
                            name: modelData.pinned ? "pinfill" : "pin"
                            size: 12
                            color: modelData.pinned ? PoniConfig.colAccent : PoniConfig.colTextFaint
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PoniClipboardHistory.togglePin(parent.parent.parent.modelData)
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: root.filteredItems.length === 0
                text: "Clipboard history empty"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 11
                color: PoniConfig.colTextFaint
            }
        }
    }
}
