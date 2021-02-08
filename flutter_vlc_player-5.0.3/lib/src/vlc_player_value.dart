import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'enums/playing_state.dart';

/// The duration, current position, buffering state, error state and settings
/// of a [VlcPlayerController].
class VlcPlayerValue {
  /// Constructs a video with the given values. Only [duration] is required. The
  /// rest will initialize with default values when unset.
  VlcPlayerValue({
    @required this.duration,
    this.size = Size.zero,
    this.position = Duration.zero,
    this.playingState = PlayingState.initializing,
    this.isInitialized = false,
    this.isPlaying = false,
    this.isLooping = false,
    this.isBuffering = false,
    this.isEnded = false,
    this.bufferPercent = 0.0,
    this.volume = 100,
    this.playbackSpeed = 1.0,
    this.videoScale = 1.0,
    this.audioTracksCount = 1,
    this.activeAudioTrack = 1,
    this.audioDelay = 0,
    this.spuTracksCount = 0,
    this.activeSpuTrack = -1,
    this.spuDelay = 0,
    this.videoTracksCount = 1,
    this.activeVideoTrack = 0,
    this.errorDescription,
  });

  /// Returns an instance with a `null` [Duration].
  factory VlcPlayerValue.uninitialized() {
    return VlcPlayerValue(
      duration: Duration.zero,
      isInitialized: false,
    );
  }

  /// Returns an instance with the playing state error
  /// and the given [errorDescription].
  factory VlcPlayerValue.erroneous(String errorDescription) {
    return VlcPlayerValue(
      duration: Duration.zero,
      playingState: PlayingState.error,
      isInitialized: false,
      errorDescription: errorDescription,
    );
  }

  /// The total duration of the video.
  ///
  /// The duration is [Duration.zero] if the video hasn't been initialized.
  final Duration duration;

  /// The current playback position.
  final Duration position;

  /// The playing state of player
  final PlayingState playingState;

  /// True if the video is playing. False if it's paused or stopped.
  final bool isPlaying;

  /// True if the video is looping.
  final bool isLooping;

  /// True if the video is currently buffering.
  final bool isBuffering;

  /// True if the video is ended
  final bool isEnded;

  /// The current volume of the playback.
  final int volume;

  /// The buffer percent if the video is buffering.
  final double bufferPercent;

  /// The current speed of the playback.
  final double playbackSpeed;

  /// The video scale
  final double videoScale;

  /// The number of audio tracks in media
  final int audioTracksCount;

  /// The index of active audio track in media
  final int activeAudioTrack;

  /// The time delay of active audio track in millisecond
  final int audioDelay;

  /// The number of subtitle tracks in media
  final int spuTracksCount;

  /// The index of active subtitle track in media
  final int activeSpuTrack;

  /// The time delay of active subtitle track in millisecond
  final int spuDelay;

  /// The number of video tracks in media
  final int videoTracksCount;

  /// The index of active video track in media
  final int activeVideoTrack;

  /// A description of the error if present.
  ///
  /// If [hasError] is false this is [null].
  final String errorDescription;

  /// The [size] of the currently loaded video.
  ///
  /// The size is [Size.zero] if the video hasn't been initialized.
  final Size size;

  /// Indicates whether or not the vlc is ready to play.
  final bool isInitialized;

  /// Indicates whether or not the video is in an error state. If this is true
  /// [errorDescription] should have information about the problem.
  bool get hasError => errorDescription != null;

  /// Returns [size.width] / [size.height] when the player is initialized, or `1.0.` when
  /// the player is not initialized or the aspect ratio would be less than or equal to 0.0.
  double get aspectRatio {
    if (!isInitialized || size.width == 0 || size.height == 0) {
      return 1.0;
    }
    final aspectRatio = size.width / size.height;
    if (aspectRatio <= 0) {
      return 1.0;
    }
    return aspectRatio;
  }

  /// Returns a new instance that has the same values as this current instance,
  /// except for any overrides passed in as arguments to [copyWidth].
  VlcPlayerValue copyWith({
    Duration duration,
    Size size,
    Duration position,
    PlayingState playingState,
    bool isInitialized,
    bool isPlaying,
    bool isLooping,
    bool isBuffering,
    bool isEnded,
    double bufferPercent,
    int volume,
    double playbackSpeed,
    double videoScale,
    int audioTracksCount,
    int activeAudioTrack,
    int audioDelay,
    int spuTracksCount,
    int activeSpuTrack,
    int spuDelay,
    int videoTracksCount,
    int activeVideoTrack,
    String errorDescription,
  }) {
    return VlcPlayerValue(
      duration: duration ?? this.duration,
      size: size ?? this.size,
      position: position ?? this.position,
      playingState: playingState ?? this.playingState,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      isBuffering: isBuffering ?? this.isBuffering,
      isEnded: isEnded ?? this.isEnded,
      bufferPercent: bufferPercent ?? this.bufferPercent,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      videoScale: videoScale ?? this.videoScale,
      audioTracksCount: audioTracksCount ?? this.audioTracksCount,
      activeAudioTrack: activeAudioTrack ?? this.activeAudioTrack,
      audioDelay: audioDelay ?? this.audioDelay,
      spuTracksCount: spuTracksCount ?? this.spuTracksCount,
      activeSpuTrack: activeSpuTrack ?? this.activeSpuTrack,
      spuDelay: spuDelay ?? this.spuDelay,
      videoTracksCount: videoTracksCount ?? this.videoTracksCount,
      activeVideoTrack: activeVideoTrack ?? this.activeVideoTrack,
      errorDescription: errorDescription ?? this.errorDescription,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'duration: $duration, '
        'size: $size, '
        'position: $position, '
        'playingState: $playingState, '
        'isInitialized $isInitialized, '
        'isPlaying: $isPlaying, '
        'isLooping: $isLooping, '
        'isBuffering: $isBuffering, '
        'isEnded: $isEnded, '
        'bufferPercent: $bufferPercent, '
        'volume: $volume, '
        'playbackSpeed: $playbackSpeed, '
        'audioTracksCount: $audioTracksCount, '
        'activeAudioTrack: $activeAudioTrack, '
        'spuTracksCount: $spuTracksCount, '
        'activeSpuTrack: $activeSpuTrack, '
        'errorDescription: $errorDescription)';
  }
}
