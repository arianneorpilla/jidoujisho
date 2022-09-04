import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

/// A default page for a [ReaderMediaSource]'s tab body content when selected
/// as a source in the main menu.
class HistoryReaderPage extends BaseHistoryPage {
  /// Create an instance of this tab page.
  const HistoryReaderPage({
    super.key,
  });

  @override
  BaseHistoryPageState<BaseHistoryPage> createState() =>
      HistoryReaderPageState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
class HistoryReaderPageState<T extends BaseHistoryPage>
    extends BaseHistoryPageState {
  /// This variable is true when the [buildPlaceholder] should be shown.
  /// For example, if a certain media type does not have any media items to
  /// show in its history.

  /// Each tab in the home page represents a media type.
  @override
  MediaType get mediaType => ReaderMediaType.instance;

  /// Get the active media source for the current media type.
  @override
  MediaSource get mediaSource =>
      appModel.getCurrentSourceForMediaType(mediaType: mediaType);

  @override
  bool get shouldPlaceholderBeShown => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<MediaItem> items = appModel.getMediaTypeHistory(mediaType: mediaType);

    if (shouldPlaceholderBeShown) {
      return buildPlaceholder();
    } else {
      return buildHistory(items);
    }
  }

  /// This is shown as the body when [shouldPlaceholderBeShown] is false.
  @override
  Widget buildHistory(List<MediaItem> items) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      controller: mediaType.scrollController,
      children: [
        const SizedBox(height: 48),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150,
            childAspectRatio: 176 / 250,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) => buildMediaItem(items[index]),
        ),
      ],
    );
  }

  /// Build the widget visually representing the [MediaItem]'s history tile.
  @override
  Widget buildMediaItemContent(MediaItem item) {
    return Container(
      padding: Spacing.of(context).insets.all.normal,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          ColoredBox(
            color: Colors.grey.shade800.withOpacity(0.3),
            child: AspectRatio(
              aspectRatio: 176 / 250,
              child: FadeInImage(
                imageErrorBuilder: (_, __, ___) => const SizedBox.shrink(),
                placeholder: MemoryImage(kTransparentImage),
                image: mediaSource.getDisplayThumbnailFromMediaItem(
                  appModel: appModel,
                  item: item,
                ),
                alignment: Alignment.topCenter,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          LayoutBuilder(builder: (context, constraints) {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(2, 2, 2, 4),
              height: constraints.maxHeight * 0.25,
              width: double.maxFinite,
              color: Colors.black.withOpacity(0.6),
              child: Text(
                mediaSource.getDisplayTitleFromMediaItem(item),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
                softWrap: true,
                style: textTheme.bodySmall!.copyWith(
                    color: Colors.white,
                    fontSize: textTheme.bodySmall!.fontSize! * 0.9),
              ),
            );
          }),
          LinearProgressIndicator(
            value: (item.position / item.duration) == double.nan ||
                    (item.position / item.duration) == double.infinity ||
                    (item.position == 0 && item.duration == 0)
                ? 0
                : (item.position / item.duration),
            backgroundColor: Colors.white.withOpacity(0.6),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
            minHeight: 2,
          ),
        ],
      ),
    );
  }
}
