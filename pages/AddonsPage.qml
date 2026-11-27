import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../services"

Item {
    id: root
    implicitWidth: 540
    implicitHeight: 460

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Addons & Extensions"
                color: "#ffffff"
                font.pixelSize: 15
                font.family: "Outfit"
                font.weight: Font.DemiBold
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "Modular extensions for PoniX"
                color: Qt.rgba(1, 1, 1, 0.4)
                font.pixelSize: 12
                font.family: "Outfit"
            }
        }

        ListView {
            id: addonList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: [
                { id: "system", name: "System Monitor", desc: "Live CPU, RAM, GPU, and system temperatures in notch", icon: "gauge" },
                { id: "prayer", name: "Sholat (Prayer Times)", desc: "Indonesian Kemenag RI and global coordinates prayer schedules with Adzan", icon: "moon" },
                { id: "downloads", name: "Video & Audio Downloader", desc: "High-speed media extraction via yt-dlp with notch progress ring", icon: "download" },
                { id: "stocks", name: "Stocks & Crypto Ticker", desc: "Real-time ticker quotes with 24h percent gains and mini trend charts", icon: "stocks" },
                { id: "caffeine", name: "Caffeine Metabolism Tracker", desc: "Decay curve and bedtime sleep window calculation", icon: "coffee" },
                { id: "script", name: "Teleprompter", desc: "Webcam aligned prompter for eye-contact during meetings", icon: "script" },
                { id: "record", name: "Screen & Audio Recorder", desc: "Quick Wayland desktop and region capture", icon: "recorder" },
                { id: "notes", name: "Meeting Notes", desc: "Audio recording and markdown notes manager", icon: "notes" },
                { id: "health", name: "Posture & Eye Rest", desc: "Periodic health reminders and 20-20-20 break timer", icon: "steps" },
                { id: "ielts", name: "IELTS Speaking Coach", desc: "Turn-taking exam simulation with Poni mascot", icon: "mic" },
                { id: "servers", name: "Server & Homelab Watch", desc: "Monitor VPS/homelab latency, HTTP/TCP uptime, and quick SSH launch", icon: "servers" },
                { id: "agent", name: "Agent Terminal", desc: "Interactive Antigravity (agy) & Claude Code terminal inside Poni", icon: "ai" },
                { id: "audio", name: "Audio & Device Mixer", desc: "Output/mic volume sliders, mute toggle, and PipeWire/PulseAudio device switcher", icon: "audio" },
                { id: "clipboard", name: "Clipboard History", desc: "Searchable copy-paste history via cliphist/wl-paste with pin support", icon: "clipboard" },
                { id: "capture", name: "Color Picker & Capture", desc: "Screen color picker (hyprpicker) and region/screen screenshot (grim/slurp)", icon: "capture" },
                { id: "weather", name: "Weather & Rain Alert", desc: "Live local temperature, humidity, wind, and hourly rain forecast", icon: "weather" },
                { id: "share", name: "QR & Local File Share", desc: "Generate QR codes from clipboard and start a local LAN file server", icon: "share" },
                { id: "translate", name: "Quick Translator", desc: "Fast inline translation (Auto/ID/EN/JA) with clipboard paste & copy", icon: "translate" }
            ]

            delegate: Rectangle {
                width: addonList.width
                height: 56
                radius: 10
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: Qt.rgba(1, 1, 1, 0.08)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 8
                        color: modelData.enabled ? Qt.rgba(240/255, 130/255, 54/255, 0.18) : Qt.rgba(1, 1, 1, 0.08)

                        PoniIcon {
                            anchors.centerIn: parent
                            name: modelData.icon
                            size: 16
                            color: modelData.enabled ? "#f08236" : Qt.rgba(1, 1, 1, 0.5)
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: modelData.name
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.family: "Outfit"
                            font.weight: Font.DemiBold
                        }
                        Text {
                            Layout.fillWidth: true
                            text: modelData.desc
                            color: Qt.rgba(1, 1, 1, 0.45)
                            font.pixelSize: 10
                            font.family: "Outfit"
                            elide: Text.ElideRight
                        }
                    }

                    Switch {
                        checked: !!PoniConfig.addons[modelData.id]
                        onToggled: PoniConfig.toggleAddon(modelData.id)
                    }
                }
            }
        }
    }
}
