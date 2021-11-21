import 'dart:async';
import 'dart:io';

import 'package:chisa/util/reading_direction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/reader_page.dart';
import 'package:chisa/util/time_format.dart';
import 'package:wakelock/wakelock.dart';

abstract class ReaderMediaSource extends MediaSource {
  ReaderMediaSource({
    required String sourceName,
    required IconData icon,
    required this.readingDirection,
  }) : super(
          sourceName: sourceName,
          icon: icon,
          mediaType: MediaType.reader,
        );

  final ReadingDirection readingDirection;

  /// A [ReaderMediaSource] must be able to construct launch parameters from
  /// its media history items.
  ReaderLaunchParams getLaunchParams(AppModel appModel, MediaHistoryItem item);

  /// Push the navigator page to the media page pertaining to this media type.
  Future<void> launchMediaPage(
    BuildContext context,
    ReaderLaunchParams params, {
    bool pushReplacement = false,
  }) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);
    appModel.isInSource = true;

    if (pushReplacement) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => ReaderPage(params: params),
        ),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => ReaderPage(params: params),
        ),
      );
    }

    appModel.isInSource = false;
    Wakelock.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    Future.delayed(const Duration(seconds: 1), () {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });
  }

  @override
  Widget buildMediaHistoryItem({
    required BuildContext context,
    required MediaHistory history,
    required MediaHistoryItem item,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
    bool isHistory = false,
  }) {
    AppModel appModel = Provider.of<AppModel>(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await launchMediaPage(context, getLaunchParams(appModel, item));
          homeRefreshCallback();
          searchRefreshCallback();
        },
        onLongPress: () async {
          AppModel appModel = Provider.of<AppModel>(context, listen: false);
          MediaHistory history = mediaType.getMediaHistory(appModel);

          List<Widget> actions = [];

          if (isHistory) {
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
                  homeRefreshCallback();
                  searchRefreshCallback();
                },
              ),
            );

            actions.add(
              TextButton(
                child: Text(
                  appModel.translate("dialog_edit"),
                ),
                onPressed: () async {
                  await showAliasDialog(
                    context: context,
                    item: item,
                    homeRefreshCallback: homeRefreshCallback,
                    searchRefreshCallback: searchRefreshCallback,
                  );
                },
              ),
            );
          }

          actions.addAll(
            getExtraHistoryActions(
              context: context,
              item: item,
              homeRefreshCallback: homeRefreshCallback,
              searchRefreshCallback: searchRefreshCallback,
              isHistory: isHistory,
            ),
          );

          actions.add(
            TextButton(
              child: Text(
                appModel.translate("dialog_read"),
                style: const TextStyle(),
              ),
              onPressed: () async {
                Navigator.pop(context);
                launchMediaPage(context, getLaunchParams(appModel, item));
                homeRefreshCallback();
                searchRefreshCallback();
              },
            ),
          );

          HapticFeedback.vibrate();
          await showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                (item.alias.isNotEmpty)
                    ? getHistoryCaptionAlias(item)
                    : getHistoryCaption(item),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          icon,
                          color: Theme.of(context).unselectedWidgetColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.sourceName,
                          style: TextStyle(
                            color: Theme.of(context).unselectedWidgetColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<ImageProvider<Object>?>(
                      future: getHistoryThumbnailAlias(item),
                      builder: (BuildContext context,
                          AsyncSnapshot<ImageProvider?> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Image(image: MemoryImage(kTransparentImage));
                        }

                        if (snapshot.data == null) {
                          return FutureBuilder<ImageProvider<Object>>(
                            future: getHistoryThumbnail(item),
                            builder: (BuildContext context,
                                AsyncSnapshot<ImageProvider> snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData) {
                                return Image(
                                    image: MemoryImage(kTransparentImage));
                              }

                              ImageProvider<Object> thumbnail = snapshot.data!;

                              return FadeInImage(
                                placeholder: MemoryImage(kTransparentImage),
                                image: thumbnail,
                                fit: BoxFit.fitWidth,
                              );
                            },
                          );
                        }

                        ImageProvider<Object> thumbnail = snapshot.data!;

                        return Image(
                          image: thumbnail,
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: actions,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                color: Colors.grey.shade800.withOpacity(0.3),
                child: AspectRatio(
                  aspectRatio: 176 / 250,
                  child: FutureBuilder<ImageProvider<Object>?>(
                    future: getHistoryThumbnailAlias(item),
                    builder: (BuildContext context,
                        AsyncSnapshot<ImageProvider?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Image(image: MemoryImage(kTransparentImage));
                      }

                      if (snapshot.data == null) {
                        return FutureBuilder<ImageProvider<Object>>(
                          future: getHistoryThumbnail(item),
                          builder: (BuildContext context,
                              AsyncSnapshot<ImageProvider> snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                !snapshot.hasData) {
                              return Image(
                                  image: MemoryImage(kTransparentImage));
                            }

                            ImageProvider<Object> thumbnail = snapshot.data!;

                            return FadeInImage(
                              placeholder: MemoryImage(kTransparentImage),
                              image: thumbnail,
                              fit: BoxFit.fitWidth,
                            );
                          },
                        );
                      }

                      ImageProvider<Object> thumbnail = snapshot.data!;

                      return FadeInImage(
                        placeholder: MemoryImage(kTransparentImage),
                        image: thumbnail,
                        fit: BoxFit.fitWidth,
                      );
                    },
                  ),
                ),
              ),
              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(2, 2, 2, 4),
                  height: constraints.maxHeight * 0.175,
                  width: double.maxFinite,
                  color: Colors.black.withOpacity(0.6),
                  child: Text(
                    (item.alias.isEmpty) ? item.title : item.alias,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                    ),
                  ),
                );
              }),
              LinearProgressIndicator(
                value: item.currentProgress / item.completeProgress,
                backgroundColor: Colors.white.withOpacity(0.6),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                minHeight: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildMediaHistoryMetadata({
    required BuildContext context,
    required MediaHistoryItem item,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
    bool isHistory = false,
  }) {
    Widget? extraMetadata = getHistoryExtraMetadata(
      context: context,
      item: item,
      homeRefreshCallback: homeRefreshCallback,
      searchRefreshCallback: searchRefreshCallback,
      isHistory: isHistory,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getHistoryCaption(item),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        const SizedBox(height: 8),
        Text(
          getHistorySubcaption(item),
          style: TextStyle(
            color: Theme.of(context).unselectedWidgetColor,
            fontSize: 12,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        const SizedBox(height: 2),
        if (isHistory)
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Icon(
              icon,
              color: Theme.of(context).unselectedWidgetColor,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              item.sourceName,
              style: TextStyle(
                color: Theme.of(context).unselectedWidgetColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ]),
        if (extraMetadata != null) extraMetadata
      ],
    );
  }

  @override
  Widget buildMediaHistoryThumbnail({
    required BuildContext context,
    required MediaHistoryItem item,
    required Function() homeRefreshCallback,
    required Function()? searchRefreshCallback,
    bool isHistory = false,
  }) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          color: Colors.black,
          child: AspectRatio(
            aspectRatio: 176 / 250,
            child: FutureBuilder<ImageProvider<Object>>(
              future: getHistoryThumbnail(item),
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
                  fit: BoxFit.fitWidth,
                );
              },
            ),
          ),
        ),
        Positioned(
          right: 4.0,
          bottom: 6.0,
          child: Container(
            height: 20,
            color: Colors.black.withOpacity(0.8),
            alignment: Alignment.center,
            child: Text(
              getDurationText(Duration(seconds: item.completeProgress)),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
        if (isHistory)
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
    );
  }

  @override
  List<Widget> getExtraHistoryActions({
    required BuildContext context,
    required MediaHistoryItem item,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
    bool isHistory = false,
  }) {
    return [];
  }

  @override
  Widget getDisplayLayout({
    required AppModel appModel,
    required BuildContext context,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
    required ScrollController scrollController,
    required PagingController<int, MediaHistoryItem> pagingController,
  }) {
    AppModel appModel = Provider.of<AppModel>(context);
    MediaHistory mediaHistory = MediaHistory(
      appModel: appModel,
      prefsDirectory: mediaType.prefsDirectory(),
    );

    return PagedListView<int, MediaHistoryItem>(
      scrollController: scrollController,
      pagingController: pagingController,
      addAutomaticKeepAlives: true,
      key: UniqueKey(),
      builderDelegate: PagedChildBuilderDelegate<MediaHistoryItem>(
          itemBuilder: (context, item, index) {
        return buildMediaHistoryItem(
          context: context,
          history: mediaHistory,
          item: item,
          homeRefreshCallback: homeRefreshCallback,
          searchRefreshCallback: searchRefreshCallback,
        );
      }),
    );
  }

  /// From a [MediaHistoryItem], get an alias for an alternative caption to
  /// show for the item.
  String getHistoryCaptionAlias(MediaHistoryItem item) {
    return item.alias;
  }

  Future<ImageProvider<Object>?> getHistoryThumbnailAlias(
      MediaHistoryItem item) async {
    if (item.thumbnailPath.isEmpty) {
      return null;
    }

    return FileImage(
      File(item.thumbnailPath),
    );
  }

  /// Define a custom [Widget] for the [ReaderPage] to represent the reading
  /// area of the session.
  Widget buildReaderArea(BuildContext context, ReaderPageState state);

  /// Return if [ReadingDirection] is vertical.
  bool isVertical() {
    switch (readingDirection) {
      case ReadingDirection.horizontalLTR:
      case ReadingDirection.horizontalRTL:
        return false;
      case ReadingDirection.verticalLTR:
      case ReadingDirection.verticalRTL:
        return true;
    }
  }

  /// See [ReaderTtuMediaSource] lmao
  bool getHorizontalHack(BuildContext context) => false;

  Future<void> showAliasDialog({
    required BuildContext context,
    required MediaHistoryItem item,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
  }) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);

    String defaultTitle = item.title;
    ImageProvider<Object> defaultThumbnail = await getHistoryThumbnail(item);

    String title = defaultTitle;
    ImageProvider<Object> thumbnail = defaultThumbnail;

    String titleAlias = item.alias;
    ImageProvider<Object>? thumbnailAlias =
        await getHistoryThumbnailAlias(item);

    if (titleAlias.isNotEmpty) {
      title = item.alias;
    }
    if (thumbnailAlias != null) {
      thumbnail = thumbnailAlias;
    }

    TextEditingController nameAliasController = TextEditingController(
      text: title,
    );
    TextEditingController coverAliasController = TextEditingController(
      text: "a",
    );

    File? newCover;
    ValueNotifier<ImageProvider> imageProviderNotifier =
        ValueNotifier<ImageProvider>(thumbnail);

    Widget showPreviewImage() {
      return ValueListenableBuilder(
        valueListenable: imageProviderNotifier,
        builder:
            (BuildContext context, ImageProvider imageProvider, Widget? child) {
          return Image(image: imageProvider);
        },
      );
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: double.maxFinite, height: 1),
                TextField(
                  controller: nameAliasController,
                  maxLines: null,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      iconSize: 18,
                      onPressed: () async {
                        nameAliasController.text = defaultTitle;
                      },
                      icon: const Icon(Icons.undo),
                    ),
                  ),
                ),
                TextField(
                  readOnly: true,
                  controller: coverAliasController,
                  style: const TextStyle(color: Colors.transparent),
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Padding(
                            child: showPreviewImage(),
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                          ),
                        ),
                        const SizedBox(width: 5),
                        IconButton(
                          iconSize: 18,
                          onPressed: () async {
                            ImagePicker imagePicker = ImagePicker();
                            final pickedFile = await imagePicker.pickImage(
                                source: ImageSource.gallery);
                            newCover = File(pickedFile!.path);
                            imageProviderNotifier.value = FileImage(newCover!);
                          },
                          icon: const Icon(Icons.file_upload),
                        ),
                        IconButton(
                          iconSize: 18,
                          onPressed: () async {
                            newCover = null;
                            imageProviderNotifier.value = defaultThumbnail;
                          },
                          icon: const Icon(Icons.undo),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                appModel.translate('dialog_return'),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                appModel.translate('dialog_set'),
              ),
              onPressed: () async {
                String newTitleAlias = nameAliasController.text.trim();

                if (newTitleAlias.isNotEmpty) {
                  item.alias = newTitleAlias;

                  if (newCover != null) {
                    Directory appDocDir =
                        await getApplicationDocumentsDirectory();
                    Directory thumbsDir = Directory(
                        appDocDir.path + "/thumbs/${getIdentifier()}");
                    if (!thumbsDir.existsSync()) {
                      thumbsDir.createSync(recursive: true);
                    }

                    DateTime dateTime = DateTime.now();

                    String thumbnailPath =
                        "${thumbsDir.path}/${dateTime.millisecondsSinceEpoch}.jpg";

                    File thumbnailFile = File(thumbnailPath);
                    if (thumbnailFile.existsSync()) {
                      thumbnailFile.deleteSync();
                    }
                    newCover?.copySync(thumbnailPath);

                    item.thumbnailPath = thumbnailPath;
                  } else {
                    item.thumbnailPath = "";
                  }
                }

                mediaType.getMediaHistory(appModel).addItem(item);

                Navigator.pop(context);
                Navigator.pop(context);

                homeRefreshCallback();
                searchRefreshCallback();
              },
            ),
          ],
        );
      },
    );
  }
}
