import QtQuick
import QtQuick.Shapes
import "../services"

Item {
    id: root

    property string mode: {
        if (PoniConfig.idleLook === "eyes" && PoniConfig.eyesDuringMedia) return "idle";
        if (PoniMedia.isPlaying || PoniMedia.isPeeking) return "media";
        if (PoniFocus.isRunning) return "focus";
        if (PoniPrayer.isCountingDown) return "prayer";
        return "idle";
    }

    property real mouseXNorm: 0.0
    property bool eyesBlink: false
    property real glanceX: 0.0
    property real glanceY: 0.0
    readonly property real activeEyeX: Math.abs(mouseXNorm) > 0.01 ? mouseXNorm : (PoniConfig.globalEyeX + glanceX)
    readonly property real activeEyeY: PoniConfig.globalEyeY + glanceY

    Timer {
        interval: 2600
        repeat: true
        running: root.mode === "idle" && PoniConfig.idleLook === "eyes"
        onTriggered: {
            var r = Math.random();
            if (r < 0.45) {
                root.eyesBlink = true;
                blinkReset.start();
            } else {
                root.glanceX = (Math.random() - 0.5) * 0.7;
                root.glanceY = (Math.random() - 0.3) * 0.4;
                glanceReset.start();
            }
        }
    }

    Timer {
        id: glanceReset
        interval: 900
        repeat: false
        onTriggered: { root.glanceX = 0.0; root.glanceY = 0.0; }
    }

    Timer {
        id: blinkReset
        interval: 130
        repeat: false
        onTriggered: root.eyesBlink = false
    }

    anchors.fill: parent

    // 1. Idle Look: Clock
    Item {
        id: idleClock
        visible: root.mode === "idle" && (PoniConfig.idleLook === "clock" || PoniConfig.idleLook === "status")
        anchors.fill: parent

        Row {
            anchors.centerIn: parent
            spacing: 6

            PoniIcon {
                visible: PoniSystem.batteryCharging
                anchors.verticalCenter: parent.verticalCenter
                name: "bolt"
                size: 11
                color: PoniConfig.colGreen
            }

            Text {
                visible: !PoniSystem.batteryCharging && PoniSystem.hasBattery && PoniSystem.batteryPct <= 20
                anchors.verticalCenter: parent.verticalCenter
                text: PoniSystem.batteryPct + "%"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: PoniConfig.colRed
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    var now = new Date();
                    var h = now.getHours();
                    var m = now.getMinutes();
                    var t = "";
                    if (!PoniConfig.use24h) {
                        var ampm = h >= 12 ? "PM" : "AM";
                        h = h % 12 || 12;
                        t = h + ":" + (m < 10 ? "0" : "") + m + " " + ampm;
                    } else {
                        t = (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m;
                    }
                    return PoniConfig.theme === "ascii" ? ("[" + t + "]") : t;
                }
                font.family: PoniConfig.fontFamily
                font.pixelSize: PoniConfig.theme === "ascii" ? 12 : 13
                font.weight: Font.DemiBold
                color: PoniConfig.colText
            }
        }
    }

    // 2. Idle Look: Eyes ("Mata doang" in Classic/Glass/Pill/Diorama/Pixel/ASCII)
    Item {
        id: idleEyes
        visible: root.mode === "idle" && PoniConfig.idleLook === "eyes"
        anchors.fill: parent

        // ASCII Eyes: [ o  o ] / [ -  - ]
        Text {
            visible: PoniConfig.theme === "ascii"
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: root.activeEyeX * 5
            anchors.verticalCenterOffset: root.activeEyeY * 2
            text: root.eyesBlink ? "[ -  - ]" : "[ o  o ]"
            font.family: "monospace"
            font.pixelSize: 13
            font.weight: Font.Bold
            color: PoniConfig.colText
            Behavior on anchors.horizontalCenterOffset { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        }

        // Pixel Art animated companion in Pixel / Retro sharp themes (when Capsule default)
        PixelArtCanvas {
            visible: PoniConfig.activeTheme.sharp && PoniConfig.eyeStyle === "capsule" && PoniConfig.theme !== "ascii"
            anchors.centerIn: parent
            mouseXNorm: root.activeEyeX
            eyesBlink: root.eyesBlink
        }

        // Standard Capsule Eyes
        Row {
            visible: PoniConfig.theme !== "ascii" && !PoniConfig.activeTheme.sharp && PoniConfig.eyeStyle === "capsule"
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: root.activeEyeX * 6.5
            anchors.verticalCenterOffset: root.activeEyeY * 2.5 - ((PoniMedia.isPlaying && PoniConfig.eyesDuringMedia) ? (PoniMedia.cavaBars[0] || 0) * 2.0 : 0)
            spacing: 12

            Behavior on anchors.horizontalCenterOffset { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

            Repeater {
                model: 2
                Rectangle {
                    width: 6.5
                    height: root.eyesBlink ? 2.5 : ((PoniMedia.isPlaying && PoniConfig.eyesDuringMedia) ? (10 + (PoniMedia.cavaBars[index * 2] || 0) * 3) : 11)
                    radius: 3.25
                    color: Qt.rgba(1, 1, 1, 0.95)
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on height { NumberAnimation { duration: 60 } }
                }
            }
        }

        // 19 Custom Expressive Eye Styles (Terminator, Sharingan, Rinnegan, Cat, Cyber, Kawaii, etc.)
        Canvas {
            id: customEyeCanvas
            visible: PoniConfig.theme !== "ascii" && PoniConfig.eyeStyle !== "capsule"
            width: 64
            height: 26
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: root.activeEyeX * 6.0
            anchors.verticalCenterOffset: root.activeEyeY * 2.2 - ((PoniMedia.isPlaying && PoniConfig.eyesDuringMedia) ? (PoniMedia.cavaBars[0] || 0) * 1.8 : 0)

            Behavior on anchors.horizontalCenterOffset { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

            property real animPhase: 0.0
            Timer {
                interval: 60
                repeat: true
                running: customEyeCanvas.visible
                onTriggered: {
                    customEyeCanvas.animPhase += 0.12;
                    customEyeCanvas.requestPaint();
                }
            }
            Connections {
                target: root
                function onEyesBlinkChanged() { if (customEyeCanvas.visible) customEyeCanvas.requestPaint(); }
                function onActiveEyeXChanged() { if (customEyeCanvas.visible) customEyeCanvas.requestPaint(); }
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                var st = PoniConfig.eyeStyle;
                var cy = height * 0.5;
                var lx = width * 0.5 - 11;
                var rx = width * 0.5 + 11;
                var ox = root.activeEyeX * 2.2;
                var oy = root.activeEyeY * 1.2;

                if (root.eyesBlink && st !== "wink") {
                    ctx.fillStyle = st === "terminator" ? "#ef4444" : (st === "sharingan" ? "#dc2626" : "#ffffff");
                    ctx.fillRect(lx - 4, cy - 1, 8, 2);
                    ctx.fillRect(rx - 4, cy - 1, 8, 2);
                    return;
                }

                if (st === "terminator") {
                    // Left eye: normal human eye
                    ctx.fillStyle = "#f8fafc";
                    ctx.beginPath(); ctx.arc(lx, cy, 4.2, 0, Math.PI * 2); ctx.fill();
                    ctx.fillStyle = "#0f172a";
                    ctx.beginPath(); ctx.arc(lx + ox * 0.6, cy + oy * 0.6, 2.0, 0, Math.PI * 2); ctx.fill();
                    // Right eye: glowing red cybernetic eye
                    ctx.fillStyle = "rgba(239, 68, 68, 0.42)";
                    ctx.beginPath(); ctx.arc(rx, cy, 7.2, 0, Math.PI * 2); ctx.fill();
                    ctx.fillStyle = "#ef4444";
                    ctx.beginPath(); ctx.arc(rx, cy, 4.6, 0, Math.PI * 2); ctx.fill();
                    ctx.fillStyle = "#fef2f2";
                    ctx.beginPath(); ctx.arc(rx + ox * 0.7, cy + oy * 0.7, 1.7, 0, Math.PI * 2); ctx.fill();
                } else if (st === "sharingan" || st === "rinnegan") {
                    var baseC = st === "sharingan" ? "#dc2626" : "#a855f7";
                    for (var j = 0; j < 2; j++) {
                        var ex2 = j === 0 ? lx : rx;
                        ctx.fillStyle = baseC;
                        ctx.beginPath(); ctx.arc(ex2, cy, 6.5, 0, Math.PI * 2); ctx.fill();
                        ctx.strokeStyle = "#111111"; ctx.lineWidth = 1;
                        ctx.beginPath(); ctx.arc(ex2, cy, 4.2, 0, Math.PI * 2); ctx.stroke();
                        if (st === "rinnegan") {
                            ctx.beginPath(); ctx.arc(ex2, cy, 2.2, 0, Math.PI * 2); ctx.stroke();
                        } else {
                            ctx.fillStyle = "#111111";
                            ctx.beginPath(); ctx.arc(ex2, cy, 1.6, 0, Math.PI * 2); ctx.fill();
                            for (var tm = 0; tm < 3; tm++) {
                                var a = customEyeCanvas.animPhase + tm * (Math.PI * 2 / 3);
                                ctx.beginPath(); ctx.arc(ex2 + Math.cos(a) * 4.2, cy + Math.sin(a) * 4.2, 1.1, 0, Math.PI * 2); ctx.fill();
                            }
                        }
                    }
                } else if (st === "cat") {
                    for (var c = 0; c < 2; c++) {
                        var ex3 = c === 0 ? lx : rx;
                        ctx.fillStyle = "#facc15";
                        ctx.beginPath(); ctx.ellipse(ex3, cy, 5.5, 6.2, 0, 0, Math.PI * 2); ctx.fill();
                        ctx.fillStyle = "#09090b";
                        ctx.beginPath(); ctx.ellipse(ex3 + ox * 0.7, cy + oy * 0.5, 1.4, 5, 0, 0, Math.PI * 2); ctx.fill();
                    }
                } else if (st === "cyber" || st === "cyclops") {
                    ctx.fillStyle = "rgba(6, 182, 212, 0.28)";
                    ctx.fillRect(width * 0.5 - 18, cy - 4, 36, 8);
                    ctx.strokeStyle = "#22d3ee"; ctx.lineWidth = 1.4;
                    ctx.strokeRect(width * 0.5 - 18, cy - 4, 36, 8);
                    var scanX = width * 0.5 + Math.sin(customEyeCanvas.animPhase) * 12;
                    ctx.fillStyle = st === "cyclops" ? "#ef4444" : "#67e8f9";
                    ctx.fillRect(scanX - 3, cy - 2, 6, 4);
                } else if (st === "kawaii") {
                    for (var k = 0; k < 2; k++) {
                        var ex4 = k === 0 ? lx : rx;
                        ctx.fillStyle = "#ffffff";
                        ctx.beginPath(); ctx.arc(ex4, cy, 6, 0, Math.PI * 2); ctx.fill();
                        ctx.fillStyle = "#111827";
                        ctx.beginPath(); ctx.arc(ex4 + ox * 0.6, cy + oy * 0.6, 3.8, 0, Math.PI * 2); ctx.fill();
                        ctx.fillStyle = "#ffffff";
                        ctx.beginPath(); ctx.arc(ex4 + ox * 0.6 - 1.3, cy + oy * 0.6 - 1.3, 1.5, 0, Math.PI * 2); ctx.fill();
                    }
                } else if (st === "angry" || st === "sleepy" || st === "sus") {
                    ctx.fillStyle = "#ffffff";
                    for (var m = 0; m < 2; m++) {
                        var ex5 = m === 0 ? lx : rx;
                        if (st === "sus") {
                            ctx.fillRect(ex5 - 5, cy - 2, 10, 4);
                            ctx.fillStyle = "#111111";
                            ctx.fillRect(ex5 + ox * 1.1 - 1.5, cy - 1.5, 3, 3);
                            ctx.fillStyle = "#ffffff";
                        } else if (st === "sleepy") {
                            ctx.beginPath(); ctx.arc(ex5, cy + 1, 5, 0, Math.PI); ctx.fill();
                        } else {
                            ctx.save(); ctx.translate(ex5, cy); ctx.rotate(m === 0 ? 0.32 : -0.32);
                            ctx.fillRect(-5, -2.5, 10, 5); ctx.restore();
                        }
                    }
                } else if (st === "heart") {
                    ctx.fillStyle = "#fb7185";
                    ctx.font = "bold 14px sans-serif";
                    ctx.textAlign = "center"; ctx.textBaseline = "middle";
                    ctx.fillText("♥", lx, cy + 1); ctx.fillText("♥", rx, cy + 1);
                } else if (st === "star") {
                    ctx.fillStyle = "#fde047";
                    ctx.font = "bold 14px sans-serif";
                    ctx.textAlign = "center"; ctx.textBaseline = "middle";
                    ctx.fillText("✦", lx, cy + 1); ctx.fillText("✦", rx, cy + 1);
                } else if (st === "dollar") {
                    ctx.fillStyle = "#4ade80";
                    ctx.font = "bold 13px monospace";
                    ctx.textAlign = "center"; ctx.textBaseline = "middle";
                    ctx.fillText("$", lx, cy + 1); ctx.fillText("$", rx, cy + 1);
                } else if (st === "matrix") {
                    ctx.fillStyle = "#4ade80";
                    ctx.font = "bold 12px monospace";
                    ctx.textAlign = "center"; ctx.textBaseline = "middle";
                    var d = (Math.floor(customEyeCanvas.animPhase) % 2 === 0) ? "0" : "1";
                    ctx.fillText(d, lx, cy + 1); ctx.fillText(d === "0" ? "1" : "0", rx, cy + 1);
                } else if (st === "xdead") {
                    ctx.fillStyle = "#f87171";
                    ctx.font = "bold 13px monospace";
                    ctx.textAlign = "center"; ctx.textBaseline = "middle";
                    ctx.fillText("X", lx, cy + 1); ctx.fillText("X", rx, cy + 1);
                } else if (st === "wink") {
                    ctx.fillStyle = "#ffffff";
                    ctx.beginPath(); ctx.ellipse(lx, cy, 3.2, 5.5, 0, 0, Math.PI * 2); ctx.fill();
                    ctx.strokeStyle = "#ffffff"; ctx.lineWidth = 2;
                    ctx.beginPath(); ctx.arc(rx, cy + 2, 4.5, Math.PI * 1.15, Math.PI * 1.85); ctx.stroke();
                } else if (st === "spiral") {
                    ctx.strokeStyle = "#e879f9"; ctx.lineWidth = 1.4;
                    for (var sp = 0; sp < 2; sp++) {
                        var ex6 = sp === 0 ? lx : rx;
                        ctx.beginPath();
                        for (var a2 = 0; a2 < 12; a2++) {
                            var rad = a2 * 0.45;
                            var ang2 = a2 * 0.9 + customEyeCanvas.animPhase;
                            if (a2 === 0) ctx.moveTo(ex6, cy);
                            else ctx.lineTo(ex6 + Math.cos(ang2) * rad, cy + Math.sin(ang2) * rad);
                        }
                        ctx.stroke();
                    }
                } else if (st === "alien") {
                    ctx.fillStyle = "#4ade80";
                    for (var al = 0; al < 2; al++) {
                        var ex7 = al === 0 ? lx : rx;
                        ctx.save(); ctx.translate(ex7, cy); ctx.rotate(al === 0 ? 0.35 : -0.35);
                        ctx.beginPath(); ctx.ellipse(0, 0, 4, 6.5, 0, 0, Math.PI * 2); ctx.fill();
                        ctx.restore();
                    }
                } else if (st === "robot") {
                    ctx.fillStyle = "#38bdf8";
                    ctx.fillRect(lx - 4, cy - 4, 8, 8);
                    ctx.fillRect(rx - 4, cy - 4, 8, 8);
                    ctx.fillStyle = "#082f49";
                    ctx.fillRect(lx - 2 + ox * 0.7, cy - 1 + oy * 0.5, 4, 2);
                    ctx.fillRect(rx - 2 + ox * 0.7, cy - 1 + oy * 0.5, 4, 2);
                }
            }
        }
    }

    // 3. Idle Look: Minimal
    Item {
        id: idleMinimal
        visible: root.mode === "idle" && PoniConfig.idleLook === "minimal"
        anchors.centerIn: parent
        width: 16
        height: parent.height

        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: PoniConfig.theme === "pixel" ? 0 : 4
            color: PoniConfig.colSurfaceHover
        }
    }

    // 4. Media Activity (Now Playing on closed island with live Cava visualizer)
    Item {
        id: mediaActivity
        visible: root.mode === "media"
        anchors.fill: parent

        // Album Art thumbnail (22x22) anchored left
        Rectangle {
            id: miniArt
            width: 22
            height: 22
            radius: PoniConfig.theme === "pixel" ? 2 : 6
            color: PoniConfig.colSurface
            clip: true
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            Image {
                anchors.fill: parent
                source: PoniMedia.displayArtUrl
                fillMode: Image.PreserveAspectCrop
                visible: PoniMedia.displayArtUrl.length > 0
            }

            PoniIcon {
                anchors.centerIn: parent
                name: "music"
                size: 12
                color: PoniConfig.colTextDim
                visible: PoniMedia.displayArtUrl.length === 0
            }
        }

        // Live Cava Equalizer Bars (4 bands) anchored safely inside right padding
        Row {
            id: miniEq
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            height: 14

            Repeater {
                model: 4
                Rectangle {
                    required property int index
                    width: 2.5
                    radius: PoniConfig.theme === "pixel" ? 0 : 1.25
                    color: PoniConfig.colAccent
                    property real rawVal: PoniMedia.cavaBars[index * 3] || 0.2
                    height: PoniMedia.isPlaying ? Math.max(3, Math.round(rawVal * 14)) : 3
                    anchors.bottom: parent.bottom

                    Behavior on height { NumberAnimation { duration: 45 } }
                }
            }
        }

        // Lyric or Title line strictly bounded between art and equalizer
        Column {
            anchors.left: miniArt.right
            anchors.leftMargin: 8
            anchors.right: miniEq.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            visible: root.width > 130
            clip: true

            Text {
                width: parent.width
                text: {
                    if (PoniConfig.showLyrics && PoniMedia.currentLyricText.length > 0) {
                        return PoniMedia.currentLyricText;
                    }
                    return PoniMedia.displayTitle || "";
                }
                font.family: PoniConfig.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: PoniConfig.colText
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                width: parent.width
                visible: PoniConfig.showLyrics && PoniConfig.showRomanization && PoniMedia.currentLyricRoman.length > 0
                text: PoniMedia.currentLyricRoman
                font.family: PoniConfig.fontFamily
                font.pixelSize: 9
                color: PoniConfig.colTextDim
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // 5. Focus Activity
    Item {
        id: focusActivity
        visible: root.mode === "focus"
        anchors.fill: parent

        Row {
            anchors.centerIn: parent
            spacing: 8

            PoniIcon {
                name: "timer"
                size: 14
                color: PoniConfig.colAccent
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: PoniFocus.formattedTime
                font.family: PoniConfig.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: PoniConfig.colText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // 6. Prayer Activity (with OK dismiss pill matching activities.rs)
    Item {
        id: prayerActivity
        visible: root.mode === "prayer"
        anchors.fill: parent

        PoniIcon {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            name: "moon"
            size: 16
            color: PoniConfig.colAccent
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 36
            anchors.right: prayerOkPill.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: PoniPrayer.nextPrayerName + " " + PoniPrayer.minutesToNext + " min"
            font.family: PoniConfig.fontFamily
            font.pixelSize: 12
            font.weight: Font.DemiBold
            color: PoniConfig.colAccent
            elide: Text.ElideRight
        }

        Rectangle {
            id: prayerOkPill
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 24
            radius: 12
            color: okArea.containsMouse ? PoniConfig.colSurfaceHover : PoniConfig.colSurface

            Text {
                anchors.centerIn: parent
                text: "OK"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: PoniConfig.colText
            }

            MouseArea {
                id: okArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: PoniPrayer.dismissCountdown()
            }
        }
    }
}
