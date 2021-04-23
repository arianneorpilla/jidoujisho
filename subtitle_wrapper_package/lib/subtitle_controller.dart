import 'package:flutter/material.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';
import 'package:subtitle_wrapper_package/bloc/subtitle/subtitle_bloc.dart';

class SubtitleController {
  String subtitlesContent;
  String subtitleUrl;
  final bool showSubtitles;
  final ValueNotifier<Subtitle> subtitleNotifier;
  SubtitleDecoder subtitleDecoder;
  SubtitleType subtitleType;
  int subtitlesOffset;

  bool _attached = false;
  SubtitleBloc subtitleBloc;

  SubtitleController({
    this.subtitleUrl,
    this.subtitlesContent,
    this.showSubtitles = true,
    this.subtitleDecoder,
    this.subtitleType = SubtitleType.webvtt,
    this.subtitleNotifier,
    this.subtitlesOffset = 0,
  });

  void attach(SubtitleBloc bloc) {
    if (subtitleBloc == null) {
      subtitleBloc = bloc;
      _attached = true;
    }
  }

  void detach() {
    _attached = false;
    subtitleBloc = null;
  }

  void updateSubtitleUrl({
    @required url,
  }) {
    if (_attached) {
      subtitleUrl = url;
      subtitleBloc.add(
        InitSubtitles(
          subtitleController: this,
        ),
      );
    } else {
      print('Seems that the controller is not correctly attached.');
    }
  }

  void updateSubtitleContent({
    @required content,
  }) {
    if (_attached) {
      subtitlesContent = content;
      subtitleBloc.add(
        InitSubtitles(
          subtitleController: this,
        ),
      );
    } else {
      print('Seems that the controller is not correctly attached.');
    }
  }
}

enum SubtitleDecoder {
  utf8,
  latin1,
}

enum SubtitleType {
  webvtt,
  srt,
}
