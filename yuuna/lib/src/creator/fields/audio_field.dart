import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Returns audio information from context.
class AudioField extends AudioExportField {
  /// Initialise this field with the predetermined and hardset values.
  AudioField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Audio',
          description: 'Enter audio search term',
          icon: Icons.audiotrack,
        );

  /// Get the singleton instance of this field.
  static AudioField get instance => _instance;

  static final AudioField _instance = AudioField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'audio';

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
