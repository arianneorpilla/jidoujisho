import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';

/// An enhancement used to pick an appropriate term from a text field easily.
class TextSegmentationEnhancement extends Enhancement {
  /// Initialise this enhancement with the hardset parameters.
  TextSegmentationEnhancement({required super.field})
      : super(
          uniqueKey: key,
          label: 'Text Segmentation',
          description: 'Search or select a new term from segmented text.',
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

    if (sourceText.trim().isEmpty) {
      String noTextLabel = appModel.translate('no_text_to_segment');
      Fluttertoast.showToast(
        msg: noTextLabel,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    appModel.openTextSegmentationDialog(
      sourceText: sourceText,
      onSearch: (selection, items) {
        appModel.openRecursiveDictionarySearch(
          searchTerm: selection,
          killOnPop: false,
        );
      },
      onSelect: (selection, items) {
        creatorModel.getFieldController(TermField.instance).text = selection;
        Navigator.pop(context);
      },
    );
  }
}
