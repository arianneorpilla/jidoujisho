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
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required bool creatorJustLaunched,
  }) {
    List<DictionaryEntry> expandedEntries = heading.entries
        .where((entry) =>
            !entry.dictionary.value!.hidden &&
            !entry.dictionary.value!.collapsed)
        .toList();

    return MeaningField.flattenMeanings(
        entries: expandedEntries,
        prependDictionaryNames:
            appModel.lastSelectedMapping.prependDictionaryNames ?? false);
  }
}
