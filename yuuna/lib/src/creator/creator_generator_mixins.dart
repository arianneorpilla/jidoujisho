import 'dart:io';

import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:yuuna/media.dart';

/// Used for entities that can generate a single image from a [MediaItem] seed.
mixin ImageGeneratorMixin {
  /// From the parameters of [seed], produce an image file that will be usable
  /// in the card creator.
  Future<NetworkToFileImage?> getImageFromSeed(MediaItem seed);
}

/// Used for entities that can generate a single audio file from a [MediaItem]
/// seed.
mixin AudioGeneratorMixin {
  /// From the parameters of [seed], produce an audio file that will be usable
  /// in the card creator.
  Future<File?> getAudioFileFromSeed(MediaItem seed);
}
