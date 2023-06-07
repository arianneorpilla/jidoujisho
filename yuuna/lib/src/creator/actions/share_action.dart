import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/dictionary.dart';

/// An enhancement that calls the native share API for sharing word details.
class ShareAction extends QuickAction {
  /// Initialise this enhancement with the hardset parameters.
  ShareAction()
      : super(
          uniqueKey: key,
          label: 'Share',
          description: 'Share the details of a dictionary term.',
          icon: Icons.share,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'share';

  @override
  Future<void> executeAction({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required String? dictionaryName,
  }) async {
    List<Dictionary> dictionaries = appModel.dictionaries;

    Map<String, bool> dictionaryNamesByHidden = Map<String, bool>.fromEntries(
        dictionaries
            .map((e) => MapEntry(e.name, e.isHidden(appModel.targetLanguage))));
    Map<String, int> dictionaryNamesByOrder = Map<String, int>.fromEntries(
        dictionaries.map((e) => MapEntry(e.name, e.order)));

    List<DictionaryEntry> entries = heading.entries
        .where(
            (entry) => !dictionaryNamesByHidden[entry.dictionary.value!.name]!)
        .toList();
    if (dictionaryName != null) {
      entries = [
        ...entries.where((e) => dictionaryName == e.dictionary.value!.name)
      ];
    }
    entries.sort((a, b) => dictionaryNamesByOrder[a.dictionary.value!.name]!
        .compareTo(dictionaryNamesByOrder[b.dictionary.value!.name]!));

    StringBuffer buffer = StringBuffer();
    buffer.write(heading.term);
    if (heading.reading.isNotEmpty) {
      buffer.write(' (${heading.reading})');
    }
    buffer.write('\n\n');
    buffer.write(
      MeaningField.flattenMeanings(
        entries: entries,
        prependDictionaryNames:
            appModel.lastSelectedMapping.prependDictionaryNames ?? false,
      ),
    );

    String shareText = buffer.toString();

    Share.share(shareText);
  }
}
