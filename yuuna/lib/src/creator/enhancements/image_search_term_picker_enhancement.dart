import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';

/// An enhancement used to pick an appropriate term from a text field easily.
class ImageSearchTermPicker extends Enhancement {
  /// Initialise this enhancement with the hardset parameters.
  ImageSearchTermPicker({required super.field})
      : super(
          uniqueKey: key,
          label: 'Image Search Term Picker',
          description: 'Select text segmented terms of a field, then use it as'
              ' an image search term with the active auto image enhancement.',
          icon: Icons.manage_search,
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
        if (appModel.activeFields.contains(ImageField.instance)) {
          ImageEnhancement? enhancement =
              appModel.lastSelectedMapping.getAutoFieldEnhancement(
            appModel: appModel,
            field: ImageField.instance,
          )! as ImageEnhancement;

          String searchTerm = items.join(' ').trim();
          if (searchTerm.isEmpty) {
            searchTerm = sourceText;
          }

          ImageField.instance.performSearch(
            appModel: appModel,
            creatorModel: creatorModel,
            searchTerm: searchTerm,
            generateImages: () => enhancement.fetchImages(
              context: context,
              searchTerm: searchTerm,
            ),
          );

          Navigator.pop(context);
        }
      },
      onSelect: (selection, items) {
        creatorModel.getFieldController(ImageField.instance).text =
            items.join(' ');
        Navigator.pop(context);
      },
    );
  }
}
