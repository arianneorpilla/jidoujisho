part of 'epub_view.dart';

class EpubChapterViewValue {
  const EpubChapterViewValue({
    required this.chapter,
    required this.chapterNumber,
    required this.paragraphNumber,
    required this.position,
  });

  final EpubChapter? chapter;
  final int chapterNumber;
  final int paragraphNumber;
  final ItemPosition position;

  /// Chapter view in percents
  double get progress => _calcProgress(
        position.itemLeadingEdge,
        position.itemTrailingEdge,
      );
}

class ParseResult {
  const ParseResult(this.epubBook, this.chapters, this.parseResult);

  final EpubBook epubBook;
  final List<EpubChapter> chapters;
  final ParseParagraphsResult parseResult;
}
