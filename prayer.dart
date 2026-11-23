import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'local.dart';
import 'native.dart';

// ---------------------------------------------------------------
//  Places (used when GPS is not available) - name, lat, lon
// ---------------------------------------------------------------
class Place {
  final String name;
  final String en;
  final double lat;
  final double lon;
  const Place(this.name, this.en, this.lat, this.lon);
}

const List<Place> kCities = <Place>[
  Place('لاہور', 'Lahore', 31.5204, 74.3587),
  Place('کراچی', 'Karachi', 24.8607, 67.0011),
  Place('اسلام آباد', 'Islamabad', 33.6844, 73.0479),
  Place('راولپنڈی', 'Rawalpindi', 33.5651, 73.0169),
  Place('فیصل آباد', 'Faisalabad', 31.4504, 73.1350),
  Place('ملتان', 'Multan', 30.1575, 71.5249),
  Place('پشاور', 'Peshawar', 34.0151, 71.5249),
  Place('کوئٹہ', 'Quetta', 30.1798, 66.9750),
  Place('حیدرآباد', 'Hyderabad', 25.3960, 68.3578),
  Place('سیالکوٹ', 'Sialkot', 32.4945, 74.5229),
  Place('گوجرانوالہ', 'Gujranwala', 32.1877, 74.1945),
  Place('بہاولپور', 'Bahawalpur', 29.3956, 71.6836),
  Place('سرگودھا', 'Sargodha', 32.0836, 72.6711),
  Place('سکھر', 'Sukkur', 27.7052, 68.8574),
  Place('مردان', 'Mardan', 34.1986, 72.0404),
  Place('ایبٹ آباد', 'Abbottabad', 34.1688, 73.2215),
  Place('مظفر آباد', 'Muzaffarabad', 34.3700, 73.4711),
  Place('گلگت', 'Gilgit', 35.9208, 74.3144),
  Place('سوات (مینگورہ)', 'Swat (Mingora)', 34.7717, 72.3600),
  Place('ڈیرہ اسماعیل خان', 'Dera Ismail Khan', 31.8626, 70.9019),
  Place('دہلی', 'Delhi', 28.6139, 77.2090),
  Place('ممبئی', 'Mumbai', 19.0760, 72.8777),
  Place('ڈھاکہ', 'Dhaka', 23.8103, 90.4125),
  Place('کابل', 'Kabul', 34.5553, 69.2075),
  Place('مکہ مکرمہ', 'Makkah', 21.3891, 39.8579),
  Place('مدینہ منورہ', 'Madinah', 24.5247, 39.5692),
  Place('ریاض', 'Riyadh', 24.7136, 46.6753),
  Place('جدہ', 'Jeddah', 21.4858, 39.1925),
  Place('دبئی', 'Dubai', 25.2048, 55.2708),
  Place('دوحہ', 'Doha', 25.2854, 51.5310),
  Place('کویت', 'Kuwait', 29.3759, 47.9774),
  Place('مسقط', 'Muscat', 23.5880, 58.3829),
  Place('استنبول', 'Istanbul', 41.0082, 28.9784),
  Place('قاہرہ', 'Cairo', 30.0444, 31.2357),
  Place('لندن', 'London', 51.5072, -0.1276),
  Place('مانچسٹر', 'Manchester', 53.4808, -2.2426),
  Place('نیویارک', 'New York', 40.7128, -74.0060),
  Place('ٹورنٹو', 'Toronto', 43.6532, -79.3832),
  Place('کوالالمپور', 'Kuala Lumpur', 3.1390, 101.6869),
  Place('جکارتہ', 'Jakarta', -6.2088, 106.8456),
  Place('سڈنی', 'Sydney', -33.8688, 151.2093),
];

// ---------------------------------------------------------------
//  Calculation methods
// ---------------------------------------------------------------
class Method {
  final String id;
  final String name;
  final double fajr;
  final double isha; // degrees, or minutes after maghrib when ishaMinutes > 0
  final double ishaMinutes;
  const Method(this.id, this.name, this.fajr, this.isha, {this.ishaMinutes = 0});
}

const List<Method> kMethods = <Method>[
  Method('karachi', 'کراچی (جامعہ علوم اسلامیہ)', 18, 18),
  Method('mwl', 'مسلم ورلڈ لیگ', 18, 17),
  Method('isna', 'شمالی امریکہ (ISNA)', 15, 15),
  Method('egypt', 'مصر', 19.5, 17.5),
  Method('makkah', 'ام القریٰ (مکہ)', 18.5, 0, ishaMinutes: 90),
];

Method methodById(String id) {
  for (final Method m in kMethods) {
    if (m.id == id) return m;
  }
  return kMethods.first;
}

class DayTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  const DayTimes(this.fajr, this.sunrise, this.dhuhr, this.asr, this.maghrib, this.isha);

  List<DateTime> get all => <DateTime>[fajr, sunrise, dhuhr, asr, maghrib, isha];
}

// ---------------------------------------------------------------
//  Astronomy (same formulas as the well-known PrayTimes.org library)
// ---------------------------------------------------------------
double _rad(double d) => d * math.pi / 180.0;
double _deg(double r) => r * 180.0 / math.pi;
double _fixAngle(double a) {
  a = a - 360.0 * (a / 360.0).floorToDouble();
  return a < 0 ? a + 360 : a;
}

double _fixHour(double a) {
  a = a - 24.0 * (a / 24.0).floorToDouble();
  return a < 0 ? a + 24 : a;
}

double _julian(int y, int m, int d) {
  if (m <= 2) {
    y -= 1;
    m += 12;
  }
  final double a = (y / 100).floorToDouble();
  final double b = 2 - a + (a / 4).floorToDouble();
  return (365.25 * (y + 4716)).floorToDouble() + (30.6001 * (m + 1)).floorToDouble() + d + b - 1524.5;
}

class _Sun {
  final double decl;
  final double eqt;
  _Sun(this.decl, this.eqt);
}

_Sun _sunPosition(double jd) {
  final double dd = jd - 2451545.0;
  final double g = _fixAngle(357.529 + 0.98560028 * dd);
  final double q = _fixAngle(280.459 + 0.98564736 * dd);
  final double l = _fixAngle(q + 1.915 * math.sin(_rad(g)) + 0.020 * math.sin(_rad(2 * g)));
  final double e = 23.439 - 0.00000036 * dd;
  double ra = _deg(math.atan2(math.cos(_rad(e)) * math.sin(_rad(l)), math.cos(_rad(l)))) / 15.0;
  ra = _fixHour(ra);
  final double decl = _deg(math.asin(math.sin(_rad(e)) * math.sin(_rad(l))));
  final double eqt = q / 15.0 - ra;
  return _Sun(decl, eqt);
}

double _midDay(double jd, double t) {
  final _Sun s = _sunPosition(jd + t);
  return _fixHour(12 - s.eqt);
}

/// Time (hours) when the sun is [angle] degrees below the horizon.
double _sunAngleTime(double jd, double lat, double angle, double t, bool ccw) {
  final double decl = _sunPosition(jd + t).decl;
  final double noon = _midDay(jd, t);
  final double x = (-math.sin(_rad(angle)) - math.sin(_rad(decl)) * math.sin(_rad(lat))) /
      (math.cos(_rad(decl)) * math.cos(_rad(lat)));
  if (x < -1 || x > 1) return double.nan;
  final double v = _deg(math.acos(x)) / 15.0;
  return noon + (ccw ? -v : v);
}

double _asrTime(double jd, double lat, double factor, double t) {
  final double decl = _sunPosition(jd + t).decl;
  final double a = -_deg(math.atan(1.0 / (factor + math.tan(_rad((lat - decl).abs())))));
  return _sunAngleTime(jd, lat, a, t, false);
}

/// Calculates the six times of a day. [hanafi] only changes Asr.
DayTimes? calcTimes(DateTime day, double lat, double lon, Method m, bool hanafi, {double? tzHours}) {
  final double tz = tzHours ?? day.timeZoneOffset.inMinutes / 60.0;
  final double jd = _julian(day.year, day.month, day.day) - lon / (15.0 * 24.0);

  double fajr = 5 / 24, sunrise = 6 / 24, dhuhr = 12 / 24, asr = 13 / 24, maghrib = 18 / 24, isha = 18 / 24;
  for (int i = 0; i < 3; i++) {
    fajr = _sunAngleTime(jd, lat, m.fajr, fajr, true) / 24.0;
    sunrise = _sunAngleTime(jd, lat, 0.833, sunrise, true) / 24.0;
    dhuhr = _midDay(jd, dhuhr) / 24.0;
    asr = _asrTime(jd, lat, hanafi ? 2 : 1, asr) / 24.0;
    maghrib = _sunAngleTime(jd, lat, 0.833, maghrib, false) / 24.0;
    if (m.ishaMinutes > 0) {
      isha = maghrib + m.ishaMinutes / 1440.0;
    } else {
      isha = _sunAngleTime(jd, lat, m.isha, isha, false) / 24.0;
    }
  }
  final List<double> v = <double>[fajr, sunrise, dhuhr, asr, maghrib, isha];
  for (final double x in v) {
    if (x.isNaN) return null; // extreme latitude - caller shows a message
  }
  final double shift = tz - lon / 15.0;
  DateTime at(double frac) {
    final double hours = _fixHour(frac * 24.0 + shift);
    final int mins = (hours * 60.0 + 0.5).floor();
    return DateTime(day.year, day.month, day.day).add(Duration(minutes: mins));
  }

  return DayTimes(
    at(fajr),
    at(sunrise),
    at(dhuhr).add(const Duration(minutes: 1)),
    at(asr),
    at(maghrib).add(const Duration(minutes: 1)),
    at(isha),
  );
}

// ---------------------------------------------------------------
//  Qibla
// ---------------------------------------------------------------
const double kKaabaLat = 21.422487;
const double kKaabaLon = 39.826206;

double qiblaBearing(double lat, double lon) {
  final double p1 = _rad(lat);
  final double p2 = _rad(kKaabaLat);
  final double dl = _rad(kKaabaLon - lon);
  final double y = math.sin(dl);
  final double x = math.cos(p1) * math.tan(p2) - math.sin(p1) * math.cos(dl);
  return _fixAngle(_deg(math.atan2(y, x)));
}

double kaabaDistanceKm(double lat, double lon) {
  const double r = 6371.0;
  final double dLat = _rad(kKaabaLat - lat);
  final double dLon = _rad(kKaabaLon - lon);
  final double a = math.pow(math.sin(dLat / 2), 2).toDouble() +
      math.cos(_rad(lat)) * math.cos(_rad(kKaabaLat)) * math.pow(math.sin(dLon / 2), 2).toDouble();
  return 2 * r * math.asin(math.sqrt(a));
}

// ---------------------------------------------------------------
//  Hijri date (tabular Islamic calendar; +-1 day adjust in settings)
// ---------------------------------------------------------------
const List<String> kHijriMonthsUr = <String>[
  'محرم الحرام', 'صفر المظفر', 'ربیع الاول', 'ربیع الثانی', 'جمادی الاولیٰ', 'جمادی الثانیہ',
  'رجب المرجب', 'شعبان المعظم', 'رمضان المبارک', 'شوال المکرم', 'ذوالقعدہ', 'ذوالحجہ',
];
const List<String> kHijriMonthsEn = <String>[
  'Muharram', 'Safar', 'Rabi I', 'Rabi II', 'Jumada I', 'Jumada II',
  'Rajab', "Sha'ban", 'Ramadan', 'Shawwal', "Dhul Qa'dah", 'Dhul Hijjah',
];
const List<String> kWeekdaysUr = <String>['پیر', 'منگل', 'بدھ', 'جمعرات', 'جمعہ', 'ہفتہ', 'اتوار'];
const List<String> kMonthsEn = <String>[
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

class HijriDate {
  final int year;
  final int month; // 1..12
  final int day;
  const HijriDate(this.year, this.month, this.day);
}

int _gregToJdn(int y, int m, int d) {
  final int a = (14 - m) ~/ 12;
  final int yy = y + 4800 - a;
  final int mm = m + 12 * a - 3;
  return d + (153 * mm + 2) ~/ 5 + 365 * yy + yy ~/ 4 - yy ~/ 100 + yy ~/ 400 - 32045;
}

HijriDate toHijri(DateTime g, {int adjust = 0}) {
  final int jdn = _gregToJdn(g.year, g.month, g.day) + adjust;
  // Civil (tabular) Islamic calendar, epoch 1948440 (16 July 622 Julian).
  final int l = jdn - 1948440 + 10632;
  final int n = (l - 1) ~/ 10631;
  final int l2 = l - 10631 * n + 354;
  final int j = ((10985 - l2) ~/ 5316) * ((50 * l2) ~/ 17719) + (l2 ~/ 5670) * ((43 * l2) ~/ 15238);
  final int l3 = l2 - ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) - (j ~/ 16) * ((15238 * j) ~/ 43) + 29;
  final int month = (24 * l3) ~/ 709;
  final int day = l3 - (709 * month) ~/ 24;
  final int year = 30 * n + j - 30;
  return HijriDate(year, month, day);
}

// ---------------------------------------------------------------
//  Saved place + settings
// ---------------------------------------------------------------
class PrayerState extends ChangeNotifier {
  bool hasPlace = false;
  double lat = 31.5204;
  double lon = 74.3587;
  String placeName = 'لاہور';
  bool fromGps = false;
  String method = 'karachi';
  bool hanafi = true;
  int hijriAdjust = 0;
  bool locating = false;
  String locMessage = '';

  Future<void> load() async {
    final dynamic j = await Local.readJson('prayer.json');
    if (j is! Map) return;
    hasPlace = j['has'] == true;
    if (j['lat'] is num) lat = (j['lat'] as num).toDouble();
    if (j['lon'] is num) lon = (j['lon'] as num).toDouble();
    placeName = (j['name'] ?? placeName).toString();
    fromGps = j['gps'] == true;
    method = (j['method'] ?? 'karachi').toString();
    hanafi = j['hanafi'] != false;
    if (j['hadj'] is num) hijriAdjust = (j['hadj'] as num).toInt().clamp(-2, 2).toInt();
  }

  void _save() {
    Local.writeJson('prayer.json', <String, dynamic>{
      'has': hasPlace,
      'lat': lat,
      'lon': lon,
      'name': placeName,
      'gps': fromGps,
      'method': method,
      'hanafi': hanafi,
      'hadj': hijriAdjust,
    });
    notifyListeners();
  }

  void setCity(Place p) {
    hasPlace = true;
    lat = p.lat;
    lon = p.lon;
    placeName = p.name;
    fromGps = false;
    _save();
  }

  void setMethod(String m) {
    method = m;
    _save();
  }

  void setHanafi(bool v) {
    hanafi = v;
    _save();
  }

  void setHijriAdjust(int v) {
    hijriAdjust = v.clamp(-2, 2).toInt();
    _save();
  }

  /// Asks the phone for its position. Returns an Urdu message when it fails.
  Future<String> useGps() async {
    locating = true;
    locMessage = '';
    notifyListeners();
    String msg = '';
    try {
      final Map<String, dynamic> r = await Native.getLocation();
      final String st = (r['status'] ?? '').toString();
      if (st == 'ok' && r['lat'] is num && r['lon'] is num) {
        hasPlace = true;
        lat = (r['lat'] as num).toDouble();
        lon = (r['lon'] as num).toDouble();
        fromGps = true;
        placeName = 'آپ کا مقام';
        for (final Place c in kCities) {
          if ((c.lat - lat).abs() < 0.35 && (c.lon - lon).abs() < 0.35) {
            placeName = c.name;
            break;
          }
        }
        _save();
      } else if (st == 'denied') {
        msg = 'مقام کی اجازت نہیں ملی۔ فون کی سیٹنگ میں اجازت دیں یا فہرست سے شہر چنیں۔';
      } else if (st == 'off') {
        msg = 'فون کی لوکیشن (GPS) بند ہے۔ اسے چالو کریں یا فہرست سے شہر چنیں۔';
      } else {
        msg = 'مقام نہیں مل سکا۔ کھلی جگہ پر دوبارہ کوشش کریں یا فہرست سے شہر چنیں۔';
      }
    } catch (_) {
      msg = 'مقام نہیں مل سکا۔ فہرست سے شہر چنیں۔';
    }
    locating = false;
    locMessage = msg;
    notifyListeners();
    return msg;
  }

  DayTimes? times(DateTime day) => calcTimes(day, lat, lon, methodById(method), hanafi);
}

final PrayerState prayer = PrayerState();

String clock12(DateTime t) {
  int h = t.hour % 12;
  if (h == 0) h = 12;
  final String m = t.minute < 10 ? '0${t.minute}' : '${t.minute}';
  return '${h < 10 ? '0$h' : '$h'}:$m';
}

String ampm(DateTime t) => t.hour < 12 ? 'AM' : 'PM';

String hms(Duration d) {
  final int s = d.inSeconds < 0 ? 0 : d.inSeconds;
  String two(int n) => n < 10 ? '0$n' : '$n';
  return '${two(s ~/ 3600)}:${two((s % 3600) ~/ 60)}:${two(s % 60)}';
}
