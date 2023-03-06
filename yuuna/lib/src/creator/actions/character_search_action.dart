import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/dictionary.dart';

/// An enhancement that is useful for searching single characters, such as
/// kanji characters.
class CharacterSearchAction extends QuickAction {
  /// Initialise this enhancement with the hardset parameters.
  CharacterSearchAction()
      : super(
          uniqueKey: key,
          label: 'Character Search',
          description: 'Select a single character and search.',
          icon: Icons.select_all,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'character_search';

  @override
  Future<void> executeAction(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel,
      required CreatorModel creatorModel,
      required DictionaryHeading heading}) async {
    appModel.openTextSegmentationDialog(
      sourceText: heading.term,
      segmentedText: heading.term.characters.toList(),
      onSearch: (selection, items) {
        appModel.openRecursiveDictionarySearch(
          searchTerm: selection,
          killOnPop: false,
        );
      },
    );
  }
}
