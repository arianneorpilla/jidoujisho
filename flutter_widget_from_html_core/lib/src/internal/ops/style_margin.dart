part of '../core_ops.dart';

const kCssMargin = 'margin';

Widget _marginHorizontalBuilder(Widget w, CssLengthBox b, TextStyleHtml tsh) =>
    Padding(
      padding: EdgeInsets.only(
        left: max(b.getValueLeft(tsh) ?? 0.0, 0.0),
        right: max(b.getValueRight(tsh) ?? 0.0, 0.0),
      ),
      child: w,
    );

class StyleMargin {
  static const kPriorityBoxModel9k = 9000;

  final WidgetFactory wf;

  StyleMargin(this.wf);

  BuildOp get buildOp => BuildOp(
        onTree: (meta, tree) {
          if (meta.willBuildSubtree == true) return;
          final m = tryParseCssLengthBox(meta, kCssMargin);
          if (m == null || !m.hasPositiveLeftOrRight) return;

          return wrapTree(
            tree,
            append: (p) => WidgetBit.inline(p, _paddingInlineAfter(p.tsb, m)),
            prepend: (p) => WidgetBit.inline(p, _paddingInlineBefore(p.tsb, m)),
          );
        },
        onWidgets: (meta, widgets) {
          if (meta.willBuildSubtree == false) return widgets;
          if (widgets.isEmpty) return widgets;

          final m = tryParseCssLengthBox(meta, kCssMargin);
          if (m == null) return null;
          final tsb = meta.tsb;

          return [
            if (m.top?.isPositive ?? false) HeightPlaceholder(m.top!, tsb),
            for (final widget in widgets)
              if (m.hasPositiveLeftOrRight)
                widget.wrapWith(
                    (c, w) => _marginHorizontalBuilder(w, m, tsb.build(c)))
              else
                widget,
            if (m.bottom?.isPositive ?? false)
              HeightPlaceholder(m.bottom!, tsb),
          ];
        },
        onWidgetsIsOptional: true,
        priority: kPriorityBoxModel9k,
      );
}
