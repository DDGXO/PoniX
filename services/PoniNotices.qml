pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property string activeHudTitle: ""
    property string activeHudIcon: ""
    property real activeHudValue: -1 // 0.0 - 1.0 or -1
    property bool hudShowing: false

    property string noticeTitle: ""
    property string noticeMessage: ""
    property string noticeActionText: ""
    property var noticeActionCallback: null
    property bool noticeShowing: false

    function showHud(title, icon, value) {
        root.activeHudTitle = title || "";
        root.activeHudIcon = icon || "info";
        root.activeHudValue = value !== undefined ? value : -1;
        root.hudShowing = true;
        hudTimer.restart();
    }

    function showNotice(title, message, actionText, callback) {
        root.noticeTitle = title || "";
        root.noticeMessage = message || "";
        root.noticeActionText = actionText || "";
        root.noticeActionCallback = callback || null;
        root.noticeShowing = true;
        noticeTimer.restart();
    }

    function dismissNotice() {
        root.noticeShowing = false;
    }

    Timer {
        id: hudTimer
        interval: 2500
        repeat: false
        onTriggered: root.hudShowing = false
    }

    Timer {
        id: noticeTimer
        interval: 6000
        repeat: false
        onTriggered: root.noticeShowing = false
    }
}
