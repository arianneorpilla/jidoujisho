import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_source_search_bar.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:chisa/util/center_icon_message.dart';

class PlayerHomePage extends MediaHomePage {
  const PlayerHomePage({
    Key? key,
    required MediaType mediaType,
    required this.searchBarController,
  }) : super(
          key: key,
          mediaType: mediaType,
        );

  final FloatingSearchBarController searchBarController;

  @override
  State<StatefulWidget> createState() => PlayerHomePageState();
}

class PlayerHomePageState extends State<PlayerHomePage>
    with AutomaticKeepAliveClientMixin {
  late AppModel appModel;

  @override
  bool get wantKeepAlive => true;

  TextEditingController searchController = TextEditingController(text: "");
  ScrollController? scrollController;

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  PlayerMediaSource getCurrentMediaSource() {
    return appModel.getCurrentMediaTypeSource(widget.mediaType)
        as PlayerMediaSource;
  }

  void refreshCallback() {
    setState(() {});
  }

  MediaSourceSearchBar buildSearchBar() {
    return MediaSourceSearchBar(
      appModel: appModel,
      mediaSource: getCurrentMediaSource(),
      refreshCallback: refreshCallback,
      searchBarController: widget.searchBarController,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    appModel = Provider.of<AppModel>(context);

    if (widget.mediaType.getMediaHistory(appModel).getItems().isEmpty) {
      return Stack(
        children: [
          buildEmptyBody(),
          buildSearchBar(),
        ],
      );
    }

    return Stack(
      children: [
        buildBody(),
        buildSearchBar(),
      ],
    );
  }

  Widget buildBody() {
    MediaHistory history = widget.mediaType.getMediaHistory(appModel);

    List<MediaHistoryItem> mediaHistoryItems =
        history.getItems().reversed.toList();

    scrollController ??= appModel.getScrollController(
      widget.mediaType,
    );

    return RawScrollbar(
      controller: scrollController,
      thumbColor:
          (appModel.getIsDarkMode()) ? Colors.grey[700] : Colors.grey[400],
      child: ListView.builder(
        controller: scrollController,
        addAutomaticKeepAlives: true,
        itemCount: mediaHistoryItems.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return const SizedBox(height: 48);
          }
          MediaHistoryItem item = mediaHistoryItems[index - 1];
          MediaSource source = appModel.getMediaSourceFromName(
              MediaType.player, item.sourceName);
          return source.buildMediaHistoryItem(
            context: context,
            history: history,
            item: item,
            homeRefreshCallback: refreshCallback,
            searchRefreshCallback: () {},
            isHistory: true,
          );
        },
      ),
    );
  }

  Widget buildEmptyBody() {
    return Column(
      children: [
        const SizedBox(height: 48),
        buildEmptyMessage(),
      ],
    );
  }

  Widget buildEmptyMessage() {
    return Expanded(
      child: showCenterIconMessage(
        context: context,
        label: appModel.translate("history_empty"),
        icon: widget.mediaType.icon(),
        jumpingDots: false,
      ),
    );
  }
}
