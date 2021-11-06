import 'package:flutter/material.dart';

class TapToSelectInfo {
  TapToSelectInfo(this.lines, this.lineIndexes);

  List<List<String>> lines;
  List<List<int>> lineIndexes;
}

TapToSelectInfo getLinesFromCharacters(
  BuildContext context,
  List<String> characters,
  double fontSize,
) {
  List<List<String>> lines = [];
  List<List<int>> lineIndexes = [];

  List<int> workingIndexes = [];
  List<String> working = [];
  String concatenate = "";
  TextPainter textPainter;
  double width = MediaQuery.of(context).size.width;
  characters.add("");

  for (int i = 0; i < characters.length; i++) {
    String character = characters[i];
    textPainter = TextPainter()
      ..text = TextSpan(
        text: concatenate + character,
        style: TextStyle(fontSize: fontSize),
      )
      ..textDirection = TextDirection.ltr
      ..layout(minWidth: 0, maxWidth: double.infinity);

    if (character.contains('\n') ||
        i == characters.length - 1 ||
        textPainter.width >= width - 60) {
      List<String> line = [];
      List<int> lineIndex = [];
      for (int i = 0; i < working.length; i++) {
        line.add(working[i]);
        lineIndex.add(workingIndexes[i]);
      }

      lines.add(line);
      lineIndexes.add(lineIndex);

      concatenate = "";

      if (character != '\n') {
        working.add(character);
        workingIndexes.add(i);
        concatenate += character;
      }
    } else {
      working.add(character);
      workingIndexes.add(i);
      concatenate += character;
    }
  }

  return TapToSelectInfo(lines, lineIndexes);
}
