import 'package:epub_view/src/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef ChapterBuilder = Widget Function(EpubChapterViewValue? chapter);

class EpubActualChapter extends StatelessWidget {
  const EpubActualChapter({
    required this.controller,
    required this.builder,
    this.loader,
    this.animationAlignment = Alignment.centerLeft,
    Key? key,
  }) : super(key: key);

  final EpubController controller;
  final ChapterBuilder builder;
  final Widget? loader;
  final Alignment animationAlignment;

  @override
  Widget build(BuildContext context) => StreamBuilder<EpubChapterViewValue?>(
        stream: controller.currentValueStream,
        builder: (_, snapshot) {
          Widget content;

          if (snapshot.hasData) {
            content = KeyedSubtree(
              key: Key('$runtimeType.chapter-${snapshot.data!.chapterNumber}'),
              child: builder(snapshot.data),
            );
          } else {
            content = KeyedSubtree(
              key: Key('$runtimeType.loader'),
              child: loader ?? Center(child: CircularProgressIndicator()),
            );
          }

          return AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (Widget child, Animation<double> animation) =>
                SlideTransition(
              child: FadeTransition(child: child, opacity: animation),
              position: Tween<Offset>(
                begin: Offset(0, -0.15),
                end: Offset(0, 0),
              ).animate(animation),
            ),
            layoutBuilder:
                (Widget? currentChild, List<Widget> previousChildren) => Stack(
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
              alignment: animationAlignment,
            ),
            child: content,
          );
        },
      );
}
