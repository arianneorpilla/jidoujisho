import 'package:flutter/widgets.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:yuuna/creator.dart';

/// An entity for enhancements that specificallly generate images.
abstract class ImageEnhancement extends Enhancement {
  /// Initialise this enhancement with the predetermined and hardset values.
  ImageEnhancement({
    required super.uniqueKey,
    required super.label,
    required super.description,
    required super.field,
    required super.icon,
  });

  /// Given a search term, generate a list of images.
  Future<List<NetworkToFileImage>> fetchImages({
    required BuildContext context,
    String? searchTerm,
  });
}
