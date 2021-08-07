package com.lrorpilla.jidoujisho_experimental;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** Some fields to store configuration details for AnkiDroid **/
final class AnkiDroidConfig {
    // Name of deck which will be created in AnkiDroid
    public static final String DECK_NAME = "API Sample";
    // Name of model which will be created in AnkiDroid
    public static final String MODEL_NAME = "com.ichi2.apisample";
    // Optional space separated list of tags to add to every note
    public static final Set<String> TAGS = new HashSet<>(Collections.singletonList("API_Sample_App"));
    // List of field names that will be used in AnkiDroid model
    public static final String[] FIELDS = {"Expression","Reading","Meaning","Furigana","Grammar","Sentence",
            "SentenceFurigana","SentenceMeaning"};
    // List of card names that will be used in AnkiDroid (one for each direction of learning)
    public static final String[] CARD_NAMES = {"Japanese>English", "English>Japanese"};
    // CSS to share between all the cards (optional). User will need to install the NotoSans font by themselves
    public static final String CSS = ".card {\n" +
            " font-family: NotoSansJP;\n" +
            " font-size: 24px;\n" +
            " text-align: center;\n" +
            " color: black;\n" +
            " background-color: white;\n" +
            " word-wrap: break-word;\n" +
            "}\n" +
            "@font-face { font-family: \"NotoSansJP\"; src: url('_NotoSansJP-Regular.otf'); }\n" +
            "@font-face { font-family: \"NotoSansJP\"; src: url('_NotoSansJP-Bold.otf'); font-weight: bold; }\n" +
            "\n" +
            ".big { font-size: 48px; }\n" +
            ".small { font-size: 18px;}\n";
    // Template for the question of each card
    static final String QFMT1 = "<div class=big>{{Expression}}</div><br>{{Grammar}}";
    static final String QFMT2 = "{{Meaning}}<br><br><div class=small>{{Grammar}}<br><br>({{SentenceMeaning}})</div>";
    public static final String[] QFMT = {QFMT1, QFMT2};
    // Template for the answer (use identical for both sides)
    static final String AFMT1 = "<div class=big>{{furigana:Furigana}}</div><br>{{Meaning}}\n" +
            "<br><br>\n" +
            "{{furigana:SentenceFurigana}}<br>\n" +
            "<a href=\"#\" onclick=\"document.getElementById('hint').style.display='block';return false;\">Sentence Translation</a>\n" +
            "<div id=\"hint\" style=\"display: none\">{{SentenceMeaning}}</div>\n" +
            "<br><br>\n" +
            "{{Grammar}}<br><div class=small>{{Tags}}</div>";
    public static final String[] AFMT = {AFMT1, AFMT1};
    // Define two keys which will be used when using legacy ACTION_SEND intent
    public static final String FRONT_SIDE_KEY = FIELDS[0];
    public static final String BACK_SIDE_KEY = FIELDS[2];

    /**
     * Generate the ArrayList<HashMap> example data which will be sent to AnkiDroid
     */
    public static List<Map<String, String>> getExampleData() {
        final String[] EXAMPLE_WORDS = {"例", "データ", "送る"};
        final String[] EXAMPLE_READINGS = {"れい", "データ", "おくる"};
        final String[] EXAMPLE_TRANSLATIONS = {"Example", "Data", "To send"};
        final String[] EXAMPLE_FURIGANA = {"例[れい]", "データ", "送[おく]る"};
        final String[] EXAMPLE_GRAMMAR = {"P, adj-no, n, n-pref", "P, n", "P, v5r, vt"};
        final String[] EXAMPLE_SENTENCE = {"そんな先例はない。", "きゃ～データが消えた！", "放蕩生活を送る。"};
        final String[] EXAMPLE_SENTENCE_FURIGANA = {"そんな 先例[せんれい]はない。", "きゃ～データが 消[き]えた！",
                "放蕩[ほうとう] 生活[せいかつ]を 送[おく]る。"};
        final String[] EXAMPLE_SENTENCE_MEANING = {"We have no such example", "Oh, I lost the data！",
                "I lead a fast way of living."};

        List<Map<String, String>> data = new ArrayList<>();
        for (int idx = 0; idx < EXAMPLE_WORDS.length; idx++) {
            Map<String, String> hm = new HashMap<>();
            hm.put(FIELDS[0], EXAMPLE_WORDS[idx]);
            hm.put(FIELDS[1], EXAMPLE_READINGS[idx]);
            hm.put(FIELDS[2], EXAMPLE_TRANSLATIONS[idx]);
            hm.put(FIELDS[3], EXAMPLE_FURIGANA[idx]);
            hm.put(FIELDS[4], EXAMPLE_GRAMMAR[idx]);
            hm.put(FIELDS[5], EXAMPLE_SENTENCE[idx]);
            hm.put(FIELDS[6], EXAMPLE_SENTENCE_FURIGANA[idx]);
            hm.put(FIELDS[7], EXAMPLE_SENTENCE_MEANING[idx]);
            data.add(hm);
        }
        return data;
    }
}