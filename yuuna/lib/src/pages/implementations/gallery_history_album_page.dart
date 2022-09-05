import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:yuuna/utils.dart';

/// The media page used for unimplemented sources.
class GalleryHistoryAlbumPage extends BasePage {
  /// Create an instance of this page.
  const GalleryHistoryAlbumPage({
    super.key,
  });

  @override
  BasePageState createState() => _GalleryHistoryAlbumPageState();
}

class _GalleryHistoryAlbumPageState
    extends BasePageState<GalleryHistoryAlbumPage> {
  String get unimplementedSource => appModel.translate('unimplemented_source');
  String get noAlbumsFoundLabel => appModel.translate('no_albums_found');

  ViewerCameraSource get source => ViewerCameraSource.instance;

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<Album>> albums = ref.watch(albumsProvider);

    return albums.when(
      loading: buildLoading,
      error: (error, stack) => buildError(
        error: error,
        stack: stack,
        refresh: () {
          ref.refresh(albumsProvider);
        },
      ),
      data: buildData,
    );
  }

  Widget buildPlaceholder() {
    return JidoujishoPlaceholderMessage(
      icon: Icons.photo,
      message: noAlbumsFoundLabel,
    );
  }

  Widget buildData(List<Album> albums) {
    if (albums.isEmpty) {
      return buildPlaceholder();
    }

    Album currentAlbum = albums
            .firstWhereOrNull((album) => source.albumIdentifier == album.id) ??
        albums.first;
    return GalleryHistoryPage(album: currentAlbum);
  }
}
