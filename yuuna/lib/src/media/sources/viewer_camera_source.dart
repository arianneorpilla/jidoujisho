import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// A media source that allows the user to take images or pick media from their
/// library and use optical character recognition features.
class ViewerCameraSource extends ViewerMediaSource {
  /// Define this media source.
  ViewerCameraSource._privateConstructor()
      : super(
          uniqueKey: 'viewer_camera',
          sourceName: 'Camera',
          description:
              'View images taken with the camera or picked from media.',
          icon: Icons.camera,
          implementsSearch: false,
          implementsHistory: false,
        );

  /// Get the singleton instance of this media type.
  static ViewerCameraSource get instance => _instance;

  static final ViewerCameraSource _instance =
      ViewerCameraSource._privateConstructor();

  @override
  BaseSourcePage buildLaunchPage({MediaItem? item}) {
    throw UnimplementedError();
  }
}
