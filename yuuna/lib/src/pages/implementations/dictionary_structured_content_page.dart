import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:path/path.dart' as path;
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/utils.dart';

/// Provides and caches the processed HTML of a [DictionaryEntry] to improve
/// performance.
final dictionaryEntryHtmlProvider =
    Provider.family<String, DictionaryEntry>((ref, entry) {
  return entry.definitions
      .map((e) {
        try {
          final node =
              StructuredContent.processContent(jsonDecode(e))?.toNode();
          if (node == null) {
            return '';
          }

          final document = dom.Document.html('');
          document.body?.append(node);
          final html = document.body?.innerHtml ?? '';

          return html;
        } catch (_) {
          return e.replaceAll('\n', '<br>');
        }
      })
      .toList()
      .join('<br>');
});

/// Get the [Directory] used as a resource directory for a certain [Dictionary].
final dictionaryResourceDirectoryProvider =
    Provider.family<Directory, int>((ref, dictionaryId) {
  final appModel = ref.watch(appProvider);

  return Directory(
      path.join(appModel.dictionaryResourceDirectory.path, '$dictionaryId'));
});

/// HTML renderer for dictionary definitions.
class DictionaryHtmlWidget extends ConsumerWidget {
  /// Create an instance of this page.
  const DictionaryHtmlWidget({
    required this.entry,
    required this.onSearch,
    super.key,
  });

  /// Dictionary entry to be rendered.
  final DictionaryEntry entry;

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final linkColor = Theme.of(context).colorScheme.error;
    final dictionaryFontSize = ref.read(appProvider).dictionaryFontSize;
    final fontSize = FontSize(dictionaryFontSize);
    const tableWidth = 0.3;
    final tableBorder = Border.all(color: textColor, width: tableWidth);
    final tableStyle = Style(
      border: tableBorder,
    );

    return Html(
      data: ref.watch(dictionaryEntryHtmlProvider(entry)),
      shrinkWrap: true,
      onAnchorTap: (url, attributes, element) {
        onSearch.call(attributes['query'] ?? element?.text ?? 'f');
      },
      style: {
        '*': Style(
          fontSize: fontSize,
          color: textColor,
        ),
        'td': tableStyle,
        'th': tableStyle,
        'ul': Style(
          padding: HtmlPaddings.zero,
        ),
        'li': Style(
          padding: HtmlPaddings.zero,
        ),
        'a': Style(color: linkColor),
      },
      extensions: [
        const TableHtmlExtension(),
        ImageExtension.inline(
          networkSchemas: {'jidoujisho'},
          builder: (extensionContext) => WidgetSpan(
            child: JidoujishoDictionaryImage(
              entry: entry,
              extensionContext: extensionContext,
            ),
          ),
        ),
      ],
    );
  }
}

/// Handles image rendering of images in a dictionary definition.
class JidoujishoDictionaryImage extends ConsumerWidget {
  /// Initialise this widget.
  const JidoujishoDictionaryImage({
    required this.entry,
    required this.extensionContext,
    super.key,
  });

  /// Dictionary entry to be rendered.
  final DictionaryEntry entry;

  /// Provides attributes for building the image.
  final ExtensionContext extensionContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final src = (extensionContext.attributes['src'] ?? '')
        .replaceFirst('jidoujisho://', '');

    final width = double.tryParse((extensionContext.attributes['width'] ?? '')
        .replaceAll(RegExp(r'\D'), ''));
    final height = double.tryParse((extensionContext.attributes['height'] ?? '')
        .replaceAll(RegExp(r'\D'), ''));

    final directory = ref
        .read(dictionaryResourceDirectoryProvider(entry.dictionary.value!.id));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.file(
          File(path.join(directory.path, src)),
          height: height,
          width: width,
          scale: 3,
        )
      ],
    );
  }
}

/// Special delegate for text selection from a dictionary search result.
class DictionarySelectionDelegate
    extends MultiSelectableSelectionContainerDelegate {
  /// Initialise this widget.
  DictionarySelectionDelegate({
    required this.onTextSelectionGuessLength,
  });

  /// Callback with a [JidoujishoTextSelection] which contains the text of all
  /// selectables as well as a [TextRange] representing the substring to use
  /// for dictionary search. Returns the guess length of the text selection.
  final JidoujishoTextSelection Function(JidoujishoTextSelection)
      onTextSelectionGuessLength;

  // This method is called when newly added selectable is in the current
  // selected range.
  @override
  void ensureChildUpdated(Selectable selectable) {}

  /// Handles a [JidoujishoTextSelection].
  SelectionResult handleTextSelection(
      SelectWordSelectionEvent event, JidoujishoTextSelection selection) {
    handleClearSelection(const ClearSelectionEvent());

    super.handleSelectWord(event);
    while ((getSelectedContent()?.plainText ?? '').length > 1) {
      super.handleGranularlyExtendSelection(
        const GranularlyExtendSelectionEvent(
            forward: false,
            isEnd: true,
            granularity: TextGranularity.character),
      );
    }

    final highlightLength = selection.textInside.length;

    SelectionResult? result;
    for (int i = 0; i < highlightLength - 1; i++) {
      result = super.handleGranularlyExtendSelection(
        const GranularlyExtendSelectionEvent(
          forward: true,
          isEnd: true,
          granularity: TextGranularity.character,
        ),
      );
    }

    return result ?? super.handleSelectWord(event);
  }

  @override
  SelectionResult dispatchSelectionEvent(SelectionEvent event) {
    // _expectSearchSelection = event is SelectWordSelectionEvent;
    return super.dispatchSelectionEvent(event);
  }

  //  bool _expectSearchSelection = false;
  SelectionEvent? _lastEvent;
  JidoujishoTextSelection? _guessSelection;
  JidoujishoTextSelection? _searchSelection;

  @override
  SelectionResult handleSelectWord(SelectWordSelectionEvent event) {
    if (_searchSelection != null && _lastEvent == event) {
      final selection = _searchSelection;
      _searchSelection = null;

      final startDiff = selection!.range.start - _guessSelection!.range.start;
      final endDiff = selection.range.end - _guessSelection!.range.end;

      SelectionResult? result;
      for (int i = 0; i < startDiff.abs(); i++) {
        result = super.handleGranularlyExtendSelection(
          GranularlyExtendSelectionEvent(
            forward: !startDiff.isNegative,
            isEnd: true,
            granularity: TextGranularity.character,
          ),
        );
      }

      for (int i = 0; i < endDiff.abs(); i++) {
        result = super.handleGranularlyExtendSelection(
          GranularlyExtendSelectionEvent(
            forward: !endDiff.isNegative,
            isEnd: true,
            granularity: TextGranularity.character,
          ),
        );
      }

      return result!;
    }

    super.handleSelectWord(event);
    _lastEvent = event;
    // _expectSearchSelection = true;

    if (!(currentSelectionEndIndex < selectables.length &&
        currentSelectionEndIndex >= 0)) {
      return handleClearSelection(const ClearSelectionEvent());
    }

    handleGranularlyExtendSelection(
      const GranularlyExtendSelectionEvent(
        forward: false,
        isEnd: true,
        granularity: TextGranularity.document,
      ),
    );

    handleClearSelection(const ClearSelectionEvent());

    final textBefore = getSelectedContent()?.plainText ?? '';

    super.handleSelectWord(event);
    handleGranularlyExtendSelection(
      const GranularlyExtendSelectionEvent(
        forward: true,
        isEnd: true,
        granularity: TextGranularity.document,
      ),
    );

    final textAfter = getSelectedContent()?.plainText ?? '';

    final text = '$textBefore$textAfter';

    final eventSelection = JidoujishoTextSelection(
      text: text,
      range: TextRange(
        start: textBefore.length,
        end: text.length,
      ),
    );

    late SelectionResult result;
    final guessSelection = onTextSelectionGuessLength(eventSelection);
    result = handleTextSelection(event, guessSelection);

    // onTextSelectionSearchLength(eventSelection, (searchSelection) {
    //   _guessSelection = guessSelection;
    //   _searchSelection = searchSelection;
    //   if (getSelectedContent()?.plainText == guessSelection.textInside &&
    //       searchSelection.textInside != guessSelection.textInside) {
    //     dispatchSelectionEvent(event);
    //   }
    // });

    return result;
  }
}
