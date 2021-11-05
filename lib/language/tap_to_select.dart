import 'package:flutter/material.dart';

List<List<String>> getLinesFromCharacters(
    BuildContext context, List<String> characters, double fontSize) {
  List<List<String>> lines = [];
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
      for (int i = 0; i < working.length; i++) {
        line.add(working[i]);
      }

      lines.add(line);
      working = [];
      concatenate = "";

      if (character != '\n') {
        working.add(character);
        concatenate += character;
      }
    } else {
      working.add(character);
      concatenate += character;
    }
  }

  return lines;
}

List<List<int>> getIndexesFromWords(
  BuildContext context,
  List<String> characters,
  double fontSize,
) {
  characters.add("");

  List<List<int>> lines = [];
  List<int> working = [];
  String concatenate = "";
  TextPainter textPainter;

  double width = MediaQuery.of(context).size.width;

  for (int i = 0; i < characters.length; i++) {
    String character = characters[i];
    textPainter = TextPainter()
      ..text = TextSpan(
          text: concatenate + character,
          style: TextStyle(
            fontSize: fontSize,
          ))
      ..textDirection = TextDirection.ltr
      ..layout(minWidth: 0, maxWidth: double.infinity);

    if (character.contains('\n') ||
        i == characters.length - 1 ||
        textPainter.width >= width - 60) {
      List<int> line = [];
      for (int i = 0; i < working.length; i++) {
        line.add(working[i]);
      }

      lines.add(line);
      working = [];
      concatenate = "";

      if (character != '\n') {
        working.add(i);
        concatenate += character;
      }
    } else {
      working.add(i);
      concatenate += character;
    }
  }

  return lines;
}
