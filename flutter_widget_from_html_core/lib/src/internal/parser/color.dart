part of '../core_parser.dart';

const kCssColor = 'color';

Color? tryParseColor(css.Expression? expression) {
  if (expression == null) return null;

  if (expression is css.FunctionTerm) {
    switch (expression.text) {
      case 'hsl':
      case 'hsla':
        final params = expression.params;
        if (params.length >= 3) {
          final param0 = params[0];
          final h = param0 is css.NumberTerm
              ? _parseColorHue(param0.number)
              : param0 is css.AngleTerm
                  ? _parseColorHue(param0.value, param0.unit)
                  : null;
          final param1 = params[1];
          final s = param1 is css.PercentageTerm
              ? param1.valueAsDouble.clamp(0.0, 1.0)
              : null;
          final param2 = params[2];
          final l = param2 is css.PercentageTerm
              ? param2.valueAsDouble.clamp(0.0, 1.0)
              : null;
          final hslA = params.length >= 4 ? _parseColorAlpha(params[3]) : 1.0;
          if (h != null && s != null && l != null && hslA != null) {
            return HSLColor.fromAHSL(hslA, h, s, l).toColor();
          }
        }
        break;
      case 'rgb':
      case 'rgba':
        final params = expression.params;
        if (params.length >= 3) {
          final r = _parseColorRgbElement(params[0]);
          final g = _parseColorRgbElement(params[1]);
          final b = _parseColorRgbElement(params[2]);
          final rgbA = params.length >= 4 ? _parseColorAlpha(params[3]) : 1.0;
          if (r != null && g != null && b != null && rgbA != null) {
            return Color.fromARGB((rgbA * 255).ceil(), r, g, b);
          }
        }
        break;
    }
  } else if (expression is css.HexColorTerm) {
    // cannot use expression.value directory due to issue with #f00 etc.
    final hex = expression.text.toUpperCase();
    switch (hex.length) {
      case 3:
        return Color(int.parse('0xFF${_x2(hex)}'));
      case 4:
        final alpha = hex[3];
        final rgb = hex.substring(0, 3);
        return Color(int.parse('0x${_x2(alpha)}${_x2(rgb)}'));
      case 6:
        return Color(int.parse('0xFF$hex'));
      case 8:
        final alpha = hex.substring(6, 8);
        final rgb = hex.substring(0, 6);
        return Color(int.parse('0x$alpha$rgb'));
    }
  } else if (expression is css.LiteralTerm) {
    switch (expression.valueAsString) {
      // TODO: add support for `currentcolor`
      case 'transparent':
        return Color(0x00000000);
    }
  }

  return null;
}

double? _parseColorAlpha(css.Expression v) => (v is css.NumberTerm
        ? v.number.toDouble()
        : v is css.PercentageTerm
            ? v.valueAsDouble
            : null)
    ?.clamp(0.0, 1.0);

double _parseColorHue(num number, [int? unit]) {
  final v = number is double ? number : number.toDouble();

  double deg;
  switch (unit) {
    case css.TokenKind.UNIT_ANGLE_RAD:
      final rad = v;
      deg = rad * (180 / pi);
      break;
    case css.TokenKind.UNIT_ANGLE_GRAD:
      final grad = v;
      deg = grad * 0.9;
      break;
    case css.TokenKind.UNIT_ANGLE_TURN:
      final turn = v;
      deg = turn * 360;
      break;
    default:
      deg = v;
  }

  while (deg < 0) {
    deg += 360;
  }

  return deg % 360;
}

int? _parseColorRgbElement(css.Expression v) => (v is css.NumberTerm
        ? v.number.ceil()
        : v is css.PercentageTerm
            ? (v.valueAsDouble * 255.0).ceil()
            : null)
    ?.clamp(0, 255);

String _x2(String value) {
  final sb = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    sb.write(value[i] * 2);
  }
  return sb.toString();
}
