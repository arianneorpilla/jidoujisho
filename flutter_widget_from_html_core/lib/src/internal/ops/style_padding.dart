part of '../core_ops.dart';

const kCssPadding = 'padding';

WidgetPlaceholder _paddingInlineAfter(TextStyleBuilder tsb, CssLengthBox box) =>
    WidgetPlaceholder<CssLengthBox>(box).wrapWith((context, _) =>
        _paddingInlineSizedBox(box.getValueRight(tsb.build(context))));

WidgetPlaceholder _paddingInlineBefore(TextStyleBuilder tsb, CssLengthBox b) =>
    WidgetPlaceholder<CssLengthBox>(b).wrapWith((context, _) =>
        _paddingInlineSizedBox(b.getValueLeft(tsb.build(context))));

Widget _paddingInlineSizedBox(double? width) =>
    width != null && width > 0 ? SizedBox(width: width) : widget0;

class StylePadding {
  static const kPriorityBoxModel3k = 3000;

  final WidgetFactory wf;

  StylePadding(this.wf);

  BuildOp get buildOp => BuildOp(
        onTree: (meta, tree) {
          if (meta.willBuildSubtree == true) return;
          final padding = tryParseCssLengthBox(meta, kCssPadding);
          if (padding == null || !padding.hasPositiveLeftOrRight) return;

          return wrapTree(
            tree,
            append: (p) =>
                WidgetBit.inline(p, _paddingInlineAfter(p.tsb, padding)),
            prepend: (p) =>
                WidgetBit.inline(p, _paddingInlineBefore(p.tsb, padding)),
          );
        },
        onWidgets: (meta, widgets) {
          if (meta.willBuildSubtree == false) return widgets;
          if (widgets.isEmpty) return widgets;

          final padding = tryParseCssLengthBox(meta, kCssPadding);
          if (padding == null) return null;

          return listOrNull(wf
              .buildColumnPlaceholder(meta, widgets)
              ?.wrapWith((c, w) => _build(c, meta, w, padding)));
        },
        onWidgetsIsOptional: true,
        priority: kPriorityBoxModel3k,
      );

  Widget? _build(BuildContext context, BuildMetadata meta, Widget child,
      CssLengthBox padding) {
    final tsh = meta.tsb.build(context);
    return wf.buildPadding(
      meta,
      child,
      EdgeInsets.fromLTRB(
        max(padding.getValueLeft(tsh) ?? 0.0, 0.0),
        max(padding.top?.getValue(tsh) ?? 0.0, 0.0),
        max(padding.getValueRight(tsh) ?? 0.0, 0.0),
        max(padding.bottom?.getValue(tsh) ?? 0.0, 0.0),
      ),
    );
  }
}
