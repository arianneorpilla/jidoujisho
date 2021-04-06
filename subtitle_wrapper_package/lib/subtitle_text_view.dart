import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jidoujisho/util.dart';
import 'package:mecab_dart/mecab_dart.dart';
import 'package:subtitle_wrapper_package/bloc/subtitle/subtitle_bloc.dart';
import 'package:subtitle_wrapper_package/data/constants/view_keys.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';

import 'package:jidoujisho/main.dart';

class SubtitleTextView extends StatelessWidget {
  final SubtitleStyle subtitleStyle;
  final FocusNode focusNode;

  const SubtitleTextView({
    Key key,
    @required this.subtitleStyle,
    @required this.focusNode,
  }) : super(key: key);

  Widget getOutlineText(TokenNode token) {
    return Text(
      token.surface.replaceAll('␝', ' '),
      style: TextStyle(
        fontSize: subtitleStyle.fontSize,
        foreground: Paint()
          ..style = subtitleStyle.borderStyle.style
          ..strokeWidth = subtitleStyle.borderStyle.strokeWidth
          ..color = Colors.black.withOpacity(0.75),
      ),
    );
  }

  Widget getText(List<dynamic> tokens, TokenNode token, int index) {
    return InkWell(
      onTap: () {
        String allText = '';
        for (int i = index; i < tokens.length - 1; i++) {
          allText += tokens[i].surface.replaceAll('␝', ' ');
        }

        Clipboard.setData(
          ClipboardData(text: allText),
        );
      },
      child: Text(
        token.surface.replaceAll('␝', ' '),
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
            valueListenable: globalSelectMode,
            builder: (context, selectMode, widget) {
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
                                    ..style = subtitleStyle.borderStyle.style
                                    ..strokeWidth =
                                        subtitleStyle.borderStyle.strokeWidth
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
                          state.subtitle.text,
                          key: ViewKeys.SUBTITLE_TEXT_CONTENT,
                          textAlign: TextAlign.center,
                          onSelectionChanged: (selection, cause) {
                            Clipboard.setData(ClipboardData(
                                text:
                                    selection.textInside(state.subtitle.text)));
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
                var pretokens = state.subtitle.text.replaceAll('\n', '␜');
                var tokens = mecabTagger.parse(pretokens.replaceAll(' ', '␝'));

                List<List<dynamic>> lines = getLinesFromTokens(tokens);
                List<List<int>> indexes = getIndexesFromTokens(tokens);
                print("MECAB TOKENS");
                print(lines);

                return Container(
                  child: Stack(
                    children: <Widget>[
                      subtitleStyle.hasBorder
                          ? Center(
                              child: SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: lines.length,
                                  itemBuilder:
                                      (BuildContext context, int lineIndex) {
                                    List<dynamic> line = lines[lineIndex];
                                    List<Widget> textWidgets = [];

                                    for (int i = 0; i < line.length; i++) {
                                      TokenNode token = line[i];
                                      textWidgets.add(getOutlineText(token));
                                    }

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: textWidgets,
                                    );
                                  },
                                ),
                              ),
                            )
                          : Container(
                              child: null,
                            ),
                      Center(
                        child: Center(
                          child: SingleChildScrollView(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: lines.length,
                              itemBuilder:
                                  (BuildContext context, int lineIndex) {
                                List<dynamic> line = lines[lineIndex];
                                List<int> indexList = indexes[lineIndex];
                                List<Widget> textWidgets = [];

                                for (int i = 0; i < line.length; i++) {
                                  TokenNode token = line[i];
                                  int index = indexList[i];
                                  textWidgets
                                      .add(getText(tokens, token, index));
                                }

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: textWidgets,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      // Center(
                      //   child: SelectableText(
                      //     state.subtitle.text,
                      //     key: ViewKeys.SUBTITLE_TEXT_CONTENT,
                      //     textAlign: TextAlign.center,
                      //     style: TextStyle(
                      //       fontSize: subtitleStyle.fontSize,
                      //       color: subtitleStyle.textColor,
                      //     ),
                      //     toolbarOptions: ToolbarOptions(
                      //         copy: true, cut: false, selectAll: false, paste: false),
                      //   ),
                      // ),
                    ],
                  ),
                );

                // return Container(
                //   child: Stack(
                //     children: <Widget>[
                //       subtitleStyle.hasBorder
                //           ? Center(
                //               child: SingleChildScrollView(
                //                 scrollDirection: Axis.horizontal,
                //                 child: Wrap(
                //                   crossAxisAlignment: WrapCrossAlignment.end,
                //                   children: List<Widget>.generate(
                //                       tokens.length - 1, (index) {
                //                     TokenNode token = tokens[index];

                //                     return Text(
                //                       token.surface.replaceAll('␝', ' '),
                //                       style: TextStyle(
                //                         fontSize: subtitleStyle.fontSize,
                //                         foreground: Paint()
                //                           ..style =
                //                               subtitleStyle.borderStyle.style
                //                           ..strokeWidth = subtitleStyle
                //                               .borderStyle.strokeWidth
                //                           ..color =
                //                               Colors.black.withOpacity(0.75),
                //                       ),
                //                     );
                //                   }),
                //                 ),
                //               ),
                //             )
                //           : Container(
                //               child: null,
                //             ),
                //       Center(
                //         child: SingleChildScrollView(
                //           scrollDirection: Axis.horizontal,
                //           child: Wrap(
                //             crossAxisAlignment: WrapCrossAlignment.end,
                //             children: List<Widget>.generate(tokens.length - 1,
                //                 (index) {
                //               TokenNode token = tokens[index];

                //               return GestureDetector(
                //                 onTap: () {
                //                   String allText = "";
                //                   for (int i = index; i < tokens.length; i++) {
                //                     allText +=
                //                         tokens[i].surface.replaceAll('␝', ' ');
                //                   }

                //                   Clipboard.setData(
                //                     ClipboardData(text: allText),
                //                   );
                //                 },
                //                 child: Text(
                //                   token.surface.replaceAll('␝', ' '),
                //                   style: TextStyle(
                //                     fontSize: subtitleStyle.fontSize,
                //                   ),
                //                 ),
                //               );
                //             }),
                //           ),
                //         ),
                //       ),
                //       // Center(
                //       //   child: SelectableText(
                //       //     state.subtitle.text,
                //       //     key: ViewKeys.SUBTITLE_TEXT_CONTENT,
                //       //     textAlign: TextAlign.center,
                //       //     style: TextStyle(
                //       //       fontSize: subtitleStyle.fontSize,
                //       //       color: subtitleStyle.textColor,
                //       //     ),
                //       //     toolbarOptions: ToolbarOptions(
                //       //         copy: true, cut: false, selectAll: false, paste: false),
                //       //   ),
                //       // ),
                //     ],
                //   ),
                // );
              }
            },
          );
        } else {
          return Container();
        }
      },
    );
  }
}
