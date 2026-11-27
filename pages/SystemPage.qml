import QtQuick
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 256

    property string activeModule: "cpu" // cpu, memory, drives, network, battery

    Item {
        anchors.fill: parent

        // 1. Top Module Strip (STRIP_H = 40, gap = 10)
        Row {
            id: modStrip
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 40
            spacing: 6

            readonly property var modulesList: {
                var arr = [
                    { id: "cpu", label: "CPU", val: PoniSystem.cpu + "%", col: PoniConfig.colAccent },
                    { id: "memory", label: "Memory", val: PoniSystem.memPct + "%", col: "#0A84FF" },
                    { id: "drives", label: "Drives", val: PoniSystem.diskPct + "%", col: "#30D158" },
                    { id: "network", label: "Network", val: "↓" + PoniSystem.netDownKb + "K", col: "#BF5AF2" }
                ];
                if (PoniSystem.hasBattery) {
                    arr.push({ id: "battery", label: "Battery", val: PoniSystem.batteryPct + "%", col: "#FFD60A" });
                }
                return arr;
            }

            Repeater {
                model: modStrip.modulesList

                Rectangle {
                    required property var modelData
                    property bool sel: root.activeModule === modelData.id
                    width: (modStrip.width - (modStrip.modulesList.length - 1) * 6) / modStrip.modulesList.length
                    height: 40
                    radius: PoniConfig.theme === "pixel" ? 2 : 10
                    color: sel ? Qt.rgba(1, 1, 1, 0.14) : (chipArea.containsMouse ? PoniConfig.colSurfaceHover : PoniConfig.colSurface)
                    border.color: sel ? Qt.rgba(1, 1, 1, 0.22) : "transparent"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: parent.parent.modelData.label
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            color: parent.parent.sel ? PoniConfig.colText : PoniConfig.colTextDim
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: parent.parent.modelData.val
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: parent.parent.modelData.col
                        }
                    }

                    MouseArea {
                        id: chipArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activeModule = parent.modelData.id
                    }
                }
            }
        }

        // 2. 3-Column Body (y = 50, h = 206)
        Item {
            anchors.top: modStrip.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            // ---- Left Column: Ring Gauge Dashboard + Details (DASH_W = 182)
            Item {
                id: dashCol
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: 182

                // Ring Gauge (70x70)
                Canvas {
                    id: ringCanvas
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 4
                    width: 76
                    height: 76

                    property real pct: {
                        if (root.activeModule === "cpu") return PoniSystem.cpu / 100.0;
                        if (root.activeModule === "memory") return PoniSystem.memPct / 100.0;
                        if (root.activeModule === "drives") return PoniSystem.diskPct / 100.0;
                        if (root.activeModule === "battery") return PoniSystem.batteryPct / 100.0;
                        return Math.min(1.0, (PoniSystem.netDownKb + PoniSystem.netUpKb) / 1024.0);
                    }
                    onPctChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        var cx = width / 2, cy = height / 2, r = 32;
                        ctx.beginPath();
                        ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                        ctx.strokeStyle = "rgba(255,255,255,0.12)";
                        ctx.lineWidth = 7;
                        ctx.stroke();

                        var endAngle = -Math.PI / 2 + Math.max(0.02, Math.min(1.0, pct)) * 2 * Math.PI;
                        ctx.beginPath();
                        ctx.arc(cx, cy, r, -Math.PI / 2, endAngle);
                        ctx.strokeStyle = root.activeModule === "cpu" ? "#0A84FF" : (root.activeModule === "memory" ? "#0A84FF" : "#30D158");
                        ctx.lineCap = "round";
                        ctx.lineWidth = 7;
                        ctx.stroke();
                    }

                    Text {
                        anchors.centerIn: parent
                        text: {
                            if (root.activeModule === "cpu") return PoniSystem.cpu + "%";
                            if (root.activeModule === "memory") return PoniSystem.memPct + "%";
                            if (root.activeModule === "drives") return PoniSystem.diskPct + "%";
                            if (root.activeModule === "battery") return PoniSystem.batteryPct + "%";
                            return PoniSystem.netDownKb + "K";
                        }
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        color: PoniConfig.colText
                    }
                }

                // Detail Rows under ring (y = 92)
                Column {
                    y: 92
                    width: parent.width
                    spacing: 5

                    Item {
                        width: parent.width; height: 18
                        Row {
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; spacing: 6
                            Rectangle { width: 7; height: 7; radius: 3.5; color: "#0A84FF"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: root.activeModule === "memory" ? "Used RAM" : "CPU Load"; font.family: PoniConfig.fontFamily; font.pixelSize: 11; color: PoniConfig.colTextDim }
                        }
                        Text {
                            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            text: root.activeModule === "memory" ? (PoniSystem.memUsedGb.toFixed(1) + " GB") : (PoniSystem.cpu + "%")
                            font.family: PoniConfig.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold; color: PoniConfig.colText
                        }
                    }

                    Item {
                        width: parent.width; height: 18
                        Row {
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; spacing: 6
                            Rectangle { width: 7; height: 7; radius: 3.5; color: "#FF453A"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "CPU Temp"; font.family: PoniConfig.fontFamily; font.pixelSize: 11; color: PoniConfig.colTextDim }
                        }
                        Text {
                            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            text: PoniSystem.cpuTemp + "°C"
                            font.family: PoniConfig.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold; color: PoniConfig.colText
                        }
                    }

                    Item {
                        width: parent.width; height: 18
                        Row {
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; spacing: 6
                            Rectangle { width: 7; height: 7; radius: 3.5; color: "#30D158"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "Disk Free"; font.family: PoniConfig.fontFamily; font.pixelSize: 11; color: PoniConfig.colTextDim }
                        }
                        Text {
                            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            text: PoniSystem.diskFreeGb + " GB"
                            font.family: PoniConfig.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold; color: PoniConfig.colText
                        }
                    }

                    Item {
                        width: parent.width; height: 18
                        Row {
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; spacing: 6
                            Rectangle { width: 7; height: 7; radius: 3.5; color: "#BF5AF2"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "Net Up/Dn"; font.family: PoniConfig.fontFamily; font.pixelSize: 11; color: PoniConfig.colTextDim }
                        }
                        Text {
                            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            text: "↓" + PoniSystem.netDownKb + " ↑" + PoniSystem.netUpKb + "K"
                            font.family: PoniConfig.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold; color: PoniConfig.colText
                        }
                    }
                }
            }

            // ---- Middle Column: Usage History Chart (60s)
            Item {
                id: chartCol
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: dashCol.right
                anchors.leftMargin: 16
                anchors.right: procCol.left
                anchors.rightMargin: 16

                Text {
                    id: histTitle
                    anchors.top: parent.top
                    anchors.left: parent.left
                    text: "Usage history"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: PoniConfig.colTextDim
                }

                Rectangle {
                    anchors.top: histTitle.bottom
                    anchors.topMargin: 6
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.05)

                    Canvas {
                        id: histCanvas
                        anchors.fill: parent
                        anchors.margins: 8

                        property var pts: root.activeModule === "memory" ? PoniSystem.memHistory : PoniSystem.cpuHistory
                        onPtsChanged: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var arr = pts || [];
                            if (arr.length < 2) return;

                            // Grid lines
                            ctx.strokeStyle = "rgba(255,255,255,0.07)";
                            ctx.lineWidth = 1;
                            for (var g = 1; g <= 3; g++) {
                                var gy = (height / 4) * g;
                                ctx.beginPath();
                                ctx.moveTo(0, gy);
                                ctx.lineTo(width, gy);
                                ctx.stroke();
                            }

                            ctx.beginPath();
                            for (var i = 0; i < arr.length; i++) {
                                var x = (i / Math.max(1, arr.length - 1)) * width;
                                var y = height - (Math.max(0, Math.min(100, arr[i])) / 100.0) * height;
                                if (i === 0) ctx.moveTo(x, y);
                                else ctx.lineTo(x, y);
                            }
                            ctx.strokeStyle = "#0A84FF";
                            ctx.lineWidth = 2;
                            ctx.stroke();

                            ctx.lineTo(width, height);
                            ctx.lineTo(0, height);
                            ctx.closePath();
                            ctx.fillStyle = "rgba(10, 132, 255, 0.16)";
                            ctx.fill();
                        }
                    }
                }
            }

            // ---- Right Column: Top Processes (TOP_W = 172)
            Item {
                id: procCol
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: 172

                Text {
                    id: procTitle
                    anchors.top: parent.top
                    anchors.left: parent.left
                    text: "Processes"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: PoniConfig.colTextDim
                }

                ListView {
                    anchors.top: procTitle.bottom
                    anchors.topMargin: 6
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    clip: true
                    spacing: 2
                    model: PoniSystem.topProcesses

                    delegate: Item {
                        required property var modelData
                        width: procCol.width
                        height: 22

                        Text {
                            anchors.left: parent.left
                            anchors.right: pVal.left
                            anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            text: parent.modelData.name
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            color: PoniConfig.colText
                            elide: Text.ElideRight
                        }

                        Text {
                            id: pVal
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: parent.modelData.cpu + "%"
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: PoniConfig.colTextDim
                        }
                    }
                }
            }
        }
    }
}
