import 'package:flutter_vlc_player_platform_interface/flutter_vlc_player_platform_interface.dart';

final VlcPlayerPlatform vlcPlayerPlatform = VlcPlayerPlatform.instance
// This will clear all open videos on the platform when a full restart is
// performed.
  ..init();
