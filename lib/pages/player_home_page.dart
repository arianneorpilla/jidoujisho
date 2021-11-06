import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:chisa/media/media_type.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/media_home_page.dart';
import 'package:chisa/util/busy_icon_button.dart';
import 'package:chisa/util/center_icon_message.dart';
import 'package:transparent_image/transparent_image.dart';

class PlayerHomePage extends MediaHomePage {
  const PlayerHomePage({
    Key? key,
    required MediaType mediaType,
  }) : super(
          key: key,
          mediaType: mediaType,
        );

  @override
  State<StatefulWidget> createState() => PlayerHomePageState();
}

class PlayerHomePageState extends State<PlayerHomePage> {
  late AppModel appModel;

  TextEditingController wordController = TextEditingController(text: "");

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  PlayerMediaSource getCurrentMediaSource() {
    return appModel.getCurrentMediaTypeSource(widget.mediaType)
        as PlayerMediaSource;
  }

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    if (!appModel.hasInitialized) {
      return Container();
    }

    if (appModel.getMediaHistory(widget.mediaType).getItems().isEmpty) {
      return buildEmptyBody();
    } else {
      return buildBody();
    }
  }

  Widget buildBody() {
    MediaHistory history = appModel.getMediaHistory(widget.mediaType);
    List<MediaHistoryItem> mediaHistoryItems =
        history.getItems().reversed.toList();

    ScrollController scrollController =
        ScrollController(initialScrollOffset: appModel.scrollOffset);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      scrollController.addListener(() {
        appModel.setScrollOffset = scrollController.offset;
      });
      scrollController.position.isScrollingNotifier.addListener(() {
        appModel.setScrollOffset = scrollController.offset;
      });
    });

    // appModel.getMediaHistory(widget.mediaType).setItems([]);

    return Scaffold(
      body: RawScrollbar(
        controller: scrollController,
        thumbColor:
            (appModel.getIsDarkMode()) ? Colors.grey[700] : Colors.grey[400],
        child: ListView.builder(
          controller: scrollController,
          addAutomaticKeepAlives: true,
          key: UniqueKey(),
          itemCount: mediaHistoryItems.length + 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return buildSearchField();
            } else if (index == 1) {
              return getCurrentMediaSource().getButton(context) ??
                  const SizedBox.shrink();
            }

            MediaHistoryItem item = mediaHistoryItems[index - 2];
            return buildMediaHistoryItem(history, item);
          },
        ),
      ),
    );
  }

  Widget buildMediaHistoryItem(MediaHistory history, MediaHistoryItem item) {
    PlayerMediaSource playerMediaSource = appModel.getMediaSourceFromName(
      widget.mediaType,
      item.source,
    ) as PlayerMediaSource;

    return playerMediaSource.buildMediaHistoryItem(
      context: context,
      item: item,
      onTap: () async {
        await playerMediaSource.launchMediaPage(
            context, playerMediaSource.getLaunchParams(item));
        setState(() {});
      },
      onLongPress: () async {
        List<Widget> actions = [];
        actions.add(
          TextButton(
            child: Text(
              appModel.translate("dialog_remove"),
              style: TextStyle(
                color: Theme.of(context).focusColor,
              ),
            ),
            onPressed: () async {
              await history.removeItem(item.key);

              Navigator.pop(context);
              setState(() {});
            },
          ),
        );

        actions.addAll(
            playerMediaSource.getExtraHistoryActions(item, callback: () {
          setState(() {});
        }));

        actions.add(
          TextButton(
            child: Text(
              appModel.translate("dialog_play"),
              style: const TextStyle(),
            ),
            onPressed: () async {
              Navigator.pop(context);
              playerMediaSource.launchMediaPage(
                  context, playerMediaSource.getLaunchParams(item));
              setState(() {});
            },
          ),
        );

        HapticFeedback.vibrate();
        ImageProvider<Object> image =
            await playerMediaSource.getThumbnail(item);
        await showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              playerMediaSource.getCaption(item),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            content: AspectRatio(
              aspectRatio: 16 / 9,
              child: FadeInImage(
                image: image,
                placeholder: MemoryImage(kTransparentImage),
              ),
            ),
            actions: actions,
          ),
        );
      },
    );
  }

  Widget buildEmptyBody() {
    return Column(
      children: [
        buildSearchField(),
        getCurrentMediaSource().getButton(context) ?? const SizedBox.shrink(),
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

  Widget buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: TextFormField(
        keyboardType: TextInputType.text,
        maxLines: 1,
        controller: wordController,
        onFieldSubmitted: (result) async {
          await getCurrentMediaSource().searchAction!();
          setState(() {});
        },
        enableInteractiveSelection: (!getCurrentMediaSource().searchSupport),
        onTap: () {
          if (!getCurrentMediaSource().searchSupport) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
        },
        readOnly: (!getCurrentMediaSource().searchSupport),
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).unselectedWidgetColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).focusColor),
          ),
          contentPadding: const EdgeInsets.all(0),
          prefixIcon: Icon(widget.mediaType.icon()),
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (getCurrentMediaSource().searchSupport)
                BusyIconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    await getCurrentMediaSource().searchAction!();
                    setState(() {});
                  },
                ),
              BusyIconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.perm_media),
                  onPressed: () async {
                    await appModel.showSourcesMenu(
                      context: context,
                      mediaType: widget.mediaType,
                    );
                  }),
              if (getCurrentMediaSource().searchSupport)
                BusyIconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.clear),
                  onPressed: () async {
                    wordController.clear();
                  },
                ),
            ],
          ),
          labelText: getCurrentMediaSource().sourceName,
          hintText: getCurrentMediaSource().searchLabel,
        ),
      ),
    );
  }
}
