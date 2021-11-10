import 'dart:convert';

import 'package:chisa/util/time_format.dart';
import 'package:flutter/material.dart';
import 'package:xml2json/xml2json.dart';

String youtubeCaptionsToSrt(String xml) {
  final Xml2Json xml2Json = Xml2Json();
  xml2Json.parse(xml);

  String json = xml2Json.toGData();
  Map<String, dynamic> data = jsonDecode(json);

  print(data["tt"]["body"]["region"]["r1"]);

  String convertedLines = "";
  int lineCount = 0;

  // for (var line in lines) {
  //   String convertedLine = timedLineToSRT(line, lineCount++);
  //   convertedLines = convertedLines + convertedLine;
  // }

  return convertedLines;
}

String timedLineToSRT(Map<String, dynamic> line, int lineCount) {
  double start = double.parse(line["begin"]);
  double duration = double.parse(line["end"]);
  String text = line["\$"];
  text = text = text.replaceAll("\\\\n", "\n");

  String startTime = formatTimeString(start);
  String endTime = formatTimeString(start + duration);
  String lineNumber = lineCount.toString();

  String srtLine = "$lineNumber\n$startTime --> $endTime\n$text\n\n";

  return srtLine;
}
