part of '../core_ops.dart';

const kCssHeight = 'height';
const kCssMaxHeight = 'max-height';
const kCssMaxWidth = 'max-width';
const kCssMinHeight = 'min-height';
const kCssMinWidth = 'min-width';
const kCssWidth = 'width';

class DisplayBlockOp extends BuildOp {
  DisplayBlockOp(WidgetFactory wf)
      : super(
          onWidgets: (meta, widgets) => listOrNull(wf
              .buildColumnPlaceholder(meta, widgets)
              ?.wrapWith((_, w) => w is CssSizing ? w : CssBlock(child: w))),
          priority: StyleSizing.kPriority5k + 1,
        );
}

class StyleSizing {
  static const kPriority5k = 5000;

  final WidgetFactory wf;

  static final _treatHeightAsMinHeight = Expando<bool>();

  StyleSizing(this.wf);

  BuildOp get buildOp => BuildOp(
        onTree: (meta, tree) {
          if (meta.willBuildSubtree == true) return;

          final input = _parse(meta);
          if (input == null) return;

          WidgetPlaceholder? widget;
          for (final b in tree.bits) {
            if (b is WidgetBit) {
              if (widget != null) return;
              widget = b.child;
            } else {
              return;
            }
          }

          widget?.wrapWith((c, w) => _build(c, w, input, meta.tsb));
        },
        onWidgets: (meta, widgets) {
          if (meta.willBuildSubtree == false) return widgets;

          final input = _parse(meta);
          if (input == null) return widgets;
          return listOrNull(wf
              .buildColumnPlaceholder(meta, widgets)
              ?.wrapWith((c, w) => _build(c, w, input, meta.tsb)));
        },
        onWidgetsIsOptional: true,
        priority: kPriority5k,
      );

  _StyleSizingInput? _parse(BuildMetadata meta) {
    CssLength? maxHeight, maxWidth, minHeight, minWidth;
    Axis? preferredAxis;
    CssLength? preferredHeight, preferredWidth;

    for (final style in meta.styles) {
      final value = style.value;
      if (value == null) continue;

      switch (style.property) {
        case kCssHeight:
          final parsedHeight = tryParseCssLength(value);
          if (parsedHeight != null) {
            if (_treatHeightAsMinHeight[meta] == true) {
              minHeight = parsedHeight;
            } else {
              preferredAxis = Axis.vertical;
              preferredHeight = parsedHeight;
            }
          }
          break;
        case kCssMaxHeight:
          maxHeight = tryParseCssLength(value) ?? maxHeight;
          break;
        case kCssMaxWidth:
          maxWidth = tryParseCssLength(value) ?? maxWidth;
          break;
        case kCssMinHeight:
          minHeight = tryParseCssLength(value) ?? minHeight;
          break;
        case kCssMinWidth:
          minWidth = tryParseCssLength(value) ?? minWidth;
          break;
        case kCssWidth:
          final parsedWidth = tryParseCssLength(value);
          if (parsedWidth != null) {
            preferredAxis = Axis.horizontal;
            preferredWidth = parsedWidth;
          }
          break;
      }
    }

    if (maxHeight == null &&
        maxWidth == null &&
        minHeight == null &&
        minWidth == null &&
        preferredHeight == null &&
        preferredWidth == null) return null;

    if (preferredWidth == null &&
        meta.buildOps.whereType<DisplayBlockOp>().isNotEmpty) {
      // `display: block` implies a 100% width
      // but it MUST NOT reset width value if specified
      // we need to keep track of block width to calculate contraints correctly
      preferredWidth = const CssLength(100, CssLengthUnit.percentage);
      preferredAxis ??= Axis.horizontal;
    }

    return _StyleSizingInput(
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      minHeight: minHeight,
      minWidth: minWidth,
      preferredAxis: preferredAxis,
      preferredHeight: preferredHeight,
      preferredWidth: preferredWidth,
    );
  }

  static void treatHeightAsMinHeight(BuildMetadata meta) =>
      _treatHeightAsMinHeight[meta] = true;

  static Widget _build(BuildContext context, Widget child,
      _StyleSizingInput input, TextStyleBuilder tsb) {
    final tsh = tsb.build(context);

    return CssSizing(
      maxHeight: _getValue(input.maxHeight, tsh),
      maxWidth: _getValue(input.maxWidth, tsh),
      minHeight: _getValue(input.minHeight, tsh),
      minWidth: _getValue(input.minWidth, tsh),
      preferredAxis: input.preferredAxis,
      preferredHeight: _getValue(input.preferredHeight, tsh),
      preferredWidth: _getValue(input.preferredWidth, tsh),
      child: child,
    );
  }

  static CssSizingValue? _getValue(CssLength? length, TextStyleHtml tsh) {
    if (length == null) return null;

    final value = length.getValue(tsh);
    if (value != null) return CssSizingValue.value(value);

    switch (length.unit) {
      case CssLengthUnit.auto:
        return CssSizingValue.auto();
      case CssLengthUnit.percentage:
        return CssSizingValue.percentage(length.number);
      default:
        return null;
    }
  }
}

@immutable
class _StyleSizingInput {
  final CssLength? maxHeight;
  final CssLength? maxWidth;
  final CssLength? minHeight;
  final CssLength? minWidth;
  final Axis? preferredAxis;
  final CssLength? preferredHeight;
  final CssLength? preferredWidth;

  _StyleSizingInput({
    this.maxHeight,
    this.maxWidth,
    this.minHeight,
    this.minWidth,
    this.preferredAxis,
    this.preferredHeight,
    this.preferredWidth,
  });
}
