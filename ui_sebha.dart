import 'dart:math' as math;
import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'common.dart';
import 'i18n.dart';
import 'ui_tasbeeh.dart';
import 'userdata.dart';

const Color _bgDark = Color(0xFF06201C);
const Color _panel = Color(0xFF0B332D);
const Color _ink = Color(0xFFD7F3EB);

const List<Color> _beadColors = <Color>[
  Color(0xFF2E9B7A),
  Color(0xFFD94F8C),
  Color(0xFF3F7FD0),
  Color(0xFF29A8D6),
  Color(0xFF8A5CD6),
  Color(0xFFD99A2B),
];

class BeadPainter extends CustomPainter {
  final double offset;
  final int beads;
  BeadPainter(this.offset, this.beads);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height * 0.46);
    final double r = math.min(size.width, size.height) * 0.36;
    final double step = 2 * math.pi / beads;
    final double o = offset % beads;
    final Paint thread = Paint()
      ..color = const Color(0xFFC8962A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(c, r, thread);

    // tassel at the bottom (own simple drawing)
    final Offset tb = Offset(c.dx, c.dy + r + 6);
    final Paint gold = Paint()..color = const Color(0xFFE2B857);
    canvas.drawCircle(Offset(tb.dx, tb.dy + 6), 7, gold);
    final Path tassel = Path()
      ..moveTo(tb.dx - 4, tb.dy + 12)
      ..lineTo(tb.dx + 4, tb.dy + 12)
      ..lineTo(tb.dx + 16, tb.dy + 62)
      ..quadraticBezierTo(tb.dx, tb.dy + 70, tb.dx - 16, tb.dy + 62)
      ..close();
    canvas.drawPath(tassel, Paint()..color = const Color(0xFFB98A2E));
    final Paint strand = Paint()
      ..color = const Color(0xFFF0D58C)
      ..strokeWidth = 1;
    for (int k = -3; k <= 3; k++) {
      canvas.drawLine(Offset(tb.dx + k * 1.2, tb.dy + 14), Offset(tb.dx + k * 4.6, tb.dy + 64), strand);
    }

    for (int i = 0; i < beads; i++) {
      final double a = -math.pi / 2 + (i - o) * step;
      final Offset p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      // closeness to the top position (0 .. 1)
      double d = ((i - o) % beads);
      if (d > beads / 2) d -= beads;
      final double near = (1 - d.abs().clamp(0.0, 1.0)).toDouble();
      final double rad = 11 + 6 * near;
      Color base = _beadColors[i % _beadColors.length];
      if (near > 0.5) base = Color.lerp(base, const Color(0xFFFFD34D), near)!;
      final Paint fill = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          colors: <Color>[Color.lerp(base, Colors.white, 0.55)!, base, Color.lerp(base, Colors.black, 0.35)!],
          stops: const <double>[0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: p, radius: rad));
      if (near > 0.3) {
        canvas.drawCircle(p, rad + 5, Paint()..color = const Color(0x55FFD34D));
      }
      canvas.drawCircle(p, rad, fill);
    }
  }

  @override
  bool shouldRepaint(BeadPainter old) => old.offset != offset || old.beads != beads;
}

class SebhaScreen extends StatefulWidget {
  const SebhaScreen({super.key});

  @override
  State<SebhaScreen> createState() => _SebhaScreenState();
}

class _SebhaScreenState extends State<SebhaScreen> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    final List<TasbeehItem> all = ud.allTasbeeh;
    final int i = all.indexWhere((TasbeehItem t) => t.id == ud.sebhaLast);
    index = i < 0 ? 0 : i;
  }

  TasbeehItem get item {
    final List<TasbeehItem> all = ud.allTasbeeh;
    if (index >= all.length) index = 0;
    return all[index];
  }

  void _select(int i) {
    final List<TasbeehItem> all = ud.allTasbeeh;
    setState(() => index = (i + all.length) % all.length);
    ud.setLast(item.id);
  }

  void _tap() {
    final TasbeehItem t = item;
    final int target = ud.targetOf(t);
    ud.tap(t.id);
    final int c = ud.countOf(t.id);
    if (target > 0 && c % target == 0) {
      HapticFeedback.heavyImpact();
      if (ud.sebhaSeq && ud.allTasbeeh.length > 1) {
        final int next = (index + 1) % ud.allTasbeeh.length;
        Future<void>.delayed(const Duration(milliseconds: 450), () {
          if (!mounted) return;
          _select(next);
          ud.resetCount(item.id);
        });
      }
    } else {
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _chooseZekr() async {
    final List<TasbeehItem> all = ud.allTasbeeh;
    final int? r = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.75,
        child: ListView.builder(
          itemCount: all.length,
          itemBuilder: (BuildContext _, int i) => ListTile(
            selected: i == index,
            title: Text(all[i].name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: all[i].arabic.isEmpty ? null : Text(all[i].arabic, style: const TextStyle(fontSize: 18, height: 1.7)),
            trailing: Text('${ud.countOf(all[i].id)}'),
            onTap: () => Navigator.pop(ctx, i),
          ),
        ),
      ),
    );
    if (r != null) _select(r);
  }

  Future<void> _chooseTarget() async {
    const List<int> values = <int>[10, 25, 33, 34, 50, 99, 100, 313, 500, 1000];
    final int? r = await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ...values.map((int v) => ListTile(title: Text('$v'), onTap: () => Navigator.pop(ctx, v))),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('اپنی تعداد لکھیں'),
              onTap: () => Navigator.pop(ctx, -1),
            ),
          ],
        ),
      ),
    );
    if (r == null) return;
    if (r > 0) {
      ud.setTarget(item.id, r);
      return;
    }
    final String? txt = await promptText(context, 'ہدف (تعداد)');
    final int? v = int.tryParse((txt ?? '').trim());
    if (v != null && v > 0 && v <= 100000) ud.setTarget(item.id, v);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ud,
      builder: (BuildContext context, Widget? _) {
        final TasbeehItem t = item;
        final int target = ud.targetOf(t);
        final int c = ud.countOf(t.id);
        int round = 1;
        int rep = 0;
        if (c > 0 && target > 0) {
          round = (c - 1) ~/ target + 1;
          rep = c - (round - 1) * target;
        } else {
          rep = c;
        }
        final double progress = target > 0 ? (rep / target).clamp(0.0, 1.0).toDouble() : 0;
        final String digits = rep.toString().padLeft(3, '0');
        final int total = ud.allTasbeeh.length;
        return Scaffold(
          backgroundColor: _bgDark,
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A2E28),
            foregroundColor: Colors.white,
            title: const Text('تسبیح'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.list_alt),
                tooltip: tr('روزانہ کا ریکارڈ'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (BuildContext _) => const TasbeehListScreen()),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                  child: Row(
                    children: <Widget>[
                      _sq(Icons.chevron_left, () => _select(index - 1)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: _chooseZekr,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _panel,
                              border: Border.all(color: const Color(0xFF3C6F65)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    t.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, color: _ink),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _sq(Icons.chevron_right, () => _select(index + 1)),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 70,
                        child: Center(
                          child: Text(
                            t.arabic.isEmpty ? t.name : t.arabic,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 28, height: 1.7),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFF1B4A42),
                          color: const Color(0xFFD9A441),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _tap,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(end: c.toDouble()),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            builder: (BuildContext context, double v, Widget? _) =>
                                CustomPaint(painter: BeadPainter(v, 33)),
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0, -0.08),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                digits,
                                style: const TextStyle(
                                  color: Color(0xFFBFEFE3),
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  letterSpacing: 4,
                                ),
                              ),
                              Text(
                                tf('ذکر %s/%s  •  چکر %s', <Object>[index + 1, total, round]),
                                style: const TextStyle(color: Color(0xFF9CC9BF), fontSize: 14),
                              ),
                              Text(
                                tf('تکرار %s/%s', <Object>[rep, target]),
                                style: const TextStyle(color: Color(0xFF9CC9BF), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Row(
                    children: <Widget>[
                      _sq(Icons.undo, () => ud.undo(t.id)),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _chooseTarget,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 48,
                          width: 92,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF3C6F65)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('$target', style: const TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.bold)),
                              const Icon(Icons.arrow_drop_down, color: _ink),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(14)),
                          child: Row(
                            children: <Widget>[
                              const Expanded(
                                child: Text('ترتیب وار', style: TextStyle(color: _ink, fontSize: 16)),
                              ),
                              Switch(value: ud.sebhaSeq, onChanged: (bool v) => ud.setSeq(v)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _sq(Icons.restart_alt, () async {
                        final bool ok = await confirmDialog(context, 'ری سیٹ', 'کیا گنتی صفر کر دی جائے؟');
                        if (ok) ud.resetCount(t.id);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sq(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: _ink),
        ),
      );
}
