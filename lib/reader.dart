import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:clipboard_monitor/clipboard_monitor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jidoujisho/main.dart';
import 'package:jidoujisho/util.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'package:jidoujisho/cache.dart';
import 'package:jidoujisho/dictionary.dart';
import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/pitch.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:ve_dart/ve_dart.dart';

class Reader extends StatefulWidget {
  Reader(this.initialURL, this.initialX);

  final String initialURL;
  final int initialX;

  @override
  State<Reader> createState() => ReaderState(this.initialURL, this.initialX);
}

class ReaderState extends State<Reader> {
  ReaderState(this.initialURL, this.initialX);

  final _clipboard = ValueNotifier<String>("");
  final _currentDictionaryEntry =
      ValueNotifier<DictionaryEntry>(DictionaryEntry(
    word: "",
    reading: "",
    meaning: "",
  ));
  final String initialURL;
  final int initialX;

  int initialPosition;
  String _volatileText = "";
  String highlightedText = "";
  FocusNode _subtitleFocusNode = new FocusNode();
  List<String> recursiveTerms = [];
  bool noPush = false;
  bool scrollDone;

  int currentIndex = -1;
  String currentTitle = "";
  String currentBookmarkDiv = "";
  String currentBase64Image = "";
  int wordCount = -1;

  Timer durationTimer;
  Timer visibilityTimer;

  InAppWebViewController webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));
  ContextMenu contextMenu;

  @override
  void dispose() {
    stopAllClipboardMonitoring();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollDone = initialX == null;
  }

  Future<void> clearSelection() async {
    String clearJs = "window.getSelection().removeAllRanges();";

    await webViewController.evaluateJavascript(source: clearJs);
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

  String textClickJs = """
/*jshint esversion: 6 */
var getImageBlob = function(url) {
	return new Promise(async resolve => {
		let response = await fetch(url);
		let blob = response.blob();
		resolve(blob);
	});
};
var blobToBase64 = function(blob) {
	return new Promise(resolve => {
		let reader = new FileReader();
		reader.onload = function() {
			let dataUrl = reader.result;
			resolve(dataUrl);
		};
		reader.readAsDataURL(blob);
	});
}
var getBase64Image = async function(url) {
	let blob = await getImageBlob(url);
	let base64 = await blobToBase64(blob);
	return base64;
}
var touchmoved;
var touchevent;
var reader = document.getElementsByTagName('app-reader')[0];
var bookmark = document.getElementsByClassName('fa-bookmark')[0].parentElement.parentElement;
var info = document.getElementsByClassName('information-overlay bottom-overlay scroll-information')[0];

var firstImage = document.getElementsByTagName("image")[0];
var firstImg = document.getElementsByTagName("img")[0];
var blob;

if (firstImage != null) {
  blob = firstImage.attributes.href.textContent;
} else if (firstImg != null) {
  blob = firstImg.src;
} else {
  blob = "";
}

if (blob != null) {
  getBase64Image(blob).then(base64Image => console.log(JSON.stringify({
				"base64Image": base64Image,
        "bookmark": info.textContent,
				"jidoujisho": "jidoujisho-metadata"
			})));
}

bookmark.addEventListener('touchstart', function() {
  console.log(JSON.stringify({
				"bookmark": info.textContent,
				"jidoujisho": "jidoujisho-bookmark"
			}));
});

reader.addEventListener('touchend', function() {
	if (touchmoved !== true) {
		var touch = touchevent.touches[0];
		var result = document.caretRangeFromPoint(touch.clientX, touch.clientY);
		var selectedElement = result.startContainer;

    var paragraph = result.startContainer;
    while (paragraph && paragraph.nodeName !== 'P') {
      paragraph = paragraph.parentNode;
    }

    if (paragraph == null) {
      paragraph = result.startContainer.parentNode;
    }

    console.log(paragraph.nodeName);

		var noFuriganaText = [];
		var noFuriganaNodes = [];
		var selectedFound = false;
		var index = 0;

		for (var value of paragraph.childNodes.values()) {
			if (value.nodeName === "#text") {
				noFuriganaText.push(value.textContent);
				noFuriganaNodes.push(value);

				if (selectedFound === false) {
					if (selectedElement !== value) {
						index = index + value.textContent.length;
					} else {
						index = index + result.startOffset;
						selectedFound = true;
					}
				}

			} else {
				for (var node of value.childNodes.values()) {
					if (node.nodeName === "#text") {
						noFuriganaText.push(node.textContent);
						noFuriganaNodes.push(node);

						if (selectedFound === false) {
							if (selectedElement !== node) {
								index = index + node.textContent.length;
							} else {
								index = index + result.startOffset;
								selectedFound = true;
							}
						}
					} else if (node.firstChild.nodeName === "#text" && node.nodeName !== "RT" && node.nodeName !== "RP") {
						noFuriganaText.push(node.firstChild.textContent);
						noFuriganaNodes.push(node.firstChild);

						if (selectedFound === false) {
							if (selectedElement !== node.firstChild) {
								index = index + node.firstChild.textContent.length;
							} else {
								index = index + result.startOffset;
								selectedFound = true;
							}
						}
					}
				}
			}
		}

		var text = noFuriganaText.join("");
		var offset = index;
    

		console.log(JSON.stringify({
				"offset": offset,
				"text": text,
				"jidoujisho": "jidoujisho"
			}));
	}
});
reader.addEventListener('touchmove', () => {
	touchmoved = true;
	touchevent = null;
});
reader.addEventListener('touchstart', (e) => {
	touchmoved = false;
	touchevent = e;
});
""";

  @override
  Widget build(BuildContext context) {
    startClipboardMonitor();

    contextMenu = ContextMenu(
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: true),
        menuItems: [
          ContextMenuItem(
              androidId: 1,
              iosId: "1",
              title: "Search",
              action: () async {
                emptyStack();

                String searchTerm = (await webViewController.getSelectedText())
                        .replaceAll("\\n", "\n")
                        .trim() ??
                    "";
                Clipboard.setData(ClipboardData(text: searchTerm));

                clearSelection();
              }),
          ContextMenuItem(
              androidId: 2,
              iosId: "2",
              title: "Dictionaries",
              action: () async {
                String clipboardMemory =
                    (await webViewController.getSelectedText())
                            .replaceAll("\\n", "\n")
                            .trim() ??
                        "";
                openDictionaryMenu(context, false).then((result) async {
                  emptyStack();
                  _clipboard.value = clipboardMemory;
                });
                clearSelection();
              }),
          ContextMenuItem(
              androidId: 3,
              iosId: "3",
              title: "Creator",
              action: () async {
                emptyStack();

                String readerExport =
                    (await webViewController.getSelectedText())
                            .replaceAll("\\n", "\n") ??
                        "";
                readerExport = readerExport.replaceAll("　", " ");
                print(readerExport);

                clearSelection();

                stopClipboardMonitor();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(readerExport: readerExport),
                  ),
                ).then((result) {
                  SystemChrome.setEnabledSystemUIOverlays([]);
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
              }),
        ],
        onCreateContextMenu: (result) {
          _clipboard.value = "";
        },
        onContextMenuActionItemClicked: (menuItem) {
          var id = (Platform.isAndroid) ? menuItem.androidId : menuItem.iosId;
        });

    return new WillPopScope(
      onWillPop: () async {
        Widget alertDialog = AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          title: new Text('Exit Reader?'),
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
          alignment: Alignment.topCenter,
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                  url: Uri.parse(initialURL ?? "https://ttu-ebook.web.app/")),
              initialOptions: options,
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                return PermissionRequestResponse(
                    resources: resources,
                    action: PermissionRequestResponseAction.GRANT);
              },
              contextMenu: contextMenu,
              onConsoleMessage: (controller, consoleMessage) async {
                print(consoleMessage);

                Map<String, dynamic> messageJson =
                    jsonDecode(consoleMessage.message);

                switch (messageJson["jidoujisho"]) {
                  case "jidoujisho":
                    if (gIsTapToSelectSupported) {
                      emptyStack();

                      int index = messageJson["offset"];
                      String text = messageJson["text"];

                      try {
                        String processedText = text.replaceAll("﻿", "␝");
                        processedText = processedText.replaceAll("　", "␝");
                        processedText = processedText.replaceAll('\n', '␜');
                        processedText = processedText.replaceAll(' ', '␝');

                        List<Word> tokens =
                            parseVe(gMecabTagger, processedText);
                        print(tokens);

                        List<String> tokenTape = [];
                        for (int i = 0; i < tokens.length; i++) {
                          Word token = tokens[i];
                          for (int j = 0; j < token.word.length; j++) {
                            tokenTape.add(token.word);
                          }
                        }

                        // print(tokenTape);
                        String searchTerm = tokenTape[index];
                        searchTerm = searchTerm.replaceAll('␜', '\n');
                        searchTerm = searchTerm.replaceAll('␝', ' ');
                        searchTerm = searchTerm.trim();
                        print("SELECTED: " + searchTerm);
                        // print("reached");

                        clearSelection();
                        Clipboard.setData(ClipboardData(text: searchTerm));
                      } catch (e) {
                        clearSelection();
                        emptyStack();
                        _clipboard.value = "";
                        print(e);
                      }
                    }
                    break;
                  case "jidoujisho-bookmark":
                    try {
                      currentBookmarkDiv = messageJson["bookmark"];
                      print("BOOKMARK GET! $currentBookmarkDiv");

                      String currentIndexText = (await controller.getUrl())
                          .toString()
                          .replaceAll("https://ttu-ebook.web.app/b/", "");
                      currentIndex = int.parse(currentIndexText);
                      HistoryItem bookHistory = HistoryItem(
                          "https://ttu-ebook.web.app/b/$currentIndex",
                          currentTitle,
                          currentBookmarkDiv,
                          currentBase64Image,
                          null,
                          wordCount);

                      await setLastSetBook();
                      await addBookHistory(bookHistory);
                    } catch (e) {
                      print(e);
                    }

                    break;
                  case "jidoujisho-metadata":
                    if (initialX == null) {
                      try {
                        if (messageJson["base64Image"]
                            .startsWith("data:image/")) {
                          currentBase64Image = messageJson["base64Image"];
                        }
                      } catch (e) {
                        currentBase64Image = null;
                      }

                      try {
                        currentBookmarkDiv = messageJson["bookmark"];
                        print("BOOKMARK GET! $currentBookmarkDiv");

                        String currentIndexText = (await controller.getUrl())
                            .toString()
                            .replaceAll("https://ttu-ebook.web.app/b/", "");
                        currentIndex = int.parse(currentIndexText);
                        HistoryItem bookHistory = HistoryItem(
                            "https://ttu-ebook.web.app/b/$currentIndex",
                            currentTitle,
                            currentBookmarkDiv,
                            currentBase64Image,
                            null,
                            wordCount);

                        await setLastSetBook();
                        await addBookHistory(bookHistory);
                      } catch (e) {
                        print(e);
                      }
                    } else {
                      print("SCROLL TO X");
                      Future.delayed(Duration(seconds: 1), () async {
                        await scrollToX(initialX);
                      });
                    }
                    break;
                }
              },
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStop: (controller, url) async {
                await controller.evaluateJavascript(source: textClickJs);

                String currentIndexText = (await controller.getUrl())
                    .toString()
                    .replaceAll("https://ttu-ebook.web.app/b/", "");
                currentIndex = int.tryParse(currentIndexText) ?? -1;

                print("NEW CURRENT INDEX: $currentIndex");
              },
              onTitleChanged: (controller, title) async {
                await controller.evaluateJavascript(source: textClickJs);

                currentTitle = (await controller.getTitle()).toString();
                currentTitle = currentTitle.replaceAll("| ッツ Ebook Reader", "");
                if (currentTitle == "ッツ Ebook Reader") {
                  currentTitle = "";
                }
                print("NEW CURRENT TITLE: $currentTitle");
              },
            ),
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

    _subtitleFocusNode.unfocus();

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

    _subtitleFocusNode.unfocus();
    ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

    return ValueListenableBuilder(
      valueListenable: selectedIndex,
      builder: (BuildContext context, int _, Widget widget) {
        _currentDictionaryEntry.value = results.entries[selectedIndex.value];
        DictionaryEntry pitchEntry =
            getClosestPitchEntry(_currentDictionaryEntry.value);
        ScrollController scrollController = ScrollController();

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

  Future scrollToX(int x) async {
    int currentScrollY = (await webViewController.getScrollY());
    await webViewController.scrollTo(x: x, y: currentScrollY);
  }

  Future dictionaryFutureHelper(String clipboard) async {
    String currentUrl = (await webViewController.getUrl()).toString();
    int currentScrollX = (await webViewController.getScrollX());

    switch (getCurrentDictionary()) {
      case "Jisho.org API":
        return fetchBilingualSearchCache(
          searchTerm: clipboard,
          contextDataSource: currentUrl,
          contextPosition: currentScrollX,
        );
      case "Sora Dictionary API":
        return fetchMonolingualSearchCache(
          searchTerm: clipboard,
          recursive: false,
          contextDataSource: currentUrl,
          contextPosition: currentScrollX,
        );
      default:
        return fetchCustomDictionarySearchCache(
          dictionaryName: getCurrentDictionary(),
          searchTerm: clipboard,
          contextDataSource: currentUrl,
          contextPosition: currentScrollX,
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
