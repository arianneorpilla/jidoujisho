import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart' as wrapped;

/// https://gist.github.com/rtybanana/2b0639052cd5bfd701b8d892f2d1088b
/// https://github.com/MarcelGarus/marquee/issues/36

class Marquee extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? textScaleFactor;
  final TextDirection textDirection;
  final Axis scrollAxis;
  final CrossAxisAlignment crossAxisAlignment;
  final double blankSpace;
  final double velocity;
  final Duration startAfter;
  final Duration pauseAfterRound;
  final int? numberOfRounds;
  final bool showFadingOnlyWhenScrolling;
  final double fadingEdgeStartFraction;
  final double fadingEdgeEndFraction;
  final double startPadding;
  final Duration accelerationDuration;
  final Curve accelerationCurve;
  final Duration decelerationDuration;
  final Curve decelerationCurve;
  final VoidCallback? onDone;

  const Marquee({
    required this.text,
    Key? key,
    this.style,
    this.textScaleFactor,
    this.textDirection = TextDirection.ltr,
    this.scrollAxis = Axis.horizontal,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.blankSpace = 0.0,
    this.velocity = 30.0,
    this.startAfter = Duration.zero,
    this.pauseAfterRound = Duration.zero,
    this.showFadingOnlyWhenScrolling = true,
    this.fadingEdgeStartFraction = 0.0,
    this.fadingEdgeEndFraction = 0.0,
    this.numberOfRounds,
    this.startPadding = 0.0,
    this.accelerationDuration = Duration.zero,
    this.accelerationCurve = Curves.decelerate,
    this.decelerationDuration = Duration.zero,
    this.decelerationCurve = Curves.decelerate,
    this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var span = TextSpan(
        text: text,
        style: style,
      );

      var tp = TextPainter(
        maxLines: 1,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
        text: span,
      );

      tp.layout(maxWidth: constraints.maxWidth);

      if (tp.didExceedMaxLines) {
        return SizedBox(
          height: tp.height,
          width: constraints.maxWidth,
          child: wrapped.Marquee(
            text: text,
            style: style,
            textScaleFactor: textScaleFactor,
            textDirection: textDirection,
            scrollAxis: scrollAxis,
            crossAxisAlignment: crossAxisAlignment,
            blankSpace: blankSpace,
            velocity: velocity,
            startAfter: startAfter,
            pauseAfterRound: pauseAfterRound,
            numberOfRounds: numberOfRounds,
            showFadingOnlyWhenScrolling: showFadingOnlyWhenScrolling,
            fadingEdgeStartFraction: fadingEdgeStartFraction,
            fadingEdgeEndFraction: fadingEdgeEndFraction,
            startPadding: startPadding,
            accelerationDuration: accelerationDuration,
            accelerationCurve: accelerationCurve,
            decelerationDuration: decelerationDuration,
            decelerationCurve: decelerationCurve,
            onDone: onDone,
          ),
        );
      } else {
        return SizedBox(
          width: constraints.maxWidth,
          child: Align(
            // Remember for RTL
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: style,
              textAlign: TextAlign.left,
            ),
          ),
        );
      }
    });
  }
}
