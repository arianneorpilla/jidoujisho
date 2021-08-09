import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

import 'package:chewie/chewie.dart';
import 'package:clipboard_monitor/clipboard_monitor.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imglib;
import 'package:jidoujisho/main.dart';
import 'package:jidoujisho/selection.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jidoujisho/util.dart';
import 'package:jidoujisho/cache.dart';
import 'package:jidoujisho/dictionary.dart';
import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/pitch.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:ve_dart/ve_dart.dart';

class Viewer extends StatefulWidget {
  Viewer(
    this.chapter, {
    this.fromEnd = false,
    this.fromStart = false,
    this.initialPage,
  });

  final MangaChapter chapter;
  final bool fromEnd;
  final bool fromStart;
  final int initialPage;

  @override
  State<Viewer> createState() => ViewerState(
        this.chapter,
        this.fromEnd,
        this.fromStart,
        this.initialPage,
      );
}

class ViewerState extends State<Viewer> {
  ViewerState(
    this.chapter,
    this.fromEnd,
    this.fromStart,
    this.initialPage,
  );

  final _clipboard = ValueNotifier<String>("");
  final _currentDictionaryEntry = ValueNotifier<DictionaryEntry>(
    DictionaryEntry(
      word: "",
      reading: "",
      meaning: "",
    ),
  );

  final MangaChapter chapter;
  final bool fromEnd;
  final bool fromStart;
  final int initialPage;

  ValueNotifier<bool> _hideStuff = ValueNotifier<bool>(false);
  String workingText = "";

  ScreenshotController screenshotController = ScreenshotController();
  PageController pageController;

  List<ImageProvider> images;
  ValueNotifier<int> currentPage;
  Uint8List croppedImage;

  String highlightedText = "";
  List<String> recursiveTerms = [];
  bool noPush = false;

  bool ocrBusy = false;
  bool ocrOverlayShown = false;
  List<TouchPoints> touchPoints = [];

  TextEditingController _sentenceController = TextEditingController(text: "");
  FocusNode workingAreaNode = FocusNode();
  final double barHeight = 48;

  int onHideSubscriberId;
  int onChangeSubscriberId;

  bool editingWorkArea = false;

  bool ocrDialogVisible = false;

  bool isExporting = false;

  @override
  void dispose() {
    stopAllClipboardMonitoring();
    KeyboardVisibilityNotification().removeListener(onHideSubscriberId);
    KeyboardVisibilityNotification().removeListener(onChangeSubscriberId);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    onHideSubscriberId =
        KeyboardVisibilityNotification().addNewListener(onHide: () {
      workingAreaNode.unfocus();
    });
    onChangeSubscriberId =
        KeyboardVisibilityNotification().addNewListener(onChange: (visible) {
      editingWorkArea = visible;
    });

    currentPage = ValueNotifier<int>(chapter.getMangaPageProgress());

    if (currentPage.value <= 0 ||
        currentPage.value > chapter.getImages().length) {
      currentPage.value = 1;
    }

    if (fromEnd) {
      currentPage.value = 1;
    }
    if (fromStart) {
      currentPage.value = chapter.getImages().length;
    }
    if (initialPage != null) {
      currentPage.value = initialPage;
    }

    pageController = PageController(initialPage: currentPage.value);

    chapter.setMangaPageProgress(currentPage.value);
    chapter.getManga().setLastChapterRead(chapter);

    setLastReadMangaDirectory(chapter.directory.path);
    setLastReadMangaPosition(currentPage.value);
    setLastMediaType(MediaType.manga);

    images = [];
    images.add(MemoryImage(kTransparentImage));
    images.addAll(chapter.getImages());
    images.add(MemoryImage(kTransparentImage));
  }

  void startClipboardMonitor() {
    ClipboardMonitor.registerCallback(onClipboardText);
  }

  void stopClipboardMonitor() {
    ClipboardMonitor.unregisterCallback(onClipboardText);
  }

  void onClipboardText(String text) {
    emptyStack();
    if (!editingWorkArea && !ocrDialogVisible && !isExporting) {
      ocrDialogVisible = true;
      showOCRHelperDialog(text).then((result) {
        ocrDialogVisible = false;
      });
    } else {
      if (!ocrDialogVisible && !isExporting) {
        _clipboard.value = text;
      }
    }
  }

  // Future<void> processOcr(Offset a, Offset b) async {
  //   if (!ocrBusy) {
  //     ocrBusy = true;
  //     print("OCR START");

  //     Uint8List imageBytes = await screenshotController.capture();
  //     imglib.Image screenshot = imglib.decodeImage(imageBytes);

  //     double actualWidth = MediaQuery.of(context).size.width;
  //     double actualHeight = MediaQuery.of(context).size.height;
  //     double widthRatioMultiplier = (screenshot.width / actualWidth);
  //     double heightRatioMultiplier = (screenshot.height / actualHeight);

  //     Offset scaledA = a.scale(widthRatioMultiplier, heightRatioMultiplier);
  //     Offset scaledB = b.scale(widthRatioMultiplier, heightRatioMultiplier);
  //     Rect rect = Rect.fromPoints(scaledA, scaledB);

  //     imglib.Image croppedImage = imglib.copyCrop(
  //       screenshot,
  //       rect.left.round(),
  //       rect.top.round(),
  //       rect.width.round(),
  //       rect.height.round(),
  //     );
  //     List<int> croppedImageBytes = imglib.writeJpg(croppedImage);

  //     // File cropTest = File("storage/emulated/0/Download/cropTest.jpg");
  //     // cropTest.createSync(recursive: true);
  //     // cropTest.writeAsBytesSync(croppedImageBytes);
  //     print("CROPPED IMAGE WRITTEN");

  //     processOcrTextFromBytes(croppedImageBytes).then((result) {
  //       setState(() {
  //         ocrBusy = false;
  //         ocrOverlayShown = false;
  //         touchPoints.clear();
  //       });

  //       print("OCR COMPLETE -- RESULT");

  //       print(result);

  //       print("OCR REORDERED OUTPUT");
  //       print(reorderOcrVerticalText(result));
  //       print("OCR END");
  //     });
  //   } else {
  //     print("OCR IS BUSY -- WAITING TO FINISH");
  //   }
  // }

  Paint ocrOverlayPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true
    ..color = Colors.black.withOpacity(0.6)
    ..strokeWidth = 3.0;

  @override
  Widget build(BuildContext context) {
    startClipboardMonitor();

    return new WillPopScope(
      onWillPop: () async {
        Widget alertDialog = AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          title: new Text('Exit Viewer?'),
          actions: <Widget>[
            new TextButton(
              child: Text(
                'NO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            new TextButton(
              child: Text(
                'YES',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );

        return (await showDialog(
              context: context,
              builder: (context) => alertDialog,
            )) ??
            false;
      },
      child: new Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Screenshot(
            controller: screenshotController,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                buildGallery(),
                buildCurrentPage(),
                buildBottomBar(context),
                buildTopBar(context),
                Padding(
                  padding: EdgeInsets.only(
                    top: 60,
                    bottom: 60,
                  ),
                  child: buildDictionary(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // void promptTimerOcr(Offset a, Offset b) {
  //   Future.delayed(Duration(seconds: 1), () {
  //     if (touchPoints[0].points == a && touchPoints[1].points == b) {
  //       processOcr(a, b);
  //     }
  //   });
  // }

  Widget sentenceField() {
    return TextFormField(
      selectionControls:
          CustomTextSelectionControls(customButton: (selectedValue) {
        _clipboard.value = "&&jidoujisho-kaku-bypass&&$selectedValue";
      }),
      minLines: 1,
      maxLines: 5,
      keyboardType: TextInputType.multiline,
      controller: _sentenceController,
      focusNode: workingAreaNode,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(16.0),
        prefixIcon: Icon(Icons.format_align_center_rounded),
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 18,
              onPressed: () {
                _hideStuff.value = false;
                _clipboard.value = _sentenceController.text;
              },
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            if (gIsTapToSelectSupported)
              IconButton(
                iconSize: 18,
                onPressed: () {
                  if (_sentenceController.text.trim().isNotEmpty) {
                    showSentenceDialog(_sentenceController.text);
                  }
                },
                icon: Icon(
                  Icons.account_tree_outlined,
                  color: Colors.white,
                ),
              ),
            IconButton(
              iconSize: 18,
              onPressed: () {
                _hideStuff.value = false;
                _sentenceController.clear();
              },
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSentenceDialog(String sentence) {
    sentence = sentence.trim();

    List<Word> segments = parseVe(gMecabTagger, sentence);
    List<String> words = [];
    segments.forEach((segment) => words.add(segment.word));

    ValueNotifier<List<bool>> indexesSelected = ValueNotifier<List<bool>>(
      List.generate(
        words.length,
        (index) => false,
      ),
    );
    List<Widget> textWidgets = getTextWidgetsFromWords(words, indexesSelected);

    ScrollController scrollController = ScrollController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding:
              EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          content: ValueListenableBuilder(
            valueListenable: indexesSelected,
            builder: (BuildContext context, List<bool> _, Widget widget) {
              return Container(
                child: Container(
                  color: Colors.grey[800].withOpacity(0.6),
                  child: RawScrollbar(
                    thumbColor: Colors.grey[600],
                    controller: scrollController,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Wrap(children: textWidgets),
                    ),
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('REPLACE', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (indexesSelected.value.every((selected) => false)) {
                  _sentenceController.text = sentence;
                } else {
                  String wordsJoined = "";

                  for (int i = 0; i < words.length; i++) {
                    if (indexesSelected.value[i]) {
                      wordsJoined += words[i];
                    }
                  }

                  _sentenceController.text = wordsJoined;
                }

                _hideStuff.value = false;
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('SEARCH', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                emptyStack();

                if (indexesSelected.value.every((selected) => false)) {
                  _clipboard.value = sentence;
                } else {
                  String wordsJoined = "";

                  for (int i = 0; i < words.length; i++) {
                    if (indexesSelected.value[i]) {
                      wordsJoined += words[i];
                    }
                  }

                  _clipboard.value = wordsJoined;
                }
                _hideStuff.value = false;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showOCRHelperDialog(String sentence) async {
    ValueNotifier<List<bool>> indexesSelected;
    List<Widget> textWidgets;
    List<String> words = [];

    if (gIsTapToSelectSupported) {
      List<Word> segments = parseVe(gMecabTagger, sentence);
      segments.forEach((segment) => words.add(segment.word));

      indexesSelected = ValueNotifier<List<bool>>(
        List.generate(
          words.length,
          (index) => false,
        ),
      );
      textWidgets = getTextWidgetsFromWords(words, indexesSelected);
    }

    ScrollController scrollController = ScrollController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding:
              EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          title: (gIsTapToSelectSupported)
              ? ValueListenableBuilder(
                  valueListenable: indexesSelected,
                  builder: (BuildContext context, List<bool> _, Widget widget) {
                    return Container(
                      child: Container(
                        color: Colors.grey[800].withOpacity(0.6),
                        child: RawScrollbar(
                          thumbColor: Colors.grey[600],
                          controller: scrollController,
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Wrap(children: textWidgets),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Text(sentence),
          actions: <Widget>[
            TextButton(
              child: Text('SEARCH', style: TextStyle(color: Colors.white)),
              onPressed: () {
                emptyStack();

                if (!gIsTapToSelectSupported ||
                    indexesSelected.value
                        .every((selected) => selected == false)) {
                  _clipboard.value = sentence;
                } else {
                  String wordsJoined = "";

                  for (int i = 0; i < words.length; i++) {
                    if (indexesSelected.value[i]) {
                      wordsJoined += words[i];
                    }
                  }

                  _clipboard.value = wordsJoined;
                }
                _hideStuff.value = false;
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('REPLACE', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (!gIsTapToSelectSupported ||
                    indexesSelected.value
                        .every((selected) => selected == false)) {
                  _sentenceController.text = sentence;
                } else {
                  String wordsJoined = "";

                  for (int i = 0; i < words.length; i++) {
                    if (indexesSelected.value[i]) {
                      wordsJoined += words[i];
                    }
                  }

                  _sentenceController.text = wordsJoined;
                }

                _hideStuff.value = false;
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('APPEND', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                if (!gIsTapToSelectSupported ||
                    indexesSelected.value
                        .every((selected) => selected == false)) {
                  _sentenceController.text += sentence;
                } else {
                  String wordsJoined = "";

                  for (int i = 0; i < words.length; i++) {
                    if (indexesSelected.value[i]) {
                      wordsJoined += words[i];
                    }
                  }

                  _sentenceController.text += wordsJoined;
                }

                _hideStuff.value = false;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Widget buildOcrOverlay() {
  //   return GestureDetector(
  //     child: CustomPaint(
  //       size: Size.infinite,
  //       painter: OcrBoxPainter(
  //         pointsList: touchPoints,
  //         defaultPaint: ocrOverlayPaint,
  //         coordsCallback: promptTimerOcr,
  //       ),
  //     ),
  //     onPanStart: (details) {
  //       setState(() {
  //         touchPoints.clear();
  //         RenderBox renderBox = context.findRenderObject();
  //         touchPoints.add(
  //           TouchPoints(
  //             points: renderBox.globalToLocal(details.globalPosition),
  //             paint: ocrOverlayPaint,
  //           ),
  //         );
  //       });
  //     },
  //     onPanUpdate: (details) {
  //       setState(() {
  //         RenderBox renderBox = context.findRenderObject();
  //         touchPoints = [touchPoints.first];
  //         touchPoints.add(
  //           TouchPoints(
  //             points: renderBox.globalToLocal(details.globalPosition),
  //             paint: ocrOverlayPaint,
  //           ),
  //         );
  //       });
  //     },
  //     onPanEnd: (details) {
  //       setState(() {
  //         touchPoints.add(null);
  //       });
  //     },
  //   );
  // }

  Future showChapterRedirectionDialog(MangaChapter redirectChapter,
      {previous = false}) async {
    Widget alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      content: RichText(
        text: TextSpan(
          style: new TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
          // Note: Styles for TextSpans must be explicitly defined.
          // Child text spans will inherit styles from parent
          children: <TextSpan>[
            TextSpan(
                text: 'Current',
                style: new TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ': ${chapter.getChapterName()}\n'),
            (previous)
                ? TextSpan(
                    text: 'Previous',
                    style: new TextStyle(fontWeight: FontWeight.bold))
                : TextSpan(
                    text: 'Next',
                    style: new TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ': ${redirectChapter.getChapterName()}'),
          ],
        ),
      ),
      contentPadding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
      actions: <Widget>[
        new TextButton(
          child: Text(
            'BACK',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextButton.styleFrom(
            textStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        new TextButton(
          child: Text(
            (previous) ? 'PREVIOUS' : 'NEXT',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextButton.styleFrom(
            textStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: () async {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Viewer(
                  redirectChapter,
                  fromEnd: !previous,
                  fromStart: previous,
                ),
              ),
            );
          },
        ),
      ],
    );

    return (await showDialog(
          context: context,
          builder: (context) => alertDialog,
        )) ??
        false;
  }

  Widget buildCurrentPage() {
    return ValueListenableBuilder(
        valueListenable: _hideStuff,
        builder: (BuildContext context, bool value, Widget child) {
          return AnimatedOpacity(
            opacity: value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: ValueListenableBuilder(
              valueListenable: currentPage,
              builder: (BuildContext context, int value, Widget child) {
                return Container(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned(
                        bottom: 10,
                        child: Text(
                          "$value / ${images.length - 2}",
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
                          "$value / ${images.length - 2}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
  }

  Widget buildGallery() {
    return PhotoViewGallery.builder(
      reverse: true,
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: images[index],
          initialScale: PhotoViewComputedScale.contained * 1,
          minScale: PhotoViewComputedScale.contained * 1,
          maxScale: PhotoViewComputedScale.contained * 6,
          filterQuality: FilterQuality.high,
          onTapDown: (context, details, value) async {
            _hideStuff.value = !_hideStuff.value;
            workingAreaNode.unfocus();
          },
        );
      },
      scrollPhysics: BouncingScrollPhysics(),
      itemCount: images.length,
      loadingBuilder: (context, event) => Center(
        child: Container(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / event.expectedTotalBytes,
          ),
        ),
      ),
      pageController: pageController,
      onPageChanged: (pageNumber) async {
        if (pageNumber <= 0) {
          MangaChapter previous = chapter.getPreviousChapter();
          if (previous != null) {
            await showChapterRedirectionDialog(previous, previous: true);
          }
          pageController.jumpToPage(1);
        } else if (pageNumber > images.length - 2) {
          MangaChapter next = chapter.getNextChapter();
          if (next != null) {
            await showChapterRedirectionDialog(next, previous: false);
          }
          pageController.jumpToPage(images.length - 2);
        } else {
          currentPage.value = pageNumber;
          chapter.setMangaPageProgress(pageNumber);
          chapter.getManga().setLastChapterRead(chapter);
          setLastReadMangaDirectory(chapter.directory.path);
          setLastReadMangaPosition(currentPage.value);
          setLastMediaType(MediaType.manga);
        }
      },
    );
  }

  Widget buildTopBar(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ValueListenableBuilder(
        valueListenable: _hideStuff,
        builder: (BuildContext context, bool value, Widget child) {
          return AnimatedOpacity(
            opacity: value ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              color: Theme.of(context).dialogBackgroundColor.withOpacity(0.8),
              child: sentenceField(),
            ),
          );
        },
      ),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    final iconColor = Theme.of(context).textTheme.button.color;

    return ValueListenableBuilder(
        valueListenable: _hideStuff,
        builder: (BuildContext context, bool value, Widget child) {
          return AnimatedOpacity(
              opacity: _hideStuff.value ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                height: barHeight,
                color: Theme.of(context).dialogBackgroundColor.withOpacity(0.8),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 24),
                    _buildPosition(iconColor),
                    _buildProgressBar(),
                    //_buildScanButton(),
                    _buildMoreButton(),
                    // _buildToolsButton(controller),
                    // _buildMoreButton(controller),
                  ],
                ),
              ));
        });
  }

  Widget _buildPosition(Color iconColor) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(
          right: 24.0,
        ),
        child: Row(
          children: [
            ValueListenableBuilder(
              valueListenable: currentPage,
              builder: (BuildContext context, int value, Widget child) {
                return Text(
                  "$value / ${images.length - 2}",
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: MangaProgressBar(
          currentPage,
          images.length - 2,
          pageController,
          colors: ChewieProgressColors(
            playedColor: Colors.grey,
            handleColor: Colors.red,
            backgroundColor: Colors.red,
            bufferedColor: Colors.red[200],
          ),
        ),
      ),
    );
  }

  // GestureDetector _buildScanButton() {
  //   return GestureDetector(
  //     onTap: () {
  //       setState(() {
  //         touchPoints.clear();
  //         ocrOverlayShown = !ocrOverlayShown;
  //       });
  //     },
  //     child: Container(
  //       height: barHeight,
  //       color: Colors.transparent,
  //       margin: const EdgeInsets.only(left: 4.0, right: 8.0),
  //       child: (ocrOverlayShown)
  //           ? Icon(Icons.highlight_remove)
  //           : Icon(Icons.qr_code_sharp),
  //     ),
  //   );
  // }

  Widget _buildMoreButton() {
    return GestureDetector(
      onTap: () async {
        final chosenOption = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => _MoreOptionsDialog(
            options: [
              "Open Chapter Navigation Menu",
              if (getOcrHorizontalMode())
                "Use Vertical Text Recognition"
              else
                "Use Horizontal Text Recognition",
              "Select Active Dictionary Source",
              "Share Links to Applications",
              "Export Current Context to Anki",
            ],
            icons: [
              Icons.menu_book,
              if (getOcrHorizontalMode())
                Icons.text_rotate_vertical
              else
                Icons.text_rotation_none,
              Icons.auto_stories,
              Icons.share_outlined,
              Icons.mobile_screen_share_rounded,
            ],
            highlights: [],
            invisibles: [1],
          ),
        );

        switch (chosenOption) {
          case 0:
            chapter.getManga().openMangaMenu(context, () {}, inViewer: true);
            break;
          case 1:
            toggleOcrHorizontalMode();
            break;
          case 2:
            openDictionaryMenu(context, false);
            final String clipboardMemory = _clipboard.value;
            _clipboard.value = "";
            setNoPush();
            _clipboard.value = clipboardMemory;
            break;
          case 3:
            openExtraShare();
            break;
          case 4:
            FileImage fileImage = images[currentPage.value];

            stopClipboardMonitor();
            isExporting = true;

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Home(
                  readerExport: CreatorExportInformation(
                    initialSentence: _sentenceController.text,
                    initialFile: fileImage.file,
                    dictionaryEntry: _currentDictionaryEntry.value,
                  ),
                ),
              ),
            ).then((result) {
              isExporting = false;
              _sentenceController.clear();
              _currentDictionaryEntry.value = DictionaryEntry(
                word: "",
                meaning: "",
                reading: "",
              );

              SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
              if (result != null && result) {
                _clipboard.value = "&<&>exported&<&>";
                Future.delayed(Duration(seconds: 2), () {
                  _clipboard.value = "";
                });
              } else {
                _clipboard.value = "";
              }
              startClipboardMonitor();
            });

            break;
        }
      },
      child: ClipRect(
        child: Container(
          height: barHeight,
          padding: const EdgeInsets.only(
            left: 12.0,
            right: 16.0,
          ),
          child: const Icon(Icons.more_vert),
        ),
      ),
    );
  }

  Future<void> openExtraShare() async {
    final chosenOption = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => _MoreOptionsDialog(
        options: const [
          "Search Text with Jisho.org",
          "Translate Text with DeepL",
          "Translate Text with Google Translate",
          "Share Text with Menu",
          "Share Current Image",
        ],
        icons: const [
          Icons.menu_book_rounded,
          Icons.translate_rounded,
          Icons.g_translate_rounded,
          Icons.share_outlined,
          Icons.photo,
        ],
        highlights: [],
        invisibles: (images[currentPage.value] is FileImage) ? [] : [4],
      ),
    );

    switch (chosenOption) {
      case 0:
        await launch("https://jisho.org/search/$workingText");
        break;
      case 1:
        await launch("https://www.deepl.com/translator#ja/en/$workingText");
        break;
      case 2:
        await launch(
            "https://translate.google.com/?sl=ja&tl=en&text=$workingText&op=translate");
        break;
      case 3:
        Share.share(workingText);
        break;
      case 4:
        FileImage fileImage = images[currentPage.value];
        Share.shareFiles([fileImage.file.path], text: " ");
        break;
    }
  }

  void emptyStack() {
    noPush = false;
    recursiveTerms = [];
  }

  void setNoPush() {
    noPush = true;
  }

  void stopAllClipboardMonitoring() {
    ClipboardMonitor.unregisterAllCallbacks();
  }

  Widget buildDictionaryLoading(String clipboard) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[600].withOpacity(0.97),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    text: '',
                    children: <InlineSpan>[
                      TextSpan(
                        text: "Looking up",
                      ),
                      TextSpan(
                        text: "『",
                        style: TextStyle(
                          color: Colors.grey[300],
                        ),
                      ),
                      TextSpan(
                        text: clipboard,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "』",
                        style: TextStyle(
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 12,
                  width: 12,
                  child: JumpingDotsProgressIndicator(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryExporting(String clipboard) {
    String lookupText = "Preparing to export";

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[600].withOpacity(0.97),
            child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(lookupText),
                  SizedBox(
                    height: 12,
                    width: 12,
                    child: JumpingDotsProgressIndicator(color: Colors.white),
                  ),
                ]),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryAutoGenDependencies(String clipboard) {
    String lookupText = "Setting up required dependencies";

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[600].withOpacity(0.97),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(lookupText),
                SizedBox(
                  height: 12,
                  width: 12,
                  child: JumpingDotsProgressIndicator(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryNetworkSubtitlesBad(String clipboard) {
    String lookupText = "Unable to query subtitles over network stream.";
    Future.delayed(Duration(seconds: 1), () {
      _clipboard.value = "";
    });

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[600].withOpacity(0.97),
            child: Text(lookupText),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryNetworkSubtitlesRequest(String clipboard) {
    String lookupText = "Requesting subtitles over network stream";

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[600].withOpacity(0.97),
            child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(lookupText),
                  SizedBox(
                    height: 12,
                    width: 12,
                    child: JumpingDotsProgressIndicator(color: Colors.white),
                  ),
                ]),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryAutoGenBad(String clipboard) {
    String lookupText = "Unable to query for automatic captions.";
    Future.delayed(Duration(seconds: 1), () {
      _clipboard.value = "";
    });

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[600].withOpacity(0.97),
            child: Text(lookupText),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryAutoGenQuery(String clipboard) {
    String lookupText = "Querying for automatic captions";

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[600].withOpacity(0.97),
            child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(lookupText),
                  SizedBox(
                    height: 12,
                    width: 12,
                    child: JumpingDotsProgressIndicator(color: Colors.white),
                  ),
                ]),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryExported(String clipboard) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[800].withOpacity(0.6),
            child: Text.rich(
              TextSpan(
                text: '',
                children: <InlineSpan>[
                  TextSpan(
                    text: "Card exported to",
                  ),
                  TextSpan(
                    text: "『",
                    style: TextStyle(
                      color: Colors.grey[300],
                    ),
                  ),
                  TextSpan(
                    text: getLastDeck(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "』",
                    style: TextStyle(
                      color: Colors.grey[300],
                    ),
                  ),
                  TextSpan(
                    text: "deck.",
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryNoMatch(String clipboard) {
    switch (getCurrentDictionary()) {
      case "Jisho.org API":
        gBilingualSearchCache[clipboard] = null;
        break;
      case "Sora Dictionary API":
        gMonolingualSearchCache[clipboard] = null;
        break;
      default:
        gCustomDictionarySearchCache[getCurrentDictionary()][clipboard] = null;
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () {
              _clipboard.value = "";
              _currentDictionaryEntry.value = DictionaryEntry(
                word: "",
                reading: "",
                meaning: "",
              );
            },
            child: GestureDetector(
              onLongPress: () {
                openDictionaryMenu(context, false);
              },
              onVerticalDragEnd: (details) async {
                if (details.primaryVelocity == 0) return;
                if (details.primaryVelocity.compareTo(0) == -1) {
                  await setNextDictionary();
                } else {
                  await setPrevDictionary();
                }
              },
              child: Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.grey[600].withOpacity(0.97),
                child: Text.rich(
                  TextSpan(
                    text: '',
                    children: <InlineSpan>[
                      TextSpan(
                        text: "No matches for",
                      ),
                      TextSpan(
                        text: "『",
                        style: TextStyle(
                          color: Colors.grey[300],
                        ),
                      ),
                      TextSpan(
                        text: clipboard,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "』",
                        style: TextStyle(
                          color: Colors.grey[300],
                        ),
                      ),
                      TextSpan(
                        text: "could be queried.",
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryMatch(DictionaryHistoryEntry results) {
    if (noPush) {
      noPush = false;
    } else if (recursiveTerms.isEmpty ||
        results.searchTerm != recursiveTerms.last) {
      recursiveTerms.add(results.searchTerm);
    }

    ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

    return ValueListenableBuilder(
      valueListenable: selectedIndex,
      builder: (BuildContext context, int _, Widget widget) {
        _currentDictionaryEntry.value = results.entries[selectedIndex.value];
        DictionaryEntry pitchEntry =
            getClosestPitchEntry(_currentDictionaryEntry.value);

        addDictionaryEntryToHistory(
          DictionaryHistoryEntry(
            entries: results.entries,
            searchTerm: results.searchTerm,
            swipeIndex: selectedIndex.value,
            contextDataSource: results.contextDataSource,
            contextPosition: results.contextPosition,
            dictionarySource: results.dictionarySource,
          ),
        );

        return Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () {
              _clipboard.value = "";
              _currentDictionaryEntry.value = DictionaryEntry(
                word: "",
                reading: "",
                meaning: "",
              );
            },
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity == 0) return;

              if (details.primaryVelocity.compareTo(0) == -1) {
                if (selectedIndex.value == results.entries.length - 1) {
                  selectedIndex.value = 0;
                } else {
                  selectedIndex.value += 1;
                }
              } else {
                if (selectedIndex.value == 0) {
                  selectedIndex.value = results.entries.length - 1;
                } else {
                  selectedIndex.value -= 1;
                }
              }
            },
            onVerticalDragEnd: (details) async {
              if (details.primaryVelocity == 0) return;
              if (details.primaryVelocity.compareTo(0) == -1) {
                await setNextDictionary();
              } else {
                await setPrevDictionary();
              }
            },
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[600].withOpacity(0.97),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onLongPress: () {
                      openDictionaryMenu(context, false);
                    },
                    child: Text(
                      results.entries[selectedIndex.value].word,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  GestureDetector(
                    onLongPress: () {
                      openDictionaryMenu(context, false);
                    },
                    child: (pitchEntry != null)
                        ? getAllPitchWidgets(pitchEntry)
                        : Text(results.entries[selectedIndex.value].reading),
                  ),
                  if (results
                      .entries[selectedIndex.value].yomichanTermTags.isNotEmpty)
                    SizedBox(height: 5),
                  if (results
                      .entries[selectedIndex.value].yomichanTermTags.isNotEmpty)
                    Wrap(
                      children: results.entries[selectedIndex.value]
                          .generateTagWidgets(context),
                    ),
                  Flexible(
                    child: results.entries[selectedIndex.value]
                        .generateMeaningWidgetsDialog(
                      context,
                      selectable: true,
                      customTextSelectionControls: CustomTextSelectionControls(
                          customButton: (selectedValue) {
                        _clipboard.value = selectedValue;
                      }),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: '',
                      children: <InlineSpan>[
                        TextSpan(
                          text: "Selecting search result ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[300],
                          ),
                        ),
                        TextSpan(
                          text: "${selectedIndex.value + 1} ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: "out of ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[300],
                          ),
                        ),
                        TextSpan(
                          text: "${results.entries.length} ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: "found for",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[300],
                          ),
                        ),
                        TextSpan(
                          text: "『",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey[300],
                          ),
                        ),
                        TextSpan(
                          text: "${results.searchTerm}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: "』",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  (recursiveTerms.length > 1)
                      ? GestureDetector(
                          onTap: () {
                            noPush = true;
                            recursiveTerms.removeLast();
                            _clipboard.value = recursiveTerms.last;
                          },
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                "『 ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey[300],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Icon(Icons.arrow_back, size: 11),
                              SizedBox(width: 5),
                              Text(
                                "Return ",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "to ",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "previous ",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "definition",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                " 』",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey[300],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future dictionaryFutureHelper(String clipboard) async {
    String contextDataSource = chapter.directory.path;
    int contextPosition = currentPage.value;

    switch (getCurrentDictionary()) {
      case "Jisho.org API":
        return fetchBilingualSearchCache(
          searchTerm: clipboard,
          contextDataSource: contextDataSource,
          contextPosition: contextPosition,
        );
      case "Sora Dictionary API":
        return fetchMonolingualSearchCache(
          searchTerm: clipboard,
          recursive: false,
          contextDataSource: contextDataSource,
          contextPosition: contextPosition,
        );
      default:
        return fetchCustomDictionarySearchCache(
          dictionaryName: getCurrentDictionary(),
          searchTerm: clipboard,
          contextDataSource: contextDataSource,
          contextPosition: contextPosition,
        );
    }
  }

  Widget buildDictionary() {
    return ValueListenableBuilder(
      valueListenable: _clipboard,
      builder: (context, clipboard, widget) {
        return ValueListenableBuilder(
          valueListenable: gActiveDictionary,
          builder:
              (BuildContext context, String activeDictionary, Widget child) {
            return FutureBuilder(
              future: dictionaryFutureHelper(clipboard),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (_clipboard.value == "&<&>export&<&>") {
                  return buildDictionaryExporting(clipboard);
                }
                if (_clipboard.value == "&<&>autogen&<&>") {
                  return buildDictionaryAutoGenQuery(clipboard);
                }
                if (_clipboard.value == "&<&>autogendependencies&<&>") {
                  return buildDictionaryAutoGenDependencies(clipboard);
                }
                if (_clipboard.value == "&<&>autogenbad&<&>") {
                  return buildDictionaryAutoGenBad(clipboard);
                }
                if (_clipboard.value == "&<&>netsubsrequest&<&>") {
                  return buildDictionaryNetworkSubtitlesRequest(clipboard);
                }
                if (_clipboard.value == "&<&>netsubsbad&<&>") {
                  return buildDictionaryNetworkSubtitlesBad(clipboard);
                }
                if (_clipboard.value == "&<&>exported&<&>") {
                  return buildDictionaryExported(clipboard);
                }
                if (_clipboard.value == "") {
                  return Container();
                }

                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return buildDictionaryLoading(clipboard);
                  default:
                    DictionaryHistoryEntry results = snapshot.data;

                    if (snapshot.hasData && results.entries.isNotEmpty) {
                      return buildDictionaryMatch(results);
                    } else {
                      return buildDictionaryNoMatch(clipboard);
                    }
                }
              },
            );
          },
        );
      },
    );
  }
}

class MangaProgressBar extends StatefulWidget {
  MangaProgressBar(
    this.currentPage,
    this.pagesCount,
    this.pageController, {
    ChewieProgressColors colors,
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
    Key key,
  })  : colors = colors ?? ChewieProgressColors(),
        super(key: key);

  final ChewieProgressColors colors;
  final ValueNotifier<int> currentPage;
  final PageController pageController;
  final int pagesCount;
  final Function() onDragStart;
  final Function() onDragEnd;
  final Function() onDragUpdate;

  @override
  MangaProgressBarState createState() {
    return MangaProgressBarState();
  }
}

class MangaProgressBarState extends State<MangaProgressBar> {
  MangaProgressBarState() {
    listener = () {
      if (!mounted) return;
      setState(() {});
    };
  }

  VoidCallback listener;

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final box = context.findRenderObject() as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final int position =
          widget.pagesCount - ((widget.pagesCount) * relative).round();
      widget.pageController.jumpToPage(
        position,
      );
    }

    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        if (widget.onDragStart != null) {
          widget.onDragStart();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        seekToRelativePosition(details.globalPosition);

        if (widget.onDragUpdate != null) {
          widget.onDragUpdate();
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (widget.onDragEnd != null) {
          widget.onDragEnd();
        }
      },
      onTapDown: (TapDownDetails details) {
        seekToRelativePosition(details.globalPosition);
      },
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          child: CustomPaint(
            painter: MangaProgressBarPainter(
              widget.currentPage,
              widget.pagesCount,
              widget.colors,
            ),
          ),
        ),
      ),
    );
  }
}

class MangaProgressBarPainter extends CustomPainter {
  MangaProgressBarPainter(this.currentPage, this.pagesCount, this.colors);

  final ValueNotifier<int> currentPage;
  final int pagesCount;

  ChewieProgressColors colors;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const height = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(size.width, size.height / 2 + height),
        ),
        const Radius.circular(4.0),
      ),
      colors.backgroundPaint,
    );

    final double playedPartPercent =
        1 - ((currentPage.value - 1) / (pagesCount - 1));
    final double playedPart =
        playedPartPercent > 1 ? size.width : playedPartPercent * size.width;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(playedPart, size.height / 2 + height),
        ),
        const Radius.circular(4.0),
      ),
      colors.playedPaint,
    );
    canvas.drawCircle(
      Offset(playedPart, size.height / 2 + height / 2),
      height * 3,
      colors.handlePaint,
    );
  }
}

class _MoreOptionsDialog extends StatelessWidget {
  const _MoreOptionsDialog({
    this.options,
    this.icons,
    this.highlights,
    this.invisibles,
  });

  final List<String> options;
  final List<IconData> icons;
  final List<int> highlights;
  final List<int> invisibles;

  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    });

    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final _option = options[index];
        final _icon = icons[index];

        if (invisibles.contains(index)) {
          return Container();
        }

        return ListTile(
          dense: true,
          title: Row(
            children: [
              Icon(
                _icon,
                size: 20.0,
                color: Colors.red,
              ),
              const SizedBox(width: 16.0),
              Text(
                _option,
                style: TextStyle(
                  color:
                      (highlights.contains(index)) ? Colors.red : Colors.white,
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).pop(index);
          },
        );
      },
    );
  }
}

class TouchPoints {
  Paint paint;
  Offset points;
  TouchPoints({this.points, this.paint});
}

typedef void OcrCoordsCallback(Offset a, Offset b);

class OcrBoxPainter extends CustomPainter {
  OcrBoxPainter({this.pointsList, this.defaultPaint, this.coordsCallback});

  OcrCoordsCallback coordsCallback;
  Paint defaultPaint;
  List<TouchPoints> pointsList;
  List<Offset> offsetPoints = [];

  @override
  void paint(Canvas canvas, Size size) {
    if (pointsList.isEmpty) {
      canvas.drawRect(Rect.largest, defaultPaint);
    }

    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawPath(
            Path()
              ..addRect(Rect.largest)
              ..addRect(Rect.fromPoints(
                  pointsList[i].points, pointsList[i + 1].points))
              ..fillType = PathFillType.evenOdd,
            pointsList[i].paint);

        coordsCallback(pointsList[i].points, pointsList[i + 1].points);
      }
    }
  }

  @override
  bool shouldRepaint(OcrBoxPainter oldDelegate) => true;
}
