import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jidoujisho/pitch.dart';
import 'package:path/path.dart' as path;
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';

import 'package:jidoujisho/dictionary.dart';
import 'package:jidoujisho/globals.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:jidoujisho/util.dart';

Future<void> requestAnkiDroidPermissions() async {
  const platform = const MethodChannel('com.lrorpilla.api/ankidroid');
  await platform.invokeMethod('requestPermissions');
}

String getPreviewImagePath() {
  return "$gAppDirPath/exportImage.jpg";
}

String getPreviewImageMultiPath(int index) {
  return "$gAppDirPath/exportMulti$index.jpg";
}

String getPreviewAudioPath() {
  return "$gAppDirPath/exportAudio.mp3";
}

void clearAllMultiFrames() {
  Directory gAppDir = Directory("$gAppDirPath");
  gAppDir.listSync().forEach((entity) {
    if (path.basename(entity.path).startsWith("exportMulti")) {
      entity.deleteSync(recursive: false);
    }
  });
}

void showAnkiDialog(
  BuildContext context,
  String sentence,
  DictionaryEntry dictionaryEntry,
  List<String> decks,
  String lastDeck,
  VlcPlayerController controller,
  ValueNotifier<String> clipboard,
  bool wasPlaying,
  List<Subtitle> exportSubtitles,
) {
  TextEditingController _sentenceController =
      TextEditingController(text: sentence);
  TextEditingController _wordController =
      TextEditingController(text: dictionaryEntry.word);

  DictionaryEntry pitchEntry = getClosestPitchEntry(dictionaryEntry);
  TextEditingController _readingController;

  if (pitchEntry != null) {
    _readingController =
        TextEditingController(text: getAllHtmlPitch(pitchEntry));
  } else {
    _readingController = TextEditingController(text: dictionaryEntry.reading);
  }

  TextEditingController _meaningController =
      TextEditingController(text: dictionaryEntry.meaning);

  Widget displayField(
    String labelText,
    String hintText,
    IconData icon,
    TextEditingController controller,
  ) {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          iconSize: 18,
          onPressed: () => controller.clear(),
          icon: Icon(Icons.clear, color: Colors.white),
        ),
        labelText: labelText,
        hintText: hintText,
      ),
    );
  }

  Widget sentenceField = displayField(
    "Sentence",
    "Enter the sentence here",
    Icons.format_align_center_rounded,
    _sentenceController,
  );
  Widget wordField = displayField(
    "Word",
    "Enter the word here",
    Icons.speaker_notes_outlined,
    _wordController,
  );
  Widget readingField = displayField(
    "Reading",
    "Enter the reading of the word here",
    Icons.surround_sound_outlined,
    _readingController,
  );
  Widget meaningField = displayField(
    "Meaning",
    "Enter the meaning of the word here",
    Icons.translate_rounded,
    _meaningController,
  );

  AudioPlayer audioPlayer = AudioPlayer();

  showDialog(
    context: context,
    builder: (context) {
      ValueNotifier<String> _selectedDeck = new ValueNotifier<String>(lastDeck);
      ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
      bool isSingle = exportSubtitles.length == 1;

      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        contentPadding: EdgeInsets.all(8),
        content: Row(
          children: <Widget>[
            Expanded(
              flex: 30,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    (isSingle)
                        ? Image.file(
                            File(getPreviewImagePath()),
                            fit: BoxFit.fitWidth,
                          )
                        : GestureDetector(
                            onTap: () {},
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity == 0) return;

                              if (details.primaryVelocity.compareTo(0) == -1) {
                                if (selectedIndex.value ==
                                    exportSubtitles.length - 1) {
                                  selectedIndex.value = 0;
                                } else {
                                  selectedIndex.value += 1;
                                }
                              } else {
                                if (selectedIndex.value == 0) {
                                  selectedIndex.value =
                                      exportSubtitles.length - 1;
                                } else {
                                  selectedIndex.value -= 1;
                                }
                              }
                            },
                            child: ValueListenableBuilder(
                              valueListenable: selectedIndex,
                              builder:
                                  (BuildContext context, value, Widget child) {
                                return Image.file(
                                  File(getPreviewImageMultiPath(
                                      selectedIndex.value)),
                                  fit: BoxFit.fitWidth,
                                );
                              },
                            )),
                    SizedBox(height: 10),
                    (isSingle)
                        ? Container()
                        : ValueListenableBuilder(
                            valueListenable: selectedIndex,
                            builder:
                                (BuildContext context, value, Widget child) {
                              return Wrap(
                                crossAxisAlignment: WrapCrossAlignment.end,
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    "Selecting preview image ",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
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
                                      color: Colors.grey[400],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "${exportSubtitles.length} ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            },
                          ),
                    DeckDropDown(
                      decks: decks,
                      selectedDeck: _selectedDeck,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(flex: 1, child: Container()),
            Expanded(
              flex: 30,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    sentenceField,
                    wordField,
                    readingField,
                    meaningField,
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'PREVIEW AUDIO',
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
              await audioPlayer.stop();
              await audioPlayer.play(
                getPreviewAudioPath(),
                isLocal: true,
              );
            },
          ),
          TextButton(
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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text(
              'EXPORT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextButton.styleFrom(
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () {
              exportAnkiCard(
                _selectedDeck.value,
                _sentenceController.text,
                _wordController.text,
                _readingController.text,
                _meaningController.text,
                isSingle,
                selectedIndex.value,
              );

              Navigator.pop(context);

              clipboard.value = "&<&>exported${_selectedDeck.value}&<&>";
              Future.delayed(Duration(seconds: 2), () {
                clipboard.value = "";
              });
            },
          ),
        ],
      );
    },
  ).then((result) {
    audioPlayer.stop();
    if (wasPlaying) {
      controller.play();
    }
  });
}

Future<void> addNote(
  String deck,
  String image,
  String audio,
  String sentence,
  String answer,
  String meaning,
  String reading,
) async {
  const platform = const MethodChannel('com.lrorpilla.api/ankidroid');

  try {
    await platform.invokeMethod('addNote', <String, dynamic>{
      'deck': deck,
      'image': image,
      'audio': audio,
      'sentence': sentence,
      'answer': answer,
      'meaning': meaning,
      'reading': reading,
    });
  } on PlatformException catch (e) {
    print("Failed to add note via AnkiDroid API");
    print(e);
  }
}

Future<void> addCreatorNote(
  String deck,
  String image,
  String audio,
  String sentence,
  String answer,
  String meaning,
  String reading,
  bool isReader,
) async {
  const platform = const MethodChannel('com.lrorpilla.api/ankidroid');

  String method = (isReader) ? "addReaderNote" : "addCreatorNote";

  try {
    await platform.invokeMethod(method, <String, dynamic>{
      'deck': deck,
      'image': image,
      'audio': audio,
      'sentence': sentence,
      'answer': answer,
      'meaning': meaning,
      'reading': reading,
    });
  } on PlatformException catch (e) {
    print("Failed to add note via AnkiDroid API");
    print(e);
  }
}

Future<List<String>> getDecks() async {
  const platform = const MethodChannel('com.lrorpilla.api/ankidroid');
  Map<dynamic, dynamic> deckMap = await platform.invokeMethod('getDecks');

  return deckMap.values.toList().cast<String>();
}

class DeckDropDown extends StatefulWidget {
  final List<String> decks;
  final ValueNotifier<String> selectedDeck;

  const DeckDropDown({this.decks, this.selectedDeck});

  @override
  _DeckDropDownState createState() =>
      _DeckDropDownState(this.selectedDeck, this.decks);
}

class _DeckDropDownState extends State<DeckDropDown> {
  final ValueNotifier<String> _selectedDeck;
  final List<String> _decks;

  _DeckDropDownState(this._selectedDeck, this._decks);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      value: _selectedDeck.value,
      items: _decks.map((String value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: new Text("  $value"),
        );
      }).toList(),
      onChanged: (selectedDeck) async {
        setLastDeck(selectedDeck);

        setState(() {
          _selectedDeck.value = selectedDeck;
        });
      },
    );
  }
}

void exportAnkiCard(String deck, String sentence, String answer, String reading,
    String meaning, bool isSingle, int selectedIndex) {
  DateTime now = DateTime.now();
  String newFileName =
      "jidoujisho-" + intl.DateFormat('yyyyMMddTkkmmss').format(now);

  File imageFile;
  if (isSingle) {
    imageFile = File(getPreviewImagePath());
  } else {
    imageFile = File(getPreviewImageMultiPath(selectedIndex));
  }

  File audioFile = File(getPreviewAudioPath());

  String newImagePath = path.join(
    getAnkiDroidDirectory().path,
    "collection.media/$newFileName.jpg",
  );
  String newAudioPath = path.join(
    getAnkiDroidDirectory().path,
    "collection.media/$newFileName.mp3",
  );

  String addImage = "";
  String addAudio = "";

  if (imageFile.existsSync()) {
    imageFile.copySync(newImagePath);
    addImage = "<img src=\"$newFileName.jpg\">";
  }
  if (audioFile.existsSync()) {
    audioFile.copySync(newAudioPath);
    addAudio = "[sound:$newFileName.mp3]";
  }

  if (answer == "") {
    answer = "​";
  }
  if (sentence == "") {
    sentence = "​";
  }
  if (meaning == "") {
    meaning = "​";
  }
  if (reading == "") {
    reading = "​";
  }

  requestAnkiDroidPermissions();
  addNote(deck, addImage, addAudio, sentence, answer, meaning, reading);
}

void exportCreatorAnkiCard(String deck, String sentence, String answer,
    String reading, String meaning, File imageFile, bool isReader) {
  DateTime now = DateTime.now();
  String newFileName =
      "jidoujisho-" + intl.DateFormat('yyyyMMddTkkmmss').format(now);

  String newImagePath = path.join(
    getAnkiDroidDirectory().path,
    "collection.media/$newFileName.jpg",
  );

  String addImage = "";
  String addAudio = "";

  if (imageFile != null && imageFile.existsSync()) {
    imageFile.copySync(newImagePath);
    addImage = "<img src=\"$newFileName.jpg\">";
  }

  if (answer == "") {
    answer = "​";
  }
  if (isReader && sentence == "") {
    sentence = "​";
  }
  if (meaning == "") {
    meaning = "​";
  }
  if (reading == "") {
    reading = "​";
  }
  requestAnkiDroidPermissions();

  addCreatorNote(
    deck,
    addImage,
    addAudio,
    sentence,
    answer,
    meaning,
    reading,
    isReader,
  );
}
