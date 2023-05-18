import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spaces/spaces.dart';

/// A tag that can be clicked on for more information. Used in dictionary
/// entries to indicate information about a definition or term.
class JidoujishoTag extends StatelessWidget {
  /// Create a tag that can be clicked on for more information.
  const JidoujishoTag({
    required this.text,
    required this.backgroundColor,
    this.message,
    this.trailingText,
    this.icon,
    this.foregroundColor = Colors.white,
    this.iconSize,
    this.style,
    super.key,
  });

  /// The icon to display on the tag.
  final IconData? icon;

  /// The text to display on the tag.
  final String text;

  /// The message to show when the tag has been clicked on.
  final String? message;

  /// An extra bit to put on a rectangle on the right of the message.
  final String? trailingText;

  /// The color of the tag background.
  final Color backgroundColor;

  /// The color of the icon and text.
  final Color foregroundColor;

  /// The display size for the [icon].
  final double? iconSize;

  /// Text style to use for the [text] of the tag.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Spacing.of(context).insets.onlyRight.small,
      child: InkWell(
        onTap: message != null
            ? () {
                Fluttertoast.showToast(
                  backgroundColor: backgroundColor,
                  textColor: foregroundColor,
                  msg: message!,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            : null,
        child: Container(
          color: backgroundColor,
          padding: Spacing.of(context).insets.all.small,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: foregroundColor,
                  size: Theme.of(context).textTheme.labelSmall?.fontSize,
                ),
              if (icon != null) const Space.small(),
              Flexible(
                child: Text(
                  text,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: foregroundColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailingText != null) const Space.small(),
              if (trailingText != null)
                Flexible(
                  child: Container(
                    padding: Spacing.of(context).insets.all.extraSmall,
                    color: Colors.red.shade400,
                    child: Text(
                      trailingText!,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: foregroundColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
