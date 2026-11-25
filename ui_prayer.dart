import 'dart:async';
import 'package:flutter/material.dart' hide Text;
import 'common.dart';
import 'i18n.dart';
import 'prayer.dart';
import 'settings.dart';

Future<void> pickCity(BuildContext context) async {
  final Object? r = await showModalBottomSheet<Object>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext ctx) {
      String q = '';
      return StatefulBuilder(
        builder: (BuildContext ctx, StateSetter set) {
          final String qq = q.trim().toLowerCase();
          final List<Place> list = kCities
              .where((Place p) => qq.isEmpty || p.name.contains(qq) || p.ar.contains(qq) || p.en.toLowerCase().contains(qq))
              .toList();
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.8,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    child: TextField(
                      onChanged: (String v) => set(() => q = v),
                      decoration: InputDecoration(
                        hintText: tr('شہر کا نام تلاش کریں'),
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.my_location, color: kGreen),
                          title: const Text('GPS سے مقام لیں'),
                          onTap: () => Navigator.pop(ctx, 'gps'),
                        ),
                        ListTile(
                          leading: Icon(Icons.edit_location_alt, color: kGreen),
                          title: const Text('اپنے شہر کے نمبر خود لکھیں'),
                          subtitle: const Text('اگر آپ کا شہر فہرست میں نہ ہو'),
                          onTap: () => Navigator.pop(ctx, 'custom'),
                        ),
                        const Divider(height: 1),
                        ...list.map((Place p) => ListTile(
                              leading: const Icon(Icons.location_on_outlined),
                              title: Text(cityLabel(p.name)),
                              subtitle: Text(settings.lang == 'ur' ? p.en : p.name),
                              onTap: () => Navigator.pop(ctx, p),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
  if (r == 'gps') {
    final String m = await prayer.useGps();
    if (m.isNotEmpty && context.mounted) snack(context, m);
  } else if (r == 'custom') {
    if (!context.mounted) return;
    final String? name = await promptText(context, 'شہر کا نام');
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    final String? la = await promptText(context, 'عرض بلد (Latitude) مثلاً 34.5650');
    if (la == null || !context.mounted) return;
    final String? lo = await promptText(context, 'طول بلد (Longitude) مثلاً 71.9300');
    final double? la2 = double.tryParse((la).trim());
    final double? lo2 = double.tryParse((lo ?? '').trim());
    if (la2 == null || lo2 == null || la2.abs() > 90 || lo2.abs() > 180) {
      if (context.mounted) snack(context, 'نمبر درست نہیں');
      return;
    }
    prayer.setCustom(name.trim(), la2, lo2);
  } else if (r is Place) {
    prayer.setCity(r);
  }
}

class _Slot {
  final String key;
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  const _Slot(this.key, this.label, this.icon, this.bg, this.fg);
}

const List<_Slot> _slots = <_Slot>[
  _Slot('fajr', 'فجر', Icons.wb_twilight, Color(0xFF4A3F7A), Colors.white),
  _Slot('sunrise', 'طلوع', Icons.wb_sunny_outlined, Color(0xFFF0A97A), Color(0xFF3A2410)),
  _Slot('dhuhr', 'ظہر', Icons.wb_sunny, Color(0xFFFAE3A1), Color(0xFF3A2D10)),
  _Slot('asr', 'عصر', Icons.filter_drama, Color(0xFFEBB878), Color(0xFF3A2410)),
  _Slot('maghrib', 'مغرب', Icons.wb_twilight, Color(0xFF8D5A8F), Colors.white),
  _Slot('isha', 'عشاء', Icons.nightlight_round, Color(0xFF1E2A55), Colors.white),
];

String gmtLabel() {
  final Duration o = DateTime.now().timeZoneOffset;
  final int m = o.inMinutes;
  final String sign = m < 0 ? '-' : '+';
  final int a = m.abs();
  final String mm = a % 60 == 0 ? '' : ':${two2(a % 60)}';
  return 'GMT$sign${a ~/ 60}$mm';
}

String two2(int n) => n < 10 ? '0$n' : '$n';

String dateLine(DateTime d, {int adjust = 0}) {
  final HijriDate h = toHijri(d, adjust: adjust);
  final bool en = settings.lang == 'en';
  final String hm = en ? kHijriMonthsEn[h.month - 1] : kHijriMonthsUr[h.month - 1];
  final String wd = en
      ? const <String>['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][d.weekday - 1]
      : kWeekdaysUr[d.weekday - 1];
  return '$wd ${h.day} $hm ${h.year}';
}

/// Prayer-times card: next prayer countdown + six coloured time cards.
class PrayerCard extends StatefulWidget {
  final bool settingsButton;
  const PrayerCard({super.key, this.settingsButton = true});

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> {
  Timer? timer;
  int dayOffset = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer _) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: prayer,
      builder: (BuildContext context, Widget? _) {
        final DateTime now = DateTime.now();
        final DateTime today = DateTime(now.year, now.month, now.day);
        final DateTime shownDay = today.add(Duration(days: dayOffset));
        final DayTimes? t = prayer.times(shownDay);
        final DayTimes? tm = prayer.times(today.add(const Duration(days: 1)));
        final DayTimes? ty = prayer.times(today.subtract(const Duration(days: 1)));

        // next event (always based on real today)
        String nextKey = '';
        Duration left = Duration.zero;
        double progress = 0;
        final DayTimes? tt = prayer.times(today);
        if (tt != null && tm != null && ty != null) {
          final List<DateTime> ev = <DateTime>[...ty.all, ...tt.all, ...tm.all];
          final List<String> names = <String>[for (int i = 0; i < 3; i++) ...<String>[for (final _Slot s in _slots) s.key]];
          for (int i = 0; i < ev.length; i++) {
            if (ev[i].isAfter(now)) {
              nextKey = names[i];
              left = ev[i].difference(now);
              if (i > 0) {
                final double total = ev[i].difference(ev[i - 1]).inSeconds.toDouble();
                final double done = now.difference(ev[i - 1]).inSeconds.toDouble();
                progress = total <= 0 ? 0 : (done / total).clamp(0.0, 1.0).toDouble();
              }
              break;
            }
          }
        }
        String nextLabel = '';
        for (final _Slot s in _slots) {
          if (s.key == nextKey) nextLabel = s.label;
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFDCEBEF),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              Container(
                color: const Color(0xFF0F5C63),
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.location_on, color: Color(0xFFFFD66B), size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        prayer.hasPlace ? cityLabel(prayer.placeName) : tr('مقام منتخب نہیں (لاہور)'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(gmtLabel(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    if (widget.settingsButton)
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(builder: (BuildContext _) => const PrayerScreen()),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8, right: 8),
                          child: Icon(Icons.open_in_full, color: Colors.white, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
              if (t == null)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('اس مقام کے لیے اوقات کا حساب ممکن نہیں۔ کوئی اور شہر چنیں۔', style: TextStyle(height: 1.8)),
                )
              else ...<Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          nextLabel.isEmpty ? '' : nextLabel,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF123A3F)),
                        ),
                      ),
                      Text(
                        hms(left),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: Color(0xFF1B2B2E),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE5C9D1),
                      color: const Color(0xFF3AA66F),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      dateLine(shownDay, adjust: prayer.hijriAdjust),
                      style: const TextStyle(fontSize: 16, color: Color(0xFF1B2B2E)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.25,
                    children: <Widget>[
                      for (int i = 0; i < 6; i++) _timeBox(_slots[i], t.all[i], dayOffset == 0 && _slots[i].key == nextKey),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  color: const Color(0xFF0F5C63),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: () => setState(() => dayOffset--),
                      ),
                      TextButton(
                        onPressed: () => setState(() => dayOffset = 0),
                        child: Text(
                          dayOffset == 0 ? 'آج' : '${shownDay.day} ${kMonthsEn[shownDay.month - 1]}',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white),
                        onPressed: () => setState(() => dayOffset++),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _timeBox(_Slot s, DateTime time, bool next) {
    return Container(
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(12),
        border: next ? Border.all(color: const Color(0xFFFFD66B), width: 3) : null,
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(s.icon, color: s.fg, size: 22),
              const SizedBox(width: 6),
              Text(s.label, style: TextStyle(color: s.fg, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(clock12(time), style: TextStyle(color: s.fg, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 3),
              Text(ampm(time), style: TextStyle(color: s.fg, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: prayer,
      builder: (BuildContext context, Widget? _) {
        return Scaffold(
          appBar: appBar('نماز کے اوقات'),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: <Widget>[
              const PrayerCard(settingsButton: false),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.location_city, color: kGreen),
                      title: const Text('مقام'),
                      subtitle: Text(prayer.hasPlace
                          ? '${cityLabel(prayer.placeName)}${prayer.fromGps ? ' (GPS)' : ''}'
                          : 'ابھی منتخب نہیں'),
                      trailing: Icon(kChevron),
                      onTap: () => pickCity(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.calculate, color: kGreen),
                      title: const Text('حساب کا طریقہ'),
                      subtitle: Text(methodById(prayer.method).name),
                      trailing: Icon(kChevron),
                      onTap: () async {
                        final String? r = await showModalBottomSheet<String>(
                          context: context,
                          builder: (BuildContext ctx) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: kMethods
                                  .map((Method m) => ListTile(
                                        title: Text(m.name),
                                        trailing: m.id == prayer.method ? const Icon(Icons.check) : null,
                                        onTap: () => Navigator.pop(ctx, m.id),
                                      ))
                                  .toList(),
                            ),
                          ),
                        );
                        if (r != null) prayer.setMethod(r);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: Icon(Icons.wb_cloudy, color: kGreen),
                      title: const Text('عصر: حنفی (سایہ دوگنا)'),
                      subtitle: const Text('بند کریں تو شافعی/مالکی/حنبلی (سایہ ایک گنا)'),
                      value: prayer.hanafi,
                      onChanged: (bool v) => prayer.setHanafi(v),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.calendar_month, color: kGreen),
                      title: const Text('ہجری تاریخ میں ایڈجسٹمنٹ'),
                      subtitle: const Text('چاند نظر آنے کے مطابق ایک دن آگے/پیچھے'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => prayer.setHijriAdjust(prayer.hijriAdjust - 1),
                          ),
                          Text('${prayer.hijriAdjust > 0 ? '+' : ''}${prayer.hijriAdjust}'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => prayer.setHijriAdjust(prayer.hijriAdjust + 1),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.tune, color: Color(0xFF0B5D4B)),
                      title: Text('وقت خود درست کریں (منٹ)'),
                      subtitle: Text('اپنی مسجد کے وقت کے مطابق ہر نماز کو آگے/پیچھے کریں'),
                    ),
                    for (final _Slot s in _slots)
                      ListTile(
                        dense: true,
                        leading: Icon(s.icon, color: kGreen),
                        title: Text(s.label),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => prayer.setTune(s.key, prayer.tuneOf(s.key) - 1),
                            ),
                            SizedBox(
                              width: 36,
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text('${prayer.tuneOf(s.key) > 0 ? '+' : ''}${prayer.tuneOf(s.key)}', textAlign: TextAlign.center),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => prayer.setTune(s.key, prayer.tuneOf(s.key) + 1),
                            ),
                          ],
                        ),
                      ),
                    TextButton(
                      onPressed: () => prayer.resetTune(),
                      child: const Text('سب وقت اصل حالت پر لائیں'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'اوقات فون پر ہی (بغیر انٹرنیٹ) فلکیاتی حساب سے نکالے جاتے ہیں۔ احتیاطاً اپنی مسجد کے جنتری وقت سے ملا لیں۔',
                  style: TextStyle(color: kMuted, height: 1.8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
