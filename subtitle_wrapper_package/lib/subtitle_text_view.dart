import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jidoujisho/preferences.dart';
import 'package:jidoujisho/util.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:subtitle_wrapper_package/bloc/subtitle/subtitle_bloc.dart';
import 'package:subtitle_wrapper_package/data/constants/view_keys.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';

import 'package:jidoujisho/globals.dart';

class SubtitleTextView extends StatelessWidget {
  final SubtitleStyle subtitleStyle;
  final ValueNotifier<bool> widgetVisibility;
  final ValueNotifier<Subtitle> comprehensionSubtitle;
  final ValueNotifier<Subtitle> contextSubtitle;
  final FocusNode focusNode;
  final VoidCallback emptyStack;

  const SubtitleTextView({
    Key key,
    @required this.subtitleStyle,
    @required this.widgetVisibility,
    @required this.comprehensionSubtitle,
    @required this.contextSubtitle,
    @required this.focusNode,
    @required this.emptyStack,
  }) : super(key: key);

  Widget getOutlineText(String word) {
    return Text(
      word,
      style: TextStyle(
        fontSize: subtitleStyle.fontSize,
        foreground: Paint()
          ..style = subtitleStyle.borderStyle.style
          ..strokeWidth = subtitleStyle.borderStyle.strokeWidth
          ..color = Colors.black.withOpacity(0.75),
      ),
    );
  }

  Widget getText(String word, int index, Subtitle currentSubtitle,
      List<String> indexTape) {
    return InkWell(
      onTap: () {
        emptyStack();
        Clipboard.setData(
          ClipboardData(text: indexTape[index]),
        );

        contextSubtitle.value = currentSubtitle;
      },
      child: Text(
        word,
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
                                  emptyStack();
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
                      List<int> spaceIndexes = [];
                      String processedSubtitles;

                      String originalText = state.subtitle.text.trim();
                      processedSubtitles = originalText.replaceAll('\n', '␜');
                      processedSubtitles =
                          processedSubtitles.replaceAll(' ', '␝');

                      List<String> letters = [];
                      List<String> words = [];

                      processedSubtitles.runes.forEach((int rune) {
                        String character = new String.fromCharCode(rune);
                        letters.add(character);
                        words.add(character);
                      });

                      List<List<String>> lines =
                          getLinesFromWords(context, subtitleStyle, words);
                      List<List<int>> indexes =
                          getIndexesFromWords(context, subtitleStyle, words);

                      for (int i = 0; i < lines.length; i++) {
                        for (int j = 0; j < lines[i].length; j++) {
                          lines[i][j] = lines[i][j].replaceAll('␝', ' ');
                          lines[i][j] = lines[i][j].replaceAll('␜', '');
                        }
                      }

                      for (int i = 0; i < letters.length; i++) {
                        if (letters[i] == '␝') {
                          spaceIndexes.add(i);
                        }
                      }

                      List<dynamic> tokens = gMecabTagger.parse(originalText);
                      tokens.removeLast();
                      tokens.forEach((token) => print(token.surface));

                      List<String> tokenTape = [];
                      for (int i = 0; i < tokens.length; i++) {
                        TokenNode token = tokens[i];
                        for (int j = 0; j < token.surface.length; j++) {
                          tokenTape.add(token.surface);
                        }
                      }

                      for (int i = 0; i < tokenTape.length; i++) {
                        if (spaceIndexes.contains(i)) {
                          tokenTape.insert(i, " ");
                        }
                      }

                      tokenTape.add('');
                      tokenTape.add('');

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
                                          String word = line[i];
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
                                      String word = line[i];
                                      int index = indexList[i];
                                      textWidgets.add(
                                        getText(word, index, state.subtitle,
                                            tokenTape),
                                      );
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
