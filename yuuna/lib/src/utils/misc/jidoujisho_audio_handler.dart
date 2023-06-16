import 'package:audio_service/audio_service.dart' as ag;

/// Enables play/pause button to be used with the app.
class JidoujishoAudioHandler extends ag.BaseAudioHandler {
  /// Define this handler.
  JidoujishoAudioHandler({
    required this.onPlayPause,
    required this.onSeek,
    required this.onRewind,
    required this.onFastForward,
  });

  /// Called during play/pause.
  final Function() onPlayPause;

  /// Called during seek.
  final Function(Duration) onSeek;

  /// Called during seek.
  final Function() onRewind;

  /// Called during seek.
  final Function() onFastForward;

  /// Handles play request.
  @override
  Future<void> play() async {
    onPlayPause();
  }

  /// Handles pause request.
  @override
  Future<void> pause() async {
    onPlayPause();
  }

  /// Handles seek request.
  @override
  Future<void> seek(Duration position) async {
    onSeek(position);
  }

  /// Handles seek request.
  @override
  Future<void> fastForward() async {
    onFastForward();
  }

  /// Handles seek request.
  @override
  Future<void> rewind() async {
    onRewind();
  }
}
