import 'package:flutter/material.dart' hide Text;
import 'api.dart';
import 'common.dart';
import 'i18n.dart';
import 'models.dart';
import 'nav.dart';
import 'state.dart';
import 'ui_admin.dart';
import 'ui_duas.dart';
import 'ui_lists.dart';
import 'ui_names.dart';
import 'ui_search.dart';

class HadithBook {
  final String ar;
  final String en;
  final String ur;
  final Color color;
  final List<String> keys; // matched inside title / source
  final List<String> exact; // matched when the whole source equals it
  const HadithBook(this.ar, this.en, this.ur, this.color, this.keys, {this.exact = const <String>[]});

  bool matchesPost(Post p) {
    final String s = p.source.toLowerCase().trim();
    if (s.isEmpty) return false;
    if (exact.contains(s)) return true;
    for (final String k in keys) {
      if (s.contains(k)) return true;
    }
    return false;
  }

  bool matchesBook(Book b) {
    final String s = '${b.title} ${b.author}'.toLowerCase();
    for (final String k in keys) {
      if (s.contains(k)) return true;
    }
    return false;
  }
}

const List<HadithBook> kHadithBooks = <HadithBook>[
  HadithBook('صَحِيحُ الْبُخَارِي', 'Sahih al-Bukhari', 'صحیح بخاری', Color(0xFFF5A800),
      <String>['بخاری', 'بخاري', 'bukhari', 'bukhary']),
  HadithBook('صَحِيحُ مُسْلِم', 'Sahih Muslim', 'صحیح مسلم', Color(0xFF5FA777),
      <String>['صحیح مسلم', 'صحيح مسلم', 'sahih muslim', 'sahih al-muslim', 'مسلم شریف'],
      exact: <String>['مسلم', 'muslim']),
  HadithBook('جَامِعُ التِّرْمِذِي', 'Jami at-Tirmidhi', 'جامع ترمذی', Color(0xFFB5483A),
      <String>['ترمذی', 'ترمذي', 'tirmidhi', 'tirmizi', 'tirmazi']),
  HadithBook('سُنَنُ أَبِي دَاوُود', 'Sunan Abi Dawud', 'سنن ابی داؤد', Color(0xFF3A86C8),
      <String>['ابی داؤد', 'ابو داؤد', 'ابوداؤد', 'ابی داود', 'ابو داود', 'dawud', 'dawood', 'daud']),
  HadithBook('سُنَنُ النَّسَائِي', "Sunan an-Nasa'i", 'سنن نسائی', Color(0xFF2DB57D),
      <String>['نسائی', 'نسائي', 'nasai', "nasa'i", 'nasa']),
  HadithBook('سُنَنُ ابْنِ مَاجَه', 'Sunan Ibn Majah', 'سنن ابن ماجہ', Color(0xFF8A5CE0),
      <String>['ماجہ', 'ماجه', 'majah', 'maja']),
  HadithBook('السِّلْسِلَةُ الصَّحِيحَة', 'As-Silsila as-Sahiha', 'سلسلہ صحیحہ', Color(0xFF2F7FC1),
      <String>['سلسلہ', 'سلسلة', 'silsila']),
  HadithBook('مُسْنَدُ أَحْمَد', 'Musnad Ahmad', 'مسند احمد', Color(0xFFB79A6A),
      <String>['مسند احمد', 'مسند أحمد', 'musnad']),
  HadithBook('مُوَطَّأُ مَالِك', 'Muwatta Imam Malik', 'موطا امام مالک', Color(0xFF00897B),
      <String>['موطا', 'موطأ', 'muwatta', 'امام مالک']),
  HadithBook('رِيَاضُ الصَّالِحِين', 'Riyad as-Salihin', 'ریاض الصالحین', Color(0xFFD84315),
      <String>['ریاض الصالحین', 'ریاض الصالحین', 'riyad', 'riyadh']),
  HadithBook('مِشْكَاةُ الْمَصَابِيح', 'Mishkat al-Masabih', 'مشکوٰۃ المصابیح', Color(0xFF6D4C41),
      <String>['مشکوۃ', 'مشکوٰۃ', 'مشكاة', 'mishkat']),
  HadithBook('بُلُوغُ الْمَرَام', 'Bulugh al-Maram', 'بلوغ المرام', Color(0xFF5E35B1),
      <String>['بلوغ', 'bulugh']),
  HadithBook('الْأَرْبَعُونَ النَّوَوِيَّة', 'Forty Hadith of Nawawi', 'اربعین نووی', Color(0xFF00838F),
      <String>['اربعین', 'اربعون', 'arbain', 'arbaeen', 'nawawi', 'نووی']),
];

class HadithTab extends StatelessWidget {
  const HadithTab({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lib,
      builder: (BuildContext context, Widget? _) {
        return Scaffold(
          appBar: appBar('کتبِ احادیث'),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
            children: <Widget>[
              Material(
                color: kCardBg,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (BuildContext _) => const SearchScreen(initialMode: 'hadith')),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.search, color: kGreen),
                        const SizedBox(width: 10),
                        const Expanded(child: Text('حدیث نمبر یا الفاظ سے تلاش کریں')),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _action(context, Icons.bookmark_border, 'پسندیدہ', () => _push(context, const ListsScreen(recent: false))),
                  _action(context, Icons.format_quote, 'تمام احادیث',
                      () => _push(context, const KindScreen(kind: 'hadith', title: 'احادیث نبویہ ﷺ'))),
                ],
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.18,
                children: kHadithBooks.map((HadithBook b) => _BookBox(book: b)).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _push(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext _) => page));

  Widget _action(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 30, color: kText),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _BookBox extends StatelessWidget {
  final HadithBook book;
  const _BookBox({required this.book});

  @override
  Widget build(BuildContext context) {
    final int posts = lib.posts.where(book.matchesPost).length;
    final int books = lib.books.where(book.matchesBook).length;
    final String count = (posts + books) == 0
        ? tr('ابھی کچھ شامل نہیں')
        : '${posts > 0 ? '$posts ${tr('احادیث')}' : ''}${posts > 0 && books > 0 ? '  •  ' : ''}${books > 0 ? '$books ${tr('کتب')}' : ''}';
    return Material(
      color: kCardBg,
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (BuildContext _) => HadithBookScreen(book: book)),
        ),
        child: CustomPaint(
          painter: CornerPainter(kFaint),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  book.ar,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(color: book.color, fontSize: 24, fontWeight: FontWeight.bold, height: 1.6),
                ),
                const SizedBox(height: 4),
                Text(
                  book.en,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: kText, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  count,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: kGreen, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HadithBookScreen extends StatelessWidget {
  final HadithBook book;
  const HadithBookScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lib,
      builder: (BuildContext context, Widget? _) {
        final List<Post> posts = lib.posts.where(book.matchesPost).toList();
        final List<Book> books = lib.books.where(book.matchesBook).toList();
        return Scaffold(
          appBar: appBar(book.ur, actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (BuildContext _) => const SearchScreen(initialMode: 'hadith')),
              ),
            ),
          ]),
          floatingActionButton: Api.isAdmin
              ? FloatingActionButton.extended(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (BuildContext _) => const PostForm()),
                  ),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('نئی حدیث'),
                )
              : null,
          body: (posts.isEmpty && books.isEmpty)
              ? const EmptyState(
                  Icons.menu_book_outlined,
                  'ابھی اس کتاب کی کوئی حدیث یا PDF شامل نہیں کی گئی۔\n(حدیث شامل کرتے وقت "حوالہ" میں کتاب کا نام لکھیں گے تو وہ یہاں خود آ جائے گی۔)',
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: 90, top: 4),
                  children: <Widget>[
                    if (books.isNotEmpty) ...<Widget>[
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: SectionTitle('کتابیں (PDF)')),
                      ...books.map((Book b) => bookTile(context, b)),
                    ],
                    if (posts.isNotEmpty) ...<Widget>[
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: SectionTitle('احادیث')),
                      ...posts.map((Post p) => postTile(context, p)),
                    ],
                  ],
                ),
        );
      },
    );
  }
}
