import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Effects
import "../services"
import "../pages"

Item {
    id: root

    property bool isExpanded: false
    property string activeTab: "music"
    property bool isPinned: false
    property var backdropSource: null
    property bool backdropHasContent: false
    property vector2d backdropOffset: Qt.vector2d(0, 0)
    property vector2d backdropSize: Qt.vector2d(1, 1)

    // Exact PoniX Resting Geometry
    property int restingWidth: {
        if (islandViews.mode === "media") {
            if (PoniConfig.showLyrics && PoniMedia.currentLyricText.length > 0) {
                return Math.min(360, Math.max(180, 84 + Math.round(lyricMeasure.width)));
            }
            return PoniMedia.isPeeking ? 300 : 120;
        }
        if (islandViews.mode === "focus") return 96;
        if (islandViews.mode === "media_timer") return 132;
        if (islandViews.mode === "prayer") return 204;
        if (islandViews.mode === "game") return 276;
        if (islandViews.mode === "recording" || islandViews.mode === "download") return 96;
        if (PoniConfig.idleLook === "hidden") return 140;
        if (PoniConfig.idleLook === "minimal") return 150;
        if (PoniConfig.idleLook === "eyes") return 118;
        if (PoniConfig.idleLook === "status") return 190;

        // Idle Clock: 84 DIPs for 24h, 104 DIPs for 12h
        var base = PoniConfig.use24h ? 84 : 104;
        var badge = 0;
        if (PoniSystem.batteryCharging) {
            badge = 22;
        } else if (PoniSystem.hasBattery && PoniSystem.batteryPct <= 20) {
            badge = 34;
        }
        return base + badge;
    }

    property int restingHeight: {
        if (islandViews.mode === "media" || islandViews.mode === "focus" || islandViews.mode === "prayer" || islandViews.mode === "game") return 32;
        if (PoniConfig.idleLook === "hidden") return islandMouseArea.containsMouse ? 24 : 3;
        if (PoniConfig.idleLook === "minimal") return 26;
        return 30;
    }

    // Exact PoniX Expanded Geometry
    property int expandedWidth: 620
    property int expandedHeight: {
        var contentH = 256;
        switch (activeTab) {
            case "music": contentH = (PoniMedia.title ? 148 : 124); break;
            case "focus": contentH = 144; break;
            case "health": contentH = 144; break;
            case "record": contentH = 144; break;
            case "prayer": contentH = 146; break;
            case "shelf": contentH = 150; break;
            case "notes": contentH = 180; break;
            case "today": contentH = 200; break;
            case "tasks": contentH = 200; break;
            case "script": contentH = 200; break;
            case "ielts": contentH = 248; break;
            case "system": contentH = 256; break;
            case "stocks": contentH = 256; break;
            case "caffeine": contentH = 256; break;
            case "downloads": contentH = 256; break;
            case "addons": contentH = 256; break;
            case "servers": contentH = 256; break;
            case "agent": contentH = 340; break;
            case "audio": contentH = 256; break;
            case "clipboard": contentH = 256; break;
            case "capture": contentH = 256; break;
            case "weather": contentH = 256; break;
            case "share": contentH = 256; break;
            case "translate": contentH = 256; break;
            case "settings": contentH = 256; break;
            case "ponix": contentH = 262; break;
        }
        return 50 + contentH + 18;
    }

    property real currentWidth: isExpanded ? expandedWidth : restingWidth
    property real currentHeight: isExpanded ? expandedHeight : restingHeight
    property real currentRadius: {
        if (PoniConfig.activeTheme.sharp) return isExpanded ? 18 : Math.min(13, restingHeight / 2);
        return isExpanded ? 22 : (restingHeight / 2);
    }
    property real shoulder: {
        if (PoniConfig.isFloating) return 0;
        if (PoniConfig.idleLook === "hidden" && !isExpanded && !islandMouseArea.containsMouse) return 0;
        return isExpanded ? 14 : 10;
    }

    Behavior on shoulder {
        NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
    }

    implicitWidth: currentWidth + shoulder * 2
    implicitHeight: currentHeight

    signal closeRequested()

    Text {
        id: lyricMeasure
        visible: false
        text: PoniMedia.currentLyricText
        font.family: PoniConfig.fontFamily
        font.pixelSize: 12
        font.weight: Font.DemiBold
    }

    Behavior on currentWidth {
        NumberAnimation {
            duration: 280
            easing.type: Easing.OutBack
            easing.overshoot: 1.12
        }
    }

    Behavior on currentHeight {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutBack
            easing.overshoot: 1.08
        }
    }

    Behavior on currentRadius {
        NumberAnimation {
            duration: 240
            easing.type: Easing.OutCubic
        }
    }

    Timer {
        id: hoverDwellTimer
        interval: PoniConfig.dwellMs
        repeat: false
        onTriggered: {
            if (islandMouseArea.containsMouse && PoniConfig.hoverExpand && !root.isExpanded && !islandMouseArea.dragging) {
                root.isExpanded = true;
            }
        }
    }

    Timer {
        id: collapseTimer
        interval: PoniConfig.collapseDelayMs
        repeat: false
        onTriggered: {
            if (root.isExpanded && !root.isPinned && !islandHover.hovered) {
                root.isExpanded = false;
            }
        }
    }

    onIsExpandedChanged: {
        if (!isExpanded) {
            collapseTimer.stop();
        }
    }

    Item {
        id: islandBody
        anchors.fill: parent

        readonly property bool isHiddenResting: PoniConfig.idleLook === "hidden" && !root.isExpanded && !islandMouseArea.containsMouse
        readonly property real maskRadius: Math.min(root.currentRadius, height * 0.5, Math.max(0, width - root.shoulder * 2) * 0.5)
        readonly property color fillColor: {
            if (isHiddenResting) return "transparent";
            if (PoniConfig.theme === "glass") return Qt.rgba(12/255, 14/255, 18/255, PoniConfig.glassOpacity);
            if (PoniConfig.theme === "liquid") return "transparent";
            return PoniConfig.colBg;
        }
        readonly property color strokeColor: {
            if (isHiddenResting) return "transparent";
            if (PoniConfig.theme === "glass") return Qt.rgba(1, 1, 1, 0.16);
            if (PoniConfig.theme === "liquid") return Qt.rgba(1, 1, 1, 0.26);
            return PoniConfig.colBorder;
        }

        Item {
            id: notchMaskItem
            anchors.fill: parent
            visible: PoniConfig.theme !== "liquid"

            Shape {
                anchors.fill: parent
                visible: root.shoulder > 0.5
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    fillColor: "#ffffff"
                    strokeColor: "transparent"
                    strokeWidth: 0
                    startX: 0
                    startY: 0

                    PathArc {
                        x: root.shoulder
                        y: root.shoulder
                        radiusX: root.shoulder
                        radiusY: root.shoulder
                        direction: PathArc.Clockwise
                    }
                    PathLine {
                        x: root.shoulder
                        y: Math.max(root.shoulder, notchMaskItem.height - islandBody.maskRadius)
                    }
                    PathArc {
                        x: root.shoulder + islandBody.maskRadius
                        y: notchMaskItem.height
                        radiusX: islandBody.maskRadius
                        radiusY: islandBody.maskRadius
                        direction: PathArc.Counterclockwise
                    }
                    PathLine {
                        x: Math.max(root.shoulder + islandBody.maskRadius, notchMaskItem.width - root.shoulder - islandBody.maskRadius)
                        y: notchMaskItem.height
                    }
                    PathArc {
                        x: notchMaskItem.width - root.shoulder
                        y: Math.max(root.shoulder, notchMaskItem.height - islandBody.maskRadius)
                        radiusX: islandBody.maskRadius
                        radiusY: islandBody.maskRadius
                        direction: PathArc.Counterclockwise
                    }
                    PathLine {
                        x: notchMaskItem.width - root.shoulder
                        y: root.shoulder
                    }
                    PathArc {
                        x: notchMaskItem.width
                        y: 0
                        radiusX: root.shoulder
                        radiusY: root.shoulder
                        direction: PathArc.Clockwise
                    }
                    PathLine {
                        x: 0
                        y: 0
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                visible: root.shoulder <= 0.5
                radius: islandBody.maskRadius
                color: "#ffffff"
            }
        }

        readonly property bool useSceneLiquid: PoniConfig.dioramaPixelLiquid && (PoniConfig.theme === "diorama" || PoniConfig.theme === "pixel")

        ShaderEffectSource {
            id: notchMaskTex
            sourceItem: notchMaskItem
            live: PoniConfig.theme !== "liquid"
            hideSource: true
        }

        ShaderEffect {
            anchors.fill: parent
            visible: PoniConfig.theme === "liquid" || islandBody.useSceneLiquid
            property vector2d uResolution: Qt.vector2d(width, height)
            property real uRadius: islandBody.maskRadius
            property real uBezel: (root.isExpanded ? 24.0 : 14.0) * PoniConfig.liquidBezelScale
            property real uThickness: root.isExpanded ? 54.0 : 48.0
            property real uIOR: 1.52
            property real uSpecular: PoniConfig.liquidSpecular
            property real uTint: 0.12
            property real uAlpha: islandBody.useSceneLiquid ? (PoniConfig.glassOpacity * 0.25) : PoniConfig.glassOpacity
            property real uHasBg: root.backdropHasContent ? 1.0 : 0.0
            property vector2d uWinOffset: root.backdropOffset
            property vector2d uWinSize: root.backdropSize
            property real uBlur: PoniConfig.glassBlur ? 6.5 : 1.0
            property real uShoulder: root.shoulder
            property variant uBgTex: root.backdropSource
            fragmentShader: "../shaders/liquid_glass.frag.qsb"
        }

        Item {
            id: islandBgLayer
            anchors.fill: parent
            visible: PoniConfig.theme !== "liquid"
            opacity: islandBody.useSceneLiquid ? PoniConfig.glassOpacity : 1.0
            layer.enabled: PoniConfig.theme !== "liquid"
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: notchMaskTex
                maskThresholdMin: 0.48
                maskSpreadAtMin: 0.12
            }

            Rectangle {
                anchors.fill: parent
                visible: !islandBody.useSceneLiquid
                color: islandBody.fillColor
            }

            DioramaCanvas {
                anchors.fill: parent
                visible: PoniConfig.theme === "diorama"
                pixelMode: false
                isExpandedMode: root.isExpanded
                opacity: islandBody.useSceneLiquid ? 1.0 : (root.isExpanded ? 0.82 : 0.96)
            }

            PixelArtSceneCanvas {
                anchors.fill: parent
                visible: PoniConfig.theme === "pixel"
                isExpandedMode: root.isExpanded
                opacity: islandBody.useSceneLiquid ? 1.0 : (root.isExpanded ? 0.85 : 0.98)
            }

            Rectangle {
                anchors.fill: parent
                visible: !islandBody.useSceneLiquid && root.isExpanded && (PoniConfig.theme === "diorama" || PoniConfig.theme === "pixel")
                color: Qt.rgba(0, 0, 0, 0.16)
            }
        }

        Shape {
            anchors.fill: parent
            z: 20
            visible: root.shoulder > 0.5 && !islandBody.isHiddenResting
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: "transparent"
                strokeColor: islandBody.strokeColor
                strokeWidth: 1
                capStyle: ShapePath.RoundCap
                startX: 0
                startY: 0.5

                PathArc {
                    x: root.shoulder + 0.5
                    y: root.shoulder
                    radiusX: root.shoulder
                    radiusY: root.shoulder
                    direction: PathArc.Clockwise
                }
                PathLine {
                    x: root.shoulder + 0.5
                    y: Math.max(root.shoulder, islandBody.height - islandBody.maskRadius)
                }
                PathArc {
                    x: root.shoulder + islandBody.maskRadius
                    y: islandBody.height - 0.5
                    radiusX: Math.max(0, islandBody.maskRadius - 0.5)
                    radiusY: Math.max(0, islandBody.maskRadius - 0.5)
                    direction: PathArc.Counterclockwise
                }
                PathLine {
                    x: Math.max(root.shoulder + islandBody.maskRadius, islandBody.width - root.shoulder - islandBody.maskRadius)
                    y: islandBody.height - 0.5
                }
                PathArc {
                    x: islandBody.width - root.shoulder - 0.5
                    y: Math.max(root.shoulder, islandBody.height - islandBody.maskRadius)
                    radiusX: Math.max(0, islandBody.maskRadius - 0.5)
                    radiusY: Math.max(0, islandBody.maskRadius - 0.5)
                    direction: PathArc.Counterclockwise
                }
                PathLine {
                    x: islandBody.width - root.shoulder - 0.5
                    y: root.shoulder
                }
                PathArc {
                    x: islandBody.width
                    y: 0.5
                    radiusX: root.shoulder
                    radiusY: root.shoulder
                    direction: PathArc.Clockwise
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            z: 20
            visible: root.shoulder <= 0.5 && !islandBody.isHiddenResting
            radius: islandBody.maskRadius
            color: "transparent"
            border.color: islandBody.strokeColor
            border.width: 1
        }

        HoverHandler {
            id: islandHover
            onHoveredChanged: {
                if (hovered) {
                    collapseTimer.stop();
                } else if (root.isExpanded && !root.isPinned) {
                    collapseTimer.restart();
                }
            }
        }

        Item {
            id: closedViewContainer
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: root.shoulder
            anchors.rightMargin: root.shoulder
            visible: !root.isExpanded
            opacity: root.isExpanded ? 0.0 : 1.0

            Behavior on opacity {
                NumberAnimation { duration: 160 }
            }

            IslandViews {
                id: islandViews
                anchors.fill: parent
                mouseXNorm: islandMouseArea.containsMouse ? ((islandMouseArea.mouseX / Math.max(1, width)) * 2.0 - 1.0) : 0.0
            }

            // Click to expand OR drag horizontally ("geser") to reposition
            MouseArea {
                id: islandMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: dragging ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                property real pressGlobalX: 0
                property real startIslandX: 0
                property bool dragging: false

                onEntered: hoverDwellTimer.start()
                onExited: hoverDwellTimer.stop()
                onPressed: mouse => {
                    hoverDwellTimer.stop();
                    var globalPt = mapToItem(null, mouse.x, mouse.y);
                    pressGlobalX = globalPt.x;
                    startIslandX = PoniConfig.islandX;
                    dragging = false;
                }
                onPositionChanged: mouse => {
                    if (pressed) {
                        var globalPt = mapToItem(null, mouse.x, mouse.y);
                        var dx = globalPt.x - pressGlobalX;
                        if (Math.abs(dx) > 6) {
                            dragging = true;
                        }
                        if (dragging) {
                            var nextX = startIslandX + dx;
                            if (Math.abs(nextX) < 28) nextX = 0; // Snap to center
                            PoniConfig.islandX = Math.max(-500, Math.min(500, Math.round(nextX)));
                        }
                    }
                }
                onReleased: {
                    if (dragging) {
                        dragging = false;
                        PoniConfig.saveSettings();
                    } else {
                        root.isExpanded = true;
                    }
                }
            }
        }

        Item {
            id: expandedViewContainer
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: root.shoulder
            anchors.rightMargin: root.shoulder
            visible: root.isExpanded
            opacity: root.isExpanded ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            // ---------- HEADER (Fixed 36 DIP row inside 50 DIP band) ----------
            Item {
                id: headerBand
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 50

                Item {
                    id: headerRow
                    anchors.top: parent.top
                    anchors.topMargin: 6
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    height: 36

                    Flickable {
                        id: tabFlick
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: rightControls.left
                        anchors.rightMargin: 10
                        contentWidth: tabRow.width
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true

                        Row {
                            id: tabRow
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            readonly property var allTabs: [
                                { id: "music", title: "Music", icon: "music", hideable: true, addon: "" },
                                { id: "today", title: "Today", icon: "calendar", hideable: true, addon: "" },
                                { id: "shelf", title: "Shelf", icon: "tray", hideable: true, addon: "" },
                                { id: "tasks", title: "Tasks", icon: "listchecks", hideable: true, addon: "" },
                                { id: "focus", title: "Focus", icon: "timer", hideable: true, addon: "" },
                                { id: "ponix", title: "PoniX", icon: "ponix", hideable: false, addon: "" },
                                { id: "health", title: "Health", icon: "steps", hideable: false, addon: "health" },
                                { id: "ielts", title: "IELTS", icon: "mic", hideable: false, addon: "ielts" },
                                { id: "notes", title: "Notes", icon: "notes", hideable: false, addon: "notes" },
                                { id: "system", title: "System", icon: "gauge", hideable: false, addon: "system" },
                                { id: "script", title: "Script", icon: "script", hideable: false, addon: "script" },
                                { id: "record", title: "Record", icon: "recorder", hideable: false, addon: "record" },
                                { id: "prayer", title: "Prayer", icon: "moon", hideable: false, addon: "prayer" },
                                { id: "stocks", title: "Stocks", icon: "stocks", hideable: false, addon: "stocks" },
                                { id: "caffeine", title: "Caffeine", icon: "coffee", hideable: false, addon: "caffeine" },
                                { id: "downloads", title: "Downloads", icon: "download", hideable: false, addon: "downloads" },
                                { id: "servers", title: "Servers", icon: "servers", hideable: false, addon: "servers" },
                                { id: "agent", title: "Agent", icon: "ai", hideable: false, addon: "agent" },
                                { id: "audio", title: "Audio", icon: "audio", hideable: false, addon: "audio" },
                                { id: "clipboard", title: "Clipboard", icon: "clipboard", hideable: false, addon: "clipboard" },
                                { id: "capture", title: "Capture", icon: "capture", hideable: false, addon: "capture" },
                                { id: "weather", title: "Weather", icon: "weather", hideable: false, addon: "weather" },
                                { id: "share", title: "Share", icon: "share", hideable: false, addon: "share" },
                                { id: "translate", title: "Translate", icon: "translate", hideable: false, addon: "translate" },
                                { id: "addons", title: "Add-ons", icon: "addons", hideable: false, addon: "" }
                            ]

                            readonly property var tabList: {
                                var out = [];
                                for (var i = 0; i < allTabs.length; i++) {
                                    var t = allTabs[i];
                                    var isOpen = (root.activeTab === t.id);
                                    if (t.addon.length > 0 && !PoniConfig.addons[t.addon] && !isOpen) continue;
                                    if (t.hideable && PoniConfig.hiddenTabs.indexOf(t.id) >= 0 && !isOpen) continue;
                                    out.push(t);
                                }
                                return out;
                            }

                            Repeater {
                                model: tabRow.tabList

                                Item {
                                    id: tabItem
                                    property bool isActive: root.activeTab === modelData.id
                                    property real textW: dummyLabel.width

                                    Text {
                                        id: dummyLabel
                                        visible: false
                                        text: modelData.title
                                        font.family: PoniConfig.fontFamily
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                    }

                                    width: isActive ? (28 + textW + 12) : 30
                                    height: 28
                                    anchors.verticalCenter: parent.verticalCenter

                                    Behavior on width {
                                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: PoniConfig.theme === "pixel" ? 2 : (PoniConfig.theme === "ascii" ? 3 : 14)
                                        color: tabItem.isActive ? PoniConfig.colSurfaceHover : (tabItemArea.containsMouse ? PoniConfig.colSurface : "transparent")
                                    }

                                    Item {
                                        id: iconSlot
                                        x: (30 - 16) / 2
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 16
                                        height: 16

                                        Image {
                                            visible: modelData.id === "ponix"
                                            anchors.centerIn: parent
                                            width: 18
                                            height: 18
                                            fillMode: Image.PreserveAspectFit
                                            smooth: true
                                            source: PoniConfig.theme === "eink" ? "../assets/ponix-x.png" : "../assets/ponix-x-white.png"
                                        }

                                        PoniIcon {
                                            visible: modelData.id !== "ponix"
                                            anchors.centerIn: parent
                                            name: modelData.icon
                                            size: 16
                                            color: tabItem.isActive ? PoniConfig.colText : (tabItemArea.containsMouse ? PoniConfig.colText : PoniConfig.colTextDim)
                                        }
                                    }

                                    Text {
                                        id: activeLabelText
                                        anchors.left: parent.left
                                        anchors.leftMargin: 28
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.title
                                        font.family: PoniConfig.fontFamily
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                        color: PoniConfig.colText
                                        visible: tabItem.isActive
                                        opacity: tabItem.isActive ? 1.0 : 0.0
                                    }

                                    MouseArea {
                                        id: tabItemArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.activeTab = modelData.id
                                    }
                                }
                            }
                        }
                    }

                    // Right Controls: Clock, Date, Pin, Gear
                    Row {
                        id: rightControls
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Text {
                            visible: root.activeTab !== "today"
                            anchors.verticalCenter: parent.verticalCenter
                            text: {
                                var now = new Date();
                                var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
                                var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                                return days[now.getDay()] + ", " + now.getDate() + " " + months[now.getMonth()];
                            }
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            color: PoniConfig.colTextFaint
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: {
                                var now = new Date();
                                var h = now.getHours();
                                var m = now.getMinutes();
                                if (!PoniConfig.use24h) {
                                    var ampm = h >= 12 ? "PM" : "AM";
                                    h = h % 12 || 12;
                                    return h + ":" + (m < 10 ? "0" : "") + m + " " + ampm;
                                }
                                return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m;
                            }
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: PoniConfig.colText
                        }

                        Rectangle {
                            width: 28
                            height: 28
                            radius: PoniConfig.theme === "pixel" ? 2 : 14
                            color: root.isPinned ? Qt.rgba(240/255, 130/255, 54/255, 0.22) : (pinArea.containsMouse ? PoniConfig.colSurface : "transparent")

                            PoniIcon {
                                anchors.centerIn: parent
                                name: root.isPinned ? "pinfill" : "pin"
                                size: 14
                                color: root.isPinned ? PoniConfig.colAccent : PoniConfig.colTextDim
                            }

                            MouseArea {
                                id: pinArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.isPinned = !root.isPinned
                            }
                        }

                        Rectangle {
                            width: 28
                            height: 28
                            radius: PoniConfig.theme === "pixel" ? 2 : 14
                            color: root.activeTab === "settings" ? PoniConfig.colSurfaceHover : (gearArea.containsMouse ? PoniConfig.colSurface : "transparent")

                            PoniIcon {
                                anchors.centerIn: parent
                                name: "gear"
                                size: 15
                                color: root.activeTab === "settings" ? PoniConfig.colText : PoniConfig.colTextDim
                            }

                            MouseArea {
                                id: gearArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.activeTab === "settings") {
                                        root.activeTab = "music";
                                    } else {
                                        root.activeTab = "settings";
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ---------- CONTENT AREA (PAD = 18 DIPs) ----------
            Item {
                id: contentArea
                anchors.top: parent.top
                anchors.topMargin: 50
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 18
                clip: true

                Loader {
                    id: pageLoader
                    anchors.fill: parent
                    source: {
                        switch (root.activeTab) {
                            case "music": return "../pages/MusicPage.qml";
                            case "today": return "../pages/TodayPage.qml";
                            case "shelf": return "../pages/ShelfPage.qml";
                            case "tasks": return "../pages/TasksPage.qml";
                            case "focus": return "../pages/FocusPage.qml";
                            case "ponix": return "../pages/PonixPage.qml";
                            case "system": return "../pages/SystemPage.qml";
                            case "prayer": return "../pages/PrayerPage.qml";
                            case "stocks": return "../pages/StocksPage.qml";
                            case "caffeine": return "../pages/CaffeinePage.qml";
                            case "downloads": return "../pages/DownloadsPage.qml";
                            case "script": return "../pages/ScriptPage.qml";
                            case "record": return "../pages/RecordPage.qml";
                            case "notes": return "../pages/NotesPage.qml";
                            case "health": return "../pages/HealthPage.qml";
                            case "ielts": return "../pages/IeltsPage.qml";
                            case "servers": return "../pages/ServersPage.qml";
                            case "agent": return "../pages/AgentPage.qml";
                            case "audio": return "../pages/AudioPage.qml";
                            case "clipboard": return "../pages/ClipboardPage.qml";
                            case "capture": return "../pages/CapturePage.qml";
                            case "weather": return "../pages/WeatherPage.qml";
                            case "share": return "../pages/SharePage.qml";
                            case "translate": return "../pages/TranslatePage.qml";
                            case "addons": return "../pages/AddonsPage.qml";
                            case "settings": return "../pages/SettingsPage.qml";
                            default: return "../pages/MusicPage.qml";
                        }
                    }
                }
            }
        }
    }
}
