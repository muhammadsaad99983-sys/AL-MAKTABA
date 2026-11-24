import 'dart:math' as math;
import 'package:flutter/material.dart' hide Text;
import 'common.dart';
import 'i18n.dart';
import 'prayer.dart';
import 'userdata.dart';

const List<String> kPrayerKeys = <String>['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
const Map<String, String> kPrayerNames = <String, String>{
  'fajr': 'فجر',
  'dhuhr': 'ظہر',
  'asr': 'عصر',
  'maghrib': 'مغرب',
  'isha': 'عشاء',
};
const Map<String, IconData> kPrayerIcons = <String, IconData>{
  'fajr': Icons.wb_twilight,
  'dhuhr': Icons.wb_sunny,
  'asr': Icons.filter_drama,
  'maghrib': Icons.wb_twilight,
  'isha': Icons.nightlight_round,
};

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime? _timeOf(String key, DateTime day) {
  if (!prayer.hasPlace) return null;
  final DayTimes? t = prayer.times(day);
  if (t == null) return null;
  switch (key) {
    case 'fajr':
      return t.fajr;
    case 'dhuhr':
      return t.dhuhr;
    case 'asr':
      return t.asr;
    case 'maghrib':
      return t.maghrib;
    default:
      return t.isha;
  }
}

class _RingPainter extends CustomPainter {
  final double frac;
  _RingPainter(this.frac);
  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = size.width / 2 - 6;
    final Paint bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..color = Colors.white24;
    final Paint fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFE8D39A);
    canvas.drawCircle(c, r, bg);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, 2 * math.pi * frac, false, fg);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.frac != frac;
}

/// Small bar for the home / ibadat screens.
class PrayerProgressChip extends StatelessWidget {
  const PrayerProgressChip({super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ud,
      builder: (BuildContext context, Widget? _) {
        final int n = ud.prayedCount(DateTime.now());
        return Material(
          color: const Color(0xFF0B5D4B),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (BuildContext _) => const PrayerTrackerScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.check_circle, color: Color(0xFFE8D39A), size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('آج کی نمازیں',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: n / 5,
                            minHeight: 8,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE8D39A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('$n/5', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PrayerTrackerScreen extends StatelessWidget {
  const PrayerTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('نماز کا حساب'),
      body: AnimatedBuilder(
        animation: ud,
        builder: (BuildContext context, Widget? _) {
          final DateTime now = DateTime.now();
          final int n = ud.prayedCount(now);
          return ListView(
            padding: const EdgeInsets.all(14),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: <Color>[Color(0xFF117A63), Color(0xFF073B30)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 92,
                          height: 92,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              CustomPaint(size: const Size(92, 92), painter: _RingPainter(n / 5)),
                              Text('$n/5',
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text('آج کی کارکردگی',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('${tr('نمازیں ادا کیں')}: $n / 5',
                                  style: const TextStyle(color: Color(0xFFE8D39A), fontSize: 15)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: n / 5,
                        minHeight: 10,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE8D39A)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (BuildContext _) => const PrayerAnalyticsScreen()),
                      ),
                      child: const Text('تمام نمازوں کا تجزیہ دیکھیں', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SectionTitle('نماز منتخب کریں'),
              for (final String k in kPrayerKeys) _PrayerRow(k: k, day: now),
              const SizedBox(height: 10),
              if (!prayer.hasPlace)
                const Text('اوقات دیکھنے کے لیے "نماز کے اوقات" میں شہر منتخب کریں۔',
                    style: TextStyle(color: kMuted, fontSize: 13)),
            ],
          );
        },
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final String k;
  final DateTime day;
  const _PrayerRow({required this.k, required this.day});

  @override
  Widget build(BuildContext context) {
    final bool done = ud.isPrayed(day, k);
    final DateTime? t = _timeOf(k, day);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: done ? const Color(0xFFE3F4EC) : kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: done ? const Color(0xFF2E9E6E) : Colors.black12),
      ),
      child: ListTile(
        onTap: () => ud.setPrayed(day, k, !done),
        leading: Icon(kPrayerIcons[k], color: const Color(0xFF0B5D4B), size: 30),
        title: Text(kPrayerNames[k]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        subtitle: t == null ? null : Text(clock12(t)),
        trailing: done
            ? const Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Text('ادا کی', style: TextStyle(color: Color(0xFF2E9E6E), fontWeight: FontWeight.bold)),
                SizedBox(width: 6),
                Icon(Icons.check_circle, color: Color(0xFF2E9E6E)),
              ])
            : const Icon(Icons.radio_button_unchecked, color: Colors.black38),
      ),
    );
  }
}

class PrayerAnalyticsScreen extends StatelessWidget {
  const PrayerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final List<DateTime> days = <DateTime>[
      for (int i = 0; i < 14; i++) DateTime(now.year, now.month, now.day - i),
    ];
    int total = 0;
    for (final DateTime d in days) {
      total += ud.prayedCount(d);
    }
    return Scaffold(
      appBar: appBar('نمازوں کا تجزیہ'),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(16)),
            child: Text('${tr('پچھلے 14 دن')}: $total / 70',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          for (final DateTime d in days)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 92, child: Directionality(textDirection: TextDirection.ltr, child: Text(dayKey(d), style: const TextStyle(fontSize: 13)))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ud.prayedCount(d) / 5,
                        minHeight: 12,
                        backgroundColor: Colors.black12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E9E6E)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${ud.prayedCount(d)}/5'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
