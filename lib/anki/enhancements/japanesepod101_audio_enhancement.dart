import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kana_kit/kana_kit.dart';
import 'package:path_provider/path_provider.dart';

class JapanesePod101AudioEnhancement extends AnkiExportEnhancement {
  JapanesePod101AudioEnhancement({
    required AppModel appModel,
  }) : super(
          appModel: appModel,
          enhancementName: "JapanesePod101 Audio",
          enhancementDescription:
              "Search for matching word pronunciations from JapanesePod101.",
          enhancementIcon: Icons.record_voice_over,
          enhancementField: AnkiExportField.audio,
        );

  KanaKit kanaKit = const KanaKit();

  @override
  Future<AnkiExportParams> enhanceParams({
    required BuildContext context,
    required AppModel appModel,
    required AnkiExportParams params,
    required bool autoMode,
    required CreatorPageState state,
  }) async {
    Directory appDirDoc = await getApplicationDocumentsDirectory();
    String jpdAudioPath = "${appDirDoc.path}/japanesePod101";
    Directory jpdAudioDir = Directory(jpdAudioPath);
    if (jpdAudioDir.existsSync()) {
      jpdAudioDir.deleteSync(recursive: true);
    }
    jpdAudioDir.createSync();

    /// If audio exists, and it is not an image from search, do nothing and
    /// keep the current image.
    if (!state.audioSearchingNotifier.value && params.audioFile != null) {
      return params;
    }

    String searchTerm = "";

    if (params.audioSearch.trim().isNotEmpty) {
      searchTerm = params.audioSearch;
    } else if (params.word.trim().isNotEmpty) {
      searchTerm = params.word;
    } else {
      return params;
    }

    late String audioUrl;

    if (params.audioSearch.isEmpty) {
      if (kanaKit.isKana(searchTerm)) {
        audioUrl =
            "http://assets.languagepod101.com/dictionary/japanese/audiomp3.php?kana=${params.word}";
      } else {
        String reading = params.reading;
        reading = reading.split("\n").first;
        reading = reading.replaceAll(
            RegExp(r'(<[^>]*>)', multiLine: true, caseSensitive: true), "");
        reading = reading.replaceAll(r"\[([^\[\]]++|(?R))*+\]", "");
        reading = reading.trim();

        audioUrl =
            "http://assets.languagepod101.com/dictionary/japanese/audiomp3.php?kanji=${params.word}&kana=$reading";
      }
    } else {
      if (kanaKit.isKana(params.audioSearch)) {
        audioUrl =
            "http://assets.languagepod101.com/dictionary/japanese/audiomp3.php?kana=${params.audioSearch}";
      } else {
        String reading = params.reading;
        reading = reading.split("\n").first;
        reading = reading.replaceAll(
            RegExp(r'(<[^>]*>)', multiLine: true, caseSensitive: true), "");
        reading = reading.replaceAll(r"\[([^\[\]]++|(?R))*+\]", "");
        reading = reading.trim();

        audioUrl =
            "http://assets.languagepod101.com/dictionary/japanese/audiomp3.php?kanji=${params.audioSearch}&kana=$reading";
      }
    }

    File file = File('$jpdAudioPath/audio.mp3');
    http.Response request = await http.get(Uri.parse(audioUrl));

    if (request.contentLength == 52288 || request.statusCode != 200) {
      return params;
    }

    Uint8List bytes = request.bodyBytes;
    await file.writeAsBytes(bytes);

    params.audioSearch = "";
    params.audioFile = file;

    state.notifyAudioSearching();

    return params;
  }
}
