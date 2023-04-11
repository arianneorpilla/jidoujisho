import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:remove_emoji/remove_emoji.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A page for [ReaderWebsocketSource] which shows lyrics of current playing
/// media.
class ReaderWebsocketPage extends BaseSourcePage {
  /// Create an instance of this tab page.
  const ReaderWebsocketPage({
    super.item,
    super.key,
  });

  @override
  BaseSourcePageState createState() => _ReaderWebsocketPageState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
class _ReaderWebsocketPageState
    extends BaseSourcePageState<ReaderWebsocketPage> {
  ReaderWebsocketSource get source => ReaderWebsocketSource.instance;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: clearDictionaryResult,
      child: StreamBuilder<void>(
        stream: source.stream,
        builder: (context, snapshot) {
          if (!source.isActive) {
            return buildNoActiveConnection();
          }

          if (source.messages.isEmpty) {
            return buildEmpty();
          } else {
            return Stack(
              children: [
                buildMessageBuilder(),
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
        },
      ),
    );
  }

  Widget buildNoActiveConnection() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.leak_remove,
        message: t.no_active_connection,
      ),
    );
  }

  Widget buildMessageBuilder() {
    List<String> messages = source.messages.reversed.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(top: 60),
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      controller: ReaderMediaType.instance.scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        String message = messages[index];

        return buildMessage(message);
      },
    );
  }

  Widget buildEmpty() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.message,
        message: t.no_text_received,
      ),
    );
  }

  JidoujishoSelectableTextController? _lastTappedController;

  @override
  void clearDictionaryResult() {
    super.clearDictionaryResult();
    _lastTappedController?.clearSelection();
    source.clearCurrentSentence();
  }

  List<InlineSpan> getTextSpans({
    required JidoujishoSelectableTextController controller,
    required String text,
  }) {
    List<InlineSpan> spans = [];

    text.runes.forEachIndexed((index, rune) {
      String character = String.fromCharCode(rune);
      spans.add(
        TextSpan(
            text: character,
            style: const TextStyle(fontSize: 18),
            recognizer: TapGestureRecognizer()
              ..onTapDown = (details) async {
                onTapDown(
                  character: character,
                  text: text,
                  index: index,
                  controller: controller,
                  details: details,
                );
              }),
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
    _lastTappedController?.clearSelection();
    _lastTappedController = controller;

    bool wholeWordCondition =
        controller.selection.start <= index && controller.selection.end > index;

    if (wholeWordCondition && currentResult != null) {
      clearDictionaryResult();
      return;
    }

    source.setCurrentSentence(text);

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

    if (character.trim().isNotEmpty) {
      /// If we cut off at a lone surrogate, offset the index back by 1. The
      /// selection meant to select the index before
      RegExp loneSurrogate = RegExp(
        '[\uD800-\uDBFF](?![\uDC00-\uDFFF])|(?:[^\uD800-\uDBFF]|^)[\uDC00-\uDFFF]',
      );
      if (index != 0 && text.substring(index).startsWith(loneSurrogate)) {
        index = index - 1;
      }
      bool isSpaceDelimited = appModel.targetLanguage.isSpaceDelimited;
      String searchTerm = appModel.targetLanguage.getSearchTermFromIndex(
        text: text,
        index: index,
      );
      int whitespaceOffset = searchTerm.length - searchTerm.trimLeft().length;
      int offsetIndex =
          appModel.targetLanguage.getStartingIndex(text: text, index: index) +
              whitespaceOffset;
      int length = appModel.targetLanguage
          .textToWords(searchTerm)
          .firstWhere((e) => e.trim().isNotEmpty)
          .length;

      controller.setSelection(
        offsetIndex,
        offsetIndex + length,
      );

      searchDictionaryResult(
        searchTerm: searchTerm,
        position: position,
      ).then((result) {
        int length = isSpaceDelimited
            ? appModel.targetLanguage
                .textToWords(searchTerm)
                .firstWhere((e) => e.trim().isNotEmpty)
                .length
            : max(1, currentResult?.bestLength ?? 0);

        controller.setSelection(offsetIndex, offsetIndex + length);
      });
    } else {
      clearDictionaryResult();
    }

    FocusScope.of(context).unfocus();
  }

  Widget buildMessage(String message) {
    message = RemoveEmoji().removemoji(message);
    final JidoujishoSelectableTextController controller =
        JidoujishoSelectableTextController();

    return Padding(
      padding: EdgeInsets.only(
        top: Spacing.of(context).spaces.extraSmall,
        left: Spacing.of(context).spaces.normal,
        right: Spacing.of(context).spaces.normal,
      ),
      child: Card(
        child: Padding(
          padding: Spacing.of(context).insets.all.normal,
          child: Row(
            children: [
              Expanded(
                child: JidoujishoSelectableText.rich(
                  TextSpan(
                    children: getTextSpans(
                      controller: controller,
                      text: message,
                    ),
                  ),
                  selectionControls: JidoujishoTextSelectionControls(
                    searchAction: (selection) async {
                      source.setCurrentSentence(message);
                      await appModel.openRecursiveDictionarySearch(
                        searchTerm: selection,
                        killOnPop: false,
                      );
                      source.clearCurrentSentence();
                    },
                    shareAction: onShare,
                    stashAction: onStash,
                    creatorAction: (selection) async {
                      launchCreator(term: '', sentence: selection);
                    },
                    allowCopy: true,
                    allowSelectAll: false,
                    allowCut: true,
                    allowPaste: true,
                  ),
                  controller: controller,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              buildSentencePickerButton(message),
              buildCardCreatorButton(message),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(),
      ),
    );
  }

  Widget buildSentencePickerButton(String message) {
    return Padding(
      padding: Spacing.of(context).insets.onlyLeft.semiSmall,
      child: JidoujishoIconButton(
        busy: true,
        shapeBorder: const RoundedRectangleBorder(),
        backgroundColor:
            Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
        size: Spacing.of(context).spaces.semiBig,
        tooltip: t.sentence_picker,
        icon: Icons.colorize,
        onTap: () async {
          appModel.openExampleSentenceDialog(
            exampleSentences: appModel.targetLanguage
                .getSentences(message)
                .map((e) => e.trim())
                .toList(),
            onSelect: (selection) {
              appModel.openCreator(
                creatorFieldValues: CreatorFieldValues(
                  textValues: {
                    SentenceField.instance: selection.join(
                        appModel.targetLanguage.isSpaceDelimited ? ' ' : ''),
                  },
                ),
                killOnPop: false,
                ref: ref,
              );
            },
          );
        },
      ),
    );
  }

  Widget buildCardCreatorButton(String message) {
    return Padding(
      padding: Spacing.of(context).insets.onlyLeft.semiSmall,
      child: JidoujishoIconButton(
        busy: true,
        shapeBorder: const RoundedRectangleBorder(),
        backgroundColor:
            Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
        size: Spacing.of(context).spaces.semiBig,
        tooltip: t.card_creator,
        icon: Icons.note_add,
        onTap: () async {
          launchCreator(term: '', sentence: message);
        },
      ),
    );
  }

  void launchCreator({required String term, required String sentence}) async {
    await appModel.openCreator(
      creatorFieldValues: CreatorFieldValues(
        textValues: {
          SentenceField.instance: sentence,
          TermField.instance: term,
        },
      ),
      killOnPop: false,
      ref: ref,
    );
  }
}
