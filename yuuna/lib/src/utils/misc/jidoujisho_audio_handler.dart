import 'package:audio_service/audio_service.dart' as ag;

/// Enables play/pause button to be used with the app.
class JidoujishoAudioHandler extends ag.BaseAudioHandler {
  /// Define this handler.
  JidoujishoAudioHandler({
    required this.onPlayPause,
  });

  /// Called during play/pause.
  final Function() onPlayPause;

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
}
