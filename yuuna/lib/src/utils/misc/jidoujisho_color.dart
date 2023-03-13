import 'package:flutter/material.dart';

/// A class for holding values related to color. Ideally, the application
/// should handle all colors with enums stored in this class.
class JidoujishoColor {
  /// Used to filter an image to have no saturation with transparency.
  static const ColorFilter greyscaleWithAlphaFilter = ColorFilter.matrix(
    <double>[
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ],
  );

  /// Adjust a color and make it darker.
  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1, 'Needs to be in range');

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  /// Adjust a color and make it brighter.
  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1, 'Needs to be in range');

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
