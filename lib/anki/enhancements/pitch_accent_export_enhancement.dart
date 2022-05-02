import 'dart:async';

import 'package:chisa/anki/anki_export_enhancement.dart';
import 'package:chisa/anki/anki_export_params.dart';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/enhancements/pitch_accent_enhancement.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/pages/creator_page.dart';
import 'package:chisa/util/anki_export_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PitchAccentExportEnhancement extends AnkiExportEnhancement {
  PitchAccentExportEnhancement({required AppModel appModel})
      : super(
          appModel: appModel,
          enhancementName: 'Pitch Accent Export Diagrams',
          enhancementDescription:
              'Generate HTML pitch accent diagrams to replace a plain text reading.',
          enhancementIcon: Icons.record_voice_over,
          enhancementField: AnkiExportField.reading,
        );

  final Map<String, Map<String, DictionaryEntry>> kanjiumDictionary = {};

  @override
  Future<AnkiExportParams> enhanceParams({
    required BuildContext context,
    required AppModel appModel,
    required AnkiExportParams params,
    required bool autoMode,
    required CreatorPageState state,
  }) async {
    DictionaryEntry? closestReadingMatch = getClosestPitchEntry(
      DictionaryEntry(
        word: params.word,
        reading: params.reading,
      ),
    );
    if (closestReadingMatch != null) {
      params.reading = getAllHtmlPitch(closestReadingMatch);
    }

    return params;
  }

  @override
  Future<void> initialiseEnhancement() async {
    String kanjiumRaw =
        await rootBundle.loadString('assets/kanjium/accents.txt');

    List<String> kanjiumLines = kanjiumRaw.split('\n');
    List<List<String>> kanjiumFields = [];

    for (String line in kanjiumLines) {
      kanjiumFields.add(line.split('\t'));
    }

    for (List<String> field in kanjiumFields) {
      List<PitchAccentInformation> pitch = parseKanjiumNumbers(field[2]);

      DictionaryEntry entry = DictionaryEntry(
        word: field[0],
        reading: field[1],
      );
      entry.workingArea['pitch_accent'] = pitch;

      if (kanjiumDictionary[entry.word] == null) {
        kanjiumDictionary[entry.word] = {};
      }

      kanjiumDictionary[entry.word]![entry.reading] = entry;
    }
  }

  List<PitchAccentInformation> parseKanjiumNumbers(String numbers) {
    List<PitchAccentInformation> pitches = [];

    List<String> splitNumbers = numbers.split(',');

    for (String number in splitNumbers) {
      PitchAccentInformation pitch;

      if (!number.contains('(')) {
        pitch = PitchAccentInformation(
          number: int.parse(number),
        );
      } else {
        String partOfSpeechRaw =
            number.substring(number.indexOf('(') + 1, number.indexOf(')'));
        int indexRaw = int.parse(number.substring(number.indexOf(')') + 1));

        pitch = PitchAccentInformation(
          partOfSpeech: partOfSpeechRaw,
          number: indexRaw,
        );
      }

      pitches.add(pitch);
    }

    return pitches;
  }

  String getHtmlPitch(String reading, PitchAccentInformation pitch) {
    String htmlPitch = '';

    if (pitch.partOfSpeech != '') {
      htmlPitch += '<span>[<b>${pitch.partOfSpeech}</b>]</span> ';
    }

    List<String> moras = [];
    for (int i = 0; i < reading.length; i++) {
      String current = reading[i];
      String? next;
      if (i + 1 < reading.length) {
        next = reading[i + 1];
      }

      if (next != null && 'ゃゅょぁぃぅぇぉャュョァィゥェォ'.contains(next)) {
        moras.add(current + next);
        i += 1;
        continue;
      } else {
        moras.add(current);
      }
    }

    if (pitch.number == 0) {
      htmlPitch += moras[0];
      htmlPitch += '<span class=\"pitch\">';
      for (int i = 1; i < moras.length; i++) {
        htmlPitch += moras[i];
      }
      htmlPitch += '</span>';
    } else {
      List<int> beforePitchNumbers = [];
      for (int i = 1; i < moras.length; i++) {
        if (i < pitch.number! - 1) {
          beforePitchNumbers.add(i);
        }
      }

      int firstBeforePitchNumber = -1;
      int lastBeforePitchNumber = -1;
      if (beforePitchNumbers.isNotEmpty) {
        firstBeforePitchNumber = beforePitchNumbers.first;
        lastBeforePitchNumber = beforePitchNumbers.last;
      }

      for (int i = 0; i < moras.length; i++) {
        if (i == firstBeforePitchNumber) {
          htmlPitch += '<span class=\"pitch\">';
        } else if (i == pitch.number! - 1) {
          htmlPitch += '<span class=\"pitch_end\">';
        }
        htmlPitch += moras[i];
        if (i == lastBeforePitchNumber || i == pitch.number! - 1) {
          htmlPitch += '</span>';
        }
      }
    }

    return htmlPitch;
  }

  DictionaryEntry? getClosestPitchEntry(DictionaryEntry entry) {
    String firstReading = entry.reading;
    if (firstReading.contains(';')) {
      firstReading = entry.reading.split(';').first;
    }

    if (kanjiumDictionary[entry.word] == null ||
        kanjiumDictionary[entry.word]![entry.reading] == null) {
      return null;
    } else {
      return kanjiumDictionary[entry.word]![entry.reading];
    }
  }

  String getAllHtmlPitch(DictionaryEntry entry) {
    String allPitches = '';
    String reading = entry.reading;
    if (reading.isEmpty) {
      reading = entry.word;
    }

    List<PitchAccentInformation> pitchAccentEntries =
        entry.workingArea['pitch_accent'] ?? [];

    for (int i = 0; i < pitchAccentEntries.length; i++) {
      allPitches += getHtmlPitch(reading, pitchAccentEntries[i]);
      if (i != pitchAccentEntries.length - 1) {
        allPitches += '<br>';
      }
    }

    return allPitches;
  }
}
