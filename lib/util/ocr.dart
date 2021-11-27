import 'package:flutter/material.dart';

class TouchPoints {
  TouchPoints({required this.points, required this.paint});

  Paint paint;
  Offset points;
}

typedef OcrCoordsCallback = void Function(Offset a, Offset b);

class OcrBoxPainter extends CustomPainter {
  OcrBoxPainter({
    required this.pointsList,
    required this.defaultPaint,
    required this.coordsCallback,
  });

  OcrCoordsCallback coordsCallback;
  Paint defaultPaint;
  List<TouchPoints?> pointsList;
  List<Offset> offsetPoints = [];

  @override
  void paint(Canvas canvas, Size size) {
    if (pointsList.isEmpty) {
      canvas.drawRect(Rect.largest, defaultPaint);
    }

    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawPath(
            Path()
              ..addRect(Rect.largest)
              ..addRect(Rect.fromPoints(
                  pointsList[i]!.points, pointsList[i + 1]!.points))
              ..fillType = PathFillType.evenOdd,
            pointsList[i]!.paint);

        coordsCallback(pointsList[i]!.points, pointsList[i + 1]!.points);
      }
    }
  }

  @override
  bool shouldRepaint(OcrBoxPainter oldDelegate) => true;
}
