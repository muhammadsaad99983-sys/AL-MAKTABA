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

  @override
  Widget build(BuildContext context) {
    final bool en = settings.lang == 'en';
    return Scaffold(
      appBar: appBar('اللہ تعالیٰ کے 99 نام', actions: <Widget>[
        IconButton(icon: const Icon(Icons.grid_view), onPressed: _pickNumber),
      ]),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                controller: ctl,
                itemCount: kNames.length,
                onPageChanged: (int i) => setState(() => index = i),
                itemBuilder: (BuildContext context, int i) {
                  final List<String> n = kNames[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 22),
                    child: Container(
                      decoration: BoxDecoration(
                        color: kCardBg,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black26, blurRadius: 14, offset: Offset(0, 6))],
                      ),
                      child: CustomPaint(
                        painter: CornerPainter(kFaint),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 60, 22, 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('${i + 1}', style: TextStyle(fontSize: 18, color: kMuted)),
                              const SizedBox(height: 18),
                              m(n[0], 46, kText),
                              const SizedBox(height: 20),
                              m(en ? n[3] : n[2], 24, kGreen, h: 1.7),
                              const SizedBox(height: 14),
                              m(n[1].toUpperCase(), 17, kText),
                              const SizedBox(height: 10),
                              m(en ? '' : n[3], 17, kMuted, h: 1.5),
                            ],
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
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _text(index)));
                      if (context.mounted) snack(context, 'کاپی ہو گیا');
                    },
                  ),
                  const SizedBox(width: 14),
                  Text('${index + 1} / ${kNames.length}', style: TextStyle(color: kMuted)),
                  const SizedBox(width: 14),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => Native.shareText(_text(index), tr('اللہ تعالیٰ کے 99 نام')),
                  ),
                ],
              ),
            ),
          ],
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
