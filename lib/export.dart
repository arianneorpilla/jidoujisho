import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:clipboard_monitor/clipboard_monitor.dart';
// import 'package:gx_file_picker/gx_file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ve_dart/ve_dart.dart';
import 'package:wakelock/wakelock.dart';

import 'package:jidoujisho/main.dart';
import 'package:jidoujisho/util.dart';

class Export extends StatefulWidget {
  Export({
    this.imageFile,
    this.defaultSentence,
    Key key,
  }) : super(key: key);

  final File imageFile;
  final String defaultSentence;

  @override
  _ExportState createState() => _ExportState(
        this.imageFile,
        this.defaultSentence,
      );
}

class _ExportState extends State<Export> {
  _ExportState(
    this.imageFile,
    this.defaultSentence,
  );

  final File imageFile;
  final String defaultSentence;

  String _volatileText = "";
  FocusNode _subtitleFocusNode = new FocusNode();

  final _clipboard = ValueNotifier<String>("");
  final _currentDictionaryEntry =
      ValueNotifier<DictionaryEntry>(DictionaryEntry(
    word: "",
    reading: "",
    meaning: "",
  ));
  final _currentText = ValueNotifier<String>("");
  SubtitleStyle subtitleStyle = SubtitleStyle(
    textColor: Colors.white,
    hasBorder: true,
    fontSize: 24,
  );

  @override
  Widget build(BuildContext context) {
    _currentText.value = defaultSentence;
    startClipboardMonitor();

    return new Scaffold(
      floatingActionButton: buildFAB(),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
              top: subtitleStyle.position.top,
              bottom: subtitleStyle.position.bottom,
              left: subtitleStyle.position.left,
              right: subtitleStyle.position.right,
              child: buildSubtitleSelector()),
          FutureBuilder(
              future: getImages("makise"),
              builder:
                  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Container();
                  default:
                    return Container(
                      // child: *Image list as child*, but don't know about the list datatype hence not created it!
                      alignment: Alignment.center,
                      child: GridView.builder(
                          itemCount: 24,
                          gridDelegate:
                              // crossAxisCount stands for number of columns you want for displaying
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemBuilder: (BuildContext context, int index) {
                            // return your grid widget here, like how your images will be displayed

                            return imageFromBase64String(snapshot.data[index]);
                          }),
                    );
                }
              }),
          buildDictionary(),
        ],
      ),
    );
  }

  Widget buildFAB() {
    return FloatingActionButton(
      onPressed: () async {
        final chosenOption = await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => _MoreOptionsDialog(options: [
            "Search Current Text with Jisho.org",
            "Translate Current Text with DeepL",
            "Translate Current Text with Google Translate",
            globalSelectMode.value
                ? "Use Tap to Select Text Selection"
                : "Use Drag to Select Text Selection",
            "Select Image from Device",
            "Export Current Context to Anki",
          ], icons: [
            Icons.menu_book_rounded,
            Icons.translate_rounded,
            Icons.g_translate_rounded,
            globalSelectMode.value
                ? Icons.touch_app_rounded
                : Icons.select_all_rounded,
            Icons.photo_library_rounded,
            Icons.mobile_screen_share_rounded,
          ]),
        );

        final String subtitleText = _currentText.value;

        switch (chosenOption) {
          case 0:
            await launch("https://jisho.org/search/$subtitleText");
            break;
          case 1:
            await launch(
                "https://www.deepl.com/translator#ja/en/$subtitleText");
            break;
          case 2:
            await launch(
                "https://translate.google.com/?sl=ja&tl=en&text=$subtitleText&op=translate");
            break;
          case 4:
            globalSelectMode.value = !globalSelectMode.value;

            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.setBool("selectMode", globalSelectMode.value);
            break;
          case 5:
            break;
          case 6:
            break;
        }
      },
      child: Icon(Icons.handyman_rounded),
      backgroundColor: Theme.of(context).dialogBackgroundColor.withOpacity(0.8),
      foregroundColor: Colors.white,
    );
  }

  Widget buildSubtitleSelector() {
    Widget getOutlineText(Word word) {
      return Text(
        word.word,
        style: TextStyle(
          fontSize: subtitleStyle.fontSize,
          foreground: Paint()
            ..style = subtitleStyle.borderStyle.style
            ..strokeWidth = subtitleStyle.borderStyle.strokeWidth
            ..color = Colors.black.withOpacity(0.75),
        ),
      );
    }

    Widget getText(Word word, int index) {
      return InkWell(
        onTap: () {
          Clipboard.setData(
            ClipboardData(text: word.word),
          );
        },
        child: Text(
          word.word,
          style: TextStyle(
            fontSize: subtitleStyle.fontSize,
          ),
        ),
      );
    }

    return ValueListenableBuilder(
      valueListenable: globalSelectMode,
      builder: (context, selectMode, widget) {
        if (selectMode) {
          return Container(
            child: Stack(
              children: <Widget>[
                subtitleStyle.hasBorder
                    ? Center(
                        child: SelectableText(
                          _currentText.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleStyle.fontSize,
                            foreground: Paint()
                              ..style = subtitleStyle.borderStyle.style
                              ..strokeWidth =
                                  subtitleStyle.borderStyle.strokeWidth
                              ..color = Colors.black.withOpacity(0.75),
                          ),
                          enableInteractiveSelection: false,
                        ),
                      )
                    : Container(
                        child: null,
                      ),
                Center(
                  child: SelectableText(
                    _currentText.value,
                    textAlign: TextAlign.center,
                    onSelectionChanged: (selection, cause) {
                      Clipboard.setData(ClipboardData(
                          text: selection.textInside(_currentText.value)));
                    },
                    style: TextStyle(
                      fontSize: subtitleStyle.fontSize,
                      color: subtitleStyle.textColor,
                    ),
                    focusNode: _subtitleFocusNode,
                    toolbarOptions: ToolbarOptions(
                        copy: false,
                        cut: false,
                        selectAll: false,
                        paste: false),
                  ),
                ),
              ],
            ),
          );
        } else {
          String processedSubtitles;
          processedSubtitles = _currentText.value.replaceAll('\n', '␜');
          processedSubtitles = processedSubtitles.replaceAll(' ', '␝');

          List<Word> words = parseVe(mecabTagger, processedSubtitles);
          print(words);

          List<List<Word>> lines =
              getLinesFromWords(context, subtitleStyle, words);
          List<List<int>> indexes =
              getIndexesFromWords(context, subtitleStyle, words);

          for (Word word in words) {
            word.word = word.word.replaceAll('␝', ' ');
            word.word = word.word.replaceAll('␜', '');
          }

          return Container(
            child: Stack(
              children: <Widget>[
                subtitleStyle.hasBorder
                    ? Center(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: lines.length,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (BuildContext context, int lineIndex) {
                            List<dynamic> line = lines[lineIndex];
                            List<Widget> textWidgets = [];

                            for (int i = 0; i < line.length; i++) {
                              Word word = line[i];
                              textWidgets.add(getOutlineText(word));
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: textWidgets,
                            );
                          },
                        ),
                      )
                    : Container(
                        child: null,
                      ),
                Center(
                  child: Center(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: lines.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int lineIndex) {
                        List<dynamic> line = lines[lineIndex];
                        List<int> indexList = indexes[lineIndex];
                        List<Widget> textWidgets = [];

                        for (int i = 0; i < line.length; i++) {
                          Word word = line[i];
                          int index = indexList[i];
                          textWidgets.add(getText(word, index));
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: textWidgets,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildDictionaryLoading(String clipboard) {
    String lookupText = "Looking up『$clipboard』...";

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

  Widget buildDictionaryExporting(String clipboard) {
    String lookupText = "Preparing to export...";

    Future.delayed(Duration(seconds: 2), () {
      if (_clipboard.value == "&<&>export&<&>") {
        Future.delayed(Duration(seconds: 2), () {
          if (_clipboard.value == "&<&>export&<&>") {
            Future.delayed(Duration(seconds: 2), () {
              if (_clipboard.value == "&<&>export&<&>") {
                Future.delayed(Duration(seconds: 2), () {
                  if (_clipboard.value == "&<&>export&<&>") {
                    Future.delayed(Duration(seconds: 2), () {
                      if (_clipboard.value == "&<&>export&<&>") {
                        _clipboard.value = "&<&>exportlong&<&>";
                      }
                    });
                  }
                });
              }
            });
          }
        });
      }
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

  Widget buildDictionaryExportingLong(String clipboard) {
    String lookupText =
        "Preparing to export... This is taking too long...\nPlease ensure AnkiDroid is launched in the background.";

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
    String lookupText;
    if (globalSelectMode.value) {
      lookupText = "No matches for \"$clipboard\" could be queried.";
    } else {
      lookupText = "No matches for the selection could be queried.";
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

  Widget buildDictionaryMatch(List<DictionaryEntry> results) {
    _subtitleFocusNode.unfocus();
    ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

    return ValueListenableBuilder(
        valueListenable: selectedIndex,
        builder: (BuildContext context, int _, Widget widget) {
          _currentDictionaryEntry.value = results[selectedIndex.value];

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
                  if (selectedIndex.value == results.length - 1) {
                    selectedIndex.value = 0;
                  } else {
                    selectedIndex.value += 1;
                  }
                } else {
                  if (selectedIndex.value == 0) {
                    selectedIndex.value = results.length - 1;
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
                    Text(
                      results[selectedIndex.value].word,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(results[selectedIndex.value].reading),
                    Flexible(
                      child: SingleChildScrollView(
                        child:
                            Text("\n${results[selectedIndex.value].meaning}\n"),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Showing search result ",
                          style: TextStyle(
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "${selectedIndex.value + 1} ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "out of ",
                          style: TextStyle(
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "${results.length} ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "found for",
                          style: TextStyle(
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "『${results[selectedIndex.value].searchTerm}』",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget buildDictionary() {
    return ValueListenableBuilder(
      valueListenable: _clipboard,
      builder: (context, clipboard, widget) {
        return FutureBuilder(
          future: getWordDetails(clipboard),
          builder: (BuildContext context,
              AsyncSnapshot<List<DictionaryEntry>> snapshot) {
            if (_clipboard.value == "&<&>export&<&>") {
              return buildDictionaryExporting(clipboard);
            }
            if (_clipboard.value == "&<&>exportlong&<&>") {
              return buildDictionaryExportingLong(clipboard);
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
                List<DictionaryEntry> entries = snapshot.data;

                if (snapshot.hasData && snapshot.data.isNotEmpty) {
                  _currentDictionaryEntry.value = entries.first;
                  return buildDictionaryMatch(entries);
                } else {
                  return buildDictionaryNoMatch(clipboard);
                }
            }
          },
        );
      },
    );
  }

  void startClipboardMonitor() {
    ClipboardMonitor.registerCallback(onClipboardText);
  }

  void stopClipboardMonitor() {
    ClipboardMonitor.unregisterCallback(onClipboardText);
  }

  void onClipboardText(String text) {
    _volatileText = text;

    Future.delayed(
        text.length == 1
            ? Duration(milliseconds: 1000)
            : Duration(milliseconds: 500), () {
      if (_volatileText == text) {
        print("CLIPBOARD CHANGED: $text");
        _clipboard.value = text;
      }
    });
  }

  void stopAllClipboardMonitoring() {
    ClipboardMonitor.unregisterAllCallbacks();
  }
}

class _MoreOptionsDialog extends StatelessWidget {
  const _MoreOptionsDialog({
    Key key,
    @required List<String> options,
    @required List<IconData> icons,
  })  : _options = options,
        _icons = icons,
        super(key: key);

  final List<String> _options;
  final List<IconData> _icons;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemBuilder: (context, index) {
        final _option = _options[index];
        final _icon = _icons[index];
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
              Text(_option),
            ],
          ),
          onTap: () {
            Navigator.of(context).pop(index);
          },
        );
      },
      itemCount: _options.length,
    );
  }
}
