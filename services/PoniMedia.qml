pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var allPlayers: Mpris.players.values
    readonly property var players: {
        var list = [];
        for (var i = 0; i < allPlayers.length; i++) {
            var p = allPlayers[i];
            if (p && (!p.dbusName || p.dbusName.indexOf("playerctld") < 0)) {
                list.push(p);
            }
        }
        return list;
    }

    // Active player selection
    readonly property var activePlayer: {
        if (players.length === 0) return null;
        for (var i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing) return players[i];
        }
        for (var j = 0; j < players.length; j++) {
            if (players[j].trackTitle && players[j].trackTitle.length > 0) return players[j];
        }
        return players[0];
    }

    readonly property bool hasMedia: activePlayer !== null && ((activePlayer.trackTitle && activePlayer.trackTitle.length > 0) || (activePlayer.playbackState === MprisPlaybackState.Playing))
    readonly property bool isPlaying: activePlayer ? (activePlayer.playbackState === MprisPlaybackState.Playing) : false
    property bool isPeeking: false
    readonly property string title: activePlayer && activePlayer.trackTitle ? activePlayer.trackTitle : ""
    readonly property string artist: activePlayer && activePlayer.trackArtist ? activePlayer.trackArtist : ""
    readonly property string album: activePlayer && activePlayer.trackAlbum ? activePlayer.trackAlbum : ""
    readonly property string artUrl: activePlayer && activePlayer.trackArtUrl ? activePlayer.trackArtUrl : ""
    readonly property var cleanedMeta: cleanMetadata(title, artist)
    readonly property string displayTitle: cleanedMeta.title || title
    readonly property string displayArtist: cleanedMeta.artist || artist
    property string fetchedArtUrl: ""
    readonly property string displayArtUrl: artUrl.length > 0 ? artUrl : fetchedArtUrl
    readonly property real rawPosition: activePlayer ? activePlayer.position : 0
    property real position: 0
    readonly property real length: activePlayer ? activePlayer.length : 0
    readonly property bool canControl: activePlayer ? activePlayer.canControl : false
    readonly property bool canSeek: activePlayer ? activePlayer.canSeek : false

    // Real-time Cava visualizer bars (16 bands, 0.0 - 1.0)
    property var cavaBars: [0.1, 0.2, 0.15, 0.3, 0.2, 0.1, 0.25, 0.15, 0.2, 0.3, 0.15, 0.1, 0.2, 0.15, 0.1, 0.08]
    property bool cavaActive: false

    // Lyrics State
    property var lyricsLines: [] // [{ time: float_sec, text: string, roman: string, words: [{time, text}] }]
    property int currentLyricIndex: -1
    property int currentWordIndex: -1
    property string currentLyricText: ""
    property string currentLyricRoman: ""
    property bool lyricsLoading: false
    property bool lyricsSynced: false
    property string lastFetchedKey: ""
    property string pendingSearchQuery: ""

    function targetPlayerArg() {
        if (!activePlayer || !activePlayer.dbusName) return "";
        return activePlayer.dbusName.replace("org.mpris.MediaPlayer2.", "");
    }

    function runPlayerCtl(args) {
        var pName = targetPlayerArg();
        var cmd = pName.length > 0 ? ["playerctl", "-p", pName].concat(args) : ["playerctl"].concat(args);
        controlProc.command = cmd;
        controlProc.running = true;
    }

    Process { id: controlProc }

    function play() { runPlayerCtl(["play"]); }
    function pause() { runPlayerCtl(["pause"]); }
    function playPause() { runPlayerCtl(["play-pause"]); }
    function togglePlay() { playPause(); }
    function next() { runPlayerCtl(["next"]); }
    function previous() { runPlayerCtl(["previous"]); }
    function nextTrack() { next(); }
    function prevTrack() { previous(); }
    function seek(sec) {
        if (!activePlayer) return;
        runPlayerCtl(["position", String(sec)]);
        root.position = sec;
        root.updateCurrentLyric();
    }

    onRawPositionChanged: {
        // Only trust rawPosition when it actively changes (e.g. user seek)
        if (Math.abs(root.rawPosition - root.position) > 1.0) {
            root.position = root.rawPosition;
            root.updateCurrentLyric();
        }
    }

    // Real-time 20Hz playback clock + lyric sync (authoritative sync via posSyncProc)
    Timer {
        id: realtimeTimer
        interval: 50
        repeat: true
        running: root.isPlaying
        onTriggered: {
            if (root.activePlayer) {
                root.position += 0.05;
                if (root.length > 0 && root.position > root.length) {
                    root.position = root.length;
                }
                root.updateCurrentLyric();
            }
        }
    }

    // Periodic authoritative position sync via playerctl every 1s
    Timer {
        interval: 1000
        repeat: true
        running: root.isPlaying
        onTriggered: {
            if (!posSyncProc.running) {
                var pName = (root.activePlayer && root.activePlayer.dbusName)
                    ? root.activePlayer.dbusName.replace("org.mpris.MediaPlayer2.", "")
                    : "";
                posSyncProc.command = pName.length > 0
                    ? ["playerctl", "-p", pName, "position"]
                    : ["playerctl", "position"];
                posSyncProc.running = true;
            }
        }
    }

    Process {
        id: posSyncProc
        stdout: StdioCollector {
            onStreamFinished: {
                var val = parseFloat(text.trim());
                if (!isNaN(val) && val >= 0) {
                    if (Math.abs(val - root.position) > 0.25) {
                        root.position = val;
                        root.updateCurrentLyric();
                    }
                }
            }
        }
    }

    // Real-time Cava audio spectrum process
    Process {
        id: cavaProc
        command: [
            "sh", "-c",
            "printf '[general]\\nbars = 16\\nframerate = 30\\n[output]\\nmethod = raw\\nraw_target = /dev/stdout\\ndata_format = ascii\\nascii_max_range = 100\\n' > /tmp/ponix_cava.conf && exec cava -p /tmp/ponix_cava.conf"
        ]
        running: root.isPlaying
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(";");
                if (parts.length >= 12) {
                    var arr = [];
                    var anyNonZero = false;
                    for (var i = 0; i < 16; i++) {
                        var v = i < parts.length ? parseInt(parts[i], 10) : 0;
                        if (isNaN(v)) v = 0;
                        var norm = Math.max(0.05, Math.min(1.0, v / 100.0));
                        if (v > 2) anyNonZero = true;
                        arr.push(norm);
                    }
                    root.cavaBars = arr;
                    root.cavaActive = anyNonZero;
                }
            }
        }
    }

    // Clean noisy YouTube/browser titles like "(24) Artist - Song (Official Video)"
    function cleanMetadata(rawTitle, rawArtist) {
        var t = (rawTitle || "").trim();
        var a = (rawArtist || "").trim();

        // Strip leading "(123) " YouTube notification count
        t = t.replace(/^\(\d+\)\s*/, "");
        // Strip trailing " - YouTube", " | Spotify", etc.
        t = t.replace(/\s*[-|]\s*(YouTube|Spotify|SoundCloud|Music)$/i, "");
        // Strip bracketed noise like [Official Video], (Official Lyric Video), (Lyrics), (Audio), [4K], (feat. ...)
        t = t.replace(/\s*[\(\[](?:official\s*(?:music\s*|lyric\s*)?video|official\s*audio|lyric\s*video|lyrics?|audio|hd|4k|mv|visualizer|live|explicit|remaster(?:ed)?(?:\s*\d+)?|(?:feat|ft|with)\.?[^\)\]]*)[\)\]]/gi, "").trim();

        // If artist is empty, try splitting "Artist - Title"
        if (a.length === 0) {
            var seps = [" - ", " \u2013 ", " \u2014 "];
            for (var i = 0; i < seps.length; i++) {
                var idx = t.indexOf(seps[i]);
                if (idx > 0) {
                    a = t.substring(0, idx).trim();
                    t = t.substring(idx + seps[i].length).trim();
                    break;
                }
            }
        }
        return { title: t, artist: a };
    }

    // Fetch lyrics from LRCLIB (/api/get then /api/search fallback)
    function checkFetchLyrics() {
        if (!hasMedia || title.length === 0) {
            lyricsLines = [];
            currentLyricIndex = -1;
            currentLyricText = "";
            currentLyricRoman = "";
            lastFetchedKey = "";
            lyricsSynced = false;
            return;
        }

        var key = title + " - " + artist;
        if (key === lastFetchedKey) return;
        lastFetchedKey = key;

        root.position = (root.rawPosition < 5) ? root.rawPosition : 0;
        trackStartSyncTimer.restart();
        lyricsLines = [];
        currentLyricIndex = -1;
        currentLyricText = "";
        currentLyricRoman = "";
        lyricsSynced = false;
        lyricsLoading = true;

        var cleaned = cleanMetadata(title, artist);
        var dur = Math.round(length);

        root.fetchedArtUrl = "";
        if (root.artUrl.length === 0) {
            var artQ = (cleaned.artist.length > 0 ? (cleaned.artist + " ") : "") + cleaned.title;
            root.pendingArtQuery = artQ.trim();
            root.pendingArtTitleOnly = cleaned.title.trim();
            if (root.pendingArtQuery.length > 0 || root.activePlayer) {
                var pName = root.targetPlayerArg();
                artFetchProc.stage = 0;
                artFetchProc.command = pName.length > 0
                    ? ["playerctl", "-p", pName, "metadata", "xesam:url"]
                    : ["playerctl", "metadata", "xesam:url"];
                artFetchProc.running = true;
            }
        }

        if (cleaned.artist.length > 0) {
            root.pendingSearchQuery = cleaned.artist + " " + cleaned.title;
            var getUrl = "https://lrclib.net/api/get?track_name=" + encodeURIComponent(cleaned.title) +
                         "&artist_name=" + encodeURIComponent(cleaned.artist) +
                         (dur > 0 ? ("&duration=" + dur) : "");
            fetchProc.isSearch = false;
            fetchProc.command = [
                "curl", "-s", "--max-time", "6",
                "-H", "User-Agent: PoniX/0.3.2 (https://github.com/DDGXO/PoniX)",
                getUrl
            ];
            fetchProc.running = true;
        } else {
            runSearchFallback(cleaned.title);
        }
    }

    function runSearchFallback(query) {
        if (!query || query.trim().length === 0) {
            root.lyricsLoading = false;
            return;
        }
        var searchUrl = "https://lrclib.net/api/search?q=" + encodeURIComponent(query.trim());
        fetchProc.isSearch = true;
        fetchProc.command = [
            "curl", "-s", "--max-time", "6",
            "-H", "User-Agent: PoniX/0.3.2 (https://github.com/DDGXO/PoniX)",
            searchUrl
        ];
        fetchProc.running = true;
    }

    function scorePair(rec, wantTitle, wantArtist, playingDur) {
        var t = (rec.trackName || "").toLowerCase().trim();
        var a = (rec.artistName || "").toLowerCase().trim();
        var wt = (wantTitle || "").toLowerCase().trim();
        var wa = (wantArtist || "").toLowerCase().trim();
        if (!t || !wt) return -1;

        var score = 0;
        if (t === wt) score += 40;
        else if (t.indexOf(wt) >= 0 || wt.indexOf(t) >= 0) score += 20;
        else return -1;

        if (wa.length > 0) {
            if (a === wa) score += 30;
            else if (a.length > 0 && (a.indexOf(wa) >= 0 || wa.indexOf(a) >= 0)) score += 15;
            else score -= 25;
        }

        if (playingDur > 0 && rec.duration && rec.duration > 0) {
            var diff = Math.abs(rec.duration - playingDur);
            if (diff <= 3) score += 30;
            else if (diff <= 6) score += 15;
            else if (diff > 15) score -= 50;
        }

        if (rec.syncedLyrics && rec.syncedLyrics.trim().length > 0) score += 15;
        return score;
    }

    function scoreRecord(rec, wantTitle, wantArtist, playingDur) {
        var s1 = scorePair(rec, wantTitle, wantArtist, playingDur);
        var s2 = (wantArtist && wantArtist.length > 0) ? scorePair(rec, wantArtist, wantTitle, playingDur) : -1;
        return Math.max(s1, s2);
    }

    property string pendingArtQuery: ""
    property string pendingArtTitleOnly: ""

    function extractYoutubeId(text) {
        if (!text) return "";
        var m = text.match(/(?:v=|youtu\.be\/|youtube\.com\/shorts\/|youtube\.com\/embed\/)([A-Za-z0-9_-]{11})/);
        if (m && m[1]) return m[1];
        var m2 = text.match(/"videoId":"([A-Za-z0-9_-]{11})"/);
        return (m2 && m2[1]) ? m2[1] : "";
    }

    Process {
        id: artFetchProc
        property int stage: 0 // 0=mpris xesam:url, 1=youtube search, 2=itunes, 3=deezer
        stdout: StdioCollector {
            onStreamFinished: {
                var found = "";
                var raw = text.trim();
                if (artFetchProc.stage === 0 || artFetchProc.stage === 1) {
                    var vid = root.extractYoutubeId(raw);
                    if (vid.length > 0) {
                        found = "https://i.ytimg.com/vi/" + vid + "/hqdefault.jpg";
                    }
                } else {
                    try {
                        var res = JSON.parse(raw);
                        if (artFetchProc.stage === 3) {
                            if (res && res.data && res.data.length > 0 && res.data[0].album) {
                                found = res.data[0].album.cover_big || res.data[0].album.cover_medium || "";
                            }
                        } else {
                            if (res && res.results && res.results.length > 0 && res.results[0].artworkUrl100) {
                                found = res.results[0].artworkUrl100.replace("100x100bb", "600x600bb");
                            }
                        }
                    } catch(e) {}
                }

                if (found.length > 0) {
                    root.fetchedArtUrl = found;
                    return;
                }

                if (artFetchProc.stage === 0 && root.pendingArtQuery.length > 0) {
                    artFetchProc.stage = 1;
                    artFetchProc.command = [
                        "curl", "-s", "--max-time", "5",
                        "-A", "Mozilla/5.0",
                        "https://www.youtube.com/results?search_query=" + encodeURIComponent(root.pendingArtQuery)
                    ];
                    artFetchProc.running = true;
                } else if (artFetchProc.stage === 1 && root.pendingArtQuery.length > 0) {
                    artFetchProc.stage = 2;
                    artFetchProc.command = [
                        "curl", "-s", "--max-time", "5",
                        "https://itunes.apple.com/search?term=" + encodeURIComponent(root.pendingArtQuery) + "&entity=song&limit=1"
                    ];
                    artFetchProc.running = true;
                } else if (artFetchProc.stage === 2 && root.pendingArtQuery.length > 0) {
                    artFetchProc.stage = 3;
                    artFetchProc.command = [
                        "curl", "-s", "--max-time", "5",
                        "https://api.deezer.com/search?q=" + encodeURIComponent(root.pendingArtQuery) + "&limit=1"
                    ];
                    artFetchProc.running = true;
                }
            }
        }
    }

    Process {
        id: fetchProc
        property bool isSearch: false
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = text.trim();
                if (!raw || raw.length === 0) {
                    if (!fetchProc.isSearch && root.pendingSearchQuery.length > 0) {
                        root.runSearchFallback(root.pendingSearchQuery);
                    } else {
                        root.lyricsLoading = false;
                    }
                    return;
                }
                try {
                    var res = JSON.parse(raw);
                    var cleaned = root.cleanMetadata(root.title, root.artist);
                    var dur = Math.round(root.length);
                    if (fetchProc.isSearch) {
                        root.lyricsLoading = false;
                        if (Array.isArray(res) && res.length > 0) {
                            var best = null;
                            var bestScore = 39; // MIN_SCORE = 40
                            for (var i = 0; i < res.length; i++) {
                                var r = res[i];
                                if (!(r.syncedLyrics || r.plainLyrics)) continue;
                                var sc = root.scoreRecord(r, cleaned.title, cleaned.artist, dur);
                                if (sc > bestScore) {
                                    bestScore = sc;
                                    best = r;
                                }
                            }
                            if (best) {
                                var lrc = best.syncedLyrics || best.plainLyrics || "";
                                root.parseLyrics(lrc);
                            } else {
                                root.lyricsLines = [];
                            }
                        } else {
                            root.lyricsLines = [];
                        }
                    } else {
                        if (res && (res.syncedLyrics || res.plainLyrics)) {
                            root.lyricsLoading = false;
                            root.parseLyrics(res.syncedLyrics || res.plainLyrics || "");
                        } else if (root.pendingSearchQuery.length > 0) {
                            root.runSearchFallback(root.pendingSearchQuery);
                        } else {
                            root.lyricsLoading = false;
                        }
                    }
                } catch(e) {
                    if (!fetchProc.isSearch && root.pendingSearchQuery.length > 0) {
                        root.runSearchFallback(root.pendingSearchQuery);
                    } else {
                        root.lyricsLoading = false;
                        root.lyricsLines = [];
                    }
                }
            }
        }
    }

    function parseLyrics(lrc) {
        if (!lrc || lrc.trim().length === 0) {
            root.lyricsLines = [];
            root.lyricsSynced = false;
            return;
        }

        var lines = lrc.split("\n");
        var parsed = [];
        var plainParsed = [];
        var offsetMs = 0;
        var tagRegex = /\[(\d{1,3}):(\d{2})(?:[\.:](\d{1,3}))?\]/g;
        var offsetRegex = /^\[offset:\s*([+-]?\d+)\s*\]$/i;

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (!line) continue;
            var om = offsetRegex.exec(line);
            if (om) {
                offsetMs = parseInt(om[1], 10) || 0;
                continue;
            }
            tagRegex.lastIndex = 0;
            var match;
            var lastIdx = 0;
            var times = [];
            while ((match = tagRegex.exec(line)) !== null) {
                var m = parseInt(match[1], 10);
                var s = parseInt(match[2], 10);
                var ms = match[3] ? parseFloat("0." + match[3]) : 0.0;
                times.push(m * 60 + s + ms);
                lastIdx = tagRegex.lastIndex;
            }
            var rawBody = line.substring(lastIdx).trim();
            // Parse enhanced word timings <00:12.34> if present
            var enhancedWords = [];
            var wordTagRegex = /<(\d{1,3}):(\d{2})(?:[\.:](\d{1,3}))?>\s*([^<]+)/g;
            var wm;
            while ((wm = wordTagRegex.exec(rawBody)) !== null) {
                var wMin = parseInt(wm[1], 10);
                var wSec = parseInt(wm[2], 10);
                var wMs = wm[3] ? parseFloat("0." + wm[3]) : 0.0;
                var wTxt = wm[4].trim();
                if (wTxt.length > 0) {
                    enhancedWords.push({ time: wMin * 60 + wSec + wMs, text: wTxt });
                }
            }
            var txt = rawBody.replace(/<\d{1,3}:\d{2}(?:[\.:]\d{1,3})?>/g, "").trim();
            if (times.length > 0) {
                if (txt.length > 0) {
                    var roman = Romanize.romanizeLine(txt);
                    for (var t = 0; t < times.length; t++) {
                        parsed.push({ time: times[t], text: txt, roman: roman, words: enhancedWords });
                    }
                }
            } else if (line.charAt(0) !== "[") {
                plainParsed.push({ time: 0, text: line, roman: Romanize.romanizeLine(line), words: [] });
            }
        }

        if (parsed.length > 0) {
            var shift = offsetMs / 1000.0;
            if (shift !== 0) {
                for (var k = 0; k < parsed.length; k++) {
                    parsed[k].time = Math.max(0.0, parsed[k].time - shift);
                    for (var wj = 0; wj < parsed[k].words.length; wj++) {
                        parsed[k].words[wj].time = Math.max(0.0, parsed[k].words[wj].time - shift);
                    }
                }
            }
            parsed.sort(function(a, b) { return a.time - b.time; });
            // Fill proportional per-word timings when enhanced LRC tags are absent
            for (var pIdx = 0; pIdx < parsed.length; pIdx++) {
                if (!parsed[pIdx].words || parsed[pIdx].words.length === 0) {
                    var parts = parsed[pIdx].text.split(/\s+/);
                    var nextT = (pIdx + 1 < parsed.length) ? parsed[pIdx + 1].time : (parsed[pIdx].time + Math.max(2.0, parts.length * 0.45));
                    var span = Math.max(0.4, Math.min(nextT - parsed[pIdx].time, Math.max(1.8, parts.length * 0.55)));
                    var totalWeight = 0;
                    for (var wi = 0; wi < parts.length; wi++) totalWeight += Math.max(2, parts[wi].length);
                    var acc = 0;
                    var genWords = [];
                    for (var w2 = 0; w2 < parts.length; w2++) {
                        var wt = parsed[pIdx].time + (acc / Math.max(1, totalWeight)) * span;
                        genWords.push({ time: wt, text: parts[w2] });
                        acc += Math.max(2, parts[w2].length);
                    }
                    parsed[pIdx].words = genWords;
                }
            }
            root.lyricsLines = parsed;
            root.lyricsSynced = true;
            root.updateCurrentLyric();
        } else if (plainParsed.length > 0) {
            root.lyricsLines = plainParsed;
            root.lyricsSynced = false;
            root.currentLyricIndex = -1;
        } else {
            root.lyricsLines = [];
            root.lyricsSynced = false;
        }
    }

    function updateCurrentLyric() {
        if (!root.lyricsSynced || root.lyricsLines.length === 0) {
            root.currentLyricIndex = -1;
            root.currentLyricText = "";
            root.currentLyricRoman = "";
            return;
        }

        var pos = root.position;
        var idx = -1;
        for (var i = 0; i < root.lyricsLines.length; i++) {
            if (root.lyricsLines[i].time <= pos + 0.15) {
                idx = i;
            } else {
                break;
            }
        }

        if (idx !== root.currentLyricIndex) {
            root.currentLyricIndex = idx;
            if (idx >= 0 && idx < root.lyricsLines.length) {
                root.currentLyricText = root.lyricsLines[idx].text;
                root.currentLyricRoman = root.lyricsLines[idx].roman;
            } else {
                root.currentLyricText = "";
                root.currentLyricRoman = "";
            }
        }

        var wIdx = -1;
        if (idx >= 0 && idx < root.lyricsLines.length && root.lyricsLines[idx].words) {
            var wList = root.lyricsLines[idx].words;
            for (var wi = 0; wi < wList.length; wi++) {
                if (wList[wi].time <= pos + 0.15) {
                    wIdx = wi;
                } else {
                    break;
                }
            }
        }
        if (wIdx !== root.currentWordIndex) {
            root.currentWordIndex = wIdx;
        }
    }

    Timer {
        id: trackStartSyncTimer
        interval: 400
        repeat: false
        onTriggered: {
            if (!posSyncProc.running && root.activePlayer) {
                var pName = root.activePlayer.dbusName
                    ? root.activePlayer.dbusName.replace("org.mpris.MediaPlayer2.", "")
                    : "";
                posSyncProc.command = pName.length > 0
                    ? ["playerctl", "-p", pName, "position"]
                    : ["playerctl", "position"];
                posSyncProc.running = true;
            }
        }
    }

    onTitleChanged: checkFetchLyrics()
    onArtistChanged: checkFetchLyrics()
}
