import 'package:flutter/material.dart' hide Text;
import 'i18n.dart';
import 'settings.dart';
import 'api.dart';
import 'common.dart';
import 'models.dart';
import 'nav.dart';
import 'state.dart';
import 'ui_admin.dart';

class CategoryScreen extends StatelessWidget {
  final String categoryId;
  const CategoryScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lib,
      builder: (BuildContext context, Widget? _) {
        final LibCategory? cat = lib.findCategory(categoryId);
        if (cat == null) {
          return Scaffold(appBar: appBar('زمرہ'), body: const EmptyState(Icons.folder_off, 'یہ زمرہ موجود نہیں'));
        }
        final List<Book> books = lib.booksIn(categoryId);
        final List<Post> posts = lib.postsIn(categoryId);

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: appBar(
              cat.name,
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
            floatingActionButton: Api.isAdmin
                ? FloatingActionButton.extended(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (BuildContext _) => BookForm(initialCategory: categoryId)),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('کتاب شامل کریں'),
                  )
                : null,
            body: TabBarView(
              children: <Widget>[
                RefreshIndicator(
                  onRefresh: lib.refresh,
                  child: books.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const <Widget>[
                            SizedBox(height: 60),
                            EmptyState(Icons.menu_book_outlined, 'اس زمرے میں ابھی کوئی کتاب نہیں۔'),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 90),
                          itemCount: books.length,
                          itemBuilder: (BuildContext context, int i) => bookTile(context, books[i]),
                        ),
                ),
                RefreshIndicator(
                  onRefresh: lib.refresh,
                  child: posts.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const <Widget>[
                            SizedBox(height: 60),
                            EmptyState(Icons.article_outlined, 'اس زمرے میں ابھی کوئی تحریر نہیں۔'),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 90),
                          itemCount: posts.length,
                          itemBuilder: (BuildContext context, int i) => postTile(context, posts[i]),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
