import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/i18n/strings.g.dart';

/// An enhancement used effectively as a shortcut for clearing the contents
/// of a [CreatorModel] pertaining to a certain field.
class ClearFieldEnhancement extends Enhancement {
  /// Initialise this enhancement with the hardset parameters.
  ClearFieldEnhancement({required super.field})
      : super(
          uniqueKey: key,
          label: t.clear_field_enhancement,
          description: t.clear_field_enhancement_description,
          icon: Icons.clear,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'clear_field';

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    creatorModel.clearField(
      field,
      overrideLocks: true,
      savedTags: '',
    );
  }
}
