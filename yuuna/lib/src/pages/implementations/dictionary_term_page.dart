import 'package:expandable/expandable.dart';
import 'package:float_column/float_column.dart';
import 'package:flutter/material.dart';
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
    required this.dictionaryMap,
    required this.dictionaryTerm,
    required this.onSearch,
    required this.onStash,
    required this.expandableControllers,
    required this.dictionaryHiddens,
    required this.lastSelectedMapping,
    this.entryOpacity = 1,
    this.onScrollLeft,
    this.onScrollRight,
    this.footerWidget,
    super.key,
  });

  /// Used for optimisations.
  final Map<String, Dictionary> dictionaryMap;

  /// The result made from a dictionary database search.
  final DictionaryTerm dictionaryTerm;

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

    return GestureDetector(
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
    );
  }

  /// Fetches the tag widgets for a [DictionaryTerm].
  List<Widget> getTagsForTerm() {
    List<Widget> tagWidgets = [];

    tagWidgets.addAll(widget.dictionaryTerm.termTags.map((tag) {
      return JidoujishoTag(
        text: tag.name,
        message: tag.notes,
        backgroundColor: tag.color,
      );
    }).toList());

    return tagWidgets;
  }

  Widget buildCard() {
    List<DictionaryMetaEntry> freqEntries = widget.dictionaryTerm.metaEntries
        .where((e) =>
            e.frequency != null &&
            (e.frequency!.reading == null ||
                e.frequency!.reading == widget.dictionaryTerm.reading))
        .toList();

    Map<String, List<DictionaryMetaEntry>> groups =
        groupBy<DictionaryMetaEntry, String>(
            freqEntries, (entry) => entry.dictionaryName);

    List<DictionaryMetaEntry> groupedFreqEntries = groups.entries.map((group) {
      if (group.value.length == 1) {
        return group.value.first;
      } else {
        return DictionaryMetaEntry(
          dictionaryName: group.key,
          term: widget.dictionaryTerm.term,
          frequency: FrequencyData(
            value: group.value.first.frequency!.value,
            displayValue:
                group.value.map((e) => e.frequency!.displayValue).join(', '),
          ),
        );
      }
    }).toList();

    List<DictionaryMetaEntry> pitchEntries = widget.dictionaryTerm.metaEntries
        .where((e) => e.pitches != null)
        .toList();

    List<Widget> termTags = getTagsForTerm();

    return Card(
      color: appModel.isDarkMode
          ? Color.fromRGBO(15, 15, 15, widget.entryOpacity)
          : Color.fromRGBO(246, 246, 246, widget.entryOpacity),
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
              child: buildTopRow(
                metaEntries: widget.dictionaryTerm.metaEntries,
              ),
            ),
            if (termTags.isNotEmpty)
              const SliverToBoxAdapter(child: Space.normal()),
            if (termTags.isNotEmpty)
              SliverToBoxAdapter(child: Wrap(children: termTags)),
            const SliverToBoxAdapter(child: Space.normal()),
            buildFreqEntries(metaEntries: groupedFreqEntries),
            buildPitchEntries(metaEntries: pitchEntries),
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
    required List<DictionaryMetaEntry> metaEntries,
    required AnkiMapping lastSelectedMapping,
  }) {
    List<Widget> buttons = [];

    for (int i = 0; i < appModel.maximumQuickActions; i++) {
      Widget button = buildQuickAction(
        mapping: lastSelectedMapping,
        slotNumber: i,
        metaEntries: metaEntries,
      );

      buttons.add(button);
    }

    return buttons.reversed.toList();
  }

  Widget buildQuickAction({
    required AnkiMapping mapping,
    required int slotNumber,
    required List<DictionaryMetaEntry> metaEntries,
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
            dictionaryTerm: widget.dictionaryTerm,
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
              dictionaryTerm: widget.dictionaryTerm,
              metaEntries: metaEntries,
            );
            setState(() {});
          },
        ),
      );
    }
  }

  Widget buildTopRow({
    required List<DictionaryMetaEntry> metaEntries,
  }) {
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
              metaEntries: metaEntries,
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
              dictionaryTerm: widget.dictionaryTerm,
            ),
            onTap: () => appModel.copyToClipboard(widget.dictionaryTerm.term),
            onLongPress: () =>
                appModel.copyToClipboard(widget.dictionaryTerm.term),
          ),
        ),
      ],
    );
  }

  Widget buildFreqEntries({
    required List<DictionaryMetaEntry> metaEntries,
  }) {
    if (metaEntries.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    List<Widget> children = metaEntries.map((metaEntry) {
      if (widget.dictionaryMap[metaEntry.dictionaryName]!.hidden) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: Spacing.of(context).insets.horizontal.small,
        child: getTagsForMetaEntry(
          dictionaryTerm: widget.dictionaryTerm,
          metaEntry: metaEntry,
        ),
      );
    }).toList();

    return SliverToBoxAdapter(
      child: Wrap(children: children),
    );
  }

  Widget buildPitchEntries({
    required List<DictionaryMetaEntry> metaEntries,
  }) {
    if (metaEntries.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          DictionaryMetaEntry metaEntry = metaEntries[index];

          if (widget.dictionaryMap[metaEntry.dictionaryName]!.hidden) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: Spacing.of(context).insets.horizontal.small,
            child: getTagsForMetaEntry(
              dictionaryTerm: widget.dictionaryTerm,
              metaEntry: metaEntry,
            ),
          );
        },
        childCount: metaEntries.length,
      ),
    );
  }

  /// Fetches the tag widgets for a [DictionaryEntry].
  Widget getTagsForMetaEntry({
    required DictionaryTerm dictionaryTerm,
    required DictionaryMetaEntry metaEntry,
  }) {
    String dictionaryImportTag = appModel.translate('dictionary_import_tag');
    late Widget widget;

    if (metaEntry.frequency != null) {
      return Padding(
        padding: Spacing.of(context).insets.onlyBottom.normal,
        child: JidoujishoTag(
          text: metaEntry.dictionaryName,
          message: dictionaryImportTag.replaceAll(
            '%dictionaryName%',
            metaEntry.dictionaryName,
          ),
          trailingText: metaEntry.frequency!.displayValue,
          backgroundColor: Colors.red.shade900,
        ),
      );
    } else if (metaEntry.pitches != null) {
      List<Widget> children = [];
      Widget tag = Padding(
        padding: Spacing.of(context).insets.onlyRight.small,
        child: JidoujishoTag(
          text: metaEntry.dictionaryName,
          message: dictionaryImportTag.replaceAll(
            '%dictionaryName%',
            metaEntry.dictionaryName,
          ),
          backgroundColor: Colors.red.shade900,
        ),
      );

      List<PitchData> pitches = metaEntry.pitches!
          .where((pitch) => pitch.reading == dictionaryTerm.reading)
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

        widget = Wrap(children: children);
      } else {
        List<Widget> children = [];
        children.add(Row(
          children: [
            Padding(
              padding: Spacing.of(context).insets.onlyBottom.semiSmall,
              child: JidoujishoTag(
                text: metaEntry.dictionaryName,
                message: dictionaryImportTag.replaceAll(
                  '%dictionaryName%',
                  metaEntry.dictionaryName,
                ),
                backgroundColor: Colors.red.shade900,
              ),
            ),
            const Spacer(),
          ],
        ));

        children.addAll(
          pitches.mapIndexed((index, element) {
            PitchData data = pitches[index];
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
          }).toList(),
        );

        widget = Padding(
          padding: Spacing.of(context).insets.onlyBottom.small,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        );
      }
    } else {
      widget = const SizedBox.shrink();
    }

    return widget;
  }

  Widget buildEntries() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          DictionaryEntry entry = widget.dictionaryTerm.entries[index];
          List<DictionaryTag> meaningTags =
              widget.dictionaryTerm.meaningTagsGroups[index];

          if (widget.dictionaryHiddens[entry.dictionaryName]!) {
            return const SizedBox.shrink();
          }

          return DictionaryEntryPage(
            entry: entry,
            meaningTags: meaningTags,
            onSearch: widget.onSearch,
            onStash: widget.onStash,
            expandableController:
                widget.expandableControllers[entry.dictionaryName]!,
          );
        },
        childCount: widget.dictionaryTerm.entries.length,
      ),
    );
  }
}
