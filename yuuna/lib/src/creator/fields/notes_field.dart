import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Supplies supplementary data that may be useful to include in a card.
class NotesField extends Field {
  /// Initialise this field with the predeAudioined and hardset values.
  NotesField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Notes',
          description: 'Supplementary information or personal observations.',
          icon: Icons.description,
        );

  /// Get the singleton instance of this field.
  static NotesField get instance => _instance;

  static final NotesField _instance = NotesField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'notes';

  @override
  String? onCreatorOpenAction({
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required bool creatorJustLaunched,
    required String? dictionaryName,
  }) {
    return null;
  }
}
