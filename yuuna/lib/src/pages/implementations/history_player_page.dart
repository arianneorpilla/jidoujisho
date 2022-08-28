import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// A default page for a [PlayerMediaSource]'s tab body content when selected
/// as a source in the main menu.
class HistoryPlayerPage extends BaseHistoryPage {
  /// Create an instance of this tab page.
  const HistoryPlayerPage({
    super.key,
  });

  @override
  BaseHistoryPageState<BaseHistoryPage> createState() =>
      HistoryPlayerPageState();
}

/// A base class for providing all tabs in the main menu. In large part, this
/// was implemented to define shortcuts for common lengthy methods across UI
/// code.
class HistoryPlayerPageState<T extends BaseHistoryPage>
    extends BaseHistoryPageState {
  /// This variable is true when the [buildPlaceholder] should be shown.
  /// For example, if a certain media type does not have any media items to
  /// show in its history.

  /// Each tab in the home page represents a media type.
  @override
  MediaType get mediaType => PlayerMediaType.instance;

  /// Get the active media source for the current media type.
  @override
  MediaSource get mediaSource =>
      appModel.getCurrentSourceForMediaType(mediaType: mediaType);

  @override
  bool get shouldPlaceholderBeShown =>
      appModel.getMediaTypeHistory(mediaType: mediaType).isEmpty;

  @override
  void initState() {
    super.initState();
    mediaType.tabRefreshNotifier.addListener(refresh);
  }

  /// Refresh the page and respond to history changes.
  void refresh() {
    setState(() {});
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
        ListView.builder(
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
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: buildThumbnail(item),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: buildMetadata(item),
          ),
        ],
      ),
    );
  }

  /// Build the thumbnail for the history item.
  Widget buildThumbnail(MediaItem item) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ColoredBox(
          color: Colors.black,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: FadeInImage(
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
        Positioned(
          right: 4,
          bottom: 6,
          child: Container(
            height: 20,
            color: Colors.black.withOpacity(0.8),
            alignment: Alignment.center,
            child: Text(
              JidoujishoTimeFormat.getVideoDurationText(
                  Duration(seconds: item.duration)),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
        Positioned(
          child: Container(
            alignment: Alignment.bottomCenter,
            child: LinearProgressIndicator(
             value: (item.position / item.duration) == double.nan ||
                    (item.position / item.duration) == double.infinity
                ? 0
                : (item.position / item.duration),
              backgroundColor: Colors.white.withOpacity(0.6),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              minHeight: 2,
            ),
          ),
        ),
      ],
    );
  }

  /// Build the right side of the history containing video information.
  Widget buildMetadata(MediaItem item) {
    MediaSource source = item.getMediaSource(appModel: appModel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          source.getDisplayTitleFromMediaItem(item),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        const SizedBox(height: 8),
        Text(
          source.getDisplaySubtitleFromMediaItem(item),
          style: TextStyle(
            color: Theme.of(context).unselectedWidgetColor,
            fontSize: 12,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(
              source.icon,
              color: Theme.of(context).unselectedWidgetColor,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              source.getLocalisedSourceName(appModel),
              style: TextStyle(
                color: Theme.of(context).unselectedWidgetColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ],
        )
      ],
    );
  }
}
