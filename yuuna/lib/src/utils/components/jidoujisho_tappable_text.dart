import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/utils.dart';

/// Text that can be reselected and resizes to the text selection to the best
/// dictionary match.
class JidoujishoTappableText extends ConsumerStatefulWidget {
  /// Initialise this widget.
  const JidoujishoTappableText({
    required this.text,
    this.style,
    this.selectionControls,
    super.key,
  });

  /// Text to display.
  final String text;

  /// Text style.
  final TextStyle? style;

  /// Context menu options.
  final JidoujishoTextSelectionControls? selectionControls;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _JidoujishoTappableTextState();
}

class _JidoujishoTappableTextState
    extends ConsumerState<JidoujishoTappableText> {
  final JidoujishoSelectableTextController _selectableTextController =
      JidoujishoSelectableTextController();

  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    AppModel appModel = ref.watch(appProvider);

    return JidoujishoSelectableText(
      widget.text,
      style: widget.style,
      controller: _selectableTextController,
      selectionControls: widget.selectionControls,
      onSelectionChanged: (selection, cause) async {
        if (appModel.targetLanguage.isSpaceDelimited) {
          return;
        }

        if (!selection.isCollapsed &&
            cause == SelectionChangedCause.tap &&
            !_isSearching) {
          _isSearching = true;
          try {
            String searchTerm = widget.text.substring(selection.baseOffset);

            int whitespaceOffset =
                searchTerm.length - searchTerm.trimLeft().length;
            int offsetIndex = appModel.targetLanguage.getStartingIndex(
                  text: widget.text,
                  index: selection.baseOffset,
                ) +
                whitespaceOffset;
            int length = appModel.targetLanguage
                .textToWords(searchTerm)
                .firstWhere((e) => e.trim().isNotEmpty)
                .length;

            _selectableTextController.setSelection(
              offsetIndex,
              offsetIndex + length,
            );

            DictionarySearchResult result = await appModel.searchDictionary(
              searchTerm: searchTerm,
              searchWithWildcards: false,
            );

            length = appModel.targetLanguage.isSpaceDelimited
                ? appModel.targetLanguage
                    .textToWords(searchTerm)
                    .firstWhere((e) => e.trim().isNotEmpty)
                    .length
                : max(1, result.bestLength);

            _selectableTextController.setSelection(
                offsetIndex, offsetIndex + length);
          } finally {
            _isSearching = false;
          }
        }
      },
    );
  }
}
