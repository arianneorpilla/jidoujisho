import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:jidoujisho/util.dart';
import 'package:subtitle_wrapper_package/bloc/subtitle/subtitle_bloc.dart';
import 'package:subtitle_wrapper_package/data/constants/view_keys.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';
import 'package:ve_dart/ve_dart.dart';

import 'package:jidoujisho/globals.dart';

class SubtitleTextView extends StatelessWidget {
  final SubtitleStyle subtitleStyle;
  final ValueNotifier<bool> widgetVisibility;
  final ValueNotifier<Subtitle> comprehensionSubtitle;
  final FocusNode focusNode;

  const SubtitleTextView({
    Key key,
    @required this.subtitleStyle,
    @required this.widgetVisibility,
    @required this.comprehensionSubtitle,
    @required this.focusNode,
  }) : super(key: key);

  Widget getOutlineText(Word word) {
    return Text(
      word.word,
      style: TextStyle(
        fontSize: subtitleStyle.fontSize,
        foreground: Paint()
          ..style = subtitleStyle.borderStyle.style
          ..strokeWidth = subtitleStyle.borderStyle.strokeWidth
          ..color = Colors.black.withOpacity(0.75),
      ),
    );
  }

  Widget getText(Word word, int index) {
    return InkWell(
      onTap: () {
        Clipboard.setData(
          ClipboardData(text: word.word),
        );
      },
      child: Text(
        word.word,
        style: TextStyle(
          fontSize: subtitleStyle.fontSize,
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
                  builder: (context, visibility, widget) {
                    if (!visibility) {
                      return Container();
                    }

                    if (getListeningComprehensionMode()) {
                      if (comprehensionSubtitle.value == null ||
                          (visibility &&
                              comprehensionSubtitle.value != null &&
                              (comprehensionSubtitle.value.startTime -
                                          Duration(seconds: 10) >
                                      state.subtitle.startTime ||
                                  comprehensionSubtitle.value.endTime <
                                      state.subtitle.endTime))) {
                        widgetVisibility.value = false;
                        return Container();
                      }
                    }

                    if (selectMode) {
                      return Container(
                        child: Stack(
                          children: <Widget>[
                            subtitleStyle.hasBorder
                                ? Center(
                                    child: SelectableText(
                                      state.subtitle.text,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: subtitleStyle.fontSize,
                                        foreground: Paint()
                                          ..style =
                                              subtitleStyle.borderStyle.style
                                          ..strokeWidth = subtitleStyle
                                              .borderStyle.strokeWidth
                                          ..color =
                                              Colors.black.withOpacity(0.75),
                                      ),
                                      enableInteractiveSelection: false,
                                    ),
                                  )
                                : Container(
                                    child: null,
                                  ),
                            Center(
                              child: SelectableText(
                                state.subtitle.text,
                                key: ViewKeys.SUBTITLE_TEXT_CONTENT,
                                textAlign: TextAlign.center,
                                onSelectionChanged: (selection, cause) {
                                  Clipboard.setData(ClipboardData(
                                      text: selection
                                          .textInside(state.subtitle.text)));
                                },
                                style: TextStyle(
                                  fontSize: subtitleStyle.fontSize,
                                  color: subtitleStyle.textColor,
                                ),
                                focusNode: focusNode,
                                toolbarOptions: ToolbarOptions(
                                    copy: false,
                                    cut: false,
                                    selectAll: false,
                                    paste: false),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      String processedSubtitles;
                      processedSubtitles =
                          state.subtitle.text.replaceAll('\n', '␜');
                      processedSubtitles =
                          processedSubtitles.replaceAll(' ', '␝');

                      // ignore: omit_local_variable_types
                      List<Word> words =
                          parseVe(gMecabTagger, processedSubtitles);
                      print(words);

                      List<List<Word>> lines =
                          getLinesFromWords(context, subtitleStyle, words);
                      List<List<int>> indexes =
                          getIndexesFromWords(context, subtitleStyle, words);

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
                                      itemBuilder: (BuildContext context,
                                          int lineIndex) {
                                        List<dynamic> line = lines[lineIndex];
                                        List<Widget> textWidgets = [];

                                        for (int i = 0; i < line.length; i++) {
                                          Word word = line[i];
                                          textWidgets.add(getOutlineText(word));
                                        }

                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
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
                                  itemBuilder:
                                      (BuildContext context, int lineIndex) {
                                    List<dynamic> line = lines[lineIndex];
                                    List<int> indexList = indexes[lineIndex];
                                    List<Widget> textWidgets = [];

                                    for (int i = 0; i < line.length; i++) {
                                      Word word = line[i];
                                      int index = indexList[i];
                                      textWidgets.add(getText(word, index));
                                    }

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
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
                  },
                );
              });
        } else {
          return Container();
        }
      },
    );
  }
}
