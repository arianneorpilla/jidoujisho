import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_source_search_bar.dart';
import 'package:chisa/media/media_sources/reader_media_source.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:chisa/util/center_icon_message.dart';

class ReaderHomePage extends MediaHomePage {
  const ReaderHomePage({
    required MediaType mediaType,
    required this.searchBarController,
    Key? key,
  }) : super(
          key: key,
          mediaType: mediaType,
        );

  final FloatingSearchBarController searchBarController;

  @override
  State<StatefulWidget> createState() => ReaderHomePageState();
}

class ReaderHomePageState extends State<ReaderHomePage>
    with AutomaticKeepAliveClientMixin {
  late AppModel appModel;

  @override
  bool get wantKeepAlive => true;

  TextEditingController searchController = TextEditingController(text: '');
  ScrollController? scrollController;

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  ReaderMediaSource getCurrentMediaSource() {
    return appModel.getCurrentMediaTypeSource(widget.mediaType)
        as ReaderMediaSource;
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

    if (!appModel.hasInitialized) {
      return Container();
    }

    return ValueListenableBuilder(
        valueListenable: appModel.readerUpdateFlipflop,
        builder: (_, __, ___) {
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
        });
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
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        controller: scrollController,
        addAutomaticKeepAlives: true,
        itemCount: 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const SizedBox(height: 48);
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 176 / 250,
            ),
            shrinkWrap: true,
            controller: scrollController,
            addAutomaticKeepAlives: true,
            itemCount: mediaHistoryItems.length,
            itemBuilder: (context, index) {
              MediaHistoryItem item = mediaHistoryItems[index];
              MediaSource source = appModel.getMediaSourceFromName(
                  MediaType.reader, item.sourceName);
              return source.buildMediaHistoryItem(
                context: context,
                history: history,
                item: item,
                homeRefreshCallback: refreshCallback,
                searchRefreshCallback: () {},
                isHistory: true,
              );
            },
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
        label: appModel.translate('history_empty'),
        icon: widget.mediaType.icon(),
        jumpingDots: false,
      ),
    );
  }
}
