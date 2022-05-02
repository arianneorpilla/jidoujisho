import 'dart:io';

import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/util/export_paths.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

const MethodChannel ankiDroidMethodChannel =
    MethodChannel('com.lrorpilla.api/ankidroid');

Future<void> requestAnkiDroidPermissions() async {
  await ankiDroidMethodChannel.invokeMethod('requestPermissions');
}

Future<List<String>> getDecks() async {
  Map<dynamic, dynamic> deckMap =
      await ankiDroidMethodChannel.invokeMethod('getDecks');
  List<String> decks = deckMap.values.toList().cast<String>();
  decks.sort((a, b) => a.compareTo(b));

  return decks;
}

Future<String> addMediaFromUri(
  String fileUriPath,
  String preferredName,
  String mimeType,
) async {
  try {
    return await ankiDroidMethodChannel
        .invokeMethod('addMediaFromUri', <String, dynamic>{
      'fileUriPath': fileUriPath,
      'preferredName': preferredName,
      'mimeType': mimeType,
    });
  } on PlatformException catch (e) {
    debugPrint('Failed to add media from URI');
    debugPrint(e.toString());
  }

  return '';
}

Future<void> addNote({
  required AnkiExportParams params,
  String deck = 'Default',
}) async {
  try {
    DateTime now = DateTime.now();
    String newFileName =
        'jidoujisho-' + intl.DateFormat('yyyyMMddTkkmmss').format(now);

    String image = '';
    String audio = '';

    if (params.imageFile != null && params.imageFile!.existsSync()) {
      File exportImageFile = File(getExportImagePath());
      params.imageFile!.copySync(exportImageFile.path);
      image = await addMediaFromUri(
        'file:///${exportImageFile.uri}',
        newFileName,
        'image',
      );
      debugPrint('IMAGE FILE EXPORTED: $image');
    }

    if (params.audioFile != null && params.audioFile!.existsSync()) {
      File exportAudioFile = File(getExportAudioPath());
      params.audioFile!.copySync(exportAudioFile.path);

      audio = await addMediaFromUri(
        'file:///${exportAudioFile.uri}',
        newFileName,
        'audio',
      );
      debugPrint('AUDIO FILE EXPORTED: $audio');
    }

    String sentence = params.sentence;
    String word = params.word;
    String reading = params.reading;
    String meaning = params.meaning;
    String extra = params.extra;
    String context = params.context;

    String zeroWidthSpace = '​';

    if (sentence.isEmpty) {
      sentence = zeroWidthSpace;
    }
    if (word.isEmpty) {
      word = zeroWidthSpace;
    }
    if (reading.isEmpty) {
      reading = zeroWidthSpace;
    }
    if (meaning.isEmpty) {
      meaning = zeroWidthSpace;
    }
    if (extra.isEmpty) {
      extra = zeroWidthSpace;
    }

    await ankiDroidMethodChannel.invokeMethod('addNote', <String, dynamic>{
      'deck': deck,
      'sentence': sentence,
      'word': word,
      'reading': reading,
      'meaning': meaning,
      'image': image,
      'audio': audio,
      'extra': extra,
      'contextParam': context,
    });
  } on PlatformException catch (e) {
    debugPrint('Failed to add note via AnkiDroid API');
    debugPrint(e.toString());
  }
}

Future<void> navigateToCreator({
  required BuildContext context,
  required AppModel appModel,
  AnkiExportParams? initialParams,
  bool editMode = false,
  bool autoMode = false,
  Color? backgroundColor,
  Color? appBarColor,
  bool popOnExport = false,
  bool hideActions = false,
  Function()? exportCallback,
  ThemeData? themeData,
}) async {
  try {
    List<String> decks = await getDecks();

    Future<Widget> buildCreatorPage() async {
      return Future.microtask(() {
        return CreatorPage(
          initialParams: initialParams,
          backgroundColor: backgroundColor,
          appBarColor: appBarColor,
          decks: decks,
          autoMode: autoMode,
          editMode: editMode,
          popOnExport: popOnExport,
          hideActions: hideActions,
          exportCallback: exportCallback,
        );
      });
    }

    Widget creatorPage = await buildCreatorPage();

    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => (themeData != null)
            ? Theme(data: themeData, child: creatorPage)
            : creatorPage,
      ),
    );
  } catch (e) {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          title: Text(
            appModel.translate('ankidroid_api'),
          ),
          content: Text(
            appModel.translate('ankidroid_api_message'),
            textAlign: TextAlign.justify,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                appModel.translate('dialog_launch_ankidroid'),
              ),
              onPressed: () async {
                DeviceApps.openApp('com.ichi2.anki');
                Navigator.pop(context);

                try {
                  List<String> decks = await getDecks();
                  Future<Widget> buildCreatorPage() async {
                    return Future.microtask(() {
                      return CreatorPage(
                        initialParams: initialParams,
                        backgroundColor: backgroundColor,
                        appBarColor: appBarColor,
                        decks: decks,
                        autoMode: autoMode,
                        editMode: editMode,
                        popOnExport: popOnExport,
                        exportCallback: exportCallback,
                      );
                    });
                  }

                  Widget creatorPage = await buildCreatorPage();
                  await Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (_, __, ___) => (themeData != null)
                          ? Theme(data: themeData, child: creatorPage)
                          : creatorPage,
                    ),
                  );
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
            ),
          ],
        );
      },
    );
    debugPrint(e.toString());
  }
}
