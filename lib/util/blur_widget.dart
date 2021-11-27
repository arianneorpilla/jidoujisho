import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:chisa/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class BlurWidgetOptions {
  double width;
  double height;
  double left;
  double top;
  Color color;
  double blurRadius;
  bool visible;

  BlurWidgetOptions(
    this.width,
    this.height,
    this.left,
    this.top,
    this.color,
    this.blurRadius,
    this.visible,
  );
}

class ResizeableWidget extends StatefulWidget {
  const ResizeableWidget({
    required this.context,
    required this.blurWidgetNotifier,
    Key? key,
  }) : super(key: key);

  final BuildContext context;
  final ValueNotifier<BlurWidgetOptions> blurWidgetNotifier;
  @override
  ResizeableWidgetState createState() => ResizeableWidgetState();
}

const ballDiameter = 28.0;

class ResizeableWidgetState extends State<ResizeableWidget> {
  late ValueNotifier<BlurWidgetOptions> blurWidgetNotifier;

  late AppModel appModel;

  late double height;
  late double width;
  late double top;
  late double left;

  @override
  void initState() {
    super.initState();
    blurWidgetNotifier = widget.blurWidgetNotifier;

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
    await Future.delayed(const Duration(seconds: 3), () {});
    visibleBalls.value = false;

    BlurWidgetOptions blurWidgetOptions = appModel.getBlurWidgetOptions();
    blurWidgetOptions.height = height;
    blurWidgetOptions.width = width;
    blurWidgetOptions.top = top;
    blurWidgetOptions.left = left;

    blurWidgetNotifier.value = blurWidgetOptions;
    appModel.setBlurWidgetOptions(blurWidgetOptions);
  }

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    return ValueListenableBuilder(
        valueListenable: widget.blurWidgetNotifier,
        builder: (BuildContext context, options, _) {
          if (!blurWidgetNotifier.value.visible) {
            return Container();
          }

          if (blurWidgetNotifier.value.top == -1 ||
              blurWidgetNotifier.value.left == -1) {
            height = 150;
            width = 150;
            top = MediaQuery.of(context).size.height / 4 - height / 2;
            left = MediaQuery.of(context).size.height / 2 - height / 2;
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
                    child: const SizedBox.shrink(),
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
  const ManipulatingBall({
    required this.onDrag,
    required this.showAndHide,
    required this.visibleBalls,
    Key? key,
  }) : super(key: key);

  final Function onDrag;
  final Function showAndHide;
  final ValueNotifier<bool> visibleBalls;

  @override
  ManipulatingBallState createState() => ManipulatingBallState();
}

class ManipulatingBallState extends State<ManipulatingBall> {
  ManipulatingBallState();

  late double initX;
  late double initY;

  handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
      widget.showAndHide();
    });
  }

  handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.visibleBalls,
      builder: (BuildContext context, bool visible, _) {
        return GestureDetector(
          onPanStart: handleDrag,
          onPanUpdate: handleUpdate,
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

Future<void> showBlurWidgetOptionsDialog(
  BuildContext context,
  ValueNotifier<BlurWidgetOptions> blurWidgetNotifier,
) async {
  AppModel appModel = Provider.of<AppModel>(context, listen: false);

  BlurWidgetOptions blurWidgetOptions = appModel.getBlurWidgetOptions();
  Color widgetColor = blurWidgetOptions.color;
  TextEditingController blurrinessController =
      TextEditingController(text: blurWidgetOptions.blurRadius.toString());

  Future<void> setValues() async {
    String blurrinessText = blurrinessController.text;
    double? newBlurriness = double.tryParse(blurrinessText);

    if (newBlurriness != null && newBlurriness >= 0) {
      BlurWidgetOptions blurWidgetOptions = appModel.getBlurWidgetOptions();
      blurWidgetOptions.blurRadius = newBlurriness;
      blurWidgetOptions.color = widgetColor;

      blurWidgetNotifier.value = blurWidgetOptions;
      await appModel.setBlurWidgetOptions(blurWidgetOptions);

      Navigator.pop(context);
    }
  }

  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * (2 / 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColorPicker(
                    pickerColor: widgetColor,
                    onColorChanged: (newColor) async {
                      widgetColor = newColor;
                    },
                    showLabel: true,
                    pickerAreaHeightPercent: 0.8,
                  ),
                  TextField(
                    controller: blurrinessController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: true,
                    ),
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText:
                          appModel.translate("player_option_blur_radius"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                appModel.translate("dialog_cancel"),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                appModel.translate("dialog_set"),
              ),
              onPressed: () async {
                await setValues();
              },
            ),
          ],
        );
      });
}
