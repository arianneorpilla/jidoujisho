import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/src/dictionary/dictionary_entry.dart';

/// An enhancement used effectively as a shortcut for exporting a card.
class InstantExportAction extends QuickAction {
  /// Initialise this enhancement with the hardset parameters.
  InstantExportAction()
      : super(
          uniqueKey: key,
          label: 'Instant Export',
          description:
              'Export a card with the selected dictionary entry parameters.',
          icon: Icons.send,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'instant_export';

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
    debugPrint('todo');
  }
}
