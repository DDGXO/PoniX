import QtQuick
import "../services"

Item {
    id: root

    property real mouseXNorm: 0.0
    property bool eyesBlink: false
    property int frameIdx: 0

    width: 36
    height: 24

    Timer {
        interval: 420
        repeat: true
        running: root.visible
        onTriggered: {
            root.frameIdx = (root.frameIdx + 1) % 2;
            spriteCanvas.requestPaint();
        }
    }

    onEyesBlinkChanged: spriteCanvas.requestPaint()
    onMouseXNormChanged: spriteCanvas.requestPaint()

    Canvas {
        id: spriteCanvas
        anchors.centerIn: parent
        width: 30
        height: 22

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.imageSmoothingEnabled = false;

            var s = 2; // 2px per pixel cell -> 15x11 grid = 30x22
            var bobY = root.frameIdx === 1 ? 1 : 0;
            var eyeShift = root.mouseXNorm > 0.3 ? 1 : (root.mouseXNorm < -0.3 ? -1 : 0);

            // Cute 8-bit pixel cat/companion (13x9)
            var sprite = [
                "0010000000100",
                "0111000001110",
                "0111111111110",
                "1111111111111",
                "1110011100111",
                "1111111111111",
                "0111110111110",
                "0011111111100",
                "0010100010100"
            ];

            var bodyCol = PoniConfig.colAccent.toString();
            var eyeCol = "#ffffff";
            var cheekCol = "#f472b6";

            for (var y = 0; y < sprite.length; y++) {
                var row = sprite[y];
                for (var x = 0; x < row.length; x++) {
                    if (row[x] === "1") {
                        ctx.fillStyle = bodyCol;
                        ctx.fillRect((x + 1) * s, (y + bobY) * s, s, s);
                    }
                }
            }

            // Cheeks
            ctx.fillStyle = cheekCol;
            ctx.fillRect(3 * s, (5 + bobY) * s, s, s);
            ctx.fillRect(11 * s, (5 + bobY) * s, s, s);

            // Eyes (track mouseXNorm & blink)
            ctx.fillStyle = eyeCol;
            if (root.eyesBlink) {
                ctx.fillRect((4 + eyeShift) * s, (4 + bobY) * s, 2 * s, 1);
                ctx.fillRect((9 + eyeShift) * s, (4 + bobY) * s, 2 * s, 1);
            } else {
                ctx.fillRect((4 + eyeShift) * s, (4 + bobY) * s, s, s);
                ctx.fillRect((10 + eyeShift) * s, (4 + bobY) * s, s, s);
            }
        }
    }
}
