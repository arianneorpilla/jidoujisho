package software.solid.fluttervlcplayer;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.os.Build;
import android.util.LongSparseArray;

import androidx.annotation.RequiresApi;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.view.TextureRegistry;
import software.solid.fluttervlcplayer.Enums.DataSourceType;

public class FlutterVlcPlayerBuilder implements Messages.VlcPlayerApi {

    private final LongSparseArray<FlutterVlcPlayer> vlcPlayers = new LongSparseArray<>();
    private FlutterVlcPlayerFactory.KeyForAssetFn keyForAsset;
    private FlutterVlcPlayerFactory.KeyForAssetAndPackageName keyForAssetAndPackageName;

    void startListening(BinaryMessenger messenger) {
        Messages.VlcPlayerApi.setup(messenger, this);
    }

    void stopListening(BinaryMessenger messenger) {
//        disposeAllPlayers();
        Messages.VlcPlayerApi.setup(messenger, null);
    }

    FlutterVlcPlayer build(int viewId, Context context, BinaryMessenger binaryMessenger, TextureRegistry textureRegistry, FlutterVlcPlayerFactory.KeyForAssetFn keyForAsset, FlutterVlcPlayerFactory.KeyForAssetAndPackageName keyForAssetAndPackageName) {
        this.keyForAsset = keyForAsset;
        this.keyForAssetAndPackageName = keyForAssetAndPackageName;
        // only create view for player and attach channel events
        FlutterVlcPlayer vlcPlayer = new FlutterVlcPlayer(viewId, context, binaryMessenger, textureRegistry);
        vlcPlayers.append(viewId, vlcPlayer);
        return vlcPlayer;
    }

    private void disposeAllPlayers() {
        for (int i = 0; i < vlcPlayers.size(); i++) {
            vlcPlayers.valueAt(i).dispose();
        }
        vlcPlayers.clear();

    }

    @Override
    public void initialize() {
//        disposeAllPlayers();
    }

    @Override
    public void create(Messages.CreateMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        //
        ArrayList<String> options = new ArrayList<String>();
        if (arg.getOptions().size() > 0)
            for (Object option : arg.getOptions())
                options.add((String) option);
        player.initialize(options);
        //
        String mediaUrl;
        boolean isAssetUrl;
        if (arg.getType() == DataSourceType.ASSET.getNumericType()) {
            String assetLookupKey;
            if (arg.getPackageName() != null)
                assetLookupKey = keyForAssetAndPackageName.get(arg.getUri(), arg.getPackageName());
            else
                assetLookupKey = keyForAsset.get(arg.getUri());
            mediaUrl = assetLookupKey;
            isAssetUrl = true;
        } else {
            mediaUrl = arg.getUri();
            isAssetUrl = false;
        }
        player.setStreamUrl(mediaUrl, isAssetUrl, arg.getAutoPlay(), arg.getHwAcc());
    }

    @Override
    public void dispose(Messages.TextureMessage arg) {
        // the player has been already disposed by platform we just remove it from players list
        vlcPlayers.remove(arg.getTextureId());
    }

    @Override
    public void setStreamUrl(Messages.SetMediaMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        //
        boolean isAssetUrl;
        String mediaUrl;
        if (arg.getType() == DataSourceType.ASSET.getNumericType()) {
            String assetLookupKey;
            if (arg.getPackageName() != null)
                assetLookupKey = keyForAssetAndPackageName.get(arg.getUri(), arg.getPackageName());
            else
                assetLookupKey = keyForAsset.get(arg.getUri());
            mediaUrl = assetLookupKey;
            isAssetUrl = true;
        } else {
            mediaUrl = arg.getUri();
            isAssetUrl = false;
        }
        player.setStreamUrl(mediaUrl, isAssetUrl, arg.getAutoPlay(), arg.getHwAcc());
    }

    @Override
    public void play(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.play();
    }

    @Override
    public void pause(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.pause();
    }

    @Override
    public void stop(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.stop();
    }

    @Override
    public Messages.BooleanMessage isPlaying(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.BooleanMessage message = new Messages.BooleanMessage();
        message.setResult(player.isPlaying());
        return message;
    }

    @Override
    public void setLooping(Messages.LoopingMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.setLooping(arg.getIsLooping());
    }

    @Override
    public void seekTo(Messages.PositionMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.seekTo(arg.getPosition().intValue());
    }

    @Override
    public Messages.PositionMessage position(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.PositionMessage message = new Messages.PositionMessage();
        message.setPosition(player.getPosition());
        return message;
    }

    @Override
    public Messages.DurationMessage duration(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.DurationMessage message = new Messages.DurationMessage();
        message.setDuration(player.getDuration());
        return message;
    }

    @Override
    public void setVolume(Messages.VolumeMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.setVolume(arg.getVolume());
    }

    @Override
    public Messages.VolumeMessage getVolume(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.VolumeMessage message = new Messages.VolumeMessage();
        message.setVolume((long) player.getVolume());
        return message;
    }

    @Override
    public void setPlaybackSpeed(Messages.PlaybackSpeedMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.setPlaybackSpeed(arg.getSpeed());
    }

    @Override
    public Messages.PlaybackSpeedMessage getPlaybackSpeed(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.PlaybackSpeedMessage message = new Messages.PlaybackSpeedMessage();
        message.setSpeed((double) player.getPlaybackSpeed());
        return message;
    }

    @Override
    public Messages.SnapshotMessage takeSnapshot(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.SnapshotMessage message = new Messages.SnapshotMessage();
        message.setSnapshot(player.getSnapshot());
        return message;
    }

    @Override
    public Messages.TrackCountMessage getSpuTracksCount(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.TrackCountMessage message = new Messages.TrackCountMessage();
        message.setCount((long) player.getSpuTracksCount());
        return message;
    }

    @Override
    public Messages.SpuTracksMessage getSpuTracks(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.SpuTracksMessage message = new Messages.SpuTracksMessage();
        message.setSubtitles(player.getSpuTracks());
        return message;
    }

    @Override
    public void setSpuTrack(Messages.SpuTrackMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.setSpuTrack(arg.getSpuTrackNumber().intValue());
    }

    @Override
    public Messages.SpuTrackMessage getSpuTrack(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.SpuTrackMessage message = new Messages.SpuTrackMessage();
        message.setSpuTrackNumber((long) player.getSpuTrack());
        return message;
    }

    @Override
    public void setSpuDelay(Messages.DelayMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.setSpuDelay(arg.getDelay());
    }

    @Override
    public Messages.DelayMessage getSpuDelay(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.DelayMessage message = new Messages.DelayMessage();
        message.setDelay(player.getSpuDelay());
        return message;
    }

    @Override
    public void addSubtitleTrack(Messages.AddSubtitleMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        boolean isNetworkUrl = arg.getType() == DataSourceType.NETWORK.getNumericType();
        player.addSubtitleTrack(arg.getUri(), isNetworkUrl, arg.getIsSelected());
    }

    @Override
    public Messages.TrackCountMessage getAudioTracksCount(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.TrackCountMessage message = new Messages.TrackCountMessage();
        message.setCount((long) player.getAudioTracksCount());
        return message;
    }

    @Override
    public Messages.AudioTracksMessage getAudioTracks(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.AudioTracksMessage message = new Messages.AudioTracksMessage();
        message.setAudios(player.getAudioTracks());
        return message;
    }

    @Override
    public void setAudioTrack(Messages.AudioTrackMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.setAudioTrack(arg.getAudioTrackNumber().intValue());
    }

    @Override
    public Messages.AudioTrackMessage getAudioTrack(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.AudioTrackMessage message = new Messages.AudioTrackMessage();
        message.setAudioTrackNumber((long) player.getAudioTrack());
        return message;
    }

    @Override
    public void setAudioDelay(Messages.DelayMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.setAudioDelay(arg.getDelay());
    }

    @Override
    public Messages.DelayMessage getAudioDelay(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.DelayMessage message = new Messages.DelayMessage();
        message.setDelay(player.getAudioDelay());
        return message;
    }

    @Override
    public void addAudioTrack(Messages.AddAudioMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        boolean isNetworkUrl = arg.getType() == DataSourceType.NETWORK.getNumericType();
        player.addAudioTrack(arg.getUri(), isNetworkUrl, arg.getIsSelected());
    }

    @Override
    public Messages.TrackCountMessage getVideoTracksCount(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.TrackCountMessage message = new Messages.TrackCountMessage();
        message.setCount((long) player.getVideoTracksCount());
        return message;
    }

    @Override
    public Messages.VideoTracksMessage getVideoTracks(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.VideoTracksMessage message = new Messages.VideoTracksMessage();
        message.setVideos(player.getVideoTracks());
        return message;
    }

    @Override
    public void setVideoTrack(Messages.VideoTrackMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.setVideoTrack(arg.getVideoTrackNumber().intValue());
    }

    @Override
    public Messages.VideoTrackMessage getVideoTrack(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.VideoTrackMessage message = new Messages.VideoTrackMessage();
        message.setVideoTrackNumber((long) player.getVideoTrack());
        return null;
    }

    @Override
    public void setVideoScale(Messages.VideoScaleMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.setVideoScale(arg.getScale().floatValue());
    }

    @Override
    public Messages.VideoScaleMessage getVideoScale(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.VideoScaleMessage message = new Messages.VideoScaleMessage();
        message.setScale((double) player.getVideoScale());
        return message;
    }

    @Override
    public void setVideoAspectRatio(Messages.VideoAspectRatioMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.setVideoAspectRatio(arg.getAspectRatio());
    }

    @Override
    public Messages.VideoAspectRatioMessage getVideoAspectRatio(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.VideoAspectRatioMessage message = new Messages.VideoAspectRatioMessage();
        message.setAspectRatio(player.getVideoAspectRatio());
        return message;
    }

    @Override
    public Messages.RendererServicesMessage getAvailableRendererServices(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.RendererServicesMessage message = new Messages.RendererServicesMessage();
        message.setServices(player.getAvailableRendererServices());
        return message;
    }

    @Override
    public void startRendererScanning(Messages.RendererScanningMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.startRendererScanning(arg.getRendererService());
    }

    @Override
    public void stopRendererScanning(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.stopRendererScanning();
    }

    @Override
    public Messages.RendererDevicesMessage getRendererDevices(Messages.TextureMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        Messages.RendererDevicesMessage message = new Messages.RendererDevicesMessage();
        message.setRendererDevices(player.getRendererDevices());
        return message;
    }

    @Override
    public void castToRenderer(Messages.RenderDeviceMessage arg) {
        FlutterVlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.castToRenderer(arg.getRendererDevice());
    }

}
