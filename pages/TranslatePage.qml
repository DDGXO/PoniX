import QtQuick
import Quickshell.Io
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 256

    property string srcLang: "auto"
    property string dstLang: "id"
    property string resultText: ""
    property bool isLoading: false

    function detectSourceLang(txt) {
        if (/[\u3040-\u30ff\u4e00-\u9faf]/.test(txt)) return "ja";
        if (/[\uac00-\ud7af]/.test(txt)) return "ko";
        return "en";
    }

    function runTranslate() {
        var q = srcInput.text.trim();
        if (q.length === 0 || transProc.running) return;
        root.isLoading = true;
        var sl = (root.srcLang === "auto") ? detectSourceLang(q) : root.srcLang;
        if (sl === root.dstLang) sl = (root.dstLang === "id") ? "en" : "id";
        var url = "https://api.mymemory.translated.net/get?q=" + encodeURIComponent(q) + "&langpair=" + encodeURIComponent(sl + "|" + root.dstLang);
        transProc.command = ["curl", "-s", "--max-time", "8", url];
        transProc.running = true;
    }

    Process {
        id: transProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.isLoading = false;
                try {
                    var res = JSON.parse(text.trim());
                    if (res && res.responseData && res.responseData.translatedText) {
                        root.resultText = res.responseData.translatedText;
                    } else {
                        root.resultText = "Translation failed";
                    }
                } catch(e) {
                    root.resultText = "Translation failed";
                }
            }
        }
    }

    Process { id: copyProc }

    Column {
        anchors.fill: parent
        spacing: 10

        // Header + Language Pair Presets
        Item {
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Quick Translator"
                font.family: PoniConfig.fontFamily
                font.pixelSize: 13
                font.weight: Font.Bold
                color: PoniConfig.colText
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                Repeater {
                    model: [
                        { label: "Auto->ID", sl: "auto", tl: "id" },
                        { label: "ID->EN", sl: "id", tl: "en" },
                        { label: "EN->ID", sl: "en", tl: "id" },
                        { label: "JA->ID", sl: "ja", tl: "id" }
                    ]

                    Rectangle {
                        required property var modelData
                        property bool sel: root.srcLang === modelData.sl && root.dstLang === modelData.tl
                        height: 22
                        width: lbl.width + 12
                        radius: PoniConfig.theme === "pixel" ? 2 : 6
                        color: sel ? PoniConfig.colAccent : PoniConfig.colSurface
                        Text {
                            id: lbl
                            anchors.centerIn: parent
                            text: modelData.label
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: parent.sel ? "#ffffff" : PoniConfig.colTextDim
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.srcLang = parent.modelData.sl;
                                root.dstLang = parent.modelData.tl;
                                if (srcInput.text.trim().length > 0) root.runTranslate();
                            }
                        }
                    }
                }
            }
        }

        // Two-column Source & Result
        Row {
            width: parent.width
            height: parent.height - 34
            spacing: 10

            // Source Box
            Rectangle {
                width: (parent.width - 10) / 2
                height: parent.height
                radius: PoniConfig.theme === "pixel" ? 2 : 10
                color: PoniConfig.colCard
                border.color: PoniConfig.colSurface
                border.width: 1

                TextEdit {
                    id: srcInput
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: srcActions.top
                    anchors.margins: 10
                    wrapMode: TextEdit.Wrap
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 12
                    color: PoniConfig.colText
                    clip: true

                    Keys.onReturnPressed: event => {
                        if ((event.modifiers & Qt.ShiftModifier) === 0) {
                            root.runTranslate();
                            event.accepted = true;
                        }
                    }

                    Text {
                        visible: !srcInput.text && !srcInput.activeFocus
                        text: "Type or paste text to translate..."
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 11
                        color: PoniConfig.colTextFaint
                    }
                }

                Row {
                    id: srcActions
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: 8
                    spacing: 6

                    Rectangle {
                        width: 48
                        height: 24
                        radius: PoniConfig.theme === "pixel" ? 2 : 6
                        color: PoniConfig.colSurface
                        Text {
                            anchors.centerIn: parent
                            text: "Paste"
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            color: PoniConfig.colTextDim
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                PoniClipboard.fetchCurrent(function(val) {
                                    if (val && val.length > 0) {
                                        srcInput.text = val;
                                        root.runTranslate();
                                    }
                                });
                            }
                        }
                    }

                    Rectangle {
                        width: 68
                        height: 24
                        radius: PoniConfig.theme === "pixel" ? 2 : 6
                        color: PoniConfig.colAccent
                        Text {
                            anchors.centerIn: parent
                            text: root.isLoading ? "..." : "Translate"
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: "#ffffff"
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.runTranslate()
                        }
                    }
                }
            }

            // Target Box
            Rectangle {
                width: (parent.width - 10) / 2
                height: parent.height
                radius: PoniConfig.theme === "pixel" ? 2 : 10
                color: PoniConfig.colCard
                border.color: PoniConfig.colSurface
                border.width: 1

                TextEdit {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: copyResBtn.top
                    anchors.margins: 10
                    readOnly: true
                    wrapMode: TextEdit.Wrap
                    text: root.resultText
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 12
                    color: PoniConfig.colText
                    clip: true

                    Keys.onReturnPressed: event => {
                        if ((event.modifiers & Qt.ShiftModifier) === 0) {
                            root.runTranslate();
                            event.accepted = true;
                        }
                    }
                }

                Rectangle {
                    id: copyResBtn
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: 8
                    width: 54
                    height: 24
                    radius: PoniConfig.theme === "pixel" ? 2 : 6
                    color: PoniConfig.colSurface
                    Text {
                        anchors.centerIn: parent
                        text: "Copy"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 10
                        color: PoniConfig.colAccent
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.resultText.length > 0) {
                                copyProc.command = ["sh", "-c", "printf '%s' \"$1\" | wl-copy", "_", root.resultText];
                                copyProc.running = true;
                                PoniNotices.post("Translator", "Copied translation");
                            }
                        }
                    }
                }
            }
        }
    }
}
