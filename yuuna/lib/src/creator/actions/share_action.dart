import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/dictionary.dart';

/// An enhancement that calls the native share API for sharing word details.
class ShareAction extends QuickAction {
  /// Initialise this enhancement with the hardset parameters.
  ShareAction()
      : super(
          uniqueKey: key,
          label: 'Share',
          description: 'Share the details of a dictionary term.',
          icon: Icons.share,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'share';

  @override
  Future<void> executeAction({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required String? dictionaryName,
  }) async {
    StringBuffer buffer = StringBuffer();
    buffer.write(heading.term);
    if (heading.reading.isNotEmpty) {
      buffer.write(' (${heading.reading})');
    }
    buffer.write('\n\n');
    buffer.write(
      MeaningField.flattenMeanings(
          entries: heading.entries.toList(),
          prependDictionaryNames:
              appModel.lastSelectedMapping.prependDictionaryNames ?? false),
    );

    String shareText = buffer.toString();

    Share.share(shareText);
  }
}
