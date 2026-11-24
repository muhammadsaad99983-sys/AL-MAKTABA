import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart' hide Text;
import 'kaaba.dart';
import 'package:flutter/services.dart';
import 'common.dart';
import 'i18n.dart';
import 'native.dart';
import 'prayer.dart';
import 'ui_prayer.dart';

class CompassPainter extends CustomPainter {
  final double heading; // degrees, where the top of the phone points (true north based)
  final double qibla; // bearing of the Kaaba from north
  final bool aligned;
  final bool live;
  CompassPainter(this.heading, this.qibla, this.aligned, this.live);

  void _label(Canvas canvas, String s, Offset c, Color col, double size) {
    final TextPainter tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(color: col, fontSize: size, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);
    final double R = math.min(size.width, size.height) / 2 - 6;
    // outer frame
    canvas.drawCircle(c, R, Paint()..color = const Color(0xFF0B5D4B));
    canvas.drawCircle(
      c,
      R - 3,
      Paint()
        ..color = aligned ? const Color(0xFF7CFFB0) : const Color(0xFFD9A441)
        ..style = PaintingStyle.stroke
        ..strokeWidth = aligned ? 5 : 3,
    );
    final double dial = R - 14;
    canvas.drawCircle(c, dial, Paint()..color = const Color(0xFFFFF8E6));

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-heading * math.pi / 180.0);
    // ticks
    final Paint tick = Paint()..color = const Color(0xFF6D5A2F);
    for (int d = 0; d < 360; d += 5) {
      final bool big = d % 30 == 0;
      final double len = big ? 14 : (d % 10 == 0 ? 9 : 5);
      tick.strokeWidth = big ? 2.2 : 1;
      final double a = d * math.pi / 180.0;
      canvas.drawLine(
        Offset(math.sin(a) * dial, -math.cos(a) * dial),
        Offset(math.sin(a) * (dial - len), -math.cos(a) * (dial - len)),
        tick,
      );
    }
    final double lr = dial - 32;
    _label(canvas, 'N', Offset(0, -lr), const Color(0xFFC62828), 20);
    _label(canvas, 'E', Offset(lr, 0), const Color(0xFF3E3E3E), 16);
    _label(canvas, 'S', Offset(0, lr), const Color(0xFF3E3E3E), 16);
    _label(canvas, 'W', Offset(-lr, 0), const Color(0xFF3E3E3E), 16);
    // line from the centre to the qibla
    final double qa = qibla * math.pi / 180.0;
    final Offset qdir = Offset(math.sin(qa), -math.cos(qa));
    canvas.drawLine(
      Offset.zero,
      qdir * (dial - 40),
      Paint()
        ..color = const Color(0xFF0B5D4B)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    // Kaaba marker (black cube with a gold band) at the rim
    final Offset k = qdir * (dial - 30);
    canvas.save();
    canvas.translate(k.dx, k.dy);
    canvas.rotate(qa);
    final RRect box = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 34, height: 34), const Radius.circular(4));
    canvas.drawRRect(box, Paint()..color = const Color(0xFF1A1A1A));
    canvas.drawRect(Rect.fromLTWH(-17, -9, 34, 7), Paint()..color = const Color(0xFFD9A441));
    canvas.restore();
    canvas.restore();

    // centre cap
    canvas.drawCircle(c, 7, Paint()..color = const Color(0xFF0B5D4B));
    canvas.drawCircle(c, 3, Paint()..color = const Color(0xFFD9A441));

    // fixed pointer at the top (where the phone points)
    final Path ptr = Path()
      ..moveTo(c.dx, c.dy - R + 2)
      ..lineTo(c.dx - 11, c.dy - R - 10 + 22)
      ..lineTo(c.dx + 11, c.dy - R - 10 + 22)
      ..close();
    canvas.drawPath(ptr, Paint()..color = aligned ? const Color(0xFF00C853) : const Color(0xFFD9A441));
    if (!live) {
      _label(canvas, '?', c, const Color(0x44000000), 90);
    }
  }

  @override
  bool shouldRepaint(CompassPainter old) =>
      old.heading != heading || old.qibla != qibla || old.aligned != aligned || old.live != live;
}

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  Timer? timer;
  bool sensorOk = true;
  bool live = false;
  double shown = 0;
  bool first = true;
  int accuracy = 3;
  bool flat = true;
  bool wasAligned = false;
  int nulls = 0;
  String source = '';
  String info = '';
  double startedLat = 999;
  double startedLon = 999;
  int startedAt = 0;

  @override
  void initState() {
    super.initState();
    prayer.addListener(_placeChanged);
    _boot();
  }

  Future<void> _boot() async {
    if (!prayer.hasPlace) {
      await prayer.useGps();
    }
    await _startCompass();
  }

  void _placeChanged() {
    if (!mounted) return;
    if ((prayer.lat - startedLat).abs() > 0.01 || (prayer.lon - startedLon).abs() > 0.01) {
      _startCompass();
    }
    setState(() {});
  }

  Future<void> _startCompass() async {
    timer?.cancel();
    startedLat = prayer.lat;
    startedLon = prayer.lon;
    startedAt = DateTime.now().millisecondsSinceEpoch;
    final bool ok = await Native.compassStart(prayer.lat, prayer.lon);
    final String inf = ok ? '' : await Native.compassInfo();
    if (!mounted) return;
    setState(() {
      info = inf;
      sensorOk = ok;
      live = false;
      first = true;
      nulls = 0;
    });
    if (!ok) return;
    timer = Timer.periodic(const Duration(milliseconds: 40), (Timer _) => _tick());
  }

  bool busy = false;
  Future<void> _tick() async {
    if (busy || !mounted) return;
    busy = true;
    final Map<String, dynamic>? r = await Native.compassRead();
    busy = false;
    if (!mounted) return;
    if (r == null || r['heading'] is! num) {
      nulls++;
      if (nulls > 75 && live) setState(() => live = false);
      return;
    }
    nulls = 0;
    final double h = (r['heading'] as num).toDouble();
    if (first) {
      shown = h;
      first = false;
    } else {
      double d = h - shown;
      while (d > 180) {
        d -= 360;
      }
      while (d < -180) {
        d += 360;
      }
      // smooth, but follow quickly when the phone is turned fast
      final double k = d.abs() > 25 ? 0.5 : 0.2;
      shown = (shown + d * k + 360) % 360;
    }
    final int acc = r['accuracy'] is num ? (r['accuracy'] as num).toInt() : 3;
    final bool fl = r['flat'] != false;
    final double q = qiblaBearing(prayer.lat, prayer.lon);
    double diff = (q - shown) % 360;
    if (diff > 180) diff -= 360;
    final bool al = diff.abs() <= 3;
    if (al && !wasAligned) HapticFeedback.mediumImpact();
    wasAligned = al;
    setState(() {
      live = true;
      source = (r['source'] ?? '').toString();
      accuracy = acc;
      flat = fl;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    prayer.removeListener(_placeChanged);
    Native.compassStop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double q = qiblaBearing(prayer.lat, prayer.lon);
    final double dist = kaabaDistanceKm(prayer.lat, prayer.lon);
    double diff = (q - shown) % 360;
    if (diff > 180) diff -= 360;
    final bool aligned = live && diff.abs() <= 3;
    final String latS = '${prayer.lat.abs().toStringAsFixed(4)}° ${prayer.lat >= 0 ? 'N' : 'S'}';
    final String lonS = '${prayer.lon.abs().toStringAsFixed(4)}° ${prayer.lon >= 0 ? 'E' : 'W'}';
    return Scaffold(
      backgroundColor: const Color(0xFF0B5D4B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF073B30),
        foregroundColor: Colors.white,
        flexibleSpace: Container(color: const Color(0xFF073B30), child: const KaabaScene(opacity: 0.3)),
        title: const Text('قبلہ نما'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFFFF8E6), borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: <Widget>[
                  Text('آپ کا مقام', style: const TextStyle(color: Color(0xFF7A6A3A), fontSize: 13)),
                  Text(
                    prayer.hasPlace ? cityLabel(prayer.placeName) : tr('مقام معلوم نہیں (لاہور فرض کیا گیا)'),
                    style: const TextStyle(color: Color(0xFF073B30), fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('$latS   $lonS', style: const TextStyle(color: Color(0xFF7A6A3A), fontSize: 12)),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      OutlinedButton.icon(
                        onPressed: prayer.locating
                            ? null
                            : () async {
                                final String m = await prayer.useGps();
                                if (m.isNotEmpty && context.mounted) snack(context, m);
                              },
                        icon: prayer.locating
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.my_location, size: 18),
                        label: const Text('GPS سے مقام لیں'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => pickCity(context),
                        icon: const Icon(Icons.location_city, size: 18),
                        label: const Text('شہر چنیں'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (!sensorOk)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFE0B2), borderRadius: BorderRadius.circular(14)),
                child: const Text(
                  'اس فون میں قطب نما (مقناطیسی سینسر) نہیں ملا یا بند ہے۔ نیچے دی گئی قبلہ کی ڈگری شمال سے گھڑی کی سمت میں ہے؛ کسی اور قطب نما سے شمال دیکھ کر اتنی ڈگری گھومیں۔',
                  style: TextStyle(height: 1.8, color: Color(0xFF4E342E)),
                ),
              ),
            if (!sensorOk && info.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text('info: $info', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12)),
                ),
              ),
            if (sensorOk && !live && DateTime.now().millisecondsSinceEpoch - startedAt > 4000)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFE0B2), borderRadius: BorderRadius.circular(14)),
                child: const Text(
                  'سینسر سے ڈیٹا نہیں آ رہا۔ فون ہلائیں یا ایپ بند کر کے دوبارہ کھولیں۔ اگر پھر بھی نہ چلے تو فون کا قطب نما (Compass) کسی اور ایپ میں آزما کر دیکھیں۔',
                  style: TextStyle(height: 1.8, color: Color(0xFF4E342E)),
                ),
              ),
            if (sensorOk && accuracy < 2)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFE0B2), borderRadius: BorderRadius.circular(14)),
                child: const Text(
                  'قطب نما کی درستی کم ہے۔ فون کو ہوا میں انگریزی کے 8 کی شکل میں چند بار گھمائیں، اور مقناطیس والے کور، دھات اور بجلی کی تاروں سے دور رکھیں۔',
                  style: TextStyle(height: 1.8, color: Color(0xFF4E342E)),
                ),
              ),
            Center(
              child: SizedBox(
                width: 320,
                height: 320,
                child: CustomPaint(painter: CompassPainter(sensorOk ? shown : 0, q, aligned, live || !sensorOk)),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFFFF8E6), borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: <Widget>[
                  Text(
                    aligned ? 'آپ قبلہ رخ ہیں ✓' : (sensorOk ? (live ? (diff > 0 ? 'دائیں گھومیں' : 'بائیں گھومیں') : 'سینسر شروع ہو رہا ہے...') : 'قبلہ کی سمت'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: aligned ? const Color(0xFF00A152) : const Color(0xFF073B30),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${q.round()}°',
                      style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Color(0xFF0B5D4B))),
                  const Text('قبلہ کی سمت (شمال سے)', style: TextStyle(color: Color(0xFF7A6A3A), fontSize: 13)),
                  const SizedBox(height: 6),
                  if (sensorOk && live)
                    Text('${tr('آپ کا رخ')}: ${shown.round()}°', style: const TextStyle(color: Color(0xFF3E3E3E))),
                  Text('${tr('کعبہ تک فاصلہ')}: ${dist.round()} ${tr('کلومیٹر')}',
                      style: const TextStyle(color: Color(0xFF3E3E3E))),
                ],
              ),
            ),
            if (live && source.isNotEmpty)
              Text('سینسر: $source', textAlign: TextAlign.center, style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 11)),
            const SizedBox(height: 10),
            Text(
              sensorOk && !flat
                  ? 'فون کھڑا پکڑا ہوا ہے: اب پیچھے والے کیمرے کی سمت کے حساب سے رخ بتایا جا رہا ہے۔'
                  : 'بہترین نتیجے کے لیے فون کو زمین کے برابر (سیدھا لیٹا ہوا) پکڑیں۔',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFD7EBE4), height: 1.8),
            ),
          ],
        ),
      ),
    );
  }
}
