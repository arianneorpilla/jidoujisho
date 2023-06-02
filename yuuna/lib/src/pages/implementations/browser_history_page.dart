import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_svg_image/cached_network_svg_image.dart';
import 'package:favicon/favicon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spaces/spaces.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/src/media/media_item.dart';
import 'package:yuuna/src/media/media_source.dart';
import 'package:yuuna/src/media/media_type.dart';
import 'package:yuuna/src/media/sources/reader_browser_source.dart';
import 'package:yuuna/src/media/types/reader_media_type.dart';
import 'package:yuuna/utils.dart';

/// Provider for getting the best favicon.
final faviconProvider =
    FutureProvider.family<Favicon?, String>((ref, url) async {
  Favicon? favicon = await FaviconFinder.getBest(url);
  favicon ??= await FaviconFinder.getBest(Uri.parse(url).host);

  return favicon;
});

/// The media page used for unimplemented sources.
class BrowserHistoryPage extends BaseHistoryPage {
  /// Create an instance of this page.
  const BrowserHistoryPage({super.key});

  @override
  BaseHistoryPageState createState() => _BrowserHistoryPageState();
}

class _BrowserHistoryPageState extends BaseHistoryPageState {
  @override
  MediaSource get mediaSource => ReaderBrowserSource.instance;

  @override
  MediaType get mediaType => ReaderMediaType.instance;

  @override
  void initState() {
    ReaderBrowserSource.instance.changeNotifier.addListener(refresh);
    super.initState();
  }

  @override
  void dispose() {
    ReaderBrowserSource.instance.changeNotifier.removeListener(refresh);
    super.dispose();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 60,
        ),
        buildBookmarksList(),
        const Space.normal(),
        Expanded(
          child: buildReadingList(),
        ),
      ],
    );
  }

  @override
  Widget buildPlaceholder() {
    return Center(
      child: JidoujishoPlaceholderMessage(
        icon: Icons.book_sharp,
        message: t.reading_list_empty,
      ),
    );
  }

  Widget buildReadingList() {
    List<MediaItem> items =
        appModel.getMediaSourceHistory(mediaSource: mediaSource);
    if (items.isEmpty) {
      return buildPlaceholder();
    } else {
      return buildHistory(items);
    }
  }

  @override
  Widget buildHistory(List<MediaItem> items) {
    return RawScrollbar(
      thumbVisibility: true,
      thickness: 3,
      controller: mediaType.scrollController,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          childAspectRatio: mediaSource.aspectRatio,
        ),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        controller: mediaType.scrollController,
        itemCount: items.length,
        itemBuilder: (context, index) => buildMediaItem(items[index]),
      ),
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
              aspectRatio: mediaSource.aspectRatio,
              child: FadeInImage(
                key: UniqueKey(),
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
            value: (item.position / item.duration).isNaN ||
                    (item.position / item.duration) == double.infinity ||
                    (item.position == 0 && item.duration == 0)
                ? 0
                : ((item.position / item.duration) > 0.97)
                    ? 1
                    : (item.position / item.duration),
            backgroundColor: Colors.white.withOpacity(0.6),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
            minHeight: 2,
          ),
        ],
      ),
    );
  }

  Widget buildBookmarksList() {
    List<BrowserBookmark> bookmarks = appModel.browserBookmarks;

    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: Spacing.of(context).insets.horizontal.normal,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        separatorBuilder: (context, index) => const Space.semiSmall(),
        scrollDirection: Axis.horizontal,
        itemCount: bookmarks.length + 1,
        itemBuilder: (context, index) {
          if (index == bookmarks.length) {
            return buildAddBookmarkButton();
          } else {
            BrowserBookmark bookmark = bookmarks[index];
            return BookmarkButton(
              bookmark: bookmark,
              onTap: () {
                appModel.openMedia(
                  context: context,
                  ref: ref,
                  mediaSource: mediaSource,
                  item: ReaderBrowserSource.instance.generateMediaItem(
                    bookmark,
                  ),
                );
              },
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => BrowserBookmarkDialogPage(
                    bookmark: bookmark,
                    onUpdate: () {
                      setState(() {});
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget buildAddBookmarkButton() {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => BrowserBookmarkDialogPage(
            onUpdate: () {
              setState(() {});
            },
          ),
        );
      },
      child: Tooltip(
        message: t.add_bookmark,
        child: Container(
          color: theme.unselectedWidgetColor.withOpacity(0.03),
          height: 64,
          width: 64,
          child: Icon(
            Icons.bookmark_add,
            color: theme.unselectedWidgetColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Button for displaying a bookmark.
class BookmarkButton extends ConsumerWidget {
  /// Initialise an instance of this widget.
  const BookmarkButton({
    required this.bookmark,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  /// Browser bookmark to show.
  final BrowserBookmark bookmark;

  /// Tap action.
  final Function()? onTap;

  /// Long press action.
  final Function()? onLongPress;

  /// Fallback widget.
  Widget get fallback {
    return const Icon(Icons.public);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<Favicon?> favicon = ref.watch(faviconProvider(bookmark.url));
    Widget faviconWidget = favicon.when(
      data: (favicon) {
        if (favicon != null) {
          if (favicon.url.endsWith('svg')) {
            return CachedNetworkSVGImage(
              favicon.url,
              errorWidget: fallback,
            );
          } else {
            return CachedNetworkImage(
              imageUrl: favicon.url,
              errorWidget: (_, __, ___) => fallback,
            );
          }
        } else {
          return fallback;
        }
      },
      error: (_, __) {
        return fallback;
      },
      loading: () => const SizedBox.expand(),
    );

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: Spacing.of(context).insets.all.small,
        color: Theme.of(context).unselectedWidgetColor.withOpacity(0.06),
        height: 64,
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: faviconWidget,
            ),
            const Space.semiSmall(),
            SizedBox(
              child: Text(
                bookmark.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
