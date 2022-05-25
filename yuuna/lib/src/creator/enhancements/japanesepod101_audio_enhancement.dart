import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/models.dart';
import 'package:http/http.dart' as http;

/// An enhancement for fetching audio from JapanesePod101.
class JapanesePod101AudioEnhancement extends AudioEnhancement {
  /// Initialise this enhancement with the hardset parameters.
  JapanesePod101AudioEnhancement()
      : super(
          uniqueKey: key,
          label: 'JapanesePod101 Audio',
          description:
              'Search for matching word pronunciations from JapanesePod101.',
          icon: Icons.record_voice_over,
          field: AudioField.instance,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'jpd101_audio';

  final KanaKit _kanaKit = const KanaKit();

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    AudioExportField audioField = field as AudioExportField;
    String? searchTerm;

    if (cause != EnhancementTriggerCause.auto) {
      searchTerm = audioField.getSearchTermWithFallback(
        appModel: appModel,
        creatorModel: creatorModel,
        fallbackSearchTerms: [
          TermField.instance,
          ReadingField.instance,
        ],
      );
    } else {
      searchTerm = creatorModel.getFieldController(TermField.instance).text;

      if (searchTerm.trim().isEmpty) {
        return;
      }
    }

    /// Show loading state.
    audioField.setSearching(
        appModel: appModel,
        creatorModel: creatorModel,
        isSearching: true,
        searchTerm: searchTerm!);
    try {
      String reading =
          creatorModel.getFieldController(ReadingField.instance).text;
      File? file = await fetchAudio(
        term: searchTerm,
        reading: reading,
      );

      if (file != null) {
        audioField.setAudioFile(
          appModel: appModel,
          creatorModel: creatorModel,
          file: file,
          searchTermUsed: searchTerm,
        );
      }
    } finally {
      /// Finish loading state.
      audioField.setSearching(
        appModel: appModel,
        creatorModel: creatorModel,
        isSearching: false,
        searchTerm: searchTerm,
      );
    }
  }

  @override
  Future<File?> fetchAudio(
      {required String term, required String reading}) async {
    Directory appDirDoc = await getApplicationSupportDirectory();
    String jpdAudioPath = '${appDirDoc.path}/japanesePod101';
    Directory jpdAudioDir = Directory(jpdAudioPath);
    if (jpdAudioDir.existsSync()) {
      jpdAudioDir.deleteSync(recursive: true);
    }
    jpdAudioDir.createSync();

    late String audioUrl;

    if (_kanaKit.isKana(term)) {
      audioUrl =
          'http://assets.languagepod101.com/dictionary/japanese/audiomp3.php?kana=$term';
    } else {
      audioUrl =
          'http://assets.languagepod101.com/dictionary/japanese/audiomp3.php?kanji=$term&kana=$reading';
    }

    File file = File('$jpdAudioPath/$term-$reading.mp3');
    http.Response request = await http.get(Uri.parse(audioUrl));

    if (request.contentLength == 52288 || request.statusCode != 200) {
      return null;
    }

    Uint8List bytes = request.bodyBytes;
    file.writeAsBytesSync(bytes);

    return file;
  }
}
