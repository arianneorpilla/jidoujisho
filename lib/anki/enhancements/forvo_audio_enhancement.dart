import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class ForvoResult {
  ForvoResult({
    required this.audioUrl,
    required this.contributor,
  });

  String audioUrl;
  String contributor;
}

class ForvoAudioEnhancement extends AnkiExportEnhancement {
  ForvoAudioEnhancement({
    required AppModel appModel,
  }) : super(
          appModel: appModel,
          enhancementName: 'Forvo Audio',
          enhancementDescription:
              'Search for matching word pronunciations from Forvo.',
          enhancementIcon: Icons.record_voice_over,
          enhancementField: AnkiExportField.audio,
        );

  Map<String, List<ForvoResult>> forvoCache = {};

  @override
  Future<AnkiExportParams> enhanceParams({
    required BuildContext context,
    required AppModel appModel,
    required AnkiExportParams params,
    required bool autoMode,
    required CreatorPageState state,
  }) async {
    Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);

    /// If audio exists, and it is not an image from search, do nothing and
    /// keep the current image.
    if (!state.audioSearchingNotifier.value && params.audioFile != null) {
      return params;
    }

    String searchTerm = '';

    if (params.audioSearch.trim().isNotEmpty) {
      searchTerm = params.audioSearch;
    } else if (params.word.trim().isNotEmpty) {
      searchTerm = params.word;
    } else {
      return params;
    }

    ValueNotifier<List<bool>> indexesSelected;
    List<Widget> textWidgets;

    String cacheKey = '${appModel.getCurrentLanguage()}/$searchTerm';
    List<ForvoResult> results = [];

    if (forvoCache[cacheKey] != null) {
      results = forvoCache[cacheKey]!;
    } else {
      var client = http.Client();
      http.Response response =
          await client.get(Uri.parse('https://forvo.com/word/$searchTerm/'));
      var document = parser.parse(response.body);

      try {
        List<dom.Element> liElements = document
            .getElementById(
                'language-container-${appModel.getCurrentLanguage().languageCode}')!
            .children
            .first
            .getElementsByClassName('show-all-pronunciations')
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

        forvoCache[cacheKey] = results;
      } catch (e) {
        if (autoMode) {
          params.audioSearch = '';
          params.audioFile = null;

          state.notifyAudioNotSearching();

          return params;
        }
      }
    }

    if (results.isEmpty) {
      return params;
    }

    AudioPlayer audioPlayer = AudioPlayer();

    Directory appDirDoc = await getApplicationDocumentsDirectory();
    String forvoAudioPath = '${appDirDoc.path}/forvoAudio';
    Directory forvoAudioDir = Directory(forvoAudioPath);
    if (forvoAudioDir.existsSync()) {
      forvoAudioDir.deleteSync(recursive: true);
    }
    forvoAudioDir.createSync();

    if (autoMode) {
      int selectedIndex = 0;
      ForvoResult result = results[selectedIndex];

      File file = File('$forvoAudioPath/$selectedIndex.mp3');
      http.Response request = await http.get(Uri.parse(result.audioUrl));
      Uint8List bytes = request.bodyBytes;
      await file.writeAsBytes(bytes);

      params.audioSearch = '';
      params.audioFile = file;

      state.notifyAudioSearching();
    } else {
      indexesSelected = ValueNotifier<List<bool>>(
        List.generate(
          results.length,
          (index) => index == 0,
        ),
      );

      textWidgets = getTextWidgetsFromResults(
        results,
        indexesSelected,
        audioPlayer,
      );

      ScrollController scrollController = ScrollController();

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            shape: const RoundedRectangleBorder(),
            content: SizedBox(
              width: double.maxFinite,
              child: RawScrollbar(
                thumbColor: (appModel.getIsDarkMode())
                    ? Colors.grey[700]
                    : Colors.grey[400],
                controller: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: ValueListenableBuilder(
                    valueListenable: indexesSelected,
                    builder: (context, _, widget) {
                      return Wrap(children: textWidgets);
                    },
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  appModel.translate('dialog_set'),
                ),
                onPressed: () async {
                  int selectedIndex = indexesSelected.value.indexOf(true);
                  ForvoResult result = results[selectedIndex];

                  File file = File('$forvoAudioPath/$selectedIndex.mp3');
                  http.Response request =
                      await http.get(Uri.parse(result.audioUrl));
                  Uint8List bytes = request.bodyBytes;
                  await file.writeAsBytes(bytes);

                  params.audioSearch = '';
                  params.audioFile = file;

                  state.notifyAudioSearching();

                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    audioPlayer.stop();
    audioPlayer.dispose();

    return params;
  }

  List<Widget> getTextWidgetsFromResults(
    List<ForvoResult> results,
    ValueNotifier<List<bool>> notifier,
    AudioPlayer audioPlayer,
  ) {
    List<Widget> widgets = [];
    for (int i = 0; i < results.length; i++) {
      widgets.add(
        GestureDetector(
          onTap: () {
            List<bool> values = List.generate(
              results.length,
              (index) => index == i,
            );
            notifier.value = [...values];
          },
          child: ValueListenableBuilder(
              valueListenable: notifier,
              builder: (context, values, child) {
                if (notifier.value[i]) {
                  audioPlayer.stop().then((_) {
                    audioPlayer.setUrl(results[i].audioUrl).then((_) {
                      audioPlayer.play();
                    });
                  });
                }

                return Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 10, right: 10),
                  color: (notifier.value[i])
                      ? Colors.red.withOpacity(0.3)
                      : (Theme.of(context).backgroundColor == Colors.black)
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.record_voice_over),
                      const SizedBox(width: 10),
                      Text(
                        results[i].contributor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ),
      );
    }

    return widgets;
  }
}
