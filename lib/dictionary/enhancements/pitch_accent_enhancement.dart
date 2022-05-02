import 'dart:async';

import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_widget_enhancement.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/dictionary_widget_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PitchAccentInformation {
  int? number;
  String partOfSpeech = '';

  PitchAccentInformation({
    this.number,
    this.partOfSpeech = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'partOfSpeech': partOfSpeech,
    };
  }

  PitchAccentInformation.fromMap(Map<String, dynamic> map) {
    number = map['number'];
    partOfSpeech = map['partOfSpeech'];
  }
}

class PitchAccentEnhancement extends DictionaryWidgetEnhancement {
  PitchAccentEnhancement({required AppModel appModel})
      : super(
          appModel: appModel,
          enhancementName: 'Pitch Accent Diagrams',
          enhancementDescription: 'Show pitch accent diagrams over a reading.',
          enhancementIcon: Icons.record_voice_over,
          enhancementField: DictionaryWidgetField.reading,
        );

  final Map<String, Map<String, DictionaryEntry>> kanjiumDictionary = {};

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

  @override
  Widget? buildReading(DictionaryEntry entry) {
    if (kanjiumDictionary[entry.word] == null ||
        kanjiumDictionary[entry.word]![entry.reading] == null) {
      return null;
    } else {
      return getAllPitchWidgets(kanjiumDictionary[entry.word]![entry.reading]!);
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

  Widget getPitchWidget(String reading, PitchAccentInformation pitch) {
    List<Widget> listWidgets = [];

    Widget getAccentTop(String text) {
      return Container(
        padding: const EdgeInsets.only(top: 1),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(width: 2.0, color: Colors.red),
          ),
        ),
        child: Text(text),
      );
    }

    Widget getAccentEnd(String text) {
      return Container(
        padding: const EdgeInsets.only(top: 1),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(width: 2.0, color: Colors.red),
            right: BorderSide(width: 2.0, color: Colors.red),
          ),
        ),
        child: Text(text),
      );
    }

    Widget getAccentNone(String text) {
      return Container(
        padding: const EdgeInsets.only(top: 1),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(width: 2.0, color: Colors.transparent),
          ),
        ),
        child: Text(text),
      );
    }

    if (pitch.partOfSpeech != '') {
      listWidgets.add(const Text('['));
      listWidgets.add(
        Text(
          pitch.partOfSpeech,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      listWidgets.add(const Text('] '));
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
      for (int i = 0; i < moras.length; i++) {
        if (i == 0) {
          listWidgets.add(getAccentNone(moras[i]));
        } else {
          listWidgets.add(getAccentTop(moras[i]));
        }
      }
    } else {
      for (int i = 0; i < moras.length; i++) {
        if (i == 0 && i != pitch.number! - 1) {
          listWidgets.add(getAccentNone(moras[i]));
        } else if (i < pitch.number! - 1) {
          listWidgets.add(getAccentTop(moras[i]));
        } else if (i == pitch.number! - 1) {
          listWidgets.add(getAccentEnd(moras[i]));
        } else {
          listWidgets.add(getAccentNone(moras[i]));
        }
      }
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: listWidgets,
    );
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

  Widget getAllPitchWidgets(DictionaryEntry entry) {
    List<Widget> listWidgets = [];
    String reading = entry.reading;
    if (reading.isEmpty) {
      reading = entry.word;
    }

    List<PitchAccentInformation> pitch = entry.workingArea['pitch_accent'];

    for (int i = 0; i < pitch.length; i++) {
      listWidgets.add(getPitchWidget(reading, pitch[i]));
      listWidgets.add(const SizedBox(height: 5));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: listWidgets,
    );
  }
}
