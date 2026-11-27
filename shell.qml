//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "services"
import "components"

ShellRoot {
    id: root

    FontLoader { id: fontReg; source: "assets/fonts/Outfit-Regular.ttf" }
    FontLoader { id: fontMed; source: "assets/fonts/Outfit-Medium.ttf" }
    FontLoader { id: fontSemi; source: "assets/fonts/Outfit-SemiBold.ttf" }
    FontLoader { id: fontBold; source: "assets/fonts/Outfit-Bold.ttf" }

    property var windows: []

    IpcHandler {
        target: "ponix"

        function toggle() {
            for (var i = 0; i < root.windows.length; i++) {
                var win = root.windows[i];
                if (win && win.visible && win.islandRef) {
                    win.islandRef.isExpanded = !win.islandRef.isExpanded;
                }
            }
        }

        function open(tab: string) {
            for (var i = 0; i < root.windows.length; i++) {
                var win = root.windows[i];
                if (win && win.visible && win.islandRef) {
                    if (tab && tab.length > 0) {
                        win.islandRef.activeTab = tab;
                    }
                    win.islandRef.isExpanded = true;
                }
            }
        }

        function close() {
            for (var i = 0; i < root.windows.length; i++) {
                var win = root.windows[i];
                if (win && win.islandRef) {
                    win.islandRef.isExpanded = false;
                }
            }
        }

        function play() { PoniMedia.togglePlay(); }
        function next() { PoniMedia.nextTrack(); }
        function prev() { PoniMedia.prevTrack(); }
        function focus() { PoniFocus.toggle(); }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: overlay
            required property var modelData

            screen: modelData
            visible: PoniConfig.shouldShowOnScreen(modelData.name)
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: (overlay.visible && island && island.isExpanded) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            WlrLayershell.namespace: "ponix"

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            property alias islandRef: island

            Component.onCompleted: {
                root.windows.push(overlay);
                Hyprland.refreshToplevels();
            }

            mask: islandRegion
            BackgroundEffect.blurRegion: ((PoniConfig.theme === "liquid" && !liveBackdrop.hasContent) || PoniConfig.theme === "glass") && PoniConfig.glassBlur ? blurRegion : null

            // Find visible Hyprland toplevel behind the island on this monitor for real-time 60fps refraction
            readonly property var hyprMonitor: {
                var mons = Hyprland.monitors ? Hyprland.monitors.values : [];
                for (var i = 0; i < mons.length; i++) {
                    if (mons[i] && mons[i].name === modelData.name) return mons[i];
                }
                return null;
            }

            readonly property var targetToplevel: {
                if (PoniConfig.theme !== "liquid" || !overlay.visible) return null;
                var mon = hyprMonitor;
                var activeWsId = (mon && mon.activeWorkspace) ? mon.activeWorkspace.id : -1;
                var list = Hyprland.toplevels ? Hyprland.toplevels.values : [];
                var fallback = null;
                for (var i = 0; i < list.length; i++) {
                    var tl = list[i];
                    if (!tl || !tl.wayland) continue;
                    if (activeWsId >= 0 && tl.workspace && tl.workspace.id !== activeWsId) continue;
                    if (tl.activated) return tl;
                    if (!fallback) fallback = tl;
                }
                return fallback;
            }

            readonly property real winLocalX: {
                if (!targetToplevel || !targetToplevel.lastIpcObject || !targetToplevel.lastIpcObject.at) return 0;
                var monX = hyprMonitor ? hyprMonitor.x : 0;
                return targetToplevel.lastIpcObject.at[0] - monX;
            }
            readonly property real winLocalY: {
                if (!targetToplevel || !targetToplevel.lastIpcObject || !targetToplevel.lastIpcObject.at) return 0;
                var monY = hyprMonitor ? hyprMonitor.y : 0;
                return targetToplevel.lastIpcObject.at[1] - monY;
            }
            readonly property real winW: (targetToplevel && targetToplevel.lastIpcObject && targetToplevel.lastIpcObject.size) ? targetToplevel.lastIpcObject.size[0] : Math.max(1, overlay.width)
            readonly property real winH: (targetToplevel && targetToplevel.lastIpcObject && targetToplevel.lastIpcObject.size) ? targetToplevel.lastIpcObject.size[1] : Math.max(1, overlay.height)

            ScreencopyView {
                id: liveBackdrop
                width: Math.max(1, overlay.winW)
                height: Math.max(1, overlay.winH)
                visible: PoniConfig.theme === "liquid" && overlay.visible && overlay.targetToplevel !== null
                live: visible
                paintCursor: false
                captureSource: visible ? overlay.targetToplevel.wayland : null
            }

            ShaderEffectSource {
                id: backdropTex
                sourceItem: liveBackdrop
                live: PoniConfig.theme === "liquid" && liveBackdrop.hasContent
                hideSource: true
            }

            Region {
                id: islandRegion
                x: island.x
                y: island.y
                width: island.width
                height: island.height
            }

            Region {
                id: blurRegion
                readonly property int inset: Math.max(2, Math.round(island.currentRadius * 0.28))
                x: island.x + inset
                y: island.y + inset
                width: Math.max(0, island.width - inset * 2)
                height: Math.max(0, island.height - inset * 2)
            }

            PoniIsland {
                id: island
                anchors.top: parent.top
                anchors.topMargin: PoniConfig.isFloating ? PoniConfig.notchGap : 0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: PoniConfig.islandX
                backdropSource: backdropTex
                backdropHasContent: liveBackdrop.hasContent && overlay.targetToplevel !== null
                backdropOffset: Qt.vector2d(island.x - overlay.winLocalX, island.y - overlay.winLocalY)
                backdropSize: Qt.vector2d(overlay.winW, overlay.winH)

                Keys.onEscapePressed: {
                    island.isExpanded = false;
                }
            }
        }
    }
}
