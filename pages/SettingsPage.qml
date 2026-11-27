import QtQuick
import Quickshell
import Quickshell.Io
import "../components"
import "../services"

Item {
    id: root

    implicitHeight: 256
    property string section: "theme" // theme, appearance, behavior, display
    property string themeCat: "All" // All, Core, Terminal, Retro, Vibe, Scenes
    property string sceneCat: "All" // All, Scenery, Cosmic, City, Game

    readonly property string detectedOs: Qt.platform.os === "windows" ? "Windows" : (Qt.platform.os === "linux" ? "Linux" : Qt.platform.os)
    readonly property string repoUrl: "https://github.com/DDGXO/PoniX.git"
    property string updateStatus: "Ready"
    property bool updateChecking: false
    property bool updateDownloading: false
    property bool updateAvailable: false

    Process {
        id: updateCheckProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.updateChecking = false;
                var raw = text.trim();
                var parts = raw.split("|");
                var localHash = (parts[0] || "").trim();
                var remoteHash = (parts[1] || "").trim();
                if (remoteHash.length >= 7) {
                    if (localHash.length >= 7 && localHash === remoteHash) {
                        root.updateAvailable = false;
                        root.updateStatus = "Up to date (" + remoteHash.substring(0, 7) + ")";
                    } else if (localHash.length >= 7) {
                        root.updateAvailable = true;
                        root.updateStatus = "Update available (" + remoteHash.substring(0, 7) + ")";
                    } else {
                        root.updateAvailable = false;
                        root.updateStatus = "Latest: " + remoteHash.substring(0, 7);
                    }
                } else {
                    root.updateStatus = "Offline / check failed";
                }
            }
        }
    }

    function checkForUpdates() {
        if (root.updateChecking || root.updateDownloading) return;
        root.updateChecking = true;
        root.updateStatus = "Checking (" + root.detectedOs + ")...";
        var branch = (root.detectedOs === "Windows") ? "refs/heads/main" : "refs/heads/linux";
        var dir = Quickshell.shellDir;
        updateCheckProc.command = [
            "sh", "-c",
            "loc=$(git -C \"$1\" rev-parse HEAD 2>/dev/null || echo ''); rem=$(git ls-remote \"$2\" \"$3\" 2>/dev/null | awk '{print $1}' | head -n1); echo \"${loc}|${rem}\"",
            "_", dir, root.repoUrl, branch
        ];
        updateCheckProc.running = true;
    }

    Process {
        id: updateRunProc
        onExited: (code) => {
            root.updateDownloading = false;
            if (code === 0) {
                root.updateAvailable = false;
                root.updateStatus = "Updated successfully";
                PoniNotices.post("PoniX Update", "Updated from " + root.repoUrl);
            } else {
                root.updateStatus = "Update failed";
            }
        }
    }

    function runSelfUpdate() {
        if (root.updateDownloading || root.updateChecking) return;
        root.updateDownloading = true;
        root.updateStatus = "Downloading update...";
        var branch = (root.detectedOs === "Windows") ? "main" : "linux";
        var dir = Quickshell.shellDir;
        if (root.detectedOs === "Windows") {
            updateRunProc.command = [
                "cmd", "/c",
                "git -C \"" + dir + "\" fetch origin " + branch + " && git -C \"" + dir + "\" pull --ff-only origin " + branch
            ];
        } else {
            updateRunProc.command = [
                "sh", "-c",
                "if [ -d \"$1/.git\" ]; then git -C \"$1\" fetch origin \"$2\" && git -C \"$1\" pull --ff-only origin \"$2\"; " +
                "else curl -fsSL https://raw.githubusercontent.com/DDGXO/PoniX/linux/install.sh | bash; fi",
                "_", dir, branch
            ];
        }
        updateRunProc.running = true;
    }

    component PoniSwitch: Item {
        property bool checked: false
        signal toggled(bool nextVal)

        width: 32
        height: 18

        Rectangle {
            anchors.fill: parent
            radius: PoniConfig.theme === "pixel" ? 2 : 9
            color: checked ? PoniConfig.colAccent : Qt.rgba(1, 1, 1, 0.16)
            Behavior on color { ColorAnimation { duration: 140 } }

            Rectangle {
                width: 14
                height: 14
                radius: PoniConfig.theme === "pixel" ? 1 : 7
                color: "#ffffff"
                y: 2
                x: checked ? 16 : 2
                Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: toggled(!checked)
        }
    }

    component CapsuleSlider: Item {
        property string label: ""
        property real value: 0.5
        property real minVal: 0.0
        property real maxVal: 1.0
        property string valueText: ""
        signal moved(real nextVal)

        height: 22

        readonly property real norm: Math.max(0, Math.min(1, (value - minVal) / Math.max(0.0001, maxVal - minVal)))

        Text {
            id: lbl
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: label
            font.family: PoniConfig.fontFamily
            font.pixelSize: 11
            color: PoniConfig.colTextDim
        }

        Text {
            id: valLbl
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            horizontalAlignment: Text.AlignRight
            text: valueText
            font.family: PoniConfig.fontFamily
            font.pixelSize: 10
            font.weight: Font.DemiBold
            color: PoniConfig.colText
        }

        Item {
            id: trackWrap
            anchors.left: lbl.right
            anchors.leftMargin: 10
            anchors.right: valLbl.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            height: 18

            Rectangle {
                id: track
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 6
                radius: PoniConfig.theme === "pixel" ? 1 : 3
                color: Qt.rgba(1, 1, 1, 0.14)

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: Math.max(6, parent.width * norm)
                    radius: parent.radius
                    color: PoniConfig.colAccent
                }

                Rectangle {
                    width: 12
                    height: 12
                    radius: PoniConfig.theme === "pixel" ? 2 : 6
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                    x: Math.max(0, Math.min(parent.width - width, parent.width * norm - width / 2))
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                function applyX(mx) {
                    var t = Math.max(0, Math.min(1, mx / Math.max(1, trackWrap.width)));
                    moved(minVal + t * (maxVal - minVal));
                }
                onPressed: mouse => applyX(mouse.x)
                onPositionChanged: mouse => { if (pressed) applyX(mouse.x); }
                onReleased: PoniConfig.saveSettings()
            }
        }
    }

    Item {
        anchors.fill: parent

        // 1. Compact Header + Segmented Control (y = 0, h = 32)
        Item {
            id: headerRow
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 32

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 54
                    height: 20
                    fillMode: Image.PreserveAspectFit
                    source: PoniConfig.theme === "eink" ? "../assets/ponix-logo.png" : "../assets/ponix-logo-white.png"
                    smooth: true
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Settings"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: PoniConfig.colText
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    height: 16
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.08)

                    Text {
                        anchors.centerIn: parent
                        text: "0.3.2"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 9
                        font.weight: Font.DemiBold
                        color: PoniConfig.colTextDim
                    }
                }
            }

            // Segmented Control (Apple HIG 4-segment capsule)
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 292
                height: 26
                radius: PoniConfig.activeTheme.sharp ? 3 : 13
                color: PoniConfig.colSurface

                Row {
                    anchors.fill: parent
                    anchors.margins: 2
                    spacing: 2

                    readonly property var sections: [
                        { id: "theme", label: "Theme" },
                        { id: "appearance", label: "Appearance" },
                        { id: "behavior", label: "Behavior" },
                        { id: "display", label: "Display" }
                    ]

                    Repeater {
                        model: parent.sections
                        Rectangle {
                            property bool sel: root.section === modelData.id
                            width: (parent.width - 6) / 4
                            height: parent.height
                            radius: PoniConfig.activeTheme.sharp ? 2 : 11
                            color: sel ? Qt.rgba(1, 1, 1, 0.18) : (segArea.containsMouse ? Qt.rgba(1, 1, 1, 0.07) : "transparent")

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 10
                                font.weight: sel ? Font.DemiBold : Font.Normal
                                color: sel ? PoniConfig.colText : PoniConfig.colTextDim
                            }

                            MouseArea {
                                id: segArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.section = modelData.id
                            }
                        }
                    }
                }
            }
        }

        // ==================== TAB 0: THEME (32 THEMES) ====================
        Column {
            visible: root.section === "theme"
            anchors.top: headerRow.bottom
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 8

            // Category Filter Row
            Item {
                width: parent.width
                height: 24

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    readonly property var cats: ["All", "Core", "Terminal", "Retro", "Vibe", "Scenes", "PixelArt"]

                    Repeater {
                        model: parent.cats
                        Rectangle {
                            property bool sel: root.themeCat === modelData
                            width: catTxt.width + 12
                            height: 22
                            radius: PoniConfig.activeTheme.sharp ? 3 : 11
                            color: sel ? PoniConfig.colAccent : PoniConfig.colSurface

                            Text {
                                id: catTxt
                                anchors.centerIn: parent
                                text: {
                                    if (modelData === "All") return "All (" + PoniConfig.themeCatalog.length + ")";
                                    if (modelData === "Scenes") return "Diorama (200)";
                                    if (modelData === "PixelArt") return "Pixel Art (50)";
                                    return modelData;
                                }
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 10
                                font.weight: sel ? Font.DemiBold : Font.Normal
                                color: sel ? "#ffffff" : PoniConfig.colTextDim
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.themeCat = modelData
                            }
                        }
                    }
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Active: " + PoniConfig.activeTheme.label
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    color: PoniConfig.colAccent
                }
            }

            // Sub-filter for Diorama/Pixel Scenes (Scenery vs Cosmic vs City vs Game)
            Row {
                visible: root.themeCat === "Scenes"
                width: parent.width
                spacing: 6

                readonly property var subCats: ["All", "Scenery", "Cosmic", "City", "Game"]

                Repeater {
                    model: parent.subCats
                    Rectangle {
                        property bool sel: root.sceneCat === modelData
                        width: scTxt.width + 14
                        height: 18
                        radius: PoniConfig.activeTheme.sharp ? 2 : 9
                        color: sel ? Qt.rgba(1, 1, 1, 0.20) : PoniConfig.colSurface

                        Text {
                            id: scTxt
                            anchors.centerIn: parent
                            text: modelData === "Game" ? "Game / Retro" : modelData
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 9
                            font.weight: sel ? Font.DemiBold : Font.Normal
                            color: sel ? PoniConfig.colText : PoniConfig.colTextDim
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.sceneCat = modelData
                        }
                    }
                }
            }

            // 4-Column Scrollable Grid (Themes / 200 Diorama / 24 Aesthetic Pixel Art)
            Flickable {
                id: themeScroll
                width: parent.width
                height: root.themeCat === "Scenes" ? 134 : 158
                clip: true
                contentWidth: width
                contentHeight: (root.themeCat === "Scenes" ? scenesTabGrid.height : (root.themeCat === "PixelArt" ? pixelArtTabGrid.height : themeGrid.height)) + 4
                boundsBehavior: Flickable.StopAtBounds

                readonly property var filteredThemes: {
                    var out = [];
                    for (var i = 0; i < PoniConfig.themeCatalog.length; i++) {
                        var t = PoniConfig.themeCatalog[i];
                        if (root.themeCat === "All" || t.cat === root.themeCat) {
                            out.push(t);
                        }
                    }
                    return out;
                }

                readonly property var filteredScenes: {
                    var out = [];
                    for (var i = 0; i < PoniConfig.dioramaScenes.length; i++) {
                        var sc = PoniConfig.dioramaScenes[i];
                        if (root.sceneCat === "All" || sc.id === "auto" || sc.cat === root.sceneCat) {
                            out.push(sc);
                        }
                    }
                    return out;
                }

                // 24 Aesthetic Pixel Art Scenes Grid
                Grid {
                    id: pixelArtTabGrid
                    visible: root.themeCat === "PixelArt"
                    width: parent.width
                    columns: 4
                    columnSpacing: 8
                    rowSpacing: 8

                    Repeater {
                        model: PoniConfig.pixelScenesCatalog
                        Rectangle {
                            required property var modelData
                            property bool sel: PoniConfig.theme === "pixel" && PoniConfig.pixelScene === modelData.id
                            width: (pixelArtTabGrid.width - 24) / 4
                            height: 30
                            radius: 4
                            color: sel ? Qt.rgba(1, 1, 1, 0.16) : (pxArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.04))
                            border.color: sel ? "#a78bfa" : Qt.rgba(1, 1, 1, 0.08)
                            border.width: sel ? 1.5 : 1

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 10
                                font.weight: sel ? Font.DemiBold : Font.Medium
                                color: sel ? PoniConfig.colText : PoniConfig.colTextDim
                            }

                            MouseArea {
                                id: pxArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    PoniConfig.theme = "pixel";
                                    PoniConfig.pixelScene = modelData.id;
                                    PoniConfig.saveSettings();
                                }
                            }
                        }
                    }
                }

                Grid {
                    id: scenesTabGrid
                    visible: root.themeCat === "Scenes"
                    width: parent.width
                    columns: 4
                    columnSpacing: 8
                    rowSpacing: 8

                    Repeater {
                        model: themeScroll.filteredScenes
                        Rectangle {
                            required property var modelData
                            property bool sel: PoniConfig.theme === "diorama" && PoniConfig.dioramaScene === modelData.id
                            width: (scenesTabGrid.width - 24) / 4
                            height: 30
                            radius: PoniConfig.activeTheme.sharp ? 4 : 10
                            color: sel ? Qt.rgba(1, 1, 1, 0.16) : (scArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.04))
                            border.color: sel ? PoniConfig.colAccent : Qt.rgba(1, 1, 1, 0.08)
                            border.width: sel ? 1.5 : 1

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 10
                                font.weight: sel ? Font.DemiBold : Font.Medium
                                color: sel ? PoniConfig.colText : PoniConfig.colTextDim
                            }

                            MouseArea {
                                id: scArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    PoniConfig.theme = "diorama";
                                    PoniConfig.dioramaScene = modelData.id;
                                    PoniConfig.saveSettings();
                                }
                            }
                        }
                    }
                }

                Grid {
                    id: themeGrid
                    visible: root.themeCat !== "Scenes" && root.themeCat !== "PixelArt"
                    width: parent.width
                    columns: 4
                    columnSpacing: 8
                    rowSpacing: 8

                    Repeater {
                        model: themeScroll.filteredThemes
                        Rectangle {
                            required property var modelData
                            property bool sel: PoniConfig.theme === modelData.id
                            width: (themeGrid.width - 24) / 4
                            height: 34
                            radius: modelData.sharp ? 4 : 10
                            color: sel ? Qt.rgba(1, 1, 1, 0.14) : (swatchArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.04))
                            border.color: sel ? modelData.accent : Qt.rgba(1, 1, 1, 0.08)
                            border.width: sel ? 1.5 : 1

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 7

                                // Mini 2-tone palette swatch
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 18
                                    height: 18
                                    radius: modelData.sharp ? 3 : 9
                                    color: modelData.bg === "transparent" ? "#1e293b" : modelData.bg
                                    border.color: modelData.border
                                    border.width: 1.5

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 7
                                        height: 7
                                        radius: modelData.sharp ? 1 : 4
                                        color: modelData.accent
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 25
                                    spacing: 1

                                    Text {
                                        width: parent.width
                                        elide: Text.ElideRight
                                        text: modelData.label
                                        font.family: modelData.mono ? "monospace" : PoniConfig.fontFamily
                                        font.pixelSize: 10
                                        font.weight: sel ? Font.DemiBold : Font.Medium
                                        color: PoniConfig.colText
                                    }

                                    Text {
                                        text: modelData.cat
                                        font.family: PoniConfig.fontFamily
                                        font.pixelSize: 8
                                        color: PoniConfig.colTextFaint
                                    }
                                }
                            }

                            MouseArea {
                                id: swatchArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    PoniConfig.theme = modelData.id;
                                    PoniConfig.saveSettings();
                                }
                            }
                        }
                    }
                }
            }
        }

        // ==================== TAB 1: APPEARANCE ====================
        Column {
            visible: root.section === "appearance"
            anchors.top: headerRow.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 10

            // Card 1: Idle Look + Eye Style (20)
            Rectangle {
                width: parent.width
                height: PoniConfig.idleLook === "eyes" ? 124 : 52
                radius: PoniConfig.activeTheme.sharp ? 4 : 12
                color: Qt.rgba(1, 1, 1, 0.04)
                border.color: Qt.rgba(1, 1, 1, 0.07)
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    Item {
                        width: parent.width
                        height: 28

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Idle Look"
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: PoniConfig.colTextDim
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 340
                            height: 26
                            radius: PoniConfig.activeTheme.sharp ? 3 : 13
                            color: PoniConfig.colSurface

                            Row {
                                anchors.fill: parent
                                anchors.margins: 2
                                spacing: 2

                                readonly property var looks: [
                                    { id: "clock", label: "Clock" },
                                    { id: "eyes", label: "Eyes" },
                                    { id: "minimal", label: "Minimal" },
                                    { id: "hidden", label: "Hidden" }
                                ]

                                Repeater {
                                    model: parent.looks
                                    Rectangle {
                                        property bool sel: PoniConfig.idleLook === modelData.id
                                        width: (parent.width - (parent.looks.length - 1) * 2) / parent.looks.length
                                        height: parent.height
                                        radius: PoniConfig.activeTheme.sharp ? 2 : 11
                                        color: sel ? Qt.rgba(1, 1, 1, 0.18) : (lArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.label
                                            font.family: PoniConfig.fontFamily
                                            font.pixelSize: 10
                                            font.weight: sel ? Font.DemiBold : Font.Normal
                                            color: sel ? PoniConfig.colText : PoniConfig.colTextDim
                                        }

                                        MouseArea {
                                            id: lArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                PoniConfig.idleLook = modelData.id;
                                                PoniConfig.saveSettings();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle { visible: PoniConfig.idleLook === "eyes"; width: parent.width; height: 1; color: Qt.rgba(1, 1, 1, 0.06) }

                    Item {
                        visible: PoniConfig.idleLook === "eyes"
                        width: parent.width
                        height: 20

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Keep Eyes visible while playing music"
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            color: PoniConfig.colTextDim
                        }

                        PoniSwitch {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: PoniConfig.eyesDuringMedia
                            onToggled: val => { PoniConfig.eyesDuringMedia = val; PoniConfig.saveSettings(); }
                        }
                    }

                    // 20 Eye Styles Grid
                    Flickable {
                        visible: PoniConfig.idleLook === "eyes"
                        width: parent.width
                        height: 44
                        clip: true
                        contentWidth: width
                        contentHeight: eyeStyleGrid.height
                        boundsBehavior: Flickable.StopAtBounds

                        Grid {
                            id: eyeStyleGrid
                            width: parent.width
                            columns: 5
                            columnSpacing: 6
                            rowSpacing: 4

                            Repeater {
                                model: PoniConfig.eyeStyles
                                Rectangle {
                                    required property var modelData
                                    property bool sel: PoniConfig.eyeStyle === modelData.id
                                    width: (eyeStyleGrid.width - 24) / 5
                                    height: 22
                                    radius: PoniConfig.activeTheme.sharp ? 3 : 11
                                    color: sel ? PoniConfig.colAccent : PoniConfig.colSurface

                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: 6
                                        anchors.rightMargin: 6
                                        spacing: 5

                                        // Mini Live Eye Preview
                                        Canvas {
                                            width: 14
                                            height: 14
                                            anchors.verticalCenter: parent.verticalCenter
                                            property string stId: modelData.id
                                            Component.onCompleted: requestPaint()
                                            onPaint: {
                                                var ctx = getContext("2d");
                                                ctx.clearRect(0, 0, 14, 14);
                                                var cx = 7, cy = 7;
                                                if (stId === "capsule") {
                                                    ctx.fillStyle = "#ffffff";
                                                    ctx.fillRect(3, 3, 3, 8); ctx.fillRect(8, 3, 3, 8);
                                                } else if (stId === "terminator") {
                                                    ctx.fillStyle = "#f8fafc";
                                                    ctx.beginPath(); ctx.arc(4, cy, 2.4, 0, Math.PI * 2); ctx.fill();
                                                    ctx.fillStyle = "#ef4444";
                                                    ctx.beginPath(); ctx.arc(10, cy, 3.0, 0, Math.PI * 2); ctx.fill();
                                                    ctx.fillStyle = "#ffffff";
                                                    ctx.beginPath(); ctx.arc(10, cy, 1.0, 0, Math.PI * 2); ctx.fill();
                                                } else if (stId === "sharingan" || stId === "rinnegan") {
                                                    ctx.fillStyle = stId === "sharingan" ? "#dc2626" : "#a855f7";
                                                    ctx.beginPath(); ctx.arc(cx, cy, 5, 0, Math.PI * 2); ctx.fill();
                                                    ctx.strokeStyle = "#111"; ctx.lineWidth = 1;
                                                    ctx.beginPath(); ctx.arc(cx, cy, 2.8, 0, Math.PI * 2); ctx.stroke();
                                                } else if (stId === "cat") {
                                                    ctx.fillStyle = "#facc15";
                                                    ctx.beginPath(); ctx.arc(cx, cy, 5, 0, Math.PI * 2); ctx.fill();
                                                    ctx.fillStyle = "#000"; ctx.fillRect(6, 3, 2, 8);
                                                } else if (stId === "cyber" || stId === "cyclops") {
                                                    ctx.fillStyle = stId === "cyclops" ? "#ef4444" : "#22d3ee";
                                                    ctx.fillRect(1, 5, 12, 4);
                                                } else if (stId === "kawaii") {
                                                    ctx.fillStyle = "#111827";
                                                    ctx.beginPath(); ctx.arc(cx, cy, 5, 0, Math.PI * 2); ctx.fill();
                                                    ctx.fillStyle = "#fff";
                                                    ctx.beginPath(); ctx.arc(5, 5, 1.8, 0, Math.PI * 2); ctx.fill();
                                                } else if (stId === "heart") {
                                                    ctx.fillStyle = "#fb7185"; ctx.font = "bold 11px sans-serif";
                                                    ctx.textAlign = "center"; ctx.textBaseline = "middle";
                                                    ctx.fillText("♥", cx, cy + 1);
                                                } else if (stId === "star") {
                                                    ctx.fillStyle = "#fde047"; ctx.font = "bold 11px sans-serif";
                                                    ctx.textAlign = "center"; ctx.textBaseline = "middle";
                                                    ctx.fillText("✦", cx, cy + 1);
                                                } else if (stId === "dollar") {
                                                    ctx.fillStyle = "#4ade80"; ctx.font = "bold 11px monospace";
                                                    ctx.textAlign = "center"; ctx.textBaseline = "middle";
                                                    ctx.fillText("$", cx, cy + 1);
                                                } else if (stId === "matrix") {
                                                    ctx.fillStyle = "#4ade80"; ctx.font = "bold 10px monospace";
                                                    ctx.textAlign = "center"; ctx.textBaseline = "middle";
                                                    ctx.fillText("01", cx, cy + 1);
                                                } else if (stId === "xdead") {
                                                    ctx.fillStyle = "#f87171"; ctx.font = "bold 11px monospace";
                                                    ctx.textAlign = "center"; ctx.textBaseline = "middle";
                                                    ctx.fillText("X", cx, cy + 1);
                                                } else if (stId === "spiral") {
                                                    ctx.strokeStyle = "#e879f9"; ctx.lineWidth = 1.4;
                                                    ctx.beginPath(); ctx.arc(cx, cy, 4.5, 0, Math.PI * 1.6); ctx.stroke();
                                                    ctx.beginPath(); ctx.arc(cx, cy, 2, 0, Math.PI * 1.5); ctx.stroke();
                                                } else if (stId === "alien") {
                                                    ctx.fillStyle = "#4ade80";
                                                    ctx.beginPath(); ctx.ellipse(cx, cy, 3.5, 5, 0.3, 0, Math.PI * 2); ctx.fill();
                                                } else if (stId === "robot") {
                                                    ctx.fillStyle = "#38bdf8"; ctx.fillRect(2, 2, 10, 10);
                                                    ctx.fillStyle = "#082f49"; ctx.fillRect(4, 6, 6, 2);
                                                } else if (stId === "wink") {
                                                    ctx.strokeStyle = "#fff"; ctx.lineWidth = 1.8;
                                                    ctx.beginPath(); ctx.arc(cx, cy + 2, 4, Math.PI * 1.15, Math.PI * 1.85); ctx.stroke();
                                                } else if (stId === "sleepy") {
                                                    ctx.fillStyle = "#fff";
                                                    ctx.beginPath(); ctx.arc(cx, cy + 1, 4.5, 0, Math.PI); ctx.fill();
                                                } else if (stId === "angry") {
                                                    ctx.fillStyle = "#fff";
                                                    ctx.save(); ctx.translate(cx, cy); ctx.rotate(0.35);
                                                    ctx.fillRect(-5, -2, 10, 4); ctx.restore();
                                                } else {
                                                    ctx.fillStyle = "#fff"; ctx.fillRect(2, 5, 10, 4);
                                                    ctx.fillStyle = "#111"; ctx.fillRect(8, 5, 3, 4);
                                                }
                                            }
                                        }

                                        Text {
                                            width: parent.width - 19
                                            elide: Text.ElideRight
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: modelData.label
                                            font.family: PoniConfig.fontFamily
                                            font.pixelSize: 9
                                            font.weight: sel ? Font.DemiBold : Font.Normal
                                            color: sel ? "#ffffff" : PoniConfig.colTextDim
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            PoniConfig.eyeStyle = modelData.id;
                                            PoniConfig.saveSettings();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Card 2: Material Controls (Liquid / Glass)
            Rectangle {
                width: parent.width
                height: PoniConfig.idleLook === "eyes" ? 64 : 86
                radius: PoniConfig.theme === "pixel" ? 4 : 12
                color: Qt.rgba(1, 1, 1, 0.04)
                border.color: Qt.rgba(1, 1, 1, 0.07)
                border.width: 1

                readonly property bool isMaterialTheme: PoniConfig.theme === "liquid" || PoniConfig.theme === "glass"

                Text {
                    visible: !parent.isMaterialTheme
                    anchors.centerIn: parent
                    text: "Select Glass or Liquid in Theme tab to tune blur, opacity, rim, and bevel."
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 11
                    color: PoniConfig.colTextFaint
                }

                Column {
                    visible: parent.isMaterialTheme
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    // Row 1: Blur Toggle + Opacity Slider + Reset
                    Item {
                        width: parent.width
                        height: 24

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Live Blur"
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 11
                                color: PoniConfig.colTextDim
                            }

                            PoniSwitch {
                                anchors.verticalCenter: parent.verticalCenter
                                checked: PoniConfig.glassBlur
                                onToggled: val => { PoniConfig.glassBlur = val; PoniConfig.saveSettings(); }
                            }
                        }

                        CapsuleSlider {
                            anchors.left: parent.left
                            anchors.leftMargin: 120
                            anchors.right: resetBtn.left
                            anchors.rightMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            label: "Opacity"
                            minVal: 0.04
                            maxVal: 0.85
                            value: PoniConfig.glassOpacity
                            valueText: Math.round(PoniConfig.glassOpacity * 100) + "%"
                            onMoved: v => { PoniConfig.glassOpacity = Math.round(v * 100) / 100; }
                        }

                        Rectangle {
                            id: resetBtn
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 48
                            height: 22
                            radius: PoniConfig.theme === "pixel" ? 2 : 11
                            color: resetGlassArea.containsMouse ? PoniConfig.colSurfaceHover : PoniConfig.colSurface

                            Text {
                                anchors.centerIn: parent
                                text: "Reset"
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: PoniConfig.colTextDim
                            }

                            MouseArea {
                                id: resetGlassArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    PoniConfig.glassBlur = true;
                                    PoniConfig.glassOpacity = 0.28;
                                    PoniConfig.liquidSpecular = 0.72;
                                    PoniConfig.liquidBezelScale = 1.0;
                                    PoniConfig.saveSettings();
                                }
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(1, 1, 1, 0.06) }

                    // Row 2: Rim & Bevel (Liquid) or Info (Glass)
                    Item {
                        width: parent.width
                        height: 24

                        Text {
                            visible: PoniConfig.theme === "glass"
                            anchors.centerIn: parent
                            text: "Switch to Liquid theme for specular rim and bevel refraction controls."
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            color: PoniConfig.colTextFaint
                        }

                        CapsuleSlider {
                            visible: PoniConfig.theme === "liquid"
                            anchors.left: parent.left
                            width: (parent.width - 20) / 2
                            anchors.verticalCenter: parent.verticalCenter
                            label: "Rim Specular"
                            minVal: 0.0
                            maxVal: 1.2
                            value: PoniConfig.liquidSpecular
                            valueText: Math.round(PoniConfig.liquidSpecular * 100) + "%"
                            onMoved: v => { PoniConfig.liquidSpecular = Math.round(v * 100) / 100; }
                        }

                        CapsuleSlider {
                            visible: PoniConfig.theme === "liquid"
                            anchors.right: parent.right
                            width: (parent.width - 20) / 2
                            anchors.verticalCenter: parent.verticalCenter
                            label: "Bevel Depth"
                            minVal: 0.4
                            maxVal: 1.8
                            value: PoniConfig.liquidBezelScale
                            valueText: PoniConfig.liquidBezelScale.toFixed(1) + "x"
                            onMoved: v => { PoniConfig.liquidBezelScale = Math.round(v * 10) / 10; }
                        }
                    }
                }
            }
        }

        // ==================== TAB 2: BEHAVIOR ====================
        Row {
            visible: root.section === "behavior"
            anchors.top: headerRow.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            // Left Card: Media & Clock
            Rectangle {
                width: (parent.width - 12) / 2
                height: 186
                radius: PoniConfig.theme === "pixel" ? 4 : 12
                color: Qt.rgba(1, 1, 1, 0.04)
                border.color: Qt.rgba(1, 1, 1, 0.07)
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text {
                        text: "MEDIA & CLOCK"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: PoniConfig.colTextFaint
                    }

                    Item {
                        width: parent.width; height: 28
                        Text {
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                            text: "Synced lyrics"
                            font.family: PoniConfig.fontFamily; font.pixelSize: 12; color: PoniConfig.colText
                        }
                        PoniSwitch {
                            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            checked: PoniConfig.showLyrics
                            onToggled: val => { PoniConfig.showLyrics = val; PoniConfig.saveSettings(); }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(1, 1, 1, 0.06) }

                    Item {
                        width: parent.width; height: 28
                        Text {
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                            text: "Lyrics pronunciation"
                            font.family: PoniConfig.fontFamily; font.pixelSize: 12; color: PoniConfig.colText
                        }
                        PoniSwitch {
                            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            checked: PoniConfig.showRomanization
                            onToggled: val => { PoniConfig.showRomanization = val; PoniConfig.saveSettings(); }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(1, 1, 1, 0.06) }

                    Item {
                        width: parent.width; height: 28
                        Text {
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                            text: "24-hour clock"
                            font.family: PoniConfig.fontFamily; font.pixelSize: 12; color: PoniConfig.colText
                        }
                        PoniSwitch {
                            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            checked: PoniConfig.use24h
                            onToggled: val => { PoniConfig.use24h = val; PoniConfig.saveSettings(); }
                        }
                    }
                }
            }

            // Right Card: Notch Interaction
            Rectangle {
                width: (parent.width - 12) / 2
                height: 186
                radius: PoniConfig.theme === "pixel" ? 4 : 12
                color: Qt.rgba(1, 1, 1, 0.04)
                border.color: Qt.rgba(1, 1, 1, 0.07)
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text {
                        text: "INTERACTION"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: PoniConfig.colTextFaint
                    }

                    Item {
                        width: parent.width; height: 28
                        Text {
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                            text: "Expand on hover"
                            font.family: PoniConfig.fontFamily; font.pixelSize: 12; color: PoniConfig.colText
                        }
                        PoniSwitch {
                            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            checked: PoniConfig.hoverExpand
                            onToggled: val => { PoniConfig.hoverExpand = val; PoniConfig.saveSettings(); }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(1, 1, 1, 0.06) }

                    Item {
                        width: parent.width; height: 28
                        Text {
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                            text: "Floating pill"
                            font.family: PoniConfig.fontFamily; font.pixelSize: 12; color: PoniConfig.colText
                        }
                        PoniSwitch {
                            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            checked: PoniConfig.notchFloating
                            onToggled: val => { PoniConfig.notchFloating = val; PoniConfig.saveSettings(); }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(1, 1, 1, 0.06) }

                    Item {
                        width: parent.width; height: 28
                        Text {
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                            text: "Sound effects"
                            font.family: PoniConfig.fontFamily; font.pixelSize: 12; color: PoniConfig.colText
                        }
                        PoniSwitch {
                            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            checked: PoniConfig.soundsEnabled
                            onToggled: val => { PoniConfig.soundsEnabled = val; PoniConfig.saveSettings(); }
                        }
                    }
                }
            }
        }

        // ==================== TAB 3: DISPLAY ====================
        Column {
            visible: root.section === "display"
            anchors.top: headerRow.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 10

            // Card 1: Monitors & Position
            Rectangle {
                width: parent.width
                height: 92
                radius: PoniConfig.theme === "pixel" ? 4 : 12
                color: Qt.rgba(1, 1, 1, 0.04)
                border.color: Qt.rgba(1, 1, 1, 0.07)
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    // Monitor Selection Row
                    Item {
                        width: parent.width
                        height: 28

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Display (" + PoniConfig.detectedMonitors.length + ")"
                                font.family: PoniConfig.fontFamily
                                font.pixelSize: 11
                                color: PoniConfig.colTextDim
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 48
                                height: 20
                                radius: PoniConfig.theme === "pixel" ? 2 : 10
                                color: detectArea.containsMouse ? PoniConfig.colSurfaceHover : PoniConfig.colSurface

                                Text {
                                    anchors.centerIn: parent
                                    text: "Detect"
                                    font.family: PoniConfig.fontFamily
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                    color: PoniConfig.colAccent
                                }

                                MouseArea {
                                    id: detectArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: PoniConfig.detectMonitors()
                                }
                            }
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 5

                            Rectangle {
                                property bool isOn: PoniConfig.displayMode === "cursor"
                                width: 56; height: 22
                                radius: PoniConfig.theme === "pixel" ? 2 : 11
                                color: isOn ? PoniConfig.colAccent : PoniConfig.colSurface

                                Text {
                                    anchors.centerIn: parent
                                    text: "Cursor"
                                    font.family: PoniConfig.fontFamily; font.pixelSize: 10; font.weight: Font.DemiBold
                                    color: parent.isOn ? "#ffffff" : PoniConfig.colTextDim
                                }

                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { PoniConfig.displayMode = "cursor"; PoniConfig.saveSettings(); }
                                }
                            }

                            Rectangle {
                                property bool isOn: PoniConfig.displayMode === "all"
                                width: 36; height: 22
                                radius: PoniConfig.theme === "pixel" ? 2 : 11
                                color: isOn ? Qt.rgba(1, 1, 1, 0.20) : PoniConfig.colSurface

                                Text {
                                    anchors.centerIn: parent
                                    text: "All"
                                    font.family: PoniConfig.fontFamily; font.pixelSize: 10; font.weight: Font.DemiBold
                                    color: parent.isOn ? PoniConfig.colText : PoniConfig.colTextDim
                                }

                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { PoniConfig.displayMode = "all"; PoniConfig.saveSettings(); }
                                }
                            }

                            Repeater {
                                model: PoniConfig.detectedMonitors
                                Rectangle {
                                    required property var modelData
                                    property bool isSel: PoniConfig.displayMode === "selected" && PoniConfig.enabledScreens.indexOf(modelData.name) >= 0
                                    width: monLabel.width + 14; height: 22
                                    radius: PoniConfig.theme === "pixel" ? 2 : 11
                                    color: isSel ? Qt.rgba(1, 1, 1, 0.20) : PoniConfig.colSurface

                                    Text {
                                        id: monLabel
                                        anchors.centerIn: parent
                                        text: parent.modelData.name
                                        font.family: PoniConfig.fontFamily; font.pixelSize: 10
                                        font.weight: parent.isSel ? Font.DemiBold : Font.Normal
                                        color: parent.isSel ? PoniConfig.colText : PoniConfig.colTextDim
                                    }

                                    MouseArea {
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: PoniConfig.toggleScreen(parent.modelData.name)
                                    }
                                }
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Qt.rgba(1, 1, 1, 0.06) }

                    // Notch Horizontal Position
                    Item {
                        width: parent.width
                        height: 28

                        Column {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: "Horizontal Position"
                                font.family: PoniConfig.fontFamily; font.pixelSize: 11; color: PoniConfig.colTextDim
                            }
                            Text {
                                text: "Drag closed notch horizontally to reposition"
                                font.family: PoniConfig.fontFamily; font.pixelSize: 9; color: PoniConfig.colTextFaint
                            }
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 108; height: 22
                            radius: PoniConfig.theme === "pixel" ? 2 : 11
                            color: resetPosArea.containsMouse ? PoniConfig.colSurfaceHover : PoniConfig.colSurface

                            Text {
                                anchors.centerIn: parent
                                text: PoniConfig.islandX === 0 ? "Centered" : "Reset (" + PoniConfig.islandX + "px)"
                                font.family: PoniConfig.fontFamily; font.pixelSize: 10; font.weight: Font.DemiBold
                                color: PoniConfig.islandX === 0 ? PoniConfig.colTextDim : PoniConfig.colAccent
                            }

                            MouseArea {
                                id: resetPosArea
                                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: { PoniConfig.islandX = 0; PoniConfig.saveSettings(); }
                            }
                        }
                    }
                }
            }

            // Card 2: Visible Tabs
            Rectangle {
                width: parent.width
                height: 84
                radius: PoniConfig.theme === "pixel" ? 4 : 12
                color: Qt.rgba(1, 1, 1, 0.04)
                border.color: Qt.rgba(1, 1, 1, 0.07)
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text {
                        text: "CORE TABS"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: PoniConfig.colTextFaint
                    }

                    Row {
                        spacing: 8

                        readonly property var hideables: [
                            { id: "music", title: "Music", icon: "music" },
                            { id: "today", title: "Today", icon: "calendar" },
                            { id: "shelf", title: "Shelf", icon: "tray" },
                            { id: "tasks", title: "Tasks", icon: "listchecks" },
                            { id: "focus", title: "Focus", icon: "timer" }
                        ]

                        Repeater {
                            model: parent.hideables
                            Rectangle {
                                property bool hidden: PoniConfig.isTabHidden(modelData.id)
                                width: 80; height: 26
                                radius: PoniConfig.theme === "pixel" ? 2 : 13
                                color: !hidden ? Qt.rgba(1, 1, 1, 0.16) : PoniConfig.colSurface

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 5
                                    PoniIcon {
                                        name: modelData.icon; size: 12
                                        color: !hidden ? "#ffffff" : PoniConfig.colTextFaint
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.title
                                        font.family: PoniConfig.fontFamily; font.pixelSize: 10
                                        font.weight: !hidden ? Font.DemiBold : Font.Normal
                                        color: !hidden ? PoniConfig.colText : PoniConfig.colTextFaint
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: PoniConfig.toggleTabHidden(modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }

        // ==================== FOOTER ====================
        Item {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 24

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    height: 18
                    width: osLbl.width + 10
                    radius: PoniConfig.theme === "pixel" ? 2 : 9
                    color: PoniConfig.colSurface
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: osLbl
                        anchors.centerIn: parent
                        text: "OS: " + root.detectedOs
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: PoniConfig.colAccent
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.updateStatus
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 10
                    color: root.updateAvailable ? PoniConfig.colOrange : PoniConfig.colTextFaint
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Rectangle {
                    height: 22
                    width: chkLbl.width + 14
                    radius: PoniConfig.theme === "pixel" ? 2 : 11
                    color: chkArea.containsMouse ? PoniConfig.colSurfaceHover : PoniConfig.colSurface

                    Text {
                        id: chkLbl
                        anchors.centerIn: parent
                        text: root.updateChecking ? "Checking..." : "Check Updates"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: PoniConfig.colTextDim
                    }

                    MouseArea {
                        id: chkArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.checkForUpdates()
                    }
                }

                Rectangle {
                    height: 22
                    width: updLbl.width + 16
                    radius: PoniConfig.theme === "pixel" ? 2 : 11
                    color: PoniConfig.colAccent
                    opacity: root.updateDownloading ? 0.65 : 1.0

                    Text {
                        id: updLbl
                        anchors.centerIn: parent
                        text: root.updateDownloading ? "Updating..." : "Updates"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.runSelfUpdate()
                    }
                }
            }
        }
    }
}
