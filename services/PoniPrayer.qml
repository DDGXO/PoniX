pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string placesFile: Quickshell.env("PWD") + "/data/places.json"
    property string activeCity: "Kota Jakarta"
    property string placeSource: "Picked by you"
    property real lat: -6.2088
    property real lng: 106.8456
    property int tz: 7
    property real h0: -1.0
    property real subuhAngle: 20.0
    property real isyaAngle: 18.0

    property string soundMode: "tone" // adzan, tone, silent
    property string dismissedKey: ""
    property var allPlaces: []

    property var times: ({
        imsak: "04:15",
        subuh: "04:25",
        terbit: "05:45",
        dzuhur: "11:58",
        ashar: "15:22",
        maghrib: "18:05",
        isya: "19:18"
    })

    property string nextPrayerName: "Isya"
    property string nextPrayerTime: "19:18"
    property bool nextIsTomorrow: false
    property int minutesToNext: 60
    property int secondsToNext: 3600
    property string countdownText: "01:00:00"
    property real dayProgress: 0.5
    property bool isDaylight: true
    property int qiblaAngle: 295
    property string qiblaCompass: "WNW"
    property string hijriLabel: ""

    readonly property bool isCountingDown: Boolean(
        PoniConfig.addons && PoniConfig.addons["prayer"] &&
        PoniConfig.prayerRemindBefore > 0 &&
        minutesToNext > 0 &&
        minutesToNext <= PoniConfig.prayerRemindBefore &&
        dismissedKey !== (nextPrayerName + ":" + nextPrayerTime)
    )

    function dismissCountdown() {
        dismissedKey = nextPrayerName + ":" + nextPrayerTime;
    }

    function setPlace(p) {
        activeCity = p.label;
        lat = p.lat;
        lng = p.lng;
        h0 = (p.h0 !== undefined) ? p.h0 : -1.0;
        subuhAngle = (p.subuh_angle !== undefined) ? p.subuh_angle : 20.0;
        isyaAngle = (p.isya_angle !== undefined) ? p.isya_angle : 18.0;
        placeSource = "Picked by you";
        calculateTodayTimes();
    }

    function computeHijri(date) {
        // Tabular Islamic calendar approximation matching Kemenag/UMM
        var jd = Math.floor((date.getTime() / 86400000) + 2440587.5);
        var l = jd - 1948440 + 10632;
        var n = Math.floor((l - 1) / 10631);
        l = l - 10631 * n + 354;
        var j = (Math.floor((10985 - l) / 5316)) * (Math.floor((50 * l) / 17719)) + (Math.floor(l / 5670)) * (Math.floor((43 * l) / 15238));
        l = l - (Math.floor((30 - j) / 15)) * (Math.floor((17719 * j) / 50)) - (Math.floor(j / 16)) * (Math.floor((15238 * j) / 43)) + 29;
        var month = Math.floor((24 * l) / 709);
        var day = l - Math.floor((709 * month) / 24);
        var year = 30 * n + j - 30;
        var months = ["", "Muharram", "Safar", "Rabiulawal", "Rabiulakhir", "Jumadilawal", "Jumadilakhir", "Rajab", "Syaban", "Ramadan", "Syawal", "Zulkaidah", "Zulhijjah"];
        return day + " " + (months[month] || "") + " " + year;
    }

    function calculateTodayTimes() {
        var now = new Date();
        var y = now.getFullYear();
        var dayOfYear = Math.floor((now - new Date(y, 0, 0)) / 1000 / 60 / 60 / 24);
        var decl = 23.45 * Math.sin((360 / 365) * (dayOfYear - 81) * Math.PI / 180);
        var eqTime = 9.87 * Math.sin(2 * (360 / 365) * (dayOfYear - 81) * Math.PI / 180) -
                     7.53 * Math.cos((360 / 365) * (dayOfYear - 81) * Math.PI / 180) -
                     1.5 * Math.sin((360 / 365) * (dayOfYear - 81) * Math.PI / 180);

        var noon = 12 + root.tz - (root.lng / 15) - (eqTime / 60);

        function hourAngle(alpha) {
            var radLat = root.lat * Math.PI / 180;
            var radDecl = decl * Math.PI / 180;
            var radAlpha = alpha * Math.PI / 180;
            var cosH = (Math.sin(radAlpha) - Math.sin(radLat) * Math.sin(radDecl)) /
                       (Math.cos(radLat) * Math.cos(radDecl));
            if (cosH > 1 || cosH < -1) return 0;
            return Math.acos(cosH) * 180 / Math.PI / 15;
        }

        var haSubuh = hourAngle(-root.subuhAngle);
        var haTerbit = hourAngle(root.h0);
        var haMaghrib = hourAngle(root.h0);
        var haIsya = hourAngle(-root.isyaAngle);

        var radLat = root.lat * Math.PI / 180;
        var radDecl = decl * Math.PI / 180;
        var acotVal = Math.tan(Math.abs(radLat - radDecl)) + 1;
        var altAsr = Math.atan(1 / acotVal) * 180 / Math.PI;
        var haAshar = hourAngle(altAsr);

        function fmt(h) {
            var hNorm = (h + 24) % 24;
            var hrs = Math.floor(hNorm);
            var mns = Math.floor((hNorm - hrs) * 60);
            return (hrs < 10 ? "0" : "") + hrs + ":" + (mns < 10 ? "0" : "") + mns;
        }

        var subuhH = noon - haSubuh;
        var imsakH = subuhH - (10 / 60);
        var terbitH = noon - haTerbit;
        var dzuhurH = noon;
        var asharH = noon + haAshar;
        var maghribH = noon + haMaghrib;
        var isyaH = noon + haIsya;

        root.times = {
            imsak: fmt(imsakH),
            subuh: fmt(subuhH),
            terbit: fmt(terbitH),
            dzuhur: fmt(dzuhurH),
            ashar: fmt(asharH),
            maghrib: fmt(maghribH),
            isya: fmt(isyaH)
        };

        var phiK = 21.4225 * Math.PI / 180;
        var lambdaK = 39.8262 * Math.PI / 180;
        var phi = root.lat * Math.PI / 180;
        var lambda = root.lng * Math.PI / 180;
        var num = Math.sin(lambdaK - lambda);
        var denom = Math.cos(phi) * Math.tan(phiK) - Math.sin(phi) * Math.cos(lambdaK - lambda);
        var q = Math.atan2(num, denom) * 180 / Math.PI;
        var deg = Math.round((q + 360) % 360);
        root.qiblaAngle = deg;
        var pts = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
        root.qiblaCompass = pts[Math.floor(((deg + 11.25) / 22.5)) % 16];
        root.hijriLabel = computeHijri(now);

        root.updateNext();
    }

    function toSec(tStr) {
        var parts = tStr.split(":");
        return parseInt(parts[0], 10) * 3600 + parseInt(parts[1], 10) * 60;
    }

    function updateNext() {
        var now = new Date();
        var curSec = now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds();

        var slots = [0.1, 0.3, 0.5, 0.7, 0.9];
        var order = [
            { name: "Subuh", time: root.times.subuh, s: toSec(root.times.subuh) },
            { name: "Dzuhur", time: root.times.dzuhur, s: toSec(root.times.dzuhur) },
            { name: "Ashar", time: root.times.ashar, s: toSec(root.times.ashar) },
            { name: "Maghrib", time: root.times.maghrib, s: toSec(root.times.maghrib) },
            { name: "Isya", time: root.times.isya, s: toSec(root.times.isya) }
        ];

        var terbitS = toSec(root.times.terbit);
        var maghribS = toSec(root.times.maghrib);
        root.isDaylight = (curSec >= terbitS && curSec < maghribS);

        // Compute arc position matching prayer.rs day_pos()
        var marks = [{ s: 0, p: 0.0 }];
        for (var i = 0; i < 5; i++) marks.push({ s: order[i].s, p: slots[i] });
        marks.push({ s: 86400, p: 1.0 });
        var pos = 1.0;
        for (var m = 0; m < marks.length - 1; m++) {
            if (curSec < marks[m + 1].s) {
                var span = Math.max(1, marks[m + 1].s - marks[m].s);
                var k = Math.max(0.0, Math.min(1.0, (curSec - marks[m].s) / span));
                pos = marks[m].p + (marks[m + 1].p - marks[m].p) * k;
                break;
            }
        }
        root.dayProgress = pos;

        var found = false;
        for (var j = 0; j < order.length; j++) {
            if (order[j].s > curSec) {
                root.nextPrayerName = order[j].name;
                root.nextPrayerTime = order[j].time;
                root.nextIsTomorrow = false;
                root.secondsToNext = order[j].s - curSec;
                found = true;
                break;
            }
        }
        if (!found) {
            root.nextPrayerName = "Subuh";
            root.nextPrayerTime = root.times.subuh;
            root.nextIsTomorrow = true;
            root.secondsToNext = (86400 - curSec) + order[0].s;
        }

        root.minutesToNext = Math.ceil(root.secondsToNext / 60);
        var hh = Math.floor(root.secondsToNext / 3600);
        var mm = Math.floor((root.secondsToNext % 3600) / 60);
        var ss = root.secondsToNext % 60;
        root.countdownText = (hh < 10 ? "0" : "") + hh + ":" + (mm < 10 ? "0" : "") + mm + ":" + (ss < 10 ? "0" : "") + ss;
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.updateNext()
    }

    Process {
        id: loadPlacesProc
        command: ["sh", "-c", "test -f \"$1\" && cat \"$1\"", "_", root.placesFile]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text);
                    if (data && Array.isArray(data.places)) {
                        root.allPlaces = data.places;
                    }
                } catch(e) {}
            }
        }
    }

    Component.onCompleted: {
        calculateTodayTimes();
        loadPlacesProc.running = true;
    }
}
