pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string city: "Auto"
    property string locationLabel: "Detecting..."
    property string tempC: "--"
    property string feelsLikeC: "--"
    property string condition: "Loading..."
    property string humidity: "--"
    property string windKmh: "--"
    property string rainChance: "0"
    property var forecast: [] // [{ time, tempC, cond, rain }]
    property bool isLoading: false

    Timer {
        interval: 900000 // 15 min
        repeat: true
        running: !!PoniConfig.addons["weather"]
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    function refresh(customCity) {
        if (customCity !== undefined) {
            root.city = customCity.trim().length > 0 ? customCity.trim() : "Auto";
        }
        if (fetchProc.running) return;
        root.isLoading = true;
        var q = (root.city === "Auto" || root.city.length === 0) ? "" : encodeURIComponent(root.city);
        fetchProc.command = ["curl", "-s", "--max-time", "8", "https://wttr.in/" + q + "?format=j1"];
        fetchProc.running = true;
    }

    Process {
        id: fetchProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.isLoading = false;
                var raw = text.trim();
                if (!raw) return;
                try {
                    var j = JSON.parse(raw);
                    if (j.nearest_area && j.nearest_area.length > 0) {
                        var na = j.nearest_area[0];
                        var area = (na.areaName && na.areaName[0]) ? na.areaName[0].value : "";
                        var country = (na.country && na.country[0]) ? na.country[0].value : "";
                        root.locationLabel = area + (country ? (", " + country) : "");
                    }
                    if (j.current_condition && j.current_condition.length > 0) {
                        var cc = j.current_condition[0];
                        root.tempC = cc.temp_C || "--";
                        root.feelsLikeC = cc.FeelsLikeC || "--";
                        root.humidity = cc.humidity || "--";
                        root.windKmh = cc.windspeedKmph || "--";
                        root.condition = (cc.weatherDesc && cc.weatherDesc[0]) ? cc.weatherDesc[0].value : "Clear";
                    }
                    if (j.weather && j.weather.length > 0 && j.weather[0].hourly) {
                        var hrs = j.weather[0].hourly;
                        var nowH = new Date().getHours();
                        var out = [];
                        var maxRain = 0;
                        for (var i = 0; i < hrs.length; i++) {
                            var hInt = Math.floor((parseInt(hrs[i].time, 10) || 0) / 100);
                            var rPct = parseInt(hrs[i].chanceofrain, 10) || 0;
                            if (hInt >= nowH && rPct > maxRain) maxRain = rPct;
                            if (hInt >= nowH && out.length < 4) {
                                out.push({
                                    time: (hInt < 10 ? "0" : "") + hInt + ":00",
                                    tempC: hrs[i].tempC + "°",
                                    cond: (hrs[i].weatherDesc && hrs[i].weatherDesc[0]) ? hrs[i].weatherDesc[0].value : "",
                                    rain: rPct + "%"
                                });
                            }
                        }
                        root.rainChance = String(maxRain);
                        root.forecast = out;
                    }
                } catch(e) {}
            }
        }
    }
}
