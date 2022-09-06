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
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryTerm dictionaryTerm,
    required List<DictionaryMetaEntry> metaEntries,
    required bool creatorJustLaunched,
  }) {
    List<String> hiddenDictionaries = appModel.dictionaries
        .where((dictionary) => dictionary.hidden)
        .map((dictionary) => dictionary.dictionaryName)
        .toList();

    List<DictionaryEntry> hiddenEntries = dictionaryTerm.entries
        .where((entry) => hiddenDictionaries.contains(entry.dictionaryName))
        .toList();

    return MeaningField.flattenMeanings(hiddenEntries);
  }
}
