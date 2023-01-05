import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';

/// An enhancement used to pick a new image search term.
class ImageSearchTermPickerEnhancement extends Enhancement {
  /// Initialise this enhancement with the hardset parameters.
  ImageSearchTermPickerEnhancement()
      : super(
          uniqueKey: key,
          label: 'Image Search Term Picker',
          description:
              'Select an image search term from all text currently in the Card Creator.',
          icon: Icons.account_tree,
          field: ImageField.instance,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'image_search_term_picker';

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    List<String> controllers = appModel.lastSelectedMapping
        .getCreatorFields()
        .map((field) => creatorModel.getFieldController(field).text)
        .toList();
    String sourceText = controllers.join(' ');

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
      onSelect: (selection, items) {
        creatorModel.getFieldController(ImageField.instance).text =
            selection.replaceAll('\n', ' ');
        Navigator.pop(context);
      },
    );
  }
}
