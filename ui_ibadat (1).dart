import 'package:flutter/material.dart' hide Text;
import 'common.dart';
import 'duas_data.dart';
import 'i18n.dart';
import 'prayer.dart';
import 'settings.dart';
import 'ui_duas.dart';
import 'ui_names.dart';
import 'ui_prayer.dart';
import 'ui_qibla.dart';
import 'ui_sebha.dart';
import 'ui_tracker.dart';
import 'ui_zakat.dart';
import 'ui_salah.dart';

void pushPage(BuildContext context, Widget page) =>
    Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext _) => page));

void openWaking(BuildContext context) {
  Dua? found;
  for (final Dua d in kDuas) {
    if (d.cat == 'sleep' && d.titleUr.contains('جاگنے')) {
      found = d;
      break;
    }
  }
  if (found != null) {
    pushPage(context, DuaDetailScreen(dua: found));
  } else {
    pushPage(context, const DuaCategoryScreen(cat: 'sleep'));
  }
}

class _Big {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Big(this.icon, this.label, this.color, this.onTap);
}

class IbadatTab extends StatelessWidget {
  const IbadatTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_Big> tiles = <_Big>[
      _Big(Icons.access_time_filled, 'نماز کے اوقات', const Color(0xFF0F5C63), () => pushPage(context, const PrayerScreen())),
      _Big(Icons.explore, 'قبلہ نما', const Color(0xFF0B5D4B), () => pushPage(context, const QiblaScreen())),
      _Big(Icons.blur_circular, 'تسبیح', const Color(0xFF4A3F7A), () => pushPage(context, const SebhaScreen())),
      _Big(Icons.volunteer_activism, 'دعائیں', const Color(0xFF8D5A8F), () => pushPage(context, const DuasScreen())),
      _Big(Icons.auto_awesome, 'اسمائے حسنیٰ', const Color(0xFFB5483A), () => pushPage(context, const NamesScreen())),
      _Big(Icons.menu_book, 'نماز اور وضو کا طریقہ', const Color(0xFF2F6F8F), () => pushPage(context, const SalahGuideScreen())),
      _Big(Icons.calculate, 'زکوٰۃ کیلکولیٹر', const Color(0xFF6B4E9B), () => pushPage(context, const ZakatScreen())),
      _Big(Icons.calendar_month, 'اسلامی کیلنڈر', const Color(0xFF3A86C8), () => pushPage(context, const CalendarScreen())),
      _Big(Icons.wb_sunny, 'صبح کے اذکار', const Color(0xFFE08A1E), () => pushPage(context, const DuaCategoryScreen(cat: 'morning'))),
      _Big(Icons.nights_stay, 'شام کے اذکار', const Color(0xFF1E2A55), () => pushPage(context, const DuaCategoryScreen(cat: 'evening'))),
    ];
    return Scaffold(
      appBar: appBar('عبادات'),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          const PrayerCard(),
          const SizedBox(height: 10),
          const PrayerProgressChip(),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: tiles
                .map((_Big t) => Material(
                      color: t.color,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: t.onTap,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(t.icon, color: Colors.white, size: 34),
                            const SizedBox(height: 6),
                            Text(t.label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Event {
  final int month;
  final int day;
  final String name;
  const _Event(this.month, this.day, this.name);
}

const List<_Event> _events = <_Event>[
  _Event(1, 1, 'اسلامی سال کا آغاز (یکم محرم)'),
  _Event(1, 10, 'یومِ عاشورہ'),
  _Event(3, 12, 'عید میلاد النبی ﷺ (12 ربیع الاول)'),
  _Event(7, 27, 'شبِ معراج (27 رجب)'),
  _Event(8, 15, 'شبِ برات (15 شعبان)'),
  _Event(9, 1, 'آغازِ رمضان المبارک'),
  _Event(9, 27, 'شبِ قدر (ممکنہ، 27 رمضان)'),
  _Event(10, 1, 'عید الفطر'),
  _Event(12, 9, 'یومِ عرفہ'),
  _Event(12, 10, 'عید الاضحیٰ'),
];

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime month = DateTime(DateTime.now().year, DateTime.now().month, 1);

  _Event? _eventOn(HijriDate h) {
    for (final _Event e in _events) {
      if (e.month == h.month && e.day == h.day) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final int days = DateTime(month.year, month.month + 1, 0).day;
    final int lead = month.weekday % 7; // Sunday first
    final HijriDate h1 = toHijri(month, adjust: prayer.hijriAdjust);
    final HijriDate h2 = toHijri(DateTime(month.year, month.month, days), adjust: prayer.hijriAdjust);
    final bool en = settings.lang == 'en';
    final List<String> hm = en ? kHijriMonthsEn : kHijriMonthsUr;
    final String hijriRange = h1.month == h2.month && h1.year == h2.year
        ? '${hm[h1.month - 1]} ${h1.year}'
        : '${hm[h1.month - 1]} ${h1.year} - ${hm[h2.month - 1]} ${h2.year}';
    const List<String> wd = <String>['اتوار', 'پیر', 'منگل', 'بدھ', 'جمعرات', 'جمعہ', 'ہفتہ'];
    final List<_Event> monthEvents = <_Event>[];
    final List<String> eventLines = <String>[];
    for (int d = 1; d <= days; d++) {
      final DateTime g = DateTime(month.year, month.month, d);
      final _Event? e = _eventOn(toHijri(g, adjust: prayer.hijriAdjust));
      if (e != null) {
        monthEvents.add(e);
        eventLines.add('$d ${kMonthsEn[month.month - 1]}  —  ${tr(e.name)}');
      }
    }
    return Scaffold(
      appBar: appBar('اسلامی کیلنڈر'),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => month = DateTime(month.year, month.month - 1, 1)),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('${kMonthsEn[month.month - 1]} ${month.year}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(hijriRange, style: TextStyle(color: kGreen, fontSize: 15)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => month = DateTime(month.year, month.month + 1, 1)),
              ),
            ],
          ),
          Row(
            children: wd
                .map((String s) => Expanded(
                      child: Center(child: Text(s, style: TextStyle(color: kMuted, fontSize: 12))),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.95,
            children: <Widget>[
              for (int i = 0; i < lead; i++) const SizedBox.shrink(),
              for (int d = 1; d <= days; d++) _cell(d, now),
            ],
          ),
          const SizedBox(height: 10),
          if (eventLines.isNotEmpty) ...<Widget>[
            const SectionTitle('اس مہینے کے اہم دن'),
            ...eventLines.map((String s) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(s, style: const TextStyle(height: 1.7))))),
          ],
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'ہجری تاریخ حسابی ہے؛ چاند نظر آنے کے مطابق ایک دن کا فرق ہو سکتا ہے۔ نماز کے اوقات کی اسکرین میں ہجری تاریخ آگے پیچھے کی جا سکتی ہے۔',
              style: TextStyle(color: kMuted, height: 1.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(int d, DateTime now) {
    final DateTime g = DateTime(month.year, month.month, d);
    final HijriDate h = toHijri(g, adjust: prayer.hijriAdjust);
    final bool today = g.year == now.year && g.month == now.month && g.day == now.day;
    final bool event = _eventOn(h) != null;
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: today ? kGreen : (event ? kLight : kCardBg),
        borderRadius: BorderRadius.circular(10),
        border: event ? Border.all(color: kGold, width: 1.5) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('$d',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: today ? Colors.white : kText)),
          Text('${h.day}',
              style: TextStyle(fontSize: 11, color: today ? Colors.white70 : kGreen)),
        ],
      ),
    );
  }
}
