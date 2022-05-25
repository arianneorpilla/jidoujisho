import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/models.dart';

/// A global [Provider] for the card creator.
final creatorProvider = ChangeNotifierProvider<CreatorModel>((ref) {
  CreatorModel creatorModel = CreatorModel();
  creatorModel.initialise();

  return creatorModel;
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
    Field field = fieldsByKey[seed.identifierType]!;
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
    Field field = fieldsByKey[seed.identifierType]!;
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
  /// A map of [TextEditingController] for every creator field.
  Map<Field, TextEditingController> get controllersByField =>
      _controllersByField;
  late final Map<Field, TextEditingController> _controllersByField;

  /// Prepare the [CreatorModel]'s final variables for use.
  void initialise() {
    _controllersByField = Map.unmodifiable(
      {for (Field field in globalFields) field: TextEditingController()},
    );
  }

  /// Refresh state for the Card Creator.
  void refresh() {
    notifyListeners();
  }

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
  void clearAll() {
    for (Field field in fieldsByKey.values) {
      clearField(field, notify: false);
    }

    notifyListeners();
  }

  /// Get the [TextEditingController] for a particular field.
  TextEditingController getFieldController(Field field) {
    return _controllersByField[field]!;
  }

  /// Clear a controller for a particular field.
  void clearField(Field field, {bool notify = true}) {
    if (field is ImageExportField) {
      field.clearFieldState(creatorModel: this);
    } else if (field is AudioExportField) {
      field.clearFieldState(creatorModel: this);
    }

    /// Need to clear the audio/image seed when that's implemented as well.
    getFieldController(field).clear();
    if (notify) {
      notifyListeners();
    }
  }

  /// Clone the [CreatorFieldValues]'s contents into the model.
  void copyContext(CreatorFieldValues creatorFieldValues) {
    /// Also need to update the generated media using the seeds.

    for (MapEntry<Field, String> entry
        in creatorFieldValues.textValues.entries) {
      TextEditingController controller = getFieldController(entry.key);
      controller.text = entry.value;
    }
  }

  /// Get a snapshot of the relevant parameters of the model for card export.
  CreatorFieldValues getExportDetails(WidgetRef ref) {
    return CreatorFieldValues(
      textValues: controllersByField.map(
        (field, controller) => MapEntry(field, controller.text),
      ),
    );
  }
}
