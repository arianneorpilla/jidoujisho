import 'package:equatable/equatable.dart';

class Subtitle extends Equatable {
  final Duration startTime;
  final Duration endTime;
  final String text;

  Subtitle({this.startTime, this.endTime, this.text});

  @override
  List<Object> get props => [
        startTime,
        endTime,
        text,
      ];
}
