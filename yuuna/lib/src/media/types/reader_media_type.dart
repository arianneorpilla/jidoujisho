import 'package:flutter/material.dart';
import 'package:yuuna/media.dart';

/// Media type that encapsulates text-based media, like books or articles.
class ReaderMediaType extends MediaType {
  /// Initialise this media type.
  ReaderMediaType()
      : super(
          uniqueKey: 'reader_media_type',
          icon: Icons.library_books,
        );

  @override
  Widget get home => Container();
}
