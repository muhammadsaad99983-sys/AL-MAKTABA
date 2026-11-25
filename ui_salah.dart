import 'package:flutter/material.dart' hide Text;
import 'common.dart';
import 'i18n.dart';

class _Step {
  final String t;
  final String b;
  const _Step(this.t, this.b);
}

const List<_Step> _kWudu = <_Step>[
  _Step('نیت کریں', 'دل میں وضو کی نیت کریں۔ زبان سے کہنا ضروری نہیں۔'),
  _Step('بسم اللہ پڑھیں', 'وضو شروع کرتے وقت “بِسْمِ اللَّهِ” کہیں۔'),
  _Step('ہاتھ دھوئیں', 'دونوں ہاتھ کلائیوں تک تین بار دھوئیں۔'),
  _Step('کلی کریں', 'منہ میں پانی ڈال کر تین بار کلی کریں۔'),
  _Step('ناک صاف کریں', 'ناک میں پانی ڈال کر تین بار جھاڑیں۔'),
  _Step('چہرہ دھوئیں', 'پیشانی کے بالوں سے ٹھوڑی تک، اور ایک کان سے دوسرے کان تک، تین بار۔'),
  _Step('بازو دھوئیں', 'پہلے دائیں ہاتھ کی کہنی سمیت، پھر بائیں کی، تین تین بار۔'),
  _Step('سر کا مسح', 'گیلے ہاتھوں سے ایک بار سر کا مسح کریں۔'),
  _Step('کانوں کا مسح', 'شہادت کی انگلیوں سے کان کے اندر اور انگوٹھوں سے باہر کا مسح کریں۔'),
  _Step('پاؤں دھوئیں', 'پہلے دایاں پاؤں، پھر بایاں، ٹخنوں اور انگلیوں سمیت، تین تین بار۔'),
  _Step('وضو کے بعد کی دعا', 'آسمان کی طرف دیکھ کر پڑھیں: أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ'),
];

const List<_Step> _kSalah = <_Step>[
  _Step('نیت کریں', 'دل میں نماز کی نیت کریں، مثلاً “فجر کی دو رکعت فرض”۔'),
  _Step('تکبیرِ تحریمہ', '“اللہ اکبر” کہہ کر دونوں ہاتھ کانوں تک اٹھائیں۔'),
  _Step('ہاتھ باندھیں', 'دایاں ہاتھ بائیں ہاتھ پر رکھ کر ناف کے نیچے باندھیں (حنفی طریقہ)۔'),
  _Step('ثنا، تعوذ اور بسم اللہ', 'ثنا: سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ۔ پھر أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ اور بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ۔ ثنا صرف پہلی رکعت میں ہے۔'),
  _Step('سورۃ الفاتحہ', 'سورۃ الفاتحہ پڑھیں، پھر قرآن کی کوئی سورت یا کم از کم تین چھوٹی آیات۔'),
  _Step('رکوع', '“اللہ اکبر” کہہ کر جھکیں، ہاتھ گھٹنوں پر رکھیں، اور تین بار سُبْحَانَ رَبِّيَ الْعَظِيمِ کہیں۔'),
  _Step('قومہ', 'رکوع سے سیدھے کھڑے ہوں اور کہیں: سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ، رَبَّنَا وَلَكَ الْحَمْدُ۔'),
  _Step('پہلا سجدہ', '“اللہ اکبر” کہہ کر سجدے میں جائیں، پیشانی اور ناک زمین پر رکھیں، اور تین بار سُبْحَانَ رَبِّيَ الْأَعْلَىٰ کہیں۔'),
  _Step('جلسہ', '“اللہ اکبر” کہہ کر سیدھے ہو کر بیٹھ جائیں۔'),
  _Step('دوسرا سجدہ', '“اللہ اکبر” کہہ کر دوبارہ سجدہ کریں اور تین بار سُبْحَانَ رَبِّيَ الْأَعْلَىٰ کہیں۔'),
  _Step('دوسری رکعت', '“اللہ اکبر” کہہ کر کھڑے ہوں۔ اس میں ثنا نہیں، صرف سورۃ الفاتحہ اور کوئی سورت پڑھیں، پھر رکوع اور سجدے کریں۔'),
  _Step('التحیات', 'دوسری رکعت کے دوسرے سجدے کے بعد بیٹھ کر التحیات پڑھیں۔'),
  _Step('درود اور دعا', 'درود شریف پڑھیں، پھر کوئی دعا (مثلاً رب اغفرلی) پڑھیں۔'),
  _Step('سلام', 'پہلے دائیں طرف منہ کر کے السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ، پھر بائیں طرف یہی کہیں۔'),
];

class SalahGuideScreen extends StatelessWidget {
  const SalahGuideScreen({super.key});

  Widget _list(List<_Step> steps) {
    return Column(
      children: <Widget>[
        for (int i = 0; i < steps.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: kGreen,
                  child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(steps[i].t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.6)),
                      const SizedBox(height: 4),
                      Text(steps[i].b, style: const TextStyle(height: 1.9, fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('نماز اور وضو کا طریقہ'),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: <Widget>[
          const SectionTitle('وضو کا طریقہ'),
          _list(_kWudu),
          const SizedBox(height: 10),
          const SectionTitle('نماز کا طریقہ (دو رکعت کی مثال)'),
          _list(_kSalah),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFFFF3C4), borderRadius: BorderRadius.circular(14)),
            child: const Text('تین رکعت (مغرب) یا چار رکعت (ظہر، عصر، عشاء) میں تیسری اور چوتھی رکعت میں صرف سورۃ الفاتحہ پڑھیں۔ دوسری رکعت کے بعد التحیات پڑھ کر “اللہ اکبر” کہہ کر کھڑے ہوں۔ آخر میں التحیات، درود اور سلام اسی طرح۔ کسی بھی شک میں اپنے امام یا عالم سے تصدیق کریں۔', style: TextStyle(height: 1.9, color: Color(0xFF4E342E))),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
