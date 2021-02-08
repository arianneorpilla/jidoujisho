import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vlc_player_platform_interface/flutter_vlc_player_platform_interface.dart';

import 'enums/playing_state.dart';
import 'vlc_app_life_cycle_observer.dart';
import 'vlc_player_platform.dart';
import 'vlc_player_value.dart';

typedef RendererCallback = void Function(VlcRendererEventType, String, String);

/// Controls a platform vlc player, and provides updates when the state is
/// changing.
///
/// Instances must be initialized with initialize.
///
/// The video is displayed in a Flutter app by creating a [VlcPlayer] widget.
///
/// To reclaim the resources used by the player call [dispose].
///
/// After [dispose] all further calls are ignored.
class VlcPlayerController extends ValueNotifier<VlcPlayerValue> {
  ///
  /// The name of the asset is given by the [dataSource] argument and must not be
  /// null. The [package] argument must be non-null when the asset comes from a
  /// package and null otherwise.
  VlcPlayerController.asset(
    this.dataSource, {
    this.autoInitialize = true,
    this.package,
    this.hwAcc = HwAcc.AUTO,
    this.autoPlay = true,
    this.options,
    VoidCallback onInit,
    RendererCallback onRendererHandler,
  })  : _dataSourceType = DataSourceType.asset,
        _onInit = onInit,
        _onRendererHandler = onRendererHandler,
        super(VlcPlayerValue(duration: Duration.zero));

  /// Constructs a [VlcPlayerController] playing a video from obtained from
  /// the network.
  ///
  /// The URI for the video is given by the [dataSource] argument and must not be
  /// null.
  VlcPlayerController.network(
    this.dataSource, {
    this.autoInitialize = true,
    this.hwAcc = HwAcc.AUTO,
    this.autoPlay = true,
    this.options,
    VoidCallback onInit,
    RendererCallback onRendererHandler,
  })  : package = null,
        _dataSourceType = DataSourceType.network,
        _onInit = onInit,
        _onRendererHandler = onRendererHandler,
        super(VlcPlayerValue(duration: Duration.zero));

  /// Constructs a [VlcPlayerController] playing a video from a file.
  ///
  /// This will load the file from the file-URI given by:
  /// `'file://${file.path}'`.
  VlcPlayerController.file(
    File file, {
    this.autoInitialize = true,
    this.hwAcc = HwAcc.AUTO,
    this.autoPlay = true,
    this.options,
    VoidCallback onInit,
    RendererCallback onRendererHandler,
  })  : dataSource = 'file://${file.path}',
        package = null,
        _dataSourceType = DataSourceType.file,
        _onInit = onInit,
        _onRendererHandler = onRendererHandler,
        super(VlcPlayerValue(duration: Duration.zero));

  /// The URI to the video file. This will be in different formats depending on
  /// the [DataSourceType] of the original video.
  final String dataSource;

  /// Set hardware acceleration for player. Default is Automatic.
  final HwAcc hwAcc;

  /// Adds options to vlc. For more [https://wiki.videolan.org/VLC_command-line_help] If nothing is provided,
  /// vlc will run without any options set.
  final VlcPlayerOptions options;

  /// The video should be played automatically.
  final bool autoPlay;

  /// Initialize vlc player when the platform is ready automatically
  final bool autoInitialize;

  /// Only set for [asset] videos. The package that the asset was loaded from.
  String package;

  /// Describes the type of data source this [VlcPlayerController]
  /// is constructed with.
  DataSourceType get dataSourceType => _dataSourceType;
  DataSourceType _dataSourceType;

  /// Determine if platform is ready to call initialize method
  bool get isReadyToInitialize => _isReadyToInitialize;
  bool _isReadyToInitialize;

  /// This is just exposed for testing. It shouldn't be used by anyone depending
  /// on the plugin.
  @visibleForTesting
  int get viewId => _viewId;

  /// The viewId for this controller
  int _viewId;

  /// This is a callback that will be executed once the platform view has been initialized.
  /// If you want the media to play as soon as the platform view has initialized, you could just call
  /// [VlcPlayerController.play] in this callback. (see the example)
  final _onInit;

  /// This is a callback that will be executed every time a new renderer cast device attached/detached
  /// It should be defined as "void Function(VlcRendererEventType, String, String)", where the VlcRendererEventType is an enum { attached, detached } and the next two String arguments are unique-id and name of renderer device, respectively.
  final _onRendererHandler;

  bool _isDisposed = false;
  Completer<void> _creatingCompleter;
  VlcAppLifeCycleObserver _lifeCycleObserver;

  /// Attempts to open the given [url] and load metadata about the video.
  Future<void> initialize() async {
    if (_isDisposed) {
      throw Exception(
          'initialize was called on a disposed VlcPlayerController');
    }
    if (value.isInitialized) {
      throw Exception('Already Initialized');
    }

    _lifeCycleObserver = VlcAppLifeCycleObserver(this);
    _lifeCycleObserver.initialize();
    _creatingCompleter = Completer<void>();

    await vlcPlayerPlatform.create(
      viewId: _viewId,
      uri: dataSource,
      type: dataSourceType,
      package: package,
      hwAcc: hwAcc ?? HwAcc.AUTO,
      autoPlay: autoPlay ?? true,
      options: options,
    );

    _creatingCompleter.complete(null);
    final initializingCompleter = Completer<void>();

    // listen for media events
    void mediaEventListener(VlcMediaEvent event) {
      if (_isDisposed) {
        return;
      }

      switch (event.mediaEventType) {
        case VlcMediaEventType.opening:
          value = value.copyWith(
            isPlaying: false,
            isBuffering: true,
            isEnded: false,
            playingState: PlayingState.buffering,
          );
          break;

        case VlcMediaEventType.paused:
          value = value.copyWith(
            isPlaying: false,
            isBuffering: false,
            playingState: PlayingState.paused,
          );
          break;

        case VlcMediaEventType.stopped:
          value = value.copyWith(
            isPlaying: false,
            isBuffering: false,
            playingState: PlayingState.stopped,
            position: Duration.zero,
          );
          break;

        case VlcMediaEventType.playing:
          value = value.copyWith(
            isEnded: false,
            isPlaying: true,
            playingState: PlayingState.playing,
            duration: event.duration,
            size: event.size,
            playbackSpeed: event.playbackSpeed,
            audioTracksCount: event.audioTracksCount,
            activeAudioTrack: event.activeAudioTrack,
            spuTracksCount: event.spuTracksCount,
            activeSpuTrack: event.activeSpuTrack,
          );
          break;

        case VlcMediaEventType.ended:
          value = value.copyWith(
            isPlaying: false,
            isBuffering: false,
            isEnded: true,
            playingState: PlayingState.ended,
            position: event.position,
          );
          break;

        case VlcMediaEventType.buffering:
        case VlcMediaEventType.timeChanged:
          value = value.copyWith(
            isEnded: false,
            position: event.position,
            duration: event.duration,
            playbackSpeed: event.playbackSpeed,
            bufferPercent: event.bufferPercent,
            size: event.size,
            audioTracksCount: event.audioTracksCount,
            activeAudioTrack: event.activeAudioTrack,
            spuTracksCount: event.spuTracksCount,
            activeSpuTrack: event.activeSpuTrack,
            isPlaying: event.isPlaying,
            playingState:
                event.isPlaying ? PlayingState.playing : value.playingState,
          );
          break;

        case VlcMediaEventType.mediaChanged:
          break;

        case VlcMediaEventType.error:
          value = value.copyWith(
            isPlaying: false,
            isBuffering: false,
            isEnded: false,
            playingState: PlayingState.error,
          );
          break;

        case VlcMediaEventType.unknown:
          break;
      }
    }

    void errorListener(Object obj) {
      final e = obj as PlatformException;
      value = VlcPlayerValue.erroneous(e.message);
      if (!initializingCompleter.isCompleted) {
        initializingCompleter.completeError(obj);
      }
    }

    vlcPlayerPlatform
        .mediaEventsFor(_viewId)
        .listen(mediaEventListener, onError: errorListener);

    // listen for renderer devices events
    void rendererEventListener(VlcRendererEvent event) {
      if (_isDisposed) {
        return;
      }
      switch (event.eventType) {
        case VlcRendererEventType.attached:
          if (_onRendererHandler != null) {
            _onRendererHandler(VlcRendererEventType.attached, event.rendererId,
                event.rendererName);
          }
          break;
        case VlcRendererEventType.detached:
          if (_onRendererHandler != null) {
            _onRendererHandler(VlcRendererEventType.detached, event.rendererId,
                event.rendererName);
          }
          break;
        case VlcRendererEventType.unknown:
          break;
      }
    }

    vlcPlayerPlatform.rendererEventsFor(_viewId).listen(rendererEventListener);

    if (!initializingCompleter.isCompleted) {
      initializingCompleter.complete(null);
    }
    //
    value = value.copyWith(
      isInitialized: true,
      playingState: PlayingState.initialized,
    );

    if (_onInit != null) _onInit();

    return initializingCompleter.future;
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _lifeCycleObserver?.dispose();
    _isDisposed = true;
    super.dispose();
    //
    if (_creatingCompleter != null) {
      await _creatingCompleter.future;
      await vlcPlayerPlatform.dispose(_viewId);
    }
  }

  /// This stops playback and changes the data source. Once the new data source has been loaded, the playback state will revert to
  /// its state before the method was called. (i.e. if this method is called whilst media is playing, once the new
  /// data source has been loaded, the new stream will begin playing.)
  /// [dataSource] - the path of the asset file.
  Future<void> setMediaFromAsset(
    String dataSource, {
    String package,
    bool autoPlay,
    HwAcc hwAcc,
  }) async {
    _dataSourceType = DataSourceType.asset;
    this.package = package;
    await _setStreamUrl(
      dataSource,
      dataSourceType: DataSourceType.asset,
      package: package,
      autoPlay: autoPlay,
      hwAcc: hwAcc,
    );
  }

  /// This stops playback and changes the data source. Once the new data source has been loaded, the playback state will revert to
  /// its state before the method was called. (i.e. if this method is called whilst media is playing, once the new
  /// data source has been loaded, the new stream will begin playing.)
  /// [dataSource] - the URL of the stream to start playing.
  Future<void> setMediaFromNetwork(
    String dataSource, {
    bool autoPlay,
    HwAcc hwAcc,
  }) async {
    _dataSourceType = DataSourceType.network;
    package = null;
    await _setStreamUrl(
      dataSource,
      dataSourceType: DataSourceType.network,
      package: null,
      autoPlay: autoPlay,
      hwAcc: hwAcc,
    );
  }

  /// This stops playback and changes the data source. Once the new data source has been loaded, the playback state will revert to
  /// its state before the method was called. (i.e. if this method is called whilst media is playing, once the new
  /// data source has been loaded, the new stream will begin playing.)
  /// [file] - the File stream to start playing.
  Future<void> setMediaFromFile(
    File file, {
    bool autoPlay,
    HwAcc hwAcc,
  }) async {
    _dataSourceType = DataSourceType.file;
    package = null;
    var dataSource = 'file://${file.path}';
    await _setStreamUrl(
      dataSource,
      dataSourceType: DataSourceType.file,
      package: null,
      autoPlay: autoPlay,
      hwAcc: hwAcc,
    );
  }

  /// This stops playback and changes the data source. Once the new data source has been loaded, the playback state will revert to
  /// its state before the method was called. (i.e. if this method is called whilst media is playing, once the new
  /// data source has been loaded, the new stream will begin playing.)
  /// [dataSource] - the URL of the stream to start playing.
  /// [dataSourceType] - the source type of media.
  Future<void> _setStreamUrl(
    String dataSource, {
    DataSourceType dataSourceType,
    String package,
    bool autoPlay,
    HwAcc hwAcc,
  }) async {
    _throwIfNotInitialized('setStreamUrl');
    await vlcPlayerPlatform.stop(_viewId);
    await vlcPlayerPlatform.setStreamUrl(
      _viewId,
      uri: dataSource,
      type: dataSourceType,
      package: package,
      hwAcc: hwAcc ?? HwAcc.AUTO,
      autoPlay: autoPlay ?? true,
    );
    return;
  }

  /// Starts playing the video.
  ///
  /// This method returns a future that completes as soon as the "play" command
  /// has been sent to the platform, not when playback itself is totally
  /// finished.
  Future<void> play() async {
    _throwIfNotInitialized('play');
    await vlcPlayerPlatform.play(_viewId);
    // This ensures that the correct playback speed is always applied when
    // playing back. This is necessary because we do not set playback speed
    // when paused.
    await setPlaybackSpeed(value.playbackSpeed);
  }

  /// Pauses the video.
  Future<void> pause() async {
    _throwIfNotInitialized('pause');
    await vlcPlayerPlatform.pause(_viewId);
  }

  /// stops the video.
  Future<void> stop() async {
    _throwIfNotInitialized('stop');
    await vlcPlayerPlatform.stop(_viewId);
  }

  /// Sets whether or not the video should loop after playing once.
  Future<void> setLooping(bool looping) async {
    _throwIfNotInitialized('setLooping');
    value = value.copyWith(isLooping: looping);
    await vlcPlayerPlatform.setLooping(_viewId, looping);
  }

  /// Returns true if media is playing.
  Future<bool> isPlaying() async {
    _throwIfNotInitialized('isPlaying');
    return await vlcPlayerPlatform.isPlaying(_viewId);
  }

  /// Set video timestamp in millisecond
  Future<void> setTime(int time) async {
    return await seekTo(Duration(milliseconds: time));
  }

  /// Sets the video's current timestamp to be at [moment]. The next
  /// time the video is played it will resume from the given [moment].
  ///
  /// If [moment] is outside of the video's full range it will be automatically
  /// and silently clamped.
  Future<void> seekTo(Duration position) async {
    _throwIfNotInitialized('seekTo');
    if (position > value.duration) {
      position = value.duration;
    } else if (position < Duration.zero) {
      position = Duration.zero;
    }
    await vlcPlayerPlatform.seekTo(_viewId, position);
  }

  /// Get the video timestamp in millisecond
  Future<int> getTime() async {
    var position = await getPosition();
    return position.inMilliseconds;
  }

  /// Returns the position in the current video.
  Future<Duration> getPosition() async {
    _throwIfNotInitialized('getPosition');
    var position = await vlcPlayerPlatform.getPosition(_viewId);
    value = value.copyWith(position: position);
    return position;
  }

  /// Sets the audio volume of
  ///
  /// [volume] indicates a value between 0 (silent) and 100 (full volume) on a
  /// linear scale.
  Future<void> setVolume(int volume) async {
    _throwIfNotInitialized('setVolume');
    value = value.copyWith(volume: volume.clamp(0, 100));
    await vlcPlayerPlatform.setVolume(_viewId, value.volume);
  }

  /// Returns current vlc volume level.
  Future<int> getVolume() async {
    _throwIfNotInitialized('getVolume');
    var volume = await vlcPlayerPlatform.getVolume(_viewId);
    value = value.copyWith(volume: volume.clamp(0, 100));
    return volume;
  }

  /// Returns duration/length of loaded video
  Future<Duration> getDuration() async {
    _throwIfNotInitialized('getDuration');
    var duration = await vlcPlayerPlatform.getDuration(_viewId);
    value = value.copyWith(duration: duration);
    return duration;
  }

  /// Sets the playback speed.
  ///
  /// [speed] - the rate at which VLC should play media.
  /// For reference:
  /// 2.0 is double speed.
  /// 1.0 is normal speed.
  /// 0.5 is half speed.
  Future<void> setPlaybackSpeed(double speed) async {
    if (speed < 0) {
      throw ArgumentError.value(
        speed,
        'Negative playback speeds are not supported.',
      );
    } else if (speed == 0) {
      throw ArgumentError.value(
        speed,
        'Zero playback speed is not supported. Consider using [pause].',
      );
    }
    _throwIfNotInitialized('setPlaybackSpeed');
    // Setting the playback speed on iOS will trigger the video to play. We
    // prevent this from happening by not applying the playback speed until
    // the video is manually played from Flutter.
    if (!value.isPlaying) return;
    await vlcPlayerPlatform.setPlaybackSpeed(
      _viewId,
      value.playbackSpeed,
    );
  }

  /// Returns the vlc playback speed.
  Future<double> getPlaybackSpeed() async {
    _throwIfNotInitialized('getPlaybackSpeed');
    var speed = await vlcPlayerPlatform.getPlaybackSpeed(_viewId);
    value = value.copyWith(playbackSpeed: speed);
    return speed;
  }

  /// Return the number of subtitle tracks (both embedded and inserted)
  Future<int> getSpuTracksCount() async {
    _throwIfNotInitialized('getSpuTracksCount');
    var spuTracksCount = await vlcPlayerPlatform.getSpuTracksCount(_viewId);
    value = value.copyWith(spuTracksCount: spuTracksCount);
    return spuTracksCount;
  }

  /// Return all subtitle tracks as array of <Int, String>
  /// The key parameter is the index of subtitle which is used for changing subtitle
  /// and the value is the display name of subtitle
  Future<Map<int, String>> getSpuTracks() async {
    _throwIfNotInitialized('getSpuTracks');
    return await vlcPlayerPlatform.getSpuTracks(_viewId);
  }

  /// Change active subtitle index (set -1 to disable subtitle).
  /// [spuTrackNumber] - the subtitle index obtained from getSpuTracks()
  Future<void> setSpuTrack(int spuTrackNumber) async {
    _throwIfNotInitialized('setSpuTrack');
    return await vlcPlayerPlatform.setSpuTrack(_viewId, spuTrackNumber);
  }

  /// Returns active spu track index
  Future<int> getSpuTrack() async {
    _throwIfNotInitialized('getSpuTrack');
    var activeSpuTrack = await vlcPlayerPlatform.getSpuTrack(_viewId);
    value = value.copyWith(activeSpuTrack: activeSpuTrack);
    return activeSpuTrack;
  }

  /// [spuDelay] - the amount of time in milliseconds which vlc subtitle should be delayed.
  /// (both positive & negative value applicable)
  Future<void> setSpuDelay(int spuDelay) async {
    _throwIfNotInitialized('setSpuDelay');
    value = value.copyWith(spuDelay: spuDelay);
    return await vlcPlayerPlatform.setSpuDelay(_viewId, spuDelay);
  }

  /// Returns the amount of subtitle time delay.
  Future<int> getSpuDelay() async {
    _throwIfNotInitialized('getSpuDelay');
    var spuDelay = await vlcPlayerPlatform.getSpuDelay(_viewId);
    value = value.copyWith(spuDelay: spuDelay);
    return spuDelay;
  }

  /// Add extra network subtitle to media.
  /// [dataSource] - Url of subtitle
  /// [isSelected] - Set true if you wanna force the added subtitle to start display on media.
  Future<void> addSubtitleFromNetwork(
    String dataSource, {
    bool isSelected,
  }) async {
    return await _addSubtitleTrack(
      dataSource,
      dataSourceType: DataSourceType.network,
      isSelected: isSelected ?? true,
    );
  }

  /// Add extra subtitle file to media.
  /// [file] - Subtitle file
  /// [isSelected] - Set true if you wanna force the added subtitle to start display on media.
  Future<void> addSubtitleFromFile(
    File file, {
    bool isSelected,
  }) async {
    return await _addSubtitleTrack(
      'file://${file.path}',
      dataSourceType: DataSourceType.file,
      isSelected: isSelected ?? true,
    );
  }

  /// Add extra subtitle to media.
  /// [uri] - URI of subtitle
  /// [isSelected] - Set true if you wanna force the added subtitle to start display on media.
  Future<void> _addSubtitleTrack(
    String uri, {
    DataSourceType dataSourceType,
    bool isSelected,
  }) async {
    _throwIfNotInitialized('addSubtitleTrack');
    return await vlcPlayerPlatform.addSubtitleTrack(
      _viewId,
      uri: uri,
      type: dataSourceType,
      isSelected: isSelected ?? true,
    );
  }

  /// Returns the number of audio tracks
  Future<int> getAudioTracksCount() async {
    _throwIfNotInitialized('getAudioTracksCount');
    var audioTracksCount = await vlcPlayerPlatform.getAudioTracksCount(_viewId);
    value = value.copyWith(audioTracksCount: audioTracksCount);
    return audioTracksCount;
  }

  /// Returns all audio tracks as array of <Int, String>
  /// The key parameter is the index of audio track which is used for changing audio
  /// and the value is the display name of audio
  Future<Map<int, String>> getAudioTracks() async {
    _throwIfNotInitialized('getAudioTracks');
    return await vlcPlayerPlatform.getAudioTracks(_viewId);
  }

  /// Returns active audio track index
  Future<int> getAudioTrack() async {
    _throwIfNotInitialized('getAudioTrack');
    var activeAudioTrack = await vlcPlayerPlatform.getAudioTrack(_viewId);
    value = value.copyWith(activeAudioTrack: activeAudioTrack);
    return activeAudioTrack;
  }

  /// Change active audio track index (set -1 to mute).
  /// [audioTrackNumber] - the audio track index obtained from getAudioTracks()
  Future<void> setAudioTrack(int audioTrackNumber) async {
    _throwIfNotInitialized('setAudioTrack');
    return await vlcPlayerPlatform.setAudioTrack(_viewId, audioTrackNumber);
  }

  /// [audioDelay] - the amount of time in milliseconds which vlc audio should be delayed.
  /// (both positive & negative value appliable)
  Future<void> setAudioDelay(int audioDelay) async {
    _throwIfNotInitialized('setAudioDelay');
    value = value.copyWith(audioDelay: audioDelay);
    return await vlcPlayerPlatform.setAudioDelay(_viewId, audioDelay);
  }

  /// Returns the amount of audio track time delay in millisecond.
  Future<int> getAudioDelay() async {
    _throwIfNotInitialized('getAudioDelay');
    var audioDelay = await vlcPlayerPlatform.getAudioDelay(_viewId);
    value = value.copyWith(audioDelay: audioDelay);
    return audioDelay;
  }

  /// Add extra network audio to media.
  /// [dataSource] - Url of audio
  /// [isSelected] - Set true if you wanna force the added audio to start playing on media.
  Future<void> addAudioFromNetwork(
    String dataSource, {
    bool isSelected,
  }) async {
    return await _addAudioTrack(
      dataSource,
      dataSourceType: DataSourceType.network,
      isSelected: isSelected ?? true,
    );
  }

  /// Add extra audio file to media.
  /// [file] - Audio file
  /// [isSelected] - Set true if you wanna force the added audio to start playing on media.
  Future<void> addAudioFromFile(
    File file, {
    bool isSelected,
  }) async {
    return await _addAudioTrack(
      'file://${file.path}',
      dataSourceType: DataSourceType.file,
      isSelected: isSelected ?? true,
    );
  }

  /// Add extra audio to media.
  /// [uri] - URI of audio
  /// [isSelected] - Set true if you wanna force the added audio to start playing on media.
  Future<void> _addAudioTrack(
    String uri, {
    DataSourceType dataSourceType,
    bool isSelected,
  }) async {
    _throwIfNotInitialized('addAudioTrack');
    return await vlcPlayerPlatform.addAudioTrack(
      _viewId,
      uri: uri,
      type: dataSourceType,
      isSelected: isSelected ?? true,
    );
  }

  /// Returns the number of video tracks
  Future<int> getVideoTracksCount() async {
    _throwIfNotInitialized('getVideoTracksCount');
    var videoTracksCount = await vlcPlayerPlatform.getVideoTracksCount(_viewId);
    value = value.copyWith(videoTracksCount: videoTracksCount);
    return videoTracksCount;
  }

  /// Returns all video tracks as array of <Int, String>
  /// The key parameter is the index of video track and the value is the display name of video track
  Future<Map<int, String>> getVideoTracks() async {
    _throwIfNotInitialized('getVideoTracks');
    return await vlcPlayerPlatform.getVideoTracks(_viewId);
  }

  /// Change active video track index.
  /// [videoTrackNumber] - the video track index obtained from getVideoTracks()
  Future<void> setVideoTrack(int videoTrackNumber) async {
    _throwIfNotInitialized('setVideoTrack');
    return await vlcPlayerPlatform.setVideoTrack(_viewId, videoTrackNumber);
  }

  /// Returns active video track index
  Future<int> getVideoTrack() async {
    _throwIfNotInitialized('getVideoTrack');
    var activeVideoTrack = await vlcPlayerPlatform.getVideoTrack(_viewId);
    value = value.copyWith(activeVideoTrack: activeVideoTrack);
    return activeVideoTrack;
  }

  /// [scale] - the video scale value
  /// Set video scale
  Future<void> setVideoScale(double videoScale) async {
    _throwIfNotInitialized('setVideoScale');
    value = value.copyWith(videoScale: videoScale);
    return await vlcPlayerPlatform.setVideoScale(_viewId, videoScale);
  }

  /// Returns video scale
  Future<double> getVideoScale() async {
    _throwIfNotInitialized('getVideoScale');
    var videoScale = await vlcPlayerPlatform.getVideoScale(_viewId);
    value = value.copyWith(videoScale: videoScale);
    return videoScale;
  }

  /// [aspectRatio] - the video aspect ratio like "16:9"
  ///
  /// Set video aspect ratio
  Future<void> setVideoAspectRatio(String aspectRatio) async {
    _throwIfNotInitialized('setVideoAspectRatio');
    return vlcPlayerPlatform.setVideoAspectRatio(_viewId, aspectRatio);
  }

  /// Returns video aspect ratio in string format
  ///
  /// This is different from the aspectRatio property in video value "16:9"
  Future<String> getVideoAspectRatio() async {
    _throwIfNotInitialized('getVideoAspectRatio');
    return vlcPlayerPlatform.getVideoAspectRatio(_viewId);
  }

  /// Returns binary data for a snapshot of the media at the current frame.
  ///
  Future<Uint8List> takeSnapshot() async {
    _throwIfNotInitialized('takeSnapshot');
    return await vlcPlayerPlatform.takeSnapshot(_viewId);
  }

  /// Start vlc cast discovery to find external display devices (chromecast)
  /// By setting serviceName, the vlc discovers renderer with that service
  Future<void> startRendererScanning({String rendererService}) async {
    _throwIfNotInitialized('startRendererScanning');
    return await vlcPlayerPlatform.startRendererScanning(viewId,
        rendererService: rendererService ?? '');
  }

  /// Stop vlc cast and scan
  Future<void> stopRendererScanning() async {
    _throwIfNotInitialized('stopRendererScanning');
    return await vlcPlayerPlatform.stopRendererScanning(viewId);
  }

  /// Returns all detected renderer devices as array of <String, String>
  /// The key parameter is the name of cast device and the value is the display name of cast device
  Future<Map<String, String>> getRendererDevices() async {
    _throwIfNotInitialized('getRendererDevices');
    return await vlcPlayerPlatform.getRendererDevices(_viewId);
  }

  /// [castDevice] - name of renderer device
  /// Start vlc video casting to the selected device.
  /// Set null if you wanna stop video casting.
  Future<void> castToRenderer(String castDevice) async {
    _throwIfNotInitialized('castToRenderer');
    return await vlcPlayerPlatform.castToRenderer(_viewId, castDevice);
  }

  /// [functionName] - name of function
  /// throw exception if vlc player controller is not initialized
  void _throwIfNotInitialized(String functionName) {
    if (!value.isInitialized) {
      throw Exception(
        '$functionName() was called on an uninitialized VlcPlayerController.',
      );
    }
    if (_isDisposed) {
      throw Exception(
        '$functionName() was called on a disposed VlcPlayerController.',
      );
    }
  }

  /// [viewId] - the id of view that is generated by the platform
  /// This method will be called after the platform view has been created
  Future<void> onPlatformViewCreated(int viewId) async {
    if (viewId == null) return;
    _viewId = viewId;
    // do we need to initialize controller after view becomes ready?
    if (autoInitialize) {
      await Future.delayed(Duration(seconds: 1));
      await initialize();
    }
    _isReadyToInitialize = true;
  }
}
