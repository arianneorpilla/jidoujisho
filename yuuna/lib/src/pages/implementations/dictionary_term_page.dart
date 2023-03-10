import 'package:expandable/expandable.dart';
import 'package:float_column/float_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/src/models/app_model.dart';
import 'package:yuuna/src/models/creator_model.dart';
import 'package:yuuna/utils.dart';
import 'package:collection/collection.dart';

/// Returns the widget for a list of [DictionaryEntry] making up a term.
class DictionaryTermPage extends ConsumerWidget {
  /// Create the widget for a dictionary word.
  const DictionaryTermPage({
    required this.heading,
    required this.onSearch,
    required this.onStash,
    required this.expandableControllers,
    required this.lastSelectedMapping,
    this.opacity = 1,
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

  /// Optional footer foor use in [DictionaryHistoryPage].
  final Widget? footerWidget;

  /// Opacity for entries.
  final double opacity;

  /// Last selected mapping for optimisation purposes. Not including this
  /// before caused rendering jank as database queries were performed multiple
  /// times for getting this value.
  final AnkiMapping lastSelectedMapping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppModel appModel = ref.watch(appProvider);
    bool isPipMode = appModel.isPipMode;

    List<DictionaryEntry> entries = heading.entries
        .where(
          (entry) => !entry.dictionary.value!.isHidden(appModel.targetLanguage),
        )
        .toList();

    entries.sort((a, b) =>
        a.dictionary.value!.order.compareTo(b.dictionary.value!.order));

    if (entries.isEmpty) {
      return const SliverPadding(padding: EdgeInsets.zero);
    }

    return SliverStack(
      children: [
        SliverPositioned.fill(
          child: Card(
            color: appModel.isDarkMode
                ? Color.fromRGBO(16, 16, 16, opacity)
                : Color.fromRGBO(249, 249, 249, opacity),
            elevation: 0,
            shape: const RoundedRectangleBorder(),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.only(
            left: Spacing.of(context).spaces.semiBig,
            top: Spacing.of(context).spaces.normal,
            right: Spacing.of(context).spaces.normal,
            bottom: Spacing.of(context).spaces.normal,
          ),
          sliver: MultiSliver(
            children: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _DictionaryTermTopRow(
                      heading: heading,
                    ),
                    if (heading.tags.isNotEmpty) const Space.normal(),
                    if (heading.tags.isNotEmpty)
                      _DictionaryTermTagsWrap(heading: heading),
                    const Space.normal(),
                    _DictionaryTermFreqList(heading: heading),
                  ],
                ),
              ),
              if (!isPipMode)
                SliverPadding(
                  padding: Spacing.of(context).insets.onlyBottom.normal,
                  sliver: _DictionaryTermPitchList(heading: heading),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: footerWidget != null
                      ? entries.length + 1
                      : entries.length,
                  (context, index) {
                    if (index == entries.length && footerWidget != null) {
                      return footerWidget;
                    }

                    DictionaryEntry entry = entries[index];

                    return DictionaryEntryPage(
                      entry: entry,
                      onSearch: onSearch,
                      onStash: onStash,
                      expandableController:
                          expandableControllers[entry.dictionary.value!]!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DictionaryTermActionsRow extends ConsumerWidget {
  const _DictionaryTermActionsRow({
    required this.heading,
  });

  /// The result made from a dictionary database search.
  final DictionaryHeading heading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppModel appModel = ref.watch(appProvider);
    CreatorModel creatorModel = ref.watch(creatorProvider);

    List<Widget> buttons = [];

    for (int i = 0; i < appModel.maximumQuickActions; i++) {
      String? actionName = appModel.lastSelectedMapping.actions![i];
      QuickAction? quickAction;

      if (actionName != null) {
        quickAction = appModel.quickActions[actionName];
      }

      late Widget button;

      if (quickAction == null) {
        button = const SizedBox.shrink();
      } else {
        ValueNotifier<bool> notifier = ValueNotifier(true);
        button = Padding(
          padding: Spacing.of(context).insets.onlyLeft.semiSmall,
          child: ValueListenableBuilder<bool>(
            valueListenable: notifier,
            builder: (context, _, child) {
              return JidoujishoIconButton(
                busy: true,
                enabledColor: quickAction!.getIconColor(
                  context: context,
                  appModel: appModel,
                  heading: heading,
                ),
                shapeBorder: const RoundedRectangleBorder(),
                backgroundColor: appModel.isDarkMode
                    ? Colors.grey.shade900
                    : Colors.grey.shade200,
                size: Spacing.of(context).spaces.semiBig,
                tooltip: quickAction.getLocalisedLabel(appModel),
                icon: quickAction.icon,
                onTap: () async {
                  await quickAction!.executeAction(
                    context: context,
                    ref: ref,
                    appModel: appModel,
                    creatorModel: creatorModel,
                    heading: heading,
                  );
                  notifier.value = !notifier.value;
                },
              );
            },
          ),
        );
      }

      buttons.add(button);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: buttons.reversed.toList(),
    );
  }
}

class _DictionaryTermPitchList extends ConsumerWidget {
  const _DictionaryTermPitchList({
    required this.heading,
  });

  /// The result made from a dictionary database search.
  final DictionaryHeading heading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppModel appModel = ref.watch(appProvider);

    List<DictionaryPitch> pitches = heading.pitches
        .where((pitch) =>
            !pitch.dictionary.value!.isHidden(appModel.targetLanguage))
        .toList();
    if (pitches.isEmpty) {
      return const SliverPadding(padding: EdgeInsets.zero);
    }

    pitches.sort((a, b) =>
        a.dictionary.value!.order.compareTo(b.dictionary.value!.order));

    Map<Dictionary, List<DictionaryPitch>> pitchesByDictionary =
        groupBy<DictionaryPitch, Dictionary>(
            pitches, (pitch) => pitch.dictionary.value!);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
          childCount: pitchesByDictionary.length, (context, index) {
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
                    reading: heading.reading,
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
                    reading: heading.reading,
                    downstep: pitch.downstep,
                  ),
                ),
              )
              .toList();

          return Wrap(
            children: [
              JidoujishoTag(
                text: dictionary.name,
                backgroundColor: Colors.red.shade900,
              ),
              ...pitchWidgets,
            ],
          );
        }
      }),
    );
  }
}

class _DictionaryTermFreqList extends ConsumerWidget {
  const _DictionaryTermFreqList({
    required this.heading,
  });

  /// The result made from a dictionary database search.
  final DictionaryHeading heading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppModel appModel = ref.watch(appProvider);

    List<DictionaryFrequency> frequencies = heading.frequencies
        .where((frequency) =>
            !frequency.dictionary.value!.isHidden(appModel.targetLanguage))
        .toList();

    frequencies += appModel.getNoReadingFrequencies(heading: heading);

    if (frequencies.isEmpty) {
      return const SizedBox.shrink();
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
          trailingText: frequenciesForDictionary.value
              .map((e) => e.displayValue)
              .join(', '),
          backgroundColor: Colors.red.shade900,
        ),
      );
    }).toList();

    return Wrap(children: children);
  }
}

class _DictionaryTermTagsWrap extends ConsumerWidget {
  const _DictionaryTermTagsWrap({
    required this.heading,
  });

  /// The result made from a dictionary database search.
  final DictionaryHeading heading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> children = heading.tags.map((tag) {
      return JidoujishoTag(
        text: tag.name,
        message: tag.notes,
        backgroundColor: tag.color,
      );
    }).toList();

    return Wrap(children: children);
  }
}

class _DictionaryTermTopRow extends ConsumerWidget {
  const _DictionaryTermTopRow({
    required this.heading,
  });

  /// The result made from a dictionary database search.
  final DictionaryHeading heading;

  /// The result made fr
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppModel appModel = ref.watch(appProvider);
    return FloatColumn(
      children: [
        if (!appModel.isPipMode)
          Floatable(
            float: FCFloat.end,
            padding: EdgeInsets.only(
              top: Spacing.of(context).spaces.small,
              right: Spacing.of(context).spaces.small,
              bottom: Spacing.of(context).spaces.small,
            ),
            child: _DictionaryTermActionsRow(heading: heading),
          ),
        Floatable(
          float: FCFloat.start,
          child: GestureDetector(
            child: appModel.targetLanguage.getTermReadingOverrideWidget(
              context: context,
              appModel: appModel,
              heading: heading,
            ),
            onTap: () => appModel.copyToClipboard(heading.term),
            onLongPress: () => appModel.copyToClipboard(heading.term),
          ),
        ),
      ],
    );
  }
}
