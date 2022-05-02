import 'package:flutter/material.dart';

class BusyIconButton extends StatefulWidget {
  const BusyIconButton({
    required this.icon,
    required this.onPressed,
    required this.iconSize,
    this.enabledColor,
    this.disabledColor,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  final Icon icon;
  final double iconSize;
  final Future<void> Function() onPressed;
  final Color? enabledColor;
  final Color? disabledColor;
  final bool enabled;

  @override
  State<StatefulWidget> createState() => BusyIconButtonState();
}

class BusyIconButtonState extends State<BusyIconButton> {
  late bool enabled;

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    enabled = widget.enabled;
  }

  @override
  void initState() {
    super.initState();
    enabled = widget.enabled;
  }

  late Color enabledColor;
  late Color disabledColor;

  @override
  Widget build(BuildContext context) {
    enabledColor = widget.enabledColor ?? Theme.of(context).iconTheme.color!;
    disabledColor =
        widget.disabledColor ?? Theme.of(context).unselectedWidgetColor;

    return IconButton(
      icon: widget.icon,
      enableFeedback: !enabled,
      onPressed: () async {
        if (enabled) {
          setState(() {
            enabled = false;
          });
          try {
            await widget.onPressed();
          } finally {
            setState(() {
              enabled = true;
            });
          }
        }
      },
      color: (enabled) ? enabledColor : disabledColor,
      iconSize: widget.iconSize,
    );
  }
}
