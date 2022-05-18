import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/src/dictionary/dictionary_entry.dart';

/// An enhancement used effectively as a shortcut for opening the Card Creator.
class CardCreatorAction extends QuickAction {
  /// Initialise this enhancement with the hardset parameters.
  CardCreatorAction()
      : super(
          uniqueKey: key,
          label: 'Card Creator',
          description:
              'Create a card with the selected dictionary entry parameters and'
              ' edit before export.',
          icon: Icons.note_add,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'card_creator';

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
    StringBuffer meaningBuffer = StringBuffer();

    Map<String, List<DictionaryEntry>> entriesByDictionaryName =
        groupBy<DictionaryEntry, String>(
      entries,
      (entry) => entry.dictionaryName,
    );

    entriesByDictionaryName.forEach((dictionaryName, singleDictionaryEntries) {
      int meaningsCount = 0;
      for (DictionaryEntry entry in singleDictionaryEntries) {
        meaningsCount += entry.meanings.length;
      }

      for (DictionaryEntry entry in singleDictionaryEntries) {
        if (singleDictionaryEntries.length == 1) {
          entry.meanings.forEachIndexed((index, meaning) {
            if (meaningsCount == 1) {
              meaningBuffer.write(meaning);
            } else {
              if (index == 0) {
                meaningBuffer.write('• ');
              }
              meaningBuffer.write(meaning);
              if (index != entry.meanings.length - 1) {
                meaningBuffer.write('; ');
              }
            }
          });
        } else {
          entry.meanings.forEachIndexed((index, meaning) {
            if (meaningsCount == 1) {
              meaningBuffer.write(meaning);
            } else {
              if (index == 0) {
                meaningBuffer.write('• ');
              }
              meaningBuffer.write(meaning);
              if (index != entry.meanings.length - 1) {
                meaningBuffer.write('; ');
              }
            }
          });
        }

        meaningBuffer.write('\n');
      }

      meaningBuffer.write('\n');
    });

    String meaning = meaningBuffer.toString().trim();

    creatorModel.clearAll();
    creatorModel.copyContext(
      CreatorContext(
        word: word,
        reading: reading,
        meaning: meaning,
      ),
    );

    appModel.openCreator();
  }
}
