import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Used to track the current sentence context from the current playing media
/// in the application.
class TermField extends FieldNua {
  /// Initialise this field with the predetermined and hardset values.
  TermField({
    super.uniqueKey = 'term',
    super.label = 'Term',
    super.description = 'Dictionary word or phrase',
    super.icon = Icons.speaker_notes_outlined,
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
    return term;
  }
}
