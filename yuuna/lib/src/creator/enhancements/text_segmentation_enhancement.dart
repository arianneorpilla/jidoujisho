import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';

/// An enhancement used to pick an appropriate word from a text field easily.
class TextSegmentationEnhancement extends Enhancement {
  /// Initialise this enhancement with the hardset parameters.
  TextSegmentationEnhancement({required super.field})
      : super(
          uniqueKey: key,
          label: 'Text Segmentation',
          description: 'Search or select a new word from segmented text.',
          icon: Icons.account_tree,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'text_segmentation';

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    String sourceText = creatorModel.getFieldController(field).text;
    appModel.openTextSegmentationDialog(
      sourceText: sourceText,
      onSearch: (selection) {
        appModel.openRecursiveDictionarySearch(
          searchTerm: selection,
          killOnPop: false,
        );
      },
      onSelect: (selection) {
        creatorModel.getFieldController(field).text = selection;
      },
    );
  }
}
