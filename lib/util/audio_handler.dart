import 'package:audio_service/audio_service.dart';

class ChisaAudioHandler extends BaseAudioHandler {
  ChisaAudioHandler({required this.playCallback, required this.pauseCallback});

  final Function() playCallback;
  final Function() pauseCallback;

  @override
  Future<void> play() async {
    playCallback();
  }

  @override
  Future<void> pause() async {
    pauseCallback();
  }
}
