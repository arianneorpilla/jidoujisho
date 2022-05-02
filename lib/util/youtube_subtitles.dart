import 'package:chisa/util/time_format.dart';

String timedLineToSRT(Map<String, dynamic> line, int lineCount) {
  double start = double.parse(line['begin']);
  double duration = double.parse(line['end']);
  String text = line['\$'];
  text = text = text.replaceAll('\\\\n', '\n');

  String startTime = formatTimeString(start);
  String endTime = formatTimeString(start + duration);
  String lineNumber = lineCount.toString();

  String srtLine = '$lineNumber\n$startTime --> $endTime\n$text\n\n';

  return srtLine;
}
