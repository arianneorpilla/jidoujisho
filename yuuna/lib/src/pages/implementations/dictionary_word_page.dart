import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// Returns the widget for a list of [DictionaryEntry] making up a word.
class DictionaryWordPage extends BasePage {
  /// Create the widget for a dictionary word.
  const DictionaryWordPage({
    required this.entries,
    required this.onTextSelect,
    super.key,
  });

  /// The result made from a dictionary database search.
  final List<DictionaryEntry> entries;

  /// Action to be done upon text select made when hovering over the text
  /// elements contained in this widget.
  final Function(String) onTextSelect;

  @override
  BasePageState<DictionaryWordPage> createState() => _DictionaryWordPageState();
}

class _DictionaryWordPageState extends BasePageState<DictionaryWordPage> {
  String get searchLabel => appModel.translate('search');

  MaterialTextSelectionControls get selectionControls =>
      JidoujishoTextSelectionControls(
        customAction: widget.onTextSelect,
        customActionLabel: searchLabel,
      );

  String get word => widget.entries.first.word;
  String get reading => widget.entries.first.reading;

  @override
  Widget build(BuildContext context) {
    Set<DictionaryPair> pairs = {};

    for (DictionaryEntry entry in widget.entries) {
      for (String tag in entry.wordTags) {
        pairs.add(DictionaryPair(word: entry.dictionaryName, reading: tag));
      }
    }

    List<Widget> tags = [];
    tags.addAll(pairs.map((pair) {
      if (pair.reading.isNotEmpty) {
        return JidoujishoTag(
          text: pair.reading,
          backgroundColor: Colors.red.shade900,
        );
      } else {
        return const SizedBox.shrink();
      }
    }).toList());

    return Card(
      color: appModel.isDarkMode
          ? theme.cardColor.withOpacity(0.75)
          : Colors.grey.shade200.withOpacity(0.55),
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: EdgeInsets.only(
          left: Spacing.of(context).spaces.semiBig,
          top: Spacing.of(context).spaces.normal,
          right: Spacing.of(context).spaces.normal,
          bottom: Spacing.of(context).spaces.normal,
        ),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        word,
                        style: textTheme.titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                        selectionControls: selectionControls,
                      ),
                      SelectableText(
                        reading,
                        style: textTheme.titleMedium,
                        selectionControls: selectionControls,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: Spacing.of(context).spaces.small,
                    right: Spacing.of(context).spaces.small,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: buildQuickActions(),
                  ),
                ),
              ],
            ),
            const Space.normal(),
            Wrap(children: tags),
            const Space.normal(),
            Padding(
              padding: Spacing.of(context).insets.horizontal.small,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.entries.length,
                itemBuilder: (context, index) {
                  return buildEntrySection(widget.entries[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEntrySection(DictionaryEntry entry) {
    List<Widget> tags = [];
    tags.add(
      JidoujishoTag(
        text: entry.dictionaryName,
        backgroundColor: Colors.red.shade900,
      ),
    );
    tags.addAll(entry.meaningTags.map((tag) {
      if (tag.isNotEmpty) {
        return JidoujishoTag(
          text: tag,
          backgroundColor: Colors.red.shade900.withOpacity(0.5),
        );
      } else {
        return const SizedBox.shrink();
      }
    }).toList());

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        const Space.small(),
        Wrap(children: tags),
        Padding(
          padding: EdgeInsets.only(
            top: Spacing.of(context).spaces.small,
            bottom: Spacing.of(context).spaces.normal,
            left: Spacing.of(context).spaces.normal,
          ),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: entry.meanings.length,
            itemBuilder: (context, index) {
              if (entry.meanings.length != 1) {
                return SelectableText(
                  '• ${entry.meanings[index]}',
                  selectionControls: selectionControls,
                );
              } else {
                return SelectableText(
                  entry.meanings.first,
                  selectionControls: selectionControls,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  List<Widget> buildQuickActions() {
    AnkiMapping mapping = appModel.lastSelectedMapping;
    List<Widget> buttons = [];

    for (int i = 0; i < appModel.maximumFieldEnhancements; i++) {
      Widget button = buildQuickAction(
        mapping: mapping,
        slotNumber: i,
      );

      buttons.add(button);
    }

    return buttons.reversed.toList();
  }

  Widget buildQuickAction({
    required AnkiMapping mapping,
    required int slotNumber,
  }) {
    String? actionName = mapping.actions[slotNumber];
    QuickAction? quickAction;

    if (actionName != null) {
      quickAction = appModel.quickActions[actionName];
    }

    if (quickAction == null) {
      return const SizedBox.shrink();
    } else {
      return Padding(
        padding: Spacing.of(context).insets.onlyLeft.semiSmall,
        child: JidoujishoIconButton(
          shapeBorder: const RoundedRectangleBorder(),
          backgroundColor:
              Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
          size: 16,
          tooltip: quickAction.getLocalisedLabel(appModel),
          icon: quickAction.icon,
          onTap: () async {
            quickAction?.executeAction(
              context: context,
              ref: ref,
              appModel: appModel,
              creatorModel: creatorModel,
              word: word,
              reading: reading,
              entries: widget.entries,
            );
            setState(() {});
          },
        ),
      );
    }
  }
}
