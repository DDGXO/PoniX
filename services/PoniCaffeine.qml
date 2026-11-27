pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Half-life ~ 5 hours
    property real halfLifeHours: 5.0
    property int bedtimeHour: 23 // 23:00 / 11 PM
    property real maxBedtimeMg: 35.0 // max caffeine in blood at bedtime

    property var drinks: [
        { id: 1, name: "Double Espresso", mg: 120, time: "09:30", hour: 9.5 },
        { id: 2, name: "Americano", mg: 95, time: "14:15", hour: 14.25 }
    ]

    // Current caffeine remaining in blood
    property real currentCaffeineMg: 68.4
    property string lastCallTime: "16:30"
    property int minutesToLastCall: 45

    function addDrink(name, mg) {
        var now = new Date();
        var h = now.getHours() + (now.getMinutes() / 60);
        var tStr = (now.getHours() < 10 ? "0" : "") + now.getHours() + ":" +
                   (now.getMinutes() < 10 ? "0" : "") + now.getMinutes();

        var list = root.drinks.slice();
        list.push({ id: Date.now(), name: name, mg: mg, time: tStr, hour: h });
        root.drinks = list;
        calculateMetabolism();
        PoniConfig.caffeineDrinks = list;
        PoniConfig.saveData();
    }

    function removeDrink(id) {
        var list = root.drinks.filter(function(d) { return d.id !== id; });
        root.drinks = list;
        calculateMetabolism();
        PoniConfig.caffeineDrinks = list;
        PoniConfig.saveData();
    }

    function calculateMetabolism() {
        var now = new Date();
        var curH = now.getHours() + (now.getMinutes() / 60);
        var totalNow = 0;

        for (var i = 0; i < root.drinks.length; i++) {
            var d = root.drinks[i];
            var elapsedH = curH - d.hour;
            if (elapsedH < 0) elapsedH += 24; // across midnight
            if (elapsedH < 24) {
                var remaining = d.mg * Math.pow(0.5, elapsedH / root.halfLifeHours);
                totalNow += remaining;
            }
        }
        root.currentCaffeineMg = Math.round(totalNow * 10) / 10;

        // Calculate last call for a standard 80mg coffee so that at bedtime <= maxBedtimeMg
        // 80 * (0.5)^(H / 5) = 35 => H = 5 * log2(80/35) = ~5.95 hours before bedtime
        var requiredLeadHours = root.halfLifeHours * (Math.log(80 / root.maxBedtimeMg) / Math.LN2);
        var lastCallH = (root.bedtimeHour - requiredLeadHours + 24) % 24;
        var lcHrs = Math.floor(lastCallH);
        var lcMns = Math.floor((lastCallH - lcHrs) * 60);
        root.lastCallTime = (lcHrs < 10 ? "0" : "") + lcHrs + ":" + (lcMns < 10 ? "0" : "") + lcMns;

        var lastCallMin = lcHrs * 60 + lcMns;
        var curMin = now.getHours() * 60 + now.getMinutes();
        root.minutesToLastCall = lastCallMin - curMin;
    }

    Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: root.calculateMetabolism()
    }

    Component.onCompleted: {
        if (PoniConfig.caffeineDrinks && PoniConfig.caffeineDrinks.length > 0) {
            root.drinks = PoniConfig.caffeineDrinks;
        }
        calculateMetabolism();
    }
}
