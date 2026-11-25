import 'package:flutter/material.dart' hide Text;
import 'common.dart';
import 'i18n.dart';

const double kGoldNisabTola = 7.5;
const double kSilverNisabTola = 52.5;
const double kZakatRate = 0.025;

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final Map<String, TextEditingController> c = <String, TextEditingController>{
    'goldQty': TextEditingController(),
    'goldPrice': TextEditingController(),
    'silverQty': TextEditingController(),
    'silverPrice': TextEditingController(),
    'cash': TextEditingController(),
    'goods': TextEditingController(),
    'owed': TextEditingController(),
    'debts': TextEditingController(),
  };
  bool silverBasis = true; // silver nisab is lower, so it is the usual choice

  @override
  void dispose() {
    for (final TextEditingController t in c.values) {
      t.dispose();
    }
    super.dispose();
  }

  double _n(String k) => double.tryParse(c[k]!.text.replaceAll(',', '').trim()) ?? 0;

  String _fmt(double v) => v.round().toString();

  Widget _field(String k, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c[k],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: tr(label), border: const OutlineInputBorder(), isDense: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double goldValue = _n('goldQty') * _n('goldPrice');
    final double silverValue = _n('silverQty') * _n('silverPrice');
    final double assets = goldValue + silverValue + _n('cash') + _n('goods') + _n('owed');
    final double wealth = assets - _n('debts');
    final double nisab = silverBasis
        ? kSilverNisabTola * _n('silverPrice')
        : kGoldNisabTola * _n('goldPrice');
    final bool due = nisab > 0 && wealth >= nisab;
    final double zakat = due ? wealth * kZakatRate : 0;

    return Scaffold(
      appBar: appBar('زکوٰۃ کیلکولیٹر'),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFF3C4), borderRadius: BorderRadius.circular(14)),
            child: Text(
              'یہ ایک تخمینہ ہے۔ آخری فیصلہ کسی عالم سے تصدیق کروا کر کریں۔',
              style: const TextStyle(height: 1.8, color: Color(0xFF4E342E)),
            ),
          ),
          const SizedBox(height: 14),
          const SectionTitle('سونا اور چاندی'),
          _field('goldQty', 'سونا (تولہ)'),
          _field('goldPrice', 'سونے کا فی تولہ بھاؤ'),
          _field('silverQty', 'چاندی (تولہ)'),
          _field('silverPrice', 'چاندی کا فی تولہ بھاؤ'),
          const SizedBox(height: 6),
          const SectionTitle('دوسرے اثاثے'),
          _field('cash', 'نقد رقم اور بینک میں'),
          _field('goods', 'کاروبار کا سامان (قیمت)'),
          _field('owed', 'قابلِ وصول رقم'),
          const SizedBox(height: 6),
          const SectionTitle('قرض'),
          _field('debts', 'واجب الادا رقم (قرض)'),
          const SizedBox(height: 6),
          const SectionTitle('نصاب کی بنیاد'),
          Wrap(
            spacing: 8,
            children: <Widget>[
              ChoiceChip(
                label: Text('چاندی (52.5 تولہ)'),
                selected: silverBasis,
                onSelected: (_) => setState(() => silverBasis = true),
              ),
              ChoiceChip(
                label: Text('سونا (7.5 تولہ)'),
                selected: !silverBasis,
                onSelected: (_) => setState(() => silverBasis = false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: due ? const Color(0xFFE3F4EC) : kCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: due ? const Color(0xFF2E9E6E) : Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _row('کل مال', _fmt(wealth)),
                _row('نصاب', _fmt(nisab)),
                const Divider(height: 22),
                Text(
                  due ? 'زکوٰۃ واجب ہے' : 'نصاب کو نہیں پہنچا، زکوٰۃ واجب نہیں',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: due ? const Color(0xFF0B5D4B) : kMuted,
                  ),
                ),
                const SizedBox(height: 6),
                _row('زکوٰۃ (2.5 فیصد)', _fmt(zakat), big: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'اگر بھاؤ نہیں لکھیں گے تو نصاب صفر دکھائے گا۔ سونے اور چاندی کا بھاؤ اسی دن کا لکھیں جس دن زکوٰۃ دینی ہو۔',
            style: TextStyle(color: kMuted, height: 1.8, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool big = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: TextStyle(fontSize: big ? 17 : 15)),
          Text(value, style: TextStyle(fontSize: big ? 22 : 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
