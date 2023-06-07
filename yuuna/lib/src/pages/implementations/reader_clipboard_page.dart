import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:remove_emoji/remove_emoji.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A page for [ReaderClipboardPage] which shows the content of the current
/// clipboard as selectable text.
class ReaderClipboardPage extends BaseSourcePage {
  /// Create an instance of this tab page.
  const ReaderClipboardPage({
    super.item,
    super.key,
  });

  @override
  BaseSourcePageState createState() => _ReaderClipboardPageState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
class _ReaderClipboardPageState<ReaderClipboardPage>
    extends BaseSourcePageState {
  Orientation? lastOrientation;

  ReaderClipboardSource get source => ReaderClipboardSource.instance;

  /// Allows programmatic changing of the current text selection.
  final JidoujishoSelectableTextController _selectableTextController =
      JidoujishoSelectableTextController();

  @override
  Widget build(BuildContext context) {
    String text = ref.watch(clipboardProvider);
    Orientation orientation = MediaQuery.of(context).orientation;
    if (orientation != lastOrientation) {
      clearDictionaryResult();
      lastOrientation = orientation;
    }

    if (text.trim().isEmpty) {
      return buildPlaceholder();
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: clearDictionaryResult,
          child: RawScrollbar(
            thumbVisibility: true,
            thickness: 3,
            controller: ReaderMediaType.instance.scrollController,
            child: SingleChildScrollView(
              controller: ReaderMediaType.instance.scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              primary: false,
              child: Padding(
                padding: Spacing.of(context).insets.horizontal.extraBig,
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const Space.extraBig(),
                    const Space.big(),
                    buildText(text),
                    const Space.big(),
                    Container(height: MediaQuery.of(context).size.height / 2)
                  ],
                ),
              ),
            ),
          ),
        ),
        Column(
          children: [
            const Space.extraBig(),
            Expanded(
              child: buildDictionary(),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildPlaceholder() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.paste,
        message: t.no_text_in_clipboard,
      ),
    );
  }

  String _currentSelection = '';
  final FocusNode _focusNode = FocusNode(skipTraversal: true);

  Widget buildText(String text) {
    text = RemoveEmoji().clean(text);
    return JidoujishoSelectableText.rich(
      TextSpan(children: getSubtitleSpans(text)),
      focusNode: _focusNode,
      controller: _selectableTextController,
      selectionControls: selectionControls,
      onSelectionChanged: (selection, cause) {
        String textSelection = selection.textInside(text);
        _currentSelection = textSelection;
      },
    );
  }

  List<InlineSpan> getSubtitleSpans(String text) {
    List<InlineSpan> spans = [];

    text.runes.forEachIndexed((index, rune) {
      String character = String.fromCharCode(rune);
      spans.add(
        TextSpan(
          text: character,
          style: const TextStyle(fontSize: 22),
          recognizer: TapGestureRecognizer()
            ..onTapDown = (details) async {
              onTapDown(
                character: character,
                text: text,
                index: index,
                controller: _selectableTextController,
                details: details,
              );
            },
        ),
      );
    });

    return spans;
  }

  void onTapDown({
    required String text,
    required String character,
    required int index,
    required TapDownDetails details,
    required JidoujishoSelectableTextController controller,
  }) {
    if (controller.selection.start == index && currentResult != null) {
      clearDictionaryResult();
      return;
    }

    double x = details.globalPosition.dx;
    double y = details.globalPosition.dy;

    late JidoujishoPopupPosition position;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      if (y < MediaQuery.of(context).size.height / 2) {
        position = JidoujishoPopupPosition.bottomHalf;
      } else {
        position = JidoujishoPopupPosition.topHalf;
      }
    } else {
      if (x < MediaQuery.of(context).size.width / 2) {
        position = JidoujishoPopupPosition.rightHalf;
      } else {
        position = JidoujishoPopupPosition.leftHalf;
      }
    }

    String searchTerm = appModel.targetLanguage.getSearchTermFromIndex(
      text: text,
      index: index,
    );

    if (_currentSelection.isEmpty && character.trim().isNotEmpty) {
      /// If we cut off at a lone surrogate, offset the index back by 1. The
      /// selection meant to select the index before
      RegExp loneSurrogate = RegExp(
        '[\uD800-\uDBFF](?![\uDC00-\uDFFF])|(?:[^\uD800-\uDBFF]|^)[\uDC00-\uDFFF]',
      );
      if (index != 0 && text.substring(index).startsWith(loneSurrogate)) {
        index = index - 1;
      }

      int whitespaceOffset = searchTerm.length - searchTerm.trimLeft().length;
      int offsetIndex = index + whitespaceOffset;
      int length = appModel.targetLanguage.getGuessHighlightLength(
        searchTerm: searchTerm,
      );

      controller.setSelection(
        offsetIndex,
        offsetIndex + length,
      );

      searchDictionaryResult(
        searchTerm: searchTerm,
        position: position,
      ).then((result) {
        length = appModel.targetLanguage.getFinalHighlightLength(
          result: currentResult,
          searchTerm: searchTerm,
        );
        controller.setSelection(offsetIndex, offsetIndex + length);

        JidoujishoTextSelection selection =
            appModel.targetLanguage.getSentenceFromParagraph(
          paragraph: text,
          index: index,
          startOffset: offsetIndex,
          endOffset: offsetIndex + length,
        );

        source.setCurrentSentence(
          selection: selection,
        );
      });
    } else {
      clearDictionaryResult();
      _currentSelection = '';
    }

    FocusScope.of(context).unfocus();
  }

  @override
  void clearDictionaryResult() {
    super.clearDictionaryResult();
    _selectableTextController.clearSelection();
    source.clearCurrentSentence();
  }

  @override
  MaterialTextSelectionControls get selectionControls =>
      JidoujishoTextSelectionControls(
        searchAction: onSearch,
        stashAction: onStash,
        shareAction: onShare,
        creatorAction: (text) async {
          await appModel.openCreator(
            creatorFieldValues: CreatorFieldValues(
              textValues: {
                SentenceField.instance: text,
                TermField.instance: '',
                ClozeBeforeField.instance: '',
                ClozeInsideField.instance: '',
                ClozeAfterField.instance: '',
              },
            ),
            killOnPop: false,
            ref: ref,
          );
        },
        allowCopy: true,
        allowSelectAll: false,
        allowCut: true,
        allowPaste: true,
      );
}
