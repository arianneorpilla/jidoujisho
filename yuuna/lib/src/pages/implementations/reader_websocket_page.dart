import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/src/media/sources/reader_websocket_source.dart';
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
class _ReaderWebsocketPageState<ReaderLyricsPage> extends BaseSourcePageState {
  String get noActiveConnectionLabel =>
      appModel.translate('no_active_connection');

  String get noTextReceived => appModel.translate('no_text_received');

  ReaderWebsocketSource get source => ReaderWebsocketSource.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: source.stream,
      builder: (context, snapshot) {
        if (!source.isActive) {
          return buildNoActiveConnection();
        }

        if (source.messages.isEmpty) {
          return buildEmpty();
        } else {
          return buildMessageBuilder();
        }
      },
    );
  }

  Widget buildNoActiveConnection() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.leak_remove,
        message: noActiveConnectionLabel,
      ),
    );
  }

  Widget buildMessageBuilder() {
    ScrollController controller = ScrollController();

    List<String> messages = source.messages.reversed.toList();
    return RawScrollbar(
      controller: controller,
      thumbVisibility: true,
      thickness: 3,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        controller: controller,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          String message = messages[index];

          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 60 : 0),
            child: buildMessage(message),
          );
        },
      ),
    );
  }

  Widget buildEmpty() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.message,
        message: noTextReceived,
      ),
    );
  }

  Widget buildMessage(String message) {
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
                child: SelectableText(
                  message,
                  selectionControls: JidoujishoTextSelectionControls(
                    searchAction: (selection) async {
                      source.setCurrentSentence(message);
                      await appModel.openRecursiveDictionarySearch(
                        searchTerm: selection,
                        killOnPop: false,
                      );
                      source.clearCurrentSentence();
                    },
                    searchActionLabel: searchLabel,
                    stashAction: onContextStash,
                    stashActionLabel: stashLabel,
                    creatorAction: (selection) async {
                      launchCreator(term: selection, sentence: message);
                    },
                    creatorActionLabel: creatorLabel,
                    allowCopy: true,
                    allowSelectAll: false,
                    allowCut: true,
                    allowPaste: true,
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              buildTextSegmentButton(message),
              buildCardCreatorButton(message),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(),
      ),
    );
  }

  Widget buildTextSegmentButton(String message) {
    String tooltip = appModel.translate('text_segmentation');

    return Padding(
      padding: Spacing.of(context).insets.onlyLeft.semiSmall,
      child: JidoujishoIconButton(
        busy: true,
        shapeBorder: const RoundedRectangleBorder(),
        backgroundColor:
            Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
        size: Spacing.of(context).spaces.semiBig,
        tooltip: tooltip,
        icon: Icons.account_tree,
        onTap: () async {
          appModel.openTextSegmentationDialog(
            sourceText: message,
            onSearch: (selection, items) async {
              source.setCurrentSentence(message);
              await appModel.openRecursiveDictionarySearch(
                searchTerm: selection,
                killOnPop: false,
              );
              source.clearCurrentSentence();
            },
            onSelect: (selection, items) {
              appModel.openCreator(
                creatorFieldValues: CreatorFieldValues(
                  textValues: {
                    TermField.instance: selection,
                    SentenceField.instance: message,
                  },
                ),
                killOnPop: false,
                ref: ref,
              );
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  @override
  void onContextSearch(String searchTerm, {String? sentence}) async {}

  Widget buildCardCreatorButton(String message) {
    String tooltip = appModel.translate('card_creator');

    return Padding(
      padding: Spacing.of(context).insets.onlyLeft.semiSmall,
      child: JidoujishoIconButton(
        busy: true,
        shapeBorder: const RoundedRectangleBorder(),
        backgroundColor:
            Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
        size: Spacing.of(context).spaces.semiBig,
        tooltip: tooltip,
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
