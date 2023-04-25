import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/utils.dart';

/// An enhancement used to save the Tags field's last value.
class SaveTagsEnhancement extends Enhancement {
  /// Initialise this enhancement with the hardset parameters.
  SaveTagsEnhancement()
      : super(
          uniqueKey: key,
          label: 'Save Tags',
          description: 'Persist the current text in the Tags field.',
          icon: Icons.save,
          field: TagsField.instance,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'save_tags';

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    String tags =
        creatorModel.getFieldController(TagsField.instance).text.trim();
    appModel.setSavedTags(tags);

    Fluttertoast.showToast(
      msg: t.saved_tags,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
