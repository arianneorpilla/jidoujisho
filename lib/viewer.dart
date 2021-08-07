import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:clipboard_monitor/clipboard_monitor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jidoujisho/main.dart';
import 'package:jidoujisho/util.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'package:jidoujisho/cache.dart';
import 'package:jidoujisho/dictionary.dart';
import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/pitch.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:ve_dart/ve_dart.dart';

class Viewer extends StatefulWidget {
  Viewer(
    this.chapter, {
    this.fromEnd = false,
    this.fromStart = false,
  });

  final MangaChapter chapter;
  final bool fromEnd;
  final bool fromStart;

  @override
  State<Viewer> createState() =>
      ViewerState(this.chapter, this.fromEnd, this.fromStart);
}

class ViewerState extends State<Viewer> {
  ViewerState(
    this.chapter,
    this.fromEnd,
    this.fromStart,
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

  PageController pageController;
  List<ImageProvider> images;
  ValueNotifier<int> currentPage;

  String highlightedText = "";
  List<String> recursiveTerms = [];
  bool noPush = false;

  @override
  void dispose() {
    stopAllClipboardMonitoring();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
    _clipboard.value = text;
  }

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
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            buildGallery(),
            buildCurrentPage(),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05,
                bottom: MediaQuery.of(context).size.height * 0.05,
              ),
              child: buildDictionary(),
            ),
          ],
        ),
      ),
    );
  }

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
            'CANCEL',
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
            (previous) ? 'READ PREVIOUS' : 'READ NEXT',
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
    );
  }

  Widget buildGallery() {
    return PhotoViewGallery.builder(
      reverse: true,
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: images[index],
          initialScale: PhotoViewComputedScale.contained * 1,
          minScale: PhotoViewComputedScale.contained * 1,
          maxScale: PhotoViewComputedScale.contained * 4,
          filterQuality: FilterQuality.high,
        );
      },
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
      onPageChanged: (pageNumber) {
        if (pageNumber <= 0) {
          MangaChapter previous = chapter.getPreviousChapter();
          if (previous != null) {
            showChapterRedirectionDialog(previous, previous: true);
          } else {}
        } else if (pageNumber > images.length - 2) {
          MangaChapter next = chapter.getNextChapter();
          if (next != null) {
            showChapterRedirectionDialog(next, previous: false);
          } else {}
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
                  results.entries[selectedIndex.value]
                      .generateMeaningWidgetsDialog(context, selectable: true),
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
