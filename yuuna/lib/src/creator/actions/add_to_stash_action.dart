import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';

/// An enhancement used as a shortcut for adding text items to the Stash.
class AddToStashAction extends QuickAction {
  /// Initialise this enhancement with the hardset parameters.
  AddToStashAction()
      : super(
          uniqueKey: key,
          label: 'Add To Stash',
          description:
              'Quickly save the headword of a dictionary entry to the Stash.',
          icon: Icons.bookmark_add,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'add_to_stash';

  @override
  Color getIconColor({
    required BuildContext context,
    required AppModel appModel,
    required DictionaryHeading heading,
  }) {
    if (appModel.isTermInStash(heading.term)) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return super.getIconColor(
        context: context,
        appModel: appModel,
        heading: heading,
      );
    }
  }

  @override
  Future<void> executeAction(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel,
      required CreatorModel creatorModel,
      required DictionaryHeading heading}) async {
    if (!appModel.isTermInStash(heading.term)) {
      appModel.addToStash(terms: [heading.term]);
    } else {
      appModel.removeFromStash(term: heading.term);
    }
  }
}
