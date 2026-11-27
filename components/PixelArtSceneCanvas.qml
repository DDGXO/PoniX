import QtQuick
import "../services"

Item {
    id: root

    property bool isExpandedMode: false
    property real t: 0.0
    property int autoIdx: 0

    readonly property var sceneIds: {
        var ids = [];
        for (var i = 0; i < PoniConfig.pixelScenesCatalog.length; i++) {
            var id = PoniConfig.pixelScenesCatalog[i].id;
            if (id !== "auto") ids.push(id);
        }
        return ids;
    }

    readonly property string activeScene: {
        if (PoniConfig.pixelScene && PoniConfig.pixelScene !== "auto") {
            return PoniConfig.pixelScene;
        }
        return sceneIds[root.autoIdx % sceneIds.length];
    }

    Timer {
        interval: 80
        repeat: true
        running: root.visible
        onTriggered: {
            root.t += 0.08;
            pixelCanvas.requestPaint();
        }
    }

    Timer {
        interval: 12000
        repeat: true
        running: root.visible && PoniConfig.pixelScene === "auto"
        onTriggered: root.autoIdx = (root.autoIdx + 1) % root.sceneIds.length
    }

    Canvas {
        id: pixelCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            var W = width;
            var H = height;
            if (W <= 0 || H <= 0) return;

            ctx.clearRect(0, 0, W, H);
            ctx.imageSmoothingEnabled = false;

            // Crisp 2px pixel-art grid for detailed sprites & dithering
            var p = 2;
            var gw = Math.floor(W / p);
            var gh = Math.floor(H / p);
            var t = root.t;
            var s = root.activeScene;

            function plot(gx, gy, pw, ph, col) {
                ctx.fillStyle = col;
                ctx.fillRect(Math.round(gx) * p, Math.round(gy) * p, Math.round(pw) * p, Math.round(ph) * p);
            }

            // Draw detailed pixel-art bitmap from string rows
            function drawBitmap(gx, gy, rows, pal) {
                for (var r = 0; r < rows.length; r++) {
                    var row = rows[r];
                    for (var c = 0; c < row.length; c++) {
                        var ch = row[c];
                        if (ch !== "." && pal[ch]) {
                            plot(gx + c, gy + r, 1, 1, pal[ch]);
                        }
                    }
                }
            }

            // Stepped pixel sky with ordered checkerboard dithering
            function drawDitherSky(bands) {
                var n = bands.length;
                var bandH = Math.max(2, Math.floor(gh / n));
                for (var i = 0; i < n; i++) {
                    var y0 = i * bandH;
                    var h0 = (i === n - 1) ? (gh - y0) : bandH;
                    plot(0, y0, gw, h0, bands[i]);
                    if (i < n - 1 && y0 + h0 - 1 >= 0) {
                        for (var dx = 0; dx < gw; dx += 2) {
                            plot(dx + (i % 2), y0 + h0 - 1, 1, 1, bands[i + 1]);
                        }
                    }
                }
            }

            // Detailed Pixel Sprites (1041uuu / Waneella / Aleha_84 style)
            var spriteUmbrellaPerson = [
                "...UUUUUU...",
                "..UuuuuuuU..",
                ".UuuuuuuuuU.",
                "UUUUUUUUUUUU",
                ".....S......",
                "....HHH.....",
                "...HSSSH....",
                "....CCC.....",
                "...CCcCC.S..",
                "...CCcCC....",
                "...CCcCC....",
                "....P.P.....",
                "....P.P.....",
                "...BB.BB...."
            ];

            var spriteCat = [
                ".O...O....",
                "OO...OO...",
                "OeoOoeO...",
                "OOOOOOO...",
                ".OOOOOO...",
                ".OooooOO..",
                ".OOOOOO.O.",
                "..OO..OO.."
            ];

            var spriteLantern = [
                "..RRR..",
                ".RyyyR.",
                "RyyyyyR",
                "RyyyyyR",
                ".RyyyR.",
                "..RRR.."
            ];

            var spriteTorii = [
                "KKKKKKKKKKKKKK",
                ".KKKKKKKKKKKK.",
                "...KK....KK...",
                ".KKKKKKKKKKKK.",
                "...KK....KK...",
                "...KK....KK...",
                "...KK....KK...",
                "...KK....KK..."
            ];

            var spriteDeskSetup = [
                "..........MMMMMM..",
                "....HH....MccccM..",
                "...HSSH...MccccM..",
                "...CCCC...MMMMMM..",
                "..CCcCC.....MM....",
                "BBBBBBBBBBBBBBBBBB",
                "..BB..........BB..",
                "..BB..........BB.."
            ];

            var spriteVending = [
                ".VVVVVV.",
                "VccccccV",
                "VcwcwcwV",
                "VccccccV",
                "VrrrrrrV",
                "VVVVVVVV",
                "V.dddd.V",
                "VVVVVVVV"
            ];

            var spriteTrain = [
                "TTTTTTTTTTTTTTTTTTTTTTTTTTTT",
                "T.WWW.WWW.WWW.WWW.WWW.WWW..T",
                "T.WWW.WWW.WWW.WWW.WWW.WWW..T",
                "TTTTTTTTTTTTTTTTTTTTTTTTTTTT",
                "SSSSSSSSSSSSSSSSSSSSSSSSSSSS",
                "..OO....OO........OO....OO.."
            ];

            var spriteTree = [
                "....GGGG....",
                "..GGggggGG..",
                ".GggggggggG.",
                "GGggGGGGggGG",
                ".GGGGGGGGGG.",
                ".....BB.....",
                ".....BB.....",
                ".....BB....."
            ];

            // Detailed Scene Library (50 unique aesthetic pixel-art scenes)
            var cfg = {
                "lofi_desk":         { sky: ["#141026", "#1e1638", "#261b47"], mode: "interior", sub: "desk",    wx: "rain",   c1: "#38bdf8", c2: "#f472b6" },
                "train_window":      { sky: ["#7c2d12", "#c2410c", "#fb923c", "#fde047"], mode: "trainwin", sub: "poles", wx: "none", c1: "#166534", c2: "#fde047" },
                "rainy_station":     { sky: ["#070b14", "#0f172a", "#1e293b"], mode: "street",   sub: "station", wx: "rain",   c1: "#38bdf8", c2: "#f43f5e" },
                "convenience_store": { sky: ["#060912", "#0f1629", "#182038"], mode: "street",   sub: "konbini", wx: "rain",   c1: "#fef9c3", c2: "#38bdf8" },
                "rooftop_sunset":    { sky: ["#3b0764", "#831843", "#db2777", "#fb923c"], mode: "rooftop",  sub: "person",  wx: "stars",  c1: "#fde047", c2: "#a78bfa" },
                "windowsill_cat":    { sky: ["#071024", "#0f1e40", "#1a2f5c"], mode: "window",   sub: "cat",     wx: "snow",   c1: "#fb923c", c2: "#fef9c3" },
                "ramen_night":       { sky: ["#0a060e", "#170d1f", "#22122b"], mode: "street",   sub: "ramen",   wx: "steam",  c1: "#ef4444", c2: "#fde047" },
                "sakura_walk":       { sky: ["#1e102e", "#3b174f", "#5e216b"], mode: "river",    sub: "walk",    wx: "petals", c1: "#f9a8d4", c2: "#fbcfe8" },
                "neon_puddle":       { sky: ["#070312", "#14072b", "#220b45"], mode: "street",   sub: "neon",    wx: "rain",   c1: "#ff71ce", c2: "#01cdfe" },
                "tatami_tea":        { sky: ["#140f0b", "#211912", "#2e2218"], mode: "interior", sub: "tea",     wx: "steam",  c1: "#86efac", c2: "#fde68a" },
                "balcony_night":     { sky: ["#050917", "#0c1633", "#16244f"], mode: "rooftop",  sub: "person",  wx: "stars",  c1: "#fef9c3", c2: "#38bdf8" },
                "laundromat":        { sky: ["#0b1221", "#142038", "#1e2e4d"], mode: "interior", sub: "wash",    wx: "none",   c1: "#38bdf8", c2: "#f472b6" },
                "bus_shelter":       { sky: ["#060a14", "#0f172a", "#17223b"], mode: "street",   sub: "bus",     wx: "rain",   c1: "#fde047", c2: "#93c5fd" },
                "bookstore":         { sky: ["#17100b", "#261910", "#362316"], mode: "street",   sub: "books",   wx: "leaves", c1: "#fde68a", c2: "#f97316" },
                "pier_lantern":      { sky: ["#050918", "#0c1836", "#132952"], mode: "river",    sub: "pier",    wx: "stars",  c1: "#fde047", c2: "#38bdf8" },
                "beach_dusk":        { sky: ["#3b0764", "#be185d", "#f472b6", "#fed7aa"], mode: "river",    sub: "walk",    wx: "stars",  c1: "#fde68a", c2: "#ffffff" },
                "stargaze_hill":     { sky: ["#030512", "#080e2b", "#111b47"], mode: "hill",     sub: "couple",  wx: "stars",  c1: "#fef08a", c2: "#7dd3fc" },
                "fireplace_cat":     { sky: ["#140905", "#241008", "#33170b"], mode: "interior", sub: "hearth",  wx: "embers", c1: "#f97316", c2: "#facc15" },
                "cyclist_dusk":      { sky: ["#451a03", "#9a3412", "#ea580c", "#fdba74"], mode: "river",    sub: "bike",    wx: "dust",   c1: "#fde047", c2: "#38bdf8" },
                "shrine_steps":      { sky: ["#06140d", "#0e291b", "#163d28"], mode: "hill",     sub: "torii",   wx: "fireflies",c1: "#be123c", c2: "#fde047" },
                "snow_window":       { sky: ["#0a1426", "#142642", "#1e3a5f"], mode: "window",   sub: "snow",    wx: "snow",   c1: "#ffffff", c2: "#bae6fd" },
                "cafe_corner":       { sky: ["#1a110b", "#2b1c12", "#3b2718"], mode: "street",   sub: "konbini", wx: "rain",   c1: "#fde68a", c2: "#fb923c" },
                "bridge_sunset":     { sky: ["#311042", "#9d174d", "#f97316", "#fde047"], mode: "bridge",   sub: "person",  wx: "dust",   c1: "#fde047", c2: "#ffffff" },
                "greenhouse_nook":   { sky: ["#0b2114", "#143822", "#1e5232"], mode: "interior", sub: "plants",  wx: "dust",   c1: "#4ade80", c2: "#fde68a" },
                "subway_platform":   { sky: ["#0d1117", "#161b22", "#21262d"], mode: "street",   sub: "train",   wx: "none",   c1: "#38bdf8", c2: "#facc15" },
                "vinyl_room":        { sky: ["#17101c", "#26192e", "#362340"], mode: "interior", sub: "desk",    wx: "dust",   c1: "#f59e0b", c2: "#e879f9" },
                "attic_rain":        { sky: ["#0b101b", "#141d30", "#1d2942"], mode: "window",   sub: "rain",    wx: "rain",   c1: "#93c5fd", c2: "#38bdf8" },
                "river_boat":        { sky: ["#091326", "#142647", "#1e3a66"], mode: "river",    sub: "pier",    wx: "fireflies",c1: "#fde047", c2: "#86efac" },
                "mountain_tram":     { sky: ["#1e3a8a", "#3b82f6", "#93c5fd"], mode: "bridge",   sub: "train",   wx: "snow",   c1: "#ef4444", c2: "#ffffff" },
                "lantern_alley":     { sky: ["#140812", "#260f21", "#38152e"], mode: "street",   sub: "ramen",   wx: "embers", c1: "#fb923c", c2: "#ef4444" },
                "tokyo_crossing":    { sky: ["#080716", "#121030", "#1c184a"], mode: "street",   sub: "neon",    wx: "rain",   c1: "#f472b6", c2: "#22d3ee" },
                "cherry_river":      { sky: ["#2e1036", "#5c1d69", "#862994"], mode: "river",    sub: "torii",   wx: "petals", c1: "#f9a8d4", c2: "#fbcfe8" },
                "winter_street":     { sky: ["#0d1524", "#18263d", "#243757"], mode: "street",   sub: "station", wx: "snow",   c1: "#ffffff", c2: "#fde68a" },
                "autumn_park":       { sky: ["#451a03", "#7c2d12", "#c2410c"], mode: "hill",     sub: "walk",    wx: "leaves", c1: "#f97316", c2: "#eab308" },
                "harbor_fog":        { sky: ["#0e1a24", "#1c3142", "#2b4961"], mode: "river",    sub: "pier",    wx: "steam",  c1: "#fde047", c2: "#cbd5e1" },
                "moon_temple":       { sky: ["#06091a", "#0f1638", "#1a2559"], mode: "hill",     sub: "torii",   wx: "stars",  c1: "#be123c", c2: "#fef9c3" },
                "night_bakery":      { sky: ["#1c1209", "#2e1d0f", "#402814"], mode: "street",   sub: "konbini", wx: "steam",  c1: "#fed7aa", c2: "#fde047" },
                "art_studio":        { sky: ["#181424", "#261f38", "#342b4d"], mode: "interior", sub: "plants",  wx: "dust",   c1: "#f472b6", c2: "#fde047" },
                "flower_shop":       { sky: ["#121f16", "#1c3323", "#264730"], mode: "street",   sub: "books",   wx: "petals", c1: "#f472b6", c2: "#4ade80" },
                "lighthouse_cliff":  { sky: ["#071124", "#0f2347", "#18376b"], mode: "hill",     sub: "pier",    wx: "rain",   c1: "#fde047", c2: "#bae6fd" },
                "bamboo_path":       { sky: ["#061a10", "#0d331f", "#144d2e"], mode: "hill",     sub: "walk",    wx: "fireflies",c1: "#86efac", c2: "#fde047" },
                "starry_camp":       { sky: ["#030510", "#080f29", "#0f1c45"], mode: "hill",     sub: "hearth",  wx: "stars",  c1: "#f97316", c2: "#fef08a" },
                "sunset_train":      { sky: ["#4c1d95", "#be185d", "#f97316", "#fde047"], mode: "bridge",   sub: "train",   wx: "dust",   c1: "#e2e8f0", c2: "#fde047" },
                "pastel_rooftop":    { sky: ["#6d28d9", "#ec4899", "#f9a8d4", "#fef08a"], mode: "rooftop",  sub: "cat",     wx: "petals", c1: "#ffffff", c2: "#fde68a" },
                "midnight_diner":    { sky: ["#0a0812", "#171226", "#241c3b"], mode: "street",   sub: "ramen",   wx: "rain",   c1: "#fde047", c2: "#fb7185" },
                "rainy_arcade":      { sky: ["#090514", "#160c2e", "#221245"], mode: "street",   sub: "neon",    wx: "rain",   c1: "#22d3ee", c2: "#f472b6" },
                "kiosk_night":       { sky: ["#080d1a", "#111b33", "#1a284a"], mode: "street",   sub: "station", wx: "fireflies",c1: "#4ade80", c2: "#fde047" },
                "canal_dusk":        { sky: ["#1e1b4b", "#4338ca", "#f472b6"], mode: "river",    sub: "bridge",  wx: "petals", c1: "#fde68a", c2: "#f9a8d4" },
                "pagoda_mist":       { sky: ["#0d1520", "#1b2a3d", "#2c4159"], mode: "hill",     sub: "torii",   wx: "steam",  c1: "#ef4444", c2: "#cbd5e1" },
                "dawn_meadow":       { sky: ["#1e3a8a", "#60a5fa", "#fbcfe8", "#fef08a"], mode: "hill",     sub: "bike",    wx: "petals", c1: "#fef08a", c2: "#f9a8d4" }
            }[s] || { sky: ["#141026", "#1e1638", "#261b47"], mode: "rooftop", sub: "person", wx: "stars", c1: "#fde047", c2: "#f472b6" };

            // 1. Dithered pixel sky
            drawDitherSky(cfg.sky);

            // 2. Background environment
            var groundY = Math.floor(gh * 0.76);
            if (cfg.mode === "street") {
                // Distant buildings
                for (var b = 0; b < gw; b += 14) {
                    var bh = Math.min(Math.floor(gh * 0.6), 10 + ((b * 13) % 18));
                    plot(b, groundY - bh, 12, bh, "rgba(10, 12, 24, 0.75)");
                    if (((b * 7) % 3) === 0) plot(b + 3, groundY - bh + 3, 2, 2, cfg.c1);
                }
                plot(0, groundY, gw, gh - groundY, "#111827");
                plot(0, groundY, gw, 1, "#334155");
            } else if (cfg.mode === "rooftop") {
                for (var b2 = 0; b2 < gw; b2 += 12) {
                    var bh2 = Math.min(Math.floor(gh * 0.45), 6 + ((b2 * 17) % 16));
                    plot(b2, groundY - bh2, 10, bh2, "rgba(15, 10, 30, 0.7)");
                    plot(b2 + 2, groundY - bh2 + 2, 1, 1, cfg.c1);
                }
                plot(0, groundY, gw, gh - groundY, "#0f0b1a");
                plot(0, groundY, gw, 1, "#475569");
            } else if (cfg.mode === "river") {
                plot(0, groundY - 4, gw, 4, "rgba(15, 23, 42, 0.65)");
                plot(0, groundY, gw, gh - groundY, "#0c2440");
                for (var rw = 0; rw < gw; rw += 9) {
                    if ((rw + Math.floor(t * 4)) % 3 === 0) plot(rw, groundY + 2 + (rw % 3), 4, 1, "rgba(255,255,255,0.28)");
                }
            } else if (cfg.mode === "hill") {
                for (var hx = 0; hx < gw; hx++) {
                    var hy = groundY - Math.floor(Math.sin(hx * 0.06) * 4 + 3);
                    plot(hx, hy, 1, gh - hy, "#0f1f1a");
                }
            } else if (cfg.mode === "bridge") {
                plot(0, groundY, gw, 2, "#0f172a");
                for (var br = 4; br < gw; br += 8) plot(br, groundY - 5, 1, 5, "#1e293b");
                plot(0, groundY - 5, gw, 1, "#1e293b");
            } else if (cfg.mode === "trainwin") {
                plot(0, Math.floor(gh * 0.64), gw, gh, "#14532d");
                for (var pl = 0; pl < 4; pl++) {
                    var pxP = ((gw - Math.floor(t * 28) + pl * Math.floor(gw * 0.3)) % gw + gw) % gw;
                    plot(pxP, Math.floor(gh * 0.16), 1, Math.floor(gh * 0.5), "#1e1b4b");
                    plot(pxP - 2, Math.floor(gh * 0.2), 5, 1, "#1e1b4b");
                }
                plot(0, 0, gw, 3, "#1f1624"); plot(0, gh - 3, gw, 3, "#1f1624");
                plot(Math.floor(gw * 0.5), 0, 2, gh, "#1f1624");
            } else if (cfg.mode === "interior" || cfg.mode === "window") {
                plot(0, groundY, gw, gh - groundY, "#291a12");
                if (cfg.mode === "window") {
                    plot(0, 0, 3, gh, "#2e1f18"); plot(gw - 3, 0, 3, gh, "#2e1f18");
                    plot(Math.floor(gw * 0.5), 0, 2, gh, "#2e1f18");
                    plot(0, Math.floor(gh * 0.45), gw, 2, "#2e1f18");
                }
            }

            // 3. Detailed Pixel-Art Focal Subject
            var cx = Math.floor(gw * 0.5);
            if (cfg.sub === "desk") {
                drawBitmap(cx - 9, groundY - 8, spriteDeskSetup, { "H": "#1e1b4b", "S": "#fde68a", "C": "#f472b6", "c": "#38bdf8", "M": "#334155", "B": "#78350f" });
            } else if (cfg.sub === "station") {
                drawBitmap(Math.floor(gw * 0.2), groundY - 8, spriteVending, { "V": "#e2e8f0", "c": "#38bdf8", "w": "#ffffff", "r": "#ef4444", "d": "#334155" });
                drawBitmap(Math.floor(gw * 0.56), groundY - 14, spriteUmbrellaPerson, { "U": cfg.c2, "u": cfg.c1, "S": "#fde68a", "H": "#0f172a", "C": "#94a3b8", "c": "#64748b", "P": "#1e293b", "B": "#0f172a" });
            } else if (cfg.sub === "konbini" || cfg.sub === "books") {
                var kx = Math.floor(gw * 0.25);
                plot(kx, groundY - 14, 28, 14, "#1e293b");
                plot(kx + 2, groundY - 10, 24, 9, cfg.c1);
                for (var aw = 0; aw < 28; aw += 4) plot(kx + aw, groundY - 15, 2, 2, (aw % 8 === 0) ? cfg.c2 : "#ffffff");
                drawBitmap(kx - 14, groundY - 14, spriteUmbrellaPerson, { "U": cfg.c2, "u": cfg.c1, "S": "#fde68a", "H": "#0f172a", "C": "#64748b", "c": "#475569", "P": "#1e293b", "B": "#0f172a" });
            } else if (cfg.sub === "ramen") {
                var rx = Math.floor(gw * 0.34);
                plot(rx, groundY - 12, 22, 2, "#b91c1c");
                plot(rx + 2, groundY - 10, 1, 10, "#78350f");
                plot(rx + 19, groundY - 10, 1, 10, "#78350f");
                plot(rx + 4, groundY - 5, 14, 5, "#451a03");
                drawBitmap(rx - 7, groundY - 11, spriteLantern, { "R": "#b91c1c", "y": "#fde047" });
                drawBitmap(rx + 23, groundY - 11, spriteLantern, { "R": "#b91c1c", "y": "#fde047" });
            } else if (cfg.sub === "torii") {
                drawBitmap(cx - 7, groundY - 8, spriteTorii, { "K": "#be123c" });
                drawBitmap(cx - 16, groundY - 6, spriteLantern, { "R": "#64748b", "y": "#fde047" });
            } else if (cfg.sub === "cat") {
                drawBitmap(Math.floor(gw * 0.36), groundY - 8, spriteCat, { "O": cfg.c1, "o": "#fed7aa", "e": "#0f172a" });
            } else if (cfg.sub === "train") {
                var tx = ((Math.floor(t * 24)) % (gw + 34)) - 30;
                drawBitmap(tx, groundY - 6, spriteTrain, { "T": cfg.c1, "W": "#fef9c3", "S": "#334155", "O": "#0f172a" });
            } else if (cfg.sub === "walk" || cfg.sub === "person") {
                var pxW = (cfg.sub === "walk") ? (Math.floor(gw * 0.2 + ((t * 5) % Math.floor(gw * 0.6)))) : Math.floor(gw * 0.42);
                drawBitmap(pxW, groundY - 14, spriteUmbrellaPerson, { "U": cfg.c1, "u": cfg.c2, "S": "#fde68a", "H": "#0f172a", "C": "#e2e8f0", "c": "#94a3b8", "P": "#1e293b", "B": "#0f172a" });
            } else if (cfg.sub === "neon") {
                plot(Math.floor(gw * 0.16), Math.floor(gh * 0.18), 10, 6, cfg.c1);
                plot(Math.floor(gw * 0.68), Math.floor(gh * 0.22), 12, 5, cfg.c2);
                drawBitmap(cx - 6, groundY - 14, spriteUmbrellaPerson, { "U": "#1e293b", "u": cfg.c2, "S": "#fde68a", "H": "#0f172a", "C": "#334155", "c": "#1e293b", "P": "#0f172a", "B": "#0f172a" });
            } else if (cfg.sub === "hearth") {
                plot(cx - 8, groundY - 12, 16, 12, "#44403c");
                plot(cx - 5, groundY - 8, 10, 8, "#09090b");
                plot(cx - 3, groundY - 5 - (Math.floor(t * 5) % 2), 6, 5, "#f97316");
                plot(cx - 2, groundY - 3, 4, 3, "#fde047");
                drawBitmap(cx - 18, groundY - 8, spriteCat, { "O": "#e2e8f0", "o": "#cbd5e1", "e": "#0f172a" });
            } else if (cfg.sub === "pier") {
                plot(0, groundY - 1, Math.floor(gw * 0.48), 2, "#78350f");
                drawBitmap(Math.floor(gw * 0.4), groundY - 7, spriteLantern, { "R": "#92400e", "y": "#fde047" });
            } else if (cfg.sub === "bike") {
                var bx = (Math.floor(t * 14) % (gw + 16)) - 8;
                plot(bx, groundY - 3, 3, 3, "#e2e8f0");
                plot(bx + 7, groundY - 3, 3, 3, "#e2e8f0");
                plot(bx + 2, groundY - 5, 6, 2, cfg.c2);
            } else {
                drawBitmap(Math.floor(gw * 0.2), groundY - 8, spriteTree, { "G": "#15803d", "g": "#4ade80", "B": "#78350f" });
                drawBitmap(Math.floor(gw * 0.7), groundY - 8, spriteTree, { "G": "#15803d", "g": "#4ade80", "B": "#78350f" });
            }

            // 4. Atmospheric Pixel FX
            if (cfg.wx === "rain") {
                var rCnt = root.isExpandedMode ? 36 : 12;
                for (var ri = 0; ri < rCnt; ri++) {
                    plot((ri * 17 + Math.floor(t * 8)) % gw, (ri * 11 + Math.floor(t * 28)) % gh, 1, 2, cfg.c1);
                }
            } else if (cfg.wx === "snow" || cfg.wx === "petals" || cfg.wx === "leaves") {
                var sCnt = root.isExpandedMode ? 32 : 12;
                for (var si = 0; si < sCnt; si++) {
                    plot(((si * 19 + Math.floor(Math.sin(t + si) * 2 + t * 2)) % gw + gw) % gw, (si * 13 + Math.floor(t * 8)) % gh, 1, 1, (si % 2 === 0) ? cfg.c1 : cfg.c2);
                }
            } else if (cfg.wx === "stars") {
                var stCnt = root.isExpandedMode ? 28 : 10;
                for (var sti = 0; sti < stCnt; sti++) {
                    if (Math.sin(t * 3 + sti * 1.9) > -0.2) {
                        plot((sti * 23 + 3) % gw, (sti * 11 + 2) % Math.max(4, Math.floor(gh * 0.6)), 1, 1, cfg.c1);
                    }
                }
            } else if (cfg.wx === "fireflies" || cfg.wx === "embers" || cfg.wx === "steam" || cfg.wx === "dust") {
                var cnt = root.isExpandedMode ? 18 : 7;
                for (var fi = 0; fi < cnt; fi++) {
                    var fx = ((fi * 23 + Math.floor(Math.sin(t * 2 + fi) * 4)) % gw + gw) % gw;
                    var fy = ((fi * 17 - Math.floor(t * (cfg.wx === "steam" || cfg.wx === "embers" ? 8 : 2))) % gh + gh) % gh;
                    plot(fx, fy, 1, 1, (fi % 2 === 0) ? cfg.c1 : cfg.c2);
                }
            }
        }
    }
}
