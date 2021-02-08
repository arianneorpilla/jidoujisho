import 'package:flutter/widgets.dart';

import 'vlc_player_controller.dart';

class VlcAppLifeCycleObserver extends Object with WidgetsBindingObserver {
  VlcAppLifeCycleObserver(this._controller);

  bool _wasPlayingBeforePause = false;
  final VlcPlayerController _controller;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _wasPlayingBeforePause = _controller.value.isPlaying;
        _controller.pause();
        break;
      case AppLifecycleState.resumed:
        if (_wasPlayingBeforePause) {
          _controller.play();
        }
        break;
      default:
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
