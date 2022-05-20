import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// An enhancement used as a shortcut for adding text items to the Stash.
class AddToStashEnhancement extends QuickAction {
  /// Initialise this enhancement with the hardset parameters.
  AddToStashEnhancement()
      : super(
          uniqueKey: key,
          label: 'Add To Stash',
          description:
              'Quickly save the headword of a dictionary entry to the Stash.',
          icon: Icons.file_download,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'add_to_stash';

  @override
  Future<void> executeAction({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required String word,
    required String reading,
    required List<DictionaryEntry> entries,
  }) async {
    appModel.addToStash(terms: [word]);
  }
}
