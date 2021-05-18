import 'package:epub_view/src/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EpubReaderTableOfContents extends StatelessWidget {
  const EpubReaderTableOfContents({
    required this.controller,
    this.padding,
    this.itemBuilder,
    this.loader,
    Key? key,
  }) : super(key: key);

  final EdgeInsetsGeometry? padding;
  final EpubController controller;

  final Widget Function(
    BuildContext context,
    int index,
    EpubViewChapter chapter,
    int itemCount,
  )? itemBuilder;
  final Widget? loader;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<EpubViewChapter>?>(
        stream: controller.tableOfContentsStream,
        builder: (_, snapshot) {
          Widget content;

          if (snapshot.hasData) {
            final toc = snapshot.data!;
            content = ListView.builder(
              padding: padding,
              key: Key('$runtimeType.content'),
              itemBuilder: (context, index) =>
                  itemBuilder?.call(context, index, toc[index], toc.length) ??
                  ListTile(
                    title: Text(toc[index].title!.trim()),
                    onTap: () =>
                        controller.scrollTo(index: toc[index].startIndex),
                  ),
              itemCount: toc.length,
            );
          } else {
            content = KeyedSubtree(
              key: Key('$runtimeType.loader'),
              child: loader ?? Center(child: CircularProgressIndicator()),
            );
          }

          return AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) =>
                FadeTransition(child: child, opacity: animation),
            child: content,
          );
        },
      );
}
