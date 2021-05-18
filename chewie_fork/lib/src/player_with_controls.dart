import 'package:chewie_fork/src/chewie_player.dart';
import 'package:chewie_fork/src/material_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:jidoujisho/util.dart';

class PlayerWithControls extends StatelessWidget {
  const PlayerWithControls({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChewieController chewieController = ChewieController.of(context);

    Widget _buildControls(
      BuildContext context,
      ChewieController chewieController,
    ) {
      return const MaterialControls();
    }

    return Stack(
      children: <Widget>[
        chewieController.placeholder ?? Container(),
        Center(
          child: SizedBox.expand(
            child: VlcPlayer(
              controller: chewieController.videoPlayerController,
              aspectRatio: chewieController.aspectRatio,
            ),
          ),
        ),
        chewieController.overlay ?? Container(),
        if (!chewieController.isFullScreen)
          _buildControls(context, chewieController)
        else
          SafeArea(
            child: _buildControls(context, chewieController),
          ),
      ],
    );
  }
}
