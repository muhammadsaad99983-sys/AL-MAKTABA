import 'package:flutter/material.dart';
import 'common.dart';
import 'models.dart';
import 'nav.dart';
import 'search_util.dart';
import 'state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController ctl = TextEditingController();
  String query = '';
  String mode = 'all'; // all | books | hadith | posts

  @override
  void dispose() {
    ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String q = normalizeText(query).trim();
    final List<String> tokens = tokensOf(query);
    final bool isNumber = RegExp(r'^\d+$').hasMatch(q);

    // ---- books
    final List<Book> bookHits = <Book>[];
    if (tokens.isNotEmpty && (mode == 'all' || mode == 'books')) {
      for (final Book b in lib.books) {
        if (containsAll(normalizeText('${b.title} ${b.author} ${b.description}'), tokens)) {
          bookHits.add(b);
        }
      }
    }

    // ---- posts (hadith number search lives here)
    final List<Post> exact = <Post>[];
    final List<Post> others = <Post>[];
    if (tokens.isNotEmpty && mode != 'books') {
      for (final Post p in lib.posts) {
        if (mode == 'hadith' && p.kind != 'hadith') continue;
        if (isNumber && numberMatches(p.number, q)) {
          exact.add(p);
          continue;
        }
        final String hay = normalizeText('${p.title} ${p.arabic} ${p.body} ${p.source} ${p.number}');
        if (containsAll(hay, tokens)) others.add(p);
      }
    }
    final List<Post> postHits = <Post>[...exact, ...others];
    final int total = bookHits.length + postHits.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: TextField(
          controller: ctl,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 17),
          cursorColor: Colors.white,
          onChanged: (String v) => setState(() => query = v),
          decoration: const InputDecoration(
            hintText: 'کتاب، حدیث نمبر یا کوئی لفظ لکھیں',
            hintStyle: TextStyle(color: Color(0xFFB7D9CE)),
            border: InputBorder.none,
          ),
        ),
        actions: <Widget>[
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ctl.clear();
                setState(() => query = '');
              },
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          ChipsRow(
            items: const <MapEntry<String, String>>[
              MapEntry<String, String>('all', 'سب'),
              MapEntry<String, String>('books', 'کتابیں'),
              MapEntry<String, String>('hadith', 'حدیث (نمبر یا متن)'),
              MapEntry<String, String>('posts', 'تمام تحریریں'),
            ],
            selected: mode,
            onSelected: (String m) => setState(() => mode = m),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: tokens.isEmpty
                ? const EmptyState(
                    Icons.search,
                    'کتاب کا نام، مصنف، یا کوئی لفظ لکھیں۔\n'
                    'حدیث نمبر لکھنا ہو تو صرف عدد لکھیں، مثلاً 1234۔ (نمبر کے ساتھ ماخذ بھی نظر آئے گا)',
                  )
                : total == 0
                    ? const EmptyState(Icons.search_off, 'کوئی نتیجہ نہیں ملا۔')
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 24),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                            child: Text('$total نتائج', style: const TextStyle(color: Colors.black54)),
                          ),
                          if (bookHits.isNotEmpty) ...<Widget>[
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: SectionTitle('کتابیں'),
                            ),
                            ...bookHits.map((Book b) => bookTile(context, b)),
                          ],
                          if (postHits.isNotEmpty) ...<Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: SectionTitle(exact.isNotEmpty ? 'حدیث / تحریریں (نمبر کے مطابق پہلے)' : 'حدیث / تحریریں'),
                            ),
                            ...postHits.map((Post p) => postTile(context, p)),
                          ],
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
