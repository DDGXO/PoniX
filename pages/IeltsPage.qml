import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../services"

Item {
    id: root
    implicitWidth: 540
    implicitHeight: 248

    property int activePart: 1
    property int remainingSec: 60
    property bool isTiming: false
    property string activePrompt: "Part 1: Let's talk about your hometown. Where is your hometown located, and what do you like most about living there?"

    property var promptsPart1: [
        "Part 1: Let's talk about your hometown. Where is your hometown located, and what do you like most about living there?",
        "Part 1: Do you work or are you a student? What are your daily responsibilities?",
        "Part 1: How do you usually spend your weekends? Do you prefer relaxing or active hobbies?"
    ]

    property var promptsPart2: [
        "Part 2 (Cue Card): Describe a person who has strongly influenced your life.\nYou should say:\n- Who this person is\n- How you met them\n- What special qualities they have\nAnd explain how they have influenced you.",
        "Part 2 (Cue Card): Describe an exciting journey you once took.\nYou should say:\n- Where you went\n- Who you went with\n- What you did there\nAnd explain why this journey was memorable."
    ]

    property var promptsPart3: [
        "Part 3: In what ways do you think modern technology changes interpersonal communication between generations?",
        "Part 3: Should governments allocate more funds to public transportation or to expanding highway infrastructure?"
    ]

    Timer {
        id: sessionTimer
        interval: 1000
        running: root.isTiming
        repeat: true
        onTriggered: {
            if (root.remainingSec > 0) {
                root.remainingSec -= 1;
            } else {
                root.isTiming = false;
                PoniNotices.post("IELTS Coach", "Time's up! Great response.");
            }
        }
    }

    function formatTime(s) {
        var m = Math.floor(s / 60);
        var sec = s % 60;
        return (m < 10 ? "0" + m : m) + ":" + (sec < 10 ? "0" + sec : sec);
    }

    function selectPart(p) {
        root.activePart = p;
        root.isTiming = false;
        if (p === 1) {
            root.remainingSec = 60;
            root.activePrompt = promptsPart1[0];
        } else if (p === 2) {
            root.remainingSec = 120;
            root.activePrompt = promptsPart2[0];
        } else {
            root.remainingSec = 180;
            root.activePrompt = promptsPart3[0];
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "IELTS Speaking Coach"
                color: "#ffffff"
                font.pixelSize: 15
                font.family: "Outfit"
                font.weight: Font.DemiBold
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 4
                Repeater {
                    model: [1, 2, 3]
                    Rectangle {
                        width: 58
                        height: 28
                        radius: 6
                        color: root.activePart === modelData ? "#f08236" : Qt.rgba(1, 1, 1, 0.08)

                        Text {
                            anchors.centerIn: parent
                            text: "Part " + modelData
                            color: root.activePart === modelData ? "#ffffff" : Qt.rgba(1, 1, 1, 0.6)
                            font.pixelSize: 11
                            font.family: "Outfit"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.selectPart(modelData)
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: Qt.rgba(1, 1, 1, 0.04)
            border.color: Qt.rgba(1, 1, 1, 0.08)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Image {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        source: "../assets/ponix-x-white.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text {
                            text: "Examiner Poni"
                            color: "#f08236"
                            font.pixelSize: 12
                            font.family: "Outfit"
                            font.weight: Font.DemiBold
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.activePrompt
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.family: "Outfit"
                            wrapMode: Text.WordWrap
                            lineHeight: 1.25
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.06)
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: "Remaining"
                            color: Qt.rgba(1, 1, 1, 0.4)
                            font.pixelSize: 10
                            font.family: "Outfit"
                        }
                        Text {
                            text: formatTime(root.remainingSec)
                            color: root.remainingSec < 15 ? "#e04f4f" : "#50e3c2"
                            font.pixelSize: 22
                            font.family: "Outfit"
                            font.weight: Font.Bold
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 100
                        height: 36
                        radius: 8
                        color: root.isTiming ? Qt.rgba(240/255, 130/255, 54/255, 0.2) : "#f08236"
                        border.color: root.isTiming ? "#f08236" : "transparent"

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            PoniIcon {
                                name: root.isTiming ? "pause" : "play"
                                size: 14
                                color: "#ffffff"
                            }
                            Text {
                                text: root.isTiming ? "Pause" : "Start"
                                color: "#ffffff"
                                font.pixelSize: 13
                                font.family: "Outfit"
                                font.weight: Font.DemiBold
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.isTiming = !root.isTiming
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    { label: "Fluency", score: "7.5" },
                    { label: "Lexical", score: "7.0" },
                    { label: "Grammar", score: "7.5" },
                    { label: "Pronunciation", score: "8.0" }
                ]

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.04)

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.label
                            color: Qt.rgba(1, 1, 1, 0.4)
                            font.pixelSize: 10
                            font.family: "Outfit"
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.score
                            color: "#50e3c2"
                            font.pixelSize: 13
                            font.family: "Outfit"
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }
        }
    }
}
