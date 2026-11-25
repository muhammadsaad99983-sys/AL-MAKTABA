import 'package:flutter/material.dart' hide Text;
import 'i18n.dart';
import 'settings.dart';
import 'ads.dart';
import 'common.dart';
import 'kaaba.dart';
import 'ui_tracker.dart';
import 'models.dart';
import 'nav.dart';
import 'state.dart';
import 'ui_ask.dart';
import 'ui_books.dart';
import 'ui_duas.dart';
import 'ui_feedback.dart';
import 'ui_hadith.dart';
import 'ui_ibadat.dart';
import 'ui_names.dart';
import 'ui_prayer.dart';
import 'ui_qibla.dart';
import 'ui_sebha.dart';
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
  int tab = 2;
  final Set<int> opened = <int>{2};

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

  void _go(int i) {
    setState(() {
      tab = i;
      opened.add(i);
    });
  }

  Widget _page(int i) {
    if (!opened.contains(i)) return const SizedBox.shrink();
    switch (i) {
      case 0:
        return const BooksTab();
      case 1:
        return const HadithTab();
      case 2:
        return HomeTab(onGoTo: _go);
      case 3:
        return const IbadatTab();
      default:
        return const MoreTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: tab,
        children: <Widget>[for (int i = 0; i < 5; i++) _page(i)],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const AdBanner(),
          NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: _go,
            destinations: <NavigationDestination>[
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book),
                label: tr('کتابیں'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.format_quote_outlined),
                selectedIcon: const Icon(Icons.format_quote),
                label: tr('حدیث'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: tr('مرکزی'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.mosque_outlined),
                selectedIcon: const Icon(Icons.mosque),
                label: tr('عبادات'),
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
      animation: lib,
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
          _Tile(Icons.local_library, 'اسلامی کتب خانہ', () => onGoTo(0)),
          _Tile(Icons.format_quote, 'کتبِ احادیث', () => onGoTo(1)),
          _Tile(Icons.volunteer_activism, 'دعائیں', () => _push(context, const DuasScreen())),
          _Tile(Icons.explore, 'قبلہ نما', () => _push(context, const QiblaScreen())),
          _Tile(Icons.auto_awesome, 'اسمائے حسنیٰ', () => _push(context, const NamesScreen())),
          _Tile(Icons.calendar_month, 'اسلامی کیلنڈر', () => _push(context, const CalendarScreen())),
          _Tile(Icons.gavel, 'فتاویٰ', () => _push(context, const KindScreen(kind: 'masla', title: 'فتاویٰ'))),
          _Tile(Icons.article, 'اسلامی مضامین', () => _push(context, const PostsTab())),
          _Tile(Icons.history_edu, 'اسلامی تاریخ', () {
            final LibCategory? c = lib.findCategory('tarikh');
            if (c != null) {
              openCategory(context, c);
            } else {
              onGoTo(0);
            }
          }),
        ];
        const Set<String> soonLabels = <String>{};
        final List<_Tile> mine = <_Tile>[
          _Tile(Icons.favorite, 'پسندیدہ', () => _push(context, const ListsScreen(recent: false))),
          _Tile(Icons.history, 'حالیہ مطالعہ', () => _push(context, const ListsScreen(recent: true))),
          _Tile(Icons.download_done, 'ڈاؤنلوڈ شدہ کتابیں', () => _push(context, const DownloadsScreen())),
          _Tile(Icons.notifications, 'اعلانات', () => _push(context, const NewsScreen()), badge: unread),
          _Tile(Icons.question_answer, 'سوال پوچھیں', () => _push(context, const AskScreen())),
          _Tile(Icons.feedback, 'شکایت / تجویز', () => _push(context, const FeedbackScreen())),
          _Tile(Icons.settings, 'سیٹنگز', () => _push(context, const SettingsScreen())),
        ];
        final double w = MediaQuery.of(context).size.width;
        final int cols = w > 700 ? 5 : (w > 480 ? 4 : 3);

        Widget grid(List<_Tile> tiles, {int offset = 0}) => GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.92,
              children: <Widget>[
                for (int i = 0; i < tiles.length; i++)
                  _HomeTile(tile: tiles[i], soon: soonLabels.contains(tiles[i].label), index: offset + i),
              ],
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
                    const SizedBox(height: 10),
                    _LearnGrid(
                      items: <_Tile>[
                        _Tile(Icons.wb_sunny_outlined, 'صبح', () => _push(context, const DuaCategoryScreen(cat: 'morning'))),
                        _Tile(Icons.wb_twilight, 'شام', () => _push(context, const DuaCategoryScreen(cat: 'evening'))),
                        _Tile(Icons.mosque_outlined, 'نماز', () => _push(context, const DuaCategoryScreen(cat: 'prayer'))),
                        _Tile(Icons.blur_circular, 'تسبیح', () => _push(context, const SebhaScreen())),
                        _Tile(Icons.bedtime_outlined, 'نیند', () => _push(context, const DuaCategoryScreen(cat: 'sleep'))),
                        _Tile(Icons.alarm, 'بیداری', () => openWaking(context)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const PrayerCard(),
                    const SizedBox(height: 10),
                    const PrayerProgressChip(),
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
                    grid(mine, offset: 9),
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
                      SectionTitle('نئی کتابیں', onMore: () => onGoTo(0)),
                      ...newBooks.map((Book b) => bookTile(context, b)),
                    ],
                    if (newPosts.isNotEmpty) ...<Widget>[
                      SectionTitle('نئی تحریریں', onMore: () => _push(context, const PostsTab())),
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

/// Colourful picture for each tile (standard emoji, drawn by the phone).
const Map<String, String> _kEmoji = <String, String>{
  'اسلامی کتب خانہ': '\u{1F4DA}',
  'کتبِ احادیث': '\u{1F4D6}',
  'دعائیں': '\u{1F64F}',
  'قبلہ نما': '\u{1F9ED}',
  'اسمائے حسنیٰ': '\u2728',
  'اسلامی کیلنڈر': '\u{1F4C5}',
  'فتاویٰ': '\u2696\uFE0F',
  'اسلامی مضامین': '\u{1F4DD}',
  'اسلامی تاریخ': '\u{1F4DC}',
  'پسندیدہ': '\u2764\uFE0F',
  'حالیہ مطالعہ': '\u{1F558}',
  'ڈاؤنلوڈ شدہ کتابیں': '\u{1F4E5}',
  'اعلانات': '\u{1F4E2}',
  'سوال پوچھیں': '\u2753',
  'شکایت / تجویز': '\u{1F4AC}',
  'سیٹنگز': '\u2699\uFE0F',
};

/// Every tile gets its own colour: [box, circle, icon].
const List<List<Color>> _kTilePalette = <List<Color>>[
  <Color>[Color(0xFFFFEB8A), Color(0xFFFFC933), Color(0xFF5A3B00)],
  <Color>[Color(0xFFFFD1DC), Color(0xFFF06292), Color(0xFF5C0A2A)],
  <Color>[Color(0xFFBBDEFB), Color(0xFF42A5F5), Color(0xFF0D2F57)],
  <Color>[Color(0xFFC8F0D4), Color(0xFF3DBE72), Color(0xFF0A3D1F)],
  <Color>[Color(0xFFFFD9B0), Color(0xFFFF9333), Color(0xFF5A2A00)],
  <Color>[Color(0xFFE1D4FF), Color(0xFF9575CD), Color(0xFF2B1458)],
  <Color>[Color(0xFFB8F0EA), Color(0xFF26B5A8), Color(0xFF04403B)],
  <Color>[Color(0xFFFFC9C9), Color(0xFFEF5350), Color(0xFF5C0A0A)],
  <Color>[Color(0xFFE6F5A8), Color(0xFF9CCC30), Color(0xFF2F4200)],
  <Color>[Color(0xFFEBD3BE), Color(0xFFA67C52), Color(0xFF3A2410)],
  <Color>[Color(0xFFCFE0FF), Color(0xFF5C7CFA), Color(0xFF14226B)],
  <Color>[Color(0xFFF8C8F0), Color(0xFFD45CC9), Color(0xFF4D0A48)],
];

class _HomeTile extends StatelessWidget {
  final _Tile tile;
  final bool soon;
  final int index;
  const _HomeTile({required this.tile, required this.soon, required this.index});

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final List<Color> pal = _kTilePalette[index % _kTilePalette.length];
    final Color boxColor = dark ? Color.lerp(pal[1], Colors.black, 0.68)! : pal[0];
    final Color circleColor = pal[1];
    final Color iconColor = dark ? Colors.white : pal[2];
    return Material(
      color: boxColor,
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
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: _kEmoji.containsKey(tile.label) ? Colors.white.withAlpha(dark ? 235 : 215) : circleColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: circleColor, width: 2),
                      ),
                      child: _kEmoji.containsKey(tile.label)
                          ? Center(child: Text(_kEmoji[tile.label]!, style: const TextStyle(fontSize: 28, height: 1.2)))
                          : Icon(tile.icon, color: iconColor, size: 26),
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
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 104),
      clipBehavior: Clip.antiAlias,
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
      child: Stack(
        children: <Widget>[
          const Positioned(left: 0, right: 0, bottom: 0, height: 96, child: KaabaScene(opacity: 1.0)),
          Column(
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
                'اسلام 960',
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


class _LearnGrid extends StatelessWidget {
  final List<_Tile> items;
  const _LearnGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF0F4F55), borderRadius: BorderRadius.circular(18)),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.6,
        children: items
            .map((_Tile t) => Material(
                  color: const Color(0xFF16808A),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: t.onTap,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(t.icon, color: const Color(0xFFFFE08A), size: 26),
                        const SizedBox(height: 3),
                        Text(t.label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
