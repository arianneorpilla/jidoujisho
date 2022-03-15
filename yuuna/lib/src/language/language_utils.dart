/// Extra methods for [RegExp].
extension RegExpExtension on RegExp {
  /// Given text, get all instances of the text split according to this
  /// [RegExp].
  List<String> allMatchesWithSep(String text, [int start = 0]) {
    var result = <String>[];
    for (var match in allMatches(text, start)) {
      result.add(text.substring(start, match.start));
      result.add(match[0] ?? '');
      start = match.end;
    }
    result.add(text.substring(start));
    return result;
  }
}

/// Extra methods for [String].
extension StringExtension on String {
  /// Split a String with a certain pattern, but keep the delimiters.
  List<String> splitWithDelim(RegExp pattern) =>
      pattern.allMatchesWithSep(this);
}
