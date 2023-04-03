import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/utils.dart';

/// Used for various dialogs, such as the dictionary, profiles and enhancements
/// menus. Used for listing, selecting and reordering items.
class JidoujishoListTile extends StatelessWidget {
  /// Initialise this widget.
  const JidoujishoListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    this.foregroundColor,
    this.onTap,
    this.trailing,
    super.key,
  });

  /// Whether or not this title is currently selected.
  final bool selected;

  /// The primary text of this tile.
  final String title;

  /// The secondary text of this tile.
  final String subtitle;

  /// The icon to show as the leading content of this tile.
  final IconData icon;

  /// The foreground color affecting the text and icon of this tile.
  final Color? foregroundColor;

  /// The action to perform if this tile is tapped.
  final Function()? onTap;

  /// Widget shown at the end of the tile. Shown only when selected.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        contentPadding: Spacing.of(context).insets.onlyLeft.semiBig,
        dense: true,
        selected: selected,
        leading: Icon(
          icon,
          color:
              foregroundColor ?? Theme.of(context).textTheme.bodyMedium?.color,
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  JidoujishoMarquee(
                    text: title,
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium?.fontSize,
                        color: foregroundColor),
                  ),
                  JidoujishoMarquee(
                    text: subtitle,
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelSmall?.fontSize,
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null && selected) trailing!,
            const Space.semiSmall(),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
