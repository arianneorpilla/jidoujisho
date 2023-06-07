import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Used to track the current sentence context from the current playing media
/// in the application.
class ReadingField extends Field {
  /// Initialise this field with the predetermined and hardset values.
  ReadingField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Reading',
          description: 'Pronunciation or speech pattern.',
          icon: Icons.surround_sound_outlined,
        );

  /// Get the singleton instance of this field.
  static ReadingField get instance => _instance;

  static final ReadingField _instance = ReadingField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'reading';

  @override
  String? onCreatorOpenAction({
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required bool creatorJustLaunched,
    required String? dictionaryName,
  }) {
    return heading.reading;
  }
}
