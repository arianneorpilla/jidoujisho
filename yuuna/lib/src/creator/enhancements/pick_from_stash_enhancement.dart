import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';

/// An enhancement used to view and manage the Stash.
class PickFromStashEnhancement extends Enhancement {
  /// Initialise this enhancement with the hardset parameters.
  PickFromStashEnhancement({required super.field})
      : super(
          uniqueKey: key,
          label: 'Pick From Stash',
          description: 'View and manage previously stashed text.',
          icon: Icons.inventory_2,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'pick_from_stash';

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    appModel.openStash(
      onSelect: (selection) {
        creatorModel.getFieldController(field).text = selection;
      },
    );
  }
}
