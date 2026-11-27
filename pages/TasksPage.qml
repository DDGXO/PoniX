import QtQuick
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 200

    function addTask() {
        var txt = taskInput.text.trim();
        if (txt.length === 0) return;
        var list = PoniConfig.tasks.slice();
        list.unshift({ id: Date.now(), text: txt, done: false });
        PoniConfig.tasks = list;
        PoniConfig.saveData();
        taskInput.text = "";
    }

    Item {
        anchors.fill: parent

        // 1. Input Row (y = 0, h = 34, MARK_X = 18, TEXT_X = 36)
        Rectangle {
            id: inputRow
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 34
            radius: PoniConfig.theme === "pixel" ? 2 : 8
            color: PoniConfig.colSurface

            PoniIcon {
                x: 10
                anchors.verticalCenter: parent.verticalCenter
                name: "plus"
                size: 16
                color: PoniConfig.colAccent
            }

            TextInput {
                id: taskInput
                anchors.left: parent.left
                anchors.leftMargin: 36
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                font.family: PoniConfig.fontFamily
                font.pixelSize: 12
                color: PoniConfig.colText
                selectByMouse: true

                Text {
                    visible: !taskInput.text && !taskInput.activeFocus
                    text: "Add a task, Enter to save"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 12
                    color: PoniConfig.colTextFaint
                    anchors.verticalCenter: parent.verticalCenter
                }

                onAccepted: root.addTask()
            }
        }

        // 2. Task List (y = 44, h = 124 -> 4 rows x 31px)
        ListView {
            id: tasksList
            anchors.top: parent.top
            anchors.topMargin: 44
            anchors.left: parent.left
            anchors.right: parent.right
            height: 124
            clip: true
            model: PoniConfig.tasks

            delegate: Item {
                id: rowItem
                required property var modelData
                required property int index
                width: tasksList.width
                height: 31

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: rowArea.containsMouse ? Qt.rgba(1,1,1,0.05) : "transparent"
                }

                MouseArea {
                    id: rowArea
                    anchors.fill: parent
                    hoverEnabled: true
                }

                // Circle Checkbox at MARK_X = 18
                Rectangle {
                    x: 9
                    anchors.verticalCenter: parent.verticalCenter
                    width: 18
                    height: 18
                    radius: PoniConfig.theme === "pixel" ? 2 : 9
                    color: rowItem.modelData.done ? PoniConfig.colAccent : "transparent"
                    border.color: rowItem.modelData.done ? PoniConfig.colAccent : PoniConfig.colTextDim
                    border.width: 1.5

                    PoniIcon {
                        visible: rowItem.modelData.done
                        anchors.centerIn: parent
                        name: "check"
                        size: 11
                        color: "#ffffff"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var list = PoniConfig.tasks.slice();
                            list[rowItem.index] = Object.assign({}, list[rowItem.index], { done: !rowItem.modelData.done });
                            PoniConfig.tasks = list;
                            PoniConfig.saveData();
                        }
                    }
                }

                // Task Text at TEXT_X = 36
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 36
                    anchors.right: delBtn.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: rowItem.modelData.text
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 12
                    color: rowItem.modelData.done ? PoniConfig.colTextFaint : PoniConfig.colText
                    font.strikeout: rowItem.modelData.done
                    elide: Text.ElideRight
                }

                // Hover Delete Button
                Item {
                    id: delBtn
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    width: 22
                    height: 22
                    visible: rowArea.containsMouse

                    PoniIcon {
                        anchors.centerIn: parent
                        name: "close"
                        size: 13
                        color: PoniConfig.colTextDim
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var list = PoniConfig.tasks.slice();
                            list.splice(rowItem.index, 1);
                            PoniConfig.tasks = list;
                            PoniConfig.saveData();
                        }
                    }
                }
            }

            Text {
                visible: PoniConfig.tasks.length === 0
                anchors.centerIn: parent
                text: "No tasks yet"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 12
                color: PoniConfig.colTextFaint
            }
        }

        // 3. Footer (y = 176, h = 24): Progress + Clear done
        Item {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 24

            property int doneCount: {
                var c = 0;
                for (var i = 0; i < PoniConfig.tasks.length; i++) {
                    if (PoniConfig.tasks[i].done) c++;
                }
                return c;
            }

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: parent.doneCount + " of " + PoniConfig.tasks.length + " done"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 11
                color: PoniConfig.colTextDim
            }

            Rectangle {
                visible: parent.doneCount > 0
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 78
                height: 22
                radius: 11
                color: clearArea.containsMouse ? PoniConfig.colSurfaceHover : PoniConfig.colSurface

                Text {
                    anchors.centerIn: parent
                    text: "Clear done"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    color: PoniConfig.colText
                }

                MouseArea {
                    id: clearArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var list = [];
                        for (var i = 0; i < PoniConfig.tasks.length; i++) {
                            if (!PoniConfig.tasks[i].done) list.push(PoniConfig.tasks[i]);
                        }
                        PoniConfig.tasks = list;
                        PoniConfig.saveData();
                    }
                }
            }
        }
    }
}
