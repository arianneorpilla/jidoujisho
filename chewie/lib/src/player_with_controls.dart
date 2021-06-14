import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/material_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:jidoujisho/preferences.dart';
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
        ValueListenableBuilder(
          valueListenable: chewieController.isCasting,
          builder: (BuildContext context, bool isCasting, Widget child) {
            if (isCasting) {
              return Container(
                padding: EdgeInsets.only(
                  top: 60,
                  bottom: 60,
                  left: 40,
                  right: 40,
                ),
                color: Colors.black,
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraint) {
                      return new Icon(Icons.cast_connected_sharp,
                          color: Colors.white.withOpacity(0.035),
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
        (!chewieController.isFullScreen)
            ? _buildControls(context, chewieController)
            : SafeArea(
                child: _buildControls(context, chewieController),
              ),
      ],
    );
  }
}

class ResizeableWidget extends StatefulWidget {
  ResizeableWidget({this.blurWidgetNotifier, this.child});

  final ValueNotifier<BlurWidgetOptions> blurWidgetNotifier;
  final Widget child;
  @override
  _ResizeableWidgetState createState() =>
      _ResizeableWidgetState(this.blurWidgetNotifier);
}

const ballDiameter = 20.0;

class _ResizeableWidgetState extends State<ResizeableWidget> {
  _ResizeableWidgetState(this.blurWidgetNotifier);

  final ValueNotifier<BlurWidgetOptions> blurWidgetNotifier;
  double height;
  double width;
  double top;
  double left;

  @override
  void initState() {
    super.initState();
    height = blurWidgetNotifier.value.height;
    width = blurWidgetNotifier.value.width;
    top = blurWidgetNotifier.value.top;
    left = blurWidgetNotifier.value.left;
  }

  ValueNotifier<bool> visibleBalls = ValueNotifier<bool>(false);

  void onDrag(double dx, double dy) {
    var newHeight = height + dy;
    var newWidth = width + dx;

    setState(() {
      height = newHeight > 0 ? newHeight : 0;
      width = newWidth > 0 ? newWidth : 0;
    });

    showAndHide();
  }

  Future<void> showAndHide() async {
    visibleBalls.value = true;
    await Future.delayed(Duration(seconds: 3), () {});
    visibleBalls.value = false;

    BlurWidgetOptions blurWidgetOptions = getBlurWidgetOptions();
    blurWidgetOptions.height = height;
    blurWidgetOptions.width = width;
    blurWidgetOptions.top = top;
    blurWidgetOptions.left = left;

    setBlurWidgetOptions(blurWidgetOptions);
    blurWidgetNotifier.value = blurWidgetOptions;
  }

  @override
  Widget build(BuildContext context) {
    if (blurWidgetNotifier.value.top == -1 &&
        blurWidgetNotifier.value.left == -1) {
      top = MediaQuery.of(context).size.height / 2 - height / 2;
      left = MediaQuery.of(context).size.width / 2 - width / 2;
      height = 200;
      width = 200;
    }

    return ValueListenableBuilder(
        valueListenable: blurWidgetNotifier,
        builder: (BuildContext context, options, Widget child) {
          if (!blurWidgetNotifier.value.visible) {
            return Container();
          }

          Color color = blurWidgetNotifier.value.color;
          double blurRadius = blurWidgetNotifier.value.blurRadius;

          return Stack(
            children: <Widget>[
              Positioned(
                top: top,
                left: left,
                child: GestureDetector(
                  onTap: () {
                    showAndHide();
                  },
                  child: BlurryContainer(
                    borderRadius: BorderRadius.zero,
                    blur: blurRadius,
                    height: height,
                    width: width,
                    bgColor: color,
                    child: widget.child,
                  ),
                ),
              ),
              // top left
              Positioned(
                top: top - ballDiameter / 2,
                left: left - ballDiameter / 2,
                child: ManipulatingBall(
                  visibleBalls: visibleBalls,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var mid = (dx + dy) / 2;
                    var newHeight = height - 2 * mid;
                    var newWidth = width - 2 * mid;

                    setState(() {
                      height = newHeight > 0 ? newHeight : 0;
                      width = newWidth > 0 ? newWidth : 0;
                      top = top + mid;
                      left = left + mid;
                    });
                  },
                ),
              ),
              // top middle
              Positioned(
                top: top - ballDiameter / 2,
                left: left + width / 2 - ballDiameter / 2,
                child: ManipulatingBall(
                  visibleBalls: visibleBalls,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var newHeight = height - dy;

                    setState(() {
                      height = newHeight > 0 ? newHeight : 0;
                      top = top + dy;
                    });
                  },
                ),
              ),
              // top right
              Positioned(
                top: top - ballDiameter / 2,
                left: left + width - ballDiameter / 2,
                child: ManipulatingBall(
                  visibleBalls: visibleBalls,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var mid = (dx + (dy * -1)) / 2;

                    var newHeight = height + 2 * mid;
                    var newWidth = width + 2 * mid;

                    setState(() {
                      height = newHeight > 0 ? newHeight : 0;
                      width = newWidth > 0 ? newWidth : 0;
                      top = top - mid;
                      left = left - mid;
                    });
                  },
                ),
              ),
              // center right
              Positioned(
                top: top + height / 2 - ballDiameter / 2,
                left: left + width - ballDiameter / 2,
                child: ManipulatingBall(
                  visibleBalls: visibleBalls,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var newWidth = width + dx;

                    setState(() {
                      width = newWidth > 0 ? newWidth : 0;
                    });
                  },
                ),
              ),
              // bottom right
              Positioned(
                top: top + height - ballDiameter / 2,
                left: left + width - ballDiameter / 2,
                child: ManipulatingBall(
                  visibleBalls: visibleBalls,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var mid = (dx + dy) / 2;

                    var newHeight = height + 2 * mid;
                    var newWidth = width + 2 * mid;

                    setState(() {
                      height = newHeight > 0 ? newHeight : 0;
                      width = newWidth > 0 ? newWidth : 0;
                      top = top - mid;
                      left = left - mid;
                    });
                  },
                ),
              ),
              // bottom center
              Positioned(
                top: top + height - ballDiameter / 2,
                left: left + width / 2 - ballDiameter / 2,
                child: ManipulatingBall(
                  visibleBalls: visibleBalls,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var newHeight = height + dy;

                    setState(() {
                      height = newHeight > 0 ? newHeight : 0;
                    });
                  },
                ),
              ),
              // bottom left
              Positioned(
                top: top + height - ballDiameter / 2,
                left: left - ballDiameter / 2,
                child: ManipulatingBall(
                  visibleBalls: visibleBalls,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var mid = ((dx * -1) + dy) / 2;

                    var newHeight = height + 2 * mid;
                    var newWidth = width + 2 * mid;

                    setState(() {
                      height = newHeight > 0 ? newHeight : 0;
                      width = newWidth > 0 ? newWidth : 0;
                      top = top - mid;
                      left = left - mid;
                    });
                  },
                ),
              ),
              //left center
              Positioned(
                top: top + height / 2 - ballDiameter / 2,
                left: left - ballDiameter / 2,
                child: ManipulatingBall(
                  visibleBalls: visibleBalls,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var newWidth = width - dx;

                    setState(() {
                      width = newWidth > 0 ? newWidth : 0;
                      left = left + dx;
                    });
                  },
                ),
              ),
              // center center
              Positioned(
                top: top + height / 2 - ballDiameter / 2,
                left: left + width / 2 - ballDiameter / 2,
                child: ManipulatingBall(
                  visibleBalls: visibleBalls,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    setState(() {
                      top = top + dy;
                      left = left + dx;
                    });
                  },
                ),
              ),
            ],
          );
        });
  }
}

class ManipulatingBall extends StatefulWidget {
  ManipulatingBall({Key key, this.onDrag, this.showAndHide, this.visibleBalls});

  final Function onDrag;
  final Function showAndHide;
  final ValueNotifier<bool> visibleBalls;

  @override
  _ManipulatingBallState createState() =>
      _ManipulatingBallState(this.showAndHide, this.visibleBalls);
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  _ManipulatingBallState(this.showAndHide, this.visibleBalls);

  final Function showAndHide;
  final ValueNotifier<bool> visibleBalls;

  double initX;
  double initY;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
      showAndHide();
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: visibleBalls,
      builder: (BuildContext context, bool visible, Widget child) {
        return GestureDetector(
          onPanStart: _handleDrag,
          onPanUpdate: _handleUpdate,
          child: Container(
            width: ballDiameter,
            height: ballDiameter,
            decoration: BoxDecoration(
              color:
                  (visible) ? Colors.red.withOpacity(0.5) : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
