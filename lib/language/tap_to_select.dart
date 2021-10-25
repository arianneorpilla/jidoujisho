import 'package:flutter/material.dart';

List<List<String>> getLinesFromWords(
    BuildContext context, List<String> words, double fontSize) {
  List<List<String>> lines = [];
  List<String> working = [];
  String concatenate = "";
  TextPainter textPainter;
  double width = MediaQuery.of(context).size.width;
  words.add("");

  for (int i = 0; i < words.length; i++) {
    String word = words[i];
    textPainter = TextPainter()
      ..text = TextSpan(
        text: concatenate + word,
        style: TextStyle(fontSize: fontSize),
      )
      ..textDirection = TextDirection.ltr
      ..layout(minWidth: 0, maxWidth: double.infinity);

    if (word.contains('␜') ||
        i == words.length - 1 ||
        textPainter.width >= width - 60) {
      List<String> line = [];
      for (int i = 0; i < working.length; i++) {
        line.add(working[i]);
      }

      lines.add(line);
      working = [];
      concatenate = "";

      working.add(word);
      concatenate += word;
    } else {
      working.add(word);
      concatenate += word;
    }
  }

  return lines;
}

List<List<int>> getIndexesFromWords(
  BuildContext context,
  List<String> words,
  double fontSize,
) {
  words.add("");

  List<List<int>> lines = [];
  List<int> working = [];
  String concatenate = "";
  TextPainter textPainter;

  double width = MediaQuery.of(context).size.width;

  for (int i = 0; i < words.length; i++) {
    String word = words[i];
    textPainter = TextPainter()
      ..text = TextSpan(
          text: concatenate + word,
          style: TextStyle(
            fontSize: fontSize,
          ))
      ..textDirection = TextDirection.ltr
      ..layout(minWidth: 0, maxWidth: double.infinity);

    if (word.contains('␜') ||
        i == words.length - 1 ||
        textPainter.width >= width - 60) {
      List<int> line = [];
      for (int i = 0; i < working.length; i++) {
        line.add(working[i]);
      }

      lines.add(line);
      working = [];
      concatenate = "";

      working.add(i);
      concatenate += word;
    } else {
      working.add(i);
      concatenate += word;
    }
  }

  return lines;
}
