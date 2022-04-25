import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';

/// A global [Provider] for the card creator.
final creatorProvider = ChangeNotifierProvider<CreatorModel>((ref) {
  return CreatorModel();
});

/// A global [Provider] for state management of getting images for the
/// card creator.
final creatorImageProvider =
    FutureProvider.family<NetworkToFileImage?, MediaItem?>((ref, seed) {
  AppModel appModel = ref.read(appProvider);

  if (seed == null) {
    return null;
  }

  if (seed.fromEnhancement) {
    Field field = Field.values.byName(seed.identifierType);
    Enhancement enhancement =
        appModel.enhancements[field]![seed.identifierKey]!;
    Future<NetworkToFileImage?> image =
        (enhancement as ImageGeneratorMixin).getImageFromSeed(seed);

    return image;
  } else if (seed.fromMedia) {
    MediaType type = appModel.mediaTypes[seed.identifierType]!;
    MediaSource source = appModel.mediaSources[type]![seed.identifierKey]!;
    Future<NetworkToFileImage?> image =
        (source as ImageGeneratorMixin).getImageFromSeed(seed);

    return image;
  } else {
    throw Exception('Invalid media item category found');
  }
});

/// A global [Provider] for state management of getting audio for the
/// card creator.
final creatorAudioProvider =
    FutureProvider.family<File?, MediaItem?>((ref, seed) {
  AppModel appModel = ref.read(appProvider);

  if (seed == null) {
    return null;
  }

  if (seed.fromEnhancement) {
    Field field = Field.values.byName(seed.identifierType);
    Enhancement enhancement =
        appModel.enhancements[field]![seed.identifierKey]!;
    Future<File?> audio =
        (enhancement as AudioGeneratorMixin).getAudioFileFromSeed(seed);

    return audio;
  } else if (seed.fromMedia) {
    MediaType type = appModel.mediaTypes[seed.identifierType]!;
    MediaSource source = appModel.mediaSources[type]![seed.identifierKey]!;
    Future<File?> audio =
        (source as AudioGeneratorMixin).getAudioFileFromSeed(seed);

    return audio;
  } else {
    throw Exception('Invalid media item category found');
  }
});

/// A scoped model for parameters that affect the card creator. RiverPod is
/// used for global state management across multiple layers, and is useful for
/// showing the creator and sharing code across the entire application.
class CreatorModel with ChangeNotifier {
  /// A map of [TextEditingController] for every creator [Field].
  final Map<Field, TextEditingController> _controllersByField =
      Map.unmodifiable(
    Map.fromIterable(
      Field.values.map(
        (field) => TextEditingController(),
      ),
    ),
  );

  /// The current context at the top of the creator being highlighted for export.
  /// The seed of the current image at the top of the creator being highlighted
  /// for export.
  MediaItem? get currentImageSeed => _currentImageSeed;
  MediaItem? _currentImageSeed;

  /// Set the current image seed.
  set currentImageSeed(MediaItem? seed) {
    _currentImageSeed = seed;
    notifyListeners();
  }

  /// Indicates the media details from the last [CreatorContext]. Used to
  /// allow return to context details to be included in card export or viewed
  /// while editing.
  MediaItem? get currentContext => _currentContext;
  MediaItem? _currentContext;

  /// Set the current context item.
  set currentContext(MediaItem? context) {
    _currentContext = context;
    notifyListeners();
  }

  /// Seeds for images that may be selected to easily replace the
  /// [currentImageSeed] that is currently highlighted for export.
  List<MediaItem>? get currentImageSuggestionsSeeds =>
      _currentImageSuggestionsSeeds;
  List<MediaItem>? _currentImageSuggestionsSeeds;

  /// Set the current image suggestions.
  set currentImageSuggestionsSeeds(List<MediaItem>? seeds) {
    _currentImageSuggestionsSeeds = seeds;
    notifyListeners();
  }

  /// The current audio at the top of the creator being highlighted for export.
  MediaItem? get currentAudioSeed => _currentAudioSeed;
  MediaItem? _currentAudioSeed;

  /// Set the current audio seed.
  set currentAudioSeed(MediaItem? seed) {
    _currentAudioSeed = seed;
    notifyListeners();
  }

  /// Clear all fields and current context.
  void clearAll(Field field) {
    Field.values.forEach(clearField);
    currentContext = null;
  }

  /// Get the [TextEditingController] for a particular field.
  TextEditingController getFieldController(Field field) {
    return _controllersByField[field]!;
  }

  /// Clear a controller for a particular [Field].
  void clearField(Field field) {
    switch (field) {
      case Field.audio:
        currentAudioSeed = null;
        break;
      case Field.image:
        currentImageSeed = null;
        currentImageSuggestionsSeeds = null;
        break;
      case Field.sentence:
      case Field.word:
      case Field.reading:
      case Field.meaning:
      case Field.extra:
      case Field.context:
        break;
    }

    getFieldController(field).clear();
  }

  /// Clone the [CreatorContext]'s contents into the model.
  void copyContext(CreatorContext creatorContext) {
    currentContext = creatorContext.context;

    for (Field field in Field.values) {
      TextEditingController controller = getFieldController(field);

      switch (field) {
        case Field.sentence:
          controller.text = creatorContext.sentence ?? controller.text;
          break;
        case Field.word:
          controller.text = creatorContext.word ?? controller.text;
          break;
        case Field.reading:
          controller.text = creatorContext.reading ?? controller.text;
          break;
        case Field.meaning:
          controller.text = creatorContext.meaning ?? controller.text;
          break;
        case Field.extra:
          controller.text = creatorContext.extra ?? controller.text;
          break;

        case Field.image:
          controller.text = creatorContext.imageSearch ?? controller.text;
          currentImageSeed = creatorContext.imageSeed;
          currentImageSuggestionsSeeds = creatorContext.imageSuggestions;
          break;
        case Field.audio:
          controller.text = creatorContext.audioSearch ?? controller.text;
          currentAudioSeed = creatorContext.audioSeed;
          break;
        case Field.context:
          if (creatorContext.context != null) {
            controller.text = jsonEncode(creatorContext.context?.toJson());
          }
      }
    }
  }

  /// Get a snapshot of the relevant parameters of the model for card export.
  ExportDetails getExportDetails(WidgetRef ref) {
    return ExportDetails(
      sentence: getFieldController(Field.sentence).text,
      word: getFieldController(Field.extra).text,
      reading: getFieldController(Field.reading).text,
      meaning: getFieldController(Field.meaning).text,
      extra: getFieldController(Field.extra).text,
      context: getFieldController(Field.context).text,
      image: ref.read(creatorImageProvider(currentImageSeed)).value?.file,
      audio: ref.read(creatorAudioProvider(currentAudioSeed)).value,
    );
  }
}
