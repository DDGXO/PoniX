pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string downloadDir: Quickshell.env("HOME") + "/Downloads/PoniX"
    property var activeJobs: [] // [{ id, url, title, progress, speed, eta, status, format, filePath }]
    property bool hasActiveDownloads: activeJobs.some(function(j) { return j.status === "downloading"; })

    function startDownload(url, format) {
        if (!url || url.trim().length === 0) return;
        var id = Date.now().toString();
        var job = {
            id: id,
            url: url.trim(),
            title: "Fetching info...",
            progress: 0,
            speed: "--",
            eta: "--",
            status: "downloading",
            format: format || "video",
            filePath: ""
        };
        var list = root.activeJobs.slice();
        list.unshift(job);
        root.activeJobs = list;

        // Command for yt-dlp
        var fmtArg = format === "audio" ? "-x --audio-format mp3" : "-f bestvideo+bestaudio/best --merge-output-format mp4";
        var cmd = "mkdir -p \"" + root.downloadDir + "\" && cd \"" + root.downloadDir + "\" && yt-dlp " + fmtArg + " --newline --no-colors \"" + url + "\"";

        var proc = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
        proc.command = ["sh", "-c", cmd];
        proc.stdout = Qt.createQmlObject('import Quickshell.Io; SplitParser {}', proc);
        proc.stdout.read.connect(function(data) {
            root.handleLine(id, data);
        });
        proc.running = true;
    }

    function handleLine(jobId, line) {
        if (!line) return;
        var list = root.activeJobs.slice();
        var idx = -1;
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === jobId) { idx = i; break; }
        }
        if (idx < 0) return;

        var job = Object.assign({}, list[idx]);
        // parse yt-dlp output
        // [download]  45.2% of 25.10MiB at 4.20MiB/s ETA 00:03
        if (line.indexOf("[download]") >= 0 && line.indexOf("%") >= 0) {
            var pctMatch = line.match(/(\d+\.?\d*)%/);
            if (pctMatch) job.progress = Math.min(100, parseFloat(pctMatch[1]));
            var speedMatch = line.match(/at\s+([\d\.]+\w+\/s)/);
            if (speedMatch) job.speed = speedMatch[1];
            var etaMatch = line.match(/ETA\s+([\d:]+)/);
            if (etaMatch) job.eta = etaMatch[1];
            job.status = "downloading";
        } else if (line.indexOf("[Destination:") >= 0 || line.indexOf("[download] Destination:") >= 0) {
            var dest = line.split("Destination:")[1].trim();
            job.title = dest.split("/").pop();
            job.filePath = root.downloadDir + "/" + job.title;
        } else if (line.indexOf("100%") >= 0 || line.indexOf("[Merger]") >= 0) {
            job.progress = 100;
            job.status = "done";
            if (job.filePath && job.filePath.length > 0) {
                PoniShelf.addFile(job.filePath);
            }
        }
        list[idx] = job;
        root.activeJobs = list;
    }

    function removeJob(jobId) {
        root.activeJobs = root.activeJobs.filter(function(j) { return j.id !== jobId; });
    }
}
