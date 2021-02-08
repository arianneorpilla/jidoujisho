package software.solid.fluttervlcplayer;

import org.videolan.libvlc.LibVLC;
import org.videolan.libvlc.Media;
import org.videolan.libvlc.MediaPlayer;
import org.videolan.libvlc.RendererDiscoverer;
import org.videolan.libvlc.RendererItem;
import org.videolan.libvlc.interfaces.IMedia;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.SurfaceTexture;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.Base64;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceView;
import android.view.TextureView;
import android.view.View;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.view.TextureRegistry;
import software.solid.fluttervlcplayer.Enums.HwAcc;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

final class FlutterVlcPlayer implements PlatformView {

    private final String TAG = this.getClass().getSimpleName();
    private final boolean debug = false;
    //
    private final Context context;
    private final TextureView textureView;
    private final TextureRegistry.SurfaceTextureEntry textureEntry;
    //
    private final QueuingEventSink mediaEventSink = new QueuingEventSink();
    private final EventChannel mediaEventChannel;
    //
    private final QueuingEventSink rendererEventSink = new QueuingEventSink();
    private final EventChannel rendererEventChannel;
    //
    private LibVLC libVLC;
    private MediaPlayer mediaPlayer;
    private List<RendererDiscoverer> rendererDiscoverers;
    private List<RendererItem> rendererItems;
    private boolean isDisposed = false;

    // Platform view
    @Override
    public View getView() {
        return textureView;
    }

    @Override
    public void dispose() {
        if (isDisposed)
            return;
        //
        textureEntry.release();
        mediaEventChannel.setStreamHandler(null);
        rendererEventChannel.setStreamHandler(null);
        if (mediaPlayer != null) {
            mediaPlayer.stop();
            mediaPlayer.getVLCVout().detachViews();
            mediaPlayer.release();
            mediaPlayer = null;
        }
        if (libVLC != null) {
            libVLC.release();
            libVLC = null;
        }
        isDisposed = true;
    }

    // VLC Player
    FlutterVlcPlayer(int viewId, Context context, BinaryMessenger binaryMessenger, TextureRegistry textureRegistry) {
        this.context = context;
        // event for media
        mediaEventChannel = new EventChannel(binaryMessenger, "flutter_video_plugin/getVideoEvents_" + viewId);
        mediaEventChannel.setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object o, EventChannel.EventSink sink) {
                        mediaEventSink.setDelegate(sink);
                    }

                    @Override
                    public void onCancel(Object o) {
                        mediaEventSink.setDelegate(null);
                    }
                });
        // event for renderer
        rendererEventChannel = new EventChannel(binaryMessenger, "flutter_video_plugin/getRendererEvents_" + viewId);
        rendererEventChannel.setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object o, EventChannel.EventSink sink) {
                        rendererEventSink.setDelegate(sink);
                    }

                    @Override
                    public void onCancel(Object o) {
                        rendererEventSink.setDelegate(null);
                    }
                });
        //
        textureEntry = textureRegistry.createSurfaceTexture();
        textureView = new TextureView(context);
        textureView.setSurfaceTexture(textureEntry.surfaceTexture());
        textureView.forceLayout();
        textureView.setFitsSystemWindows(true);
    }

    // private Uri getStreamUri(String streamPath, boolean isLocal) {
    //     return isLocal ? Uri.fromFile(new File(streamPath)) : Uri.parse(streamPath);
    // }

    public void initialize(List<String> options) {
        libVLC = new LibVLC(context, options);
        mediaPlayer = new MediaPlayer(libVLC);
        setupVlcMediaPlayer();
    }

    private void setupVlcMediaPlayer() {

        // method 1
        textureView.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {

            boolean wasPlaying = false;

            @Override
            public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
                log("onSurfaceTextureAvailable");

                new Handler(Looper.getMainLooper()).postDelayed(() -> {
                    if (mediaPlayer == null)
                        return;
                    mediaPlayer.getVLCVout().setWindowSize(width, height);
                    mediaPlayer.getVLCVout().setVideoSurface(surface);
                    if (!mediaPlayer.getVLCVout().areViewsAttached())
                        mediaPlayer.getVLCVout().attachViews();
                    mediaPlayer.setVideoTrackEnabled(true);
                    if (wasPlaying)
                        mediaPlayer.play();
                    wasPlaying = false;
                }, 100L);

            }

            @Override
            public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
                if (mediaPlayer != null)
                    mediaPlayer.getVLCVout().setWindowSize(width, height);
            }

            @Override
            public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
                log("onSurfaceTextureDestroyed");

                if (mediaPlayer != null) {
                    wasPlaying = mediaPlayer.isPlaying();
                    mediaPlayer.pause();
                    mediaPlayer.setVideoTrackEnabled(false);
                    mediaPlayer.getVLCVout().detachViews();
                }
                return false; //do not return true if you reuse it.
            }

            @Override
            public void onSurfaceTextureUpdated(SurfaceTexture surface) {
            }

        });

//         method 2
        textureView.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
            @Override
            public void onLayoutChange(View view, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {
                log("onLayoutChange");
                //
                if (left != oldLeft || top != oldTop || right != oldRight || bottom != oldBottom) {
                    mediaPlayer.pause();
                    mediaPlayer.setVideoTrackEnabled(false);
                    mediaPlayer.getVLCVout().detachViews();
                    mediaPlayer.getVLCVout().setWindowSize(view.getWidth(), view.getHeight());
                    mediaPlayer.getVLCVout().setVideoView((TextureView) view);
                    mediaPlayer.getVLCVout().attachViews();
                    mediaPlayer.setVideoTrackEnabled(true);
                    // hacky way to prevent video pixeling, it might be larger than buffer size
                    long tmpTime = mediaPlayer.getTime() - 500;
                    if (tmpTime > 0)
                        mediaPlayer.setTime(tmpTime);
                    mediaPlayer.play();
                }
            }
        });
        //
        mediaPlayer.getVLCVout().setWindowSize(textureView.getWidth(), textureView.getHeight());
        mediaPlayer.getVLCVout().setVideoSurface(textureView.getSurfaceTexture());
        mediaPlayer.getVLCVout().attachViews();
        mediaPlayer.setVideoTrackEnabled(true);
        //
        mediaPlayer.setEventListener(
                new MediaPlayer.EventListener() {
                    @Override
                    public void onEvent(MediaPlayer.Event event) {
                        HashMap<String, Object> eventObject = new HashMap<>();
                        //
                        // Current video track is only available when the media is playing
                        int height = 0;
                        int width = 0;
                        Media.VideoTrack currentVideoTrack = mediaPlayer.getCurrentVideoTrack();
                        if (currentVideoTrack != null) {
                            height = currentVideoTrack.height;
                            width = currentVideoTrack.width;
                        }
                        //
                        switch (event.type) {

                            case MediaPlayer.Event.Opening:
                                eventObject.put("event", "opening");
                                mediaEventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.Paused:
                                eventObject.put("event", "paused");
                                mediaEventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.Stopped:
                                eventObject.put("event", "stopped");
                                mediaEventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.Playing:
                                eventObject.put("event", "playing");
                                eventObject.put("height", height);
                                eventObject.put("width", width);
                                eventObject.put("speed", mediaPlayer.getRate());
                                eventObject.put("duration", mediaPlayer.getLength());
                                eventObject.put("audioTracksCount", mediaPlayer.getAudioTracksCount());
                                eventObject.put("activeAudioTrack", mediaPlayer.getAudioTrack());
                                eventObject.put("spuTracksCount", mediaPlayer.getSpuTracksCount());
                                eventObject.put("activeSpuTrack", mediaPlayer.getSpuTrack());
                                mediaEventSink.success(eventObject.clone());
                                break;

                            case MediaPlayer.Event.Vout:
//                                mediaPlayer.getVLCVout().setWindowSize(textureView.getWidth(), textureView.getHeight());
                                break;

                            case MediaPlayer.Event.EndReached:
                                eventObject.put("event", "ended");
                                eventObject.put("position", mediaPlayer.getTime());
                                mediaEventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.Buffering:
                            case MediaPlayer.Event.TimeChanged:
                                eventObject.put("event", "timeChanged");
                                eventObject.put("height", height);
                                eventObject.put("width", width);
                                eventObject.put("speed", mediaPlayer.getRate());
                                eventObject.put("position", mediaPlayer.getTime());
                                eventObject.put("duration", mediaPlayer.getLength());
                                eventObject.put("buffer", event.getBuffering());
                                eventObject.put("audioTracksCount", mediaPlayer.getAudioTracksCount());
                                eventObject.put("activeAudioTrack", mediaPlayer.getAudioTrack());
                                eventObject.put("spuTracksCount", mediaPlayer.getSpuTracksCount());
                                eventObject.put("activeSpuTrack", mediaPlayer.getSpuTrack());
                                eventObject.put("isPlaying", mediaPlayer.isPlaying());
                                mediaEventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.EncounteredError:
                                //mediaEventSink.error("500", "Player State got an error.", null);
                                eventObject.put("event", "error");
                                mediaEventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.LengthChanged:
                            case MediaPlayer.Event.MediaChanged:
                            case MediaPlayer.Event.ESAdded:
                            case MediaPlayer.Event.ESDeleted:
                            case MediaPlayer.Event.ESSelected:
                            case MediaPlayer.Event.PausableChanged:
                            case MediaPlayer.Event.RecordChanged:
                            case MediaPlayer.Event.SeekableChanged:
                            case MediaPlayer.Event.PositionChanged:
                            default:
                                break;
                        }
                    }
                }
        );
    }

    void play() {
        mediaPlayer.play();
    }

    void pause() {
        mediaPlayer.pause();
    }

    void stop() {
        mediaPlayer.stop();
    }

    boolean isPlaying() {
        return mediaPlayer.isPlaying();
    }

    void setStreamUrl(String url, boolean isAssetUrl, boolean autoPlay, long hwAcc) {
        try {
            mediaPlayer.stop();
            //
            Media media;
            if (isAssetUrl)
                media = new Media(libVLC, context.getAssets().openFd(url));
            else
                media = new Media(libVLC, Uri.parse(url));
            final HwAcc hwAccValue = HwAcc.values()[(int) hwAcc];
            switch (hwAccValue) {
                case DISABLED:
                    media.setHWDecoderEnabled(false, false);
                    break;
                case DECODING:
                case FULL:
                    media.setHWDecoderEnabled(true, true);
                    break;
            }
            if (hwAccValue == HwAcc.DECODING) {
                media.addOption(":no-mediacodec-dr");
                media.addOption(":no-omxil-dr");
            }
            mediaPlayer.setMedia(media);
            media.release();
            //
            mediaPlayer.play();
            if (!autoPlay) {
                mediaPlayer.stop();
            }
        } catch (IOException e) {
            log(e.getMessage());
        }
    }

    void setLooping(boolean value) {
        if (mediaPlayer != null) {
            if (mediaPlayer.getMedia() != null)
                mediaPlayer.getMedia().addOption(value ? "--loop" : "--no-loop");
        }
    }

    void setVolume(long value) {
        long bracketedValue = Math.max(0, Math.min(100, value));
        mediaPlayer.setVolume((int) bracketedValue);
    }

    int getVolume() {
        return mediaPlayer.getVolume();
    }

    void setPlaybackSpeed(double value) {
        mediaPlayer.setRate((float) value);
    }

    float getPlaybackSpeed() {
        return mediaPlayer.getRate();
    }

    void seekTo(int location) {
        mediaPlayer.setTime(location);
    }

    long getPosition() {
        return mediaPlayer.getTime();
    }

    long getDuration() {
        return mediaPlayer.getLength();
    }

    int getSpuTracksCount() {
        return mediaPlayer.getSpuTracksCount();
    }

    HashMap<Integer, String> getSpuTracks() {
        MediaPlayer.TrackDescription[] spuTracks = mediaPlayer.getSpuTracks();
        HashMap<Integer, String> subtitles = new HashMap<>();
        if (spuTracks != null)
            for (MediaPlayer.TrackDescription trackDescription : spuTracks) {
                if (trackDescription.id >= 0)
                    subtitles.put(trackDescription.id, trackDescription.name);
            }
        return subtitles;
    }

    void setSpuTrack(int index) {
        mediaPlayer.setSpuTrack(index);
    }

    int getSpuTrack() {
        return mediaPlayer.getSpuTrack();
    }

    void setSpuDelay(long delay) {
        mediaPlayer.setSpuDelay(delay);
    }

    long getSpuDelay() {
        return mediaPlayer.getSpuDelay();
    }

    void addSubtitleTrack(String url, boolean isNetworkUrl, boolean isSelected) {
        if (isNetworkUrl)
            mediaPlayer.addSlave(Media.Slave.Type.Subtitle, Uri.parse(url), isSelected);
        else
            mediaPlayer.addSlave(Media.Slave.Type.Subtitle, url, isSelected);
    }

    int getAudioTracksCount() {
        return mediaPlayer.getAudioTracksCount();
    }

    HashMap<Integer, String> getAudioTracks() {
        MediaPlayer.TrackDescription[] audioTracks = mediaPlayer.getAudioTracks();
        HashMap<Integer, String> audios = new HashMap<>();
        if (audioTracks != null)
            for (MediaPlayer.TrackDescription trackDescription : audioTracks) {
                if (trackDescription.id >= 0)
                    audios.put(trackDescription.id, trackDescription.name);
            }
        return audios;
    }

    void setAudioTrack(int index) {
        mediaPlayer.setAudioTrack(index);
    }

    int getAudioTrack() {
        return mediaPlayer.getAudioTrack();
    }

    void setAudioDelay(long delay) {
        mediaPlayer.setAudioDelay(delay);
    }

    long getAudioDelay() {
        return mediaPlayer.getAudioDelay();
    }

    void addAudioTrack(String url, boolean isNetworkUrl, boolean isSelected) {
        if (isNetworkUrl)
            mediaPlayer.addSlave(Media.Slave.Type.Audio, Uri.parse(url), isSelected);
        else
            mediaPlayer.addSlave(Media.Slave.Type.Audio, url, isSelected);
    }

    int getVideoTracksCount() {
        return mediaPlayer.getVideoTracksCount();
    }

    HashMap<Integer, String> getVideoTracks() {
        MediaPlayer.TrackDescription[] videoTracks = mediaPlayer.getVideoTracks();
        HashMap<Integer, String> videos = new HashMap<>();
        if (videoTracks != null)
            for (MediaPlayer.TrackDescription trackDescription : videoTracks) {
                if (trackDescription.id >= 0)
                    videos.put(trackDescription.id, trackDescription.name);
            }
        return videos;
    }

    void setVideoTrack(int index) {
        mediaPlayer.setVideoTrack(index);
    }

    int getVideoTrack() {
        return mediaPlayer.getVideoTrack();
    }

    void setVideoScale(float scale) {
        mediaPlayer.setScale(scale);
    }

    float getVideoScale() {
        return mediaPlayer.getScale();
    }

    void setVideoAspectRatio(String aspectRatio) {
        mediaPlayer.setAspectRatio(aspectRatio);
    }

    String getVideoAspectRatio() {
        return mediaPlayer.getAspectRatio();
    }

    void startRendererScanning(String rendererService) {

        //
        //  android -> chromecast -> "microdns"
        //  ios -> chromecast -> "Bonjour_renderer"
        //
        rendererDiscoverers = new ArrayList<>();
        rendererItems = new ArrayList<>();
        //
        //todo: check for duplicates
        RendererDiscoverer.Description[] renderers = RendererDiscoverer.list(libVLC);
        for (RendererDiscoverer.Description renderer : renderers) {
            RendererDiscoverer rendererDiscoverer = new RendererDiscoverer(libVLC, renderer.name);
            try {
                rendererDiscoverer.setEventListener(new RendererDiscoverer.EventListener() {
                    @Override
                    public void onEvent(RendererDiscoverer.Event event) {
                        HashMap<String, Object> eventObject = new HashMap<>();
                        RendererItem item = event.getItem();
                        switch (event.type) {
                            case RendererDiscoverer.Event.ItemAdded:
                                rendererItems.add(item);
                                eventObject.put("event", "attached");
                                eventObject.put("id", item.name);
                                eventObject.put("name", item.displayName);
                                rendererEventSink.success(eventObject);
                                break;

                            case RendererDiscoverer.Event.ItemDeleted:
                                rendererItems.remove(item);
                                eventObject.put("event", "detached");
                                eventObject.put("id", item.name);
                                eventObject.put("name", item.displayName);
                                rendererEventSink.success(eventObject);
                                break;

                            default:
                                break;
                        }
                    }
                });
                rendererDiscoverer.start();
                rendererDiscoverers.add(rendererDiscoverer);
            } catch (Exception ex) {
                rendererDiscoverer.setEventListener(null);
            }

        }

    }

    void stopRendererScanning() {
        if (isDisposed)
            return;
        //
        for (RendererDiscoverer rendererDiscoverer : rendererDiscoverers) {
            rendererDiscoverer.stop();
            rendererDiscoverer.setEventListener(null);
        }
        rendererDiscoverers.clear();
        rendererItems.clear();
        //
        // return back to default output
        if (mediaPlayer != null) {
            mediaPlayer.pause();
            mediaPlayer.setRenderer(null);
            mediaPlayer.play();
        }
    }

    ArrayList<String> getAvailableRendererServices() {
        RendererDiscoverer.Description[] renderers = RendererDiscoverer.list(libVLC);
        ArrayList<String> availableRendererServices = new ArrayList<>();
        for (RendererDiscoverer.Description renderer : renderers) {
            availableRendererServices.add(renderer.name);
        }
        return availableRendererServices;
    }

    HashMap<String, String> getRendererDevices() {
        HashMap<String, String> renderers = new HashMap<>();
        if (rendererItems != null)
            for (RendererItem rendererItem : rendererItems) {
                renderers.put(rendererItem.name, rendererItem.displayName);
            }
        return renderers;
    }

    void castToRenderer(String rendererDevice) {
        if(isDisposed)
            return;
        //
        boolean isPlaying = mediaPlayer.isPlaying();
        if (isPlaying)
            mediaPlayer.pause();

        // if you set it to null, it will start to render normally (i.e. locally) again
        RendererItem rendererItem = null;
        for (RendererItem item : rendererItems) {
            if (item.name.equals(rendererDevice)) {
                rendererItem = item;
                break;
            }
        }
        mediaPlayer.setRenderer(rendererItem);

        // start the playback
        mediaPlayer.play();
    }

    String getSnapshot() {
        Bitmap bitmap = textureView.getBitmap();
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
        return Base64.encodeToString(outputStream.toByteArray(), Base64.DEFAULT);
    }

    private void log(String message) {
        if (debug) {
            Log.d(TAG, message);
        }
    }

}
