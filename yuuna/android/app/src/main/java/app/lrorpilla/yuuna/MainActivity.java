// Derived from the AnkiDroid API Sample

package app.lrorpilla.yuuna;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.NonNull;
import android.net.Uri;

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
import java.util.List;
import java.util.Set;

import java.io.File;

import com.ichi2.anki.api.NoteInfo;
import com.ryanheise.audioservice.AudioServiceActivity;
import android.content.res.Configuration;

public class MainActivity extends AudioServiceActivity {
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
            modelId = mAnkiDroid.findModelIdByName("jidoujisho Yuuna", 12);
        } else {
            modelId = api.addNewCustomModel("jidoujisho Yuuna",
                new String[] {
                    "Term", 
                    "Sentence",
                    "Reading",
                    "Meaning",
                    "Notes",
                    "Image",
                    "Term Audio",
                    "Pitch Accent",
                    "Furigana",
                    "Expanded Meaning",
                    "Collapsed Meaning",
                    "Sentence Audio",
                },
                new String[] {
                    "jidoujisho Yuuna"
                },
                new String[] {
                    "<div id=\"word\">{{Term}}</div>"
                },
                new String[] {
                    "<div id=\"word\">{{furigana:Furigana}}</div>{{#Pitch Accent}}{{Pitch Accent}}{{/Pitch Accent}}\n{{#Meaning}}<p><small>{{furigana:Meaning}}</small></p>{{/Meaning}}\n{{#Expanded Meaning}}<p><small>{{furigana:Expanded Meaning}}</small></p>{{/Expanded Meaning}}{{#Collapsed Meaning}}<details><summary></summary><p><small>{{furigana:Collapsed Meaning}}</small></p></details><br>\n{{/Collapsed Meaning}}\n{{#Image}}<div class=\"image\">{{Image}}</div>{{/Image}}\n{{#Term Audio}}{{Term Audio}}{{/Term Audio}}{{#Sentence Audio}}{{Sentence Audio}}{{/Sentence Audio}}<br><div id=\"sentence\">{{Sentence}}</div>"
                },
                ".card {\n  font-family: \"Helvetica Neue\", Arial, sans-serif;\n  font-size: 16px;\n  text-align: center;\n  color: #333333;\n  background-color: #F6F6F6;\n  border-radius: 12px;\n  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.2);\n  padding: 24px;\n  margin: 12px;\n  border: 1px solid #D9D9D9;\n}\n\n#word {\n  font-size: 30px;\n  font-weight: bold;\n  margin-bottom: 16px;\n}\n\n.details-summary {\n  cursor: pointer;\n  font-size: 16px;\n  text-shadow: 1px 1px #ffffff;\n  display: flex;\n  justify-content: space-between;\n  align-items: center;\n  margin-bottom: 16px;\n}\n\n.details-summary:hover {\n  color: #6495ED;\n}\n\n.details-summary:hover .arrow {\n  transform: translateX(4px);\n}\n\n.arrow {\n  fill: #777777;\n  transition: transform 0.2s ease-in-out;\n  margin-right: 8px;\n}\n\n.image img {\n  max-width: 100%;\n  height: auto;\n  border-radius: 12px;\n  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.2);\n  margin-top: 16px;\n  margin-bottom: 16px;\n  transition: transform 0.2s ease-in-out;\n}\n\n.image:hover img {\n  transform: scale(1.05);\n}\n\n.furigana {\n  font-size: 22px;\n  font-weight: bold;\n  line-height: 1.4;\n  margin-bottom: 16px;\n  text-shadow: 1px 1px #ffffff;\n}\n\n.meaning {\n  font-size: 18px;\n  line-height: 1.6;\n  margin-bottom: 16px;\n  text-shadow: 1px 1px #ffffff;\n}\n\n#sentence {\n  font-size: 20px;\n  line-height: 1.6;\n  margin-top: 8px;\n  margin-bottom: 8px;\n} \n\n.pitch{\n  border-top: solid red 2px;\n  padding-top: 1px;\n}\n\n.pitch_end{\n  border-color: red;\n  border-right: solid red 2px;\n  border-top: solid red 2px;  \n  line-height: 1px;\n  margin-right: 1px;\n  padding-right: 1px;\n  padding-top:1px;\n}",
                    null,
                    null
                    );
        }
    }

    private boolean checkForDuplicates(String model, Integer numFields, String key) {
        final AddContentApi api = new AddContentApi(context);
        long modelId = mAnkiDroid.findModelIdByName(model, numFields);

        List<NoteInfo> notes = api.findDuplicateNotes(modelId, key);
        return !notes.isEmpty();
    }

    private void addNote(String model, String deck, ArrayList<String> fields, ArrayList<String> tags) {
        final AddContentApi api = new AddContentApi(context);

        long deckId;
        if (deckExists(deck)) {
            deckId = mAnkiDroid.findDeckIdByName(deck);
        } else {
            deckId = api.addNewDeck(deck);
        }

        long modelId = mAnkiDroid.findModelIdByName(model, fields.size());
       
        Set<String> allTags = new HashSet<>(Arrays.asList("Yuuna"));
        allTags.addAll(tags);

        api.addNote(modelId, deckId, fields.toArray(new String[fields.size()]), allTags);

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
                    final String key = call.argument("key");
                    final Integer numFields = call.argument("numFields");
                    final ArrayList<String> fields = call.argument("fields"); 
                    final ArrayList<String> tags = call.argument("tags"); 

                    final String filename = call.argument("filename");
                    final String preferredName = call.argument("preferredName");
                    final String mimeType = call.argument("mimeType");

                    final AddContentApi api = new AddContentApi(context);

                    switch (call.method) {
                        case "addNote":
                            addNote(model, deck, fields, tags);
                            result.success("Added note");
                            break;
                        case "checkForDuplicates":
                            result.success(checkForDuplicates(model, numFields, key));
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
