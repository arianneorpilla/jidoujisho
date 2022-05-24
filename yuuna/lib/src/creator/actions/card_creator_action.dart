import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/pages.dart';

/// An enhancement used effectively as a shortcut for opening the Card Creator.
class CardCreatorAction extends QuickAction {
  /// Initialise this enhancement with the hardset parameters.
  CardCreatorAction()
      : super(
          uniqueKey: key,
          label: 'Card Creator',
          description:
              'Create a card with the selected dictionary entry parameters and'
              ' edit before export.',
          icon: Icons.note_add,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'card_creator';

  @override
  Future<void> executeAction({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required String term,
    required String reading,
    required List<DictionaryEntry> entries,
  }) async {
    String meaning = MeaningField.flattenMeanings(entries);

    if (appModel.isCreatorOpen) {
      creatorModel.copyContext(
        CreatorFieldValues(
          textValues: {
            TermField.instance: term,
            ReadingField.instance: reading,
            MeaningField.instance: meaning,
          },
        ),
      );
      Navigator.of(context).popUntil(
        (route) => route.settings.name == (CreatorPage).toString(),
      );
    } else {
      appModel.openCreator(
        ref: ref,
        killOnPop: false,
        creatorFieldValues: CreatorFieldValues(
          textValues: {
            TermField.instance: term,
            ReadingField.instance: reading,
            MeaningField.instance: meaning,
          },
        ),
      );
    }
  }
}
