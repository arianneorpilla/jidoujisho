import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/utils.dart';

/// An enhancement used to pop the latest element of the Stash onto a field.
class PopFromStashEnhancement extends Enhancement {
  /// Initialise this enhancement with the hardset parameters.
  PopFromStashEnhancement({required super.field})
      : super(
          uniqueKey: key,
          label: 'Pop From Stash',
          description: 'Quickly pop the latest item in the Stash.',
          icon: Icons.bookmark_remove,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'pop_from_stash';

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    List<String> stashContents = appModel.getStash();
    if (stashContents.isEmpty) {
      Fluttertoast.showToast(
        msg: t.stash_nothing_to_pop,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else {
      String lastStashItem = stashContents.last;

      appModel.removeFromStash(term: lastStashItem);
      creatorModel.getFieldController(field).text = lastStashItem;
    }
  }
}
