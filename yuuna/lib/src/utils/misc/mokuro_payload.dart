import 'dart:math';
import 'dart:ui';

/// Parameters that define a series of images and metadata about each image.
class MokuroPayload {
  /// Initialise this object.
  const MokuroPayload({
    required this.images,
  });

  /// All images in sequential order.
  final List<MokuroImage> images;

  @override
  String toString() {
    return '$runtimeType(images: '
        '[${images.map((e) => e.toString()).join(', ')}])';
  }
}

/// Contains all information needed to render an image, including any text
/// coordinate information and the display image itself.
class MokuroImage {
  /// Initialise this object.
  const MokuroImage({
    required this.url,
    required this.size,
    required this.blocks,
  });

  /// The image file pertaining to this image.
  final String url;

  /// Dimensions of the image.
  final Size size;

  /// The blocks of text for this image.
  final List<MokuroBlock> blocks;

  @override
  String toString() {
    return '$runtimeType(url: $url, size: $size, blocks: '
        '[${blocks.map((e) => e.toString()).join(', ')}])';
  }
}

/// Coordinate information for a single group of text that can have multiple
/// lines.
class MokuroBlock {
  /// Initialise this object.
  const MokuroBlock({
    required this.rectangle,
    required this.isVertical,
    required this.fontSize,
    required this.zIndex,
    required this.lines,
  });

  /// Coordinates for this block.
  final Rect rectangle;

  /// Whether or not the text for this block should be rendered as vertical
  /// text.
  final bool isVertical;

  /// The font size that this block should be rendered with.
  final double fontSize;

  /// The z-index of this block, to allow prioritising which block should
  /// come first in a stack.
  final int zIndex;

  /// The individual lines to be rendered.
  final List<String> lines;

  @override
  String toString() {
    return '$runtimeType(rectangle: $rectangle, isVertical: $isVertical, '
        'fontSize: $fontSize, lines: '
        '[${lines.join(', ')}])';
  }
}
