import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Used to return a formatted text from hidden dictionary entries.
class HiddenMeaningField extends Field {
  /// Initialise this field with the predetermined and hardset values.
  HiddenMeaningField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Hidden Meaning',
          description: 'Dictionary definitions only from hidden'
              ' dictionaries.',
          icon: Icons.visibility_off,
        );

  /// Get the singleton instance of this field.
  static HiddenMeaningField get instance => _instance;

  static final HiddenMeaningField _instance =
      HiddenMeaningField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'hidden_meaning';

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
    Map<String, int> dictionaryNamesByOrder = Map<String, int>.fromEntries(
        dictionaries.map((e) => MapEntry(e.name, e.order)));

    List<DictionaryEntry> hiddenEntries = heading.entries
        .where(
            (entry) => dictionaryNamesByHidden[entry.dictionary.value!.name]!)
        .toList();

    hiddenEntries.sort((a, b) =>
        dictionaryNamesByOrder[a.dictionary.value!.name]!
            .compareTo(dictionaryNamesByOrder[b.dictionary.value!.name]!));

    return MeaningField.flattenMeanings(
        entries: hiddenEntries,
        prependDictionaryNames:
            appModel.lastSelectedMapping.prependDictionaryNames ?? false);
  }
}
