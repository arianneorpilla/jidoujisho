import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class PaginatedPlayerPage extends StatefulWidget {
  const PaginatedPlayerPage({
    required this.title,
    required this.source,
    required this.pagingController,
    Key? key,
    this.actions = const [],
  }) : super(key: key);

  final String title;
  final List<Widget> actions;
  final PlayerMediaSource source;
  final PagingController<int, MediaHistoryItem> pagingController;

  @override
  State<StatefulWidget> createState() => PaginatedPlayerPageState();
}

class PaginatedPlayerPageState extends State<PaginatedPlayerPage> {
  late AppModel appModel;
  late PagingController pagingController;

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: widget.actions,
      ),
      body: RawScrollbar(
        controller: scrollController,
        thumbColor:
            (appModel.getIsDarkMode()) ? Colors.grey[700] : Colors.grey[400],
        child: PagedListView<int, MediaHistoryItem>(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          scrollController: scrollController,
          pagingController: widget.pagingController,
          key: UniqueKey(),
          builderDelegate: PagedChildBuilderDelegate<MediaHistoryItem>(
              itemBuilder: (context, item, index) {
            return widget.source.buildMediaHistoryItem(
              context: context,
              history: widget.source.mediaType.getMediaHistory(appModel),
              item: item,
              homeRefreshCallback: () {
                setState(() {});
              },
              searchRefreshCallback: () {},
            );
          }),
        ),
      ),
    );
  }
}
