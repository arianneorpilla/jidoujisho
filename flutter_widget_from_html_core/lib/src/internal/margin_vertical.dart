import 'package:flutter/widgets.dart';

import '../core_data.dart';
import '../core_helpers.dart';

class HeightPlaceholder extends WidgetPlaceholder<CssLength> {
  final TextStyleBuilder tsb;

  final List<CssLength> _heights = [];

  HeightPlaceholder(CssLength height, this.tsb) : super(height) {
    super.wrapWith((c, w) => _build(c, w, height, tsb));
    _heights.add(height);
  }

  CssLength get height => _heights.first;

  void mergeWith(HeightPlaceholder other) {
    final height = other.height;
    _heights.add(height);

    super.wrapWith((c, w) => _build(c, w, height, other.tsb));
  }

  @override
  HeightPlaceholder wrapWith(Widget? Function(BuildContext, Widget) builder) =>
      this;

  static Widget _build(BuildContext context, Widget child, CssLength height,
      TextStyleBuilder tsb) {
    final existing = (child is SizedBox ? child.height : null) ?? 0.0;
    final value = height.getValue(tsb.build(context));
    if (value != null && value > existing) return SizedBox(height: value);
    return child;
  }
}
