import QtQuick
import "../services"
import "../components"

Item {
    id: root

    implicitHeight: 148

    Row {
        anchors.fill: parent
        spacing: 16

        // Left + Middle: Player Column (56% width)
        Item {
            id: leftCol
            width: parent.width * 0.56
            height: parent.height

            Row {
                anchors.fill: parent
                spacing: 14

                // Album Art (104x104)
                Rectangle {
                    id: artRect
                    width: 104
                    height: 104
                    radius: PoniConfig.theme === "pixel" ? 4 : 14
                    color: PoniConfig.colCard
                    clip: true
                    anchors.verticalCenter: parent.verticalCenter
                    scale: PoniMedia.isPlaying ? 1.0 : 0.94

                    Behavior on scale {
                        NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                    }

                    Image {
                        anchors.fill: parent
                        source: PoniMedia.displayArtUrl
                        fillMode: Image.PreserveAspectCrop
                        visible: PoniMedia.displayArtUrl.length > 0
                    }

                    PoniIcon {
                        anchors.centerIn: parent
                        name: "music"
                        size: 32
                        color: PoniConfig.colTextDim
                        visible: PoniMedia.displayArtUrl.length === 0
                    }
                }

                // Controls, Cava Visualizer & Metadata
                Column {
                    width: parent.width - 118
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    Text {
                        width: parent.width
                        text: PoniMedia.displayTitle || "Nothing playing"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: PoniConfig.colText
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: PoniMedia.displayArtist || "Start a track in any player"
                        font.family: PoniConfig.fontFamily
                        font.pixelSize: 11
                        color: PoniConfig.colTextDim
                        elide: Text.ElideRight
                    }

                    // Live Cava Audio Visualizer (16 bars)
                    Row {
                        width: parent.width
                        height: 18
                        spacing: 3

                        Repeater {
                            model: 16
                            Rectangle {
                                required property int index
                                width: Math.max(3, (parent.width - 15 * 3) / 16)
                                radius: PoniConfig.theme === "pixel" ? 0 : 1.5
                                color: PoniConfig.colAccent
                                opacity: PoniMedia.isPlaying ? 0.85 : 0.25
                                property real barVal: PoniMedia.cavaBars[index] || 0.1
                                height: PoniMedia.isPlaying ? Math.max(2, Math.round(barVal * 18)) : 2
                                anchors.bottom: parent.bottom

                                Behavior on height { NumberAnimation { duration: 45 } }
                            }
                        }
                    }

                    // Seekable Progress Bar
                    Item {
                        width: parent.width
                        height: 14

                        Rectangle {
                            id: track
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 4
                            radius: PoniConfig.theme === "pixel" ? 0 : 2
                            color: PoniConfig.colSurface

                            Rectangle {
                                width: (PoniMedia.length > 0 ? Math.min(1, PoniMedia.position / PoniMedia.length) : 0) * parent.width
                                height: parent.height
                                radius: parent.radius
                                color: PoniConfig.colAccent
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                if (PoniMedia.length > 0) {
                                    var fraction = Math.max(0, Math.min(1, mouse.x / width));
                                    PoniMedia.seek(fraction * PoniMedia.length);
                                }
                            }
                        }
                    }

                    // Times
                    Item {
                        width: parent.width
                        height: 12

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: {
                                var sec = Math.max(0, Math.floor(PoniMedia.position));
                                var m = Math.floor(sec / 60);
                                var s = sec % 60;
                                return m + ":" + (s < 10 ? "0" : "") + s;
                            }
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            color: PoniConfig.colTextFaint
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: {
                                if (PoniMedia.length <= 0) return "--:--";
                                var rem = Math.max(0, Math.floor(PoniMedia.length - PoniMedia.position));
                                var m = Math.floor(rem / 60);
                                var s = rem % 60;
                                return "-" + m + ":" + (s < 10 ? "0" : "") + s;
                            }
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            color: PoniConfig.colTextFaint
                        }
                    }

                    // Transport Buttons
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 16

                        Item {
                            width: 28
                            height: 28
                            PoniIcon {
                                anchors.centerIn: parent
                                name: "prev"
                                size: 15
                                color: PoniConfig.colText
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PoniMedia.previous()
                            }
                        }

                        Rectangle {
                            width: 34
                            height: 34
                            radius: PoniConfig.theme === "pixel" ? 4 : 17
                            color: PoniConfig.colSurface
                            anchors.verticalCenter: parent.verticalCenter

                            PoniIcon {
                                anchors.centerIn: parent
                                name: PoniMedia.isPlaying ? "pause" : "play"
                                size: 15
                                color: PoniConfig.colText
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PoniMedia.playPause()
                            }
                        }

                        Item {
                            width: 28
                            height: 28
                            PoniIcon {
                                anchors.centerIn: parent
                                name: "next"
                                size: 15
                                color: PoniConfig.colText
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PoniMedia.next()
                            }
                        }
                    }
                }
            }
        }

        // Vertical divider
        Rectangle {
            width: 1
            height: parent.height - 6
            anchors.verticalCenter: parent.verticalCenter
            color: PoniConfig.colSurface
        }

        // Right: Synced Lyrics Column (fills remaining width cleanly)
        Item {
            width: Math.max(100, parent.width - leftCol.width - 33)
            height: parent.height

            ListView {
                id: lyricsList
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                clip: true
                spacing: 8
                model: PoniMedia.lyricsLines
                highlightFollowsCurrentItem: true
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: height * 0.34
                preferredHighlightEnd: height * 0.56
                highlightMoveDuration: 360
                highlightMoveVelocity: -1
                currentIndex: PoniMedia.currentLyricIndex

                delegate: Item {
                    width: lyricsList.width
                    height: col.height

                    Column {
                        id: col
                        width: parent.width
                        spacing: 2
                        property bool isCurrent: PoniMedia.lyricsSynced ? (index === PoniMedia.currentLyricIndex) : true
                        transformOrigin: Item.Left
                        scale: isCurrent ? 1.0 : 0.94

                        Behavior on scale {
                            NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
                        }

                        Text {
                            width: parent.width
                            readonly property bool useKaraoke: col.isCurrent && PoniMedia.lyricsSynced && modelData.words && modelData.words.length > 0
                            textFormat: useKaraoke ? Text.RichText : Text.PlainText
                            text: {
                                if (!useKaraoke) return modelData.text;
                                var words = modelData.words;
                                var curW = PoniMedia.currentWordIndex;
                                var pastCol = PoniConfig.colTextDim.toString();
                                var activeCol = PoniConfig.colText.toString();
                                var todoCol = PoniConfig.colTextFaint.toString();
                                var out = "";
                                for (var i = 0; i < words.length; i++) {
                                    var w = words[i].text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
                                    var colHex = (i === curW) ? activeCol : ((i < curW) ? pastCol : todoCol);
                                    if (i === curW) {
                                        out += "<span style=\"color:" + colHex + "; font-weight:700;\">" + w + "</span>";
                                    } else {
                                        out += "<span style=\"color:" + colHex + "; font-weight:400;\">" + w + "</span>";
                                    }
                                    if (i < words.length - 1) out += " ";
                                }
                                return out;
                            }
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 13
                            font.weight: col.isCurrent ? Font.Bold : Font.Medium
                            color: col.isCurrent ? PoniConfig.colText : PoniConfig.colTextFaint
                            wrapMode: Text.Wrap
                            opacity: col.isCurrent ? 1.0 : 0.42

                            Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration: 260 } }
                        }

                        Text {
                            width: parent.width
                            visible: PoniConfig.showRomanization && modelData.roman.length > 0
                            text: modelData.roman
                            font.family: PoniConfig.fontFamily
                            font.pixelSize: 10
                            color: col.isCurrent ? PoniConfig.colTextDim : PoniConfig.colTextFaint
                            wrapMode: Text.Wrap
                            opacity: col.isCurrent ? 0.85 : 0.32

                            Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (PoniMedia.lyricsSynced) PoniMedia.seek(modelData.time);
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: PoniMedia.lyricsLines.length === 0
                    text: PoniMedia.lyricsLoading ? "Fetching synced lyrics..." : "No lyrics found for this song"
                    font.family: PoniConfig.fontFamily
                    font.pixelSize: 11
                    color: PoniConfig.colTextFaint
                }
            }
        }
    }
}
