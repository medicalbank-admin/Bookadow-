import 'package:flutter/material.dart';

import '../models/book_layout_model.dart';

class PageMarginPreview extends StatelessWidget {
  const PageMarginPreview({
    super.key,
    required this.layout,
  });

  final BookLayoutModel layout;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: layout.effectivePageWidth /
          layout.effectivePageHeight,
      child: CustomPaint(
        painter: _PageMarginPainter(layout),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PageMarginPainter extends CustomPainter {
  _PageMarginPainter(this.layout);

  final BookLayoutModel layout;

  @override
  void paint(Canvas canvas, Size size) {
    final pagePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pageBorderPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final marginPaint = Paint()
      ..color = const Color(0xFF315B87).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final guidePaint = Paint()
      ..color = const Color(0xFF315B87)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final pageRect = Offset.zero & size;

    canvas.drawRect(pageRect, pagePaint);
    canvas.drawRect(pageRect, pageBorderPaint);

    final pageWidth = layout.effectivePageWidth;
    final pageHeight = layout.effectivePageHeight;

    final leftMargin = size.width *
        (layout.insideMargin / pageWidth);

    final rightMargin = size.width *
        (layout.outsideMargin / pageWidth);

    final topMargin = size.height *
        (layout.topMargin / pageHeight);

    final bottomMargin = size.height *
        (layout.bottomMargin / pageHeight);

    final contentRect = Rect.fromLTRB(
      leftMargin,
      topMargin,
      size.width - rightMargin,
      size.height - bottomMargin,
    );

    canvas.drawRect(contentRect, marginPaint);
    canvas.drawRect(contentRect, guidePaint);

    _drawLabel(
      canvas,
      'TOP',
      Offset(size.width / 2, topMargin / 2),
    );

    _drawLabel(
      canvas,
      'BOTTOM',
      Offset(
        size.width / 2,
        size.height - bottomMargin / 2,
      ),
    );

    _drawLabel(
      canvas,
      'INSIDE',
      Offset(leftMargin / 2, size.height / 2),
    );

    _drawLabel(
      canvas,
      'OUTSIDE',
      Offset(
        size.width - rightMargin / 2,
        size.height / 2,
      ),
    );

    _drawLabel(
      canvas,
      'TEXT AREA',
      contentRect.center,
      color: const Color(0xFF315B87),
    );
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset center, {
    Color color = Colors.grey,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _PageMarginPainter oldDelegate) {
    return oldDelegate.layout != layout;
  }
}
