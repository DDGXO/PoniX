import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../components"
import "../services"

Item {
    id: root
    implicitWidth: 540
    implicitHeight: 460

    property bool isListening: false
    property var notesList: []
    property string activeNoteId: ""

    Process {
        id: fsProc
        onExited: root.loadNotes()
    }

    Component.onCompleted: {
        var dirCmd = "mkdir -p " + PoniConfig.configDir + "/notes";
        fsProc.command = ["bash", "-c", dirCmd];
        fsProc.running = true;
    }

    function loadNotes() {
        var readCmd = "ls -t " + PoniConfig.configDir + "/notes/*.md 2>/dev/null | head -n 20";
        var p = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
        p.command = ["bash", "-c", readCmd];
        p.stdout = function(line) {
            var items = [];
            var lines = line.trim().split("\n");
            for (var i = 0; i < lines.length; i++) {
                if (lines[i].length > 0) {
                    var parts = lines[i].split("/");
                    items.push({ path: lines[i], name: parts[parts.length - 1] });
                }
            }
            root.notesList = items;
        };
        p.running = true;
    }

    function saveCurrentNote() {
        var content = noteArea.text;
        var filename = root.activeNoteId.length > 0 ? root.activeNoteId : ("note_" + Date.now() + ".md");
        root.activeNoteId = filename;
        var fullPath = PoniConfig.configDir + "/notes/" + filename;

        var saveProc = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
        saveProc.command = ["bash", "-c", "cat > " + fullPath];
        saveProc.running = true;
        saveProc.write(content);
        saveProc.close();
        PoniNotices.post("Note saved", filename);
        root.loadNotes();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Meeting & Voice Notes"
                color: "#ffffff"
                font.pixelSize: 15
                font.family: "Outfit"
                font.weight: Font.DemiBold
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 30
                height: 30
                radius: 6
                color: root.isListening ? "#e04f4f" : Qt.rgba(1, 1, 1, 0.08)

                PoniIcon {
                    anchors.centerIn: parent
                    name: "mic"
                    size: 15
                    color: "#ffffff"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.isListening = !root.isListening;
                        if (root.isListening) {
                            PoniNotices.post("Voice Transcribe", "Listening to audio input...");
                        }
                    }
                }
            }

            Rectangle {
                width: 70
                height: 30
                radius: 6
                color: "#f08236"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    PoniIcon {
                        name: "save"
                        size: 13
                        color: "#ffffff"
                    }
                    Text {
                        text: "Save"
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.family: "Outfit"
                        font.weight: Font.DemiBold
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.saveCurrentNote()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            Rectangle {
                Layout.fillHeight: true
                width: 150
                radius: 10
                color: Qt.rgba(1, 1, 1, 0.04)
                border.color: Qt.rgba(1, 1, 1, 0.08)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Recent Notes"
                            color: Qt.rgba(1, 1, 1, 0.5)
                            font.pixelSize: 11
                            font.family: "Outfit"
                        }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 4
                            color: Qt.rgba(1, 1, 1, 0.1)
                            PoniIcon {
                                anchors.centerIn: parent
                                name: "plus"
                                size: 12
                                color: "#ffffff"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeNoteId = "";
                                    noteArea.text = "";
                                }
                            }
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        model: root.notesList

                        delegate: Rectangle {
                            width: parent.width
                            height: 32
                            radius: 6
                            color: root.activeNoteId === modelData.name ? Qt.rgba(240/255, 130/255, 54/255, 0.2) : Qt.rgba(1, 1, 1, 0.04)

                            Text {
                                anchors.fill: parent
                                anchors.margins: 6
                                text: modelData.name.replace(".md", "")
                                color: "#ffffff"
                                font.pixelSize: 11
                                font.family: "Outfit"
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeNoteId = modelData.name;
                                    var read = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
                                    read.command = ["cat", modelData.path];
                                    var buf = "";
                                    read.stdout = function(line) { buf += line + "\n"; };
                                    read.exited.connect(function() { noteArea.text = buf; });
                                    read.running = true;
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: Qt.rgba(0, 0, 0, 0.3)
                border.color: Qt.rgba(1, 1, 1, 0.08)

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 10

                    TextArea {
                        id: noteArea
                        color: "#ffffff"
                        font.pixelSize: 13
                        font.family: "Outfit"
                        wrapMode: Text.WordWrap
                        background: null
                        selectByMouse: true
                        placeholderText: "Start typing meeting summary, action items, or voice transcript..."
                    }
                }
            }
        }
    }
}
