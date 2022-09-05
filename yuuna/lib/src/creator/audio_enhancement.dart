import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';

/// An entity for enhancements that specificallly generate audio.
abstract class AudioEnhancement extends Enhancement {
  /// Initialise this enhancement with the predetermined and hardset values.
  AudioEnhancement({
    required super.uniqueKey,
    required super.label,
    required super.description,
    required super.field,
    required super.icon,
  });

  /// Given a term and a reading, fetch an audio file that is playable for
  /// the play audio action.
  Future<File?> fetchAudio({
    required AppModel appModel,
    required BuildContext context,
    required String term,
    required String reading,
  });
}
