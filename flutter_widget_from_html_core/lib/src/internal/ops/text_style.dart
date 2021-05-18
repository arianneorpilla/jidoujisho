part of '../core_ops.dart';

const kCssDirection = 'direction';
const kCssDirectionLtr = 'ltr';
const kCssDirectionRtl = 'rtl';
const kAttributeDir = 'dir';

const kCssFontFamily = 'font-family';

const kCssFontSize = 'font-size';
const kCssFontSizeXxLarge = 'xx-large';
const kCssFontSizeXLarge = 'x-large';
const kCssFontSizeLarge = 'large';
const kCssFontSizeMedium = 'medium';
const kCssFontSizeSmall = 'small';
const kCssFontSizeXSmall = 'x-small';
const kCssFontSizeXxSmall = 'xx-small';
const kCssFontSizeLarger = 'larger';
const kCssFontSizeSmaller = 'smaller';
const kCssFontSizes = {
  '1': kCssFontSizeXxSmall,
  '2': kCssFontSizeXSmall,
  '3': kCssFontSizeSmall,
  '4': kCssFontSizeMedium,
  '5': kCssFontSizeLarge,
  '6': kCssFontSizeXLarge,
  '7': kCssFontSizeXxLarge,
};

const kCssFontStyle = 'font-style';
const kCssFontStyleItalic = 'italic';
const kCssFontStyleNormal = 'normal';

const kCssFontWeight = 'font-weight';
const kCssFontWeightBold = 'bold';

const kCssLineHeight = 'line-height';
const kCssLineHeightNormal = 'normal';

const kCssTextDecoration = 'text-decoration';
const kCssTextDecorationLineThrough = 'line-through';
const kCssTextDecorationNone = 'none';
const kCssTextDecorationOverline = 'overline';
const kCssTextDecorationUnderline = 'underline';

class TextStyleOps {
  static TextStyleHtml color(TextStyleHtml p, Color color) =>
      p.copyWith(style: p.style.copyWith(color: color));

  static TextStyleHtml fontFamily(TextStyleHtml p, List<String> list) =>
      p.copyWith(
        style: p.style.copyWith(
          fontFamily: list.isNotEmpty ? list.first : null,
          fontFamilyFallback: list.skip(1).toList(growable: false),
        ),
      );

  static TextStyleHtml fontSize(TextStyleHtml p, css.Expression v) =>
      p.copyWith(style: p.style.copyWith(fontSize: _fontSizeTryParse(p, v)));

  static TextStyleHtml fontSizeEm(TextStyleHtml p, double v) => p.copyWith(
      style: p.style.copyWith(
          fontSize:
              _fontSizeTryParseCssLength(p, CssLength(v, CssLengthUnit.em))));

  static TextStyleHtml fontSizeTerm(TextStyleHtml p, String v) => p.copyWith(
      style: p.style.copyWith(fontSize: _fontSizeTryParseTerm(p, v)));

  static TextStyleHtml fontStyle(TextStyleHtml p, FontStyle fontStyle) =>
      p.copyWith(style: p.style.copyWith(fontStyle: fontStyle));

  static TextStyleHtml fontWeight(TextStyleHtml p, FontWeight v) =>
      p.copyWith(style: p.style.copyWith(fontWeight: v));

  static TextStyleHtml Function(TextStyleHtml, css.Expression) lineHeight(
          WidgetFactory wf) =>
      (p, v) => p.copyWith(height: _lineHeightTryParse(wf, p, v));

  static TextStyleHtml maxLines(TextStyleHtml p, int v) =>
      p.copyWith(maxLines: v);

  static int? maxLinesTryParse(css.Expression? expression) {
    if (expression is css.LiteralTerm) {
      if (expression is css.NumberTerm) {
        return expression.number.ceil();
      }

      switch (expression.valueAsString) {
        case kCssMaxLinesNone:
          return -1;
      }
    }

    return null;
  }

  static TextStyleHtml textDeco(TextStyleHtml p, TextDeco v) {
    final pd = p.style.decoration;
    final lineThough = pd?.contains(TextDecoration.lineThrough) == true;
    final overline = pd?.contains(TextDecoration.overline) == true;
    final underline = pd?.contains(TextDecoration.underline) == true;

    final list = <TextDecoration>[];
    if (v.over == true || (overline && v.over != false)) {
      list.add(TextDecoration.overline);
    }
    if (v.strike == true || (lineThough && v.strike != false)) {
      list.add(TextDecoration.lineThrough);
    }
    if (v.under == true || (underline && v.under != false)) {
      list.add(TextDecoration.underline);
    }

    return p.copyWith(
      style: p.style.copyWith(
        decoration: TextDecoration.combine(list),
        decorationColor: v.color,
        decorationStyle: v.style,
        decorationThickness: v.thickness?.getValue(p),
      ),
    );
  }

  static TextStyleHtml textDirection(TextStyleHtml p, String v) {
    switch (v) {
      case kCssDirectionLtr:
        return p.copyWith(textDirection: TextDirection.ltr);
      case kCssDirectionRtl:
        return p.copyWith(textDirection: TextDirection.rtl);
    }

    return p;
  }

  static TextStyleHtml textOverflow(TextStyleHtml p, TextOverflow v) =>
      p.copyWith(textOverflow: v);

  static TextOverflow? textOverflowTryParse(String value) {
    switch (value) {
      case kCssTextOverflowClip:
        return TextOverflow.clip;
      case kCssTextOverflowEllipsis:
        return TextOverflow.ellipsis;
    }

    return null;
  }

  static List<String> fontFamilyTryParse(List<css.Expression> expressions) {
    final list = <String>[];

    for (final expression in expressions) {
      if (expression is css.LiteralTerm) {
        final fontFamily = expression.valueAsString;
        if (fontFamily.isNotEmpty) list.add(fontFamily);
      }
    }

    return list;
  }

  static FontStyle? fontStyleTryParse(String value) {
    switch (value) {
      case kCssFontStyleItalic:
        return FontStyle.italic;
      case kCssFontStyleNormal:
        return FontStyle.normal;
    }

    return null;
  }

  static FontWeight? fontWeightTryParse(css.Expression expression) {
    if (expression is css.LiteralTerm) {
      if (expression is css.NumberTerm) {
        switch (expression.number) {
          case 100:
            return FontWeight.w100;
          case 200:
            return FontWeight.w200;
          case 300:
            return FontWeight.w300;
          case 400:
            return FontWeight.w400;
          case 500:
            return FontWeight.w500;
          case 600:
            return FontWeight.w600;
          case 700:
            return FontWeight.w700;
          case 800:
            return FontWeight.w800;
          case 900:
            return FontWeight.w900;
        }
      }

      switch (expression.valueAsString) {
        case kCssFontWeightBold:
          return FontWeight.bold;
      }
    }

    return null;
  }

  static TextStyleHtml whitespace(TextStyleHtml p, CssWhitespace v) =>
      p.copyWith(whitespace: v);

  static CssWhitespace? whitespaceTryParse(String value) {
    switch (value) {
      case kCssWhitespacePre:
        return CssWhitespace.pre;
      case kCssWhitespaceNormal:
        return CssWhitespace.normal;
    }

    return null;
  }

  static double? _fontSizeTryParse(TextStyleHtml p, css.Expression v) {
    final length = tryParseCssLength(v);
    if (length != null) {
      final lengthValue = _fontSizeTryParseCssLength(p, length);
      if (lengthValue != null) return lengthValue;
    }

    if (v is css.LiteralTerm) {
      return _fontSizeTryParseTerm(p, v.valueAsString);
    }

    return null;
  }

  static double? _fontSizeTryParseCssLength(TextStyleHtml p, CssLength v) =>
      v.getValue(
        p,
        baseValue: p.parent?.style.fontSize,
        scaleFactor: p.getDependency<MediaQueryData>().textScaleFactor,
      );

  static double? _fontSizeTryParseTerm(TextStyleHtml p, String v) {
    switch (v) {
      case kCssFontSizeXxLarge:
        return _fontSizeMultiplyRootWith(p, 2.0);
      case kCssFontSizeXLarge:
        return _fontSizeMultiplyRootWith(p, 1.5);
      case kCssFontSizeLarge:
        return _fontSizeMultiplyRootWith(p, 1.125);
      case kCssFontSizeMedium:
        return _fontSizeMultiplyRootWith(p, 1);
      case kCssFontSizeSmall:
        return _fontSizeMultiplyRootWith(p, .8125);
      case kCssFontSizeXSmall:
        return _fontSizeMultiplyRootWith(p, .625);
      case kCssFontSizeXxSmall:
        return _fontSizeMultiplyRootWith(p, .5625);

      case kCssFontSizeLarger:
        return _fontSizeMultiplyWith(p.parent?.style.fontSize, 1.2);
      case kCssFontSizeSmaller:
        return _fontSizeMultiplyWith(p.parent?.style.fontSize, 15 / 18);
    }

    return null;
  }

  static double? _fontSizeMultiplyRootWith(TextStyleHtml tsh, double value) {
    var root = tsh;
    while (root.parent != null) {
      root = root.parent!;
    }

    return _fontSizeMultiplyWith(root.style.fontSize, value);
  }

  static double? _fontSizeMultiplyWith(double? fontSize, double value) =>
      fontSize != null ? fontSize * value : null;

  static double? _lineHeightTryParse(
      WidgetFactory wf, TextStyleHtml p, css.Expression v) {
    if (v is css.LiteralTerm) {
      if (v is css.NumberTerm) {
        final number = v.number.toDouble();
        if (number > 0) return number;
      }

      switch (v.valueAsString) {
        case kCssLineHeightNormal:
          return -1;
      }
    }

    final fontSize = p.style.fontSize;
    if (fontSize == null) return null;

    final length = tryParseCssLength(v);
    if (length == null) return null;

    final lengthValue = length.getValue(
      p,
      baseValue: fontSize,
      scaleFactor: p.getDependency<MediaQueryData>().textScaleFactor,
    );
    if (lengthValue == null) return null;

    return lengthValue / fontSize;
  }
}

@immutable
class TextDeco {
  final Color? color;
  final bool? over;
  final bool? strike;
  final TextDecorationStyle? style;
  final CssLength? thickness;
  final bool? under;

  TextDeco({
    this.color,
    this.over,
    this.strike,
    this.style,
    this.thickness,
    this.under,
  });

  static TextDeco? tryParse(List<css.Expression> expressions) {
    for (final expression in expressions) {
      if (expression is! css.LiteralTerm) continue;
      switch (expression.valueAsString) {
        case kCssTextDecorationLineThrough:
          return TextDeco(strike: true);
        case kCssTextDecorationNone:
          return TextDeco(over: false, strike: false, under: false);
        case kCssTextDecorationOverline:
          return TextDeco(over: true);
        case kCssTextDecorationUnderline:
          return TextDeco(under: true);
      }
    }

    return null;
  }
}
