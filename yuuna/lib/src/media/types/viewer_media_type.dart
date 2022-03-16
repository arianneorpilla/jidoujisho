import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';

/// Media type that encapsulates static visual media, like comics or pictures.
class ViewerMediaType extends MediaType {
  /// Initialise this media type.
  ViewerMediaType()
      : super(
          uniqueKey: 'viewer_media_type',
          icon: Icons.photo_library,
        );

  @override
  Widget get home => Container();
}
