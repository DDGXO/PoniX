import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property string name: "music"
    property color color: "#ffffff"
    property real size: 16

    width: size
    height: size

    Shape {
        id: shape
        anchors.fill: parent
        anchors.centerIn: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            id: sp
            strokeColor: root.color
            fillColor: "transparent"
            strokeWidth: 2.0
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            scale: Qt.size(root.width / 24.0, root.height / 24.0)

            PathSvg {
                path: {
                    var n = root.name.toLowerCase();
                    switch (n) {
                        case "play":
                            sp.fillColor = root.color;
                            return "M8 5.6v12.8a1.1 1.1 0 0 0 1.7.93l10-6.4a1.1 1.1 0 0 0 0-1.86l-10-6.4A1.1 1.1 0 0 0 8 5.6z";
                        case "pause":
                            sp.fillColor = root.color;
                            return "M7.2 5h1.6a1.2 1.2 0 0 1 1.2 1.2v11.6a1.2 1.2 0 0 1-1.2 1.2H7.2A1.2 1.2 0 0 1 6 17.8V6.2A1.2 1.2 0 0 1 7.2 5z M15.2 5h1.6a1.2 1.2 0 0 1 1.2 1.2v11.6a1.2 1.2 0 0 1-1.2 1.2h-1.6a1.2 1.2 0 0 1-1.2-1.2V6.2A1.2 1.2 0 0 1 15.2 5z";
                        case "next":
                            sp.fillColor = root.color;
                            return "M4.5 6.3v11.4a.9.9 0 0 0 1.4.74l8.3-5.7a.9.9 0 0 0 0-1.48L5.9 5.56a.9.9 0 0 0-1.4.74z M17 5.5h1.6a.9.9 0 0 1 .9.9v11.2a.9.9 0 0 1-.9.9H17a.9.9 0 0 1-.9-.9V6.4a.9.9 0 0 1 .9-.9z";
                        case "prev":
                            sp.fillColor = root.color;
                            return "M19.5 6.3v11.4a.9.9 0 0 1-1.4.74l-8.3-5.7a.9.9 0 0 1 0-1.48l8.3-5.7a.9.9 0 0 1 1.4.74z M5.4 5.5H7a.9.9 0 0 1 .9.9v11.2a.9.9 0 0 1-.9.9H5.4a.9.9 0 0 1-.9-.9V6.4a.9.9 0 0 1 .9-.9z";
                        case "music":
                        case "media":
                            sp.fillColor = "transparent";
                            return "M9 18V5.5l11-2V16 M3 18a3 3 0 1 0 6 0a3 3 0 1 0-6 0 M14 16a3 3 0 1 0 6 0a3 3 0 1 0-6 0";
                        case "timer":
                        case "focus":
                        case "clock":
                            sp.fillColor = "transparent";
                            return "M4 13a8 8 0 1 0 16 0a8 8 0 1 0-16 0 M12 9v4l2.5 2.5 M10 2.5h4 M19 5.5l1.5 1.5";
                        case "calendar":
                        case "today":
                            sp.fillColor = "transparent";
                            return "M5.5 5h13A1.5 1.5 0 0 1 20 6.5v12a1.5 1.5 0 0 1-1.5 1.5h-13A1.5 1.5 0 0 1 4 18.5v-12A1.5 1.5 0 0 1 5.5 5z M4 10h16 M8.5 3v4 M15.5 3v4";
                        case "tray":
                        case "shelf":
                        case "paperclip":
                            sp.fillColor = "transparent";
                            return "M4 13l2.4-7.2a1.6 1.6 0 0 1 1.5-1.1h8.2a1.6 1.6 0 0 1 1.5 1.1L20 13 M4 13v5a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-5 M4 13h4.5l1.5 2.5h4l1.5-2.5H20";
                        case "listchecks":
                        case "tasks":
                        case "check-square":
                            sp.fillColor = "transparent";
                            return "M11 6h9 M11 12h9 M11 18h9 M3.5 6l1.6 1.6L8 4.7 M3.5 12l1.6 1.6L8 10.7 M4 18h3";
                        case "check":
                            sp.fillColor = "transparent";
                            return "M5 12.5l4.5 4.5L19 7.5";
                        case "ai":
                        case "sparkles":
                        case "cpu":
                            sp.fillColor = "transparent";
                            return "M10.5 5Q12.7 11.3 19 13.5Q12.7 15.7 10.5 22Q8.3 15.7 2 13.5Q8.3 11.3 10.5 5Z M19.25 1.25Q19.85 4.15 22.75 4.75Q19.85 5.35 19.25 8.25Q18.65 5.35 15.75 4.75Q18.65 4.15 19.25 1.25Z";
                        case "wallet":
                        case "ponix":
                        case "zap":
                            sp.fillColor = "transparent";
                            return "M4 7.5h14.5A1.5 1.5 0 0 1 20 9v9a1.5 1.5 0 0 1-1.5 1.5h-13A1.5 1.5 0 0 1 4 18z M4 7.5l10.5-3v3 M15.5 13.5h2";
                        case "steps":
                        case "health":
                        case "heart":
                            sp.fillColor = "transparent";
                            return "M5.2 12.5C4.8 11.1 4 9.7 4 7.6C4 4.8 5.5 2.5 7.5 2.5C9.5 2.5 11 4.8 11 7.6C11 9.7 10.2 11.1 9.8 12.5Z M5.5 15H9.5V15.6A2 2 0 0 1 5.5 15.6Z M14.2 17C13.8 15.6 13 14.2 13 12.1C13 9.3 14.5 7 16.5 7C18.5 7 20 9.3 20 12.1C20 14.2 19.2 15.6 18.8 17Z M14.5 19.5H18.5V20.1A2 2 0 0 1 14.5 20.1Z";
                        case "mic":
                        case "ielts":
                            sp.fillColor = "transparent";
                            return "M9 6a3 3 0 0 1 6 0v5a3 3 0 0 1-6 0z M5.5 11a6.5 6.5 0 0 0 13 0 M12 17.5V21";
                        case "notes":
                        case "file-text":
                            sp.fillColor = "transparent";
                            return "M6.5 3h11A1.5 1.5 0 0 1 19 4.5v15a1.5 1.5 0 0 1-1.5 1.5h-11A1.5 1.5 0 0 1 5 19.5v-15A1.5 1.5 0 0 1 6.5 3z M8.5 8v1.5 M10.75 6.5v4.5 M13 7.25v3 M15.25 8v1.5 M8.5 14.5h7 M8.5 17.5h4.5";
                        case "gauge":
                        case "system":
                        case "activity":
                            sp.fillColor = "transparent";
                            return "M4.6 18.5A8.5 8.5 0 1 1 19.4 18.5 M12 14.5l3.8-4.3";
                        case "script":
                        case "edit":
                            sp.fillColor = "transparent";
                            return "M10 6.5h10 M10 12h10 M10 17.5h6.5 M3.6 9.3v5.4a.8.8 0 0 0 1.2.7l4.3-2.7a.8.8 0 0 0 0-1.4L4.8 8.6a.8.8 0 0 0-1.2.7z";
                        case "recorder":
                        case "record":
                        case "video":
                            sp.fillColor = "transparent";
                            return "M3 12a9 9 0 1 0 18 0a9 9 0 1 0-18 0 M8.5 12a3.5 3.5 0 1 0 7 0a3.5 3.5 0 1 0-7 0z";
                        case "moon":
                        case "prayer":
                        case "compass":
                            sp.fillColor = "transparent";
                            return "M19.77 13.9A8 8 0 1 1 10.1 4.23A7 7 0 0 0 19.77 13.9Z";
                        case "stocks":
                        case "trending-up":
                            sp.fillColor = "transparent";
                            return "M3.5 17.5l5.5-5.5 4 4 7.5-7.5 M15 8.5h5.5V14";
                        case "coffee":
                        case "caffeine":
                            sp.fillColor = "transparent";
                            return "M5 9h11v5a5 5 0 0 1-5 5h-1a5 5 0 0 1-5-5z M16 10.5h1.5a2.5 2.5 0 0 1 0 5H16 M8.5 3.5V6 M12 3.5V6";
                        case "download":
                        case "downloads":
                            sp.fillColor = "transparent";
                            return "M12 4v10.5 M7.5 10L12 14.5 16.5 10 M4.5 16v2.5A1.5 1.5 0 0 0 6 20h12a1.5 1.5 0 0 0 1.5-1.5V16";
                        case "addons":
                        case "grid":
                            sp.fillColor = "transparent";
                            return "M5.5 4h3A1.5 1.5 0 0 1 10 5.5v3A1.5 1.5 0 0 1 8.5 10h-3A1.5 1.5 0 0 1 4 8.5v-3A1.5 1.5 0 0 1 5.5 4z M15.5 4h3A1.5 1.5 0 0 1 20 5.5v3a1.5 1.5 0 0 1-1.5 1.5h-3A1.5 1.5 0 0 1 14 8.5v-3A1.5 1.5 0 0 1 15.5 4z M5.5 14h3a1.5 1.5 0 0 1 1.5 1.5v3A1.5 1.5 0 0 1 8.5 20h-3A1.5 1.5 0 0 1 4 18.5v-3A1.5 1.5 0 0 1 5.5 14z M17 13.5v7 M13.5 17h7";
                        case "server":
                        case "servers":
                            sp.fillColor = "transparent";
                            return "M4 4.5h16a1 1 0 0 1 1 1v4a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1v-4a1 1 0 0 1 1-1z M4 13.5h16a1 1 0 0 1 1 1v4a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1v-4a1 1 0 0 1 1-1z M7 7.5h.01 M7 16.5h.01";
                        case "audio":
                        case "volume":
                            sp.fillColor = "transparent";
                            return "M4.5 9.5h3.5l5-4v13l-5-4H4.5z M16.5 8.5a5 5 0 0 1 0 7 M19 6a8.5 8.5 0 0 1 0 12";
                        case "clipboard":
                            sp.fillColor = "transparent";
                            return "M9 4h6a1 1 0 0 1 1 1v1H8V5a1 1 0 0 1 1-1z M6 6h12a1.5 1.5 0 0 1 1.5 1.5v12A1.5 1.5 0 0 1 18 21H6a1.5 1.5 0 0 1-1.5-1.5v-12A1.5 1.5 0 0 1 6 6z";
                        case "capture":
                        case "camera":
                            sp.fillColor = "transparent";
                            return "M4 8.5A1.5 1.5 0 0 1 5.5 7h2.2l1.5-2h5.6l1.5 2h2.2A1.5 1.5 0 0 1 20 8.5v9A1.5 1.5 0 0 1 18.5 19h-13A1.5 1.5 0 0 1 4 17.5z M9 13a3 3 0 1 0 6 0a3 3 0 1 0-6 0";
                        case "weather":
                        case "cloud":
                            sp.fillColor = "transparent";
                            return "M6.5 18.5h11a4 4 0 0 0 .8-7.9A5.5 5.5 0 0 0 7.7 9.3a4.5 4.5 0 0 0-1.2 9.2z";
                        case "share":
                        case "qr":
                            sp.fillColor = "transparent";
                            return "M4 4h6v6H4z M14 4h6v6h-6z M4 14h6v6H4z M14 14h2v2h-2z M18 14h2v2h-2z M14 18h2v2h-2z M18 18h2v2h-2z";
                        case "translate":
                        case "globe":
                            sp.fillColor = "transparent";
                            return "M3.5 12a8.5 8.5 0 1 0 17 0a8.5 8.5 0 1 0-17 0 M3.5 12h17 M12 3.5a13 13 0 0 1 0 17 M12 3.5a13 13 0 0 0 0 17";
                        case "gear":
                        case "settings":
                            sp.fillColor = "transparent";
                            return "M10.25 5.22L10.43 2.63A9.5 9.5 0 0 1 13.57 2.63L13.75 5.22A7 7 0 0 1 15.55 5.97L17.52 4.27A9.5 9.5 0 0 1 19.73 6.48L18.03 8.45A7 7 0 0 1 18.78 10.25L21.37 10.43A9.5 9.5 0 0 1 21.37 13.57L18.78 13.75A7 7 0 0 1 18.03 15.55L19.73 17.52A9.5 9.5 0 0 1 17.52 19.73L15.55 18.03A7 7 0 0 1 13.75 18.78L13.57 21.37A9.5 9.5 0 0 1 10.43 21.37L10.25 18.78A7 7 0 0 1 8.45 18.03L6.48 19.73A9.5 9.5 0 0 1 4.27 17.52L5.97 15.55A7 7 0 0 1 5.22 13.75L2.63 13.57A9.5 9.5 0 0 1 2.63 10.43L5.22 10.25A7 7 0 0 1 5.97 8.45L4.27 6.48A9.5 9.5 0 0 1 6.48 4.27L8.45 5.97A7 7 0 0 1 10.25 5.22Z M9 12a3 3 0 1 0 6 0a3 3 0 1 0-6 0";
                        case "pin":
                            sp.fillColor = "transparent";
                            return "M9 4h6l-1 5.5 3 3V14H7v-1.5l3-3z M12 14v6";
                        case "pinfill":
                            sp.fillColor = root.color;
                            return "M9 4h6l-1 5.5 3 3V14H7v-1.5l3-3z M12 14v6";
                        case "eye":
                            sp.fillColor = "transparent";
                            return "M2.5 12s3.5-6.5 9.5-6.5 9.5 6.5 9.5 6.5-3.5 6.5-9.5 6.5S2.5 12 2.5 12z M9.2 12a2.8 2.8 0 1 0 5.6 0a2.8 2.8 0 1 0-5.6 0";
                        case "moneyin":
                            sp.fillColor = "transparent";
                            return "M12 4v10.5 M7.5 10.5L12 15l4.5-4.5 M5 19.5h14";
                        case "moneyout":
                            sp.fillColor = "transparent";
                            return "M12 20V9.5 M7.5 13.5L12 9l4.5 4.5 M5 4.5h14";
                        case "transfer":
                            sp.fillColor = "transparent";
                            return "M5 9h12.5 M14.5 6l3 3-3 3 M19 15H6.5 M9.5 12l-3 3 3 3";
                        case "card":
                            sp.fillColor = "transparent";
                            return "M4.5 6.5h15A1.5 1.5 0 0 1 21 8v8a1.5 1.5 0 0 1-1.5 1.5h-15A1.5 1.5 0 0 1 3 16V8a1.5 1.5 0 0 1 1.5-1.5z M3 10h18 M6.5 14h4";
                        case "undo":
                            sp.fillColor = "transparent";
                            return "M9 14L4.5 9.5 9 5 M4.5 9.5H14a5.5 5.5 0 0 1 0 11h-3";
                        case "open":
                            sp.fillColor = "transparent";
                            return "M14 4h6v6 M20 4l-9 9 M18 14v4.5a1.5 1.5 0 0 1-1.5 1.5h-11A1.5 1.5 0 0 1 4 18.5v-11A1.5 1.5 0 0 1 5.5 6H10";
                        case "bolt":
                            sp.fillColor = root.color;
                            return "M13.4 2.5L5 13.6h6.2l-1.3 7.9L19 10.4h-6.3z";
                        case "battery":
                            sp.fillColor = "transparent";
                            return "M4.5 7h12A1.5 1.5 0 0 1 18 8.5v7a1.5 1.5 0 0 1-1.5 1.5h-12A1.5 1.5 0 0 1 3 15.5v-7A1.5 1.5 0 0 1 4.5 7z M21 10.5v3";
                        case "plus":
                            sp.fillColor = "transparent";
                            return "M12 5v14 M5 12h14";
                        case "minus":
                            sp.fillColor = "transparent";
                            return "M5 12h14";
                        case "close":
                            sp.fillColor = "transparent";
                            return "M6.5 6.5l11 11 M17.5 6.5l-11 11";
                        case "search":
                            sp.fillColor = "transparent";
                            return "M4.5 10.5a6 6 0 1 0 12 0a6 6 0 1 0-12 0 M15 15l4.5 4.5";
                        case "volume":
                            sp.fillColor = "transparent";
                            return "M4 9.5h3l4.5-4v13L7 14.5H4z M15 9a4 4 0 0 1 0 6 M17.8 6.5a7.5 7.5 0 0 1 0 11";
                        case "volumelow":
                            sp.fillColor = "transparent";
                            return "M4 9.5h3l4.5-4v13L7 14.5H4z M15 9a4 4 0 0 1 0 6";
                        case "volumemute":
                            sp.fillColor = "transparent";
                            return "M4 9.5h3l4.5-4v13L7 14.5H4z M16 9.5l5 5 M21 9.5l-5 5";
                        case "trash":
                            sp.fillColor = "transparent";
                            return "M4 7h16 M9.5 7V5a1 1 0 0 1 1-1h3a1 1 0 0 1 1 1v2 M6.5 7l.9 12a1.5 1.5 0 0 0 1.5 1.4h6.2a1.5 1.5 0 0 0 1.5-1.4L17.5 7";
                        case "bell":
                        case "notifications":
                            sp.fillColor = "transparent";
                            return "M6 11a6 6 0 0 1 12 0v4.2l1.6 2.3H4.4L6 15.2z M10 20.3a2.2 2.2 0 0 0 4 0";
                        default:
                            sp.fillColor = "transparent";
                            return "M12 5v14 M5 12h14";
                    }
                }
            }
        }
    }
}
