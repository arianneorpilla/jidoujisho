import 'package:float_column/float_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
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
    required this.dictionaryNamesByHidden,
    required this.dictionaryNamesByOrder,
    required this.lastSelectedMapping,
    this.cardColor,
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
  final Map<Dictionary, ExpandedTileController> expandableControllers;

  /// Lists whether a dictionary is hidden.
  final Map<String, bool> dictionaryNamesByHidden;

  /// Lists the order of dictionaries.
  final Map<String, int> dictionaryNamesByOrder;

  /// Optional footer foor use in [DictionaryHistoryPage].
  final Widget? footerWidget;

  /// Override color for card background color.
  final Color? cardColor;

  /// Opacity for entries.
  final double opacity;

  /// Last selected mapping for optimisation purposes. Not including this
  /// before caused rendering jank as database queries were performed multiple
  /// times for getting this value.
  final AnkiMapping lastSelectedMapping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppModel appModel = ref.watch(appProvider);

    List<DictionaryEntry> entries = heading.entries
        .where(
            (entry) => !dictionaryNamesByHidden[entry.dictionary.value!.name]!)
        .toList();

    entries.sort((a, b) => dictionaryNamesByOrder[a.dictionary.value!.name]!
        .compareTo(dictionaryNamesByOrder[b.dictionary.value!.name]!));

    if (entries.isEmpty) {
      return const SliverPadding(padding: EdgeInsets.zero);
    }

    return SliverStack(
      children: [
        SliverPositioned.fill(
          child: Card(
            color: cardColor?.withOpacity(opacity) ??
                (appModel.isDarkMode
                    ? Color.fromRGBO(16, 16, 16, opacity)
                    : Color.fromRGBO(249, 249, 249, opacity)),
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
                    _DictionaryTermFreqList(
                      heading: heading,
                      dictionaryNamesByHidden: dictionaryNamesByHidden,
                    ),
                  ],
                ),
              ),
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

class _DictionaryTermActionsRow extends ConsumerStatefulWidget {
  const _DictionaryTermActionsRow({
    required this.heading,
  });

  /// The result made from a dictionary database search.
  final DictionaryHeading heading;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DictionaryTermActionsRowState();
}

class _DictionaryTermActionsRowState
    extends ConsumerState<_DictionaryTermActionsRow> {
  Map<String, Color?>? _lastColors;

  @override
  Widget build(BuildContext context) {
    AppModel appModel = ref.watch(appProvider);
    CreatorModel creatorModel = ref.watch(creatorProvider);

    AsyncValue<Map<String, Color?>> colors =
        ref.watch(quickActionColorProvider(widget.heading));
    Map<String, Color?> defaultColors = Map<String, Color?>.fromEntries(
        appModel.quickActions.values.map((e) => MapEntry(e.uniqueKey, null)));

    _lastColors ??= defaultColors;

    return colors.when(
      data: (colors) {
        _lastColors = colors;
        return buildRow(
          context: context,
          appModel: appModel,
          creatorModel: creatorModel,
          ref: ref,
          colors: colors,
        );
      },
      loading: () => buildRow(
        context: context,
        appModel: appModel,
        creatorModel: creatorModel,
        ref: ref,
        colors: _lastColors!,
      ),
      error: (_, __) => buildRow(
        context: context,
        appModel: appModel,
        creatorModel: creatorModel,
        ref: ref,
        colors: _lastColors!,
      ),
    );
  }

  Widget buildRow({
    required BuildContext context,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required WidgetRef ref,
    required Map<String, Color?> colors,
  }) {
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
        late Color enabledColor;
        Color defaultColor = Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black;
        enabledColor = colors[quickAction.uniqueKey] ?? defaultColor;
        button = Padding(
          padding: Spacing.of(context).insets.onlyLeft.semiSmall,
          child: JidoujishoIconButton(
            busy: true,
            enabledColor: enabledColor,
            disabledColor: enabledColor.withOpacity(0.8),
            shapeBorder: const RoundedRectangleBorder(),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            size: Spacing.of(context).spaces.semiBig,
            tooltip: quickAction.getLocalisedLabel(appModel),
            icon: quickAction.icon,
            onTap: () async {
              await quickAction!.executeAction(
                context: context,
                ref: ref,
                appModel: appModel,
                creatorModel: creatorModel,
                heading: widget.heading,
                dictionaryName: null,
              );
              ref.refresh(quickActionColorProvider(widget.heading));
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
    required this.dictionaryNamesByHidden,
  });

  /// The result made from a dictionary database search.
  final DictionaryHeading heading;

  /// Lists whether a dictionary is hidden.
  final Map<String, bool> dictionaryNamesByHidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppModel appModel = ref.watch(appProvider);

    List<DictionaryFrequency> frequencies = heading.frequencies
        .where((frequency) =>
            !dictionaryNamesByHidden[frequency.dictionary.value!.name]!)
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppModel appModel = ref.watch(appProvider);
    return FloatColumn(
      children: [
        Floatable(
          float: FCFloat.end,
          padding: EdgeInsets.only(
            top: Spacing.of(context).spaces.small,
            right: Spacing.of(context).spaces.small,
            bottom: Spacing.of(context).spaces.small,
          ),
          child: _DictionaryTermActionsRow(
            heading: heading,
          ),
        ),
        Floatable(
          float: FCFloat.start,
          child: GestureDetector(
            child: appModel.targetLanguage.getTermReadingOverrideWidget(
              context: context,
              appModel: appModel,
              heading: heading,
            ),
          ),
        ),
      ],
    );
  }
}
