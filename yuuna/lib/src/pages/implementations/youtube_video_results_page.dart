import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The page shown to view YouTube search results.
class YoutubeVideoResultsPage extends HistoryPlayerPage {
  /// Create an instance of this page.
  const YoutubeVideoResultsPage({
    required this.title,
    required this.pagingController,
    required this.showAppBar,
    super.key,
  });

  /// Title to show under the page. Can be a search term or a channel ID.
  final String title;

  /// Used fosr infinite scroll pagination.
  final PagingController<int, MediaItem> pagingController;

  /// Whether or not to show an app bar.
  final bool showAppBar;

  @override
  HistoryPlayerPageState<YoutubeVideoResultsPage> createState() =>
      _YoutubeVideoResultsPageState();
}

class _YoutubeVideoResultsPageState
    extends HistoryPlayerPageState<YoutubeVideoResultsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get isHistory => false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: widget.showAppBar ? buildAppBar() : null,
      body: SafeArea(
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return RawScrollbar(
      thumbVisibility: true,
      thickness: 3,
      controller: _scrollController,
      child: buildList(),
    );
  }

  Widget buildList() {
    return PagedListView<int, MediaItem>(
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      scrollController: _scrollController,
      pagingController: widget.pagingController,
      key: UniqueKey(),
      builderDelegate: PagedChildBuilderDelegate<MediaItem>(
        firstPageProgressIndicatorBuilder: (context) {
          return buildLoading();
        },
        newPageProgressIndicatorBuilder: (context) {
          return buildLoading();
        },
        itemBuilder: (context, item, index) {
          return buildMediaItem(item);
        },
      ),
    );
  }

  Widget buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: JidoujishoMarquee(
            text: widget.title,
            style: TextStyle(
              fontSize: textTheme.titleMedium?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      leading: buildBackButton(),
      title: buildTitle(),
      titleSpacing: 8,
    );
  }

  Widget buildBackButton() {
    return JidoujishoIconButton(
      tooltip: t.back,
      icon: Icons.arrow_back,
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  /// Build the right side of the history containing video information.
  @override
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
        ),
        ...extraMetadata(item),
      ],
    );
  }

  @override
  List<Widget> extraActions(MediaItem item) {
    return [
      buildChannelButton(item),
    ];
  }

  /// Allows extra metadata to be shown.
  @override
  List<Widget> extraMetadata(MediaItem item) {
    return [
      ClosedCaptionsIndicator(item: item),
    ];
  }
}
