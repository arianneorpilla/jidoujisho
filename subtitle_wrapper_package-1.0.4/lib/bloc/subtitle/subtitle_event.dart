part of 'subtitle_bloc.dart';

abstract class SubtitleEvent {
  const SubtitleEvent();
}

class InitSubtitles extends SubtitleEvent {
  final SubtitleController subtitleController;

  InitSubtitles({@required this.subtitleController});
}

class LoadSubtitle extends SubtitleEvent {}

class UpdateLoadedSubtitle extends SubtitleEvent {
  final Subtitle subtitle;

  UpdateLoadedSubtitle({this.subtitle});
}
