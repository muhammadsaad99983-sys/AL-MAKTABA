import 'package:flutter/material.dart';
import 'common.dart';
import 'models.dart';
import 'nav.dart';
import 'state.dart';
import 'ui_books.dart';
import 'ads.dart';
import 'ui_more.dart';
import 'ui_search.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: tab,
        children: <Widget>[
          HomeTab(onGoTo: (int i) => setState(() => tab = i)),
          const BooksTab(),
          const PostsTab(),
          const MoreTab(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const AdBanner(),
          NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (int i) => setState(() => tab = i),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'مرکزی',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'کتابیں',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'تحریریں',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu),
            selectedIcon: Icon(Icons.menu_open),
            label: 'مزید',
          ),
        ],
      ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  final ValueChanged<int> onGoTo;
  const HomeTab({super.key, required this.onGoTo});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lib,
      builder: (BuildContext context, Widget? _) {
        final List<Book> newBooks = lib.books.take(5).toList();
        final List<Post> newPosts = lib.posts.take(5).toList();
        final bool nothing = lib.categories.isEmpty && lib.books.isEmpty && lib.posts.isEmpty;

        return RefreshIndicator(
          onRefresh: lib.refresh,
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              _Header(),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (lib.offline && lib.error != null)
                      NoticeBanner(
                        '${lib.error}\nپہلے سے محفوظ شدہ مواد دکھایا جا رہا ہے۔',
                        onRetry: lib.refresh,
                      ),
                    if (nothing && lib.loading)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (nothing && !lib.loading && !lib.offline)
                      const EmptyState(Icons.menu_book_outlined, 'ابھی کوئی کتاب یا تحریر شامل نہیں کی گئی۔'),
                    if (lib.categories.isNotEmpty) ...<Widget>[
                      const SectionTitle('زمرے'),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.3,
                        children: lib.categories
                            .map((LibCategory c) => _CategoryCard(category: c))
                            .toList(),
                      ),
                    ],
                    if (newBooks.isNotEmpty) ...<Widget>[
                      SectionTitle('نئی کتابیں', onMore: () => onGoTo(1)),
                      ...newBooks.map((Book b) => bookTile(context, b)),
                    ],
                    if (newPosts.isNotEmpty) ...<Widget>[
                      SectionTitle('نئی تحریریں', onMore: () => onGoTo(2)),
                      ...newPosts.map((Post p) => postTile(context, p)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 22, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF117A63), Color(0xFF073B30)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.wb_sunny, color: kGold, size: 34),
              const SizedBox(width: 10),
              const Text(
                'المکتبۃ الآفتابیہ',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.6),
              ),
            ],
          ),
          const Text(
            'اسلامی کتابوں اور مضامین کا مجموعہ',
            style: TextStyle(color: Color(0xFFD7EBE4), fontSize: 14),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (BuildContext _) => const SearchScreen()),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.search, color: kGreen),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'کتاب، حدیث نمبر یا مضمون تلاش کریں',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final LibCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final int books = lib.booksIn(category.id).length;
    final int posts = lib.postsIn(category.id).length;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => openCategory(context, category),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: kLight, shape: BoxShape.circle),
                child: Icon(categoryIcon(category.id), color: kGreen, size: 22),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '$books کتابیں  •  $posts تحریریں',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
