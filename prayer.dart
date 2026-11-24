import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'local.dart';
import 'native.dart';
import 'settings.dart';

// ---------------------------------------------------------------
//  Places (used when GPS is not available) - name, lat, lon
// ---------------------------------------------------------------
class Place {
  final String name;
  final String en;
  final double lat;
  final double lon;
  final String ar;
  const Place(this.name, this.en, this.lat, this.lon, [this.ar = '']);
}

/// Name of a saved place in the app language.
String cityLabel(String urName) {
  final String l = settings.lang;
  if (l == 'ur') return urName;
  for (final Place c in kCities) {
    if (c.name == urName) {
      if (l == 'en') return c.en;
      return c.ar.isNotEmpty ? c.ar : c.name;
    }
  }
  return urName;
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
  Place('دہلی', 'Delhi', 28.6139, 77.2090, 'دلهي'),
  Place('ممبئی', 'Mumbai', 19.0760, 72.8777, 'مومباي'),
  Place('ڈھاکہ', 'Dhaka', 23.8103, 90.4125, 'دكا'),
  Place('کابل', 'Kabul', 34.5553, 69.2075, 'كابل'),
  Place('مکہ مکرمہ', 'Makkah', 21.3891, 39.8579, 'مكة المكرمة'),
  Place('مدینہ منورہ', 'Madinah', 24.5247, 39.5692, 'المدينة المنورة'),
  Place('ریاض', 'Riyadh', 24.7136, 46.6753, 'الرياض'),
  Place('جدہ', 'Jeddah', 21.4858, 39.1925, 'جدة'),
  Place('دبئی', 'Dubai', 25.2048, 55.2708, 'دبي'),
  Place('دوحہ', 'Doha', 25.2854, 51.5310, 'الدوحة'),
  Place('کویت', 'Kuwait', 29.3759, 47.9774, 'الكويت'),
  Place('مسقط', 'Muscat', 23.5880, 58.3829, 'مسقط'),
  Place('استنبول', 'Istanbul', 41.0082, 28.9784, 'إسطنبول'),
  Place('قاہرہ', 'Cairo', 30.0444, 31.2357, 'القاهرة'),
  Place('لندن', 'London', 51.5072, -0.1276, 'لندن'),
  Place('مانچسٹر', 'Manchester', 53.4808, -2.2426, 'مانشستر'),
  Place('نیویارک', 'New York', 40.7128, -74.0060, 'نيويورك'),
  Place('ٹورنٹو', 'Toronto', 43.6532, -79.3832, 'تورونتو'),
  Place('کوالالمپور', 'Kuala Lumpur', 3.1390, 101.6869, 'كوالالمبور'),
  Place('جکارتہ', 'Jakarta', -6.2088, 106.8456, 'جاكرتا'),
  Place('سڈنی', 'Sydney', -33.8688, 151.2093, 'سيدني'),
  Place('ملاکنڈ', 'Malakand', 34.5650, 71.9300),
  Place('بٹ خیلہ', 'Batkhela', 34.6177, 71.9700),
  Place('چکدرہ', 'Chakdara', 34.6500, 72.0300),
  Place('دیر', 'Dir', 35.2074, 71.8768),
  Place('تیمرگرہ', 'Timergara', 34.8277, 71.8419),
  Place('ڈگر (بونیر)', 'Daggar (Buner)', 34.5100, 72.4800),
  Place('چترال', 'Chitral', 35.8500, 71.7864),
  Place('کوہاٹ', 'Kohat', 33.5869, 71.4414),
  Place('بنوں', 'Bannu', 32.9889, 70.6056),
  Place('لکی مروت', 'Lakki Marwat', 32.6070, 70.9120),
  Place('ٹانک', 'Tank', 32.2170, 70.3830),
  Place('چارسدہ', 'Charsadda', 34.1453, 71.7308),
  Place('نوشہرہ', 'Nowshera', 34.0153, 71.9747),
  Place('صوابی', 'Swabi', 34.1200, 72.4700),
  Place('مانسہرہ', 'Mansehra', 34.3333, 73.2000),
  Place('ہری پور', 'Haripur', 33.9940, 72.9330),
  Place('اٹک', 'Attock', 33.7667, 72.3598),
  Place('جہلم', 'Jhelum', 32.9425, 73.7257),
  Place('چکوال', 'Chakwal', 32.9328, 72.8630),
  Place('گجرات', 'Gujrat', 32.5731, 74.0789),
  Place('شیخوپورہ', 'Sheikhupura', 31.7131, 73.9783),
  Place('قصور', 'Kasur', 31.1187, 74.4500),
  Place('اوکاڑہ', 'Okara', 30.8138, 73.4534),
  Place('ساہیوال', 'Sahiwal', 30.6682, 73.1114),
  Place('جھنگ', 'Jhang', 31.2681, 72.3181),
  Place('میانوالی', 'Mianwali', 32.5839, 71.5370),
  Place('خانیوال', 'Khanewal', 30.3017, 71.9321),
  Place('وہاڑی', 'Vehari', 30.0452, 72.3489),
  Place('بہاولنگر', 'Bahawalnagar', 29.9987, 73.2536),
  Place('رحیم یار خان', 'Rahim Yar Khan', 28.4202, 70.2952),
  Place('ڈیرہ غازی خان', 'Dera Ghazi Khan', 30.0561, 70.6403),
  Place('مظفر گڑھ', 'Muzaffargarh', 30.0703, 71.1933),
  Place('نواب شاہ', 'Nawabshah', 26.2483, 68.4097),
  Place('لاڑکانہ', 'Larkana', 27.5589, 68.2123),
  Place('میرپور خاص', 'Mirpur Khas', 25.5276, 69.0159),
  Place('گوادر', 'Gwadar', 25.1216, 62.3254),
  Place('خضدار', 'Khuzdar', 27.8000, 66.6167),
  Place('میرپور (آزاد کشمیر)', 'Mirpur (AJK)', 33.1478, 73.7519),
  Place('کوٹلی', 'Kotli', 33.5156, 73.9019),
  Place('باغ', 'Bagh', 33.9800, 73.7800),
  Place('سکردو', 'Skardu', 35.2971, 75.6333),
  Place('شارجہ', 'Sharjah', 25.3463, 55.4209, 'الشارقة'),
  Place('ابوظہبی', 'Abu Dhabi', 24.4539, 54.3773, 'أبوظبي'),
  Place('منامہ', 'Manama', 26.2285, 50.5860, 'المنامة'),
  Place('برمنگھم', 'Birmingham', 52.4862, -1.8904, 'برمنغهام'),
  Place('بریڈفورڈ', 'Bradford', 53.7960, -1.7594, 'برادفورد'),
  Place('بھکر', 'Bhakkar', 31.6270, 71.0654),
  Place('چنیوٹ', 'Chiniot', 31.7200, 72.9780),
  Place('حافظ آباد', 'Hafizabad', 32.0709, 73.6885),
  Place('خوشاب', 'Khushab', 32.2976, 72.3525),
  Place('لیہ', 'Layyah', 30.9613, 70.9390),
  Place('لودھراں', 'Lodhran', 29.5393, 71.6324),
  Place('منڈی بہاؤالدین', 'Mandi Bahauddin', 32.5861, 73.4917),
  Place('ننکانہ صاحب', 'Nankana Sahib', 31.4500, 73.7000),
  Place('نارووال', 'Narowal', 32.1019, 74.8730),
  Place('پاکپتن', 'Pakpattan', 30.3438, 73.3873),
  Place('راجن پور', 'Rajanpur', 29.1044, 70.3250),
  Place('ٹوبہ ٹیک سنگھ', 'Toba Tek Singh', 30.9709, 72.4826),
  Place('مری', 'Murree', 33.9070, 73.3943),
  Place('تونسہ', 'Taunsa', 30.7047, 70.6506),
  Place('کوٹ ادو', 'Kot Addu', 30.4694, 70.9669),
  Place('وزیر آباد', 'Wazirabad', 32.4423, 74.1200),
  Place('صادق آباد', 'Sadiqabad', 28.3009, 70.1302),
  Place('ڈسکہ', 'Daska', 32.3243, 74.3500),
  Place('کامونکی', 'Kamoke', 31.9770, 74.2230),
  Place('گوجرہ', 'Gojra', 31.1500, 72.6833),
  Place('بورے والا', 'Burewala', 30.1667, 72.6500),
  Place('جڑانوالہ', 'Jaranwala', 31.3331, 73.4189),
  Place('خانپور', 'Khanpur', 28.6470, 70.6620),
  Place('عارف والا', 'Arifwala', 30.2900, 73.0650),
  Place('بدین', 'Badin', 24.6560, 68.8370),
  Place('دادو', 'Dadu', 26.7300, 67.7750),
  Place('گھوٹکی', 'Ghotki', 28.0060, 69.3150),
  Place('جیکب آباد', 'Jacobabad', 28.2769, 68.4514),
  Place('جامشورو', 'Jamshoro', 25.4300, 68.2800),
  Place('کشمور', 'Kashmore', 28.4330, 69.5830),
  Place('خیرپور', 'Khairpur', 27.5295, 68.7592),
  Place('مٹیاری', 'Matiari', 25.5970, 68.4470),
  Place('نوشہرو فیروز', 'Naushahro Feroze', 26.8400, 68.1220),
  Place('سانگھڑ', 'Sanghar', 26.0460, 68.9480),
  Place('شکارپور', 'Shikarpur', 27.9556, 68.6382),
  Place('سجاول', 'Sujawal', 24.6050, 68.0730),
  Place('ٹنڈو الہ یار', 'Tando Allahyar', 25.4600, 68.7170),
  Place('ٹنڈو محمد خان', 'Tando Muhammad Khan', 25.1230, 68.5370),
  Place('ٹھٹھہ', 'Thatta', 24.7470, 67.9230),
  Place('عمرکوٹ', 'Umerkot', 25.3600, 69.7360),
  Place('مٹھی (تھرپارکر)', 'Mithi (Tharparkar)', 24.7370, 69.8000),
  Place('قمبر (شہداد کوٹ)', 'Qambar (Shahdadkot)', 27.5870, 68.0000),
  Place('سیہون', 'Sehwan', 26.4170, 67.8610),
  Place('تربت', 'Turbat', 26.0012, 63.0544),
  Place('سبی', 'Sibi', 29.5430, 67.8770),
  Place('ژوب', 'Zhob', 31.3410, 69.4490),
  Place('لورالائی', 'Loralai', 30.3705, 68.5979),
  Place('چمن', 'Chaman', 30.9210, 66.4590),
  Place('پشین', 'Pishin', 30.5800, 66.9970),
  Place('قلات', 'Kalat', 29.0260, 66.5890),
  Place('نوشکی', 'Nushki', 29.5530, 66.0220),
  Place('ڈیرہ مراد جمالی', 'Dera Murad Jamali', 28.5460, 68.2230),
  Place('خاران', 'Kharan', 28.5830, 65.4170),
  Place('پنجگور', 'Panjgur', 26.9710, 64.0950),
  Place('آواران', 'Awaran', 26.4560, 65.2300),
  Place('اوتھل (لسبیلہ)', 'Uthal (Lasbela)', 25.8000, 66.6200),
  Place('حب', 'Hub', 25.0430, 66.8960),
  Place('کوہلو', 'Kohlu', 29.8960, 69.2540),
  Place('بارکھان', 'Barkhan', 29.8970, 69.5250),
  Place('موسیٰ خیل', 'Musakhel', 30.8580, 69.8210),
  Place('قلعہ سیف اللہ', 'Qila Saifullah', 30.7000, 68.3600),
  Place('قلعہ عبداللہ', 'Qila Abdullah', 30.7300, 66.6600),
  Place('زیارت', 'Ziarat', 30.3800, 67.7260),
  Place('مستونگ', 'Mastung', 29.7990, 66.8450),
  Place('دالبندین (چاغی)', 'Dalbandin (Chagai)', 28.8900, 64.4100),
  Place('جھل مگسی', 'Jhal Magsi', 28.2900, 67.4400),
  Place('ہرنائی', 'Harnai', 30.1000, 67.9400),
  Place('اوستہ محمد', 'Usta Muhammad', 28.1770, 68.0450),
  Place('بٹگرام', 'Battagram', 34.6780, 73.0230),
  Place('الپوری (شانگلہ)', 'Alpuri (Shangla)', 34.9000, 72.6300),
  Place('داسو (کوہستان)', 'Dassu (Kohistan)', 35.2900, 73.2100),
  Place('ہنگو', 'Hangu', 33.5320, 71.0590),
  Place('کرک', 'Karak', 33.1160, 71.0930),
  Place('کلایہ (اورکزئی)', 'Kalaya (Orakzai)', 33.7190, 70.9130),
  Place('پاڑاچنار (کرم)', 'Parachinar (Kurram)', 33.8990, 70.1000),
  Place('لنڈی کوتل (خیبر)', 'Landi Kotal (Khyber)', 34.0990, 71.1560),
  Place('خار (باجوڑ)', 'Khar (Bajaur)', 34.7370, 71.5090),
  Place('غلنئی (مہمند)', 'Ghalanai (Mohmand)', 34.3920, 71.4120),
  Place('میران شاہ (شمالی وزیرستان)', 'Miranshah (North Waziristan)', 32.9860, 70.0710),
  Place('وانا (جنوبی وزیرستان)', 'Wana (South Waziristan)', 32.3000, 69.5670),
  Place('اوگی (تورغر)', 'Oghi (Torghar)', 34.4720, 73.1360),
  Place('درگئی', 'Dargai', 34.5030, 71.9040),
  Place('راولاکوٹ', 'Rawalakot', 33.8584, 73.7600),
  Place('بھمبر', 'Bhimber', 32.9750, 74.0780),
  Place('اٹھمقام (نیلم)', 'Athmuqam (Neelum)', 34.5830, 73.8000),
  Place('کہوٹہ (ہویلی)', 'Forward Kahuta (Haveli)', 33.7133, 73.8957),
  Place('پلندری (سدھنوتی)', 'Pallandri (Sudhanoti)', 33.7130, 73.6910),
  Place('کریم آباد (ہنزہ)', 'Karimabad (Hunza)', 36.3160, 74.6620),
  Place('گاہکوچ (غذر)', 'Gahkuch (Ghizer)', 36.1770, 73.7640),
  Place('چلاس (دیامر)', 'Chilas (Diamer)', 35.4130, 74.0970),
  Place('استور', 'Astore', 35.3400, 74.8600),
  Place('خپلو (غانچے)', 'Khaplu (Ghanche)', 35.1580, 76.3350),
  Place('شگر', 'Shigar', 35.4260, 75.7360),
  Place('دمام', 'Dammam', 26.4207, 50.0888, 'الدمام'),
  Place('طائف', 'Taif', 21.2703, 40.4158, 'الطائف'),
  Place('تبوک', 'Tabuk', 28.3835, 36.5662, 'تبوك'),
  Place('ابہا', 'Abha', 18.2164, 42.5053, 'أبها'),
  Place('بریدہ', 'Buraydah', 26.3260, 43.9750, 'بريدة'),
  Place('الخبر', 'Khobar', 26.2794, 50.2083, 'الخبر'),
  Place('ینبع', 'Yanbu', 24.0895, 38.0618, 'ينبع'),
  Place('حائل', 'Hail', 27.5114, 41.7208, 'حائل'),
  Place('نجران', 'Najran', 17.4933, 44.1277, 'نجران'),
  Place('جازان', 'Jazan', 16.8892, 42.5511, 'جازان'),
  Place('الہفوف', 'Al Hofuf', 25.3647, 49.5877, 'الهفوف'),
  Place('عجمان', 'Ajman', 25.4052, 55.5136, 'عجمان'),
  Place('راس الخیمہ', 'Ras Al Khaimah', 25.7895, 55.9432, 'رأس الخيمة'),
  Place('العین', 'Al Ain', 24.2075, 55.7447, 'العين'),
  Place('فجیرہ', 'Fujairah', 25.1288, 56.3265, 'الفجيرة'),
  Place('صلالہ', 'Salalah', 17.0151, 54.0924, 'صلالة'),
  Place('صحار', 'Sohar', 24.3470, 56.7090, 'صحار'),
  Place('صنعاء', 'Sanaa', 15.3694, 44.1910, 'صنعاء'),
  Place('عدن', 'Aden', 12.7855, 45.0187, 'عدن'),
  Place('بغداد', 'Baghdad', 33.3152, 44.3661, 'بغداد'),
  Place('بصرہ', 'Basra', 30.5085, 47.7804, 'البصرة'),
  Place('موصل', 'Mosul', 36.3350, 43.1189, 'الموصل'),
  Place('نجف', 'Najaf', 32.0000, 44.3350, 'النجف'),
  Place('کربلا', 'Karbala', 32.6160, 44.0249, 'كربلاء'),
  Place('اربیل', 'Erbil', 36.1911, 44.0092, 'أربيل'),
  Place('تہران', 'Tehran', 35.6892, 51.3890, 'طهران'),
  Place('مشہد', 'Mashhad', 36.2605, 59.6168, 'مشهد'),
  Place('اصفہان', 'Isfahan', 32.6539, 51.6660, 'أصفهان'),
  Place('شیراز', 'Shiraz', 29.5918, 52.5837, 'شيراز'),
  Place('تبریز', 'Tabriz', 38.0962, 46.2738, 'تبريز'),
  Place('قم', 'Qom', 34.6416, 50.8746, 'قم'),
  Place('عمان', 'Amman', 31.9454, 35.9284, 'عمّان'),
  Place('عقبہ', 'Aqaba', 29.5320, 35.0063, 'العقبة'),
  Place('دمشق', 'Damascus', 33.5138, 36.2765, 'دمشق'),
  Place('حلب', 'Aleppo', 36.2021, 37.1343, 'حلب'),
  Place('بیروت', 'Beirut', 33.8938, 35.5018, 'بيروت'),
  Place('بیت المقدس (یروشلم)', 'Jerusalem', 31.7683, 35.2137, 'القدس'),
  Place('غزہ', 'Gaza', 31.5017, 34.4668, 'غزة'),
  Place('اسکندریہ', 'Alexandria', 31.2001, 29.9187, 'الإسكندرية'),
  Place('جیزہ', 'Giza', 30.0131, 31.2089, 'الجيزة'),
  Place('اقصر', 'Luxor', 25.6872, 32.6396, 'الأقصر'),
  Place('اسوان', 'Aswan', 24.0889, 32.8998, 'أسوان'),
  Place('پورٹ سعید', 'Port Said', 31.2653, 32.3019, 'بورسعيد'),
  Place('طرابلس (لیبیا)', 'Tripoli', 32.8872, 13.1913, 'طرابلس'),
  Place('تیونس', 'Tunis', 36.8065, 10.1815, 'تونس'),
  Place('الجزائر', 'Algiers', 36.7538, 3.0588, 'الجزائر'),
  Place('کاسابلانکا', 'Casablanca', 33.5731, -7.5898, 'الدار البيضاء'),
  Place('رباط', 'Rabat', 34.0209, -6.8416, 'الرباط'),
  Place('مراکش', 'Marrakesh', 31.6295, -7.9811, 'مراكش'),
  Place('فاس', 'Fez', 34.0331, -5.0003, 'فاس'),
  Place('خرطوم', 'Khartoum', 15.5007, 32.5599, 'الخرطوم'),
  Place('مقدیشو', 'Mogadishu', 2.0469, 45.3182, 'مقديشو'),
  Place('ادیس ابابا', 'Addis Ababa', 9.0300, 38.7400, 'أديس أبابا'),
  Place('نیروبی', 'Nairobi', -1.2921, 36.8219, 'نيروبي'),
  Place('لاگوس', 'Lagos', 6.5244, 3.3792, 'لاغوس'),
  Place('ابوجا', 'Abuja', 9.0765, 7.3986, 'أبوجا'),
  Place('کانو', 'Kano', 12.0022, 8.5920, 'كانو'),
  Place('ڈاکار', 'Dakar', 14.7167, -17.4677, 'داكار'),
  Place('جوہانسبرگ', 'Johannesburg', -26.2041, 28.0473, 'جوهانسبرغ'),
  Place('کیپ ٹاؤن', 'Cape Town', -33.9249, 18.4241, 'كيب تاون'),
  Place('ڈربن', 'Durban', -29.8587, 31.0218, 'ديربان'),
  Place('دار السلام', 'Dar es Salaam', -6.7924, 39.2083, 'دار السلام'),
  Place('اکرا', 'Accra', 5.6037, -0.1870, 'أكرا'),
  Place('انقرہ', 'Ankara', 39.9334, 32.8597, 'أنقرة'),
  Place('ازمیر', 'Izmir', 38.4237, 27.1428, 'إزمير'),
  Place('بورصہ', 'Bursa', 40.1885, 29.0610, 'بورصة'),
  Place('قونیہ', 'Konya', 37.8746, 32.4932, 'قونية'),
  Place('تاشقند', 'Tashkent', 41.2995, 69.2401, 'طشقند'),
  Place('سمرقند', 'Samarkand', 39.6270, 66.9750, 'سمرقند'),
  Place('بخارا', 'Bukhara', 39.7747, 64.4286, 'بخارى'),
  Place('الماتی', 'Almaty', 43.2220, 76.8512, 'ألماتي'),
  Place('باکو', 'Baku', 40.4093, 49.8671, 'باكو'),
  Place('قندھار', 'Kandahar', 31.6289, 65.7372, 'قندهار'),
  Place('ہرات', 'Herat', 34.3529, 62.2040, 'هرات'),
  Place('مزار شریف', 'Mazar-i-Sharif', 36.7069, 67.1100, 'مزار شريف'),
  Place('جلال آباد', 'Jalalabad', 34.4415, 70.4361, 'جلال آباد'),
  Place('کولکتہ', 'Kolkata', 22.5726, 88.3639, 'كولكاتا'),
  Place('چنئی', 'Chennai', 13.0827, 80.2707, 'تشيناي'),
  Place('حیدرآباد (بھارت)', 'Hyderabad (India)', 17.3850, 78.4867, 'حيدر أباد'),
  Place('لکھنؤ', 'Lucknow', 26.8467, 80.9462, 'لكناو'),
  Place('احمد آباد', 'Ahmedabad', 23.0225, 72.5714, 'أحمد آباد'),
  Place('بنگلور', 'Bengaluru', 12.9716, 77.5946, 'بنغالور'),
  Place('چٹاگانگ', 'Chittagong', 22.3569, 91.7832, 'شيتاغونغ'),
  Place('کولمبو', 'Colombo', 6.9271, 79.8612, 'كولومبو'),
  Place('کھٹمنڈو', 'Kathmandu', 27.7172, 85.3240, 'كاتماندو'),
  Place('مالے', 'Male', 4.1755, 73.5093, 'ماليه'),
  Place('سنگاپور', 'Singapore', 1.3521, 103.8198, 'سنغافورة'),
  Place('بینکاک', 'Bangkok', 13.7563, 100.5018, 'بانكوك'),
  Place('منیلا', 'Manila', 14.5995, 120.9842, 'مانيلا'),
  Place('سورابایا', 'Surabaya', -7.2575, 112.7521, 'سورابايا'),
  Place('باندونگ', 'Bandung', -6.9175, 107.6191, 'باندونغ'),
  Place('میدان', 'Medan', 3.5952, 98.6722, 'ميدان'),
  Place('بندر سری بگاوان', 'Bandar Seri Begawan', 4.9031, 114.9398, 'بندر سري بكاوان'),
  Place('رنگون', 'Yangon', 16.8409, 96.1735, 'يانغون'),
  Place('بیجنگ', 'Beijing', 39.9042, 116.4074, 'بكين'),
  Place('شنگھائی', 'Shanghai', 31.2304, 121.4737, 'شنغهاي'),
  Place('ہانگ کانگ', 'Hong Kong', 22.3193, 114.1694, 'هونغ كونغ'),
  Place('ارومچی', 'Urumqi', 43.8256, 87.6168, 'أورومتشي'),
  Place('ٹوکیو', 'Tokyo', 35.6762, 139.6503, 'طوكيو'),
  Place('سیول', 'Seoul', 37.5665, 126.9780, 'سيول'),
  Place('گلاسگو', 'Glasgow', 55.8642, -4.2518, 'غلاسكو'),
  Place('لیسٹر', 'Leicester', 52.6369, -1.1398, 'ليستر'),
  Place('پیرس', 'Paris', 48.8566, 2.3522, 'باريس'),
  Place('برلن', 'Berlin', 52.5200, 13.4050, 'برلين'),
  Place('فرینکفرٹ', 'Frankfurt', 50.1109, 8.6821, 'فرانكفورت'),
  Place('میڈرڈ', 'Madrid', 40.4168, -3.7038, 'مدريد'),
  Place('روم', 'Rome', 41.9028, 12.4964, 'روما'),
  Place('ایمسٹرڈیم', 'Amsterdam', 52.3676, 4.9041, 'أمستردام'),
  Place('برسلز', 'Brussels', 50.8503, 4.3517, 'بروكسل'),
  Place('اسٹاک ہوم', 'Stockholm', 59.3293, 18.0686, 'ستوكهولم'),
  Place('اوسلو', 'Oslo', 59.9139, 10.7522, 'أوسلو'),
  Place('کوپن ہیگن', 'Copenhagen', 55.6761, 12.5683, 'كوبنهاغن'),
  Place('ویانا', 'Vienna', 48.2082, 16.3738, 'فيينا'),
  Place('زیورخ', 'Zurich', 47.3769, 8.5417, 'زيورخ'),
  Place('ماسکو', 'Moscow', 55.7558, 37.6173, 'موسكو'),
  Place('سراییوو', 'Sarajevo', 43.8563, 18.4131, 'سراييفو'),
  Place('ڈبلن', 'Dublin', 53.3498, -6.2603, 'دبلن'),
  Place('لاس اینجلس', 'Los Angeles', 34.0522, -118.2437, 'لوس أنجلوس'),
  Place('شکاگو', 'Chicago', 41.8781, -87.6298, 'شيكاغو'),
  Place('ہیوسٹن', 'Houston', 29.7604, -95.3698, 'هيوستن'),
  Place('واشنگٹن', 'Washington D.C.', 38.9072, -77.0369, 'واشنطن'),
  Place('ڈیلاس', 'Dallas', 32.7767, -96.7970, 'دالاس'),
  Place('ڈیٹرائٹ', 'Detroit', 42.3314, -83.0458, 'ديترويت'),
  Place('اٹلانٹا', 'Atlanta', 33.7490, -84.3880, 'أتلانتا'),
  Place('سان فرانسسکو', 'San Francisco', 37.7749, -122.4194, 'سان فرانسيسكو'),
  Place('مائیامی', 'Miami', 25.7617, -80.1918, 'ميامي'),
  Place('مونٹریال', 'Montreal', 45.5017, -73.5673, 'مونتريال'),
  Place('وینکوور', 'Vancouver', 49.2827, -123.1207, 'فانكوفر'),
  Place('کیلگری', 'Calgary', 51.0447, -114.0719, 'كالغاري'),
  Place('میکسیکو سٹی', 'Mexico City', 19.4326, -99.1332, 'مكسيكو سيتي'),
  Place('ساؤ پاولو', 'Sao Paulo', -23.5505, -46.6333, 'ساو باولو'),
  Place('بیونس آئرس', 'Buenos Aires', -34.6037, -58.3816, 'بوينس آيرس'),
  Place('میلبورن', 'Melbourne', -37.8136, 144.9631, 'ملبورن'),
  Place('برسبین', 'Brisbane', -27.4698, 153.0251, 'بريزبن'),
  Place('پرتھ', 'Perth', -31.9505, 115.8605, 'بيرث'),
  Place('آک لینڈ', 'Auckland', -36.8509, 174.7645, 'أوكلاند'),
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
  final Map<String, int> tune = <String, int>{};
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
    final dynamic tj = j['tune'];
    if (tj is Map) {
      tj.forEach((dynamic k, dynamic v) {
        if (v is num) tune[k.toString()] = v.toInt().clamp(-60, 60).toInt();
      });
    }
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
      'tune': tune,
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

  void setCustom(String name, double la, double lo) {
    hasPlace = true;
    lat = la;
    lon = lo;
    placeName = name;
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

  int tuneOf(String key) => tune[key] ?? 0;

  void setTune(String key, int minutes) {
    final int v = minutes.clamp(-60, 60).toInt();
    if (v == 0) {
      tune.remove(key);
    } else {
      tune[key] = v;
    }
    _save();
  }

  void resetTune() {
    tune.clear();
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

  DayTimes? times(DateTime day) {
    final DayTimes? b = calcTimes(day, lat, lon, methodById(method), hanafi);
    if (b == null || tune.isEmpty) return b;
    DateTime f(DateTime t, String k) => t.add(Duration(minutes: tuneOf(k)));
    return DayTimes(f(b.fajr, 'fajr'), f(b.sunrise, 'sunrise'), f(b.dhuhr, 'dhuhr'), f(b.asr, 'asr'),
        f(b.maghrib, 'maghrib'), f(b.isha, 'isha'));
  }
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
