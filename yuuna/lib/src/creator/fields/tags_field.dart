import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/i18n/strings.g.dart';

/// Organise notes in a deck with space-delimited labels.
class TagsField extends Field {
  /// Initialise this field with the predetermined and hardset values.
  TagsField._privateConstructor()
      : super(
          uniqueKey: key,
          label: t.tags_field,
          description: t.tags_field_description,
          icon: Icons.sell,
        );

  /// Get the singleton instance of this field.
  static TagsField get instance => _instance;

  static final TagsField _instance = TagsField._privateConstructor();

  /// The unique key for this field.
  static const String key = 'tags';

  @override
  String? onCreatorOpenAction({
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required bool creatorJustLaunched,
    required String? dictionaryName,
  }) {
    return appModel.savedTags;
  }
}
