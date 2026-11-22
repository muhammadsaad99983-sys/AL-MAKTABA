import 'package:flutter/material.dart' hide Text;
import 'common.dart';
import 'i18n.dart';
import 'models.dart';
import 'nav.dart';
import 'settings.dart';
import 'state.dart';
import 'userdata.dart';

/// Favourites (recent = false) or recently opened items (recent = true).
class ListsScreen extends StatelessWidget {
  final bool recent;
  const ListsScreen({super.key, required this.recent});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[lib, ud]),
      builder: (BuildContext context, Widget? _) {
        final List<Book> books = <Book>[];
        for (final String id in recent ? ud.recentBooks : ud.favBooks) {
          final Book? b = lib.findBook(id);
          if (b != null) books.add(b);
        }
        final List<Post> posts = <Post>[];
        for (final String id in recent ? ud.recentPosts : ud.favPosts) {
          final Post? p = lib.findPost(id);
          if (p != null) posts.add(p);
        }
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: appBar(
              recent ? 'حالیہ مطالعہ' : 'پسندیدہ',
              actions: <Widget>[
                if (recent && (books.isNotEmpty || posts.isNotEmpty))
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    onPressed: () async {
                      final bool ok = await confirmDialog(context, 'فہرست صاف کریں', 'حالیہ مطالعے کی فہرست صاف کر دی جائے؟');
                      if (ok) ud.clearRecents();
                    },
                  ),
              ],
              bottom: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFFB7D9CE),
                indicatorColor: kGold,
                tabs: <Widget>[
                  Tab(text: tf('کتابیں (%s)', <Object>[books.length])),
                  Tab(text: tf('تحریریں (%s)', <Object>[posts.length])),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                books.isEmpty
                    ? EmptyState(Icons.menu_book_outlined, recent ? 'ابھی کوئی کتاب نہیں کھولی۔' : 'ابھی کوئی پسندیدہ کتاب نہیں۔\nکتاب کے صفحے پر دل کا نشان دبائیں۔')
                    : ListView(padding: const EdgeInsets.only(top: 8, bottom: 20), children: books.map((Book b) => bookTile(context, b)).toList()),
                posts.isEmpty
                    ? EmptyState(Icons.article_outlined, recent ? 'ابھی کوئی تحریر نہیں کھولی۔' : 'ابھی کوئی پسندیدہ تحریر نہیں۔\nتحریر کے صفحے پر دل کا نشان دبائیں۔')
                    : ListView(padding: const EdgeInsets.only(top: 8, bottom: 20), children: posts.map((Post p) => postTile(context, p)).toList()),
              ],
            ),
          ),
        );
      },
    );
  }
}
