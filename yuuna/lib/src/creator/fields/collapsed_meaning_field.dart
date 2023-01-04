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
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryTerm dictionaryTerm,
    required List<DictionaryMetaEntry> metaEntries,
    required bool creatorJustLaunched,
  }) {
    List<String> collapsedDictionaries = appModel.dictionaries
        .where((dictionary) => dictionary.collapsed && !dictionary.hidden)
        .map((dictionary) => dictionary.dictionaryName)
        .toList();

    List<DictionaryEntry> collapsedEntries = dictionaryTerm.entries!
        .where((entry) => collapsedDictionaries.contains(entry.dictionaryName))
        .toList();

    return MeaningField.flattenMeanings(collapsedEntries);
  }
}
