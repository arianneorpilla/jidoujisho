part of '../core_data.dart';

/// An image.
@immutable
class ImageMetadata {
  /// The image alternative text.
  final String? alt;

  /// The image sources.
  final Iterable<ImageSource> sources;

  /// The image title.
  final String? title;

  /// Creates an image.
  ImageMetadata({this.alt, required this.sources, this.title});
}

/// An image source.
@immutable
class ImageSource {
  /// The image height.
  final double? height;

  /// The image URL.
  final String url;

  /// The image width.
  final double? width;

  /// Creates a source.
  ImageSource(this.url, {this.height, this.width});
}
