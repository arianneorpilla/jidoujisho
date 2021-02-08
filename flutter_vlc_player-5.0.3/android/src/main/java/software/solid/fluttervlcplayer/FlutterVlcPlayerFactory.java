package software.solid.fluttervlcplayer;

import android.content.Context;
import android.util.LongSparseArray;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import io.flutter.view.TextureRegistry;

public class FlutterVlcPlayerFactory extends PlatformViewFactory {

    public interface KeyForAssetFn {
        String get(String asset);
    }

    public interface KeyForAssetAndPackageName {
        String get(String asset, String packageName);
    }

    private final BinaryMessenger messenger;
    private final TextureRegistry textureRegistry;
    private final KeyForAssetFn keyForAsset;
    private final KeyForAssetAndPackageName keyForAssetAndPackageName;
    //
    private FlutterVlcPlayerBuilder flutterVlcPlayerBuilder;

    public FlutterVlcPlayerFactory(BinaryMessenger messenger, TextureRegistry textureRegistry, KeyForAssetFn keyForAsset, KeyForAssetAndPackageName keyForAssetAndPackageName) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
        this.textureRegistry = textureRegistry;
        this.keyForAsset = keyForAsset;
        this.keyForAssetAndPackageName = keyForAssetAndPackageName;
        //
        flutterVlcPlayerBuilder = new FlutterVlcPlayerBuilder();
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
//        Map<String, Object> params = (Map<String, Object>) args;
        return flutterVlcPlayerBuilder.build(viewId, context, messenger, textureRegistry, keyForAsset, keyForAssetAndPackageName);
    }

    public void startListening() {
        flutterVlcPlayerBuilder.startListening(messenger);
    }

    public void stopListening() {
        flutterVlcPlayerBuilder.stopListening(messenger);
    }
}
