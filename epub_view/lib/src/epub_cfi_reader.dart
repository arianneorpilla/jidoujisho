part of 'epub_view.dart';

class EpubCfiReader {
  EpubCfiReader()
      : cfiInput = null,
        chapters = [],
        paragraphs = [];

  EpubCfiReader.parser({
    required this.cfiInput,
    required this.chapters,
    required this.paragraphs,
  });

  String? cfiInput;
  final List<EpubChapter> chapters;
  final List<Paragraph> paragraphs;

  CfiFragment? _cfiFragment;
  int? _lastParagraphIndex;

  set epubCfi(String? epubCfi) {
    cfiInput = epubCfi;
    _lastParagraphIndex = null;
  }

  int? get paragraphIndexByCfiFragment {
    if (_lastParagraphIndex == null && cfiInput != null) {
      try {
        _cfiFragment = EpubCfiParser().parse(cfiInput, 'fragment');
        _lastParagraphIndex = _paragraphIndexByCfiFragment(_cfiFragment);
      } catch (e) {
        _lastParagraphIndex = null;
      }
    }
    return _lastParagraphIndex;
  }

  int? _paragraphIndexByCfiFragment(CfiFragment? cfiFragment) {
    if (cfiFragment == null ||
        cfiFragment.path?.localPath?.steps == null ||
        cfiFragment.path!.localPath!.steps!.isEmpty) {
      return null;
    }

    final int chapterIndex =
        _getChapterIndexBy(cfiStep: cfiFragment.path!.localPath!.steps!.first)!;
    final chapter = chapters[chapterIndex];
    final document = chapterDocument(chapter);
    if (document == null) {
      return null;
    }
    final element = EpubCfiInterpreter().searchLocalPathForHref(
      document.documentElement,
      cfiFragment.path!.localPath!,
    );
    final int? paragraphNumber = _getParagraphIndexByElement(element);

    return paragraphNumber;
  }

  String? _cfiChapter({
    required EpubBook? book,
    required EpubChapter? chapter,
    EpubCfiGenerator generator = const EpubCfiGenerator(),
  }) {
    if (book == null || chapter == null) {
      return null;
    }
    final document = chapterDocument(chapter);
    if (document == null) {
      return null;
    }

    return generator.generatePackageDocumentCFIComponent(
        chapter, book.Schema!.Package!);
  }

  String? generateCfi({
    required EpubBook? book,
    required EpubChapter? chapter,
    required int? paragraphIndex,
    List<String> additional = const [],
    EpubCfiGenerator generator = const EpubCfiGenerator(),
  }) {
    if (paragraphIndex == null) {
      return null;
    }

    final currentNode = paragraphs[paragraphIndex].element;

    final packageDocumentCFIComponent = _cfiChapter(
      book: book,
      chapter: chapter,
      generator: generator,
    );

    final contentDocumentCFIComponent =
        generator.generateElementCFIComponent(currentNode);

    return generator.generateCompleteCFI([
      packageDocumentCFIComponent,
      contentDocumentCFIComponent,
      ...additional,
    ]);
  }

  String generateCfiChapter({
    required EpubBook? book,
    required EpubChapter chapter,
    List<String> additional = const [],
    EpubCfiGenerator generator = const EpubCfiGenerator(),
  }) {
    final packageDocumentCFIComponent = _cfiChapter(
      book: book,
      chapter: chapter,
      generator: generator,
    );

    return generator.generateCompleteCFI([
      packageDocumentCFIComponent,
      ...additional,
    ]);
  }

  dom.Document? chapterDocument(EpubChapter? chapter) {
    if (chapter == null) {
      return null;
    }
    final html = chapter.HtmlContent!.replaceAllMapped(
        RegExp(r'<\s*([^\s>]+)([^>]*)\/\s*>'),
        (match) => '<${match.group(1)}${match.group(2)}></${match.group(1)}>');
    final regExp = RegExp(
      r'<body.*?>.+?</body>',
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    );
    final matches = regExp.firstMatch(html)!;

    return parse(matches.group(0));
  }

  int? _getChapterIndexBy({CfiStep? cfiStep}) {
    if (cfiStep == null) {
      return null;
    }

    final index = chapters.indexWhere(
      (chapter) =>
          chapter.Anchor == cfiStep.idAssertion ||
          chapter.ContentFileName!.contains(cfiStep.idAssertion!),
    );

    if (index == -1) {
      return null;
    }

    return index;
  }

  int? _getParagraphIndexByElement(dom.Element? element) {
    if (element == null) {
      return null;
    }

    final index = paragraphs.indexWhere(
        (paragraph) => paragraph.element.outerHtml == element.outerHtml);

    if (index == -1) {
      return null;
    }

    return index;
  }
}
