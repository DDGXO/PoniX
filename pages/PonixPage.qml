import QtQuick
import QtQuick.Controls
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 262

    property bool showAmounts: false
    property string activeDay: "Today"
    property bool undoVisible: false
    property string lastSavedText: ""
    property string statusText: ""

    Timer {
        id: undoTimer
        interval: 10000
        repeat: false
        onTriggered: root.undoVisible = false
    }

    function commitSpend() {
        var text = spendInput.text.trim();
        if (text.length === 0) return;
        root.lastSavedText = text;
        spendInput.text = "";
        root.undoVisible = true;
        undoTimer.restart();
        PoniConfig.addTransaction(text, 25000, "out");
    }

    Item {
        anchors.fill: parent

        // 1. Note a Spend Input Row (y = 0, h = 34)
        Rectangle {
            id: inputRow
            visible: PoniConfig.ponixAccount.connected || (PoniConfig.ponixAccount.transactions || []).length > 0
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 34
            radius: 8
            color: Qt.rgba(1, 1, 1, 0.08)
            border.color: Qt.rgba(1, 1, 1, 0.12)
            border.width: 1

            // Saved state with Undo
            Item {
                visible: root.undoVisible
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10

                Row {
                    anchors.left: parent.left
                    anchors.right: undoButton.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    PoniIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "check"
                        size: 14
                        color: PoniConfig.colGreen
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Saved"
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: "#ffffff"
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "· " + root.lastSavedText
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 12
                        color: PoniConfig.colTextDim
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    id: undoButton
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    width: 54
                    height: 22
                    radius: 11
                    color: undoArea.containsMouse ? Qt.rgba(240/255, 130/255, 54/255, 0.3) : Qt.rgba(240/255, 130/255, 54/255, 0.18)

                    Text {
                        anchors.centerIn: parent
                        text: "Undo"
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: PoniConfig.colAccent
                    }

                    MouseArea {
                        id: undoArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.undoVisible = false;
                            undoTimer.stop();
                        }
                    }
                }
            }

            // Normal typing state
            Row {
                visible: !root.undoVisible
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                spacing: 8

                PoniIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "plus"
                    size: 14
                    color: Qt.rgba(1, 1, 1, 0.5)
                }

                TextInput {
                    id: spendInput
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 32
                    font.family: "Outfit, sans-serif"
                    font.pixelSize: 12
                    color: "#ffffff"
                    selectByMouse: true

                    Text {
                        visible: !spendInput.text && !spendInput.activeFocus
                        text: "Note a spend, like kopi 25rb · Enter to save"
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 12
                        color: Qt.rgba(1, 1, 1, 0.4)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    onAccepted: root.commitSpend()
                }
            }
        }

        // 2. Status Row (y = 34, h = 14)
        Item {
            id: statusRow
            anchors.top: inputRow.bottom
            anchors.left: parent.left
            anchors.leftMargin: 36
            anchors.right: parent.right
            height: 14

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.statusText
                font.family: "Outfit, sans-serif"
                font.pixelSize: 11
                color: PoniConfig.colAccent
                visible: root.statusText.length > 0
            }
        }

        // 3. Segmented Day Strip (y = 49, h = 26)
        Rectangle {
            id: dayStrip
            visible: PoniConfig.ponixAccount.connected || (PoniConfig.ponixAccount.transactions || []).length > 0
            anchors.top: parent.top
            anchors.topMargin: 49
            anchors.left: parent.left
            anchors.right: parent.right
            height: 26
            radius: 13
            color: Qt.rgba(1, 1, 1, 0.06)

            Row {
                anchors.fill: parent
                anchors.margins: 2
                spacing: 2

                readonly property var days: [
                    "Mon", "Tue", "Wed", "Thu", "Fri", "Yesterday", "Today", "Tomorrow", "Later"
                ]

                Repeater {
                    model: parent.days

                    Rectangle {
                        id: dayPill
                        property bool isSelected: root.activeDay === modelData
                        width: (parent.width - (parent.days.length - 1) * 2) / parent.days.length
                        height: parent.height
                        radius: 11
                        color: isSelected ? Qt.rgba(1, 1, 1, 0.16) : (dayArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.family: "Outfit, sans-serif"
                            font.pixelSize: 11
                            font.weight: dayPill.isSelected ? Font.DemiBold : Font.Normal
                            color: dayPill.isSelected ? "#ffffff" : Qt.rgba(1, 1, 1, 0.55)
                        }

                        MouseArea {
                            id: dayArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activeDay = modelData
                        }
                    }
                }
            }
        }

        // 4. Day Heading & Amounts Row (y = 80, h = 24)
        Item {
            id: headRow
            visible: PoniConfig.ponixAccount.connected || (PoniConfig.ponixAccount.transactions || []).length > 0
            anchors.top: parent.top
            anchors.topMargin: 80
            anchors.left: parent.left
            anchors.right: parent.right
            height: 24

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Text {
                    text: root.activeDay + " · " + PoniConfig.ponixAccount.transactions.length + " items"
                    font.family: "Outfit, sans-serif"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: Qt.rgba(1, 1, 1, 0.5)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    visible: PoniConfig.ponixAccount.transactions.length > 0
                    text: root.showAmounts ? ("Balance: Rp " + (PoniConfig.ponixAccount.balance || 0).toLocaleString()) : "+Rp •••  -Rp •••"
                    font.family: "Outfit, sans-serif"
                    font.pixelSize: 11
                    color: Qt.rgba(1, 1, 1, 0.4)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // "Show amounts" / "Hide amounts" eye button pill
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 104
                height: 22
                radius: 11
                color: revealArea.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.06)

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    PoniIcon {
                        name: "eye"
                        size: 13
                        color: Qt.rgba(1, 1, 1, 0.6)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.showAmounts ? "Hide amounts" : "Show amounts"
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: Qt.rgba(1, 1, 1, 0.8)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: revealArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.showAmounts = !root.showAmounts
                }
            }
        }

        // 5. Scrollable Transaction List (or full centered empty state)
        ListView {
            id: txList
            anchors.top: parent.top
            anchors.topMargin: (PoniConfig.ponixAccount.connected || (PoniConfig.ponixAccount.transactions || []).length > 0) ? 112 : 0
            anchors.left: parent.left
            anchors.right: parent.right
            height: (PoniConfig.ponixAccount.connected || (PoniConfig.ponixAccount.transactions || []).length > 0) ? 118 : 230
            clip: true
            spacing: 2
            model: PoniConfig.ponixAccount.transactions

            delegate: Item {
                width: txList.width
                height: 26

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: rowMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                }

                // Disc Icon at MARK_X = 18 (radius 11, centered on x=18)
                Rectangle {
                    id: disc
                    x: 7 // 18 - 11
                    anchors.verticalCenter: parent.verticalCenter
                    width: 22
                    height: 22
                    radius: 11
                    color: modelData.type === "in" ? Qt.rgba(46/255, 204/255, 113/255, 0.22) : Qt.rgba(240/255, 130/255, 54/255, 0.22)

                    PoniIcon {
                        anchors.centerIn: parent
                        name: modelData.type === "in" ? "moneyin" : "moneyout"
                        size: 13
                        color: modelData.type === "in" ? PoniConfig.colGreen : PoniConfig.colAccent
                    }
                }

                // Description starting at TEXT_X = 36 (clean 7px gap from disc)
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 36
                    anchors.right: amountText.left
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text {
                        text: modelData.desc
                        width: Math.min(implicitWidth, parent.width - 50)
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 12
                        color: "#ffffff"
                        elide: Text.ElideRight
                    }

                    Text {
                        text: "12:30"
                        font.family: "Outfit, sans-serif"
                        font.pixelSize: 11
                        color: Qt.rgba(1, 1, 1, 0.4)
                    }
                }

                // Amount on the right
                Text {
                    id: amountText
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.showAmounts ? ((modelData.type === "in" ? "+Rp " : "-Rp ") + modelData.amount.toLocaleString()) : "••••••"
                    font.family: "Outfit, sans-serif"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: modelData.type === "in" ? PoniConfig.colGreen : "#ffffff"
                }

                MouseArea {
                    id: rowMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }

            Text {
                anchors.centerIn: parent
                visible: (PoniConfig.ponixAccount.transactions || []).length === 0
                text: "No exclusive PoniX features active yet"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 12
                color: PoniConfig.colTextFaint
            }
        }

        // 6. Footer Row (y = 234, h = 24)
        Item {
            id: footerRow
            anchors.top: parent.top
            anchors.topMargin: 234
            anchors.left: parent.left
            anchors.right: parent.right
            height: 24

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    width: 7
                    height: 7
                    radius: 3.5
                    color: PoniConfig.colGreen
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        var now = new Date();
                        var h = now.getHours();
                        var m = now.getMinutes();
                        return "Live · updated " + (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m;
                    }
                    font.family: "Outfit, sans-serif"
                    font.pixelSize: 11
                    color: Qt.rgba(1, 1, 1, 0.45)
                }
            }
        }
    }
}
