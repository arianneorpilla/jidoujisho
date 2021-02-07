import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:subtitle_wrapper_package/bloc/subtitle/subtitle_bloc.dart';
import 'package:subtitle_wrapper_package/data/constants/view_keys.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';

class SubtitleTextView extends StatelessWidget {
  final SubtitleStyle subtitleStyle;

  const SubtitleTextView({Key key, @required this.subtitleStyle})
      : super(key: key);

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
          return Container(
            child: Stack(
              children: <Widget>[
                subtitleStyle.hasBorder
                    ? Center(
                        child: Text(
                          state.subtitle.text.replaceAll('\\n', '\n'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleStyle.fontSize,
                            foreground: Paint()
                              ..style = subtitleStyle.borderStyle.style
                              ..strokeWidth =
                                  subtitleStyle.borderStyle.strokeWidth
                              ..color = subtitleStyle.borderStyle.color,
                          ),
                        ),
                      )
                    : Container(
                        child: null,
                      ),
                Center(
                  child: SelectableText(
                    state.subtitle.text.replaceAll('\\n', '\n'),
                    key: ViewKeys.SUBTITLE_TEXT_CONTENT,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: subtitleStyle.fontSize,
                      color: subtitleStyle.textColor,
                    ),
                    toolbarOptions: ToolbarOptions(
                        copy: true, cut: false, selectAll: false, paste: false),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
