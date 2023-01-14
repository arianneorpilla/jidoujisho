import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// Media type that encapsulates dictionary search results.
class DictionaryMediaType extends MediaType {
  /// Initialise this media type.
  DictionaryMediaType._privateConstructor()
      : super(
          uniqueKey: 'dictionary_media_type',
          icon: Icons.auto_stories_rounded,
          outlinedIcon: Icons.auto_stories_outlined,
        );

  /// Get the singleton instance of this media type.
  static DictionaryMediaType get instance => _instance;

  static final DictionaryMediaType _instance =
      DictionaryMediaType._privateConstructor();

  @override
  Widget get home => const HomeDictionaryPage();
}
