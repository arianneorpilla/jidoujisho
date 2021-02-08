package software.solid.fluttervlcplayer;

import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

public class FlutterVlcPlayerPlugin implements FlutterPlugin, ActivityAware {

    private static FlutterVlcPlayerFactory flutterVlcPlayerFactory;
    private FlutterPluginBinding flutterPluginBinding;

    private static final String VIEW_TYPE = "flutter_video_plugin/getVideoView";

    public FlutterVlcPlayerPlugin() {
    }

    @SuppressWarnings("deprecation")
    public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
        flutterVlcPlayerFactory =
                new FlutterVlcPlayerFactory(
                        registrar.messenger(),
                        registrar.textures(),
                        registrar::lookupKeyForAsset,
                        registrar::lookupKeyForAsset
                );
        registrar
                .platformViewRegistry()
                .registerViewFactory(
                        VIEW_TYPE,
                        flutterVlcPlayerFactory
                );
        registrar.addViewDestroyListener(view -> {
            stopListening();
            return false;
        });
        //
        startListening();
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        flutterPluginBinding = binding;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        flutterPluginBinding = null;
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        final FlutterInjector injector = FlutterInjector.instance();
        //
        flutterVlcPlayerFactory =
                new FlutterVlcPlayerFactory(
                        flutterPluginBinding.getBinaryMessenger(),
                        flutterPluginBinding.getTextureRegistry(),
                        injector.flutterLoader()::getLookupKeyForAsset,
                        injector.flutterLoader()::getLookupKeyForAsset
                );
        flutterPluginBinding
                .getPlatformViewRegistry()
                .registerViewFactory(
                        VIEW_TYPE,
                        flutterVlcPlayerFactory
                );
        //
        startListening();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        stopListening();
    }

    // extra methods

    private static void startListening() {
        if (flutterVlcPlayerFactory != null)
            flutterVlcPlayerFactory.startListening();
    }

    private static void stopListening() {
        if (flutterVlcPlayerFactory != null)
            flutterVlcPlayerFactory.stopListening();
    }
}
