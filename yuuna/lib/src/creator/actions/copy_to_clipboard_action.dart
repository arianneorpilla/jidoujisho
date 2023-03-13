import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/dictionary.dart';

/// An enhancement that is useful for copying the headword term.
class CopyToClipboardAction extends QuickAction {
  /// Initialise this enhancement with the hardset parameters.
  CopyToClipboardAction()
      : super(
          uniqueKey: key,
          label: 'Copy To Clipboard',
          description:
              'Copy the headword of a dictionary entry to the clipboard.',
          icon: Icons.copy,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'copy_to_clipboard';

  @override
  Future<void> executeAction(
      {required BuildContext context,
      required WidgetRef ref,
      required AppModel appModel,
      required CreatorModel creatorModel,
      required DictionaryHeading heading}) async {
    appModel.copyToClipboard(heading.term);
  }
}
