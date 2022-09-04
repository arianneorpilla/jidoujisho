import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';
import 'package:yuuna/dictionary.dart';

/// An enhancement used effectively as a shortcut for exporting a card.
class InstantExportAction extends QuickAction {
  /// Initialise this enhancement with the hardset parameters.
  InstantExportAction()
      : super(
          uniqueKey: key,
          label: 'Instant Export',
          description:
              'Export a card with the selected dictionary entry parameters.',
          icon: Icons.send,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'instant_export';

  @override
  Future<void> executeAction({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryTerm dictionaryTerm,
    required List<DictionaryMetaEntry> metaEntries,
  }) async {
    CreatorModel creatorModel = ref.read(instantExportProvider);

    Map<Field, String> newTextFields = {};
    for (Field field in appModel.activeFields) {
      String? newTextField = field.onCreatorOpenAction(
        context: context,
        ref: ref,
        appModel: appModel,
        creatorModel: creatorModel,
        dictionaryTerm: dictionaryTerm,
        metaEntries: metaEntries,
        creatorJustLaunched: true,
      );

      if (newTextField != null) {
        newTextFields[field] = newTextField;
      }
    }

    creatorModel.copyContext(
      CreatorFieldValues(textValues: newTextFields),
    );

    for (Field field in appModel.activeFields) {
      /// If a media source has a generate images or audio function, then use that
      /// over any set auto enhancement.
      if (appModel.isMediaOpen && appModel.getCurrentMediaItem() != null) {
        MediaSource mediaSource =
            appModel.getCurrentMediaItem()!.getMediaSource(appModel: appModel);
        if (field is ImageField && mediaSource.overridesAutoImage) {
          await field.setImages(
            appModel: appModel,
            creatorModel: creatorModel,
            searchTerm: '',
            newAutoCannotOverride: true,
            cause: EnhancementTriggerCause.manual,
            generateImages: () async {
              return mediaSource.generateImages(
                appModel: appModel,
                subtitles: null,
                item: appModel.getCurrentMediaItem()!,
                options: appModel.currentSubtitleOptions!.value,
              );
            },
          );
          continue;
        }
        if (field is AudioField && mediaSource.overridesAutoAudio) {
          await field.setAudio(
            appModel: appModel,
            creatorModel: creatorModel,
            searchTerm: '',
            newAutoCannotOverride: true,
            cause: EnhancementTriggerCause.manual,
            generateAudio: () async {
              return mediaSource.generateAudio(
                appModel: appModel,
                subtitles: null,
                item: appModel.getCurrentMediaItem()!,
                options: appModel.currentSubtitleOptions!.value,
              );
            },
          );
          continue;
        }
      }

      Enhancement? enhancement = appModel.lastSelectedMapping
          .getAutoFieldEnhancement(appModel: appModel, field: field);

      if (enhancement != null) {
        await enhancement.enhanceCreatorParams(
          context: context,
          ref: ref,
          appModel: appModel,
          creatorModel: creatorModel,
          cause: EnhancementTriggerCause.auto,
        );
      }
    }

    await appModel.addNote(
      creatorFieldValues: creatorModel.getExportDetails(ref),
      mapping: appModel.lastSelectedMapping,
      deck: appModel.lastSelectedDeckName,
    );
    creatorModel.clearAll();
  }
}
