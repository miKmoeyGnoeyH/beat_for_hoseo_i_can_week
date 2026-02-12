import 'package:flutter/material.dart';

class QROverlay extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutWidth;
  final double cutOutHeight;

  const QROverlay({
    this.borderColor = const Color(0xFFFFEB3B),
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.7),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutWidth = 250,
    this.cutOutHeight = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left + borderLength, rect.top)
        ..lineTo(rect.left + borderRadius, rect.top)
        ..quadraticBezierTo(
            rect.left, rect.top, rect.left, rect.top + borderRadius)
        ..lineTo(rect.left, rect.top + borderLength);
    }

    return Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutWidth,
            height: cutOutHeight,
          ),
          Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final borderOffset = borderWidth / 2;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxRect = Rect.fromLTWH(
      rect.left + (width - cutOutWidth) / 2,
      rect.top + (height - cutOutHeight) / 2,
      cutOutWidth,
      cutOutHeight,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(
          boxRect,
          const Radius.circular(0),
        ),
        Paint()..blendMode = BlendMode.clear,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          boxRect.inflate(borderOffset),
          Radius.circular(borderRadius),
        ),
        borderPaint,
      )
      ..restore();
  }

  @override
  ShapeBorder scale(double t) {
    return QROverlay(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
    );
  }
}