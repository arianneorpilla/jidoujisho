import 'package:equatable/equatable.dart';

class Subtitle extends Equatable {
  final Duration startTime;
  final Duration endTime;
  final String text;
  Subtitle nextSubtitle;

  Subtitle({
    this.startTime,
    this.endTime,
    this.text,
    this.nextSubtitle,
  });

  @override
  List<Object> get props => [
        startTime,
        endTime,
        text,
      ];
}
