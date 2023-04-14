import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/utils.dart';

/// An enhancement used effectively as a shortcut for performing a dictionary
/// search.
class SearchDictionaryEnhancement extends Enhancement {
  /// Initialise this enhancement with the hardset parameters.
  SearchDictionaryEnhancement()
      : super(
          uniqueKey: key,
          label: 'Search Dictionary',
          description: 'Search the dictionary with the content of a field.',
          icon: Icons.search,
          field: TermField.instance,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'search_dictionary';

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    String searchTerm = creatorModel.getFieldController(field).text.trim();

    if (searchTerm.isEmpty) {
      Field fallbackField = SentenceField.instance;
      searchTerm = creatorModel.getFieldController(fallbackField).text.trim();
      if (searchTerm.isEmpty) {
        Fluttertoast.showToast(
          msg: t.no_text_to_search,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      } else {
        Fluttertoast.showToast(
          msg: t.field_fallback_used(
            field: field.getLocalisedLabel(appModel),
            secondField: fallbackField.getLocalisedLabel(appModel),
          ),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }

    appModel.openRecursiveDictionarySearch(
      searchTerm: searchTerm,
      killOnPop: false,
    );
  }
}
