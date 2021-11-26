import 'dart:async';
import 'dart:io';

import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_source.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/viewer_page.dart';
import 'package:chisa/util/marquee.dart';
import 'package:chisa/util/time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wakelock/wakelock.dart';

enum ChapterProgressState {
  unstarted,
  viewed,
  finished,
}

abstract class ViewerMediaSource extends MediaSource {
  ViewerMediaSource({
    required String sourceName,
    required IconData icon,
  }) : super(
          sourceName: sourceName,
          icon: icon,
          mediaType: MediaType.viewer,
        );

  /// A cache for a source to store its chapters if it has already fetched
  /// it once this session.
  Map<String, List<String>> chaptersCache = {};
  Map<String, Map<String, List<ImageProvider<Object>>>> cachedImages = {};

  bool saveHistoryItem = true;

  /// Push the navigator page to the media page pertaining to this media type.
  Future<void> launchMediaPage(
    BuildContext context,
    ViewerLaunchParams params, {
    bool pushReplacement = false,
  }) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);
    appModel.isInSource = true;

    if (pushReplacement) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => ViewerPage(params: params),
        ),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => ViewerPage(params: params),
        ),
      );
    }

    appModel.isInSource = false;
  }

  /// From a [MediaHistoryItem], get an alias for an alternative caption to
  /// show for the item.
  String getHistoryCaptionAlias(MediaHistoryItem item) {
    return item.alias;
  }

  ImageProvider<Object>? getHistoryThumbnailAlias(MediaHistoryItem item) {
    if (item.thumbnailPath.isEmpty) {
      return null;
    }

    return FileImage(
      File(item.thumbnailPath),
    );
  }

  int? getUnfinishedChapters(MediaHistoryItem item) {
    List<dynamic>? chapterCache = item.extra["chapters"];
    List<String>? chapters;
    if (chapterCache != null) {
      chapters = List<String>.from(chapterCache);
    }

    if (chapters == null) {
      return null;
    }

    int unfinished = chapters.length;

    for (String chapter in chapters) {
      if (getChapterProgressState(item, chapter) ==
          ChapterProgressState.finished) {
        unfinished -= 1;
      }
    }

    return unfinished;
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
    ValueNotifier<bool> chapterValueNotifier = ValueNotifier<bool>(false);

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
              chapters: await getCachedChapters(item),
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
        ),
        onPressed: () async {
          ViewerLaunchParams params = ViewerLaunchParams(
            mediaHistoryItem: item,
            appModel: appModel,
            chapters: await getCachedChapters(item),
            mediaSource: this,
          );

          Navigator.pop(context);
          Wakelock.enable();
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: [SystemUiOverlay.bottom],
          );

          await launchMediaPage(
            context,
            params,
          );

          homeRefreshCallback();
        },
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          ValueNotifier<bool> shouldRefreshNotifier =
              ValueNotifier<bool>(false);
          await showChapterMenu(
            context: context,
            item: item,
            shouldRefreshNotifier: shouldRefreshNotifier,
            chapterValueNotifier: chapterValueNotifier,
            actions: actions,
          );
          if (shouldRefreshNotifier.value) {
            homeRefreshCallback();
            searchRefreshCallback();
          }
        },
        onLongPress: () async {
          ValueNotifier<bool> shouldRefreshNotifier =
              ValueNotifier<bool>(false);
          HapticFeedback.vibrate();
          await showChapterMenu(
            context: context,
            item: item,
            shouldRefreshNotifier: shouldRefreshNotifier,
            chapterValueNotifier: chapterValueNotifier,
            actions: actions,
          );

          if (shouldRefreshNotifier.value) {
            homeRefreshCallback();
            searchRefreshCallback();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                color: Colors.grey.shade800.withOpacity(0.3),
                child: AspectRatio(
                  aspectRatio: 250 / 350,
                  child: FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: getHistoryThumbnailAlias(item) ??
                        getHistoryThumbnail(item),
                    alignment: Alignment.topCenter,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              if (isHistory)
                ValueListenableBuilder(
                  valueListenable: chapterValueNotifier,
                  builder: (_, __, ___) {
                    if (getUnfinishedChapters(item) != null &&
                        getUnfinishedChapters(item) != 0) {
                      return Positioned(
                        right: 5.0,
                        top: 18.0,
                        child: Container(
                          height: 20,
                          color: Colors.black.withOpacity(0.6),
                          alignment: Alignment.center,
                          child: Text(
                            "  ${getUnfinishedChapters(item)}  ",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Container(
                  alignment: Alignment.center,
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
            child: FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              image: getHistoryThumbnail(item),
              alignment: Alignment.topCenter,
              fit: BoxFit.fitWidth,
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

  /// A unique button for a [MediaSource] that appears on the menu of the
  /// [ViewerPage] when an item from the source is shown.
  Widget? buildSourceButton(BuildContext context, ViewerPageState page) {
    return null;
  }

  Future<void> showAliasDialog({
    required BuildContext context,
    required MediaHistoryItem item,
    required List<String> chapters,
    required Function() homeRefreshCallback,
    required Function() searchRefreshCallback,
  }) async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);

    String defaultTitle = item.title;
    ImageProvider<Object> defaultThumbnail = getHistoryThumbnail(item);

    String title = defaultTitle;
    ImageProvider<Object> thumbnail = defaultThumbnail;

    String titleAlias = item.alias;
    ImageProvider<Object>? thumbnailAlias = getHistoryThumbnailAlias(item);

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
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameAliasController,
                    maxLines: null,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .unselectedWidgetColor
                                .withOpacity(0.5)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).focusColor),
                      ),
                      suffixIcon: IconButton(
                        iconSize: 18,
                        color: appModel.getIsDarkMode()
                            ? Colors.white
                            : Colors.black,
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
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .unselectedWidgetColor
                                .withOpacity(0.5)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).focusColor),
                      ),
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
                            color: appModel.getIsDarkMode()
                                ? Colors.white
                                : Colors.black,
                            onPressed: () async {
                              ImagePicker imagePicker = ImagePicker();
                              final pickedFile = await imagePicker.pickImage(
                                  source: ImageSource.gallery);
                              newCover = File(pickedFile!.path);
                              imageProviderNotifier.value =
                                  FileImage(newCover!);
                            },
                            icon: const Icon(Icons.file_upload),
                          ),
                          IconButton(
                            iconSize: 18,
                            color: appModel.getIsDarkMode()
                                ? Colors.white
                                : Colors.black,
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

                await mediaType.getMediaHistory(appModel).addItem(item);

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

  /// Get the name of the last chapter read pertaining to a [MediaHistoryItem].
  MediaHistoryItem setCurrentChapterName(
      MediaHistoryItem item, String chapter) {
    item.extra["currentChapterName"] = chapter;
    return item;
  }

  /// Get the last chapter read pertaining to a [MediaHistoryItem] and a given
  /// list of [Chapter].
  String? getCurrentChapter(MediaHistoryItem item, List<String> chapters) {
    return item.extra["currentChapterName"];
  }

  /// Get the chapter before the last read chapter pertaining to a
  /// [MediaHistoryItem]  and a given list of [Chapter].
  String? getPreviousChapter(String currentChapter, List<String> chapters) {
    if (chapters.isEmpty || chapters.length == 1) {
      return null;
    }

    for (int i = 0; i < chapters.length; i++) {
      if (chapters[i] == currentChapter) {
        if (i == 0) {
          return null;
        } else {
          return chapters[i - 1];
        }
      }
    }
  }

  /// Get the chapter after the last read chapter pertaining to a
  /// [MediaHistoryItem]  and a given list of [Chapter].
  String? getNextChapter(String currentChapter, List<String> chapters) {
    if (chapters.isEmpty || chapters.length == 1) {
      return null;
    }

    for (int i = 0; i < chapters.length; i++) {
      if (chapters[i] == currentChapter) {
        if (i == chapters.length - 1) {
          return null;
        } else {
          return chapters[i + 1];
        }
      }
    }
  }

  ChapterProgressState getChapterProgress(
    MediaHistoryItem item,
    String chapter,
  ) {
    int? pageTotal = getChapterPageTotal(item, chapter);
    if (pageTotal == null) {
      return ChapterProgressState.unstarted;
    }

    int pageProgress = getChapterPageProgress(item, chapter) ?? 0;

    if (pageTotal == pageProgress) {
      return ChapterProgressState.finished;
    } else {
      return ChapterProgressState.viewed;
    }
  }

  int? getChapterPageProgress(
    MediaHistoryItem item,
    String chapter,
  ) {
    return item.extra["$chapter/pageProgress"];
  }

  MediaHistoryItem setChapterPageProgress(
    MediaHistoryItem item,
    String chapter,
    int? pageProgress,
  ) {
    item.extra["$chapter/pageProgress"] = pageProgress;
    return item;
  }

  int? getChapterPageTotal(
    MediaHistoryItem item,
    String chapter,
  ) {
    return item.extra["$chapter/pageTotal"];
  }

  MediaHistoryItem setChapterPageTotal(
    MediaHistoryItem item,
    String chapter,
    int? pageTotal,
  ) {
    item.extra["$chapter/pageTotal"] = pageTotal;
    return item;
  }

  Future<List<String>> getCachedChapters(MediaHistoryItem item) async {
    List<String>? cachedChapters = chaptersCache[item.key];
    if (cachedChapters != null) {
      return cachedChapters;
    }

    List<String> chapters = await getChapters(item);
    chaptersCache[item.key] = chapters;
    return chapters;
  }

  Future<List<ImageProvider<Object>>> getCachedImages(
      MediaHistoryItem item, String chapter) async {
    Map<String, List<ImageProvider<Object>>>? keyMap = cachedImages[item.key];

    if (keyMap == null) {
      cachedImages[item.key] = {};
    }

    List<ImageProvider<Object>>? images = cachedImages[item.key]![chapter];

    if (images == null) {
      images = await getChapterImages(item, chapter);
      cachedImages[item.key]![chapter] = images;
      return images;
    } else {
      return images;
    }
  }

  /// Get all chapters given a [MediaHistoryItem].
  Future<List<String>> getChapters(MediaHistoryItem item);

  /// Given a [Chapter] from a [MediaHistoryItem], return a list of
  /// [ImageProvider<Object>] representing the chapter contents.
  Future<List<ImageProvider<Object>>> getChapterImages(
    MediaHistoryItem item,
    String chapter,
  );

  ChapterProgressState getChapterProgressState(
    MediaHistoryItem item,
    String chapterName,
  ) {
    if (getChapterPageProgress(item, chapterName) == null ||
        getChapterPageTotal(item, chapterName) == null) {
      return ChapterProgressState.unstarted;
    }

    if (getChapterPageProgress(item, chapterName) ==
        getChapterPageTotal(item, chapterName)) {
      return ChapterProgressState.finished;
    }

    return ChapterProgressState.viewed;
  }

  Future<void> showChapterMenu({
    required BuildContext context,
    required MediaHistoryItem item,
    ValueNotifier<bool>? shouldRefreshNotifier,
    ValueNotifier<bool>? chapterValueNotifier,
    List<Widget> actions = const [],
    bool pushReplacement = false,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return ChapterMenu(
          item: item,
          source: this,
          chapterValueNotifier: chapterValueNotifier,
          shouldRefreshNotifier: shouldRefreshNotifier,
          actions: actions,
          pushReplacement: pushReplacement,
        );
      },
    );
  }
}

class ChapterMenu extends StatefulWidget {
  const ChapterMenu({
    Key? key,
    required this.item,
    required this.source,
    required this.shouldRefreshNotifier,
    required this.chapterValueNotifier,
    required this.actions,
    this.pushReplacement = false,
  }) : super(key: key);

  final MediaHistoryItem item;
  final ViewerMediaSource source;
  final ValueNotifier<bool>? shouldRefreshNotifier;
  final ValueNotifier<bool>? chapterValueNotifier;
  final bool pushReplacement;
  final List<Widget> actions;

  @override
  State<StatefulWidget> createState() => ChapterMenuState();
}

class ChapterMenuState extends State<ChapterMenu> {
  late AppModel appModel;
  late MediaHistoryItem item;

  bool editMode = false;

  ScrollController scrollController = ScrollController();
  Map<String, ChapterProgressState?> stateDeltas = {};

  @override
  void initState() {
    super.initState();
    item = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    return AlertDialog(
      contentPadding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      title: buildTitle(),
      content: buildChapterMenuContent(
        context,
        item,
        shouldRefreshNotifier: widget.shouldRefreshNotifier,
        pushReplacement: widget.pushReplacement,
      ),
      actions: (editMode) ? getEditModeActions() : widget.actions,
    );
  }

  List<Widget> getEditModeActions() {
    return [
      TextButton(
        child: Text(
          appModel.translate('dialog_return'),
        ),
        onPressed: () {
          toggleEditMode();
        },
      ),
      TextButton(
        child: Text(
          appModel.translate('dialog_set'),
        ),
        onPressed: () async {
          for (String chapter in widget.source.chaptersCache[item.key]!) {
            ChapterProgressState? stateDelta = stateDeltas[chapter];
            if (stateDelta == null) {
              continue;
            }

            switch (stateDelta) {
              case ChapterProgressState.unstarted:
                item =
                    widget.source.setChapterPageProgress(item, chapter, null);
                item = widget.source.setChapterPageTotal(item, chapter, null);

                break;
              case ChapterProgressState.viewed:
              case ChapterProgressState.finished:
                List<ImageProvider<Object>> images =
                    await widget.source.getCachedImages(item, chapter);
                item = widget.source
                    .setChapterPageProgress(item, chapter, images.length);
                item = widget.source
                    .setChapterPageTotal(item, chapter, images.length);
                break;
            }
          }

          if (widget.chapterValueNotifier != null) {
            widget.chapterValueNotifier!.value =
                !widget.chapterValueNotifier!.value;
          }
          widget.shouldRefreshNotifier?.value = true;
          await widget.source.mediaType.getMediaHistory(appModel).addItem(item);

          toggleEditMode();
        },
      ),
    ];
  }

  void toggleEditMode() {
    editMode = !editMode;
    stateDeltas = {};

    setState(() {});
  }

  Widget? buildTitle() {
    if (widget.pushReplacement) {
      return null;
    }

    return Text(
      (item.alias.isNotEmpty)
          ? widget.source.getHistoryCaptionAlias(item)
          : widget.source.getHistoryCaption(item),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget buildChapterListTile({
    required BuildContext context,
    required MediaHistoryItem item,
    required String chapterName,
    required ChapterProgressState state,
  }) {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);

    ValueNotifier<ChapterProgressState?> stateDeltaNotifier =
        ValueNotifier<ChapterProgressState?>(stateDeltas[chapterName]);

    return ValueListenableBuilder<ChapterProgressState?>(
        valueListenable: stateDeltaNotifier,
        builder: (context, value, child) {
          ChapterProgressState deltaOrActualState = value ?? state;
          Color color;
          switch (deltaOrActualState) {
            case ChapterProgressState.unstarted:
              color = (appModel.getIsDarkMode()) ? Colors.white : Colors.black;
              break;
            case ChapterProgressState.viewed:
            case ChapterProgressState.finished:
              color = Theme.of(context).unselectedWidgetColor;
              break;
          }

          return ListTile(
            dense: true,
            title: Row(
              children: [
                Icon(
                  (editMode) ? Icons.history : Icons.book_sharp,
                  size: 20.0,
                  color: color,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: Marquee(
                      text: chapterName,
                      style: TextStyle(
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                buildProgressIndicator(
                  context,
                  item,
                  chapterName,
                  deltaOrActualState,
                  color,
                ),
              ],
            ),
            onTap: () async {
              if (editMode) {
                switch (deltaOrActualState) {
                  case ChapterProgressState.unstarted:
                    stateDeltas[chapterName] = ChapterProgressState.finished;

                    break;
                  case ChapterProgressState.viewed:
                    stateDeltas[chapterName] = ChapterProgressState.unstarted;
                    break;
                  case ChapterProgressState.finished:
                    if (state == ChapterProgressState.viewed) {
                      stateDeltas[chapterName] = null;
                    } else {
                      stateDeltas[chapterName] = ChapterProgressState.unstarted;
                    }
                    break;
                }
                stateDeltaNotifier.value = stateDeltas[chapterName];
              } else {
                widget.shouldRefreshNotifier?.value = true;

                ViewerLaunchParams newParams = ViewerLaunchParams(
                  mediaHistoryItem: item,
                  appModel: appModel,
                  chapters: widget.source.chaptersCache[item.key]!,
                  chapterName: chapterName,
                  pushReplacement: widget.pushReplacement,
                  mediaSource: widget.source,
                );

                Navigator.pop(context);

                if (!widget.pushReplacement) {
                  Wakelock.enable();
                  SystemChrome.setEnabledSystemUIMode(
                    SystemUiMode.manual,
                    overlays: [SystemUiOverlay.bottom],
                  );
                }
                await widget.source.launchMediaPage(
                  context,
                  newParams,
                  pushReplacement: widget.pushReplacement,
                );
              }
            },
            onLongPress: () async {
              if (editMode) {
                switch (deltaOrActualState) {
                  case ChapterProgressState.unstarted:
                    stateDeltas[chapterName] = ChapterProgressState.finished;
                    break;
                  case ChapterProgressState.viewed:
                  case ChapterProgressState.finished:
                    stateDeltas[chapterName] = ChapterProgressState.unstarted;
                    break;
                }

                for (String chapter in widget.source.chaptersCache[item.key]!) {
                  stateDeltas[chapter] = stateDeltas[chapterName];

                  if (chapter == chapterName) {
                    break;
                  }
                }

                setState(() {});
              }
            },
          );
        });
  }

  Widget buildProgressIndicator(
    BuildContext context,
    MediaHistoryItem item,
    String chapterName,
    ChapterProgressState state,
    Color color,
  ) {
    switch (state) {
      case ChapterProgressState.unstarted:
        return Icon(Icons.play_arrow, color: color);

      case ChapterProgressState.finished:
        return Icon(Icons.check, color: color);

      case ChapterProgressState.viewed:
        late double percentage;
        int currentProgress =
            widget.source.getChapterPageProgress(item, chapterName)!;
        int completeProgress =
            widget.source.getChapterPageTotal(item, chapterName)!;
        percentage = currentProgress / completeProgress;

        return Padding(
          child: SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(
              value: percentage,
              backgroundColor: Theme.of(context).unselectedWidgetColor,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).focusColor),
              strokeWidth: 2,
            ),
          ),
          padding: const EdgeInsets.only(right: 5),
        );
    }
  }

  Widget buildChapterMenuContent(
    BuildContext context,
    MediaHistoryItem item, {
    ValueNotifier<bool>? shouldRefreshNotifier,
    bool pushReplacement = false,
  }) {
    return FutureBuilder(
      initialData: widget.source.chaptersCache[item.key],
      future: widget.source.getCachedChapters(item),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: double.maxFinite,
            child: SizedBox(
              height: 32,
              width: 32,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation(Theme.of(context).focusColor),
                ),
              ),
            ),
          );
        }

        List<String> chapters = snapshot.data;
        if (item.extra["chapters"] != null &&
            item.extra["chapters"].length != chapters.length) {
          item.extra["chapters"] = chapters;
          widget.shouldRefreshNotifier?.value = true;
          if (widget.chapterValueNotifier != null) {
            widget.chapterValueNotifier!.value =
                !widget.chapterValueNotifier!.value;
          }
          widget.source.mediaType.getMediaHistory(appModel).addItem(item);
        }

        if (chapters.isEmpty) {
          return SizedBox(
            height: 128,
            width: 128,
            child: Center(
              child: Icon(
                Icons.broken_image,
                color: Theme.of(context).unselectedWidgetColor,
                size: 128,
              ),
            ),
          );
        }

        return SizedBox(
          width: double.maxFinite,
          child: RawScrollbar(
            thumbColor: (appModel.getIsDarkMode())
                ? Colors.grey[700]
                : Colors.grey[400],
            controller: scrollController,
            child: ListView.builder(
              controller: scrollController,
              shrinkWrap: true,
              itemCount: chapters.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  if (widget.pushReplacement) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          widget.source.icon,
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
                        const Spacer(),
                        Visibility(
                          visible: !editMode,
                          child: CircularButton(
                            onPressed: () {
                              if (!widget.pushReplacement && !editMode) {
                                toggleEditMode();
                              }
                            },
                            icon: Icon(
                              Icons.edit,
                              size: 16,
                              color: Theme.of(context).unselectedWidgetColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32)
                      ],
                    ),
                  );
                }

                String chapterName = chapters[index - 1];

                ChapterProgressState state =
                    widget.source.getChapterProgressState(item, chapterName);

                return buildChapterListTile(
                  context: context,
                  item: item,
                  chapterName: chapterName,
                  state: state,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
