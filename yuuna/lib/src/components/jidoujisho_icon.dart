import 'dart:async';

import 'package:flutter/material.dart';

/// A button that can be set as busy. When busy, the icon is faded out when its
/// [onPressed] action is on-going and processing, which can be used to
/// indicate when a button cannot be pressed once its click action has been
/// executed and is busy.
class JidoujishoIcon extends StatefulWidget {
  /// Creates a busy icon button. Default values rely on [IconTheme].
  const JidoujishoIcon({
    required this.icon,
    required this.onPressed,
    this.busy = false,
    this.enabled = true,
    this.size,
    this.enabledColor,
    this.disabledColor,
    Key? key,
  }) : super(key: key);

  /// The icon to display within the button.
  final IconData icon;

  /// The size of the icon. By default, this is 24.0.
  final double? size;

  /// Whether or not this icon should have busy behaviour, locking the icon
  /// out from being pressed when its [onPressed] action is on-going.
  final bool busy;

  /// The action to execute and wait for. While enabled,
  final FutureOr<void> Function() onPressed;

  /// What color to show for this icon when enabled. If null, this is the
  /// theme's default icon color.
  final Color? enabledColor;

  /// What color to show for this icon when disabled. If null, this is the
  /// theme's unselected widget color.
  final Color? disabledColor;

  /// Whether the icon is clickable upon build of this widget.
  final bool enabled;

  @override
  State<StatefulWidget> createState() => _JidoujishoIconState();
}

class _JidoujishoIconState extends State<JidoujishoIcon> {
  late bool enabled;
  late Color enabledColor;
  late Color disabledColor;

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

  @override
  Widget build(BuildContext context) {
    enabledColor = widget.enabledColor ?? Theme.of(context).iconTheme.color!;
    disabledColor =
        widget.disabledColor ?? Theme.of(context).unselectedWidgetColor;

    return IconButton(
      icon: Icon(widget.icon),
      enableFeedback: !enabled,
      onPressed: enabled
          ? () async {
              if (widget.busy) {
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
              } else {
                await widget.onPressed();
              }
            }
          : null,
      color: enabled ? enabledColor : disabledColor,
      iconSize: widget.size,
    );
  }
}
