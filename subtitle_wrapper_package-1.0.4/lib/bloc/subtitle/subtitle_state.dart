part of 'subtitle_bloc.dart';

abstract class SubtitleState extends Equatable {
  const SubtitleState();
}

class SubtitleInitial extends SubtitleState {
  @override
  List<Object> get props => [];
}

class SubtitleInitializating extends SubtitleState {
  @override
  List<Object> get props => [];
}

class SubtitleInitialized extends SubtitleState {
  @override
  List<Object> get props => [];
}

class LoadingSubtitle extends SubtitleState {
  @override
  List<Object> get props => [];
}

class LoadedSubtitle extends SubtitleState {
  final Subtitle subtitle;

  LoadedSubtitle(this.subtitle);

  @override
  List<Object> get props => [
        subtitle,
      ];
}
