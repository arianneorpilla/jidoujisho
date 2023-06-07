import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Used to return a formatted text from multiple dictionary entries from
/// expanded dictionaries only.
class ExpandedMeaningField extends Field {
  /// Initialise this field with the predetermined and hardset values.
  ExpandedMeaningField._privateConstructor()
      : super(
            uniqueKey: key,
            label: 'Expanded Meaning',
            description: 'Dictionary definitions only from expanded'
                ' dictionaries.',
            icon: Icons.open_in_full);

  /// Get the singleton instance of this field.
  static ExpandedMeaningField get instance => _instance;

  static final ExpandedMeaningField _instance =
      ExpandedMeaningField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'expanded_meaning';

  @override
  String? onCreatorOpenAction({
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required bool creatorJustLaunched,
    required String? dictionaryName,
  }) {
    List<Dictionary> dictionaries = appModel.dictionaries;
    Map<String, bool> dictionaryNamesByHidden = Map<String, bool>.fromEntries(
        dictionaries
            .map((e) => MapEntry(e.name, e.isHidden(appModel.targetLanguage))));
    Map<String, bool> dictionaryNamesByCollapsed =
        Map<String, bool>.fromEntries(dictionaries.map(
            (e) => MapEntry(e.name, e.isCollapsed(appModel.targetLanguage))));
    Map<String, int> dictionaryNamesByOrder = Map<String, int>.fromEntries(
        dictionaries.map((e) => MapEntry(e.name, e.order)));

    late List<DictionaryEntry> expandedEntries;
    if (dictionaryName != null) {
      expandedEntries = heading.entries
          .where((entry) =>
              !dictionaryNamesByHidden[entry.dictionary.value!.name]! &&
              dictionaryName == entry.dictionary.value!.name)
          .toList();
    } else {
      expandedEntries = heading.entries
          .where((entry) =>
              !dictionaryNamesByHidden[entry.dictionary.value!.name]! &&
              !dictionaryNamesByCollapsed[entry.dictionary.value!.name]!)
          .toList();
    }

    expandedEntries.sort((a, b) =>
        dictionaryNamesByOrder[a.dictionary.value!.name]!
            .compareTo(dictionaryNamesByOrder[b.dictionary.value!.name]!));

    return MeaningField.flattenMeanings(
        entries: expandedEntries,
        prependDictionaryNames:
            appModel.lastSelectedMapping.prependDictionaryNames ?? false);
  }
}
