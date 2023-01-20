/// A class that encapsulates a sentence and the indices for which it should
/// be highlighted. If start is not null, empty should not be null either.
class JidoujishoTextSelection {
  /// Instantiate an instance of this class.
  JidoujishoTextSelection({
    required this.text,
    this.start,
    this.end,
  });

  /// The text pertaining to the selection.
  final String text;

  /// The start of the highlighted text, inclusive.
  final int? start;

  /// The end of the highlighted text, exclusive.
  final int? end;
}
