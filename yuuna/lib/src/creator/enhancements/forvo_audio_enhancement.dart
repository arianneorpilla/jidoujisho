import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yuuna/creator.dart';
import 'package:yuuna/language.dart';
import 'package:yuuna/models.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:yuuna/pages.dart';

/// An entity used to neatly return and organise results fetched from Forvo.
class ForvoResult {
  /// Define a result with the given parameters.
  ForvoResult({
    required this.audioUrl,
    required this.contributor,
  });

  /// The URL of the audio recording.
  String audioUrl;

  /// The contributor to attribute the recording to.
  String contributor;
}

/// An enhancement for fetching audio from Forvo.
class ForvoAudioEnhancement extends AudioEnhancement {
  /// Initialise this enhancement with the hardset parameters.
  ForvoAudioEnhancement()
      : super(
          uniqueKey: key,
          label: 'Forvo Audio',
          description: 'Get word audio from Forvo.',
          icon: Icons.spatial_audio_off,
          field: AudioField.instance,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'forvo_audio';

  final Map<String, List<ForvoResult>> _forvoCache = {};

  /// Client used to communicate with Forvo.
  final http.Client _client = http.Client();

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

    Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);

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

    Language language = appModel.targetLanguage;
    String cacheKey = '${language.languageCode}/$searchTerm';

    List<ForvoResult> results = [];

    if (_forvoCache[cacheKey] != null) {
      results = _forvoCache[cacheKey]!;
    } else {
      http.Response response =
          await _client.get(Uri.parse('https://forvo.com/word/$searchTerm/'));
      var document = parser.parse(response.body);

      try {
        List<dom.Element> liElements = document
            .getElementsByClassName('pronunciations-list-ja')
            .first
            .children
            .where((element) =>
                element.localName == 'li' &&
                element.children.first.id.startsWith('play_'))
            .toList();

        results = liElements.map((element) {
          String onClick = element.children[0].attributes['onclick']!;
          String? contributor = element.children[1].attributes['data-p2'];

          if (contributor == null) {
            element.children
                .where((child) =>
                    child.className == 'more' || child.className == 'from')
                .toList()
                .forEach((child) => child.remove());

            contributor = element.text
                .replaceAll(
                    RegExp(r'[\s\S]*?(?=Pronunciation by)Pronunciation by'), '')
                .trim();
          }

          String onClickCut = onClick.substring(onClick.indexOf(',') + 2);
          String base64 = onClickCut.substring(0, onClickCut.indexOf("'"));

          String fileUrl = stringToBase64Url.decode(base64);

          String audioUrl = 'https://audio.forvo.com/mp3/$fileUrl';

          return ForvoResult(
            audioUrl: audioUrl,
            contributor: contributor,
          );
        }).toList();

        _forvoCache[cacheKey] = results;
      } catch (error) {
        debugPrint('$error');
      }
    }

    Directory appDirDoc = await getApplicationDocumentsDirectory();
    String forvoAudioPath = '${appDirDoc.path}/forvoAudio';
    Directory forvoAudioDir = Directory(forvoAudioPath);
    if (forvoAudioDir.existsSync()) {
      forvoAudioDir.deleteSync(recursive: true);
    }
    forvoAudioDir.createSync();

    if (cause != EnhancementTriggerCause.manual) {
      if (results.isNotEmpty) {
        int index = 0;
        ForvoResult result = results[index];

        File file = File('$forvoAudioPath/$index.mp3');
        http.Response request = await http.get(Uri.parse(result.audioUrl));
        Uint8List bytes = request.bodyBytes;
        await file.writeAsBytes(bytes);

        await audioField.setAudio(
          appModel: appModel,
          creatorModel: creatorModel,
          searchTerm: searchTerm!,
          newAutoCannotOverride: false,
          cause: cause,
          generateAudio: () async {
            return file;
          },
        );
      }
    } else {
      await showDialog(
        context: context,
        builder: (context) => ForvoAudioDialogPage(
          results: results,
          onSelect: (index) async {
            File file = File('$forvoAudioPath/$index.mp3');
            http.Response request =
                await http.get(Uri.parse(results[index].audioUrl));
            Uint8List bytes = request.bodyBytes;
            await file.writeAsBytes(bytes);

            await audioField.setAudio(
              appModel: appModel,
              creatorModel: creatorModel,
              searchTerm: searchTerm!,
              newAutoCannotOverride: false,
              cause: cause,
              generateAudio: () async {
                return file;
              },
            );
          },
        ),
      );
    }
  }

  @override
  Future<File?> fetchAudio({
    required BuildContext context,
    required String term,
    required String reading,
  }) {
    throw UnimplementedError();
  }
}
