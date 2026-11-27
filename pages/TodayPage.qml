import QtQuick
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 200

    readonly property var weekDays: ["M", "T", "W", "T", "F", "S", "S"]
    readonly property var calendarCells: {
        var now = new Date();
        var dayOfWeek = now.getDay(); // 0=Sun..6=Sat
        var mondayOffset = (dayOfWeek === 0) ? -6 : (1 - dayOfWeek);
        var start = new Date(now.getFullYear(), now.getMonth(), now.getDate() + mondayOffset);
        var cells = [];
        for (var i = 0; i < 35; i++) {
            var d = new Date(start.getFullYear(), start.getMonth(), start.getDate() + i);
            cells.push({
                num: d.getDate(),
                isToday: (d.getDate() === now.getDate() && d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear()),
                isCurrentMonth: (d.getMonth() === now.getMonth())
            });
        }
        return cells;
    }

    Item {
        anchors.fill: parent

        // ---- Left Column: Date Heading + 5-Week Monday-first Grid (GRID_W = 161)
        Item {
            id: leftCol
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 168

            Column {
                x: 0; y: 0
                spacing: 1

                Text {
                    text: {
                        var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                        return days[new Date().getDay()];
                    }
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    color: PoniConfig.colText
                }

                Text {
                    text: {
                        var now = new Date();
                        var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
                        return now.getDate() + " " + months[now.getMonth()] + " " + now.getFullYear();
                    }
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 11
                    color: PoniConfig.colTextDim
                }
            }

            // Weekday initials (y = 48)
            Row {
                x: 0; y: 48
                width: 161
                height: 16

                Repeater {
                    model: root.weekDays
                    Item {
                        required property string modelData
                        width: 23
                        height: 16
                        Text {
                            anchors.centerIn: parent
                            text: parent.modelData
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: PoniConfig.colTextFaint
                        }
                    }
                }
            }

            // 5-week Grid (y = 66)
            Grid {
                x: 0; y: 66
                width: 161
                columns: 7

                Repeater {
                    model: root.calendarCells
                    Item {
                        required property var modelData
                        width: 23
                        height: 26

                        Rectangle {
                            visible: parent.modelData.isToday
                            anchors.centerIn: parent
                            width: 20
                            height: 20
                            radius: PoniConfig.theme === "pixel" ? 2 : 10
                            color: PoniConfig.colAccent
                        }

                        Text {
                            anchors.centerIn: parent
                            text: parent.modelData.num
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            font.weight: parent.modelData.isToday ? Font.Bold : Font.Normal
                            color: parent.modelData.isToday ? "#ffffff" : (parent.modelData.isCurrentMonth ? PoniConfig.colText : PoniConfig.colTextFaint)
                        }
                    }
                }
            }
        }

        // ---- Right Column: 2x2 Stat Tiles (CPU, Memory, Disk, Battery/Network) matching today.rs Side::Tiles
        Grid {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: leftCol.right
            anchors.leftMargin: 20
            anchors.right: parent.right
            columns: 2
            columnSpacing: 8
            rowSpacing: 8

            readonly property var tiles: [
                { title: "CPU", val: PoniSystem.cpu + "%", sub: PoniSystem.cpuTemp + "°C", col: "#0A84FF" },
                { title: "Memory", val: PoniSystem.memPct + "%", sub: PoniSystem.memUsedGb.toFixed(1) + " / " + PoniSystem.memTotalGb.toFixed(0) + " GB", col: "#30D158" },
                { title: "Disk", val: PoniSystem.diskPct + "%", sub: PoniSystem.diskFreeGb + " GB free", col: "#FF9F0A" },
                {
                    title: PoniSystem.hasBattery ? "Battery" : "Network",
                    val: PoniSystem.hasBattery ? (PoniSystem.batteryPct + "%") : ("↓" + PoniSystem.netDownKb + "K"),
                    sub: PoniSystem.hasBattery ? (PoniSystem.batteryCharging ? "Charging" : "On battery") : ("↑" + PoniSystem.netUpKb + " KB/s"),
                    col: "#BF5AF2"
                }
            ]

            Repeater {
                model: parent.tiles

                Rectangle {
                    required property var modelData
                    width: (parent.width - 8) / 2
                    height: (parent.height - 8) / 2
                    radius: PoniConfig.theme === "pixel" ? 4 : 16
                    color: PoniConfig.colSurface

                    Column {
                        anchors.centerIn: parent
                        spacing: 3

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: parent.parent.modelData.title
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            color: PoniConfig.colTextDim
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: parent.parent.modelData.val
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 20
                            font.weight: Font.Bold
                            color: parent.parent.modelData.col
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: parent.parent.modelData.sub
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            color: PoniConfig.colTextFaint
                        }
                    }
                }
            }
        }
    }
}
