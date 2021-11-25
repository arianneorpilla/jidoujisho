import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/media/media_sources/viewer_media_source.dart';
import 'package:chisa/util/anki_creator.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:chisa/util/ocr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
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

import 'package:image/image.dart' as imglib;

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
  AnkiExportParams exportParams = AnkiExportParams();
  late AppModel appModel;

  /// Public for a [MediaSource] to edit and store session-specific details
  /// for its source button.
  Map<dynamic, dynamic> sourceOptions = {};

  final ValueNotifier<int> latestResultEntryIndex = ValueNotifier<int>(0);
  DictionarySearchResult? latestResult;

  Timer? menuHideTimer;

  PageController pageController = PageController(
    viewportFraction: 1,
  );

  late Color menuColor;
  late Color dictionaryColor;
  double menuHeight = 48;

  final ValueNotifier<bool> isMenuHidden = ValueNotifier<bool>(false);

  List<ImageProvider<Object>> sourceImages = [];
  List<ImageProvider<Object>> galleryImages = [];
  bool isViewerReady = false;

  ValueNotifier<int> currentProgress = ValueNotifier<int>(0);
  int completeProgress = 0;
  bool isDragging = false;

  List<String> chapters = [];
  String chapterName = "";

  DictionarySearchResult? searchResult;
  ValueNotifier<String> searchTerm = ValueNotifier<String>("");
  ValueNotifier<String> searchMessage = ValueNotifier<String>("");

  TextEditingController sentenceController = TextEditingController();
  FocusNode sentenceFocusNode = FocusNode();
  KeyboardVisibilityController keyboardVisibilityController =
      KeyboardVisibilityController();
  ScreenshotController screenshotController = ScreenshotController();
  late StreamSubscription<bool> visibilitySubscription;
  List<TouchPoints?> touchPoints = [];
  ValueNotifier<bool> ocrBusy = ValueNotifier<bool>(false);
  bool ocrOverlayShown = false;

  @override
  void initState() {
    super.initState();

    ClipboardListener.addListener(copyClipboardAction);

    visibilitySubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        sentenceFocusNode.unfocus();
      }
    });

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

  @override
  void dispose() async {
    ClipboardListener.removeListener(copyClipboardAction);
    pageController.dispose();
    visibilitySubscription.cancel();

    super.dispose();
  }

  Future<void> copyClipboardAction() async {
    setSearchTerm((await Clipboard.getData(Clipboard.kTextPlain))!
        .text!
        .replaceAll("￼", ""));
  }

  Future<void> processOcr(Offset a, Offset b) async {
    if (!ocrBusy.value) {
      ocrBusy.value = true;
      print("OCR START");

      Uint8List? imageBytes = await screenshotController.capture();
      imglib.Image? screenshot = imglib.decodeImage(imageBytes!)!;

      double actualWidth = MediaQuery.of(context).size.width;
      double actualHeight = MediaQuery.of(context).size.height;
      double widthRatioMultiplier = (screenshot.width / actualWidth);
      double heightRatioMultiplier = (screenshot.height / actualHeight);

      Offset scaledA = a.scale(widthRatioMultiplier, heightRatioMultiplier);
      Offset scaledB = b.scale(widthRatioMultiplier, heightRatioMultiplier);
      Rect rect = Rect.fromPoints(scaledA, scaledB);

      imglib.Image croppedImage = imglib.copyCrop(
        screenshot,
        rect.left.round(),
        rect.top.round(),
        rect.width.round(),
        rect.height.round(),
      );
      List<int> croppedImageBytes = imglib.writeJpg(croppedImage);

      final tempDir = await getTemporaryDirectory();
      DateTime now = DateTime.now();
      File file = File('${tempDir.path}/${now.millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(croppedImageBytes);

      print("CROPPED IMAGE WRITTEN");

      final textDetector = GoogleMlKit.vision.textDetectorV2();
      RecognisedText recognisedText = await textDetector.processImage(
          InputImage.fromFile(file),
          script: TextRecognitionOptions.JAPANESE);

      setState(() {
        ocrBusy.value = false;
        ocrOverlayShown = false;
        touchPoints.clear();
      });

      print(recognisedText);
      recognisedText.blocks.forEach((block) {
        print(block.cornerPoints);
        print(block.lines);
        print(block.rect);
        print(block.text);
      });
    } else {
      print("OCR IS BUSY -- WAITING TO FINISH");
    }
  }

  Widget buildScanButton() {
    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: ocrBusy,
          builder: (context, busy, child) {
            if (busy) {
              return SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(
                    appModel.getIsDarkMode() ? Colors.white : Colors.black,
                  ),
                ),
              );
            } else {
              return IconButton(
                color: appModel.getIsDarkMode() ? Colors.white : Colors.black,
                icon: (ocrOverlayShown)
                    ? const Icon(Icons.highlight_remove)
                    : const Icon(Icons.qr_code_sharp),
                onPressed: () async {
                  setState(() {
                    touchPoints.clear();
                    ocrOverlayShown = !ocrOverlayShown;
                  });
                },
              );
            }
          },
        ),
      ),
    );
  }

  void promptTimerOcr(Offset a, Offset b) {
    Future.delayed(const Duration(seconds: 1), () {
      if (touchPoints.isNotEmpty) {
        if (touchPoints[0]!.points == a && touchPoints[1]!.points == b) {
          processOcr(a, b);
        }
      }
    });
  }

  Widget buildOcrOverlay() {
    return GestureDetector(
      child: CustomPaint(
        size: Size.infinite,
        painter: OcrBoxPainter(
          pointsList: touchPoints,
          defaultPaint: ocrOverlayPaint,
          coordsCallback: promptTimerOcr,
        ),
      ),
      onPanStart: (details) {
        setState(() {
          touchPoints.clear();
          final container = context.findRenderObject() as RenderBox;
          touchPoints.add(
            TouchPoints(
              points: container.globalToLocal(details.globalPosition),
              paint: ocrOverlayPaint,
            ),
          );
        });
      },
      onPanUpdate: (details) {
        setState(() {
          final container = context.findRenderObject() as RenderBox;
          touchPoints = [touchPoints.first];
          touchPoints.add(
            TouchPoints(
              points: container.globalToLocal(details.globalPosition),
              paint: ocrOverlayPaint,
            ),
          );
        });
      },
      onPanEnd: (details) {
        setState(() {
          touchPoints.add(null);
        });
      },
    );
  }

  Paint ocrOverlayPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true
    ..color = Colors.black.withOpacity(0.6)
    ..strokeWidth = 3.0;

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
            onPressed: () async {
              Wakelock.disable();
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);

              Navigator.of(context).popUntil((route) => route.isFirst);
            }),
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

    sourceImages = await source.getCachedImages(item, chapterName);
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

    updateHistory();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      pageController.jumpToPage(currentProgress.value);
    });
  }

  void setSearchTerm(String newTerm) {
    latestResult = null;
    searchTerm.value = newTerm.trim();
  }

  MediaHistoryItem? generateContextHistoryItem() {
    if (!widget.params.saveHistoryItem) {
      return null;
    }

    MediaHistoryItem item = widget.params.mediaHistoryItem;
    item.currentProgress = currentProgress.value;
    item.completeProgress = completeProgress;
    item = widget.params.mediaSource
        .setChapterPageProgress(item, chapterName, currentProgress.value);
    item = widget.params.mediaSource
        .setChapterPageTotal(item, chapterName, completeProgress);
    item = widget.params.mediaSource.setCurrentChapterName(item, chapterName);
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
                    if (!snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.waiting) {
                      return buildDictionarySearching();
                    }

                    latestResult = snapshot.data;

                    if (!snapshot.hasData || latestResult!.entries.isEmpty) {
                      return buildDictionaryNoMatch();
                    } else {
                      return buildDictionaryMatch();
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
    item.completeProgress = completeProgress;
    item = widget.params.mediaSource
        .setChapterPageProgress(item, chapterName, currentProgress.value);
    item = widget.params.mediaSource
        .setChapterPageTotal(item, chapterName, completeProgress);
    item = widget.params.mediaSource.setCurrentChapterName(item, chapterName);
    item.extra["chapters"] = chapters;

    if (item.completeProgress != 0) {
      if (!appModel.getIncognitoMode()) {
        await history.addItem(item);
      }
    }
  }

  bool isDialogBusy = false;

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
      gaplessPlayback: true,
      backgroundDecoration:
          BoxDecoration(color: appModel.getViewerColorBackground()),
      scrollPhysics: const PageScrollPhysics(),
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
          if (!isDragging) {
            await updateHistory();
          }
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
              pushReplacement: true,
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

    if (!isDialogBusy) {
      isDialogBusy = true;
      await showDialog(
        context: context,
        builder: (context) => alertDialog,
      );
      isDialogBusy = false;
    }
  }

  Widget buildSearchArea() {
    return Align(
      alignment: Alignment.topCenter,
      child: ValueListenableBuilder(
        valueListenable: isMenuHidden,
        builder: (BuildContext context, bool value, _) {
          return AnimatedOpacity(
            opacity: value ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: buildSearchContent(),
          );
        },
      ),
    );
  }

  AnkiExportParams getExportParams() {
    return exportParams;
  }

  void setExportParams(AnkiExportParams newParams, {AnkiExportField? field}) {
    sentenceController.text = exportParams.sentence;
  }

  List<Widget> getFieldEnhancementWidgets(
      {required BuildContext context, required AnkiExportField field}) {
    List<Widget> widgets = [];
    List<AnkiExportEnhancement?> enhancements =
        appModel.getExportEnabledFieldEnhancement(field);

    for (int position = 0; position < enhancements.length; position++) {
      AnkiExportEnhancement? enhancement = enhancements[position];
      if (enhancement == null) {
        continue;
      }

      widgets.add(
        enhancement.getButton(
          context: context,
          paramsCallback: getExportParams,
          updateCallback: setExportParams,
          autoMode: false,
          editMode: false,
          position: position,
        ),
      );
    }

    return widgets;
  }

  Widget buildSentenceField({
    TextInputType keyboardType = TextInputType.multiline,
  }) {
    AnkiExportField field = AnkiExportField.sentence;

    return TextFormField(
      minLines: 1,
      maxLines: 5,
      controller: sentenceController,
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).unselectedWidgetColor.withOpacity(0.5)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).focusColor),
        ),
        prefixIcon: Icon(field.icon(appModel)),
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: getFieldEnhancementWidgets(context: context, field: field),
        ),
      ),
      keyboardType: keyboardType,
      focusNode: sentenceFocusNode,
    );
  }

  Widget buildMenuArea() {
    return Align(
      alignment: Alignment.bottomCenter,
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

  void toggleMenuVisibility() async {
    isMenuHidden.value = !isMenuHidden.value;
    sentenceFocusNode.unfocus();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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

  Widget buildSearchContent() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: menuColor,
        child: GestureDetector(
          onTap: () {
            toggleMenuVisibility();
          },
          child: AbsorbPointer(
            absorbing: isMenuHidden.value,
            child: buildSentenceField(),
          ),
        ),
      ),
    );
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
                buildScanButton(),
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
        backgroundColor: appModel.getViewerColorBackground(),
        body: Screenshot(
          controller: screenshotController,
          child: Stack(
            children: <Widget>[
              buildViewer(),
              if (ocrOverlayShown) buildOcrOverlay(),
              buildCurrentPage(),
              buildMenuArea(),
              buildSearchArea(),
              Padding(
                padding: const EdgeInsets.only(
                  top: 60,
                  bottom: 60,
                ),
                child: buildDictionary(),
              ),
            ],
          ),
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

  List<BottomSheetDialogOption> getOptions() {
    List<BottomSheetDialogOption> options = [
      BottomSheetDialogOption(
        label: appModel.translate("viewer_option_chapter_menu"),
        icon: Icons.book,
        action: () async {
          await widget.params.mediaSource.showChapterMenu(
            context: context,
            item: widget.params.mediaHistoryItem,
            actions: [],
            pushReplacement: true,
          );
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
              isDragging = true;
            },
            onChangeEnd: (value) async {
              isDragging = false;
              await updateHistory();
            },
            onChanged: (progress) async {
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
