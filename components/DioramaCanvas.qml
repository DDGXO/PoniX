import QtQuick
import "../services"

Item {
    id: root

    property bool pixelMode: false
    property bool isExpandedMode: false
    property real t: 0.0
    property int autoIdx: 0

    readonly property var sceneIds: {
        var ids = [];
        for (var i = 0; i < PoniConfig.dioramaScenes.length; i++) {
            var id = PoniConfig.dioramaScenes[i].id;
            if (id !== "auto") ids.push(id);
        }
        return ids;
    }

    readonly property var pixelScenes: [
        "pacchase", "catwalk", "rocket", "aquarium", "invaders",
        "pong", "snake", "ufo", "matrix", "campfire",
        "snowcabin", "sakura", "rainbow", "pyramids", "windmill",
        "arcade80s", "crtbedroom", "handheld", "tetris", "breakout",
        "mariosky", "dragonfly", "knighttorch", "wizardtower", "alchemist",
        "castlebats", "slimecave", "whale", "shipwreck", "tokyocross"
    ]

    readonly property string activeScene: {
        if (PoniConfig.dioramaScene && PoniConfig.dioramaScene !== "auto") {
            return PoniConfig.dioramaScene;
        }
        if (root.pixelMode) {
            return pixelScenes[root.autoIdx % pixelScenes.length];
        }
        return sceneIds[root.autoIdx % sceneIds.length];
    }

    Timer {
        interval: 50
        repeat: true
        running: root.visible
        onTriggered: {
            root.t += 0.05;
            sceneCanvas.requestPaint();
        }
    }

    Timer {
        interval: 10000
        repeat: true
        running: root.visible && PoniConfig.dioramaScene === "auto"
        onTriggered: root.autoIdx = (root.autoIdx + 1) % root.sceneIds.length
    }

    Canvas {
        id: sceneCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            var w = width;
            var h = height;
            if (w <= 0 || h <= 0) return;

            ctx.clearRect(0, 0, w, h);
            ctx.imageSmoothingEnabled = !root.pixelMode;

            var s = root.activeScene;
            var t = root.t;
            var expanded = root.isExpandedMode;
            var kScale = expanded ? 1.85 : 1.0;
            var density = expanded ? 3 : 1;

            function px(x, y, pw, ph, col) {
                ctx.fillStyle = col;
                ctx.fillRect(Math.round(x), Math.round(y), Math.round(pw), Math.round(ph));
            }

            function drawSky(cTop, cMid, cBot) {
                var g = ctx.createLinearGradient(0, 0, 0, h);
                g.addColorStop(0, cTop);
                g.addColorStop(0.55, cMid);
                g.addColorStop(1, cBot);
                ctx.fillStyle = g;
                ctx.fillRect(0, 0, w, h);
            }

            function drawHills(colBack, colFront) {
                ctx.fillStyle = colBack;
                ctx.beginPath(); ctx.moveTo(0, h);
                for (var x = 0; x <= w; x += 18) ctx.lineTo(x, h * 0.68 + Math.sin(x * 0.025 + 1.2) * (h * 0.14));
                ctx.lineTo(w, h); ctx.closePath(); ctx.fill();

                ctx.fillStyle = colFront;
                ctx.beginPath(); ctx.moveTo(0, h);
                for (var x2 = 0; x2 <= w; x2 += 14) ctx.lineTo(x2, h * 0.8 + Math.cos(x2 * 0.032) * (h * 0.09));
                ctx.lineTo(w, h); ctx.closePath(); ctx.fill();
            }

            function drawClouds(count, speed, col) {
                ctx.fillStyle = col;
                for (var i = 0; i < count; i++) {
                    var cw = (18 + (i % 3) * 10) * kScale;
                    var ch = (5 + (i % 2) * 3) * kScale;
                    var cx = ((i * 79 + t * (speed + (i % 3) * 4)) % (w + cw * 2)) - cw;
                    var cy = (4 + (i * 19) % Math.max(12, h * 0.45));
                    ctx.fillRect(cx, cy, cw, ch);
                    ctx.fillRect(cx + cw * 0.2, cy - ch * 0.45, cw * 0.6, ch * 0.5);
                }
            }

            function drawParticles(count, vx, vy, size, col1, col2, sway) {
                var total = Math.min(90, count * density);
                var sz = size * (0.85 + kScale * 0.4);
                for (var i = 0; i < total; i++) {
                    var x = ((i * 41 + t * (vx + (i % 3) * 5) + Math.sin(t * 2 + i) * sway) % (w + 20) + (w + 20)) % (w + 20) - 10;
                    var y = ((i * 23 + t * (vy + (i % 4) * 3)) % (h + 14) + (h + 14)) % (h + 14) - 7;
                    px(x, y, sz, sz, (i % 2 === 0) ? col1 : col2);
                }
            }

            function drawWave(yBase, amp, freq, speed, col) {
                ctx.fillStyle = col;
                for (var ox = 0; ox < w; ox += 4) {
                    var oy = yBase + Math.sin(ox * freq + t * speed) * (amp * kScale);
                    ctx.fillRect(ox, oy, 4, h - oy);
                }
            }

            function drawStars(count, col) {
                var total = Math.min(80, count * density);
                ctx.fillStyle = col;
                for (var i = 0; i < total; i++) {
                    ctx.globalAlpha = 0.25 + 0.75 * Math.abs(Math.sin(t * 2.2 + i * 1.3));
                    var sz = (i % 5 === 0) ? 3.5 : ((i % 2 === 0) ? 2.5 : 1.5);
                    ctx.fillRect((i * 53 + 7) % w, (i * 29 + 3) % (h * 0.8), sz, sz);
                }
                ctx.globalAlpha = 1.0;
            }

            function drawSkyline(colBack, colFront, winCol, countStep) {
                for (var b = 0; b < w; b += countStep + 4) {
                    var bh1 = Math.min(h * 0.78, (14 + ((b * 23) % 42)) * kScale);
                    px(b, h - bh1, countStep + 2, bh1, colBack);
                }
                for (var b2 = 0; b2 < w; b2 += countStep) {
                    var bh = Math.min(h * 0.65, (10 + ((b2 * 19) % 34)) * kScale);
                    px(b2, h - bh, countStep - 2, bh, colFront);
                    for (var wy = h - bh + 4; wy < h - 6; wy += 7) {
                        if (((b2 + wy) % 3) === 0) px(b2 + 3, wy, 3, 3, winCol);
                        if (countStep >= 14 && ((b2 + wy) % 2) === 0) px(b2 + 8, wy, 3, 3, winCol);
                    }
                }
            }

            // ---- 40 Unique Handcrafted Scenes ----
            if (s === "meadow") {
                var hr = new Date().getHours();
                var night = (hr >= 18 || hr < 6);
                drawSky(night ? "#090d1a" : "#2563eb", night ? "#141d38" : "#60a5fa", night ? "#1e293b" : "#bae6fd");
                if (night) drawStars(24, "#ffffff"); else drawClouds(6, 12, "rgba(255,255,255,0.45)");
                ctx.fillStyle = night ? "#fef9c3" : "#fde047";
                ctx.beginPath(); ctx.arc(w * 0.8, h * 0.25, 6 * kScale, 0, Math.PI * 2); ctx.fill();
                drawHills(night ? "#151e30" : "#166534", night ? "#1e293b" : "#22c55e");
                px(14, h - 14 * kScale, 14 * kScale, 11 * kScale, night ? "#27273a" : "#e2d5c3");
                px(17, h - 11 * kScale, 4 * kScale, 4 * kScale, night ? "#facc15" : "#60a5fa");
                px(w - 26, h - 14 * kScale, 3 * kScale, 8 * kScale, "#5c3d2e");
                px(w - 32, h - 22 * kScale, 14 * kScale, 10 * kScale, night ? "#14532d" : "#16a34a");
            } else if (s === "rain") {
                drawSky("#070b18", "#0f172a", "#050811");
                drawSkyline("#0f172a", "#1e293b", "#38bdf8", 16);
                ctx.strokeStyle = "rgba(56, 189, 248, 0.75)"; ctx.lineWidth = 1.2;
                for (var r = 0; r < 26 * density; r++) {
                    var rx = ((r * 29 + t * 30) % (w + 14)) - 7;
                    var ry = ((r * 19 + t * 110) % (h + 14)) - 7;
                    ctx.beginPath(); ctx.moveTo(rx, ry); ctx.lineTo(rx - 3, ry + 8 * kScale); ctx.stroke();
                }
            } else if (s === "aurora") {
                drawSky("#040914", "#0a1628", "#0f172a");
                drawStars(22, "#cbd5e1");
                for (var ax = 0; ax < w; ax += 4) {
                    var wave = Math.sin(ax * 0.035 + t * 1.9) * (8 * kScale) + Math.cos(ax * 0.07 - t) * (5 * kScale);
                    var g = ctx.createLinearGradient(0, 2, 0, h - 6);
                    g.addColorStop(0, "rgba(16, 185, 129, 0.0)");
                    g.addColorStop(0.45, "rgba(52, 211, 153, 0.55)");
                    g.addColorStop(0.75, "rgba(167, 139, 250, 0.35)");
                    g.addColorStop(1, "rgba(139, 92, 246, 0.0)");
                    ctx.fillStyle = g; ctx.fillRect(ax, 4 + wave * 0.4, 4, h - 8);
                }
                drawHills("#09111e", "#0f172a");
            } else if (s === "ocean") {
                drawSky("#061224", "#0c223d", "#0369a1");
                drawStars(16, "#e2e8f0");
                var beamA = Math.sin(t * 1.5) * 0.35;
                ctx.fillStyle = "rgba(253, 224, 71, 0.28)";
                ctx.beginPath(); ctx.moveTo(w - 18, h * 0.3);
                ctx.lineTo(w - 18 - 140 * kScale, h * 0.12 + beamA * 34);
                ctx.lineTo(w - 18 - 140 * kScale, h * 0.48 + beamA * 34);
                ctx.closePath(); ctx.fill();
                px(w - 20, h * 0.28, 6, h * 0.72, "#e2e8f0");
                px(w - 20, h * 0.22, 6, 5, "#facc15");
                drawWave(h * 0.65, 3, 0.06, 2.5, "rgba(14, 165, 233, 0.45)");
                drawWave(h * 0.76, 3.2, 0.08, 3.8, "#0284c7");
                drawWave(h * 0.86, 2.5, 0.11, 5.0, "#0369a1");
            } else if (s === "space") {
                drawSky("#03030c", "#08071a", "#110a24");
                drawStars(26, "#e2e8f0");
                ctx.fillStyle = "#a78bfa";
                ctx.beginPath(); ctx.arc(w * 0.78, h * 0.45, 7 * kScale, 0, Math.PI * 2); ctx.fill();
                ctx.strokeStyle = "#f472b6"; ctx.lineWidth = 1.6;
                ctx.beginPath(); ctx.ellipse(w * 0.78, h * 0.45, 13 * kScale, 3.5 * kScale, -0.3, 0, Math.PI * 2); ctx.stroke();
            } else if (s === "matrix") {
                px(0, 0, w, h, "#020904");
                for (var mx = 2; mx < w; mx += 7) {
                    var my = ((mx * 13 + t * (32 + (mx % 5) * 8)) % (h + 30)) - 12;
                    px(mx, my, 2.5, 3, "#86efac");
                    px(mx, my - 6, 2.5, 5, "#22c55e");
                    px(mx, my - 15, 2.5, 8, "rgba(34,197,94,0.28)");
                }
            } else if (s === "campfire") {
                drawSky("#080504", "#180c07", "#241109");
                drawStars(14, "#fde68a");
                drawHills("#140b07", "#1c120c");
                px(w * 0.5 - 9 * kScale, h - 7 * kScale, 18 * kScale, 4 * kScale, "#5c3d2e");
                for (var f = 0; f < 7; f++) {
                    var fh = (8 + Math.sin(t * 11 + f) * 4) * kScale;
                    px(w * 0.5 - 6 * kScale + f * 2 * kScale, h - 7 * kScale - fh, 2.5 * kScale, fh, f % 2 === 0 ? "#f97316" : "#facc15");
                }
                drawParticles(14, 0, -22, 2, "#fde047", "#fb923c", 8);
            } else if (s === "sakura") {
                drawSky("#140a18", "#271229", "#3b1530");
                drawHills("#1a0c1e", "#240f24");
                px(18, h - 22 * kScale, 3, 22 * kScale, "#9f1239");
                px(36, h - 22 * kScale, 3, 22 * kScale, "#9f1239");
                px(13, h - 23 * kScale, 31, 3.5, "#be123c");
                px(15, h - 17 * kScale, 27, 2.5, "#9f1239");
                drawParticles(24, 18, 14, 3, "#f9a8d4", "#fbcfe8", 6);
            } else if (s === "synthgrid") {
                drawSky("#190a29", "#3b0a45", "#be185d");
                ctx.fillStyle = "#ff7edb";
                ctx.beginPath(); ctx.arc(w * 0.5, h * 0.56, 14 * kScale, Math.PI, 0); ctx.fill();
                px(0, h * 0.56, w, h * 0.44, "#120620");
                ctx.strokeStyle = "#36f9f6"; ctx.lineWidth = 1.2;
                for (var k = 0; k < 6; k++) {
                    var yLine = h * 0.56 + (((t * 16) + k * 9) % (h * 0.44));
                    ctx.beginPath(); ctx.moveTo(0, yLine); ctx.lineTo(w, yLine); ctx.stroke();
                }
                for (var vx = -w * 0.5; vx < w * 1.5; vx += 28) {
                    ctx.beginPath(); ctx.moveTo(w * 0.5, h * 0.56); ctx.lineTo(vx, h); ctx.stroke();
                }
            } else if (s === "cybertrain") {
                drawSky("#070a16", "#101935", "#1e1b4b");
                drawSkyline("#0f172a", "#1e293b", "#f472b6", 18);
                px(0, h - 6 * kScale, w, 2.5, "#475569");
                var tx = ((t * 60) % (w + 130)) - 130;
                for (var c = 0; c < 5; c++) {
                    px(tx + c * 24, h - 14 * kScale, 22, 8 * kScale, "#1e293b");
                    px(tx + c * 24 + 3, h - 11 * kScale, 5, 3 * kScale, "#00f0ff");
                    px(tx + c * 24 + 12, h - 11 * kScale, 5, 3 * kScale, "#00f0ff");
                }
            } else if (s === "fireflies") {
                drawSky("#040f0a", "#081c14", "#0c291d");
                drawHills("#061710", "#0b2419");
                drawParticles(22, 4, -6, 3, "#bef264", "#4ade80", 10);
            } else if (s === "aquarium") {
                drawSky("#031326", "#052742", "#083358");
                for (var kl = 10; kl < w; kl += 28) px(kl + Math.sin(t * 2 + kl) * 3, h - 16 * kScale, 3, 16 * kScale, "#10b981");
                for (var fi = 0; fi < 7; fi++) {
                    var fx2 = ((t * (16 + fi * 4) + fi * 44) % (w + 24)) - 12;
                    var fy2 = 6 + ((fi * 19) % Math.max(12, h - 16));
                    px(fx2, fy2, 7 * kScale, 3.5 * kScale, fi % 2 === 0 ? "#fb923c" : "#38bdf8");
                    px(fx2 - 3, fy2 + kScale, 3, 2, "#fde047");
                }
                drawParticles(12, 0, -20, 2.5, "rgba(186,230,253,0.75)", "rgba(125,211,252,0.55)", 3);
            } else if (s === "meteor") {
                drawSky("#050711", "#0c1126", "#161836");
                drawStars(26, "#94a3b8");
                for (var mt = 0; mt < 7; mt++) {
                    var prog = ((t * 0.95 + mt * 0.21) % 1.0);
                    var mx2 = (mt * 63 + 20) % w + prog * 65;
                    var my2 = prog * (h + 14) - 7;
                    ctx.strokeStyle = mt % 2 === 0 ? "#ffffff" : "#7dd3fc"; ctx.lineWidth = 1.6;
                    ctx.beginPath(); ctx.moveTo(mx2, my2); ctx.lineTo(mx2 - 16 * kScale, my2 - 9 * kScale); ctx.stroke();
                }
            } else if (s === "lightning") {
                var flash = (Math.sin(t * 7) > 0.9);
                drawSky(flash ? "#475569" : "#0b1120", flash ? "#334155" : "#111827", "#090d16");
                drawClouds(7, 10, "#1e293b");
                if (flash) {
                    ctx.strokeStyle = "#fde047"; ctx.lineWidth = 2;
                    var lx = w * 0.2 + ((Math.floor(t * 5) * 43) % (w * 0.6));
                    ctx.beginPath(); ctx.moveTo(lx, 6); ctx.lineTo(lx - 6, h * 0.4); ctx.lineTo(lx + 4, h * 0.55); ctx.lineTo(lx - 5, h); ctx.stroke();
                }
            } else if (s === "desert") {
                drawSky("#7c2d12", "#c2410c", "#fb923c");
                ctx.fillStyle = "#fdba74";
                ctx.beginPath(); ctx.arc(w * 0.78, h * 0.28, 6 * kScale, 0, Math.PI * 2); ctx.fill();
                drawHills("#9a3412", "#78350f");
                px(18, h - 20 * kScale, 3, 14 * kScale, "#451a03");
                px(12, h - 22 * kScale, 15, 3, "#166534");
            } else if (s === "volcano") {
                drawSky("#180606", "#2e0b0b", "#0f0909");
                ctx.fillStyle = "#2b1414";
                ctx.beginPath(); ctx.moveTo(w * 0.5 - 32 * kScale, h); ctx.lineTo(w * 0.5 - 8 * kScale, h - 18 * kScale); ctx.lineTo(w * 0.5 + 8 * kScale, h - 18 * kScale); ctx.lineTo(w * 0.5 + 32 * kScale, h); ctx.fill();
                drawParticles(18, 0, -26, 2.5, "#ef4444", "#facc15", 8);
            } else if (s === "snowcabin") {
                drawSky("#08111f", "#13233a", "#1e293b");
                drawHills("#1e293b", "#e2e8f0");
                px(18, h - 16 * kScale, 16 * kScale, 12 * kScale, "#451a03");
                px(23, h - 12 * kScale, 5 * kScale, 5 * kScale, "#fde047");
                drawParticles(28, 8, 16, 2.8, "#ffffff", "#cbd5e1", 5);
            } else if (s === "lava") {
                drawSky("#150726", "#230c3d", "#150726");
                for (var lb = 0; lb < 7; lb++) {
                    var bx = (w * 0.1) + lb * (w * 0.13);
                    var by2 = h * 0.5 + Math.sin(t * 1.6 + lb * 1.4) * (h * 0.3);
                    ctx.fillStyle = lb % 2 === 0 ? "rgba(244, 63, 94, 0.78)" : "rgba(251, 146, 60, 0.78)";
                    ctx.beginPath(); ctx.arc(bx, by2, (6 + (lb % 3) * 2) * kScale, 0, Math.PI * 2); ctx.fill();
                }
            } else if (s === "equalizer") {
                drawSky("#080814", "#111128", "#080814");
                for (var eq = 4; eq < w - 4; eq += 7) {
                    var eh = 6 + Math.abs(Math.sin(t * 4.5 + eq * 0.16)) * (h - 10);
                    px(eq, h - eh, 5, eh, PoniConfig.colAccent.toString());
                }
            } else if (s === "pacchase") {
                drawSky("#050512", "#090920", "#050512");
                for (var dt = 12; dt < w - 10; dt += 14) px(dt, h * 0.5 - 1, 3, 3, "#fde68a");
                var pacX = ((t * 42) % (w + 30)) - 15;
                ctx.fillStyle = "#facc15";
                var mouth = Math.abs(Math.sin(t * 12)) * 0.45;
                ctx.beginPath(); ctx.moveTo(pacX, h * 0.5); ctx.arc(pacX, h * 0.5, 7 * kScale, mouth, Math.PI * 2 - mouth); ctx.closePath(); ctx.fill();
                var gx = pacX - 22 * kScale;
                px(gx - 5 * kScale, h * 0.5 - 5 * kScale, 10 * kScale, 10 * kScale, "#ef4444");
            } else if (s === "catwalk") {
                drawSky("#0c101b", "#151c2e", "#1e293b");
                drawStars(14, "#cbd5e1");
                px(0, h - 5 * kScale, w, 5 * kScale, "#1e293b");
                var cx3 = ((t * 30) % (w + 30)) - 15;
                var step = Math.floor(t * 6) % 2;
                var col = PoniConfig.colAccent.toString();
                px(cx3, h - 11 * kScale, 9 * kScale, 5 * kScale, col);
                px(cx3 + 5 * kScale, h - 16 * kScale, 6 * kScale, 5 * kScale, col);
                px(cx3 + (1 + step) * kScale, h - 6 * kScale, 2 * kScale, 3 * kScale, col);
                px(cx3 + (6 - step) * kScale, h - 6 * kScale, 2 * kScale, 3 * kScale, col);
                px(cx3 + 9 * kScale, h - 14 * kScale, 2, 2, "#ffffff");
            } else if (s === "rocket") {
                drawSky("#050814", "#0c132b", "#141e3d");
                drawParticles(20, -40, 0, 2.5, "#cbd5e1", "#38bdf8", 0);
                var ry2 = h * 0.45 + Math.sin(t * 3.5) * 6 * kScale;
                var rx2 = ((t * 48) % (w + 60)) - 30;
                px(rx2 - 14 * kScale, ry2 - 2 * kScale, 14 * kScale, 4 * kScale, "#f97316");
                px(rx2, ry2 - 4 * kScale, 16 * kScale, 8 * kScale, "#f8fafc");
                px(rx2 + 16 * kScale, ry2 - 2 * kScale, 5 * kScale, 4 * kScale, "#ef4444");
            } else if (s === "ufo") {
                drawSky("#070918", "#0e132b", "#090b1a");
                drawStars(16, "#a5b4fc");
                var ux = w * 0.5 + Math.sin(t * 1.4) * (w * 0.3);
                ctx.fillStyle = "rgba(74, 222, 128, 0.25)";
                ctx.beginPath(); ctx.moveTo(ux - 5 * kScale, h * 0.32); ctx.lineTo(ux - 18 * kScale, h); ctx.lineTo(ux + 18 * kScale, h); ctx.lineTo(ux + 5 * kScale, h * 0.32); ctx.closePath(); ctx.fill();
                px(ux - 10 * kScale, h * 0.26, 20 * kScale, 4 * kScale, "#94a3b8");
                px(ux - 5 * kScale, h * 0.18, 10 * kScale, 4 * kScale, "#4ade80");
            } else if (s === "koi") {
                drawSky("#05181d", "#07252c", "#0a333d");
                var kx = ((t * 22) % (w + 34)) - 17;
                var ky = h * 0.5 + Math.sin(t * 2.5) * (7 * kScale);
                ctx.strokeStyle = "rgba(103, 232, 249, 0.4)";
                ctx.beginPath(); ctx.arc(w * 0.5, h * 0.5, ((t * 15) % (22 * kScale)) + 3, 0, Math.PI * 2); ctx.stroke();
                px(kx, ky - 2 * kScale, 9 * kScale, 4 * kScale, "#fb923c");
                px(kx - 3 * kScale, ky - kScale, 3 * kScale, 2 * kScale, "#ffffff");
            } else if (s === "starfield") {
                drawSky("#03030c", "#08071a", "#110a24");
                for (var sf = 0; sf < 48; sf++) {
                    var ang = sf * 0.73;
                    var dist = ((t * 42 + sf * 13) % (w * 0.65));
                    var sz = 1.5 + (dist / (w * 0.65)) * 3;
                    px(w * 0.5 + Math.cos(ang) * dist, h * 0.5 + Math.sin(ang) * dist * 0.55, sz, sz, sf % 3 === 0 ? "#38bdf8" : "#e0f2fe");
                }
            } else if (s === "pyramids") {
                drawSky("#0f0c24", "#1e1b4b", "#312e81");
                drawStars(20, "#ffffff");
                ctx.fillStyle = "#fef08a";
                ctx.beginPath(); ctx.arc(w * 0.78, h * 0.28, 6 * kScale, 0, Math.PI * 2); ctx.fill();
                drawHills("#3b2f1e", "#5c472c");
                ctx.fillStyle = "#b4833e";
                ctx.beginPath(); ctx.moveTo(24, h - 6); ctx.lineTo(48, h - 26 * kScale); ctx.lineTo(72, h - 6); ctx.fill();
            } else if (s === "radar") {
                drawSky("#031008", "#051a0d", "#031008");
                var rcx = w * 0.5, rcy = h * 0.5;
                ctx.strokeStyle = "rgba(34, 197, 94, 0.35)";
                ctx.beginPath(); ctx.arc(rcx, rcy, Math.min(w, h) * 0.42, 0, Math.PI * 2); ctx.stroke();
                ctx.beginPath(); ctx.arc(rcx, rcy, Math.min(w, h) * 0.22, 0, Math.PI * 2); ctx.stroke();
                ctx.strokeStyle = "#4ade80"; ctx.lineWidth = 1.6;
                ctx.beginPath(); ctx.moveTo(rcx, rcy);
                ctx.lineTo(rcx + Math.cos(t * 2.5) * 24 * kScale, rcy + Math.sin(t * 2.5) * 16 * kScale); ctx.stroke();
            } else if (s === "dna") {
                drawSky("#050d14", "#0a1826", "#050d14");
                ctx.strokeStyle = "#a78bfa"; ctx.lineWidth = 1.8;
                ctx.beginPath();
                for (var ox2 = 0; ox2 < w; ox2 += 3) {
                    var oy2 = h * 0.5 + Math.sin(ox2 * 0.06 + t * 5) * (h * 0.28);
                    if (ox2 === 0) ctx.moveTo(ox2, oy2); else ctx.lineTo(ox2, oy2);
                }
                ctx.stroke();
                ctx.strokeStyle = "#38bdf8"; ctx.beginPath();
                for (var ox3 = 0; ox3 < w; ox3 += 3) {
                    var oy3 = h * 0.5 - Math.sin(ox3 * 0.06 + t * 5) * (h * 0.28);
                    if (ox3 === 0) ctx.moveTo(ox3, oy3); else ctx.lineTo(ox3, oy3);
                }
                ctx.stroke();
            } else if (s === "heartbeat") {
                drawSky("#120509", "#240a12", "#120509");
                ctx.strokeStyle = "#f43f5e"; ctx.lineWidth = 1.8;
                ctx.beginPath();
                for (var hx2 = 0; hx2 < w; hx2 += 3) {
                    var hy2 = h * 0.55;
                    if (((Math.floor(hx2 - t * 44) % 50 + 50) % 50) < 7) hy2 -= h * 0.32;
                    if (hx2 === 0) ctx.moveTo(hx2, hy2); else ctx.lineTo(hx2, hy2);
                }
                ctx.stroke();
            } else if (s === "fireworks") {
                drawSky("#050712", "#0b1024", "#111827");
                drawStars(16, "#94a3b8");
                for (var bIdx = 0; bIdx < 3; bIdx++) {
                    var fwProg = ((t * 0.75 + bIdx * 0.33) % 1.0);
                    var fcx = w * (0.2 + bIdx * 0.3);
                    var fcy = h * (0.35 + (bIdx % 2) * 0.2);
                    for (var fp = 0; fp < 14; fp++) {
                        var fa = fp * (Math.PI * 2 / 14);
                        var rad = fwProg * (18 * kScale);
                        px(fcx + Math.cos(fa) * rad, fcy + Math.sin(fa) * rad * 0.75, 3, 3, fp % 2 === 0 ? "#facc15" : (bIdx === 1 ? "#38bdf8" : "#f472b6"));
                    }
                }
            } else if (s === "windmill") {
                drawSky("#14122b", "#29224d", "#3d2c5e");
                px(0, h - 6 * kScale, w, 6 * kScale, "#15803d");
                px(w * 0.5 - 3 * kScale, h - 20 * kScale, 6 * kScale, 14 * kScale, "#d6d3d1");
                ctx.strokeStyle = "#f8fafc"; ctx.lineWidth = 2;
                for (var bl = 0; bl < 4; bl++) {
                    var ba = t * 2 + bl * (Math.PI / 2);
                    ctx.beginPath(); ctx.moveTo(w * 0.5, h - 18 * kScale);
                    ctx.lineTo(w * 0.5 + Math.cos(ba) * 11 * kScale, h - 18 * kScale + Math.sin(ba) * 11 * kScale); ctx.stroke();
                }
            } else if (s === "sailboat") {
                drawSky("#0c1428", "#1a2a4d", "#0369a1");
                px(0, h - 6 * kScale, w, 6 * kScale, "#0284c7");
                var sx3 = ((t * 18) % (w + 36)) - 18;
                px(sx3, h - 10 * kScale, 15 * kScale, 4 * kScale, "#92400e");
                ctx.fillStyle = "#f8fafc";
                ctx.beginPath(); ctx.moveTo(sx3 + 7 * kScale, h - 10 * kScale); ctx.lineTo(sx3 + 7 * kScale, h - 24 * kScale); ctx.lineTo(sx3 + 14 * kScale, h - 10 * kScale); ctx.fill();
            } else if (s === "waterfall") {
                drawSky("#08141a", "#0d252e", "#08141a");
                px(0, 0, w * 0.35, h, "#1e293b");
                drawParticles(22, 0, 48, 3.5, "#38bdf8", "#bae6fd", 2);
            } else if (s === "invaders") {
                drawSky("#080714", "#120f29", "#080714");
                for (var iv = 0; iv < 7; iv++) {
                    var ix = ((iv * 42 + Math.sin(t * 2) * 18) % (w - 20)) + 10;
                    var iy = h * 0.45 - 4 * kScale + Math.sin(t * 5 + iv) * 5 * kScale;
                    px(ix, iy, 11 * kScale, 7 * kScale, "#a855f7");
                    px(ix + 2 * kScale, iy + 2 * kScale, 2 * kScale, 2 * kScale, "#000000");
                    px(ix + 7 * kScale, iy + 2 * kScale, 2 * kScale, 2 * kScale, "#000000");
                }
            } else if (s === "pong") {
                px(0, 0, w, h, "#050505");
                var bx3 = Math.abs(((t * 68) % ((w - 24) * 2)) - (w - 24)) + 12;
                var by3 = Math.abs(((t * 44) % ((h - 10) * 2)) - (h - 10)) + 5;
                px(8, by3 - 6 * kScale, 4, 12 * kScale, "#ffffff");
                px(w - 12, by3 - 6 * kScale, 4, 12 * kScale, "#ffffff");
                px(bx3 - 3, by3 - 3, 6, 6, "#4ade80");
            } else if (s === "snake") {
                px(0, 0, w, h, "#061208");
                for (var seg = 0; seg < 12; seg++) {
                    var sx4 = ((t * 36 - seg * 6) % w + w) % w;
                    var sy4 = h * 0.5 + Math.sin((t * 36 - seg * 6) * 0.05) * (h * 0.3);
                    px(sx4, sy4, 5 * kScale, 5 * kScale, seg === 0 ? "#86efac" : "#22c55e");
                }
            } else if (s === "clockwork") {
                drawSky("#120f0d", "#1f1914", "#120f0d");
                ctx.strokeStyle = "#f59e0b"; ctx.lineWidth = 2.5;
                ctx.beginPath(); ctx.arc(w * 0.3, h * 0.5, 10 * kScale, t * 2, t * 2 + Math.PI * 1.6); ctx.stroke();
                ctx.beginPath(); ctx.arc(w * 0.5, h * 0.5, 12 * kScale, -t * 2, -t * 2 + Math.PI * 1.6); ctx.stroke();
                ctx.beginPath(); ctx.arc(w * 0.7, h * 0.5, 10 * kScale, t * 2, t * 2 + Math.PI * 1.6); ctx.stroke();
            } else if (s === "rainbow") {
                drawSky("#0f172a", "#1e293b", "#0f172a");
                var rcols = ["#ef4444", "#f97316", "#eab308", "#22c55e", "#38bdf8", "#a855f7"];
                for (var rb = 0; rb < rcols.length; rb++) {
                    ctx.strokeStyle = rcols[rb]; ctx.lineWidth = 2.5 * kScale;
                    ctx.beginPath(); ctx.arc(w * 0.5, h * 0.95, (18 + rb * 3.5) * kScale, Math.PI, 0); ctx.stroke();
                }
                drawClouds(4, 10, "rgba(255,255,255,0.65)");
            } else if (s === "eclipse") {
                drawSky("#04040c", "#0a0a1a", "#04040c");
                drawStars(22, "#ffffff");
                ctx.fillStyle = "#fde047"; ctx.beginPath(); ctx.arc(w * 0.5, h * 0.48, 9 * kScale, 0, Math.PI * 2); ctx.fill();
                ctx.fillStyle = "#04040c"; ctx.beginPath(); ctx.arc(w * 0.5, h * 0.48, 7.5 * kScale, 0, Math.PI * 2); ctx.fill();
            } else if (s === "pendulum") {
                drawSky("#0d0f17", "#171a26", "#0d0f17");
                var pa = Math.sin(t * 2.4) * 0.7;
                var pxP = w * 0.5 + Math.sin(pa) * (h * 0.65);
                var pyP = Math.cos(pa) * (h * 0.65);
                ctx.strokeStyle = "rgba(255,255,255,0.35)"; ctx.lineWidth = 1.5;
                ctx.beginPath(); ctx.moveTo(w * 0.5, 0); ctx.lineTo(pxP, pyP); ctx.stroke();
                ctx.fillStyle = PoniConfig.colAccent.toString();
                ctx.beginPath(); ctx.arc(pxP, pyP, 5 * kScale, 0, Math.PI * 2); ctx.fill();
            } else {
                // Compositional Renderer for Scenes 41-150 (unique sky + terrain + animated subject + fx)
                var extra = {
                    // Nature (41-60)
                    "forestglade":  { sky: ["#0c2618", "#18472e", "#0a1c12"], ter: "forest", sub: "deer",       fx: "dust",      c1: "#fef08a", c2: "#bbf7d0" },
                    "mushroom":     { sky: ["#07091a", "#0f1436", "#050712"], ter: "forest", sub: "shrooms",    fx: "spores",    c1: "#22d3ee", c2: "#a855f7" },
                    "autumnwind":   { sky: ["#2b1208", "#5c2510", "#9a3412"], ter: "hills",  sub: "trees",      fx: "leaves",    c1: "#f97316", c2: "#eab308" },
                    "sakurariver":  { sky: ["#160b24", "#2e1645", "#192647"], ter: "ocean",  sub: "torii",      fx: "petals",    c1: "#f9a8d4", c2: "#fbcfe8" },
                    "alpinefall":   { sky: ["#0c2440", "#1c4a75", "#38bdf8"], ter: "peaks",  sub: "waterfall",  fx: "bubbles",   c1: "#e0f2fe", c2: "#bae6fd" },
                    "bamboosway":   { sky: ["#091f12", "#143d24", "#091c10"], ter: "bamboo", sub: "crane",      fx: "leaves",    c1: "#86efac", c2: "#4ade80" },
                    "sunflowers":   { sky: ["#1d4ed8", "#60a5fa", "#fde047"], ter: "hills",  sub: "sunflowers", fx: "dust",      c1: "#fef08a", c2: "#ffffff" },
                    "caldera":      { sky: ["#1a0505", "#3d0c0c", "#120404"], ter: "peaks",  sub: "volcano",    fx: "embers",    c1: "#ef4444", c2: "#facc15" },
                    "canyondusk":   { sky: ["#3b0f26", "#7c2d12", "#f97316"], ter: "canyon", sub: "eagle",      fx: "dust",      c1: "#fed7aa", c2: "#fdba74" },
                    "mistyfen":     { sky: ["#0e1a24", "#1b3142", "#0f1c26"], ter: "ocean",  sub: "crane",      fx: "fireflies", c1: "#cbd5e1", c2: "#94a3b8" },
                    "gianttree":    { sky: ["#0b1f14", "#19402a", "#08140d"], ter: "forest", sub: "gianttree",  fx: "spores",    c1: "#bef264", c2: "#4ade80" },
                    "wildflower":   { sky: ["#1e40af", "#3b82f6", "#93c5fd"], ter: "hills",  sub: "flowers",    fx: "petals",    c1: "#f472b6", c2: "#fde047" },
                    "icecave":      { sky: ["#051929", "#0a334d", "#03101a"], ter: "cave",   sub: "icicles",    fx: "snow",      c1: "#bae6fd", c2: "#7dd3fc" },
                    "savannah":     { sky: ["#451a03", "#b45309", "#f59e0b"], ter: "dunes",  sub: "giraffe",    fx: "dust",      c1: "#fde68a", c2: "#fbbf24" },
                    "clover":       { sky: ["#062e19", "#0f5132", "#041f11"], ter: "hills",  sub: "ladybug",    fx: "dust",      c1: "#bbf7d0", c2: "#ffffff" },
                    "lagoon":       { sky: ["#041226", "#08294d", "#020b17"], ter: "cave",   sub: "waterfall",  fx: "bubbles",   c1: "#38bdf8", c2: "#bae6fd" },
                    "tundra":       { sky: ["#071224", "#12294a", "#e2e8f0"], ter: "peaks",  sub: "snowcabin",  fx: "snow",      c1: "#ffffff", c2: "#cbd5e1" },
                    "rootsystem":   { sky: ["#1c1108", "#2e1d0f", "#120b05"], ter: "cave",   sub: "roots",      fx: "spores",    c1: "#fde047", c2: "#a3e635" },
                    "pinefog":      { sky: ["#0e171c", "#1b2c36", "#0a1114"], ter: "forest", sub: "owl",        fx: "snow",      c1: "#cbd5e1", c2: "#94a3b8" },
                    "fireflybrook": { sky: ["#051018", "#0b2230", "#040c12"], ter: "ocean",  sub: "trees",      fx: "fireflies", c1: "#bef264", c2: "#fde047" },
                    // Retro & Arcade (61-80)
                    "arcade80s":    { sky: ["#0d041c", "#1f0940", "#080212"], ter: "grid",   sub: "arcade",     fx: "scanlines", c1: "#ff71ce", c2: "#01cdfe" },
                    "crtbedroom":   { sky: ["#0b0d1f", "#171c3d", "#080914"], ter: "none",   sub: "crt",        fx: "scanlines", c1: "#38bdf8", c2: "#a855f7" },
                    "vaporbust":    { sky: ["#1e0a36", "#4c1d95", "#ec4899"], ter: "grid",   sub: "bust",       fx: "scanlines", c1: "#01cdfe", c2: "#ff71ce" },
                    "terminal":     { sky: ["#020a04", "#041408", "#020803"], ter: "none",   sub: "term",       fx: "scanlines", c1: "#4ade80", c2: "#22c55e" },
                    "cassette":     { sky: ["#140c1c", "#261736", "#0e0814"], ter: "none",   sub: "cassette",   fx: "scanlines", c1: "#fb923c", c2: "#facc15" },
                    "vhsstore":     { sky: ["#0c0a1d", "#1b163d", "#090714"], ter: "city",   sub: "vhs",        fx: "scanlines", c1: "#e879f9", c2: "#38bdf8" },
                    "jukebox":      { sky: ["#1a0814", "#360f28", "#12050d"], ter: "none",   sub: "jukebox",    fx: "confetti",  c1: "#f43f5e", c2: "#facc15" },
                    "handheld":     { sky: ["#0f380f", "#1b4d1b", "#0f380f"], ter: "hills",  sub: "dino",       fx: "scanlines", c1: "#9bbc0f", c2: "#cadc9f" },
                    "rollerrink":   { sky: ["#140624", "#2d0b4d", "#10051c"], ter: "grid",   sub: "discoball",  fx: "confetti",  c1: "#f472b6", c2: "#36f9f6" },
                    "drivein":      { sky: ["#050712", "#0d1226", "#050712"], ter: "highway",sub: "screen",     fx: "stars",     c1: "#e2e8f0", c2: "#94a3b8" },
                    "boombox":      { sky: ["#121218", "#22222e", "#0d0d12"], ter: "none",   sub: "boombox",    fx: "lasers",    c1: "#38bdf8", c2: "#f43f5e" },
                    "dinersign":    { sky: ["#1a0a14", "#2e1024", "#0f060c"], ter: "city",   sub: "coffeecup",  fx: "steam",     c1: "#ff71ce", c2: "#fde047" },
                    "gasstation":   { sky: ["#0c0e1c", "#1c1f3b", "#090a14"], ter: "highway",sub: "sign",       fx: "rain",      c1: "#ef4444", c2: "#38bdf8" },
                    "loading":      { sky: ["#0b132b", "#1c2541", "#0b132b"], ter: "none",   sub: "hourglass",  fx: "scanlines", c1: "#38bdf8", c2: "#e2e8f0" },
                    "vinyl":        { sky: ["#140f0c", "#261c16", "#0e0a08"], ter: "none",   sub: "vinyl",      fx: "dust",      c1: "#f59e0b", c2: "#fde68a" },
                    "tetris":       { sky: ["#080814", "#12122b", "#080814"], ter: "none",   sub: "tetris",     fx: "scanlines", c1: "#ef4444", c2: "#38bdf8" },
                    "breakout":     { sky: ["#060914", "#0d1429", "#060914"], ter: "none",   sub: "breakout",   fx: "scanlines", c1: "#facc15", c2: "#f43f5e" },
                    "mariosky":     { sky: ["#1d4ed8", "#3b82f6", "#60a5fa"], ter: "hills",  sub: "coins",      fx: "dust",      c1: "#facc15", c2: "#ffffff" },
                    "crtstatic":    { sky: ["#0f0f12", "#1c1c22", "#0f0f12"], ter: "none",   sub: "glitch",     fx: "scanlines", c1: "#e2e8f0", c2: "#64748b" },
                    "laserdisc":    { sky: ["#09051a", "#180d3d", "#09051a"], ter: "grid",   sub: "disc",       fx: "lasers",    c1: "#c084fc", c2: "#22d3ee" },
                    // Sci-Fi & Space (81-100)
                    "observatory":  { sky: ["#030510", "#0a1029", "#13193b"], ter: "peaks",  sub: "telescope",  fx: "stars",     c1: "#ffffff", c2: "#38bdf8" },
                    "spacediner":   { sky: ["#0a0518", "#1a0d38", "#070312"], ter: "none",   sub: "saturn",     fx: "stars",     c1: "#f472b6", c2: "#38bdf8" },
                    "hackerden":    { sky: ["#030b08", "#061710", "#020604"], ter: "city",   sub: "term",       fx: "rain",      c1: "#00ff41", c2: "#00f0ff" },
                    "blackhole":    { sky: ["#020208", "#090418", "#020208"], ter: "none",   sub: "blackhole",  fx: "warp",      c1: "#f97316", c2: "#fde047" },
                    "nebula":       { sky: ["#080314", "#1f0936", "#2d0b38"], ter: "none",   sub: "nebula",     fx: "stars",     c1: "#c084fc", c2: "#f472b6" },
                    "galaxy":       { sky: ["#03020a", "#0c0724", "#03020a"], ter: "none",   sub: "galaxy",     fx: "stars",     c1: "#38bdf8", c2: "#a855f7" },
                    "satellite":    { sky: ["#030712", "#0b1733", "#030712"], ter: "none",   sub: "satellite",  fx: "stars",     c1: "#38bdf8", c2: "#e2e8f0" },
                    "moonbase":     { sky: ["#050712", "#0e1326", "#334155"], ter: "dunes",  sub: "dome",       fx: "stars",     c1: "#e2e8f0", c2: "#94a3b8" },
                    "mechbay":      { sky: ["#0c1018", "#1a2233", "#090c12"], ter: "city",   sub: "mech",       fx: "spores",    c1: "#f97316", c2: "#38bdf8" },
                    "portal":       { sky: ["#070414", "#150a33", "#070414"], ter: "ruins",  sub: "portal",     fx: "warp",      c1: "#a855f7", c2: "#22d3ee" },
                    "solarflare":   { sky: ["#1f0704", "#4a1207", "#7c2d12"], ter: "none",   sub: "sunflare",   fx: "embers",    c1: "#fb923c", c2: "#fef08a" },
                    "comets":       { sky: ["#040612", "#0a1026", "#040612"], ter: "peaks",  sub: "comets",     fx: "stars",     c1: "#7dd3fc", c2: "#f472b6" },
                    "cyberalley":   { sky: ["#0a0514", "#190c2e", "#06030c"], ter: "alley",  sub: "sign",       fx: "rain",      c1: "#f472b6", c2: "#22d3ee" },
                    "holocity":     { sky: ["#06101f", "#0d2240", "#050c17"], ter: "city",   sub: "holo",       fx: "lasers",    c1: "#38bdf8", c2: "#c084fc" },
                    "spaceship":    { sky: ["#03050e", "#080e24", "#03050e"], ter: "none",   sub: "cruiser",    fx: "warp",      c1: "#38bdf8", c2: "#e2e8f0" },
                    "terraform":    { sky: ["#2b1108", "#5c2512", "#14291c"], ter: "dunes",  sub: "dome",       fx: "dust",      c1: "#4ade80", c2: "#fb923c" },
                    "cryopod":      { sky: ["#04131c", "#0a2a3d", "#04131c"], ter: "none",   sub: "cryo",       fx: "bubbles",   c1: "#67e8f9", c2: "#bae6fd" },
                    "lasergrid":    { sky: ["#080312", "#180833", "#080312"], ter: "grid",   sub: "pyramid",    fx: "lasers",    c1: "#f43f5e", c2: "#22d3ee" },
                    "dronepatrol":  { sky: ["#070914", "#12182e", "#070914"], ter: "city",   sub: "drones",     fx: "lasers",    c1: "#ef4444", c2: "#38bdf8" },
                    "orbitring":    { sky: ["#040814", "#0c1833", "#040814"], ter: "none",   sub: "ringstation",fx: "stars",     c1: "#e2e8f0", c2: "#38bdf8" },
                    // Fantasy & Cozy (101-120)
                    "dragonfly":    { sky: ["#14081c", "#2b1038", "#451436"], ter: "peaks",  sub: "dragon",     fx: "embers",    c1: "#ef4444", c2: "#facc15" },
                    "knighttorch":  { sky: ["#0c0e17", "#181d2e", "#090a10"], ter: "ruins",  sub: "knight",     fx: "embers",    c1: "#f97316", c2: "#fde047" },
                    "wizardtower":  { sky: ["#08091f", "#141842", "#060714"], ter: "hills",  sub: "tower",      fx: "spores",    c1: "#a855f7", c2: "#38bdf8" },
                    "alchemist":    { sky: ["#0d071a", "#1c0e36", "#0b0514"], ter: "cave",   sub: "cauldron",   fx: "bubbles",   c1: "#4ade80", c2: "#c084fc" },
                    "dungeon":      { sky: ["#100b09", "#1f1511", "#0a0705"], ter: "cave",   sub: "torch",      fx: "embers",    c1: "#f97316", c2: "#fde047" },
                    "castlebats":   { sky: ["#0a0818", "#181333", "#080612"], ter: "peaks",  sub: "castle",     fx: "bats",      c1: "#cbd5e1", c2: "#a78bfa" },
                    "shrine":       { sky: ["#081610", "#122b1f", "#0a1c14"], ter: "forest", sub: "torii",      fx: "fireflies", c1: "#fde047", c2: "#86efac" },
                    "lanterns":     { sky: ["#12081a", "#241030", "#0e0614"], ter: "hills",  sub: "lanterns",   fx: "embers",    c1: "#fb923c", c2: "#fde047" },
                    "coffeeshop":   { sky: ["#1a120b", "#2c1e12", "#140d07"], ter: "city",   sub: "coffeecup",  fx: "rain",      c1: "#bae6fd", c2: "#fde68a" },
                    "fireplace":    { sky: ["#140905", "#291209", "#120704"], ter: "none",   sub: "hearth",     fx: "embers",    c1: "#f97316", c2: "#facc15" },
                    "greenhouse":   { sky: ["#0c1f14", "#183a26", "#0b1a11"], ter: "forest", sub: "flowers",    fx: "dust",      c1: "#fef08a", c2: "#86efac" },
                    "ramenstall":   { sky: ["#140c10", "#29151e", "#0c0709"], ter: "alley",  sub: "ramen",      fx: "steam",     c1: "#fde047", c2: "#f87171" },
                    "bathhouse":    { sky: ["#0b161c", "#142933", "#091217"], ter: "ocean",  sub: "lanterns",   fx: "steam",     c1: "#e2e8f0", c2: "#99f6e4" },
                    "trainwindow":  { sky: ["#162238", "#2b426b", "#15291c"], ter: "hills",  sub: "trees",      fx: "dust",      c1: "#fef9c3", c2: "#cbd5e1" },
                    "atticstorm":   { sky: ["#0a0e17", "#161e2e", "#080b12"], ter: "none",   sub: "window",     fx: "rain",      c1: "#bae6fd", c2: "#38bdf8" },
                    "library":      { sky: ["#17100b", "#291c12", "#0f0a07"], ter: "none",   sub: "books",      fx: "dust",      c1: "#fde68a", c2: "#f59e0b" },
                    "bakery":       { sky: ["#1c1209", "#362210", "#140d06"], ter: "city",   sub: "coffeecup",  fx: "steam",     c1: "#fed7aa", c2: "#fde047" },
                    "fairyring":    { sky: ["#07121a", "#0f2636", "#050e14"], ter: "forest", sub: "shrooms",    fx: "fireflies", c1: "#f472b6", c2: "#a855f7" },
                    "ghosttown":    { sky: ["#14101c", "#261e36", "#0d0a12"], ter: "dunes",  sub: "ghosts",     fx: "dust",      c1: "#cbd5e1", c2: "#94a3b8" },
                    "slimecave":    { sky: ["#061410", "#0c2920", "#040d0a"], ter: "cave",   sub: "slimes",     fx: "bubbles",   c1: "#4ade80", c2: "#86efac" },
                    // Ocean & Underwater (121-135)
                    "coralreef":    { sky: ["#03192e", "#07365e", "#04223d"], ter: "ocean",  sub: "fish",       fx: "bubbles",   c1: "#fb923c", c2: "#38bdf8" },
                    "deepangler":   { sky: ["#01040c", "#030a1c", "#010308"], ter: "trench", sub: "angler",     fx: "spores",    c1: "#22d3ee", c2: "#a855f7" },
                    "shipwreck":    { sky: ["#03111f", "#06213b", "#020b14"], ter: "trench", sub: "shipwreck",  fx: "bubbles",   c1: "#facc15", c2: "#7dd3fc" },
                    "whale":        { sky: ["#04162b", "#082d54", "#031121"], ter: "ocean",  sub: "whale",      fx: "bubbles",   c1: "#bae6fd", c2: "#60a5fa" },
                    "jellyfish":    { sky: ["#040b24", "#091847", "#03081a"], ter: "trench", sub: "jellyfish",  fx: "spores",    c1: "#f472b6", c2: "#c084fc" },
                    "hydrovent":    { sky: ["#04060d", "#0b101f", "#030408"], ter: "trench", sub: "volcano",    fx: "bubbles",   c1: "#ef4444", c2: "#94a3b8" },
                    "atoll":        { sky: ["#0c4a6e", "#0284c7", "#38bdf8"], ter: "ocean",  sub: "palm",       fx: "dust",      c1: "#fde047", c2: "#ffffff" },
                    "submarine":    { sky: ["#031324", "#062440", "#020d17"], ter: "trench", sub: "sub",        fx: "bubbles",   c1: "#facc15", c2: "#38bdf8" },
                    "sunkencity":   { sky: ["#041826", "#08304a", "#03121c"], ter: "ruins",  sub: "fish",       fx: "bubbles",   c1: "#38bdf8", c2: "#99f6e4" },
                    "mantaray":     { sky: ["#041b30", "#09365c", "#031424"], ter: "ocean",  sub: "manta",      fx: "bubbles",   c1: "#7dd3fc", c2: "#e0f2fe" },
                    "seaturtle":    { sky: ["#041c2c", "#083654", "#031624"], ter: "bamboo", sub: "turtle",     fx: "bubbles",   c1: "#4ade80", c2: "#bae6fd" },
                    "cavediver":    { sky: ["#030914", "#07152b", "#02060d"], ter: "cave",   sub: "diver",      fx: "bubbles",   c1: "#fde047", c2: "#7dd3fc" },
                    "oyster":       { sky: ["#041626", "#082945", "#03101c"], ter: "trench", sub: "pearl",      fx: "bubbles",   c1: "#fef9c3", c2: "#f9a8d4" },
                    "octopus":      { sky: ["#061124", "#0d2245", "#040b17"], ter: "trench", sub: "octopus",    fx: "bubbles",   c1: "#c084fc", c2: "#f472b6" },
                    "kelpcathedral":{ sky: ["#031a1c", "#052e30", "#021415"], ter: "bamboo", sub: "fish",       fx: "bubbles",   c1: "#2dd4bf", c2: "#99f6e4" },
                    // City & Weather (136-150)
                    "tokyocross":   { sky: ["#090818", "#161438", "#070612"], ter: "city",   sub: "pedestrians",fx: "lasers",    c1: "#f472b6", c2: "#22d3ee" },
                    "subway":       { sky: ["#0c0f14", "#171c24", "#080a0e"], ter: "bridge", sub: "train",      fx: "scanlines", c1: "#facc15", c2: "#38bdf8" },
                    "rooftop":      { sky: ["#2e102e", "#7c2d4d", "#fb923c"], ter: "city",   sub: "watertower", fx: "dust",      c1: "#f9a8d4", c2: "#fde047" },
                    "yellowcab":    { sky: ["#080a14", "#12172b", "#06080f"], ter: "city",   sub: "taxi",       fx: "rain",      c1: "#facc15", c2: "#38bdf8" },
                    "crane":        { sky: ["#0f172a", "#1e293b", "#334155"], ter: "city",   sub: "crane",      fx: "dust",      c1: "#f97316", c2: "#e2e8f0" },
                    "nightmarket":  { sky: ["#140a14", "#291224", "#0e060e"], ter: "alley",  sub: "lanterns",   fx: "steam",     c1: "#fb923c", c2: "#ef4444" },
                    "fireescape":   { sky: ["#120c14", "#241729", "#0c080d"], ter: "alley",  sub: "flowers",    fx: "fireflies", c1: "#4ade80", c2: "#f472b6" },
                    "trainbridge":  { sky: ["#070b18", "#111a36", "#050914"], ter: "bridge", sub: "train",      fx: "stars",     c1: "#38bdf8", c2: "#fde047" },
                    "parkbench":    { sky: ["#1c120c", "#362216", "#120b07"], ter: "hills",  sub: "bench",      fx: "leaves",    c1: "#f97316", c2: "#eab308" },
                    "skatepark":    { sky: ["#141026", "#2b204d", "#120d21"], ter: "dunes",  sub: "skater",     fx: "confetti",  c1: "#38bdf8", c2: "#f472b6" },
                    "busstop":      { sky: ["#080e1a", "#111c33", "#060a12"], ter: "city",   sub: "bus",        fx: "rain",      c1: "#bae6fd", c2: "#fde047" },
                    "pizzeria":     { sky: ["#140a0a", "#291212", "#0d0606"], ter: "alley",  sub: "moped",      fx: "steam",     c1: "#ef4444", c2: "#22c55e" },
                    "highwayjam":   { sky: ["#050712", "#0c1126", "#04050d"], ter: "highway",sub: "traffic",    fx: "lasers",    c1: "#ef4444", c2: "#f8fafc" },
                    "blizzard":     { sky: ["#0b1320", "#1c2d42", "#334155"], ter: "peaks",  sub: "trees",      fx: "snow",      c1: "#ffffff", c2: "#cbd5e1" },
                    "mirage":       { sky: ["#451a03", "#9a3412", "#ea580c"], ter: "dunes",  sub: "tumbleweed", fx: "dust",      c1: "#fed7aa", c2: "#fdba74" },
                    // 151-200 Aesthetic Landscapes (Pemandangan)
                    "lavender":     { sky: ["#3b1d5e", "#7e22ce", "#f472b6"], ter: "hills",  sub: "flowers",    fx: "petals",    c1: "#d8b4fe", c2: "#f9a8d4" },
                    "fjord":        { sky: ["#0c1e38", "#1d4e73", "#38bdf8"], ter: "peaks",  sub: "whale",      fx: "snow",      c1: "#e0f2fe", c2: "#bae6fd" },
                    "riceterrace":  { sky: ["#0f3d2e", "#166534", "#fde047"], ter: "hills",  sub: "trees",      fx: "dust",      c1: "#bbf7d0", c2: "#fef08a" },
                    "hotspring":    { sky: ["#140c1c", "#2e1a36", "#0f2933"], ter: "peaks",  sub: "lanterns",   fx: "steam",     c1: "#e2e8f0", c2: "#fde047" },
                    "pastelcloud":  { sky: ["#4c1d95", "#ec4899", "#fed7aa"], ter: "hills",  sub: "flowers",    fx: "dust",      c1: "#fbcfe8", c2: "#fef08a" },
                    "goldenfield":  { sky: ["#78350f", "#d97706", "#fde047"], ter: "hills",  sub: "sunflowers", fx: "dust",      c1: "#fef08a", c2: "#ffffff" },
                    "twilightcliff":{ sky: ["#1e1b4b", "#6d28d9", "#f43f5e"], ter: "canyon", sub: "crane",      fx: "stars",     c1: "#fda4af", c2: "#fef08a" },
                    "moonlake":     { sky: ["#050a18", "#0f2042", "#1e3a8a"], ter: "ocean",  sub: "saturn",     fx: "fireflies", c1: "#fef9c3", c2: "#93c5fd" },
                    "pinevalley":   { sky: ["#091a14", "#15382a", "#2b5943"], ter: "forest", sub: "deer",       fx: "dust",      c1: "#bbf7d0", c2: "#e2e8f0" },
                    "alpineglow":   { sky: ["#311042", "#be185d", "#fb923c"], ter: "peaks",  sub: "eagle",      fx: "snow",      c1: "#fbcfe8", c2: "#fed7aa" },
                    "sunsetbay":    { sky: ["#450a0a", "#ea580c", "#fde047"], ter: "ocean",  sub: "whale",      fx: "dust",      c1: "#fed7aa", c2: "#fef08a" },
                    "canyonmist":   { sky: ["#2e1010", "#7c2d12", "#d97706"], ter: "canyon", sub: "eagle",      fx: "steam",     c1: "#fed7aa", c2: "#e2e8f0" },
                    "cherrybridge": { sky: ["#1a0b24", "#4a1942", "#831843"], ter: "bridge", sub: "torii",      fx: "petals",    c1: "#f9a8d4", c2: "#fbcfe8" },
                    "iceberg":      { sky: ["#061a2e", "#0c4a6e", "#7dd3fc"], ter: "ocean",  sub: "whale",      fx: "snow",      c1: "#ffffff", c2: "#bae6fd" },
                    "stargaze":     { sky: ["#03040f", "#0b102e", "#1e1b4b"], ter: "hills",  sub: "telescope",  fx: "stars",     c1: "#fef08a", c2: "#7dd3fc" },
                    "fireflylake":  { sky: ["#041214", "#082426", "#0b3336"], ter: "ocean",  sub: "trees",      fx: "fireflies", c1: "#bef264", c2: "#4ade80" },
                    "rainyvalley":  { sky: ["#0b131e", "#1a2b40", "#0f172a"], ter: "hills",  sub: "trees",      fx: "rain",      c1: "#bae6fd", c2: "#38bdf8" },
                    "snowpine":     { sky: ["#0c1824", "#1b334a", "#e2e8f0"], ter: "forest", sub: "snowcabin",  fx: "snow",      c1: "#ffffff", c2: "#cbd5e1" },
                    "oceanhorizon": { sky: ["#0c4a6e", "#0284c7", "#38bdf8"], ter: "ocean",  sub: "manta",      fx: "dust",      c1: "#ffffff", c2: "#bae6fd" },
                    "mistpeak":     { sky: ["#0f172a", "#334155", "#64748b"], ter: "peaks",  sub: "crane",      fx: "steam",     c1: "#e2e8f0", c2: "#cbd5e1" },
                    "duskharbor":   { sky: ["#1e1b4b", "#7c2d12", "#f97316"], ter: "ocean",  sub: "lanterns",   fx: "embers",    c1: "#fde047", c2: "#fb923c" },
                    "autumnriver":  { sky: ["#2e1208", "#7c2d12", "#0c4a6e"], ter: "ocean",  sub: "trees",      fx: "leaves",    c1: "#f97316", c2: "#eab308" },
                    "springhill":   { sky: ["#1d4ed8", "#38bdf8", "#86efac"], ter: "hills",  sub: "flowers",    fx: "petals",    c1: "#fbcfe8", c2: "#fef08a" },
                    "summerbeach":  { sky: ["#0284c7", "#38bdf8", "#fde68a"], ter: "ocean",  sub: "palm",       fx: "dust",      c1: "#fef08a", c2: "#ffffff" },
                    "wintermoon":   { sky: ["#040814", "#0f1c3a", "#1e293b"], ter: "peaks",  sub: "owl",        fx: "snow",      c1: "#ffffff", c2: "#93c5fd" },
                    "coralbay":     { sky: ["#032830", "#065f46", "#2dd4bf"], ter: "ocean",  sub: "turtle",     fx: "bubbles",   c1: "#99f6e4", c2: "#fde047" },
                    "lotuspond":    { sky: ["#0a1f1c", "#113832", "#06211d"], ter: "ocean",  sub: "flowers",    fx: "fireflies", c1: "#f9a8d4", c2: "#bef264" },
                    "redwood":      { sky: ["#2b1208", "#143d24", "#091c10"], ter: "forest", sub: "gianttree",  fx: "dust",      c1: "#fde047", c2: "#86efac" },
                    "cliffvillage": { sky: ["#1e3a8a", "#f472b6", "#fed7aa"], ter: "canyon", sub: "snowcabin",  fx: "dust",      c1: "#fef08a", c2: "#ffffff" },
                    "desertmoon":   { sky: ["#0a081c", "#1e1640", "#451a03"], ter: "dunes",  sub: "saturn",     fx: "stars",     c1: "#fef08a", c2: "#fdba74" },
                    "glacier":      { sky: ["#082f49", "#0369a1", "#bae6fd"], ter: "peaks",  sub: "icicles",    fx: "snow",      c1: "#ffffff", c2: "#7dd3fc" },
                    "aurorapeak":   { sky: ["#040b18", "#064e3b", "#4c1d95"], ter: "peaks",  sub: "trees",      fx: "stars",     c1: "#34d399", c2: "#a78bfa" },
                    "skyisland":    { sky: ["#1e40af", "#60a5fa", "#fbcfe8"], ter: "peaks",  sub: "gianttree",  fx: "dust",      c1: "#ffffff", c2: "#fde047" },
                    "cloudsea":     { sky: ["#1e1b4b", "#db2777", "#fde68a"], ter: "hills",  sub: "eagle",      fx: "steam",     c1: "#fbcfe8", c2: "#ffffff" },
                    "meadowbrook":  { sky: ["#0284c7", "#34d399", "#fef08a"], ter: "ocean",  sub: "deer",       fx: "petals",    c1: "#ffffff", c2: "#fbcfe8" },
                    "sunsetpier":   { sky: ["#3b0764", "#ea580c", "#facc15"], ter: "bridge", sub: "lanterns",   fx: "dust",      c1: "#fde047", c2: "#fb923c" },
                    "bamboozen":    { sky: ["#061c12", "#14532d", "#05140d"], ter: "bamboo", sub: "torii",      fx: "fireflies", c1: "#bef264", c2: "#86efac" },
                    "rainyforest":  { sky: ["#05140e", "#0d2e20", "#040d09"], ter: "forest", sub: "shrooms",    fx: "rain",      c1: "#86efac", c2: "#4ade80" },
                    "starrydune":   { sky: ["#040614", "#171133", "#451a03"], ter: "dunes",  sub: "tumbleweed", fx: "stars",     c1: "#fef08a", c2: "#ffffff" },
                    "emeraldgorge": { sky: ["#062e1c", "#0f5132", "#0284c7"], ter: "canyon", sub: "waterfall",  fx: "bubbles",   c1: "#6ee7b7", c2: "#bae6fd" },
                    "ambervalley":  { sky: ["#451a03", "#b45309", "#f59e0b"], ter: "hills",  sub: "trees",      fx: "leaves",    c1: "#fde047", c2: "#fb923c" },
                    "violetdusk":   { sky: ["#1e1038", "#6d28d9", "#c084fc"], ter: "peaks",  sub: "crane",      fx: "stars",     c1: "#e9d5ff", c2: "#f472b6" },
                    "rosegarden":   { sky: ["#2e0b1e", "#831843", "#f472b6"], ter: "hills",  sub: "flowers",    fx: "petals",    c1: "#fda4af", c2: "#fbcfe8" },
                    "moongrove":    { sky: ["#060d1c", "#0f2447", "#1e3a5f"], ter: "forest", sub: "owl",        fx: "fireflies", c1: "#fef9c3", c2: "#7dd3fc" },
                    "frostmeadow":  { sky: ["#0f172a", "#334155", "#e0f2fe"], ter: "hills",  sub: "deer",       fx: "snow",      c1: "#ffffff", c2: "#bae6fd" },
                    "silverlake":   { sky: ["#0f172a", "#475569", "#94a3b8"], ter: "ocean",  sub: "crane",      fx: "dust",      c1: "#f8fafc", c2: "#cbd5e1" },
                    "crimsoncliff": { sky: ["#450a0a", "#991b1b", "#f97316"], ter: "canyon", sub: "dragon",     fx: "embers",    c1: "#fca5a5", c2: "#fde047" },
                    "jadepool":     { sky: ["#042f2e", "#0f766e", "#2dd4bf"], ter: "cave",   sub: "waterfall",  fx: "spores",    c1: "#99f6e4", c2: "#5eead4" },
                    "peachsky":     { sky: ["#7c2d12", "#fb923c", "#fecdd3"], ter: "hills",  sub: "flowers",    fx: "petals",    c1: "#fecdd3", c2: "#fef08a" },
                    "midnightsea":  { sky: ["#020617", "#0f172a", "#1e3a8a"], ter: "ocean",  sub: "jellyfish",  fx: "stars",     c1: "#38bdf8", c2: "#e2e8f0" }
                }[s];

                if (extra) {
                    drawSky(extra.sky[0], extra.sky[1], extra.sky[2]);

                    // Terrain layer
                    if (extra.ter === "hills") drawHills("rgba(0,0,0,0.28)", "rgba(0,0,0,0.45)");
                    else if (extra.ter === "peaks") {
                        ctx.fillStyle = "rgba(15,23,42,0.75)";
                        ctx.beginPath(); ctx.moveTo(0, h); ctx.lineTo(w * 0.2, h * 0.45); ctx.lineTo(w * 0.4, h);
                        ctx.lineTo(w * 0.65, h * 0.38); ctx.lineTo(w * 0.9, h); ctx.closePath(); ctx.fill();
                    } else if (extra.ter === "city") drawSkyline("rgba(15,23,42,0.6)", "rgba(30,41,59,0.85)", extra.c2, 16);
                    else if (extra.ter === "ocean") drawWave(h * 0.72, 3, 0.08, 3.2, "rgba(14,165,233,0.45)");
                    else if (extra.ter === "forest" || extra.ter === "bamboo") {
                        for (var tr = 10; tr < w; tr += 18) {
                            px(tr, 4, 3 * kScale, h - 4, "rgba(10,30,18,0.8)");
                            if (extra.ter === "forest") px(tr - 5 * kScale, 6, 12 * kScale, 12 * kScale, "rgba(20,60,35,0.75)");
                        }
                    } else if (extra.ter === "grid") {
                        ctx.strokeStyle = extra.c1; ctx.lineWidth = 1;
                        for (var gk = 0; gk < 5; gk++) {
                            var gy = h * 0.58 + (((t * 14) + gk * 9) % (h * 0.42));
                            ctx.beginPath(); ctx.moveTo(0, gy); ctx.lineTo(w, gy); ctx.stroke();
                        }
                    } else if (extra.ter === "dunes" || extra.ter === "canyon") {
                        drawHills("rgba(120,53,15,0.5)", "rgba(69,26,3,0.7)");
                    } else if (extra.ter === "cave" || extra.ter === "trench") {
                        px(0, 0, w, 6 * kScale, "rgba(0,0,0,0.5)");
                        px(0, h - 6 * kScale, w, 6 * kScale, "rgba(0,0,0,0.65)");
                    } else if (extra.ter === "bridge" || extra.ter === "highway") {
                        px(0, h - 8 * kScale, w, 8 * kScale, "#1e293b");
                        px(0, h - 5 * kScale, w, 1.5, extra.c1);
                    } else if (extra.ter === "ruins" || extra.ter === "alley") {
                        for (var cl = 14; cl < w; cl += 44) px(cl, h - 22 * kScale, 5 * kScale, 22 * kScale, "rgba(255,255,255,0.12)");
                    }

                    // Subject layer (animated focal element)
                    var sub = extra.sub;
                    var sx = ((t * 26) % (w + 40)) - 20;
                    var bob = Math.sin(t * 3) * 3 * kScale;
                    if (sub === "whale" || sub === "manta" || sub === "sub" || sub === "turtle" || sub === "cruiser") {
                        px(sx, h * 0.45 + bob, 20 * kScale, 8 * kScale, extra.c1);
                        px(sx - 5 * kScale, h * 0.45 + bob + 2 * kScale, 6 * kScale, 4 * kScale, extra.c2);
                    } else if (sub === "dragon" || sub === "eagle" || sub === "bats" || sub === "drones") {
                        for (var dr = 0; dr < 3; dr++) {
                            var dx = ((sx + dr * 55) % (w + 30)) - 15;
                            var dy = h * 0.3 + dr * 8 + Math.sin(t * 5 + dr) * 4 * kScale;
                            px(dx, dy, 9 * kScale, 4 * kScale, extra.c1);
                            px(dx + 2 * kScale, dy - 3 * kScale + (Math.floor(t * 8) % 3), 5 * kScale, 3 * kScale, extra.c2);
                        }
                    } else if (sub === "taxi" || sub === "bus" || sub === "moped" || sub === "train" || sub === "skater" || sub === "traffic") {
                        for (var vh = 0; vh < (sub === "traffic" ? 5 : 2); vh++) {
                            var vx2 = ((t * (40 + vh * 12) + vh * 45) % (w + 30)) - 15;
                            px(vx2, h - 10 * kScale, 14 * kScale, 5 * kScale, vh % 2 === 0 ? extra.c1 : extra.c2);
                        }
                    } else if (sub === "shrooms" || sub === "flowers" || sub === "sunflowers" || sub === "trees" || sub === "gianttree") {
                        for (var pl = 18; pl < w - 18; pl += 36) {
                            px(pl, h - 12 * kScale, 3 * kScale, 10 * kScale, "#166534");
                            px(pl - 4 * kScale, h - 15 * kScale, 11 * kScale, 5 * kScale, extra.c1);
                        }
                    } else if (sub === "saturn" || sub === "blackhole" || sub === "galaxy" || sub === "nebula" || sub === "portal" || sub === "sunflare") {
                        ctx.fillStyle = extra.c1; ctx.beginPath(); ctx.arc(w * 0.5, h * 0.48, 8 * kScale, 0, Math.PI * 2); ctx.fill();
                        ctx.strokeStyle = extra.c2; ctx.lineWidth = 1.6;
                        ctx.beginPath(); ctx.ellipse(w * 0.5, h * 0.48, 15 * kScale, 4 * kScale, t * 0.4, 0, Math.PI * 2); ctx.stroke();
                    } else if (sub === "vinyl" || sub === "cassette" || sub === "disc" || sub === "discoball" || sub === "hourglass") {
                        ctx.strokeStyle = extra.c1; ctx.lineWidth = 2;
                        ctx.beginPath(); ctx.arc(w * 0.5, h * 0.5, 11 * kScale, t * 3, t * 3 + Math.PI * 1.5); ctx.stroke();
                        ctx.fillStyle = extra.c2; ctx.beginPath(); ctx.arc(w * 0.5, h * 0.5, 3 * kScale, 0, Math.PI * 2); ctx.fill();
                    } else if (sub === "jellyfish" || sub === "angler" || sub === "octopus" || sub === "ghosts" || sub === "slimes") {
                        for (var jf = 0; jf < 4; jf++) {
                            var jx = (w * 0.15) + jf * (w * 0.22) + Math.sin(t * 1.5 + jf) * 6;
                            var jy = h * 0.45 + Math.cos(t * 2 + jf) * 6 * kScale;
                            px(jx - 5 * kScale, jy - 3 * kScale, 10 * kScale, 6 * kScale, jf % 2 === 0 ? extra.c1 : extra.c2);
                        }
                    } else if (sub === "tumbleweed") {
                        ctx.strokeStyle = extra.c2; ctx.lineWidth = 1.5;
                        ctx.beginPath(); ctx.arc(sx, h - 7 * kScale, 5 * kScale, t * 5, t * 5 + Math.PI * 1.7); ctx.stroke();
                    } else {
                        px(w * 0.5 - 8 * kScale, h - 16 * kScale, 16 * kScale, 12 * kScale, "rgba(255,255,255,0.16)");
                        px(w * 0.5 - 4 * kScale, h - 12 * kScale, 8 * kScale, 5 * kScale, extra.c1);
                    }

                    // Atmospheric FX layer
                    var fx = extra.fx;
                    if (fx === "snow" || fx === "petals" || fx === "leaves") drawParticles(24, 14, 14, 2.8, extra.c1, extra.c2, 6);
                    else if (fx === "embers" || fx === "spores" || fx === "steam" || fx === "bubbles") drawParticles(20, 3, -18, 2.5, extra.c1, extra.c2, 5);
                    else if (fx === "fireflies" || fx === "dust" || fx === "confetti") drawParticles(22, 5, -4, 2.6, extra.c1, extra.c2, 9);
                    else if (fx === "rain") {
                        ctx.strokeStyle = extra.c1; ctx.lineWidth = 1.2;
                        for (var ri2 = 0; ri2 < 24 * density; ri2++) {
                            var rrx2 = ((ri2 * 29 + t * 25) % (w + 14)) - 7;
                            var rry2 = ((ri2 * 19 + t * 105) % (h + 14)) - 7;
                            ctx.beginPath(); ctx.moveTo(rrx2, rry2); ctx.lineTo(rrx2 - 3, rry2 + 8 * kScale); ctx.stroke();
                        }
                    } else if (fx === "stars") drawStars(24, extra.c1);
                    else if (fx === "warp") {
                        for (var wf2 = 0; wf2 < 32; wf2++) {
                            var wa = wf2 * 0.6;
                            var wd = ((t * 44 + wf2 * 12) % (w * 0.6));
                            px(w * 0.5 + Math.cos(wa) * wd, h * 0.5 + Math.sin(wa) * wd * 0.55, 2.5, 2.5, wf2 % 2 === 0 ? extra.c1 : extra.c2);
                        }
                    } else if (fx === "scanlines" || fx === "lasers") {
                        ctx.fillStyle = "rgba(255,255,255,0.06)";
                        for (var sl = 0; sl < h; sl += 4) ctx.fillRect(0, sl, w, 1);
                    }
                }
            }
        }
    }
}
