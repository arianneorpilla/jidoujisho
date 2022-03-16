import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';

/// Media type that encapsulates dictionary search results.
class DictionaryMediaType extends MediaType {
  /// Initialise this media type.
  DictionaryMediaType()
      : super(
          uniqueKey: 'dictionary_media_type',
          icon: Icons.auto_stories,
        );

  @override
  Widget get home => Container();
}
