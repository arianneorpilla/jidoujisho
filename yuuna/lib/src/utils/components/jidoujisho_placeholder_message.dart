import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';

/// Used to show information or error messages across the application.
/// For example, this is used for the empty placeholder messages on the home
/// tabs when there are no media item entries in them.
class JidoujishoPlaceholderMessage extends StatelessWidget {
  /// Instantiate a decorative information/error message with an icon.
  const JidoujishoPlaceholderMessage({
    required this.icon,
    required this.message,
    this.color,
    this.iconSize,
    this.messageStyle,
    Key? key,
  }) : super(key: key);

  /// Decorative icon that is appropriate to relay the message even
  /// if a user may not understand the message.
  final IconData icon;

  /// A message to be shown below the icon that briefly explains the
  /// information or error to be relayed to the user.
  final String message;

  /// The color to be used for the icon and the message, if null,
  /// this is the unselected widget color defined by the app theme.
  final Color? color;

  /// The size of the icon in logical pixels.
  final double? iconSize;

  /// The text style to be used to display the message below the icon.
  final TextStyle? messageStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: Theme.of(context).textTheme.headlineMedium?.fontSize,
          color: color ?? Theme.of(context).unselectedWidgetColor,
        ),
        const Space.small(),
        Text(
          message,
          textAlign: TextAlign.center,
          style: messageStyle ??
              Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: color ?? Theme.of(context).unselectedWidgetColor,
                  ),
        )
      ],
    );
  }
}
