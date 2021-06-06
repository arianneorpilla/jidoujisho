import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/material_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

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
        ValueListenableBuilder(
          valueListenable: chewieController.isCasting,
          builder: (BuildContext context, bool isCasting, Widget child) {
            if (isCasting) {
              return Container(
                padding: EdgeInsets.only(top: 60, bottom: 60),
                color: Colors.black,
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraint) {
                      return new Icon(Icons.cast_connected_sharp,
                          color: Colors.white.withOpacity(0.05),
                          size: constraint.biggest.height);
                    },
                  ),
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          },
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
