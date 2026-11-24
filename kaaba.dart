import 'package:flutter/material.dart';

/// Own simple drawing of the Kaaba with minarets and a soft golden glow.
class KaabaPainter extends CustomPainter {
  final double opacity;
  final double align; // 0 = left, 0.5 = centre, 1 = right
  KaabaPainter(this.opacity, this.align);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    if (w < 60 || h < 40) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.saveLayer(Offset.zero & size, Paint()..color = Color.fromARGB((255 * opacity).round().clamp(0, 255).toInt(), 255, 255, 255));

    final double base = h * 0.93;
    final double kh = h * 0.60;
    final double fw = kh * 0.92;
    final double sw = kh * 0.40;
    final double total = fw + sw;
    final double cx = w * align;
    double x0 = cx - total / 2;
    if (x0 < h * 1.05) x0 = h * 1.05;
    if (x0 + total > w - h * 1.05) x0 = w - h * 1.05 - total;
    final double top = base - kh;

    // golden glow behind the Kaaba
    final Rect glow = Rect.fromCircle(center: Offset(x0 + total / 2, base - kh * 0.5), radius: h * 1.1);
    canvas.drawRect(
      glow,
      Paint()
        ..shader = const RadialGradient(colors: <Color>[Color(0x66F5D98B), Color(0x00F5D98B)]).createShader(glow),
    );

    // minarets (two on each side)
    void minaret(double mx, double mh) {
      final double mw = h * 0.075;
      final Rect body = Rect.fromLTWH(mx - mw / 2, base - mh, mw, mh);
      canvas.drawRect(
        body,
        Paint()
          ..shader = const LinearGradient(colors: <Color>[Color(0xFFF4EEDC), Color(0xFFC9C2A8)]).createShader(body),
      );
      final Paint gold = Paint()..color = const Color(0xFFD9A441);
      canvas.drawRect(Rect.fromLTWH(mx - mw * 0.95, base - mh * 0.72, mw * 1.9, mw * 0.45), gold);
      canvas.drawRect(Rect.fromLTWH(mx - mw * 0.75, base - mh * 0.97, mw * 1.5, mw * 0.4), gold);
      final Path cap = Path()
        ..moveTo(mx - mw * 0.7, base - mh)
        ..lineTo(mx, base - mh - mw * 2.6)
        ..lineTo(mx + mw * 0.7, base - mh)
        ..close();
      canvas.drawPath(cap, gold);
      canvas.drawCircle(Offset(mx, base - mh - mw * 2.9), mw * 0.35, gold);
    }

    minaret(x0 - h * 0.42, h * 0.80);
    minaret(x0 - h * 0.85, h * 0.62);
    minaret(x0 + total + h * 0.42, h * 0.80);
    minaret(x0 + total + h * 0.85, h * 0.62);

    // front face
    final Rect front = Rect.fromLTWH(x0, top, fw, kh);
    canvas.drawRect(
      front,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF3A3A3A), Color(0xFF141414)],
        ).createShader(front),
    );
    // cloth folds
    final Paint fold = Paint()..color = const Color(0x22FFFFFF);
    for (int i = 1; i < 9; i++) {
      canvas.drawRect(Rect.fromLTWH(x0 + fw * i / 9, top, 1.2, kh), fold);
    }
    // side face
    final Path side = Path()
      ..moveTo(x0 + fw, top)
      ..lineTo(x0 + fw + sw, top + kh * 0.05)
      ..lineTo(x0 + fw + sw, base)
      ..lineTo(x0 + fw, base)
      ..close();
    canvas.drawPath(side, Paint()..color = const Color(0xFF080808));

    // gold band with small panels
    final double by = top + kh * 0.18;
    final double bh = kh * 0.13;
    final Rect band = Rect.fromLTWH(x0, by, fw, bh);
    canvas.drawRect(
      band,
      Paint()
        ..shader = const LinearGradient(colors: <Color>[Color(0xFFF2CE6B), Color(0xFFC08A22)]).createShader(band),
    );
    final Paint panel = Paint()..color = const Color(0x55704E10);
    for (int i = 0; i < 5; i++) {
      final double px = x0 + fw * (0.08 + i * 0.18);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(px, by + bh * 0.2, fw * 0.12, bh * 0.6), const Radius.circular(2)),
        panel,
      );
    }
    final Path sideBand = Path()
      ..moveTo(x0 + fw, by)
      ..lineTo(x0 + fw + sw, by + kh * 0.05)
      ..lineTo(x0 + fw + sw, by + kh * 0.05 + bh)
      ..lineTo(x0 + fw, by + bh)
      ..close();
    canvas.drawPath(sideBand, Paint()..color = const Color(0xFF9C7220));

    // golden door with arch
    final double dw = fw * 0.20;
    final double dh = kh * 0.38;
    final double dx = x0 + fw * 0.60;
    final Path door = Path()
      ..moveTo(dx, base)
      ..lineTo(dx, base - dh + dw / 2)
      ..arcToPoint(Offset(dx + dw, base - dh + dw / 2), radius: Radius.circular(dw / 2))
      ..lineTo(dx + dw, base)
      ..close();
    canvas.drawPath(door, Paint()..color = const Color(0xFFE8C063));
    canvas.drawPath(
      door,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF8A6418),
    );
    canvas.drawRect(Rect.fromLTWH(dx + dw * 0.18, base - dh * 0.55, dw * 0.64, dh * 0.4), Paint()..color = const Color(0x55704E10));

    // ground
    canvas.drawRect(Rect.fromLTWH(0, base, w, h - base), Paint()..color = const Color(0x40FFFFFF));
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(KaabaPainter old) => old.opacity != opacity || old.align != align;
}

class KaabaScene extends StatelessWidget {
  final double opacity;
  final double align;
  const KaabaScene({super.key, this.opacity = 0.95, this.align = 0.5});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: KaabaPainter(opacity, align), size: Size.infinite),
    );
  }
}
