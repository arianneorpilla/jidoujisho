import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// Returns audio information from context.
class ImageField extends ImageExportField {
  /// Initialise this field with the predetermined and hardset values.
  ImageField._privateConstructor()
      : super(
          uniqueKey: key,
          label: 'Image',
          description: 'Enter image search term',
          icon: Icons.image,
        );

  /// Get the singleton instance of this field.
  static ImageField get instance => _instance;

  static final ImageField _instance = ImageField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'image';

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
