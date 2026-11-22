import 'package:flutter/material.dart' hide Text;
import 'i18n.dart';
import 'settings.dart';
import 'ads.dart';
import 'common.dart';
import 'models.dart';
import 'nav.dart';
import 'state.dart';
import 'ui_books.dart';
import 'ui_duas.dart';
import 'ui_feedback.dart';
import 'ui_import.dart';
import 'ui_lists.dart';
import 'ui_more.dart';
import 'ui_search.dart';
import 'ui_settings.dart';
import 'ui_tasbeeh.dart';
import 'userdata.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) handleShared(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) handleShared(context);
  }

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
            destinations: <NavigationDestination>[
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: tr('مرکزی'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book),
                label: tr('کتابیں'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.article_outlined),
                selectedIcon: const Icon(Icons.article),
                label: tr('تحریریں'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu),
                selectedIcon: const Icon(Icons.menu_open),
                label: tr('مزید'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tile {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final int badge;
  const _Tile(this.icon, this.label, this.onTap, {this.badge = 0});
}

class HomeTab extends StatelessWidget {
  final ValueChanged<int> onGoTo;
  const HomeTab({super.key, required this.onGoTo});

  void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext _) => page));
  }

  void _soon(BuildContext context) => snack(context, 'یہ سہولت جلد آ رہی ہے، ان شاء اللہ');

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[lib, ud]),
      builder: (BuildContext context, Widget? _) {
        final List<Book> newBooks = lib.books.take(5).toList();
        final List<Post> newPosts = lib.posts.take(5).toList();
        final bool nothing = lib.categories.isEmpty && lib.books.isEmpty && lib.posts.isEmpty;
        final int unread = lib.news.where((News n) => !ud.seenNews.contains(n.id)).length;

        Book? resume;
        for (final String id in ud.recentBooks) {
          resume = lib.findBook(id);
          if (resume != null) break;
        }

        final List<_Tile> main = <_Tile>[
          _Tile(Icons.auto_stories, 'قرآن مجید', () => _soon(context)),
          _Tile(Icons.local_library, 'اسلامی کتب خانہ', () => onGoTo(1)),
          _Tile(Icons.format_quote, 'احادیث نبویہ ﷺ',
              () => _push(context, const KindScreen(kind: 'hadith', title: 'احادیث نبویہ ﷺ'))),
          _Tile(Icons.blur_circular, 'اذکار و تسبیحات', () => _push(context, const TasbeehListScreen())),
          _Tile(Icons.volunteer_activism, 'دعائیں', () => _push(context, const DuasScreen())),
          _Tile(Icons.access_time, 'نماز کے اوقات', () => _soon(context)),
          _Tile(Icons.explore, 'قبلہ نما', () => _soon(context)),
          _Tile(Icons.calendar_month, 'اسلامی کیلنڈر', () => _soon(context)),
          _Tile(Icons.article, 'اسلامی مضامین', () => onGoTo(2)),
          _Tile(Icons.gavel, 'فتاویٰ', () => _push(context, const KindScreen(kind: 'masla', title: 'فتاویٰ'))),
          _Tile(Icons.history_edu, 'اسلامی تاریخ', () {
            final LibCategory? c = lib.findCategory('tarikh');
            if (c != null) {
              openCategory(context, c);
            } else {
              onGoTo(1);
            }
          }),
          _Tile(Icons.translate, 'عربی زبان سیکھیں', () => _soon(context)),
        ];
        const Set<String> soonLabels = <String>{
          'قرآن مجید',
          'نماز کے اوقات',
          'قبلہ نما',
          'اسلامی کیلنڈر',
          'عربی زبان سیکھیں',
        };
        final List<_Tile> mine = <_Tile>[
          _Tile(Icons.favorite, 'پسندیدہ', () => _push(context, const ListsScreen(recent: false))),
          _Tile(Icons.history, 'حالیہ مطالعہ', () => _push(context, const ListsScreen(recent: true))),
          _Tile(Icons.download_done, 'ڈاؤنلوڈ شدہ کتابیں', () => _push(context, const DownloadsScreen())),
          _Tile(Icons.notifications, 'اعلانات', () => _push(context, const NewsScreen()), badge: unread),
          _Tile(Icons.feedback, 'شکایت / تجویز', () => _push(context, const FeedbackScreen())),
          _Tile(Icons.settings, 'سیٹنگز', () => _push(context, const SettingsScreen())),
        ];
        final double w = MediaQuery.of(context).size.width;
        final int cols = w > 700 ? 5 : (w > 480 ? 4 : 3);

        Widget grid(List<_Tile> tiles) => GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.92,
              children: tiles
                  .map((_Tile t) => _HomeTile(tile: t, soon: soonLabels.contains(t.label)))
                  .toList(),
            );

        return RefreshIndicator(
          onRefresh: lib.refresh,
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              _Header(unread: unread),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (lib.offline && lib.error != null)
                      NoticeBanner(
                        '${tr(lib.error ?? '')}\n${tr('پہلے سے محفوظ شدہ مواد دکھایا جا رہا ہے۔')}',
                        onRetry: lib.refresh,
                      ),
                    if (resume != null)
                      Builder(builder: (BuildContext context) {
                        final Book rb = resume!;
                        return Card(
                          color: kLight,
                          margin: const EdgeInsets.only(top: 6, bottom: 4),
                          child: ListTile(
                            leading: Icon(Icons.auto_stories, color: kGreen),
                            title: Text(rb.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(tf('مطالعہ جاری رکھیں — صفحہ %s', <Object>[lib.lastPage(rb.id) + 1])),
                            trailing: Icon(kChevron),
                            onTap: () => openBook(context, rb),
                          ),
                        );
                      }),
                    const SectionTitle('اسلامی خزانہ'),
                    grid(main),
                    const SectionTitle('میرا مکتبہ'),
                    grid(mine),
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
                        crossAxisCount: w > 700 ? 3 : 2,
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

class _HomeTile extends StatelessWidget {
  final _Tile tile;
  final bool soon;
  const _HomeTile({required this.tile, required this.soon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCardBg,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.6,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: tile.onTap,
        child: Opacity(
          opacity: soon ? 0.55 : 1,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: kLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: kGold.withAlpha(120)),
                      ),
                      child: Icon(tile.icon, color: kGreen, size: 26),
                    ),
                    if (tile.badge > 0)
                      PositionedDirectional(
                        top: -4,
                        end: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(10)),
                          child: Text('${tile.badge}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  tile.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.4),
                ),
                if (soon)
                  Text('جلد', style: TextStyle(fontSize: 10, color: kGold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int unread;
  const _Header({required this.unread});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 22),
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
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (BuildContext _) => const SettingsScreen()),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.notifications_none, color: Colors.white),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (BuildContext _) => const NewsScreen()),
                ),
              ),
            ],
          ),
          const Text(
            'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ',
            style: TextStyle(color: Color(0xFFE8D39A), fontSize: 18, height: 1.8),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.wb_sunny, color: kGold, size: 32),
              const SizedBox(width: 10),
              const Text(
                'المکتبۃ الآفتابیہ',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.6),
              ),
            ],
          ),
          const Text(
            'اسلامی کتابوں اور مضامین کا مجموعہ',
            style: TextStyle(color: Color(0xFFD7EBE4), fontSize: 14),
          ),
          const SizedBox(height: 14),
          Material(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (BuildContext _) => const SearchScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.search, color: kGreen),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'کتاب، حدیث نمبر یا مضمون تلاش کریں',
                        style: TextStyle(color: kMuted),
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
      color: kCardBg,
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
                decoration: BoxDecoration(color: kLight, shape: BoxShape.circle),
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
                      tf('%s کتابیں  •  %s تحریریں', <Object>[books, posts]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: kMuted, fontSize: 11),
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
