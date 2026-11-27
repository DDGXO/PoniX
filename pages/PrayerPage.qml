import QtQuick
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 146

    property bool picking: false
    property string searchQuery: ""

    readonly property var filteredPlaces: {
        var q = searchQuery.trim().toLowerCase();
        var list = PoniPrayer.allPlaces || [];
        var out = [];
        for (var i = 0; i < list.length; i++) {
            var p = list[i];
            if (q.length === 0 || p.label.toLowerCase().indexOf(q) >= 0 || (p.prov && p.prov.toLowerCase().indexOf(q) >= 0)) {
                out.push(p);
                if (out.length >= 8) break;
            }
        }
        return out;
    }

    // ==================== MAIN PRAYER VIEW (1:1 prayer.rs) ====================
    Item {
        visible: !root.picking
        anchors.fill: parent

        // ---- Left Column: Next Prayer, hh:mm:ss Countdown, Time & Place (width = 224)
        Item {
            id: leftCol
            anchors.top: parent.top
            anchors.left: parent.left
            width: 224
            height: 110

            // Next prayer name (y = 0)
            Text {
                x: 0; y: 0
                text: PoniPrayer.nextPrayerName
                font.family: PoniConfig.fontFamily
                font.pixelSize: 15
                font.weight: Font.DemiBold
                color: PoniConfig.colAccent
            }

            // Big Countdown hh:mm:ss + time beside it (y = 22)
            Row {
                x: 0; y: 22
                spacing: 12

                Text {
                    id: countLabel
                    text: PoniPrayer.countdownText
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 28
                    font.weight: Font.Medium
                    color: PoniConfig.colText
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    Text {
                        text: PoniPrayer.nextPrayerTime
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: PoniConfig.colText
                    }

                    Text {
                        text: PoniPrayer.nextIsTomorrow ? "tomorrow" : "today"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        color: PoniConfig.colTextDim
                    }
                }
            }

            // Place label & source (y = 70)
            Column {
                x: 0; y: 70
                spacing: 1

                Text {
                    text: PoniPrayer.activeCity
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: PoniConfig.colText
                    elide: Text.ElideRight
                    width: leftCol.width
                }

                Text {
                    text: PoniPrayer.placeSource
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 10
                    color: PoniConfig.colTextDim
                }
            }
        }

        // ---- Right Column: Hijri, Imsak/Terbit/Qibla, and Today's Day Arc (x = 236)
        Item {
            id: arcArea
            anchors.top: parent.top
            anchors.left: leftCol.right
            anchors.leftMargin: 12
            anchors.right: parent.right
            height: 110

            // Top Info Row (Hijri left, Imsak · Terbit · Qibla right)
            Item {
                id: topInfo
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 15

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: PoniPrayer.hijriLabel
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 10
                    color: PoniConfig.colText
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Imsak " + PoniPrayer.times.imsak + " · Terbit " + PoniPrayer.times.terbit + " · Qibla " + PoniPrayer.qiblaAngle + "° " + PoniPrayer.qiblaCompass
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 10
                    color: PoniConfig.colTextDim
                }
            }

            // Dotted Sine Arc + Sun/Moon + 5 Prayer Dots
            Canvas {
                id: dayArcCanvas
                anchors.fill: parent

                property real herePos: PoniPrayer.dayProgress
                property string nextName: PoniPrayer.nextPrayerName
                property bool daylight: PoniPrayer.isDaylight
                property color accentCol: PoniConfig.colAccent

                onHerePosChanged: requestPaint()
                onNextNameChanged: requestPaint()
                onDaylightChanged: requestPaint()
                onAccentColChanged: requestPaint()
                onWidthChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    var w = width;
                    if (w <= 10) return;

                    var ARC_END_Y = 56;
                    var ARC_TOP_Y = 28;
                    var SLOTS = [0.1, 0.3, 0.5, 0.7, 0.9];
                    var names = ["Subuh", "Dzuhur", "Ashar", "Maghrib", "Isya"];
                    var timesArr = [PoniPrayer.times.subuh, PoniPrayer.times.dzuhur, PoniPrayer.times.ashar, PoniPrayer.times.maghrib, PoniPrayer.times.isya];
                    var here = herePos;

                    function pt(pos) {
                        return {
                            x: pos * w,
                            y: ARC_END_Y - (ARC_END_Y - ARC_TOP_Y) * Math.sin(Math.PI * pos)
                        };
                    }

                    // 1. Dotted arc
                    var n = Math.max(2, Math.round(w / 6.0));
                    for (var i = 0; i <= n; i++) {
                        var pos = i / n;
                        var skip = false;
                        for (var s = 0; s < SLOTS.length; s++) {
                            if (Math.abs((SLOTS[s] - pos) * w) < 11) { skip = true; break; }
                        }
                        if (Math.abs((here - pos) * w) < 12) skip = true;
                        if (skip) continue;

                        var p = pt(pos);
                        ctx.beginPath();
                        ctx.arc(p.x, p.y, 1.15, 0, 2 * Math.PI);
                        ctx.fillStyle = (pos <= here) ? "rgba(255, 255, 255, 0.42)" : "rgba(255, 255, 255, 0.16)";
                        ctx.fill();
                    }

                    // 2. 5 prayer dots
                    var nextIdx = names.indexOf(nextName);
                    for (var j = 0; j < SLOTS.length; j++) {
                        var c = pt(SLOTS[j]);
                        var isNext = (j === nextIdx);
                        var isPast = !isNext && (SLOTS[j] < here);
                        if (!isNext) {
                            ctx.beginPath();
                            ctx.arc(c.x, c.y, 3.5, 0, 2 * Math.PI);
                            ctx.fillStyle = isPast ? "rgba(255, 255, 255, 0.30)" : "rgba(255, 255, 255, 0.62)";
                            ctx.fill();
                        }
                    }

                    // 3. Sun (Terbit..Maghrib) or Moon
                    var m = pt(here);
                    if (daylight) {
                        ctx.beginPath();
                        ctx.arc(m.x, m.y, 8.0, 0, 2 * Math.PI);
                        ctx.fillStyle = "rgba(255, 159, 10, 0.22)";
                        ctx.fill();
                        ctx.beginPath();
                        ctx.arc(m.x, m.y, 5.0, 0, 2 * Math.PI);
                        ctx.fillStyle = "#FF9F0A";
                        ctx.fill();
                    } else {
                        ctx.beginPath();
                        ctx.arc(m.x, m.y, 8.0, 0, 2 * Math.PI);
                        ctx.fillStyle = "rgba(185, 174, 247, 0.22)";
                        ctx.fill();
                        ctx.beginPath();
                        ctx.arc(m.x, m.y, 4.8, 0, 2 * Math.PI);
                        ctx.fillStyle = "#B9AEF7";
                        ctx.fill();
                    }

                    // 4. Next prayer ring
                    if (nextIdx >= 0) {
                        var nc = pt(SLOTS[nextIdx]);
                        ctx.beginPath();
                        ctx.arc(nc.x, nc.y, 9.5, 0, 2 * Math.PI);
                        ctx.strokeStyle = accentCol;
                        ctx.lineWidth = 1.5;
                        ctx.stroke();

                        if (Math.abs(nc.x - m.x) > 9.5) {
                            ctx.beginPath();
                            ctx.arc(nc.x, nc.y, 3.0, 0, 2 * Math.PI);
                            ctx.fillStyle = accentCol;
                            ctx.fill();
                        }
                    }
                }
            }

            // 5 Prayer Labels & Times under dots (y = 64, y = 78)
            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                y: 64
                height: 36

                Repeater {
                    model: [
                        { name: "Subuh", time: PoniPrayer.times.subuh, slot: 0.1 },
                        { name: "Dzuhur", time: PoniPrayer.times.dzuhur, slot: 0.3 },
                        { name: "Ashar", time: PoniPrayer.times.ashar, slot: 0.5 },
                        { name: "Maghrib", time: PoniPrayer.times.maghrib, slot: 0.7 },
                        { name: "Isya", time: PoniPrayer.times.isya, slot: 0.9 }
                    ]

                    Item {
                        required property var modelData
                        width: arcArea.width / 5
                        height: 36

                        property bool isNext: PoniPrayer.nextPrayerName === modelData.name
                        property bool isPast: !isNext && (modelData.slot < PoniPrayer.dayProgress)

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: 0
                            text: parent.modelData.name
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            font.weight: parent.isNext ? Font.DemiBold : Font.Normal
                            color: parent.isNext ? PoniConfig.colAccent : (parent.isPast ? Qt.rgba(1,1,1,0.35) : PoniConfig.colTextDim)
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: 14
                            text: parent.modelData.time
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            font.weight: parent.isNext ? Font.DemiBold : Font.Normal
                            color: parent.isNext ? PoniConfig.colText : (parent.isPast ? Qt.rgba(1,1,1,0.35) : PoniConfig.colText)
                        }
                    }
                }
            }
        }

        // ---- Footer Row (y = 114, h = 28)
        Item {
            anchors.top: parent.top
            anchors.topMargin: 114
            anchors.left: parent.left
            anchors.right: parent.right
            height: 28

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    width: 88
                    height: 24
                    radius: PoniConfig.theme === "pixel" ? 2 : 12
                    color: chArea.containsMouse ? PoniConfig.colSurfaceHover : PoniConfig.colSurface

                    Text {
                        anchors.centerIn: parent
                        text: "Change place"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: PoniConfig.colText
                    }

                    MouseArea {
                        id: chArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.searchQuery = "";
                            root.picking = true;
                        }
                    }
                }

                Rectangle {
                    width: 90
                    height: 24
                    radius: PoniConfig.theme === "pixel" ? 2 : 12
                    color: quranArea.containsMouse ? PoniConfig.colSurfaceHover : PoniConfig.colSurface

                    Row {
                        anchors.centerIn: parent
                        spacing: 5
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Read Quran"
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: PoniConfig.colText
                        }
                        PoniIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: "open"
                            size: 10
                            color: PoniConfig.colTextDim
                        }
                    }

                    MouseArea {
                        id: quranArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally("https://quran.ponix.com")
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                // Sound Picker: Adzan | Tone | Silent
                Rectangle {
                    width: 146
                    height: 24
                    radius: PoniConfig.theme === "pixel" ? 2 : 12
                    color: PoniConfig.colSurface

                    Row {
                        anchors.fill: parent
                        anchors.margins: 2
                        spacing: 2

                        Repeater {
                            model: [
                                { id: "adzan", label: "Adzan" },
                                { id: "tone", label: "Tone" },
                                { id: "silent", label: "Silent" }
                            ]
                            Rectangle {
                                required property var modelData
                                property bool sel: PoniPrayer.soundMode === modelData.id
                                width: (parent.width - 4) / 3
                                height: parent.height
                                radius: PoniConfig.theme === "pixel" ? 2 : 10
                                color: sel ? Qt.rgba(1,1,1,0.18) : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: parent.modelData.label
                                    font.family: PoniConfig.fontFamily
                                    font.pixelSize: 10
                                    font.weight: parent.sel ? Font.DemiBold : Font.Normal
                                    color: parent.sel ? PoniConfig.colText : PoniConfig.colTextDim
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: PoniPrayer.soundMode = parent.modelData.id
                                }
                            }
                        }
                    }
                }

                // "10 min before" switch
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "10 min before"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 11
                        color: PoniConfig.colText
                    }

                    Rectangle {
                        width: 30
                        height: 18
                        radius: PoniConfig.theme === "pixel" ? 2 : 9
                        color: PoniConfig.prayerRemindBefore > 0 ? PoniConfig.colAccent : Qt.rgba(1,1,1,0.16)
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width: 14
                            height: 14
                            radius: PoniConfig.theme === "pixel" ? 1 : 7
                            color: "#ffffff"
                            y: 2
                            x: PoniConfig.prayerRemindBefore > 0 ? 14 : 2
                            Behavior on x { NumberAnimation { duration: 140 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                PoniConfig.prayerRemindBefore = PoniConfig.prayerRemindBefore > 0 ? 0 : 10;
                                PoniConfig.saveSettings();
                            }
                        }
                    }
                }
            }
        }
    }

    // ==================== PLACE PICKER VIEW ====================
    Item {
        visible: root.picking
        anchors.fill: parent

        Item {
            id: pickerTop
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 32

            Rectangle {
                anchors.left: parent.left
                anchors.right: doneBtn.left
                anchors.rightMargin: 10
                height: 32
                radius: 8
                color: PoniConfig.colSurface

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    PoniIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "moon"
                        size: 14
                        color: PoniConfig.colAccent
                    }

                    TextInput {
                        id: searchInput
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 28
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 12
                        color: PoniConfig.colText
                        selectByMouse: true
                        text: root.searchQuery
                        onTextChanged: root.searchQuery = text

                        Text {
                            visible: !searchInput.text && !searchInput.activeFocus
                            text: "Type a city or kab/kota, like Bandung or Jakarta"
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 12
                            color: PoniConfig.colTextFaint
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            Rectangle {
                id: doneBtn
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 56
                height: 24
                radius: 12
                color: PoniConfig.colSurfaceHover

                Text {
                    anchors.centerIn: parent
                    text: "Done"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: PoniConfig.colText
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.picking = false
                }
            }
        }

        Grid {
            anchors.top: pickerTop.bottom
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            columns: 2
            columnSpacing: 12
            rowSpacing: 4

            Repeater {
                model: root.filteredPlaces

                Rectangle {
                    required property var modelData
                    width: (parent.width - 12) / 2
                    height: 24
                    radius: 6
                    color: cityArea.containsMouse ? PoniConfig.colSurface : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: parent.parent.modelData.label
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: PoniConfig.colText
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: parent.parent.modelData.prov || ""
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            color: PoniConfig.colTextDim
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: cityArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            PoniPrayer.setPlace(parent.modelData);
                            root.picking = false;
                        }
                    }
                }
            }
        }
    }
}
