import 'package:chisa/media/media_history_item.dart';
import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_sources/player_media_source.dart';
import 'package:chisa/util/time_format.dart';
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

  MediaSource getSource() {
    return appModel.getCurrentMediaTypeSource(widget.mediaType);
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
    List<MediaHistoryItem> mediaHistoryItems =
        appModel.getMediaHistory(widget.mediaType).getItems().reversed.toList();

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
              return getSource().getButton(context) ?? const SizedBox.shrink();
            }

            MediaHistoryItem item = mediaHistoryItems[index - 2];

            return buildMediaHistoryItem(item);
          },
        ),
      ),
    );
  }

  Widget buildEmptyBody() {
    return Column(
      children: [
        buildSearchField(),
        getSource().getButton(context) ?? const SizedBox.shrink(),
        buildEmptyMessage(),
      ],
    );
  }

  Widget buildEmptyMessage() {
    return Expanded(
      child: showCenterIconMessage(
        context: context,
        label: appModel.translate("history_empty"),
        icon: widget.mediaType.mediaTypeIcon,
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
          await getSource().searchAction!();
          setState(() {});
        },
        enableInteractiveSelection: (!getSource().searchSupport),
        onTap: () {
          if (!getSource().searchSupport) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
        },
        readOnly: (!getSource().searchSupport),
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).unselectedWidgetColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).focusColor),
          ),
          contentPadding: const EdgeInsets.all(0),
          prefixIcon: Icon(widget.mediaType.mediaTypeIcon),
          suffixIcon: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (getSource().searchSupport)
                BusyIconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    await getSource().searchAction!();
                    setState(() {});
                  },
                ),
              BusyIconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.perm_media),
                  onPressed: () async {
                    await appModel.showSourcesMenu(context, widget.mediaType);
                  }),
              if (getSource().searchSupport)
                BusyIconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.clear),
                  onPressed: () async {
                    wordController.clear();
                  },
                ),
            ],
          ),
          labelText: getSource().sourceName,
          hintText: getSource().searchLabel,
        ),
      ),
    );
  }

  Widget buildMediaHistoryItem(MediaHistoryItem item) {
    MediaSource source =
        widget.mediaType.getMediaSourceFromItem(appModel, item);

    return InkWell(
      onTap: () {
        PlayerMediaSource playerMediaSource = source as PlayerMediaSource;
        playerMediaSource.launchMediaPage(
            context, playerMediaSource.getLaunchParams(item));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            buildMediaHistoryThumbnail(source, item),
            const SizedBox(width: 12),
            Expanded(
              child: buildMediaHistoryMetadata(source, item),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMediaHistoryMetadata(MediaSource source, MediaHistoryItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          source.getCaption(item),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        const SizedBox(height: 8),
        Text(
          source.getSubcaption(item),
          style: TextStyle(
            color: Theme.of(context).unselectedWidgetColor,
            fontSize: 12,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        Row(
          children: [
            Icon(
              source.icon,
              color: Theme.of(context).unselectedWidgetColor,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              source.sourceName,
              style: TextStyle(
                color: Theme.of(context).unselectedWidgetColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMediaHistoryThumbnail(MediaSource source, MediaHistoryItem item) {
    double scaleWidth = MediaQuery.of(context).size.width * 0.4;

    return Container(
      width: scaleWidth,
      height: (scaleWidth) / 16 * 9,
      color: Colors.black,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          FutureBuilder<ImageProvider<Object>>(
              future: source.getThumbnail(item),
              builder: (BuildContext context,
                  AsyncSnapshot<ImageProvider> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return Image(image: MemoryImage(kTransparentImage));
                }

                ImageProvider<Object> thumbnail = snapshot.data!;

                return FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: thumbnail,
                  fit: BoxFit.contain,
                );
              }),
          Positioned(
            right: 4.0,
            bottom: 6.0,
            child: Container(
              height: 20,
              color: Colors.black.withOpacity(0.8),
              alignment: Alignment.center,
              child: Text(
                getYouTubeDuration(Duration(seconds: item.completeProgress)),
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
                value: item.currentProgress / item.completeProgress,
                backgroundColor: Colors.white.withOpacity(0.6),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                minHeight: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
