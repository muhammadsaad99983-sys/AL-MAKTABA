import 'package:flutter/material.dart';

/// Own simple drawing of the Kaaba with two minarets (no copied artwork).
class KaabaPainter extends CustomPainter {
  final double opacity;
  KaabaPainter(this.opacity);

  Color _c(int rgb, [double a = 1]) =>
      Color(0xFF000000 | rgb).withAlpha((255 * opacity * a).round().clamp(0, 255).toInt());

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    if (w < 40 || h < 30) return;
    final double base = h * 0.94; // ground line
    final double kh = h * 0.62; // cube height
    final double fw = kh * 0.95; // front face width
    final double sw = kh * 0.42; // side face width
    final double total = fw + sw;
    final double x0 = (w - total) / 2;
    final double top = base - kh;

    // minarets on both sides
    void minaret(double cx, double height) {
      final double mw = h * 0.07;
      canvas.drawRect(Rect.fromLTWH(cx - mw / 2, base - height, mw, height), Paint()..color = _c(0xE8F1EE, 0.55));
      canvas.drawRect(Rect.fromLTWH(cx - mw * 0.9, base - height * 0.78, mw * 1.8, mw * 0.5), Paint()..color = _c(0xE8F1EE, 0.7));
      final Path cap = Path()
        ..moveTo(cx - mw * 0.8, base - height)
        ..lineTo(cx, base - height - mw * 2.2)
        ..lineTo(cx + mw * 0.8, base - height)
        ..close();
      canvas.drawPath(cap, Paint()..color = _c(0xE8F1EE, 0.7));
    }

    minaret(x0 - h * 0.45, h * 0.78);
    minaret(x0 + total + h * 0.45, h * 0.78);
    minaret(x0 - h * 0.85, h * 0.6);
    minaret(x0 + total + h * 0.85, h * 0.6);

    // cube: front face + side face
    final Rect front = Rect.fromLTWH(x0, top, fw, kh);
    canvas.drawRect(front, Paint()..color = _c(0x1B1B1B));
    final Path side = Path()
      ..moveTo(x0 + fw, top)
      ..lineTo(x0 + fw + sw, top + kh * 0.05)
      ..lineTo(x0 + fw + sw, base)
      ..lineTo(x0 + fw, base)
      ..close();
    canvas.drawPath(side, Paint()..color = _c(0x0A0A0A));
    // gold band
    final double by = top + kh * 0.2;
    final double bh = kh * 0.11;
    canvas.drawRect(Rect.fromLTWH(x0, by, fw, bh), Paint()..color = _c(0xD9A441));
    final Path sideBand = Path()
      ..moveTo(x0 + fw, by)
      ..lineTo(x0 + fw + sw, by + kh * 0.05 * (1 - 0.0))
      ..lineTo(x0 + fw + sw, by + kh * 0.05 + bh)
      ..lineTo(x0 + fw, by + bh)
      ..close();
    canvas.drawPath(sideBand, Paint()..color = _c(0xB98A2E));
    // door
    final double dw = fw * 0.16;
    final double dh = kh * 0.34;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x0 + fw * 0.62, base - dh - kh * 0.02, dw, dh), const Radius.circular(2)),
      Paint()..color = _c(0xE2B857),
    );
    // ground
    canvas.drawRect(Rect.fromLTWH(0, base, w, h - base), Paint()..color = _c(0xFFFFFF, 0.25));
  }

  @override
  bool shouldRepaint(KaabaPainter old) => old.opacity != opacity;
}

class KaabaScene extends StatelessWidget {
  final double opacity;
  const KaabaScene({super.key, this.opacity = 0.35});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: KaabaPainter(opacity), size: Size.infinite),
    );
  }
}
