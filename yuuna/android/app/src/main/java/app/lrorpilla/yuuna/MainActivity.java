// Derived from the AnkiDroid API Sample

package app.lrorpilla.yuuna;

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

import com.ichi2.anki.FlashCardsContract;
import com.ichi2.anki.api.AddContentApi;
import android.content.ContentValues;
import androidx.core.content.FileProvider;
import android.content.ContentResolver;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

public class MainActivity extends FlutterActivity {
    private static final String ANKIDROID_CHANNEL = "app.lrorpilla.yuuna/anki";
    private static final int AD_PERM_REQUEST = 0;

    private Activity context;
    private AnkiDroidHelper mAnkiDroid;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        isAppRunning = false;
        
        context = MainActivity.this;
        // Create the example data
        mAnkiDroid = new AnkiDroidHelper(context);
    }

    private boolean deckExists(String deck) {
        Long deckId = mAnkiDroid.findDeckIdByName(deck);
        return (deckId != null);
    }

    private boolean modelExists(String model) {
        Long deckId = mAnkiDroid.findModelIdByName(model, 8);
        return (deckId != null);
    }

    private static boolean isAppRunning;

    public static boolean getIsAppRunning() {
        return isAppRunning;
    }

    public void addDefaultModel() {
        final AddContentApi api = new AddContentApi(context);

        long modelId;
        if (modelExists("jidoujisho Yuuna")) {
            modelId = mAnkiDroid.findModelIdByName("jidoujisho Yuuna", 11);
        } else {
            modelId = api.addNewCustomModel("jidoujisho Yuuna",
                new String[] {
                    "Sentence",
                    "Term",
                    "Reading",
                    "Meaning",
                    "Notes",
                    "Image",
                    "Audio",
                    "Pitch Accent",
                    "Furigana",
                    "Expanded Meaning",
                    "Collapsed Meaning",
                },
                new String[] {
                    "jidoujisho Yuuna"
                },
                new String[] {"<div id=\"word\">{{Term}}</div><hr><p id=\"sentence\">{{Sentence}}"},
                    new String[] {"<div id=\"word\">{{Term}}</div><hr><p id=\"sentence\">{{Sentence}}</p><br>{{#Audio}}[sound:{{Audio}}]{{/Audio}}{{#Image}}<div class=\"image\"><img src=\"{{Image}}\"></div>{{/Image}}{{#Pitch Accent}}<br>{{Pitch Accent}}<br>{{/Pitch Accent}}<br><h2 id=\"word\">{{furigana:Furigana}}</h2><br>{{#Meaning}}<p><small id=\"meaning\">{{Meaning}}</p </small><br>{{/Meaning}}{{#Expanded Meaning}}<p><small id=\"meaning\">{{Expanded Meaning}}</small></p>{{/Expanded Meaning}}<br>{{#Collapsed Meaning}}<details><summary></summary><br><p><small id=\"meaning\">{{Collapsed Meaning}}</small></p><br></details>{{/Collapsed Meaning}}"},
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
                            "  text-align: center;\n" +
                            "  color: black;\n" +
                            "  background-color: white;\n" +
                            "  white-space: pre-line;\n" +
                            "}\n" +
                            "\n" +
                            "#sentence {\n" +
                            "    font-size: 30px\n" +
                            "}\n" +
                            "\n" +
                            ".context.night_mode {\n" + 
                            "    text-decoration: none;\n" +
                            "    color: red;\n" +
                            "}\n" +
                            ".context {\n" +
                            "    text-decoration: none;\n" +
                            "    color: red;\n" +
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
    }

    private void addNote(String model, String deck, ArrayList<String> fields) {
        final AddContentApi api = new AddContentApi(context);

        long deckId;
        if (deckExists(deck)) {
            deckId = mAnkiDroid.findDeckIdByName(deck);
        } else {
            deckId = api.addNewDeck(deck);
        }

        long modelId = mAnkiDroid.findModelIdByName(model, fields.size());
       
        Set<String> tags = new HashSet<>(Arrays.asList("Yuuna"));

        api.addNote(modelId, deckId, fields.toArray(new String[fields.size()]), tags);

        System.out.println("Added note via flutter_ankidroid_api");
        System.out.println("Model: " + modelId);
        System.out.println("Deck: " + deckId);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {

        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), ANKIDROID_CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    final String model = call.argument("model");
                    final String deck = call.argument("deck");
                    final ArrayList<String> fields = call.argument("fields"); 

                    final String filename = call.argument("filename");
                    final String preferredName = call.argument("preferredName");
                    final String mimeType = call.argument("mimeType");

                    final AddContentApi api = new AddContentApi(context);

                    switch (call.method) {
                        case "addNote":
                            addNote(model, deck, fields);
                            result.success("Added note");
                            break;
                        case "getDecks":
                            result.success(api.getDeckList());
                            break;
                        case "getModelList":
                            result.success(api.getModelList());
                            break;
                        case "getFieldList":
                            Long mid = mAnkiDroid.findModelIdByName(model, 1);
                            result.success(Arrays.asList(api.getFieldList(mid)));
                            break;
                        case "addDefaultModel":
                            addDefaultModel();
                            break;
                        case "requestAnkidroidPermissions":
                            if (mAnkiDroid.shouldRequestPermission()) {
                                mAnkiDroid.requestPermission(MainActivity.this, AD_PERM_REQUEST);
                            }
                            result.success(true);
                            break;
                        case "addFileToMedia":
                            System.out.println(filename);
                            System.out.println(preferredName);
                            System.out.println(mimeType);

                            // Workaround from KamWithK
                            // https://github.com/ankidroid/Anki-Android/issues/10335
  
                            File file = new File(filename);

                            Uri file_uri = FileProvider.getUriForFile(context, BuildConfig.APPLICATION_ID + ".provider", file);
                            context.grantUriPermission("com.ichi2.anki", file_uri, Intent.FLAG_GRANT_READ_URI_PERMISSION);

                            ContentValues contentValues = new ContentValues();
                            contentValues.put(FlashCardsContract.AnkiMedia.FILE_URI, file_uri.toString());
                            contentValues.put(FlashCardsContract.AnkiMedia.PREFERRED_NAME, preferredName);

                            ContentResolver contentResolver = context.getContentResolver();
                            Uri returnUri = contentResolver.insert(FlashCardsContract.AnkiMedia.CONTENT_URI, contentValues);

                            result.success(new File(returnUri.getPath()).toString().substring(1));

                            break;
                        default:
                            result.notImplemented();
                    }
                }
            );
    }
}