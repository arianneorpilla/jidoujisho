import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jidoujisho/dictionary.dart';
import 'package:jidoujisho/globals.dart';

class PitchAccentInformation {
  int number;
  String partOfSpeech = "";

  PitchAccentInformation({
    this.number,
    this.partOfSpeech = "",
  });

  Map<String, dynamic> toMap() {
    return {
      "number": this.number,
      "partOfSpeech": this.partOfSpeech,
    };
  }

  PitchAccentInformation.fromMap(Map<String, dynamic> map) {
    this.number = map['number'] as int;
    this.partOfSpeech = map['partOfSpeech'];
  }
}

FutureOr<List<DictionaryEntry>> initializeKanjiumEntries() async {
  List<DictionaryEntry> entries = [];

  String kanjiumRaw = await rootBundle.loadString("assets/kanjium/accents.txt");

  List<String> kanjiumLines = kanjiumRaw.split("\n");
  List<List<String>> kanjiumFields = [];

  kanjiumLines.forEach((line) => {kanjiumFields.add(line.split("\t"))});

  kanjiumFields.forEach(
    (field) {
      DictionaryEntry entry = (DictionaryEntry(
          word: field[0],
          reading: field[1],
          meaning: "",
          searchTerm: "",
          pitchAccentEntries: parseKanjiumNumbers(field[2])));
      entries.add(entry);

      print(entry);
    },
  );

  return entries;
}

List<PitchAccentInformation> parseKanjiumNumbers(String numbers) {
  List<PitchAccentInformation> pitches = [];

  List<String> splitNumbers = numbers.split(",");

  splitNumbers.forEach((number) {
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
  });

  return pitches;
}

String getHtmlPitch(String reading, PitchAccentInformation pitch) {
  String htmlPitch = "";

  if (pitch.partOfSpeech != "") {
    htmlPitch += "<span>[<b>${pitch.partOfSpeech}</b>]</span> ";
  }

  List<String> units = [];
  for (int i = 0; i < reading.length; i++) {
    String current = reading[i];
    String next;
    if (i + 1 < reading.length) {
      next = reading[i + 1];
    }

    if (next != null && "ゃゅょぁぃぅぇぉっャュョァィゥェォッ".contains(next)) {
      units.add(current + next);
      i += 1;
      continue;
    } else {
      units.add(current);
    }
  }

  if (pitch.number == 0) {
    htmlPitch += units[0];
    htmlPitch += "<span class=\"pitch\">";
    for (int i = 1; i < units.length; i++) {
      htmlPitch += units[i];
    }
    htmlPitch += "</span>";
  } else {
    List<int> beforePitchNumbers = [];
    for (int i = 0; i < units.length; i++) {
      if (i < pitch.number - 1) {
        beforePitchNumbers.add(i);
      }
    }

    int firstBeforePitchNumber = -1;
    int lastBeforePitchNumber = -1;
    if (beforePitchNumbers.isNotEmpty) {
      firstBeforePitchNumber = beforePitchNumbers.first;
      lastBeforePitchNumber = beforePitchNumbers.last;
    }

    for (int i = 0; i < units.length; i++) {
      if (i == firstBeforePitchNumber) {
        htmlPitch += "<span class=\"pitch\">";
      } else if (i == pitch.number - 1) {
        htmlPitch += "<span class=\"pitch_end\">";
      }
      htmlPitch += units[i];
      if (i == lastBeforePitchNumber || i == pitch.number - 1) {
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
      decoration: BoxDecoration(
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
      decoration: BoxDecoration(
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
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 2.0, color: Colors.transparent),
        ),
      ),
      child: Text(text),
    );
  }

  if (pitch.partOfSpeech != "") {
    listWidgets.add(Text("["));
    listWidgets.add(
      Text(
        "${pitch.partOfSpeech}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    listWidgets.add(Text("] "));
  }

  List<String> units = [];
  for (int i = 0; i < reading.length; i++) {
    String current = reading[i];
    String next;
    if (i + 1 < reading.length) {
      next = reading[i + 1];
    }

    if (next != null && "ゃゅょぁぃぅぇぉっャュョァィゥェォッ".contains(next)) {
      units.add(current + next);
      i += 1;
      continue;
    } else {
      units.add(current);
    }
  }

  if (pitch.number == 0) {
    for (int i = 0; i < units.length; i++) {
      if (i == 0) {
        listWidgets.add(getAccentNone(units[i]));
      } else {
        listWidgets.add(getAccentTop(units[i]));
      }
    }
  } else {
    for (int i = 0; i < units.length; i++) {
      if (i == 0 && i != pitch.number - 1) {
        listWidgets.add(getAccentNone(units[i]));
      } else if (i < pitch.number - 1) {
        listWidgets.add(getAccentTop(units[i]));
      } else if (i == pitch.number - 1) {
        listWidgets.add(getAccentEnd(units[i]));
      } else {
        listWidgets.add(getAccentNone(units[i]));
      }
    }
  }

  return Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: listWidgets,
  );
}

DictionaryEntry getClosestPitchEntry(DictionaryEntry entry) {
  String firstReading = sanitizeGooForPitchMatch(entry.reading).first;
  print(firstReading);

  List<DictionaryEntry> readingMatches = gKanjiumDictionary
      .where((pitchEntry) => pitchEntry.reading == firstReading)
      .toList();

  print(sanitizeGooForPitchMatch(entry.word));

  return readingMatches.firstWhere(
      (pitchEntry) =>
          sanitizeGooForPitchMatch(entry.word).contains(pitchEntry.word),
      orElse: () {
    return null;
  });
}

List<String> sanitizeGooForPitchMatch(String text) {
  List<String> sanitized = [];
  String fixedGooTitle = text.replaceAll("／", ";");
  fixedGooTitle = fixedGooTitle.replaceAll("×", ";");

  if (fixedGooTitle.contains(";")) {
    List<String> splitLine = fixedGooTitle.split(";");
    splitLine.forEach((line) {
      String sanitizedLine = line;

      if (line.contains("〔")) {
        sanitizedLine = line.substring(0, line.indexOf("〔"));
      }

      sanitizedLine = sanitizedLine.replaceAll(" ", "");
      sanitizedLine = sanitizedLine.replaceAll("‐", "");
      sanitizedLine = sanitizedLine.replaceAll("▽", "");
      sanitizedLine = sanitizedLine.replaceAll("△", "");
      sanitizedLine = sanitizedLine.replaceAll("・", "");
      sanitizedLine = sanitizedLine.replaceAll("◦", "");

      sanitized.add(sanitizedLine);
    });
  } else {
    String sanitizedLine = fixedGooTitle;

    if (fixedGooTitle.contains("〔")) {
      sanitizedLine = fixedGooTitle.substring(0, fixedGooTitle.indexOf("〔"));
    }

    sanitizedLine = sanitizedLine.replaceAll(" ", "");
    sanitizedLine = sanitizedLine.replaceAll("‐", "");
    sanitizedLine = sanitizedLine.replaceAll("▽", "");
    sanitizedLine = sanitizedLine.replaceAll("△", "");
    sanitizedLine = sanitizedLine.replaceAll("・", "");
    sanitizedLine = sanitizedLine.replaceAll("◦", "");

    sanitized.add(sanitizedLine);
  }

  return sanitized;
}

Widget getAllPitchWidgets(DictionaryEntry entry) {
  List<Widget> listWidgets = [];
  for (int i = 0; i < entry.pitchAccentEntries.length; i++) {
    listWidgets.add(getPitchWidget(entry.reading, entry.pitchAccentEntries[i]));
    listWidgets.add(SizedBox(height: 5));
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: listWidgets,
  );
}

String getAllHtmlPitch(DictionaryEntry entry) {
  String allPitches = "";

  for (int i = 0; i < entry.pitchAccentEntries.length; i++) {
    allPitches += getHtmlPitch(entry.reading, entry.pitchAccentEntries[i]);
    if (i != entry.pitchAccentEntries.length - 1) {
      allPitches += "<br>";
    }
  }

  return allPitches;
}
