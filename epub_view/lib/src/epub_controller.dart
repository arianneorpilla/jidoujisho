part of 'epub_view.dart';

class EpubController {
  EpubController({
    required this.document,
    this.epubCfi,
  });

  Future<EpubBook> document;
  final String? epubCfi;

  _EpubViewState? _epubViewState;
  List<EpubViewChapter>? _cacheTableOfContents;

  final BehaviorSubject<EpubChapterViewValue?> _valueStreamController =
      BehaviorSubject<EpubChapterViewValue?>();

  final BehaviorSubject<List<EpubViewChapter>?>
      _tableOfContentsStreamController =
      BehaviorSubject<List<EpubViewChapter>?>();

  EpubBook? _document;

  EpubChapterViewValue? get currentValue => _epubViewState?._currentValue;

  bool? get isBookLoaded => _epubViewState?._initialized;

  Stream<EpubChapterViewValue?> get currentValueStream =>
      _valueStreamController.stream;

  Stream<List<EpubViewChapter>?> get tableOfContentsStream =>
      _tableOfContentsStreamController.stream;

  void jumpTo({required int index, double alignment = 0}) =>
      _epubViewState?._itemScrollController?.jumpTo(
        index: index,
        alignment: alignment,
      );

  Future<void>? scrollTo({
    required int index,
    Duration duration = const Duration(milliseconds: 250),
    double alignment = 0,
    Curve curve = Curves.linear,
  }) =>
      _epubViewState?._itemScrollController?.scrollTo(
        index: index,
        duration: duration,
        alignment: alignment,
        curve: curve,
      );

  void gotoEpubCfi(
    String epubCfi, {
    double alignment = 0,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  }) {
    _epubViewState?._gotoEpubCfi(
      epubCfi,
      alignment: alignment,
      duration: duration,
      curve: curve,
    );
  }

  String? generateEpubCfi() => _epubViewState?._epubCfiReader?.generateCfi(
        book: _document,
        chapter: _epubViewState?._currentValue?.chapter,
        paragraphIndex: _epubViewState?._getAbsParagraphIndexBy(
          positionIndex: _epubViewState?._currentValue?.position.index ?? 0,
          trailingEdge:
              _epubViewState?._currentValue?.position.itemTrailingEdge,
          leadingEdge: _epubViewState?._currentValue?.position.itemLeadingEdge,
        ),
      );

  List<EpubViewChapter>? tableOfContents() {
    if (_cacheTableOfContents != null) {
      return _cacheTableOfContents;
    }

    if (_document == null) {
      return [];
    }

    int index = -1;

    return _cacheTableOfContents =
        _document!.Chapters!.fold<List<EpubViewChapter>>(
      [],
      (acc, next) {
        index += 1;
        acc.add(EpubViewChapter(next.Title, _getChapterStartIndex(index)));
        for (final subChapter in next.SubChapters!) {
          index += 1;
          acc.add(EpubViewSubChapter(
              subChapter.Title, _getChapterStartIndex(index)));
        }
        return acc;
      },
    );
  }

  int _getChapterStartIndex(int index) =>
      index < _epubViewState!._chapterIndexes.length
          ? _epubViewState!._chapterIndexes[index]
          : 0;

  Future<void> loadDocument(Future<EpubBook> document) {
    this.document = document;
    return _loadDocument(document);
  }

  Future<void> _loadDocument(Future<EpubBook> document) async {
    _epubViewState!._initialized = false;
    try {
      _epubViewState!._changeLoadingState(_EpubViewLoadingState.loading);
      _document = await document;
      await _epubViewState!._init();
      _epubViewState!._actualChapter.stream.listen((chapter) {
        _valueStreamController.sink.add(chapter);
      });
      _tableOfContentsStreamController.sink.add(tableOfContents());
      _epubViewState!._changeLoadingState(_EpubViewLoadingState.success);
    } catch (error) {
      _epubViewState!
        .._loadingError = error is Exception
            ? error
            : Exception('An unexpected error occurred')
        .._changeLoadingState(_EpubViewLoadingState.error);
    }
  }

  void _attach(_EpubViewState epubReaderViewState) {
    _epubViewState = epubReaderViewState;

    _loadDocument(document);
  }

  void _detach() {
    _epubViewState = null;
  }

  void dispose() {
    _epubViewState = null;
  }
}

class EpubViewChapter {
  EpubViewChapter(this.title, this.startIndex);

  final String? title;
  final int startIndex;

  String get type => this is EpubViewSubChapter ? 'subchapter' : 'chapter';

  @override
  String toString() => '$type: {title: $title, startIndex: $startIndex}';
}

class EpubViewSubChapter extends EpubViewChapter {
  EpubViewSubChapter(String? title, int startIndex) : super(title, startIndex);
}

double _calcProgress(double leadingEdge, double trailingEdge) {
  final itemLeadingEdgeAbsolute = leadingEdge.abs();
  final fullHeight = itemLeadingEdgeAbsolute + trailingEdge;
  final heightPercent = fullHeight / 100;
  return itemLeadingEdgeAbsolute / heightPercent;
}
