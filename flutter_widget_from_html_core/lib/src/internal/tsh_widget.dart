import 'package:flutter/widgets.dart';

import '../core_data.dart';

class TshWidget extends InheritedWidget {
  final TextStyleHtml? tsh;

  TshWidget({
    Key? key,
    required Widget child,
    required this.tsh,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(TshWidget oldWidget) =>
      tsh == null || tsh != oldWidget.tsh;
}
