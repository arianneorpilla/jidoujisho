import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Used to track the current sentence context from the current playing media
/// in the application.
class SentenceField extends FieldNua {
  /// Initialise this field with the predetermined and hardset values.
  SentenceField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Sentence',
          description: 'Example sentence or context',
          icon: Icons.format_align_center,
        );

  /// Get the singleton instance of this field.
  static SentenceField get instance => _instance;

  static final SentenceField _instance = SentenceField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'sentence';

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
