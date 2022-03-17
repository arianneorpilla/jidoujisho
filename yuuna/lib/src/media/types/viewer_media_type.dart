import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';

/// Media type that encapsulates static visual media, like comics or pictures.
class ViewerMediaType extends MediaType {
  /// Initialise this media type.
  ViewerMediaType._privateConstructor()
      : super(
          uniqueKey: 'viewer_media_type',
          icon: Icons.photo_library,
          outlinedIcon: Icons.photo_library_outlined,
        );

  /// Get the singleton instance of this media type.
  static ViewerMediaType get instance => _instance;

  static final ViewerMediaType _instance =
      ViewerMediaType._privateConstructor();

  @override
  StatelessWidget get home => Container();
}
