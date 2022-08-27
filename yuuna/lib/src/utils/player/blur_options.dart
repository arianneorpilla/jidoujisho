import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/models.dart';

/// Settings that are persisted for the blur widget used in the player.
class BlurOptions {
  /// Initialise this object.
  BlurOptions({
    required this.width,
    required this.height,
    required this.left,
    required this.top,
    required this.color,
    required this.blurRadius,
    required this.visible,
  });

  /// Width of the blur widget.
  double width;

  /// Height of the blur weight.
  double height;

  /// Horizontal position of the blur widget.
  double left;

  /// Vertical positon of the blur widget.
  double top;

  /// Background color of the blur widget.
  Color color;

  /// Blur radius of the blur widget.
  double blurRadius;

  /// Whether or not the blur widget is visible.
  bool visible;
}

/// Blur widget used in the player.
class ResizeableWidget extends ConsumerStatefulWidget {
  /// Initialise this object.
  const ResizeableWidget({
    required this.notifier,
    super.key,
  });

  /// Used to update the widget when the options are changed.
  final ValueNotifier<BlurOptions> notifier;

  @override
  ConsumerState<ResizeableWidget> createState() => _ResizeableWidgetState();
}

class _ResizeableWidgetState extends ConsumerState<ResizeableWidget> {
  late ValueNotifier<BlurOptions> _notifier;

  late double _height;
  late double _width;
  late double _top;
  late double _left;

  final ValueNotifier<bool> _visibleBallsNotifier = ValueNotifier<bool>(false);

  /// Used as the size of the resize buttons.
  static const double ballDiameter = 28;

  @override
  void initState() {
    super.initState();
    _notifier = widget.notifier;

    _height = _notifier.value.height;
    _width = _notifier.value.width;
    _top = _notifier.value.top;
    _left = _notifier.value.left;
  }

  void onDrag(double dx, double dy) {
    var newHeight = _height + dy;
    var newWidth = _width + dx;

    setState(() {
      _height = newHeight > 0 ? newHeight : 0;
      _width = newWidth > 0 ? newWidth : 0;
    });

    showAndHide();
  }

  Future<void> showAndHide() async {
    AppModel appModel = ref.watch(appProvider);

    _visibleBallsNotifier.value = true;
    await Future.delayed(const Duration(seconds: 3), () {});
    _visibleBallsNotifier.value = false;

    BlurOptions blurWidgetOptions = appModel.blurOptions;
    blurWidgetOptions.height = _height;
    blurWidgetOptions.width = _width;
    blurWidgetOptions.top = _top;
    blurWidgetOptions.left = _left;

    _notifier.value = blurWidgetOptions;
    appModel.setBlurOptions(blurWidgetOptions);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.notifier,
        builder: (context, options, _) {
          if (!_notifier.value.visible) {
            return Container();
          }

          if (_notifier.value.top == -1 || _notifier.value.left == -1) {
            _height = 150;
            _width = 150;
            _top = MediaQuery.of(context).size.height / 4 - _height / 2;
            _left = MediaQuery.of(context).size.height / 2 - _height / 2;
          }

          Color color = _notifier.value.color;
          double blurRadius = _notifier.value.blurRadius;

          return Stack(
            children: <Widget>[
              Positioned(
                top: _top,
                left: _left,
                child: GestureDetector(
                  onTap: showAndHide,
                  child: BlurryContainer(
                    borderRadius: BorderRadius.zero,
                    blur: blurRadius,
                    height: _height,
                    width: _width,
                    bgColor: color,
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),
              // top left
              Positioned(
                top: _top - ballDiameter / 2,
                left: _left - ballDiameter / 2,
                child: ManipulatingBall(
                  notifier: _visibleBallsNotifier,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var mid = (dx + dy) / 2;
                    var newHeight = _height - 2 * mid;
                    var newWidth = _width - 2 * mid;

                    setState(() {
                      _height = newHeight > 0 ? newHeight : 0;
                      _width = newWidth > 0 ? newWidth : 0;
                      _top = _top + mid;
                      _left = _left + mid;
                    });
                  },
                ),
              ),
              // top middle
              Positioned(
                top: _top - ballDiameter / 2,
                left: _left + _width / 2 - ballDiameter / 2,
                child: ManipulatingBall(
                  notifier: _visibleBallsNotifier,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var newHeight = _height - dy;

                    setState(() {
                      _height = newHeight > 0 ? newHeight : 0;
                      _top = _top + dy;
                    });
                  },
                ),
              ),
              // top right
              Positioned(
                top: _top - ballDiameter / 2,
                left: _left + _width - ballDiameter / 2,
                child: ManipulatingBall(
                  notifier: _visibleBallsNotifier,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var mid = (dx + (dy * -1)) / 2;

                    var newHeight = _height + 2 * mid;
                    var newWidth = _width + 2 * mid;

                    setState(() {
                      _height = newHeight > 0 ? newHeight : 0;
                      _width = newWidth > 0 ? newWidth : 0;
                      _top = _top - mid;
                      _left = _left - mid;
                    });
                  },
                ),
              ),
              // center right
              Positioned(
                top: _top + _height / 2 - ballDiameter / 2,
                left: _left + _width - ballDiameter / 2,
                child: ManipulatingBall(
                  notifier: _visibleBallsNotifier,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var newWidth = _width + dx;

                    setState(() {
                      _width = newWidth > 0 ? newWidth : 0;
                    });
                  },
                ),
              ),
              // bottom right
              Positioned(
                top: _top + _height - ballDiameter / 2,
                left: _left + _width - ballDiameter / 2,
                child: ManipulatingBall(
                  notifier: _visibleBallsNotifier,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var mid = (dx + dy) / 2;

                    var newHeight = _height + 2 * mid;
                    var newWidth = _width + 2 * mid;

                    setState(() {
                      _height = newHeight > 0 ? newHeight : 0;
                      _width = newWidth > 0 ? newWidth : 0;
                      _top = _top - mid;
                      _left = _left - mid;
                    });
                  },
                ),
              ),
              // bottom center
              Positioned(
                top: _top + _height - ballDiameter / 2,
                left: _left + _width / 2 - ballDiameter / 2,
                child: ManipulatingBall(
                  notifier: _visibleBallsNotifier,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var newHeight = _height + dy;

                    setState(() {
                      _height = newHeight > 0 ? newHeight : 0;
                    });
                  },
                ),
              ),
              // bottom left
              Positioned(
                top: _top + _height - ballDiameter / 2,
                left: _left - ballDiameter / 2,
                child: ManipulatingBall(
                  notifier: _visibleBallsNotifier,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var mid = ((dx * -1) + dy) / 2;

                    var newHeight = _height + 2 * mid;
                    var newWidth = _width + 2 * mid;

                    setState(() {
                      _height = newHeight > 0 ? newHeight : 0;
                      _width = newWidth > 0 ? newWidth : 0;
                      _top = _top - mid;
                      _left = _left - mid;
                    });
                  },
                ),
              ),
              //left center
              Positioned(
                top: _top + _height / 2 - ballDiameter / 2,
                left: _left - ballDiameter / 2,
                child: ManipulatingBall(
                  notifier: _visibleBallsNotifier,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    var newWidth = _width - dx;

                    setState(() {
                      _width = newWidth > 0 ? newWidth : 0;
                      _left = _left + dx;
                    });
                  },
                ),
              ),
              // center center
              Positioned(
                top: _top + _height / 2 - ballDiameter / 2,
                left: _left + _width / 2 - ballDiameter / 2,
                child: ManipulatingBall(
                  notifier: _visibleBallsNotifier,
                  showAndHide: showAndHide,
                  onDrag: (dx, dy) {
                    setState(() {
                      _top = _top + dy;
                      _left = _left + dx;
                    });
                  },
                ),
              ),
            ],
          );
        });
  }
}

/// Used for balls used to resize the [ResizeableWidget].
class ManipulatingBall extends StatefulWidget {
  /// Initialise this object.
  const ManipulatingBall({
    required this.onDrag,
    required this.showAndHide,
    required this.notifier,
    super.key,
  });

  /// Function executed when widget is dragged.
  final Function(double, double) onDrag;

  /// Function that shows and hides widget.
  final VoidCallback showAndHide;

  /// Used to update visibility of balls.
  final ValueNotifier<bool> notifier;

  @override
  State<ManipulatingBall> createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  _ManipulatingBallState();

  late double _x;
  late double _y;

  /// Used as the size of the resize buttons.
  static const double ballDiameter = 28;

  void handleDrag(DragStartDetails details) {
    setState(() {
      _x = details.globalPosition.dx;
      _y = details.globalPosition.dy;
      widget.showAndHide();
    });
  }

  void handleUpdate(DragUpdateDetails details) {
    var dx = details.globalPosition.dx - _x;
    var dy = details.globalPosition.dy - _y;
    _x = details.globalPosition.dx;
    _y = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.notifier,
      builder: (context, visible, _) {
        return GestureDetector(
          onPanStart: handleDrag,
          onPanUpdate: handleUpdate,
          child: Container(
            width: ballDiameter,
            height: ballDiameter,
            decoration: BoxDecoration(
              color: visible ? Colors.red.withOpacity(0.5) : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
