import 'package:flutter/material.dart';

const ColorFilter greyscale = ColorFilter.matrix(<double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

class GreyscaleWrapper extends StatelessWidget {
  const GreyscaleWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: greyscale,
      child: child,
    );
  }
}
