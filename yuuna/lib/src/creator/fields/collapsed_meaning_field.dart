import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Used to return a formatted text from hidden dictionary entries from
/// collapsed dictionaries only.
class CollapsedMeaningField extends Field {
  /// Initialise this field with the predetermined and hardset values.
  CollapsedMeaningField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Collapsed Meaning',
          description: 'Dictionary definitions only from collapsed'
              ' dictionaries.',
          icon: Icons.close_fullscreen,
        );

  /// Get the singleton instance of this field.
  static CollapsedMeaningField get instance => _instance;

  static final CollapsedMeaningField _instance =
      CollapsedMeaningField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'collapsed_meaning';

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

    late List<DictionaryEntry> collapsedEntries;
    if (dictionaryName != null) {
      collapsedEntries = heading.entries
          .where((entry) =>
              !dictionaryNamesByHidden[entry.dictionary.value!.name]! &&
              dictionaryName != entry.dictionary.value!.name)
          .toList();
    } else {
      collapsedEntries = heading.entries
          .where((entry) =>
              !dictionaryNamesByHidden[entry.dictionary.value!.name]! &&
              dictionaryNamesByCollapsed[entry.dictionary.value!.name]!)
          .toList();
    }

    collapsedEntries.sort((a, b) =>
        dictionaryNamesByOrder[a.dictionary.value!.name]!
            .compareTo(dictionaryNamesByOrder[b.dictionary.value!.name]!));

    return MeaningField.flattenMeanings(
        entries: collapsedEntries,
        prependDictionaryNames:
            appModel.lastSelectedMapping.prependDictionaryNames ?? false);
  }
}
