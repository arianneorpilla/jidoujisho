import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The page shown to view video search results.
class VideoResultsPage extends HistoryPlayerPage {
  /// Create an instance of this page.
  const VideoResultsPage({
    required this.title,
    required this.pagingController,
    required this.showAppBar,
    super.key,
  });

  /// Title to show under the page. Can be a search term or a channel ID.
  final String title;

  /// Used for infinite scroll pagination.
  final PagingController<int, MediaItem> pagingController;

  /// Whether or not to show an app bar.
  final bool showAppBar;

  @override
  HistoryPlayerPageState<VideoResultsPage> createState() =>
      _VideoResultsPageState();
}

class _VideoResultsPageState extends HistoryPlayerPageState<VideoResultsPage> {
  String get backLabel => appModel.translate('back');
  String get dictionariesLabel => appModel.translate('dictionaries');
  String get searchEllipsisLabel => appModel.translate('search_ellipsis');
  String get noDictionariesLabel =>
      appModel.translate('dictionaries_menu_empty');
  String get noSearchResultsLabel => appModel.translate('no_search_results');
  String get enterSearchTermLabel => appModel.translate('enter_search_term');
  String get clearLabel => appModel.translate('clear');

  Map<String, Dictionary>? dictionaryMap;
  Map<int, List<DictionaryMetaEntry>> metaEntriesCache = {};
  Map<int, Map<String, ExpandableController>> expandedControllers = {};
  Map<int, Map<String, bool>> dictionaryHiddens = {};

  final ScrollController _scrollController = ScrollController();

  @override
  bool get isHistory => false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: widget.showAppBar ? buildAppBar() : null,
      body: buildBody(),
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
      tooltip: backLabel,
      icon: Icons.arrow_back,
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
