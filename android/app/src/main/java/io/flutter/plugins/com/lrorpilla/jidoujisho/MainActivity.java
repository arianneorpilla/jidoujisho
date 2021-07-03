// Derived from the AnkiDroid API Sample

package com.lrorpilla.jidoujisho;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.app.ShareCompat;
import android.util.Log;
import android.util.SparseBooleanArray;
import android.view.ActionMode;
import android.view.ActionProvider;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.SubMenu;
import android.view.View;
import android.widget.AbsListView;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.Toast;
import android.net.Uri;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import com.ichi2.anki.api.AddContentApi;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;


public class MainActivity extends FlutterActivity {
    private static final String ANKIDROID_CHANNEL = "com.lrorpilla.api/ankidroid";
    private static final String YOUTUDEDL_CHANNEL = "flutter_youtube_dl/nativelibdir";

    private static final int AD_PERM_REQUEST = 0;

    private Activity context;
    private AnkiDroidHelper mAnkiDroid;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        context = MainActivity.this;
        // Create the example data
        mAnkiDroid = new AnkiDroidHelper(context);
    }

    private void addCreatorNote(String deck, String image, String audio, String sentence, String word, String meaning, String reading) {
        final AddContentApi api = new AddContentApi(context);

        long deckId;
        if (deckExists(deck)) {
            deckId = mAnkiDroid.findDeckIdByName(deck);
        } else {
            deckId = api.addNewDeck(deck);
        }

        long modelId;
        if (modelExists("jidoujisho (Creator)")) {
            modelId = mAnkiDroid.findModelIdByName("jidoujisho (Creator)", 6);
        } else {
            modelId = api.addNewCustomModel("jidoujisho (Creator)",
                    new String[] {"Image", "Audio", "Sentence", "Word", "Meaning", "Reading"},
                    new String[] {"jidoujisho (Creator) Default"},
                    new String[] {"{{Audio}}<div class=\"image\">{{Image}}</div><br><p id=\"sentence\">{{Sentence}}</p><div id=\"word\">{{Word}}</div>"},
                    new String[] {"{{Audio}}<div class=\"image\">{{Image}}</div><br><p id=\"sentence\">{{Sentence}}</p><div id=\"word\">{{Word}}</div>" +
                            "<hr><p id=\"reading\">{{Reading}}</p><h2 id=\"word\">{{Word}}</h2><br><p><small id=\"meaning\">{{Meaning}}</small></p><br>"},
                            "p {\n" +
                            "    margin: 0px\n" +
                            "}\n" +
                            "\n" +
                            "h2 {\n" +
                            "    margin: 0px\n" +
                            "}\n" +
                            "\n" +
                            "small {\n" +
                            "    margin: 0px\n" +
                            "}\n" +
                            "\n" +
                            ".card {\n" +
                            "  font-family: arial;\n" +
                            "  font-size: 20px;\n" +
                            "  white-space: pre-line;\n" +
                            "  text-align: center;\n" +
                            "  color: black;\n" +
                            "  background-color: white;\n" +
                            "}\n" +
                            "\n" +
                            "#sentence {\n" +
                            "    font-size: 30px\n" +
                            "}\n" +
                            "\n" +
                            ".image img {\n" +
                            "  position: static;\n" +
                            "  height: auto;\n" +
                            "  width: auto;\n" +
                            "  max-height: 400px;\n" +
                            "}\n" +
                            ".pitch{\n" +
                            "  border-top: solid red 2px;\n" +
                            "  padding-top: 1px;\n" +
                            "}\n" +
                            "\n" +
                            ".pitch_end{\n" +
                            "  border-color: red;\n" +
                            "  border-right: solid red 2px;\n" +
                            "  border-top: solid red 2px;  \n" +
                            "  line-height: 1px;\n" +
                            "  margin-right: 1px;\n" +
                            "  padding-right: 1px;\n" +
                            "  padding-top:1px;\n" +
                            "}",
                    null,
                    null
                    );
        }

        Set<String> tags = new HashSet<>(Arrays.asList("jidoujisho"));

        api.addNote(modelId, deckId, new String[] {image, audio, sentence, word, meaning, reading}, tags);

        System.out.println("Added note via flutter_ankidroid_api");
        System.out.println("Model: " + modelId);
        System.out.println("Deck: " + deckId);
    }

    private void addNote(String deck, String image, String audio, String sentence, String word, String meaning, String reading) {
        final AddContentApi api = new AddContentApi(context);

        long deckId;
        if (deckExists(deck)) {
            deckId = mAnkiDroid.findDeckIdByName(deck);
        } else {
            deckId = api.addNewDeck(deck);
        }

        long modelId;
        if (modelExists("jidoujisho")) {
            modelId = mAnkiDroid.findModelIdByName("jidoujisho", 6);
        } else {
            modelId = api.addNewCustomModel("jidoujisho",
                    new String[] {"Image", "Audio", "Sentence", "Word", "Meaning", "Reading"},
                    new String[] {"jidoujisho Default"},
                    new String[] {"<p id=\"sentence\">{{Sentence}}</p><div id=\"word\">{{Word}}</div>"},
                    new String[] {"<p id=\"sentence\">{{Sentence}}</p><div id=\"word\">{{Word}}</div><br>{{Audio}}<div class=\"image\">{{Image}}</div>" +
                    "<hr id=reading><p id=\"reading\">{{Reading}}</p><h2 id=\"word\">{{Word}}</h2><br><p><small id=\"meaning\">{{Meaning}}</small></p>"},
                            "p {\n" +
                            "    margin: 0px\n" +
                            "}\n" +
                            "\n" +
                            "h2 {\n" +
                            "    margin: 0px\n" +
                            "}\n" +
                            "\n" +
                            "small {\n" +
                            "    margin: 0px\n" +
                            "}\n" +
                            "\n" +
                            ".card {\n" +
                            "  font-family: arial;\n" +
                            "  font-size: 20px;\n" +
                            "  white-space: pre-line;\n" +
                            "  text-align: center;\n" +
                            "  color: black;\n" +
                            "  background-color: white;\n" +
                            "}\n" +
                            "\n" +
                            "#sentence {\n" +
                            "    font-size: 30px\n" +
                            "}\n" +
                            "\n" +
                            ".image img {\n" +
                            "  position: static;\n" +
                            "  height: auto;\n" +
                            "  width: auto;\n" +
                            "  max-height: 250px;\n" +
                            "}\n" +
                            ".pitch{\n" +
                            "  border-top: solid red 2px;\n" +
                            "  padding-top: 1px;\n" +
                            "}\n" +
                            "\n" +
                            ".pitch_end{\n" +
                            "  border-color: red;\n" +
                            "  border-right: solid red 2px;\n" +
                            "  border-top: solid red 2px;  \n" +
                            "  line-height: 1px;\n" +
                            "  margin-right: 1px;\n" +
                            "  padding-right: 1px;\n" +
                            "  padding-top:1px;\n" +
                            "}",
                    null,
                    null
                    );
        }

        Set<String> tags = new HashSet<>(Arrays.asList("jidoujisho"));

        api.addNote(modelId, deckId, new String[] {image, audio, sentence, word, meaning, reading}, tags);

        System.out.println("Added note via flutter_ankidroid_api");
        System.out.println("Model: " + modelId);
        System.out.println("Deck: " + deckId);
    }

    private void addReaderNote(String deck, String image, String audio, String sentence, String word, String meaning, String reading) {
        final AddContentApi api = new AddContentApi(context);

        long deckId;
        if (deckExists(deck)) {
            deckId = mAnkiDroid.findDeckIdByName(deck);
        } else {
            deckId = api.addNewDeck(deck);
        }

        long modelId;
        if (modelExists("jidoujisho (Reader)")) {
            modelId = mAnkiDroid.findModelIdByName("jidoujisho (Reader)", 6);
        } else {
            modelId = api.addNewCustomModel("jidoujisho (Reader)",
                    new String[] {"Image", "Audio", "Sentence", "Word", "Meaning", "Reading"},
                    new String[] {"jidoujisho (Reader) Default"},
                    new String[] {"<p id=\"sentence\">{{Sentence}}</p><div id=\"word\">{{Word}}</div>"},
                    new String[] {"<p id=\"sentence\">{{Sentence}}</p><div id=\"word\">{{Word}}</div><br>{{Audio}}<div class=\"image\">{{Image}}</div>" +
                            "<hr id=reading><p id=\"reading\">{{Reading}}</p><h2 id=\"word\">{{Word}}</h2><br><p><small id=\"meaning\">{{Meaning}}</small></p>"},
                            "p {\n" +
                            "    margin: 0px\n" +
                            "}\n" +
                            "\n" +
                            "h2 {\n" +
                            "    margin: 0px\n" +
                            "}\n" +
                            "\n" +
                            "small {\n" +
                            "    margin: 0px\n" +
                            "}\n" +
                            "\n" +
                            ".card {\n" +
                            "  font-family: arial;\n" +
                            "  font-size: 20px;\n" +
                            "  white-space: pre-line;\n" +
                            "  text-align: center;\n" +
                            "  color: black;\n" +
                            "  background-color: white;\n" +
                            "}\n" +
                            "\n" +
                            "#sentence {\n" +
                            "    font-size: 30px\n" +
                            "}\n" +
                            "\n" +
                            ".image img {\n" +
                            "  position: static;\n" +
                            "  height: auto;\n" +
                            "  width: auto;\n" +
                            "  max-height: 250px;\n" +
                            "}\n" +
                            ".pitch{\n" +
                            "  border-top: solid red 2px;\n" +
                            "  padding-top: 1px;\n" +
                            "}\n" +
                            "\n" +
                            ".pitch_end{\n" +
                            "  border-color: red;\n" +
                            "  border-right: solid red 2px;\n" +
                            "  border-top: solid red 2px;  \n" +
                            "  line-height: 1px;\n" +
                            "  margin-right: 1px;\n" +
                            "  padding-right: 1px;\n" +
                            "  padding-top:1px;\n" +
                            "}",
                    null,
                    null
                    );
        }

        Set<String> tags = new HashSet<>(Arrays.asList("jidoujisho"));

        api.addNote(modelId, deckId, new String[] {image, audio, sentence, word, meaning, reading}, tags);

        System.out.println("Added note via flutter_ankidroid_api");
        System.out.println("Model: " + modelId);
        System.out.println("Deck: " + deckId);
    }

    private boolean deckExists(String deck) {
        Long deckId = mAnkiDroid.findDeckIdByName(deck);
        return (deckId != null);
    }

    private boolean modelExists(String model) {
        Long deckId = mAnkiDroid.findModelIdByName(model, 6);
        return (deckId != null);
    }

    /**
     * get the deck id
     * @return might be null if there was a problem
     */
    private Long getDeckId() {
        Long did = mAnkiDroid.findDeckIdByName(AnkiDroidConfig.DECK_NAME);
        if (did == null) {
            did = mAnkiDroid.getApi().addNewDeck(AnkiDroidConfig.DECK_NAME);
            mAnkiDroid.storeDeckReference(AnkiDroidConfig.DECK_NAME, did);
        }
        return did;
    }

    /**
     * get model id
     * @return might be null if there was an error
     */
    private Long getModelId() {
        Long mid = mAnkiDroid.findModelIdByName(AnkiDroidConfig.MODEL_NAME, AnkiDroidConfig.FIELDS.length);
        if (mid == null) {
            mid = mAnkiDroid.getApi().addNewCustomModel(AnkiDroidConfig.MODEL_NAME, AnkiDroidConfig.FIELDS,
                    AnkiDroidConfig.CARD_NAMES, AnkiDroidConfig.QFMT, AnkiDroidConfig.AFMT, AnkiDroidConfig.CSS, getDeckId(), null);
            mAnkiDroid.storeModelReference(AnkiDroidConfig.MODEL_NAME, mid);
        }
        return mid;
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), ANKIDROID_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            final String deck = call.argument("deck");
                            final String image = call.argument("image");
                            final String audio = call.argument("audio");
                            final String sentence = call.argument("sentence");
                            final String answer = call.argument("answer");
                            final String meaning = call.argument("meaning");
                            final String reading = call.argument("reading");

                            final String fileUriPath = call.argument("fileUriPath");
                            final String preferredName = call.argument("preferredName");
                            final String mimeType = call.argument("mimeType");
                            final AddContentApi api = new AddContentApi(context);

                            switch (call.method) {
                                case "addNote":
                                    addNote(deck, image, audio, sentence, answer, meaning, reading);
                                    break;
                                case "addCreatorNote":
                                    addCreatorNote(deck, image, audio, sentence, answer, meaning, reading);
                                    break;
                                case "addReaderNote":
                                    addReaderNote(deck, image, audio, sentence, answer, meaning, reading);
                                    break;
                                case "getDecks":
                                    result.success(api.getDeckList());
                                    break;
                                case "requestPermissions":
                                    if (mAnkiDroid.shouldRequestPermission()) {
                                        mAnkiDroid.requestPermission(MainActivity.this, AD_PERM_REQUEST);
                                    }
                                    break;
                                case "addMediaFromUri":
                                    System.out.println(fileUriPath);
                                    System.out.println(preferredName);
                                    System.out.println(mimeType);
                                    Uri fileUri = Uri.parse(fileUriPath);
                                    
                                    try {
                                        String addedFileName = api.addMediaFromUri(fileUri, preferredName, mimeType);
                                        result.success(addedFileName);
                                        System.out.println("Added media from URI");
                                    } catch (Exception e) {
                                        System.out.println(e);
                                    }
                                    
                                    
                                    break;
                                default:
                                    result.notImplemented();
                            }
                        }

                );

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), YOUTUDEDL_CHANNEL)
        .setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "getNativeDir":
                            result.success(getApplicationContext().getApplicationInfo().nativeLibraryDir);
                            break;
                        default:
                            result.notImplemented();
                    }
                }

        );
    }
}