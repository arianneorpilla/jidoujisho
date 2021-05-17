import 'dart:io';

import 'package:clipboard_monitor/clipboard_monitor.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:gx_file_picker/gx_file_picker.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'package:jidoujisho/anki.dart';
import 'package:jidoujisho/cache.dart';
import 'package:jidoujisho/dictionary.dart';
import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:jidoujisho/util.dart';

class ReaderPicker extends StatelessWidget {
  ReaderPicker({
    this.file,
    this.initialPosition = -1,
  });

  final File file;
  final int initialPosition;

  @override
  Widget build(BuildContext context) {
    if (file != null) {
      return Reader(bookFile: file, initialPosition: -1);
    } else {
      return new FutureBuilder(
        future: FilePicker.getFile(
            type: Platform.isIOS ? FileType.any : FileType.video),
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return loadingCircle();
            default:
              if (snapshot.hasData) {
                File bookFile = snapshot.data;
                if (bookFile == null) {
                  Navigator.pop(context);
                }

                return Reader(bookFile: bookFile, initialPosition: -1);
              }
              Navigator.pop(context);
              return Container();
          }
        },
      );
    }
  }

  Widget loadingCircle() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
      ),
    );
  }
}

class Reader extends StatefulWidget {
  Reader({
    this.bookFile,
    this.initialPosition,
    Key key,
  }) : super(key: key);

  final File bookFile;
  final int initialPosition;

  @override
  _ReaderState createState() => _ReaderState(
        this.bookFile,
        this.initialPosition,
      );
}

class _ReaderState extends State<Reader> with SingleTickerProviderStateMixin {
  _ReaderState(
    this.bookFile,
    this.initialPosition,
  );

  final File bookFile;
  int initialPosition;

  String _volatileText = "";
  List<String> recursiveTerms = [];
  bool noPush = false;

  int initialSubTrack;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startClipboardMonitor() {
    ClipboardMonitor.registerCallback(onClipboardText);
  }

  void stopClipboardMonitor() {
    ClipboardMonitor.unregisterCallback(onClipboardText);
  }

  void emptyStack() {
    noPush = false;
    recursiveTerms = [];
  }

  void setNoPush() {
    noPush = true;
  }

  void onClipboardText(String text) {
    text = text.trim();
    _volatileText = text.trim();

    Future.delayed(
        text.length == 1
            ? Duration(milliseconds: 1000)
            : Duration(milliseconds: 500), () {
      if (_volatileText.trim() == text.trim()) {
        _clipboard.value = text;
      }
    });
  }

  void stopAllClipboardMonitoring() {
    ClipboardMonitor.unregisterAllCallbacks();
  }

  final _clipboard = ValueNotifier<String>("");
  final _currentDictionaryEntry =
      ValueNotifier<DictionaryEntry>(DictionaryEntry(
    word: "",
    reading: "",
    meaning: "",
  ));
  final _failureMetadata = ValueNotifier<AnkiExportMetadata>(null);

  @override
  Widget build(BuildContext context) {
    startClipboardMonitor();

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            buildDictionary(),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    Widget alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      title: new Text('End Playback?'),
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
            unlockLandscape();
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

  Widget buildDictionaryLoading(String clipboard) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[800].withOpacity(0.6),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "Looking up",
                  style: TextStyle(),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "『",
                      style: TextStyle(
                        color: Colors.grey[300],
                      ),
                    ),
                    Text(
                      clipboard,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "』",
                      style: TextStyle(
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
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
            color: Colors.grey[800].withOpacity(0.6),
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
            color: Colors.grey[800].withOpacity(0.6),
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
            color: Colors.grey[800].withOpacity(0.6),
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
            color: Colors.grey[800].withOpacity(0.6),
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

  Widget buildDictionaryExportingLong(String clipboard) {
    String lookupText =
        "The AnkiDroid background service must be active for card export.\n" +
            "Press here to launch AnkiDroid and return to continue.";

    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            await LaunchApp.openApp(
              androidPackageName: 'com.ichi2.anki',
              openStore: true,
            );

            _clipboard.value = "";

            try {
              await getDecks();
              AnkiExportMetadata metadata = _failureMetadata.value;

              _clipboard.value = "&<&>export&<&>";

              exportToAnki(
                context,
                metadata.chewie,
                metadata.controller,
                metadata.clipboard,
                metadata.subtitle,
                metadata.dictionaryEntry,
                metadata.wasPlaying,
                metadata.exportSubtitles,
                metadata.audioAllowance,
                metadata.subtitleDelay,
                _failureMetadata,
              );

              _failureMetadata.value = null;
            } catch (e) {
              print(e);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.grey[800].withOpacity(0.6),
              child: Text(lookupText),
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryExported(String clipboard) {
    String deckName = clipboard.substring(12, clipboard.length - 4);
    String lookupText = "Card exported to \"$deckName\".";

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[800].withOpacity(0.6),
            child: Text(lookupText),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget buildDictionaryNoMatch(String clipboard) {
    if (getMonolingualMode()) {
      gMonolingualSearchCache[clipboard] = null;
    } else {
      gBilingualSearchCache[clipboard] = null;
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
            child: Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.grey[800].withOpacity(0.6),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "No matches for",
                      style: TextStyle(),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "『",
                          style: TextStyle(
                            color: Colors.grey[300],
                          ),
                        ),
                        Text(
                          clipboard,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "』",
                          style: TextStyle(
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "could be queried.",
                      style: TextStyle(),
                    ),
                  ],
                )),
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
        addDictionaryEntryToHistory(
          DictionaryHistoryEntry(
            entries: results.entries,
            searchTerm: results.searchTerm,
            swipeIndex: selectedIndex.value,
            contextDataSource: results.contextDataSource,
            contextPosition: results.contextPosition,
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
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 84),
              color: Colors.grey[800].withOpacity(0.6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onLongPress: () {
                      toggleMonolingualMode();
                      final String clipboardMemory = _clipboard.value;
                      _clipboard.value = "";
                      setNoPush();
                      _clipboard.value = clipboardMemory;
                    },
                    child: Text(
                      results.entries[selectedIndex.value].word,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onLongPress: () {
                      toggleMonolingualMode();
                      final String clipboardMemory = _clipboard.value;
                      _clipboard.value = "";
                      setNoPush();
                      _clipboard.value = clipboardMemory;
                    },
                    child: Text(results.entries[selectedIndex.value].reading),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child:
                          gCustomDictionary.isNotEmpty || getMonolingualMode()
                              ? SelectableText(
                                  "\n${results.entries[selectedIndex.value].meaning}\n",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                  toolbarOptions: ToolbarOptions(
                                      copy: true,
                                      cut: false,
                                      selectAll: false,
                                      paste: false),
                                )
                              : Text(
                                  "\n${results.entries[selectedIndex.value].meaning}\n",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                    ),
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        "Selecting search result ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "${selectedIndex.value + 1} ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "out of ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "${results.entries.length} ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "found for",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "『",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey[300],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${results.searchTerm}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "』",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey[300],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
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
                                "Return to previous definition",
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

  Widget buildDictionary() {
    return ValueListenableBuilder(
      valueListenable: _clipboard,
      builder: (context, clipboard, widget) {
        return FutureBuilder(
          future: getMonolingualMode()
              ? fetchMonolingualSearchCache(
                  searchTerm: clipboard,
                  recursive: false,
                )
              : fetchBilingualSearchCache(
                  searchTerm: clipboard,
                ),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (_clipboard.value == "&<&>export&<&>") {
              return buildDictionaryExporting(clipboard);
            }
            if (_clipboard.value == "&<&>exportlong&<&>") {
              return buildDictionaryExportingLong(clipboard);
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
            if (_clipboard.value.startsWith("&<&>exported")) {
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
  }
}
