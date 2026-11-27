pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int workSec: 25 * 60
    readonly property int shortBreakSec: 5 * 60
    readonly property int longBreakSec: 15 * 60

    property string phase: "work" // work, short_break, long_break
    property int remainingSec: workSec
    property int targetSec: workSec
    property bool running: false
    readonly property bool isRunning: running
    property int completedSessions: 0

    readonly property string formattedTime: {
        var m = Math.floor(remainingSec / 60);
        var s = remainingSec % 60;
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
    }

    readonly property real progress: targetSec > 0 ? (1.0 - (remainingSec / targetSec)) : 0.0

    function start() {
        if (remainingSec <= 0) reset();
        running = true;
    }

    function pause() {
        running = false;
    }

    function toggle() {
        if (running) pause();
        else start();
    }

    function reset() {
        running = false;
        if (phase === "work") remainingSec = workSec;
        else if (phase === "short_break") remainingSec = shortBreakSec;
        else remainingSec = longBreakSec;
        targetSec = remainingSec;
    }

    function setPhase(p) {
        phase = p;
        if (p === "work") remainingSec = workSec;
        else if (p === "short_break") remainingSec = shortBreakSec;
        else remainingSec = longBreakSec;
        targetSec = remainingSec;
        running = false;
    }

    function finishPhase() {
        running = false;
        if (phase === "work") {
            completedSessions++;
            PoniConfig.focusCompleted = completedSessions;
            PoniConfig.saveData();
            if (completedSessions % 4 === 0) {
                setPhase("long_break");
            } else {
                setPhase("short_break");
            }
            notifyProc.command = ["notify-send", "-a", "PoniX", "Focus Session Complete", "Good job. Time for a well-deserved break."];
        } else {
            setPhase("work");
            notifyProc.command = ["notify-send", "-a", "PoniX", "Break Finished", "Ready to focus again? Let's go."];
        }
        notifyProc.running = true;
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.running
        onTriggered: {
            if (root.remainingSec > 0) {
                root.remainingSec--;
            } else {
                root.finishPhase();
            }
        }
    }

    Process {
        id: notifyProc
    }

    Component.onCompleted: {
        completedSessions = PoniConfig.focusCompleted;
    }
}
