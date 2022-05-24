import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Used to track the current sentence context from the current playing media
/// in the application.
class SentenceField extends FieldNua {
  /// Initialise this field with the predetermined and hardset values.
  SentenceField({
    super.uniqueKey = 'sentence',
    super.label = 'Sentence',
    super.description = 'Example sentence or context',
    super.icon = Icons.format_align_center,
  });

  @override
  String onCreatorOpenAction({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required String term,
    required String reading,
    required List<DictionaryEntry> entries,
  }) {
    throw UnimplementedError(
      'Field must generate a value upon opening creator',
    );
  }
}
