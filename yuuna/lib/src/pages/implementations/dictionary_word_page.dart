import 'package:expandable/expandable.dart';
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
    required this.onSearch,
    required this.onStash,
    required this.expandableControllers,
    required this.dictionaryHiddens,
    this.onScrollLeft,
    this.onScrollRight,
    this.footerWidget,
    super.key,
  });

  /// The result made from a dictionary database search.
  final List<DictionaryEntry> entries;

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  /// Action to be done upon selecting the stash option.
  final Function(String) onStash;

  /// Controls expandables by dictionary name.
  final Map<String, ExpandableController> expandableControllers;

  /// Used to hide entries by dictionary name.
  final Map<String, bool> dictionaryHiddens;

  /// Called when the widget is scrolled to the left.
  final Function()? onScrollLeft;

  /// Called when the widget is scrolled to the right.
  final Function()? onScrollRight;

  /// Optional footer foor use in [DictionaryHistoryPage].
  final Widget? footerWidget;

  @override
  BasePageState<DictionaryWordPage> createState() => _DictionaryWordPageState();
}

class _DictionaryWordPageState extends BasePageState<DictionaryWordPage> {
  String get searchLabel => appModel.translate('search');
  String get stashLabel => appModel.translate('stash');
  String get dictionaryNameNotes => appModel.translate('dictionary_name_notes');
  String get dictionaryInfoNotes => appModel.translate('dictionary_info_notes');

  MaterialTextSelectionControls get selectionControls =>
      JidoujishoTextSelectionControls(
        searchAction: widget.onSearch,
        searchActionLabel: searchLabel,
        stashAction: widget.onStash,
        stashActionLabel: stashLabel,
        allowCopy: true,
        allowSelectAll: true,
        allowCut: false,
        allowPaste: false,
      );

  String get word => widget.entries.first.word;
  String get reading => widget.entries.first.reading;

  List<Widget>? tags;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      buildTopRow(),
      const Space.normal(),
      buildTags(),
      const Space.normal(),
      buildMetaWidgets(),
      const Space.normal(),
      buildEntries(),
      if (widget.footerWidget != null) widget.footerWidget!
    ];

    return GestureDetector(
      child: Card(
        color: appModel.isDarkMode
            ? const Color(0xff313131)
            : const Color(0xfff6f6f6),
        elevation: 0,
        shape: const RoundedRectangleBorder(),
        child: Padding(
          padding: EdgeInsets.only(
            left: Spacing.of(context).spaces.semiBig,
            top: Spacing.of(context).spaces.normal,
            right: Spacing.of(context).spaces.normal,
            bottom: Spacing.of(context).spaces.normal,
          ),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => children[index],
            itemCount: children.length,
          ),
        ),
      ),
      onHorizontalDragEnd: (details) async {
        if (details.primaryVelocity == 0) {
          return;
        }

        if (details.primaryVelocity!.compareTo(0) == -1) {
          widget.onScrollRight?.call();
        } else {
          widget.onScrollLeft?.call();
        }
      },
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
          busy: true,
          enabledColor: quickAction.getIconColor(
            context: context,
            appModel: appModel,
            word: word,
            reading: reading,
            entries: widget.entries,
          ),
          shapeBorder: const RoundedRectangleBorder(),
          backgroundColor:
              Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.1),
          size: Spacing.of(context).spaces.semiBig,
          tooltip: quickAction.getLocalisedLabel(appModel),
          icon: quickAction.icon,
          onTap: () async {
            await quickAction?.executeAction(
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

  Widget buildTopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            child: appModel.targetLanguage.getWordReadingOverrideWidget(
              context: context,
              appModel: appModel,
              word: word,
              reading: reading,
              meanings: widget.entries,
            ),
            onTap: () => appModel.copyToClipboard(word),
            onLongPress: () => appModel.copyToClipboard(word),
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
    );
  }

  Widget buildTags() {
    if (tags == null) {
      tags = [];

      Set<DictionaryPair> pairs = {};

      for (DictionaryEntry entry in widget.entries) {
        for (String tag in entry.wordTags) {
          pairs.add(
            DictionaryPair(
              word: entry.dictionaryName,
              reading: tag,
            ),
          );
        }
      }

      tags!.addAll(pairs.map((pair) {
        if (pair.reading.isNotEmpty) {
          DictionaryTag tag = appModel.getDictionaryTag(
            dictionaryName: pair.word,
            tagName: pair.reading,
          );

          return JidoujishoTag(
            text: tag.name,
            message: tag.notes,
            backgroundColor: tag.color,
          );
        } else {
          return const SizedBox.shrink();
        }
      }).toList());
    }

    return Wrap(children: tags!);
  }

  Widget buildMetaWidgets() {
    List<DictionaryMetaEntry> metaEntries =
        appModel.getMetaEntriesFromWord(word);

    if (metaEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: metaEntries.length,
      itemBuilder: (context, index) {
        DictionaryMetaEntry metaEntry = metaEntries[index];
        if (appModel.getDictionary(metaEntry.dictionaryName).hidden) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: Spacing.of(context).insets.horizontal.small,
          child: buildMetaWidget(metaEntry),
        );
      },
    );
  }

  Widget buildMetaWidget(DictionaryMetaEntry metaEntry) {
    if (metaEntry.frequency != null) {
      return Row(
        children: [
          Padding(
            padding: Spacing.of(context).insets.onlyBottom.normal,
            child: JidoujishoTag(
              text: metaEntry.dictionaryName,
              message: dictionaryInfoNotes.replaceAll(
                '%dictionaryName%',
                metaEntry.dictionaryName,
              ),
              trailingText: metaEntry.frequency.toString(),
              backgroundColor: Colors.red.shade900,
            ),
          ),
          const Spacer(),
        ],
      );
    } else if (metaEntry.pitches != null) {
      List<Widget> children = [];
      Widget tag = Padding(
        padding: Spacing.of(context).insets.onlyRight.small,
        child: JidoujishoTag(
          text: metaEntry.dictionaryName,
          message: dictionaryInfoNotes.replaceAll(
            '%dictionaryName%',
            metaEntry.dictionaryName,
          ),
          backgroundColor: Colors.red.shade900,
        ),
      );

      List<PitchData> pitches = metaEntry.pitches!
          .where((pitch) => pitch.reading == reading)
          .toList();

      if (pitches.isEmpty) {
        return const SizedBox.shrink();
      }

      if (pitches.length == 1) {
        for (PitchData data in metaEntry.pitches!) {
          children.add(
            appModel.targetLanguage.getPitchWidget(
              context: context,
              reading: data.reading,
              downstep: data.downstep,
            ),
          );

          children.add(const Space.small());
        }

        children.insert(
          0,
          Padding(
            padding: Spacing.of(context).insets.onlyBottom.normal,
            child: tag,
          ),
        );

        return Wrap(children: children);
      } else {
        return Padding(
          padding: Spacing.of(context).insets.onlyBottom.small,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Row(
                  children: [
                    Padding(
                      padding: Spacing.of(context).insets.onlyBottom.semiSmall,
                      child: JidoujishoTag(
                        text: metaEntry.dictionaryName,
                        message: dictionaryInfoNotes.replaceAll(
                          '%dictionaryName%',
                          metaEntry.dictionaryName,
                        ),
                        backgroundColor: Colors.red.shade900,
                      ),
                    ),
                    const Spacer(),
                  ],
                );
              } else {
                PitchData data = pitches[index - 1];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: Spacing.of(context).spaces.small,
                    left: Spacing.of(context).spaces.small,
                  ),
                  child: appModel.targetLanguage.getPitchWidget(
                    context: context,
                    reading: data.reading,
                    downstep: data.downstep,
                  ),
                );
              }
            },
            itemCount: pitches.length + 1,
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildEntries() {
    return Padding(
      padding: Spacing.of(context).insets.horizontal.small,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.entries.length,
        itemBuilder: (context, index) {
          DictionaryEntry entry = widget.entries[index];

          if (widget.dictionaryHiddens[entry.dictionaryName]!) {
            return const SizedBox.shrink();
          }

          return DictionaryEntryPage(
            expandableController:
                widget.expandableControllers[entry.dictionaryName]!,
            entry: entry,
            onSearch: widget.onSearch,
            onStash: widget.onStash,
          );
        },
      ),
    );
  }
}
