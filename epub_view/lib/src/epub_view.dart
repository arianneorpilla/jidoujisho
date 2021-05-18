import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:epubx/epubx.dart' hide Image;
import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:flutter_html/flutter_html.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:rxdart/rxdart.dart';

import 'epub_cfi/generator.dart';
import 'epub_cfi/interpreter.dart';
import 'epub_cfi/parser.dart';

export 'package:epubx/epubx.dart' hide Image;

part 'epub_data.dart';
part 'epub_parser.dart';
part 'epub_controller.dart';
part 'epub_cfi_reader.dart';

const MIN_TRAILING_EDGE = 0.55;
const MIN_LEADING_EDGE = -0.05;

const _defaultTextStyle = TextStyle(
  height: 1.25,
  fontSize: 16,
);

typedef ChaptersBuilder = Widget Function(
  BuildContext context,
  List<EpubChapter> chapters,
  List<Paragraph> paragraphs,
  int index,
);

typedef ExternalLinkPressed = void Function(String href);

class EpubView extends StatefulWidget {
  const EpubView({
    required this.controller,
    this.itemBuilder,
    this.onExternalLinkPressed,
    this.loaderSwitchDuration,
    this.loader,
    this.errorBuilder,
    this.dividerBuilder,
    this.onChange,
    this.onDocumentLoaded,
    this.onDocumentError,
    this.chapterPadding = const EdgeInsets.all(8),
    this.paragraphPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.textStyle = _defaultTextStyle,
    Key? key,
  }) : super(key: key);

  final EpubController controller;
  final ExternalLinkPressed? onExternalLinkPressed;

  /// Show document loading error message inside [EpubView]
  final Widget Function(Exception? error)? errorBuilder;
  final Widget Function(EpubChapter value)? dividerBuilder;
  final void Function(EpubChapterViewValue? value)? onChange;

  /// Called when a document is loaded
  final void Function(EpubBook? document)? onDocumentLoaded;

  /// Called when a document loading error
  final void Function(Exception? error)? onDocumentError;
  final Duration? loaderSwitchDuration;
  final Widget? loader;
  final EdgeInsetsGeometry chapterPadding;
  final EdgeInsetsGeometry paragraphPadding;
  final ChaptersBuilder? itemBuilder;
  final TextStyle textStyle;

  @override
  _EpubViewState createState() => _EpubViewState();
}

class _EpubViewState extends State<EpubView> {
  _EpubViewLoadingState _loadingState = _EpubViewLoadingState.loading;
  Exception? _loadingError;
  ItemScrollController? _itemScrollController;
  ItemPositionsListener? _itemPositionListener;
  List<EpubChapter> _chapters = [];
  List<Paragraph> _paragraphs = [];
  EpubCfiReader? _epubCfiReader;
  EpubChapterViewValue? _currentValue;
  bool _initialized = false;

  final List<int> _chapterIndexes = [];
  final BehaviorSubject<EpubChapterViewValue?> _actualChapter =
      BehaviorSubject();
  final BehaviorSubject<bool> _bookLoaded = BehaviorSubject();

  @override
  void initState() {
    _itemScrollController = ItemScrollController();
    _itemPositionListener = ItemPositionsListener.create();
    widget.controller._attach(this);
    super.initState();
  }

  @override
  void dispose() {
    _itemPositionListener!.itemPositions.removeListener(_changeListener);
    _actualChapter.close();
    _bookLoaded.close();
    widget.controller._detach();
    super.dispose();
  }

  Future<bool> _init() async {
    if (_initialized) {
      return true;
    }
    _chapters = parseChapters(widget.controller._document!);
    final parseParagraphsResult =
        parseParagraphs(_chapters, widget.controller._document!.Content);
    _paragraphs = parseParagraphsResult.flatParagraphs;

    _chapterIndexes.addAll(parseParagraphsResult.chapterIndexes);

    _epubCfiReader = EpubCfiReader.parser(
      cfiInput: widget.controller.epubCfi,
      chapters: _chapters,
      paragraphs: _paragraphs,
    );
    _itemPositionListener!.itemPositions.addListener(_changeListener);
    _initialized = true;
    _bookLoaded.sink.add(true);

    return true;
  }

  void _changeListener() {
    if (_paragraphs.isEmpty ||
        _itemPositionListener!.itemPositions.value.isEmpty) {
      return;
    }
    final position = _itemPositionListener!.itemPositions.value.first;
    final chapterIndex = _getChapterIndexBy(
      positionIndex: position.index,
      trailingEdge: position.itemTrailingEdge,
      leadingEdge: position.itemLeadingEdge,
    );
    final paragraphIndex = _getParagraphIndexBy(
      positionIndex: position.index,
      trailingEdge: position.itemTrailingEdge,
      leadingEdge: position.itemLeadingEdge,
    );
    _currentValue = EpubChapterViewValue(
      chapter: chapterIndex >= 0 ? _chapters[chapterIndex] : null,
      chapterNumber: chapterIndex + 1,
      paragraphNumber: paragraphIndex + 1,
      position: position,
    );
    _actualChapter.sink.add(_currentValue);
    widget.onChange?.call(_currentValue);
  }

  void _gotoEpubCfi(
    String? epubCfi, {
    double alignment = 0,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  }) {
    _epubCfiReader?.epubCfi = epubCfi;
    final index = _epubCfiReader?.paragraphIndexByCfiFragment;

    if (index == null) {
      return null;
    }

    _itemScrollController?.scrollTo(
      index: index,
      duration: duration,
      alignment: alignment,
      curve: curve,
    );
  }

  void _onLinkPressed(String href, void Function(String href)? openExternal) {
    if (href.contains('://')) {
      openExternal?.call(href);
      return;
    }

    // Chapter01.xhtml#ph1_1 -> [ph1_1, Chapter01.xhtml] || [ph1_1]
    String? hrefIdRef;
    String? hrefFileName;

    if (href.contains('#')) {
      final dividedHref = href.split('#');
      if (dividedHref.length == 1) {
        hrefIdRef = href;
      } else {
        hrefFileName = dividedHref[0];
        hrefIdRef = dividedHref[1];
      }
    } else {
      hrefFileName = href;
    }

    if (hrefIdRef == null) {
      final chapter = _chapterByFileName(hrefFileName);
      if (chapter != null) {
        final cfi = _epubCfiReader?.generateCfiChapter(
          book: widget.controller._document,
          chapter: chapter,
          additional: ['/4/2'],
        );

        _gotoEpubCfi(cfi);
      }
      return;
    } else {
      final paragraph = _paragraphByIdRef(hrefIdRef);
      final chapter =
          paragraph != null ? _chapters[paragraph.chapterIndex] : null;

      if (chapter != null && paragraph != null) {
        final paragraphIndex =
            _epubCfiReader?._getParagraphIndexByElement(paragraph.element);
        final cfi = _epubCfiReader?.generateCfi(
          book: widget.controller._document,
          chapter: chapter,
          paragraphIndex: paragraphIndex,
        );

        _gotoEpubCfi(cfi);
      }

      return;
    }
  }

  Paragraph? _paragraphByIdRef(String idRef) =>
      _paragraphs.firstWhereOrNull((paragraph) {
        if (paragraph.element.id == idRef) {
          return true;
        }

        return paragraph.element.children.isNotEmpty &&
            paragraph.element.children[0].id == idRef;
      });

  EpubChapter? _chapterByFileName(String? fileName) =>
      _chapters.firstWhereOrNull((chapter) {
        if (fileName != null) {
          if (chapter.ContentFileName!.contains(fileName)) {
            return true;
          } else {
            return false;
          }
        }
        return false;
      });

  int _getChapterIndexBy({
    required int positionIndex,
    double? trailingEdge,
    double? leadingEdge,
  }) {
    final posIndex = _getAbsParagraphIndexBy(
      positionIndex: positionIndex,
      trailingEdge: trailingEdge,
      leadingEdge: leadingEdge,
    );
    final index = posIndex >= _chapterIndexes.last
        ? _chapterIndexes.length
        : _chapterIndexes.indexWhere((chapterIndex) {
            if (posIndex < chapterIndex) {
              return true;
            }
            return false;
          });

    return index - 1;
  }

  int _getParagraphIndexBy({
    required int positionIndex,
    double? trailingEdge,
    double? leadingEdge,
  }) {
    final posIndex = _getAbsParagraphIndexBy(
      positionIndex: positionIndex,
      trailingEdge: trailingEdge,
      leadingEdge: leadingEdge,
    );

    final index = _getChapterIndexBy(positionIndex: posIndex);

    if (index == -1) {
      return posIndex;
    }

    return posIndex - _chapterIndexes[index];
  }

  int _getAbsParagraphIndexBy({
    required int positionIndex,
    double? trailingEdge,
    double? leadingEdge,
  }) {
    int posIndex = positionIndex;
    if (trailingEdge != null &&
        leadingEdge != null &&
        trailingEdge < MIN_TRAILING_EDGE &&
        leadingEdge < MIN_LEADING_EDGE) {
      posIndex += 1;
    }

    return posIndex;
  }

  void _changeLoadingState(_EpubViewLoadingState state) {
    if (state == _EpubViewLoadingState.success) {
      widget.onDocumentLoaded?.call(widget.controller._document);
    } else if (state == _EpubViewLoadingState.error) {
      widget.onDocumentError?.call(_loadingError);
    }
    setState(() {
      _loadingState = state;
    });
  }

  Widget _buildDivider(EpubChapter chapter) =>
      widget.dividerBuilder?.call(chapter) ??
      Container(
        height: 56,
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0x24000000),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          chapter.Title ?? '',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _defaultItemBuilder(int index) {
    if (_paragraphs.isEmpty) {
      return Container();
    }

    return Column(
      children: <Widget>[
        HtmlWidget(
          _paragraphs[index].element.outerHtml,
          onTapUrl: (url) {
            _onLinkPressed(url, widget.onExternalLinkPressed);
          },
          textStyle: TextStyle(fontSize: 15),
          enableCaching: true,
          customWidgetBuilder: (element) {
            if (element.localName == 'img') {
              final url = element.attributes['src']!.replaceAll('../', '');
              return Image(
                image: MemoryImage(
                  Uint8List.fromList(widget
                      .controller._document!.Content!.Images![url]!.Content!),
                ),
              );
            }
          },
        ),
        // Html(
        //   data: _paragraphs[index].element.outerHtml,
        //   onLinkTap: (href, _, __, ___) =>
        //       _onLinkPressed(href!, widget.onExternalLinkPressed),
        //   style: {
        //     'html': Style(
        //       padding: widget.paragraphPadding as EdgeInsets?,
        //     ).merge(Style.fromTextStyle(widget.textStyle)),
        //   },
        //   customRender: {
        //     'img': (context, child, attributes, node) {
        //       final url = attributes['src']!.replaceAll('../', '');
        //       return Image(
        //         image: MemoryImage(
        //           Uint8List.fromList(widget
        //               .controller._document!.Content!.Images![url]!.Content!),
        //         ),
        //       );
        //     },
        //     'p': (context, child, attributes, node) {
        //       if (node!.attributes["a"] == null) {}
        //       return Container(child: child);
        //     },
        //   },
        // ),
      ],
    );
  }

  Widget _buildLoaded() {
    Widget _buildItem(BuildContext context, int index) =>
        widget.itemBuilder?.call(context, _chapters, _paragraphs, index) ??
        _defaultItemBuilder(index);

    return ScrollablePositionedList.builder(
      initialScrollIndex: _epubCfiReader!.paragraphIndexByCfiFragment ?? 0,
      itemCount: _paragraphs.length,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionListener,
      itemBuilder: _buildItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? content;

    switch (_loadingState) {
      case _EpubViewLoadingState.loading:
        content = KeyedSubtree(
          key: Key('$runtimeType.root.loading'),
          child: widget.loader ?? SizedBox(),
        );
        break;
      case _EpubViewLoadingState.error:
        content = KeyedSubtree(
          key: Key('$runtimeType.root.error'),
          child: Padding(
            padding: EdgeInsets.all(32),
            child: widget.errorBuilder?.call(_loadingError) ??
                Center(child: Text(_loadingError.toString())),
          ),
        );
        break;
      case _EpubViewLoadingState.success:
        content = KeyedSubtree(
          key: Key('$runtimeType.root.success'),
          child: _buildLoaded(),
        );
        break;
    }

    return AnimatedSwitcher(
      duration: widget.loaderSwitchDuration ?? Duration(milliseconds: 500),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: content,
    );
  }
}

enum _EpubViewLoadingState {
  loading,
  error,
  success,
}
