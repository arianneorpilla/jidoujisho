import 'package:audio_service/audio_service.dart';

/// A handler for player audio in the application.
class JidoujishoAudioHandler extends BaseAudioHandler {
  /// Initialise this handler.
  JidoujishoAudioHandler({required this.onPlay, required this.onPause,});

  /// Function that executes on play.
  final Function() onPlay;
    /// Function that executes on pause.
  final Function() onPause;

  @override
  Future<void> play() async {
    onPlay();
  }

  @override
  Future<void> pause() async {
    onPause();
  }
}
