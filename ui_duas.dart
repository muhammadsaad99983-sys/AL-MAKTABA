import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'common.dart';
import 'duas_data.dart';
import 'i18n.dart';
import 'models.dart';
import 'native.dart';
import 'nav.dart';
import 'settings.dart';
import 'state.dart';
import 'ui_search.dart';

const Map<String, String> _srcNames = <String, String>{
  'B': 'صحیح بخاری',
  'M': 'صحیح مسلم',
  'D': 'سنن ابی داؤد',
  'T': 'جامع ترمذی',
  'I': 'سنن ابن ماجہ',
  'N': 'سنن نسائی',
};

String duaTitle(Dua d) {
  if (settings.lang == 'en') return d.titleEn;
  if (settings.lang == 'ar') return d.titleAr;
  return d.titleUr;
}

String duaSource(Dua d) {
  final List<String> out = <String>[];
  for (final String p in d.src.split(' ')) {
    if (p.startsWith('Q:')) {
      out.add(tf('قرآن مجید %s', <Object>[p.substring(2)]));
    } else {
      for (final String ch in p.split('')) {
        final String? n = _srcNames[ch];
        if (n != null) out.add(tr(n));
      }
    }
  }
  return out.join(' ، ');
}

String duaAsText(Dua d) {
  final StringBuffer b = StringBuffer();
  b.writeln(duaTitle(d));
  b.writeln();
  b.writeln(d.arabic);
  if (settings.lang == 'ur') {
    b.writeln();
    b.writeln(d.ur);
  } else if (settings.lang == 'en') {
    b.writeln();
    b.writeln(d.en);
  }
  b.writeln();
  b.write('— ${tr('اسلام 960')}');
  return b.toString();
}

class DuasScreen extends StatelessWidget {
  const DuasScreen({super.key});

  static const Map<String, IconData> _icons = <String, IconData>{
    'morning': Icons.wb_sunny_outlined,
    'evening': Icons.nights_stay_outlined,
    'sleep': Icons.bedtime_outlined,
    'food': Icons.restaurant_outlined,
    'travel': Icons.flight_takeoff,
    'home': Icons.home_outlined,
    'prayer': Icons.mosque_outlined,
    'quran': Icons.menu_book_outlined,
    'hadith': Icons.format_quote,
    'daily': Icons.volunteer_activism,
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lib,
      builder: (BuildContext context, Widget? _) {
        final List<Post> mine =
            lib.posts.where((Post p) => p.kind == 'dua' || p.kind == 'zikr').toList();
        return Scaffold(
          appBar: appBar('دعائیں'),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: <Widget>[
              ...kDuaCats.entries.map((MapEntry<String, String> e) {
                final int n = kDuas.where((Dua d) => d.cat == e.key).length;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: kLight,
                      child: Icon(_icons[e.key] ?? Icons.auto_awesome, color: kGreen),
                    ),
                    title: Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(tf('%s دعائیں', <Object>[n])),
                    trailing: Icon(kChevron),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (BuildContext _) => DuaCategoryScreen(cat: e.key)),
                    ),
                  ),
                );
              }),
              if (mine.isNotEmpty) ...<Widget>[
                const SectionTitle('مکتبے کی طرف سے شامل کردہ'),
                ...mine.map((Post p) => postTile(context, p)),
              ],
            ],
          ),
        );
      },
    );
  }
}

class DuaCategoryScreen extends StatelessWidget {
  final String cat;
  const DuaCategoryScreen({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    final List<Dua> items = kDuas.where((Dua d) => d.cat == cat).toList();
    return Scaffold(
      appBar: appBar(kDuaCats[cat] ?? 'دعائیں'),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int i) {
          final Dua d = items[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (BuildContext _) => DuaDetailScreen(dua: d)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(duaTitle(d), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.5)),
                    const SizedBox(height: 6),
                    Text(
                      d.arabic,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: TextStyle(color: kMuted, fontSize: 16, height: 1.9),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DuaDetailScreen extends StatelessWidget {
  final Dua dua;
  const DuaDetailScreen({super.key, required this.dua});

  @override
  Widget build(BuildContext context) {
    final String meaning = settings.lang == 'ur' ? dua.ur : (settings.lang == 'en' ? dua.en : '');
    return Scaffold(
      appBar: appBar('دعا', actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.copy),
          tooltip: tr('کاپی'),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: duaAsText(dua)));
            if (context.mounted) snack(context, 'کاپی ہو گیا');
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: tr('شیئر'),
          onPressed: () => Native.shareText(duaAsText(dua), tr('شیئر کریں')),
        ),
      ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(duaTitle(dua), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kDark, height: 1.7)),
          if (dua.times.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Align(alignment: AlignmentDirectional.centerStart, child: Pill(tr(dua.times), kGold)),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: kWarm, borderRadius: BorderRadius.circular(14)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SelectableText(
                dua.arabic,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26 , height: 2.2, color: kText),
              ),
            ),
          ),
          if (meaning.isNotEmpty) ...<Widget>[
            const SectionTitle('ترجمہ'),
            SelectableText(meaning, style: TextStyle(fontSize: 16, height: 2.0, color: kText)),
          ],
          const SectionTitle('حوالہ'),
          Text(duaSource(dua), style: TextStyle(color: kMuted, height: 1.8)),
        ],
      ),
    );
  }
}

/// All posts of one kind (hadith, fatawa ...).
class KindScreen extends StatelessWidget {
  final String kind;
  final String title;
  const KindScreen({super.key, required this.kind, required this.title});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lib,
      builder: (BuildContext context, Widget? _) {
        final List<Post> items = lib.posts.where((Post p) => p.kind == kind).toList();
        return Scaffold(
          appBar: appBar(title, actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext _) => SearchScreen(initialMode: kind == 'hadith' ? 'hadith' : 'all'),
                ),
              ),
            ),
          ]),
          body: items.isEmpty
              ? const EmptyState(Icons.article_outlined, 'ابھی اس حصے میں کوئی مواد شامل نہیں کیا گیا۔')
              : ListView(
                  padding: const EdgeInsets.only(bottom: 20, top: 8),
                  children: items.map((Post p) => postTile(context, p)).toList(),
                ),
        );
      },
    );
  }
}
