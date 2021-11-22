import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/media/media_sources/viewer_media_source.dart';
import 'package:chisa/util/anki_creator.dart';
import 'package:chisa/util/list_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:chisa/dictionary/dictionary_search_result.dart';
import 'package:chisa/media/media_histories/media_history.dart';
import 'package:chisa/media/media_history_items/media_history_item.dart';
import 'package:chisa/media/media_type.dart';
import 'package:chisa/media/media_types/media_launch_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/bottom_sheet_dialog.dart';
import 'package:chisa/util/dictionary_scrollable_widget.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wakelock/wakelock.dart';

class ViewerPage extends StatefulWidget {
  final ViewerLaunchParams params;

  const ViewerPage({
    Key? key,
    required this.params,
  }) : super(key: key);

  @override
  ViewerPageState createState() => ViewerPageState();
}

class ViewerPageState extends State<ViewerPage> {
  late AppModel appModel;

  /// Public for a [MediaSource] to edit and store session-specific details
  /// for its source button.
  Map<dynamic, dynamic> sourceOptions = {};

  final ValueNotifier<int> latestResultEntryIndex = ValueNotifier<int>(0);
  DictionarySearchResult? latestResult;

  Timer? menuHideTimer;

  PageController pageController = PageController();

  late Color menuColor;
  late Color dictionaryColor;
  double menuHeight = 48;

  final ValueNotifier<bool> isMenuHidden = ValueNotifier<bool>(false);

  List<ImageProvider<Object>> sourceImages = [];
  List<ImageProvider<Object>> galleryImages = [];
  bool isViewerReady = false;

  ValueNotifier<int> currentProgress = ValueNotifier<int>(0);
  int completeProgress = 0;

  List<String> chapters = [];
  String chapterName = "";

  DictionarySearchResult? searchResult;
  ValueNotifier<String> searchTerm = ValueNotifier<String>("");
  ValueNotifier<String> searchMessage = ValueNotifier<String>("");

  Future<bool> onWillPop() async {
    Widget alertDialog = AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      title: Text(
        appModel.translate("dialog_exit_viewer"),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            appModel.translate("dialog_yes"),
            style: TextStyle(
              color: Theme.of(context).focusColor,
            ),
          ),
          onPressed: () => Navigator.pop(context, true),
        ),
        TextButton(
          child: Text(
            appModel.translate("dialog_no"),
          ),
          onPressed: () async {
            Navigator.pop(context, false);
          },
        ),
      ],
    );

    return await showDialog(
          context: context,
          builder: (context) => alertDialog,
        ) ??
        false;
  }

  @override
  void dispose() async {
    ClipboardListener.removeListener(copyClipboardAction);

    pageController.dispose();

    await Wakelock.disable();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  Future<void> copyClipboardAction() async {
    setSearchTerm((await Clipboard.getData(Clipboard.kTextPlain))!
        .text!
        .replaceAll("￼", ""));
  }

  @override
  void initState() {
    super.initState();

    Wakelock.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    ClipboardListener.addListener(copyClipboardAction);

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      menuColor = appModel.getIsDarkMode()
          ? const Color(0xcc424242)
          : const Color(0xdeeeeeee);
      dictionaryColor = appModel.getIsDarkMode()
          ? Colors.grey.shade800.withOpacity(0.6)
          : Colors.white.withOpacity(0.8);

      await initialiseViewer();
      setState(() {
        isViewerReady = true;
      });
    });
  }

  Future<void> initialiseViewer() async {
    MediaHistoryItem item = widget.params.mediaHistoryItem;
    ViewerMediaSource source = widget.params.mediaSource;

    bool fromEnd = widget.params.fromEnd;
    bool fromStart = widget.params.fromStart;

    chapters = widget.params.chapters;
    if (widget.params.chapterName == null) {
      chapterName = source.getCurrentChapter(item, chapters) ?? chapters.first;
    } else {
      chapterName = widget.params.chapterName!;
    }

    sourceImages = await source.getChapterImages(item, chapterName);
    int historyProgress = source.getChapterPageProgress(item, chapterName) ?? 1;
    completeProgress = sourceImages.length;

    galleryImages.add(MemoryImage(kTransparentImage));
    galleryImages.addAll(sourceImages);
    galleryImages.add(MemoryImage(kTransparentImage));

    if (currentProgress.value <= 0 ||
        currentProgress.value > sourceImages.length) {
      currentProgress.value = 1;
    }

    if (fromStart) {
      currentProgress.value = sourceImages.length;
    } else if (fromEnd) {
      currentProgress.value = 1;
    } else {
      currentProgress.value = historyProgress;
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      pageController.jumpToPage(currentProgress.value);
    });
  }

  void setSearchTerm(String newTerm) {
    searchTerm.value = newTerm.trim();
    latestResult = null;
  }

  MediaHistoryItem? generateContextHistoryItem() {
    if (!widget.params.saveHistoryItem) {
      return null;
    }

    MediaHistoryItem item = widget.params.mediaHistoryItem;
    item.currentProgress = currentProgress.value;
    item.completeProgress = completeProgress;
    return item;
  }

  Widget buildPlaceholder() {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: SizedBox(
          height: 32,
          width: 32,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Theme.of(context).focusColor),
          ),
        ),
      ),
    );
  }

  Widget buildDictionary() {
    return MultiValueListenableBuider(
      valueListenables: [
        searchTerm,
        searchMessage,
      ],
      builder: (context, values, _) {
        String searchTerm = values.elementAt(0);
        String searchMessage = values.elementAt(1);

        if (searchMessage.isNotEmpty) {
          return Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 96,
              ),
              child: GestureDetector(
                onTap: () {
                  setSearchTerm("");
                },
                child: Container(
                  color: dictionaryColor,
                  padding: const EdgeInsets.all(16),
                  child: buildDictionaryMessage(searchMessage),
                ),
              ),
            ),
          );
        }

        if (searchTerm.isEmpty) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 96,
            ),
            child: GestureDetector(
              onTap: () {
                setSearchTerm("");
              },
              onLongPress: () async {
                await appModel.showDictionaryMenu(context,
                    onDictionaryChange: () {
                  refreshDictionaryWidget();
                });
              },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity == 0) return;

                if (details.primaryVelocity!.compareTo(0) == -1) {
                  appModel.setPrevDictionary();
                } else {
                  appModel.setNextDictionary();
                }
                refreshDictionaryWidget();
              },
              child: Container(
                color: dictionaryColor,
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<DictionarySearchResult>(
                  future: appModel.searchDictionary(
                    searchTerm,
                    mediaHistoryItem: generateContextHistoryItem(),
                  ), // a previously-obtained Future<String> or null
                  builder: (BuildContext context,
                      AsyncSnapshot<DictionarySearchResult> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return buildDictionarySearching();
                      default:
                        latestResult = snapshot.data;

                        if (!snapshot.hasData ||
                            latestResult!.entries.isEmpty) {
                          return buildDictionaryNoMatch();
                        } else {
                          return buildDictionaryMatch();
                        }
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildDictionaryMatch() {
    latestResultEntryIndex.value = 0;

    return DictionaryScrollableWidget.fromLatestResult(
      appModel: appModel,
      result: latestResult!,
      indexNotifier: latestResultEntryIndex,
      selectable: true,
    );
  }

  Widget buildDictionarySearching() {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: appModel.translate("dictionary_searching_before"),
            style: const TextStyle(),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: searchTerm.value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: appModel.translate("dictionary_searching_after"),
          ),
          WidgetSpan(
            child: SizedBox(
              height: 12,
              width: 12,
              child: JumpingDotsProgressIndicator(
                color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget buildDictionaryMessage1Argument(
    String beforeText,
    String boldedText,
    String afterText,
    bool jumpingDots,
  ) {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: beforeText,
            style: const TextStyle(),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: boldedText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(text: afterText),
          if (jumpingDots)
            WidgetSpan(
              child: SizedBox(
                height: 12,
                width: 12,
                child: JumpingDotsProgressIndicator(
                  color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDictionaryMessageArgument(
    String beforeText,
    String boldedText,
    String afterText,
    bool jumpingDots,
  ) {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: beforeText,
            style: const TextStyle(),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: boldedText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(text: afterText),
          if (jumpingDots)
            WidgetSpan(
              child: SizedBox(
                height: 12,
                width: 12,
                child: JumpingDotsProgressIndicator(
                  color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDictionaryMessage(String messageText) {
    // Handle special cases with certain reserved patterns.
    if (messageText.startsWith("deckExport://")) {
      String deckName = messageText.replaceAll("deckExport://", "");
      return buildDictionaryMessageArgument(
        appModel.translate("deck_label_before"),
        deckName,
        appModel.translate("deck_label_after"),
        false,
      );
    }

    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: messageText.replaceAll("...", ""),
          ),
          if (messageText.endsWith("..."))
            WidgetSpan(
              child: SizedBox(
                height: 12,
                width: 12,
                child: JumpingDotsProgressIndicator(
                  color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDictionaryNoMatch() {
    return Text.rich(
      TextSpan(
        text: '',
        children: <InlineSpan>[
          TextSpan(
            text: appModel.translate("dictionary_nomatch_before"),
          ),
          TextSpan(
            text: "『",
            style: TextStyle(
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: searchTerm.value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: "』",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          TextSpan(
            text: appModel.translate("dictionary_nomatch_after"),
            style: const TextStyle(),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> updateHistory() async {
    MediaHistory history =
        widget.params.mediaSource.mediaType.getMediaHistory(appModel);
    MediaHistoryItem item = widget.params.mediaHistoryItem;
    item.currentProgress = currentProgress.value;
    widget.params.mediaSource
        .setChapterPageProgress(item, chapterName, currentProgress.value);
    widget.params.mediaSource
        .setChapterPageTotal(item, chapterName, completeProgress);
    widget.params.mediaSource.setCurrentChapterName(item, chapterName);

    if (item.completeProgress != 0) {
      await history.addItem(item);
    }
  }

  Widget buildViewer() {
    return PhotoViewGallery.builder(
      reverse: (appModel.isViewerRightToLeft()),
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: galleryImages[index],
          initialScale: PhotoViewComputedScale.contained * 1,
          minScale: PhotoViewComputedScale.contained * 1,
          maxScale: PhotoViewComputedScale.contained * 6,
          filterQuality: FilterQuality.high,
          onTapDown: (context, details, value) async {
            toggleMenuVisibility();
          },
        );
      },
      backgroundDecoration:
          BoxDecoration(color: appModel.getViewerColorBackground()),
      scrollPhysics: const BouncingScrollPhysics(),
      itemCount: galleryImages.length,
      loadingBuilder: (context, event) => Center(
        child: SizedBox(
          width: 32.0,
          height: 32.0,
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
          ),
        ),
      ),
      pageController: pageController,
      onPageChanged: (pageNumber) async {
        ViewerMediaSource source = widget.params.mediaSource;

        if (pageNumber <= 0) {
          String? previousChapterName =
              source.getPreviousChapter(chapterName, chapters);
          if (previousChapterName != null) {
            await showChapterRedirectionDialog(
              previousChapterName,
              previous: true,
            );
          }
          pageController.jumpToPage(1);
        } else if (pageNumber > completeProgress) {
          String? nextChapterName =
              source.getNextChapter(chapterName, chapters);
          if (nextChapterName != null) {
            await showChapterRedirectionDialog(
              nextChapterName,
              previous: false,
            );
          }
          pageController.jumpToPage(completeProgress);
        } else {
          currentProgress.value = pageNumber;
          updateHistory();
        }
      },
    );
  }

  Future<void> showChapterRedirectionDialog(
    String newChapterName, {
    bool previous = false,
  }) async {
    Widget alertDialog = AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      content: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 16.0,
            color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
          ),
          // Note: Styles for TextSpans must be explicitly defined.
          // Child text spans will inherit styles from parent
          children: <TextSpan>[
            TextSpan(
              text: appModel.translate('viewer_chapter_current'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ': $chapterName\n'),
            (previous)
                ? TextSpan(
                    text: appModel.translate('viewer_chapter_previous'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : TextSpan(
                    text: appModel.translate('viewer_chapter_next'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
            TextSpan(text: ': $newChapterName'),
          ],
        ),
      ),
      contentPadding:
          const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
      actions: <Widget>[
        TextButton(
          child: Text(
            appModel.translate('dialog_return'),
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(
            (previous)
                ? appModel.translate('dialog_previous')
                : appModel.translate('dialog_next'),
          ),
          onPressed: () async {
            ViewerLaunchParams newParams = ViewerLaunchParams(
              appModel: appModel,
              saveHistoryItem: widget.params.saveHistoryItem,
              mediaHistoryItem: widget.params.mediaHistoryItem,
              chapters: chapters,
              chapterName: newChapterName,
              mediaSource: widget.params.mediaSource,
              fromStart: previous,
              fromEnd: !previous,
            );

            Navigator.pop(context);
            await widget.params.mediaSource.launchMediaPage(
              context,
              newParams,
              pushReplacement: true,
            );
          },
        ),
      ],
    );

    await showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  Widget buildMenuArea() {
    return Align(
      alignment: Alignment.topCenter,
      child: ValueListenableBuilder(
        valueListenable: isMenuHidden,
        builder: (BuildContext context, bool value, _) {
          return AnimatedOpacity(
            opacity: value ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: buildMenuContent(),
          );
        },
      ),
    );
  }

  Widget buildSourceButton() {
    Widget? sourceButton =
        widget.params.mediaSource.buildSourceButton(context, this);

    if (sourceButton == null) {
      return const SizedBox.shrink();
    } else {
      return sourceButton;
    }
  }

  void cancelHideTimer() {
    menuHideTimer?.cancel();
    isMenuHidden.value = false;
  }

  void startHideTimer() {
    menuHideTimer = Timer(const Duration(seconds: 3), toggleMenuVisibility);
  }

  void toggleMenuVisibility() async {
    menuHideTimer?.cancel();
    isMenuHidden.value = !isMenuHidden.value;
    if (!isMenuHidden.value) {
      startHideTimer();
    }
  }

  Widget buildCurrentPage() {
    return ValueListenableBuilder(
        valueListenable: isMenuHidden,
        builder: (BuildContext context, bool value, Widget? child) {
          return AnimatedOpacity(
            opacity: value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: ValueListenableBuilder(
              valueListenable: currentProgress,
              builder: (BuildContext context, int progress, Widget? child) {
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      bottom: 10,
                      child: Text(
                        "$progress / $completeProgress",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          foreground: Paint()
                            ..strokeWidth = 2
                            ..style = PaintingStyle.stroke
                            ..color = Colors.black.withOpacity(0.75),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      child: Text(
                        "$progress / $completeProgress",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        });
  }

  Widget buildMenuContent() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: menuHeight,
        color: menuColor,
        child: GestureDetector(
          onTap: () {
            toggleMenuVisibility();
          },
          child: AbsorbPointer(
            absorbing: isMenuHidden.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildPosition(),
                buildSlider(),
                buildSourceButton(),
                buildOptionsButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setDictionaryMessage(String messageText, {Duration? duration}) {
    searchMessage.value = messageText;
    if (duration != null) {
      Future.delayed(duration, () {
        clearDictionaryMessage();
      });
    }
  }

  void clearDictionaryMessage() {
    searchMessage.value = "";
  }

  @override
  Widget build(BuildContext context) {
    appModel = Provider.of<AppModel>(context);

    if (!isViewerReady) {
      return buildPlaceholder();
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            buildViewer(),
            buildCurrentPage(),
            buildMenuArea(),
            buildDictionary(),
          ],
        ),
      ),
    );
  }

  Widget buildPosition() {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 24.0,
        ),
        child: Row(
          children: [
            ValueListenableBuilder(
              valueListenable: currentProgress,
              builder: (BuildContext context, int progress, Widget? child) {
                return Text(
                  "$progress / $completeProgress",
                  style: TextStyle(
                    fontSize: 14.0,
                    color:
                        appModel.getIsDarkMode() ? Colors.white : Colors.black,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOptionsButton() {
    return IconButton(
      color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
      icon: const Icon(Icons.more_vert),
      onPressed: () async {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => BottomSheetDialog(
            options: getOptions(),
          ),
        );
      },
    );
  }

  void refreshDictionaryWidget() {
    String holder = searchTerm.value;
    searchTerm.value = "";
    searchTerm.value = holder;
  }

  Future<void> showChapterMenu() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        ValueNotifier<int> indexNotifier =
            ValueNotifier<int>(chapters.indexOf(chapterName));
        List<ListMenuItem> items = [];
        for (String chapter in chapters) {
          items.add(
            ListMenuItem(
              icon: Icons.book,
              label: chapter,
              action: () async {
                ViewerLaunchParams newParams = ViewerLaunchParams(
                  appModel: appModel,
                  saveHistoryItem: widget.params.saveHistoryItem,
                  mediaHistoryItem: widget.params.mediaHistoryItem,
                  chapters: chapters,
                  chapterName: chapter,
                  mediaSource: widget.params.mediaSource,
                );

                Navigator.pop(context);
                await widget.params.mediaSource.launchMediaPage(
                  context,
                  newParams,
                  pushReplacement: true,
                );
              },
            ),
          );
        }

        return ListMenu(
          items: items,
          indexNotifier: indexNotifier,
          stateCallback: () {
            setState(() {});
          },
          popOnSelect: false,
          emptyWidget: Container(),
        );
      },
    );
  }

  List<BottomSheetDialogOption> getOptions() {
    List<BottomSheetDialogOption> options = [
      BottomSheetDialogOption(
        label: appModel.translate("viewer_option_chapter_menu"),
        icon: Icons.book,
        action: () async {
          await showChapterMenu();
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("viewer_option_dictionary_menu"),
        icon: Icons.auto_stories,
        action: () async {
          await appModel.showDictionaryMenu(context, onDictionaryChange: () {
            refreshDictionaryWidget();
          });
        },
      ),
      BottomSheetDialogOption(
        label: (appModel.isViewerRightToLeft())
            ? appModel.translate("viewer_option_direction_ltr")
            : appModel.translate("viewer_option_direction_rtl"),
        icon: (appModel.isViewerRightToLeft())
            ? Icons.format_textdirection_l_to_r
            : Icons.format_textdirection_r_to_l,
        action: () async {
          await appModel.toggleViewerRightToLeft();
          cancelHideTimer();
          startHideTimer();
          setState(() {});
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("viewer_option_background_color"),
        icon: Icons.color_lens,
        action: () async {
          await showColorOptionsDialog();
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("viewer_option_share_image"),
        icon: Icons.share,
        action: () async {
          File file = await getFileFromCurrentImage();
          Share.shareFiles([file.path]);
        },
      ),
      BottomSheetDialogOption(
        label: appModel.translate("player_option_export"),
        icon: Icons.mobile_screen_share,
        action: () async {
          await openCardCreator();
        },
      ),
    ];

    return options;
  }

  Future<void> openCardCreator() async {
    File file = await getFileFromCurrentImage();
    AnkiExportParams initialParams = // todo other params
        AnkiExportParams(
      imageFile: file,
      imageFiles: [NetworkToFileImage(file: file)],
    );

    searchTerm.value = "";

    ClipboardListener.removeListener(copyClipboardAction);

    clearDictionaryMessage();

    await navigateToCreator(
      context: context,
      appModel: appModel,
      initialParams: initialParams,
      popOnExport: true,
      exportCallback: () {
        Navigator.of(context).pop();
        String lastDeck = appModel.getLastAnkiDroidDeck();
        setDictionaryMessage(
          "deckExport://$lastDeck",
          duration: const Duration(seconds: 3),
        );
      },
    );

    await Clipboard.setData(const ClipboardData(text: ""));
    ClipboardListener.addListener(copyClipboardAction);
  }

  ImageProvider<Object> getCurrentImage() {
    return sourceImages[currentProgress.value - 1];
  }

  Future<File> getFileFromCurrentImage() async {
    ImageProvider<Object> image = getCurrentImage();

    if (image is FileImage) {
      return image.file;
    }
    if (image is NetworkImage) {
      FileInfo fileInfo = await DefaultCacheManager().downloadFile(image.url);
      return fileInfo.file;
    }
    if (image is NetworkToFileImage) {
      return image.file!;
    }

    throw UnsupportedError("ImageProvider type not implemented for share");
  }

  // 'viewer_option_chapter_menu': 'Pumili ng Kabanata',
  //     'viewer_option_direction_ltr': 'Magbasa mula sa Kanan',
  //     'viewer_option_direction_rtl': 'Magbasa mula sa Kaliwa',
  //     'viewer_option_dictionary_menu': 'Pumili ng Ibang Diksunaryo',
  //     'viewer_option_background_color': 'Ibahin ang Kulay ng Likod',
  //     'viewer_option_share_image': 'Ibahagi ang Imahe na Ito',
  //     'viewer_option_export': 'Gumawa ng Card Mula sa Konteksto',

  Future<void> showColorOptionsDialog() async {
    AppModel appModel = Provider.of<AppModel>(context, listen: false);
    Color widgetColor = appModel.getViewerColorBackground();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * (2 / 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColorPicker(
                    pickerColor: widgetColor,
                    onColorChanged: (newColor) async {
                      widgetColor = newColor;
                    },
                    showLabel: true,
                    pickerAreaHeightPercent: 0.8,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                appModel.translate("dialog_close"),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                appModel.translate("dialog_set"),
              ),
              onPressed: () async {
                await appModel.setViewerColorBackground(widgetColor);
                Navigator.pop(context);
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildSlider() {
    return MultiValueListenableBuider(
        valueListenables: [
          currentProgress,
        ],
        builder: (context, values, _) {
          int currentProgress = values.elementAt(0);

          bool validPosition = completeProgress.compareTo(currentProgress) >= 0;
          double sliderValue = validPosition ? currentProgress.toDouble() : 0;

          Slider slider = Slider(
            thumbColor: Theme.of(context).focusColor,
            activeColor: Theme.of(context).focusColor,
            inactiveColor: Theme.of(context).unselectedWidgetColor,
            value: sliderValue,
            min: 0.99,
            max: completeProgress.toDouble() + 0.01,
            onChangeStart: (value) {
              cancelHideTimer();
            },
            onChangeEnd: (value) {
              startHideTimer();
            },
            onChanged: (progress) async {
              cancelHideTimer();

              int page = progress.floor();
              sliderValue = page.toDouble();
              pageController.jumpToPage(page);

              ViewerMediaSource source = widget.params.mediaSource;
              if (progress == 0.99) {
                String? previousChapterName =
                    source.getPreviousChapter(chapterName, chapters);
                if (previousChapterName != null) {
                  await showChapterRedirectionDialog(
                    previousChapterName,
                    previous: true,
                  );
                  pageController.jumpToPage(1);
                }
              } else if (progress == completeProgress.toDouble() + 0.01) {
                String? nextChapterName =
                    source.getNextChapter(chapterName, chapters);
                if (nextChapterName != null) {
                  await showChapterRedirectionDialog(
                    nextChapterName,
                    previous: false,
                  );
                }
                pageController.jumpToPage(completeProgress);
              }
            },
          );

          return Expanded(
            child: appModel.isViewerRightToLeft()
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: slider,
                  )
                : slider,
          );
        });
  }
}
