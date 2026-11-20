import 'package:flutter/material.dart';
import 'api.dart';
import 'common.dart';
import 'models.dart';
import 'nav.dart';
import 'search_util.dart';
import 'state.dart';
import 'ui_admin.dart';

// =====================================================================
//  All books
// =====================================================================

class BooksTab extends StatefulWidget {
  const BooksTab({super.key});

  @override
  State<BooksTab> createState() => _BooksTabState();
}

class _BooksTabState extends State<BooksTab> {
  String lang = 'ur';
  String catId = '';
  String query = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lib,
      builder: (BuildContext context, Widget? _) {
        final List<String> tokens = tokensOf(query);
        final List<Book> list = lib.books.where((Book b) {
          if (b.language != lang) return false;
          if (catId.isNotEmpty && b.categoryId != catId) return false;
          if (tokens.isEmpty) return true;
          return containsAll(normalizeText('${b.title} ${b.author} ${b.description}'), tokens);
        }).toList();

        final List<MapEntry<String, String>> langItems = kLanguages.entries
            .map((MapEntry<String, String> e) => MapEntry<String, String>(
                  e.key,
                  '${e.value} (${lib.books.where((Book b) => b.language == e.key).length})',
                ))
            .toList();

        final List<MapEntry<String, String>> filters = <MapEntry<String, String>>[
          const MapEntry<String, String>('', 'سب'),
          ...lib.categories.map((LibCategory c) => MapEntry<String, String>(c.id, c.name)),
        ];

        return Scaffold(
          appBar: appBar('${languageLabel(lang)} کتابیں (${list.length})'),
          floatingActionButton: Api.isAdmin
              ? FloatingActionButton.extended(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (BuildContext _) => BookForm(initialCategory: catId, initialLanguage: lang)),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('کتاب شامل کریں'),
                )
              : null,
          body: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              ChipsRow(items: langItems, selected: lang, onSelected: (String l) => setState(() => lang = l)),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: TextField(
                  onChanged: (String v) => setState(() => query = v),
                  decoration: InputDecoration(
                    hintText: 'کتابوں میں تلاش کریں',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              ChipsRow(items: filters, selected: catId, onSelected: (String id) => setState(() => catId = id)),
              const SizedBox(height: 6),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: lib.refresh,
                  child: list.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: <Widget>[
                            const SizedBox(height: 60),
                            EmptyState(
                              Icons.menu_book_outlined,
                              lib.books.isEmpty ? 'ابھی کوئی کتاب شامل نہیں کی گئی۔' : 'اس زبان میں ابھی کوئی کتاب نہیں۔',
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 90),
                          itemCount: list.length,
                          itemBuilder: (BuildContext context, int i) => bookTile(context, list[i]),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =====================================================================
//  All articles / hadith / duas
// =====================================================================

class PostsTab extends StatefulWidget {
  const PostsTab({super.key});

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  String kind = '';
  String query = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lib,
      builder: (BuildContext context, Widget? _) {
        final List<String> tokens = tokensOf(query);
        final List<Post> list = lib.posts.where((Post p) {
          if (kind.isNotEmpty && p.kind != kind) return false;
          if (tokens.isEmpty) return true;
          return containsAll(normalizeText('${p.title} ${p.arabic} ${p.body} ${p.source} ${p.number}'), tokens);
        }).toList();

        final List<MapEntry<String, String>> filters = <MapEntry<String, String>>[
          const MapEntry<String, String>('', 'سب'),
          ...kKinds.entries,
        ];

        return Scaffold(
          appBar: appBar('تحریریں (${lib.posts.length})'),
          floatingActionButton: Api.isAdmin
              ? FloatingActionButton.extended(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (BuildContext _) => const PostForm()),
                  ),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('نئی تحریر'),
                )
              : null,
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: TextField(
                  onChanged: (String v) => setState(() => query = v),
                  decoration: InputDecoration(
                    hintText: 'تحریروں میں تلاش کریں',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              ChipsRow(items: filters, selected: kind, onSelected: (String k) => setState(() => kind = k)),
              const SizedBox(height: 6),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: lib.refresh,
                  child: list.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: <Widget>[
                            const SizedBox(height: 60),
                            EmptyState(
                              Icons.article_outlined,
                              lib.posts.isEmpty ? 'ابھی کوئی تحریر شامل نہیں کی گئی۔' : 'کوئی تحریر نہیں ملی۔',
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 90),
                          itemCount: list.length,
                          itemBuilder: (BuildContext context, int i) => postTile(context, list[i]),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
