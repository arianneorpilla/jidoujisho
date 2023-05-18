import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';

/// A button that can be set as busy. When busy, the icon is faded out when its
/// [onTap] action is on-going and processing, which can be used to
/// indicate when a button cannot be pressed once its click action has been
/// executed and is busy.
class JidoujishoIconButton extends StatefulWidget {
  /// Creates a busy icon button. Default values rely on [IconTheme].
  const JidoujishoIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.onTapDown,
    this.busy = false,
    this.enabled = true,
    this.size,
    this.shapeBorder = const CircleBorder(),
    this.backgroundColor,
    this.enabledColor,
    this.disabledColor,
    this.constraints,
    this.padding,
    this.isWideTapArea = false,
    super.key,
  });

  /// The icon to display within the button.
  final IconData icon;

  /// The size of the icon. By default, this is 24.0.
  final double? size;

  /// Enforces all icons to have a tooltip that explains the purpose of this
  /// icon for accessibility and tutorial purposes.
  final String tooltip;

  /// Whether or not this icon should have busy behaviour, locking the icon
  /// out from being pressed when its [onTap] action is on-going.
  final bool busy;

  /// The action to execute and wait for. Use when the global position is
  /// needed.
  final FutureOr<void> Function(TapDownDetails)? onTapDown;

  /// The action to execute and wait for. While enabled,
  final FutureOr<void> Function()? onTap;

  /// For configuring a custom shaped button. By default, this is a circle.
  final ShapeBorder shapeBorder;

  /// Color of the shape around the icon.
  final Color? backgroundColor;

  /// What color to show for this icon when enabled. If null, this is the
  /// theme's default icon color.
  final Color? enabledColor;

  /// What color to show for this icon when disabled. If null, this is the
  /// theme's unselected widget color.
  final Color? disabledColor;

  /// Whether the icon is clickable upon build of this widget.
  final bool enabled;

  /// Allows overriding of the standard size of the [IconButton] constraints.
  final BoxConstraints? constraints;

  /// Allows overriding of the standard size of the [IconButton] padding.
  final EdgeInsets? padding;

  /// If this button needs to act like an [IconButton] with a wide area.
  final bool isWideTapArea;

  @override
  State<StatefulWidget> createState() => _JidoujishoIconButtonState();
}

class _JidoujishoIconButtonState extends State<JidoujishoIconButton> {
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

  Color get enabledColor =>
      widget.enabledColor ?? Theme.of(context).iconTheme.color!;
  Color get disabledColor =>
      widget.disabledColor ?? Theme.of(context).unselectedWidgetColor;

  @override
  Widget build(BuildContext context) {
    if (widget.isWideTapArea) {
      return IconButton(
        constraints: BoxConstraints(
          maxWidth: Spacing.of(context).spaces.extraBig,
          maxHeight: Spacing.of(context).spaces.extraBig,
        ),
        tooltip: widget.tooltip,
        icon: Icon(
          widget.icon,
          color: enabled ? enabledColor : disabledColor,
          size: widget.size,
        ),
        onPressed: enabled
            ? () async {
                if (widget.busy) {
                  if (enabled) {
                    enabled = false;
                    if (mounted) {
                      setState(() {});
                    }
                    try {
                      await widget.onTap?.call();
                    } finally {
                      enabled = true;
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  }
                } else {
                  await widget.onTap?.call();
                }
              }
            : null,
      );
    }

    return Tooltip(
      message: widget.tooltip,
      child: InkWell(
        enableFeedback: enabled,
        customBorder: widget.shapeBorder,
        onTap: enabled
            ? () async {
                if (widget.busy) {
                  if (enabled) {
                    enabled = false;
                    if (mounted) {
                      setState(() {});
                    }
                    try {
                      await widget.onTap?.call();
                    } finally {
                      enabled = true;
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  }
                } else {
                  await widget.onTap?.call();
                }
              }
            : null,
        onTapDown: widget.onTapDown,
        child: ColoredBox(
          color: widget.backgroundColor ?? Colors.transparent,
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(8),
            child: Icon(
              widget.icon,
              size: widget.size,
              color: enabled ? enabledColor : disabledColor,
            ),
          ),
        ),
      ),
    );
  }
}
