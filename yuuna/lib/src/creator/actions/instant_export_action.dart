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
          showInSingleDictionary: true,
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
    required DictionaryHeading heading,
    required String? dictionaryName,
  }) async {
    CreatorModel creatorModel = ref.read(instantExportProvider);

    Map<Field, String> newTextFields = {};
    for (Field field in appModel.activeFields) {
      String? newTextField = field.onCreatorOpenAction(
        context: context,
        ref: ref,
        appModel: appModel,
        creatorModel: creatorModel,
        heading: heading,
        creatorJustLaunched: true,
        dictionaryName: dictionaryName,
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
                item: appModel.getCurrentMediaItem()!,
                options: appModel.currentSubtitleOptions!.value,
                data: mediaSource.currentExtraData,
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
      onSuccess: () {
        creatorModel.clearAll(
          overrideLocks: true,
          savedTags: appModel.savedTags,
        );
      },
    );
  }

  @override
  Future<Color?> getIconColor({
    required AppModel appModel,
    required DictionaryHeading heading,
  }) async {
    bool hasDuplicates = await appModel.checkForDuplicates(heading.term);
    if (hasDuplicates) {
      return Colors.red;
    } else {
      return null;
    }
  }
}
