import 'dart:math' as math;
import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'common.dart';
import 'i18n.dart';
import 'names_data.dart';
import 'native.dart';
import 'settings.dart';

/// Simple decorative corner used on cards (own design).
class CornerPainter extends CustomPainter {
  final Color color;
  CornerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    void corner(double dx, double dy, double sx, double sy) {
      canvas.save();
      canvas.translate(dx, dy);
      canvas.scale(sx, sy);
      final Path path = Path()
        ..moveTo(0, 46)
        ..lineTo(0, 16)
        ..quadraticBezierTo(0, 0, 16, 0)
        ..lineTo(46, 0);
      canvas.drawPath(path, p);
      final Path inner = Path()
        ..moveTo(10, 34)
        ..lineTo(10, 20)
        ..quadraticBezierTo(10, 10, 20, 10)
        ..lineTo(34, 10);
      canvas.drawPath(inner, p);
      canvas.drawCircle(const Offset(22, 22), 3, p);
      canvas.restore();
    }

    corner(10, 10, 1, 1);
    corner(size.width - 10, 10, -1, 1);
    corner(10, size.height - 10, 1, -1);
    corner(size.width - 10, size.height - 10, -1, -1);
  }

  @override
  bool shouldRepaint(CornerPainter old) => old.color != color;
}

class NamesScreen extends StatefulWidget {
  const NamesScreen({super.key});

  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends State<NamesScreen> {
  final PageController ctl = PageController(viewportFraction: 0.88);
  int index = 0;

  @override
  void dispose() {
    ctl.dispose();
    super.dispose();
  }

  String _text(int i) {
    final List<String> n = kNames[i];
    return '${i + 1}. ${n[0]}\n${n[2]}\n${n[1]} - ${n[3]}\n\n— ${tr('اسلام 960')}';
  }

  void _jump(int i) {
    ctl.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Future<void> _pickNumber() async {
    final int? r = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.7,
        child: ListView.builder(
          itemCount: kNames.length,
          itemBuilder: (BuildContext _, int i) => ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: kLight,
              child: Text('${i + 1}', style: TextStyle(fontSize: 12, color: kGreen)),
            ),
            title: Text(kNames[i][0], style: const TextStyle(fontSize: 22, height: 1.6)),
            subtitle: Text(settings.lang == 'en' ? kNames[i][3] : kNames[i][2]),
            onTap: () => Navigator.pop(ctx, i),
          ),
        ),
      ),
    );
    if (r != null) _jump(r);
  }

  double _page() {
    if (ctl.hasClients && ctl.position.haveDimensions && ctl.page != null) return ctl.page!;
    return index.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final bool en = settings.lang == 'en';
    final NamePalette cur = paletteFor(index);
    return Scaffold(
      backgroundColor: cur.page,
      appBar: appBar('اللہ تعالیٰ کے 99 نام', actions: <Widget>[
        IconButton(icon: const Icon(Icons.grid_view), onPressed: _pickNumber),
      ]),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        color: cur.page,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: PageView.builder(
                  controller: ctl,
                  itemCount: kNames.length,
                  onPageChanged: (int i) => setState(() => index = i),
                  itemBuilder: (BuildContext context, int i) {
                    final List<String> n = kNames[i];
                    final NamePalette pal = paletteFor(i);
                    return AnimatedBuilder(
                      animation: ctl,
                      builder: (BuildContext context, Widget? child) {
                        final double sc = (1 - (_page() - i).abs() * 0.07).clamp(0.9, 1.0).toDouble();
                        return Transform.scale(scale: sc, child: child);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 18),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[pal.bg1, pal.bg2],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: pal.ornament, width: 2),
                            boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black54, blurRadius: 18, offset: Offset(0, 8))],
                          ),
                          child: CustomPaint(
                            painter: CornerPainter(pal.ornament),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(22, 46, 22, 40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    width: 74,
                                    height: 74,
                                    child: CustomPaint(
                                      painter: StarBadgePainter(pal.ornament),
                                      child: Center(
                                        child: Text('${i + 1}',
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: pal.fg)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  Text(
                                    n[0],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 50,
                                      fontWeight: FontWeight.bold,
                                      height: 1.5,
                                      color: pal.fg,
                                      shadows: <Shadow>[Shadow(color: pal.ornament.withAlpha(150), blurRadius: 16)],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(height: 14, width: 180, child: CustomPaint(painter: DividerPainter(pal.ornament))),
                                  const SizedBox(height: 14),
                                  m(en ? n[3] : n[2], 25, pal.accent, h: 1.7),
                                  const SizedBox(height: 12),
                                  m(n[1].toUpperCase(), 16, pal.fg.withAlpha(215)),
                                  const SizedBox(height: 8),
                                  m(en ? '' : n[3], 16, pal.fg.withAlpha(190), h: 1.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: _text(index)));
                        if (context.mounted) snack(context, 'کاپی ہو گیا');
                      },
                    ),
                    const SizedBox(width: 14),
                    Text('${index + 1} / ${kNames.length}', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(width: 14),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () => Native.shareText(_text(index), tr('اللہ تعالیٰ کے 99 نام')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Centered text that does not get translated again (data text).
  Widget m(String s, double size, Color c, {double h = 1.6}) {
    if (s.isEmpty) return const SizedBox.shrink();
    return Text(
      s,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: size, color: c, height: h, fontWeight: size > 40 ? FontWeight.bold : FontWeight.normal),
    );
  }
}

/// Colours of one name card.
class NamePalette {
  final Color bg1;
  final Color bg2;
  final Color fg;
  final Color accent;
  final Color ornament;
  final Color page;
  const NamePalette(this.bg1, this.bg2, this.fg, this.accent, this.ornament, this.page);
}

/// 1 white, 2 red, 3 green, 4 blue, 5 black, then a different colour for every name.
NamePalette paletteFor(int i) {
  switch (i) {
    case 0:
      return const NamePalette(Color(0xFFFFFFFF), Color(0xFFEAE3CF), Color(0xFF0B3D2E), Color(0xFF9A7410), Color(0xFFC9A24B), Color(0xFF0B3D2E));
    case 1:
      return const NamePalette(Color(0xFFE0393E), Color(0xFF7F0F1A), Colors.white, Color(0xFFFFE3A6), Color(0xFFF2CE6B), Color(0xFF3D0710));
    case 2:
      return const NamePalette(Color(0xFF22A55F), Color(0xFF0B4D2E), Colors.white, Color(0xFFFFE3A6), Color(0xFFF2CE6B), Color(0xFF052A19));
    case 3:
      return const NamePalette(Color(0xFF3585DA), Color(0xFF0F3C78), Colors.white, Color(0xFFFFE3A6), Color(0xFFF2CE6B), Color(0xFF061D3D));
    case 4:
      return const NamePalette(Color(0xFF3C3C3C), Color(0xFF000000), Colors.white, Color(0xFFF2CE6B), Color(0xFFF2CE6B), Color(0xFF0A0A0A));
  }
  final double h = ((i - 5) * 47.0 + 20.0) % 360.0;
  Color hsl(double s, double l) => HSLColor.fromAHSL(1, h, s, l).toColor();
  return NamePalette(hsl(0.60, 0.44), hsl(0.70, 0.20), Colors.white, const Color(0xFFFFE9B0), const Color(0xFFF2CE6B), hsl(0.65, 0.09));
}

/// Eight pointed star ring behind the number.
class StarBadgePainter extends CustomPainter {
  final Color color;
  StarBadgePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = size.width / 2 - 2;
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final Path star = Path();
    for (int k = 0; k < 16; k++) {
      final double ang = k * 3.141592653589793 / 8 - 3.141592653589793 / 2;
      final double rr = k.isEven ? r : r * 0.74;
      final Offset pt = Offset(c.dx + rr * _cos(ang), c.dy + rr * _sin(ang));
      if (k == 0) {
        star.moveTo(pt.dx, pt.dy);
      } else {
        star.lineTo(pt.dx, pt.dy);
      }
    }
    star.close();
    canvas.drawPath(star, Paint()..color = color.withAlpha(60));
    canvas.drawPath(star, stroke);
    canvas.drawCircle(c, r * 0.58, stroke);
  }

  double _cos(double a) => math.cos(a);
  double _sin(double a) => math.sin(a);

  @override
  bool shouldRepaint(StarBadgePainter old) => old.color != color;
}

/// Thin line with a diamond in the middle.
class DividerPainter extends CustomPainter {
  final Color color;
  DividerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 1.6;
    final double y = size.height / 2;
    final double cx = size.width / 2;
    canvas.drawLine(Offset(0, y), Offset(cx - 12, y), p);
    canvas.drawLine(Offset(cx + 12, y), Offset(size.width, y), p);
    final Path d = Path()
      ..moveTo(cx, y - 6)
      ..lineTo(cx + 6, y)
      ..lineTo(cx, y + 6)
      ..lineTo(cx - 6, y)
      ..close();
    canvas.drawPath(d, Paint()..color = color);
  }

  @override
  bool shouldRepaint(DividerPainter old) => old.color != color;
}
