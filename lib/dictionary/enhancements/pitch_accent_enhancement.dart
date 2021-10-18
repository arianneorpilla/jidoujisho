import 'dart:async';
import 'dart:convert';
import 'package:chisa/dictionary/dictionary_entry.dart';
import 'package:chisa/dictionary/dictionary_widget_enhancement.dart';
import 'package:chisa/models/app_model.dart';
import 'package:chisa/util/dictionary_widget_field.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PitchAccentInformation {
  int? number;
  String partOfSpeech = "";

  PitchAccentInformation({
    this.number,
    this.partOfSpeech = "",
  });

  Map<String, dynamic> toMap() {
    return {
      "number": number,
      "partOfSpeech": partOfSpeech,
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
          enhancementName: "Pitch Accent Diagrams",
          enhancementDescription: "Show pitch accent diagrams over a reading.",
          enhancementIcon: Icons.record_voice_over,
          enhancementField: DictionaryWidgetField.reading,
        );

  final List<DictionaryEntry> kanjiumDictionary = [];

  @override
  Future<void> initialiseEnhancement() async {
    String kanjiumRaw =
        await rootBundle.loadString("assets/kanjium/accents.txt");

    List<String> kanjiumLines = kanjiumRaw.split("\n");
    List<List<String>> kanjiumFields = [];

    for (String line in kanjiumLines) {
      kanjiumFields.add(line.split("\t"));
    }

    for (List<String> field in kanjiumFields) {
      String pitchAccentListMap = jsonEncode(parseKanjiumNumbers(field[2])
          .map((pitchInfo) => pitchInfo.toMap())
          .toList());

      DictionaryEntry entry = DictionaryEntry(
        word: field[0],
        reading: field[1],
        extra: pitchAccentListMap,
      );
      kanjiumDictionary.add(entry);
    }
  }

  @override
  Widget? buildReading(DictionaryEntry entry) {
    DictionaryEntry? closestReadingMatch = getClosestPitchEntry(entry);
    if (closestReadingMatch == null) {
      return null;
    }

    return getAllPitchWidgets(entry, jsonDecode(closestReadingMatch.extra));
  }

  List<PitchAccentInformation> parseKanjiumNumbers(String numbers) {
    List<PitchAccentInformation> pitches = [];

    List<String> splitNumbers = numbers.split(",");

    for (String number in splitNumbers) {
      PitchAccentInformation pitch;

      if (!number.contains("(")) {
        pitch = PitchAccentInformation(
          number: int.parse(number),
        );
      } else {
        String partOfSpeechRaw =
            number.substring(number.indexOf("(") + 1, number.indexOf(")"));
        int indexRaw = int.parse(number.substring(number.indexOf(")") + 1));

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
    String htmlPitch = "";

    if (pitch.partOfSpeech != "") {
      htmlPitch += "<span>[<b>${pitch.partOfSpeech}</b>]</span> ";
    }

    List<String> moras = [];
    for (int i = 0; i < reading.length; i++) {
      String current = reading[i];
      String? next;
      if (i + 1 < reading.length) {
        next = reading[i + 1];
      }

      if (next != null && "ゃゅょぁぃぅぇぉャュョァィゥェォ".contains(next)) {
        moras.add(current + next);
        i += 1;
        continue;
      } else {
        moras.add(current);
      }
    }

    if (pitch.number == 0) {
      htmlPitch += moras[0];
      htmlPitch += "<span class=\"pitch\">";
      for (int i = 1; i < moras.length; i++) {
        htmlPitch += moras[i];
      }
      htmlPitch += "</span>";
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
          htmlPitch += "<span class=\"pitch\">";
        } else if (i == pitch.number! - 1) {
          htmlPitch += "<span class=\"pitch_end\">";
        }
        htmlPitch += moras[i];
        if (i == lastBeforePitchNumber || i == pitch.number! - 1) {
          htmlPitch += "</span>";
        }
      }
    }

    return htmlPitch;
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

    if (pitch.partOfSpeech != "") {
      listWidgets.add(const Text("["));
      listWidgets.add(
        Text(
          pitch.partOfSpeech,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      listWidgets.add(const Text("] "));
    }

    List<String> moras = [];
    for (int i = 0; i < reading.length; i++) {
      String current = reading[i];
      String? next;
      if (i + 1 < reading.length) {
        next = reading[i + 1];
      }

      if (next != null && "ゃゅょぁぃぅぇぉャュョァィゥェォ".contains(next)) {
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
    if (firstReading.contains(";")) {
      firstReading = entry.reading.split(";").first;
    }

    List<DictionaryEntry> readingMatches = kanjiumDictionary
        .where((pitchEntry) => pitchEntry.reading == firstReading)
        .toList();

    return readingMatches.firstWhereOrNull(
      (pitchEntry) => entry.word.contains(pitchEntry.word),
    );
  }

  Widget getAllPitchWidgets(DictionaryEntry entry, List<dynamic> pitchJsons) {
    List<Widget> listWidgets = [];
    String reading = entry.reading;
    if (reading.isEmpty) {
      reading = entry.word;
    }

    List<PitchAccentInformation> pitchAccentEntries = pitchJsons
        .map((entryJson) => PitchAccentInformation.fromMap(entryJson))
        .toList();

    for (int i = 0; i < pitchAccentEntries.length; i++) {
      listWidgets.add(getPitchWidget(reading, pitchAccentEntries[i]));
      listWidgets.add(const SizedBox(height: 5));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: listWidgets,
    );
  }

  String getAllHtmlPitch(DictionaryEntry entry) {
    String allPitches = "";
    String reading = entry.reading;
    if (reading.isEmpty) {
      reading = entry.word;
    }

    List<Map<String, dynamic>> entryJsons = jsonDecode(entry.extra);
    List<PitchAccentInformation> pitchAccentEntries = entryJsons
        .map((entryJson) => PitchAccentInformation.fromMap(entryJson))
        .toList();

    for (int i = 0; i < pitchAccentEntries.length; i++) {
      allPitches += getHtmlPitch(reading, pitchAccentEntries[i]);
      if (i != pitchAccentEntries.length - 1) {
        allPitches += "\n";
      }
    }

    return allPitches;
  }
}
