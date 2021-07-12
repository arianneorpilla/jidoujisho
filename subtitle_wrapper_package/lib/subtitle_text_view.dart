import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:jidoujisho/util.dart';
import 'package:subtitle_wrapper_package/bloc/subtitle/subtitle_bloc.dart';
import 'package:subtitle_wrapper_package/data/constants/view_keys.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';
import 'package:ve_dart/ve_dart.dart';

import 'package:jidoujisho/globals.dart';

class SubtitleTextView extends StatelessWidget {
  final VlcPlayerController videoPlayerController;
  final SubtitleStyle subtitleStyle;
  final ValueNotifier<bool> widgetVisibility;
  final ValueNotifier<Subtitle> comprehensionSubtitle;
  final ValueNotifier<Subtitle> contextSubtitle;
  final VoidCallback emptyStack;
  final FocusNode focusNode;
  final ValueNotifier<double> fontSize;
  final ValueNotifier<String> regexFilter;

  const SubtitleTextView({
    Key key,
    @required this.videoPlayerController,
    @required this.subtitleStyle,
    @required this.widgetVisibility,
    @required this.comprehensionSubtitle,
    @required this.contextSubtitle,
    @required this.focusNode,
    @required this.emptyStack,
    @required this.fontSize,
    @required this.regexFilter,
  }) : super(key: key);

  Widget getOutlineText(Word word) {
    return Text(
      word.word,
      style: TextStyle(
        fontSize: fontSize.value,
        foreground: Paint()
          ..style = subtitleStyle.borderStyle.style
          ..strokeWidth = subtitleStyle.borderStyle.strokeWidth
          ..color = Colors.black.withOpacity(0.75),
      ),
    );
  }

  Widget getText(Word word, int index, Subtitle currentSubtitle) {
    return InkWell(
      onTap: () {
        emptyStack();
        Clipboard.setData(
          ClipboardData(text: word.word),
        );

        contextSubtitle.value = currentSubtitle;
      },
      child: Text(
        word.word,
        style: TextStyle(
          fontSize: fontSize.value,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var subtitleBloc = BlocProvider.of<SubtitleBloc>(context);
    return BlocConsumer<SubtitleBloc, SubtitleState>(
      listener: (context, state) {
        if (state is SubtitleInitialized) {
          subtitleBloc.add(LoadSubtitle());
        }
      },
      builder: (context, state) {
        if (state is LoadedSubtitle) {
          return ValueListenableBuilder(
              valueListenable: gIsSelectMode,
              builder: (context, selectMode, widget) {
                return ValueListenableBuilder(
                    valueListenable: widgetVisibility,
                    builder: (context, visible, widget) {
                      if (!visible) {
                        return Container();
                      }

                      Subtitle currentSubtitle = state.subtitle;
                      String subtitleText = currentSubtitle.text;

                      if (regexFilter.value.isNotEmpty) {
                        subtitleText = subtitleText.replaceAll(
                            RegExp(regexFilter.value), "");
                      }

                      if (getLatinFilterMode()) {
                        subtitleText =
                            stripLatinCharactersFromText(subtitleText);
                      }

                      if (getListeningComprehensionMode()) {
                        if (comprehensionSubtitle.value == null ||
                            (widgetVisibility.value &&
                                comprehensionSubtitle.value != null &&
                                (comprehensionSubtitle.value.startTime -
                                            Duration(seconds: 10) >
                                        currentSubtitle.startTime ||
                                    comprehensionSubtitle.value.endTime <
                                        currentSubtitle.endTime))) {
                          if (widgetVisibility.value) {
                            widgetVisibility.value = false;
                          }

                          if (videoPlayerController.value.isPlaying) {
                            return Container();
                          }
                        }
                      }

                      if (selectMode) {
                        return dragToSelectWidget(subtitleText);
                      } else {
                        return tapToSelectWidget(
                            context, subtitleText, currentSubtitle);
                      }
                    });
              });
        } else {
          return Container();
        }
      },
    );
  }

  StatelessWidget dragToSelectWidget(String subtitleText) {
    return Container(
      child: Stack(
        children: <Widget>[
          subtitleStyle.hasBorder
              ? Center(
                  child: SelectableText(
                    subtitleText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize.value,
                      foreground: Paint()
                        ..style = subtitleStyle.borderStyle.style
                        ..strokeWidth = subtitleStyle.borderStyle.strokeWidth
                        ..color = Colors.black.withOpacity(0.75),
                    ),
                    enableInteractiveSelection: false,
                  ),
                )
              : Container(
                  child: null,
                ),
          Center(
            child: SelectableText(
              subtitleText,
              key: ViewKeys.SUBTITLE_TEXT_CONTENT,
              textAlign: TextAlign.center,
              onSelectionChanged: (selection, cause) {
                emptyStack();
                Clipboard.setData(
                    ClipboardData(text: selection.textInside(subtitleText)));
              },
              style: TextStyle(
                fontSize: fontSize.value,
                color: subtitleStyle.textColor,
              ),
              focusNode: focusNode,
              toolbarOptions: ToolbarOptions(
                  copy: false, cut: false, selectAll: false, paste: false),
            ),
          ),
        ],
      ),
    );
  }

  StatelessWidget tapToSelectWidget(
      BuildContext context, String subtitleText, Subtitle currentSubtitle) {
    String processedSubtitles;
    processedSubtitles = subtitleText.replaceAll('\n', '␜');
    processedSubtitles = processedSubtitles.replaceAll(' ', '␝');

    List<Word> words = parseVe(gMecabTagger, processedSubtitles);

    List<List<Word>> lines = getLinesFromWords(
      context,
      subtitleStyle,
      words,
      fontSize.value,
    );
    List<List<int>> indexes = getIndexesFromWords(
      context,
      subtitleStyle,
      words,
      fontSize.value,
    );

    for (Word word in words) {
      word.word = word.word.replaceAll('␝', ' ');
      word.word = word.word.replaceAll('␜', '');
    }
    return Container(
      child: Stack(
        children: <Widget>[
          subtitleStyle.hasBorder
              ? Center(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: lines.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int lineIndex) {
                      List<dynamic> line = lines[lineIndex];
                      List<Widget> textWidgets = [];

                      for (int i = 0; i < line.length; i++) {
                        Word word = line[i];
                        textWidgets.add(getOutlineText(word));
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: textWidgets,
                      );
                    },
                  ),
                )
              : Container(
                  child: null,
                ),
          Center(
            child: Center(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: lines.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int lineIndex) {
                  List<dynamic> line = lines[lineIndex];
                  List<int> indexList = indexes[lineIndex];
                  List<Widget> textWidgets = [];

                  for (int i = 0; i < line.length; i++) {
                    Word word = line[i];
                    int index = indexList[i];
                    textWidgets.add(
                      getText(
                        word,
                        index,
                        currentSubtitle,
                      ),
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: textWidgets,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
