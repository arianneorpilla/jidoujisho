import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';

/// Media type that encapsulates dictionary search results.
class DictionaryMediaType extends MediaType {
  /// Initialise this media type.
  DictionaryMediaType._privateConstructor()
      : super(
          uniqueKey: 'dictionary',
          icon: Icons.auto_stories,
          outlinedIcon: Icons.auto_stories_outlined,
        );

  /// Get the singleton instance of this media type.
  static DictionaryMediaType get instance => _instance;

  static final DictionaryMediaType _instance =
      DictionaryMediaType._privateConstructor();

  @override
  StatelessWidget get home => Container();
}
