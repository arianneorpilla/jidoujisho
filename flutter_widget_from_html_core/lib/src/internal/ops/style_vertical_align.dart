part of '../core_ops.dart';

const kCssVerticalAlign = 'vertical-align';
const kCssVerticalAlignBaseline = 'baseline';
const kCssVerticalAlignTop = 'top';
const kCssVerticalAlignBottom = 'bottom';
const kCssVerticalAlignMiddle = 'middle';
const kCssVerticalAlignSub = 'sub';
const kCssVerticalAlignSuper = 'super';

class StyleVerticalAlign {
  static const kPriority4500 = 4500;

  final WidgetFactory wf;

  static final _skipBuilding = Expando<bool>();

  StyleVerticalAlign(this.wf);

  BuildOp get buildOp => BuildOp(
        onTree: (meta, tree) {
          if (meta.willBuildSubtree == true) return;

          final v = meta[kCssVerticalAlign]?.term;
          if (v == null || v == kCssVerticalAlignBaseline) return;

          final alignment = _tryParsePlaceholderAlignment(v);
          if (alignment == null) return;

          _skipBuilding[meta] = true;
          final built = _buildTree(meta, tree);
          if (built == null) return;

          if (v == kCssVerticalAlignSub || v == kCssVerticalAlignSuper) {
            built.wrapWith(
              (context, child) => _buildPaddedAlign(
                context,
                meta,
                child,
                EdgeInsets.only(
                  bottom: v == kCssVerticalAlignSuper ? .4 : 0,
                  top: v == kCssVerticalAlignSub ? .4 : 0,
                ),
              ),
            );
          }

          tree.replaceWith(WidgetBit.inline(tree, built, alignment: alignment));
        },
        onWidgets: (meta, widgets) {
          if (_skipBuilding[meta] == true || widgets.isEmpty) {
            return widgets;
          }

          final v = meta[kCssVerticalAlign]?.term;
          if (v == null) return widgets;

          _skipBuilding[meta] = true;
          return listOrNull(wf
              .buildColumnPlaceholder(meta, widgets)
              ?.wrapWith((context, child) {
            final tsh = meta.tsb.build(context);
            final alignment = _tryParseAlignmentGeometry(tsh.textDirection, v);
            if (alignment == null) return child;
            return wf.buildAlign(meta, child, alignment);
          }));
        },
        onWidgetsIsOptional: true,
        priority: kPriority4500,
      );

  WidgetPlaceholder? _buildTree(BuildMetadata meta, BuildTree tree) {
    final bits = tree.bits.toList(growable: false);
    if (bits.length == 1) {
      final firstBit = bits.first;
      if (firstBit is WidgetBit) {
        // use the first widget if possible
        // and avoid creating a redundant `RichText`
        return firstBit.child;
      }
    }

    final copied = tree.copyWith() as BuildTree;
    return wf.buildColumnPlaceholder(meta, copied.build());
  }

  Widget? _buildPaddedAlign(BuildContext context, BuildMetadata meta,
      Widget child, EdgeInsets padding) {
    final tsh = meta.tsb.build(context);
    final fontSize = tsh.style.fontSize;
    if (fontSize == null) return child;

    final withPadding = wf.buildPadding(
      meta,
      child,
      EdgeInsets.only(
        bottom: fontSize * padding.bottom,
        top: fontSize * padding.top,
      ),
    );
    if (withPadding == null) return child;

    return wf.buildAlign(
      meta,
      withPadding,
      padding.bottom > 0 ? Alignment.topCenter : Alignment.bottomCenter,
      widthFactor: 1.0,
    );
  }
}

AlignmentGeometry? _tryParseAlignmentGeometry(TextDirection dir, String value) {
  final isLtr = dir != TextDirection.rtl;
  switch (value) {
    case kCssVerticalAlignTop:
    case kCssVerticalAlignSuper:
      return isLtr ? Alignment.topLeft : Alignment.topRight;
    case kCssVerticalAlignMiddle:
      return isLtr ? Alignment.centerLeft : Alignment.centerRight;
    case kCssVerticalAlignBottom:
    case kCssVerticalAlignSub:
      return isLtr ? Alignment.bottomLeft : Alignment.bottomRight;
  }

  return null;
}

PlaceholderAlignment? _tryParsePlaceholderAlignment(String value) {
  switch (value) {
    case kCssVerticalAlignTop:
    case kCssVerticalAlignSub:
      return PlaceholderAlignment.top;
    case kCssVerticalAlignSuper:
    case kCssVerticalAlignBottom:
      return PlaceholderAlignment.bottom;
    case kCssVerticalAlignMiddle:
      return PlaceholderAlignment.middle;
  }

  return null;
}
