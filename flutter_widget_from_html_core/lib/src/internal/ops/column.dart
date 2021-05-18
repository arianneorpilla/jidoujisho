part of '../core_ops.dart';

class ColumnPlaceholder extends WidgetPlaceholder<BuildMetadata> {
  final BuildMetadata meta;
  final bool trimMarginVertical;
  final WidgetFactory wf;

  final Iterable<Widget> _children;

  ColumnPlaceholder(
    this._children, {
    required this.meta,
    required this.trimMarginVertical,
    required this.wf,
  }) : super(meta);

  @override
  Widget build(BuildContext context) {
    final tsh = meta.tsb.build(context);
    return wf.buildColumnWidget(meta, tsh, getChildren(context)) ?? widget0;
  }

  List<Widget> getChildren(BuildContext context) {
    final contents = <Widget>[];

    HeightPlaceholder? marginBottom, marginTop;
    Widget? prev;
    var state = 0;

    for (final child in _getIterable(context)) {
      if (state == 0) {
        if (child is HeightPlaceholder) {
          if (!trimMarginVertical) {
            if (marginTop != null) {
              marginTop.mergeWith(child);
            } else {
              marginTop = child;
            }
          }
        } else {
          state++;
        }
      }

      if (state == 1) {
        if (child is HeightPlaceholder && prev is HeightPlaceholder) {
          prev.mergeWith(child);
          continue;
        }

        contents.add(child);
        prev = child;
      }
    }

    if (contents.isNotEmpty) {
      final lastWidget = contents.last;
      if (lastWidget is HeightPlaceholder) {
        contents.removeLast();

        if (!trimMarginVertical) marginBottom = lastWidget;
      }
    }

    final tsh = meta.tsb.build(context);
    final column = wf.buildColumnWidget(meta, tsh, contents);

    return [
      if (marginTop != null) marginTop,
      if (column != null) callBuilders(context, column),
      if (marginBottom != null) marginBottom,
    ];
  }

  Iterable<Widget> _getIterable(BuildContext context) sync* {
    for (var child in _children) {
      if (child == widget0) continue;

      if (child is ColumnPlaceholder) {
        for (final grandChild in child.getChildren(context)) {
          yield grandChild;
        }
        continue;
      }

      yield child;
    }
  }
}
