import 'package:flutter/material.dart';

/// Text and a range for a highlighted selection.
class JidoujishoTextSelection {
  /// Initialise an instance of this entity.
  JidoujishoTextSelection({
    required this.text,
    this.range = TextRange.empty,
  });

  /// Text that has a length valid within range.
  final String text;

  /// Highlighted text range.
  final TextRange range;

  /// Text before the highlighted text.
  String get textBefore {
    if (range == TextRange.empty) {
      return '';
    }

    return range.textBefore(text);
  }

  /// Text after the highlighted text.
  String get textAfter {
    if (range == TextRange.empty) {
      return '';
    }

    return range.textAfter(text);
  }

  /// Highlighted text.
  String get textInside {
    if (range == TextRange.empty) {
      return '';
    }

    return range.textInside(text);
  }

  @override
  String toString() {
    return '''
JidoujishoTextSelection(
  text: $text
  range: $range
  before: $textBefore
  inside: $textInside
  after: $textAfter
)
''';
  }
}
