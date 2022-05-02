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