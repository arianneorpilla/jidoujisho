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
}
