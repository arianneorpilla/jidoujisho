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

import com.ichi2.anki.api.AddContentApi;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class MainActivity extends FlutterActivity {
    private static final String ANKIDROID_CHANNEL = "app.lrorpilla.yuuna/anki";
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

    private boolean deckExists(String deck) {
        Long deckId = mAnkiDroid.findDeckIdByName(deck);
        return (deckId != null);
    }

    private boolean modelExists(String model) {
        Long deckId = mAnkiDroid.findModelIdByName(model, 8);
        return (deckId != null);
    }

    public void addDefaultModel() {
        final AddContentApi api = new AddContentApi(context);

        long modelId;
        if (modelExists("jidoujisho Yuuna")) {
            modelId = mAnkiDroid.findModelIdByName("jidoujisho Yuuna", 8);
        } else {
            modelId = api.addNewCustomModel("jidoujisho Yuuna",
                new String[] {
                    "Sentence",
                    "Word",
                    "Reading",
                    "Meaning",
                    "Extra",
                    "Image",
                    "Audio",
                    "Context",
                },
                new String[] {
                    "jidoujisho Yuuna"
                },
                new String[] {"<p id=\"sentence\">{{Sentence}}</p><div id=\"word\">{{Word}}</div>"},
                    new String[] {"<p id=\"sentence\">{{Sentence}}</p><div id=\"word\">{{Word}}</div><br>{{Audio}}<div class=\"image\">{{Image}}</div><hr id=reading><p id=\"reading\">{{Reading}}</p><h2 id=\"word\">{{Word}}</h2><br><p><small id=\"meaning\">{{Meaning}}</small></p><br>{{#Context}}<a style=\"text-decoration:none;color:red;\" href=\"{{Context}}\">↩</a>{{/Context}}"},
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

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {

        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), ANKIDROID_CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    final String model = call.argument("model");
                    final AddContentApi api = new AddContentApi(context);

                    switch (call.method) {
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
                            break;
                        default:
                            result.notImplemented();
                    }
                }
            );
    }
}