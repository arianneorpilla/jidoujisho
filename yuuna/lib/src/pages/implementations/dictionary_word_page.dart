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
  String get dictionaryNameNotes => appModel.translate('dictionary_name_notes');

  MaterialTextSelectionControls get selectionControls =>
      JidoujishoTextSelectionControls(
        customAction: widget.onTextSelect,
        customActionLabel: searchLabel,
      );

  String get word => widget.entries.first.word;
  String get reading => widget.entries.first.reading;

  final Map<String, ExpandableController> _expandableControllers = {};
  final Map<String, bool> _dictionaryHiddens = {};

  @override
  void initState() {
    super.initState();
    Set<String> dictionaryNames =
        widget.entries.map((entry) => entry.dictionaryName).toSet();

    for (String dictionaryName in dictionaryNames) {
      Dictionary dictionary = appModelNoUpdate.getDictionary(dictionaryName);
      _expandableControllers[dictionaryName] = ExpandableController(
        initialExpanded: !dictionary.collapsed,
      );
      _dictionaryHiddens[dictionaryName] = dictionary.hidden;
    }
  }

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

    List<Widget> children = [
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
            DictionaryEntry entry = widget.entries[index];

            if (_dictionaryHiddens[entry.dictionaryName]!) {
              return const SizedBox.shrink();
            }

            return DictionaryEntryPage(
              expandableController:
                  _expandableControllers[entry.dictionaryName]!,
              entry: entry,
              onTextSelect: widget.onTextSelect,
            );
          },
        ),
      ),
    ];

    return Card(
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
