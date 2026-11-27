pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // Hangul Jamo tables
    readonly property var initialJamo: ["g", "kk", "n", "d", "tt", "r", "m", "b", "pp", "s", "ss", "", "j", "jj", "ch", "k", "t", "p", "h"]
    readonly property var medialJamo: ["a", "ae", "ya", "yae", "eo", "e", "yeo", "ye", "o", "wa", "wae", "oe", "yo", "u", "wo", "we", "wi", "yu", "eu", "ui", "i"]
    readonly property var finalJamo: ["", "k", "k", "ks", "n", "nj", "nh", "t", "l", "lg", "lm", "lb", "ls", "lt", "lp", "lh", "m", "p", "ps", "s", "ss", "ng", "j", "ch", "k", "t", "p", "h"]

    // Hiragana map
    readonly property var kanaMap: ({
        "あ":"a","い":"i","う":"u","え":"e","お":"o",
        "か":"ka","き":"ki","く":"ku","け":"ke","こ":"ko",
        "さ":"sa","し":"shi","す":"su","せ":"se","そ":"so",
        "た":"ta","ち":"chi","つ":"tsu","て":"te","と":"to",
        "な":"na","に":"ni","ぬ":"nu","ね":"ne","の":"no",
        "は":"ha","ひ":"hi","ふ":"fu","へ":"he","ほ":"ho",
        "ま":"ma","み":"mi","む":"mu","め":"me","も":"mo",
        "や":"ya","ゆ":"yu","よ":"yo",
        "ら":"ra","り":"ri","る":"ru","れ":"re","ろ":"ro",
        "わ":"wa","を":"wo","ん":"n",
        "が":"ga","ぎ":"gi","ぐ":"gu","げ":"ge","ご":"go",
        "ざ":"za","じ":"ji","ず":"zu","ぜ":"ze","ぞ":"zo",
        "だ":"da","ぢ":"ji","づ":"zu","で":"de","ど":"do",
        "ば":"ba","び":"bi","ぶ":"bu","べ":"be","ぼ":"bo",
        "ぱ":"pa","ぴ":"pi","ぷ":"pu","ぺ":"pe","ぽ":"po",
        "きゃ":"kya","きゅ":"kyu","きょ":"kyo",
        "しゃ":"sha","しゅ":"shu","しょ":"sho",
        "ちゃ":"cha","ちゅ":"chu","ちょ":"cho",
        "にゃ":"nya","にゅ":"nyu","にょ":"nyo",
        "ひゃ":"hya","ひゅ":"hyu","ひょ":"hyo",
        "みゃ":"mya","みゅ":"myu","みょ":"myo",
        "りゃ":"rya","りゅ":"ryu","りょ":"ryo",
        "ぎゃ":"gya","ぎゅ":"gyu","ぎょ":"gyo",
        "じゃ":"ja","じゅ":"ju","じょ":"jo",
        "びゃ":"bya","びゅ":"byu","びょ":"byo",
        "ぴゃ":"pya","ぴゅ":"pyu","ぴょ":"pyo",
        "っか":"kka","っき":"kki","っく":"kku","っけ":"kke","っこ":"kko",
        "っさ":"ssa","っし":"sshi","っす":"ssu","っせ":"sse","っそ":"sso",
        "った":"tta","っち":"cchi","っつ":"ttsu","って":"tte","っと":"tto",
        "っぱ":"ppa","っぴ":"ppi","っぷ":"ppu","っぺ":"ppe","っぽ":"ppo",
        // Katakana
        "ア":"a","イ":"i","ウ":"u","エ":"e","オ":"o",
        "カ":"ka","キ":"ki","ク":"ku","ケ":"ke","コ":"ko",
        "サ":"sa","シ":"shi","ス":"su","セ":"se","ソ":"so",
        "タ":"ta","チ":"chi","ツ":"tsu","テ":"te","ト":"to",
        "ナ":"na","ニ":"ni","ヌ":"nu","ネ":"ne","ノ":"no",
        "ハ":"ha","ヒ":"hi","フ":"fu","ヘ":"he","ホ":"ho",
        "マ":"ma","ミ":"mi","ム":"mu","メ":"me","モ":"mo",
        "ヤ":"ya","ユ":"yu","ヨ":"yo",
        "ラ":"ra","リ":"ri","ル":"ru","レ":"re","ロ":"ro",
        "ワ":"wa","ヲ":"wo","ン":"n",
        "ガ":"ga","ギ":"gi","グ":"gu","ゲ":"ge","ゴ":"go",
        "ザ":"za","ジ":"ji","ズ":"zu","ゼ":"ze","ゾ":"zo",
        "ダ":"da","ヂ":"ji","ヅ":"zu","デ":"de","ド":"do",
        "バ":"ba","ビ":"bi","ブ":"bu","ベ":"be","ボ":"bo",
        "パ":"pa","ピ":"pi","プ":"pu","ペ":"pe","ポ":"po"
    })

    function isHangul(char) {
        var code = char.charCodeAt(0);
        return code >= 0xAC00 && code <= 0xD7A3;
    }

    function isKana(char) {
        var code = char.charCodeAt(0);
        return (code >= 0x3040 && code <= 0x309F) || (code >= 0x30A0 && code <= 0x30FF);
    }

    function isCJK(char) {
        var code = char.charCodeAt(0);
        return (code >= 0x4E00 && code <= 0x9FFF);
    }

    function romanizeHangulChar(char) {
        var code = char.charCodeAt(0) - 0xAC00;
        if (code < 0 || code > 11171) return char;
        var initial = Math.floor(code / (21 * 28));
        var medial = Math.floor((code % (21 * 28)) / 28);
        var finalC = code % 28;
        return initialJamo[initial] + medialJamo[medial] + finalJamo[finalC];
    }

    function romanizeHangul(text) {
        var out = "";
        for (var i = 0; i < text.length; i++) {
            var ch = text[i];
            if (isHangul(ch)) {
                out += romanizeHangulChar(ch);
            } else {
                out += ch;
            }
        }
        return out;
    }

    function romanizeKana(text) {
        var out = "";
        var i = 0;
        while (i < text.length) {
            if (i + 1 < text.length) {
                var doubleCh = text.substr(i, 2);
                if (kanaMap[doubleCh]) {
                    out += kanaMap[doubleCh];
                    i += 2;
                    continue;
                }
            }
            var singleCh = text[i];
            if (kanaMap[singleCh]) {
                out += kanaMap[singleCh];
            } else {
                out += singleCh;
            }
            i++;
        }
        return out;
    }

    function romanizeLine(text) {
        if (!text || text.trim().length === 0) return "";
        var hasHangul = false;
        var hasKana = false;
        var hasHan = false;

        for (var i = 0; i < text.length; i++) {
            var ch = text[i];
            if (isHangul(ch)) hasHangul = true;
            else if (isKana(ch)) hasKana = true;
            else if (isCJK(ch)) hasHan = true;
        }

        if (!hasHangul && !hasKana && !hasHan) {
            return ""; // No romanization needed
        }

        if (hasHangul) {
            return romanizeHangul(text);
        }

        if (hasKana) {
            return romanizeKana(text);
        }

        return "";
    }
}
