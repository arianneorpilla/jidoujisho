import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';
import 'package:collection/collection.dart';

/// Used to return a formatted text from multiple dictionary entries.
class MeaningField extends Field {
  /// Initialise this field with the predetermined and hardset values.
  MeaningField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Meaning',
          description: 'All dictionary definitions of a term.',
          icon: Icons.translate_rounded,
        );

  /// Get the singleton instance of this field.
  static MeaningField get instance => _instance;

  static final MeaningField _instance = MeaningField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'meaning';

  /// Get a single combined text for all meanings in a list of entries.
  static String flattenMeanings({
    required List<DictionaryEntry> entries,
    required bool prependDictionaryNames,
  }) {
    StringBuffer meaningBuffer = StringBuffer();

    Map<String, List<DictionaryEntry>> entriesByDictionaryName =
        groupBy<DictionaryEntry, String>(
      entries,
      (entry) => entry.dictionary.value!.name,
    );

    entriesByDictionaryName.forEach((dictionaryName, singleDictionaryEntries) {
      int meaningsCount = 0;
      for (DictionaryEntry entry in singleDictionaryEntries) {
        meaningsCount += entry.definitions.length;
      }

      if (prependDictionaryNames) {
        meaningBuffer.writeln('【$dictionaryName】');
      }

      for (DictionaryEntry entry in singleDictionaryEntries) {
        if (singleDictionaryEntries.length == 1) {
          entry.definitions.forEachIndexed((index, meaning) {
            if (meaningsCount != 1) {
              meaningBuffer.write('• $meaning');
            } else {
              meaningBuffer.write(meaning);
            }

            if (index != entry.definitions.length - 1) {
              meaningBuffer.write('\n');
            }
          });
        } else {
          entry.definitions.forEachIndexed((index, meaning) {
            if (meaningsCount == 1) {
              meaningBuffer.write('$meaning\n');
            } else {
              if (index == 0) {
                meaningBuffer.write('• ');
              }
              meaningBuffer.write(meaning);
              if (index != entry.definitions.length - 1) {
                meaningBuffer.write('; ');
              }
            }
          });
        }

        meaningBuffer.write('\n');
      }

      meaningBuffer.write('\n');
    });

    return meaningBuffer.toString().trim();
  }

  @override
  String? onCreatorOpenAction({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required bool creatorJustLaunched,
  }) {
    return flattenMeanings(
      entries: heading.entries.toList(),
      prependDictionaryNames:
          appModel.lastSelectedMapping.prependDictionaryNames ?? false,
    );
  }
}
