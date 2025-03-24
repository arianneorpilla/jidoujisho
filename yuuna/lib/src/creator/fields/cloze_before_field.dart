import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/i18n/strings.g.dart';

/// Text before highlighted text in a sentence
class ClozeBeforeField extends Field {
  /// Initialise this field with the predetermined and hardset values.
  ClozeBeforeField._privateConstructor()
      : super(
          uniqueKey: key,
          label: t.cloze_before_field,
          description: t.cloze_before_field_description,
          icon: Icons.keyboard_double_arrow_left,
        );

  /// Get the singleton instance of this field.
  static ClozeBeforeField get instance => _instance;

  static final ClozeBeforeField _instance =
      ClozeBeforeField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'cloze_before';

  @override
  String? onCreatorOpenAction({
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required bool creatorJustLaunched,
    required String? dictionaryName,
  }) {
    if (creatorJustLaunched) {
      return appModel.getCurrentSentence().textBefore.trimLeft();
    } else {
      return null;
    }
  }
}
