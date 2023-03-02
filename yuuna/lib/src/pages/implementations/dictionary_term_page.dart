import 'package:expandable/expandable.dart';
import 'package:float_column/float_column.dart';
import 'package:flutter/material.dart';
import 'package:keframe/keframe.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';
import 'package:collection/collection.dart';

/// Returns the widget for a list of [DictionaryEntry] making up a term.
class DictionaryTermPage extends BasePage {
  /// Create the widget for a dictionary word.
  const DictionaryTermPage({
    required this.heading,
    required this.onSearch,
    required this.onStash,
    required this.expandableControllers,
    required this.lastSelectedMapping,
    this.entryOpacity = 1,
    this.onScrollLeft,
    this.onScrollRight,
    this.footerWidget,
    super.key,
  });

  /// The result made from a dictionary database search.
  final DictionaryHeading heading;

  /// Action to be done upon selecting the search option.
  final Function(String) onSearch;

  /// Action to be done upon selecting the stash option.
  final Function(String) onStash;

  /// Controls expandables by dictionary name.
  final Map<Dictionary, ExpandableController> expandableControllers;

  /// Called when the widget is scrolled to the left.
  final Function()? onScrollLeft;

  /// Called when the widget is scrolled to the right.
  final Function()? onScrollRight;

  /// Optional footer foor use in [DictionaryHistoryPage].
  final Widget? footerWidget;

  /// Opacity for entries.
  final double entryOpacity;

  /// Last selected mapping for optimisation purposes. Not including this
  /// before caused rendering jank as database queries were performed multiple
  /// times for getting this value.
  final AnkiMapping lastSelectedMapping;

  @override
  BasePageState<DictionaryTermPage> createState() => _DictionaryTermPageState();
}

class _DictionaryTermPageState extends BasePageState<DictionaryTermPage> {
  String get dictionaryImportTag => appModel.translate('dictionary_import_tag');

  @override
  Widget build(BuildContext context) {
    if (widget.onScrollLeft == null && widget.onScrollRight == null) {
      return buildCard();
    }

    return FrameSeparateWidget(
      child: GestureDetector(
        child: buildCard(),
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
      ),
    );
  }

  /// Fetches the tag widgets for the [DictionaryHeading].
  List<Widget> getTagsForTerm() {
    List<Widget> tagWidgets = [];

    tagWidgets.addAll(widget.heading.tags.map((tag) {
      return JidoujishoTag(
        text: tag.name,
        message: tag.notes,
        backgroundColor: tag.color,
      );
    }).toList());

    return tagWidgets;
  }

  Widget buildCard() {
    List<Widget> termTags = getTagsForTerm();

    return Card(
      color: appModel.isDarkMode
          ? Color.fromRGBO(15, 15, 15, widget.entryOpacity)
          : Color.fromRGBO(249, 249, 249, widget.entryOpacity),
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: EdgeInsets.only(
          left: Spacing.of(context).spaces.semiBig,
          top: Spacing.of(context).spaces.normal,
          right: Spacing.of(context).spaces.normal,
          bottom: Spacing.of(context).spaces.normal,
        ),
        child: CustomScrollView(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: buildTopRow(),
            ),
            if (termTags.isNotEmpty)
              const SliverToBoxAdapter(child: Space.normal()),
            if (termTags.isNotEmpty)
              SliverToBoxAdapter(child: Wrap(children: termTags)),
            const SliverToBoxAdapter(child: Space.normal()),
            buildFreqEntries(),
            buildPitchEntries(),
            const SliverToBoxAdapter(child: Space.normal()),
            buildEntries(),
            SliverToBoxAdapter(
              child: (widget.footerWidget != null)
                  ? widget.footerWidget!
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildQuickActions({
    required AnkiMapping lastSelectedMapping,
  }) {
    List<Widget> buttons = [];

    for (int i = 0; i < appModel.maximumQuickActions; i++) {
      Widget button = buildQuickAction(
        mapping: lastSelectedMapping,
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
    String? actionName = mapping.actions![slotNumber];
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
            heading: widget.heading,
          ),
          shapeBorder: const RoundedRectangleBorder(),
          backgroundColor:
              appModel.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
          size: Spacing.of(context).spaces.semiBig,
          tooltip: quickAction.getLocalisedLabel(appModel),
          icon: quickAction.icon,
          onTap: () async {
            await quickAction?.executeAction(
              context: context,
              ref: ref,
              appModel: appModel,
              creatorModel: creatorModel,
              heading: widget.heading,
            );
            if (mounted) {
              setState(() {});
            }
          },
        ),
      );
    }
  }

  Widget buildFreqEntries() {
    List<DictionaryFrequency> frequencies = widget.heading.frequencies
        .where((frequency) => !frequency.dictionary.value!.hidden)
        .toList();

    frequencies += appModel.getNoReadingFrequencies(heading: widget.heading);

    if (frequencies.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    List<MapEntry<Dictionary, List<DictionaryFrequency>>>
        frequenciesByDictionary = groupBy<DictionaryFrequency, Dictionary>(
                frequencies, (frequency) => frequency.dictionary.value!)
            .entries
            .toList();

    frequenciesByDictionary.sort((a, b) => a.key.order.compareTo(b.key.order));
    for (MapEntry<Dictionary, List<DictionaryFrequency>> entries
        in frequenciesByDictionary) {
      entries.value.sort((a, b) => b.value.compareTo(a.value));
    }

    List<Widget> children =
        frequenciesByDictionary.map((frequenciesForDictionary) {
      return Padding(
        padding: Spacing.of(context).insets.onlyBottom.normal,
        child: JidoujishoTag(
          text: frequenciesForDictionary.key.name,
          message: dictionaryImportTag.replaceAll(
            '%dictionaryName%',
            frequenciesForDictionary.key.name,
          ),
          trailingText: frequenciesForDictionary.value
              .map((e) => e.displayValue)
              .join(', '),
          backgroundColor: Colors.red.shade900,
        ),
      );
    }).toList();

    return SliverToBoxAdapter(
      child: Wrap(children: children),
    );
  }

  Widget buildPitchEntries() {
    List<DictionaryPitch> pitches = widget.heading.pitches
        .where((pitch) => !pitch.dictionary.value!.hidden)
        .toList();
    if (pitches.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    pitches.sort((a, b) =>
        a.dictionary.value!.order.compareTo(b.dictionary.value!.order));

    Map<Dictionary, List<DictionaryPitch>> pitchesByDictionary =
        groupBy<DictionaryPitch, Dictionary>(
            pitches, (pitch) => pitch.dictionary.value!);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          MapEntry<Dictionary, List<DictionaryPitch>> pitchesForDictionary =
              pitchesByDictionary.entries.elementAt(index);
          Dictionary dictionary = pitchesForDictionary.key;
          List<DictionaryPitch> pitches = pitchesForDictionary.value;

          if (pitches.length > 1) {
            List<Widget> pitchWidgets = pitches
                .map(
                  (pitch) => Padding(
                    padding: Spacing.of(context).insets.onlyLeft.normal,
                    child: appModel.targetLanguage.getPitchWidget(
                      appModel: appModel,
                      context: context,
                      reading: widget.heading.reading,
                      downstep: pitch.downstep,
                    ),
                  ),
                )
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: Spacing.of(context).insets.onlyBottom.semiSmall,
                  child: JidoujishoTag(
                    text: dictionary.name,
                    message: dictionaryImportTag.replaceAll(
                      '%dictionaryName%',
                      dictionary.name,
                    ),
                    backgroundColor: Colors.red.shade900,
                  ),
                ),
                ...pitchWidgets,
              ],
            );
          } else {
            List<Widget> pitchWidgets = pitches
                .map(
                  (pitch) => Padding(
                    padding: Spacing.of(context).insets.onlyLeft.small,
                    child: appModel.targetLanguage.getPitchWidget(
                      appModel: appModel,
                      context: context,
                      reading: widget.heading.reading,
                      downstep: pitch.downstep,
                    ),
                  ),
                )
                .toList();

            return Wrap(
              children: [
                JidoujishoTag(
                  text: dictionary.name,
                  message: dictionaryImportTag.replaceAll(
                    '%dictionaryName%',
                    dictionary.name,
                  ),
                  backgroundColor: Colors.red.shade900,
                ),
                ...pitchWidgets,
              ],
            );
          }
        },
        childCount: pitchesByDictionary.length,
      ),
    );
  }

  Widget buildTopRow() {
    return FloatColumn(
      children: [
        Floatable(
          float: FCFloat.end,
          padding: EdgeInsets.only(
            top: Spacing.of(context).spaces.small,
            right: Spacing.of(context).spaces.small,
            bottom: Spacing.of(context).spaces.small,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: buildQuickActions(
              lastSelectedMapping: widget.lastSelectedMapping,
            ),
          ),
        ),
        Floatable(
          float: FCFloat.start,
          child: GestureDetector(
            child: appModel.targetLanguage.getTermReadingOverrideWidget(
              context: context,
              appModel: appModel,
              heading: widget.heading,
            ),
            onTap: () => appModel.copyToClipboard(widget.heading.term),
            onLongPress: () => appModel.copyToClipboard(widget.heading.term),
          ),
        ),
      ],
    );
  }

  Widget buildEntries() {
    List<DictionaryEntry> entries = widget.heading.entries
        .where((entry) => !entry.dictionary.value!.hidden)
        .toList();

    entries.sort((a, b) =>
        a.dictionary.value!.order.compareTo(b.dictionary.value!.order));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          DictionaryEntry entry = entries[index];

          return DictionaryEntryPage(
            entry: entry,
            onSearch: widget.onSearch,
            onStash: widget.onStash,
            expandableController:
                widget.expandableControllers[entry.dictionary.value!]!,
          );
        },
        childCount: entries.length,
      ),
    );
  }
}
