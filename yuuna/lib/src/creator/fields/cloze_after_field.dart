import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Text after highlighted text in a sentence.
class ClozeAfterField extends Field {
  /// Initialise this field with the predetermined and hardset values.
  ClozeAfterField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Cloze After',
          description: 'Text after highlighted text in a sentence. '
              'Empty if nothing is highlighted.',
          icon: Icons.keyboard_double_arrow_right,
        );

  /// Get the singleton instance of this field.
  static ClozeAfterField get instance => _instance;

  static final ClozeAfterField _instance =
      ClozeAfterField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'cloze_after';

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
      return appModel.getCurrentSentence().textAfter.trimRight();
    } else {
      return null;
    }
  }
}
