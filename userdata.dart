import 'dart:async';
import 'package:flutter/foundation.dart';
import 'local.dart';

class TasbeehItem {
  final String id;
  final String name;
  final String arabic;
  final int target;
  final bool custom;
  const TasbeehItem(this.id, this.name, this.arabic, this.target, {this.custom = false});

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'id': id, 'name': name, 'arabic': arabic, 'target': target};
}

const List<TasbeehItem> kTasbeehPresets = <TasbeehItem>[
  TasbeehItem('p_subhan', 'سبحان اللہ', 'سُبْحَانَ اللّٰهِ', 33),
  TasbeehItem('p_hamd', 'الحمد للہ', 'اَلْحَمْدُ لِلّٰهِ', 33),
  TasbeehItem('p_akbar', 'اللہ اکبر', 'اَللّٰهُ أَكْبَرُ', 34),
  TasbeehItem('p_tawheed', 'کلمہ طیبہ', 'لَا إِلٰهَ إِلَّا اللّٰهُ', 100),
  TasbeehItem('p_istighfar', 'استغفار', 'أَسْتَغْفِرُ اللّٰهَ', 100),
  TasbeehItem('p_durood', 'درود شریف', 'اَللّٰهُمَّ صَلِّ عَلٰى مُحَمَّدٍ', 100),
  TasbeehItem('p_hawqala', 'لا حول ولا قوۃ', 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ', 100),
  TasbeehItem('p_morning', 'سبحان اللہ وبحمدہ', 'سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ', 100),
  TasbeehItem('p_azim', 'سبحان اللہ العظیم', 'سُبْحَانَ اللّٰهِ الْعَظِيمِ', 100),
  TasbeehItem('p_hasbi', 'حسبنا اللہ', 'حَسْبُنَا اللّٰهُ وَنِعْمَ الْوَكِيلُ', 100),
  TasbeehItem('p_rabbi', 'رب اغفر لی', 'رَبِّ اغْفِرْ لِي', 100),
  TasbeehItem('p_yahayy', 'یا حی یا قیوم', 'يَا حَيُّ يَا قَيُّومُ', 100),
  TasbeehItem('p_tasbih4', 'چوتھا کلمہ', 'سُبْحَانَ اللّٰهِ وَالْحَمْدُ لِلّٰهِ وَلَا إِلٰهَ إِلَّا اللّٰهُ وَاللّٰهُ أَكْبَرُ', 100),
];

String dayKey(DateTime d) => '${d.year}-${d.month < 10 ? '0' : ''}${d.month}-${d.day < 10 ? '0' : ''}${d.day}';

/// Everything that belongs to this phone only: favourites, recent reading,
/// tasbeeh counters, read announcements.
class UserData extends ChangeNotifier {
  final List<String> favBooks = <String>[];
  final List<String> favPosts = <String>[];
  final List<String> recentBooks = <String>[];
  final List<String> recentPosts = <String>[];
  final Map<String, int> counts = <String, int>{};
  final Map<String, Map<String, int>> daily = <String, Map<String, int>>{};
  final List<TasbeehItem> custom = <TasbeehItem>[];
  final Set<String> seenNews = <String>{};
  final Map<String, int> sebhaTargets = <String, int>{};
  bool sebhaSeq = false;
  String sebhaLast = '';
  Timer? _timer;

  List<TasbeehItem> get allTasbeeh => <TasbeehItem>[...kTasbeehPresets, ...custom];

  TasbeehItem? tasbeehById(String id) {
    for (final TasbeehItem t in allTasbeeh) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<String> _strs(dynamic v) =>
      v is List ? v.map((dynamic e) => e.toString()).toList() : <String>[];

  Future<void> load() async {
    final dynamic j = await Local.readJson('userdata.json');
    if (j is! Map) return;
    favBooks.addAll(_strs(j['favBooks']));
    favPosts.addAll(_strs(j['favPosts']));
    recentBooks.addAll(_strs(j['recentBooks']));
    recentPosts.addAll(_strs(j['recentPosts']));
    seenNews.addAll(_strs(j['seenNews']));
    sebhaSeq = j['sebhaSeq'] == true;
    sebhaLast = (j['sebhaLast'] ?? '').toString();
    final dynamic st = j['sebhaTargets'];
    if (st is Map) {
      st.forEach((dynamic k, dynamic v) {
        if (v is num && v > 0) sebhaTargets[k.toString()] = v.toInt();
      });
    }
    final dynamic c = j['counts'];
    if (c is Map) {
      c.forEach((dynamic k, dynamic v) {
        if (v is num) counts[k.toString()] = v.toInt();
      });
    }
    final dynamic d = j['daily'];
    if (d is Map) {
      d.forEach((dynamic k, dynamic v) {
        if (v is Map) {
          final Map<String, int> m = <String, int>{};
          v.forEach((dynamic a, dynamic b) {
            if (b is num) m[a.toString()] = b.toInt();
          });
          daily[k.toString()] = m;
        }
      });
    }
    final dynamic cu = j['custom'];
    if (cu is List) {
      for (final dynamic e in cu) {
        if (e is Map) {
          custom.add(TasbeehItem(
            (e['id'] ?? '').toString(),
            (e['name'] ?? '').toString(),
            (e['arabic'] ?? '').toString(),
            e['target'] is num ? (e['target'] as num).toInt() : 33,
            custom: true,
          ));
        }
      }
    }
  }

  void _save({bool now = false}) {
    notifyListeners();
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: now ? 10 : 700), () {
      Local.writeJson('userdata.json', <String, dynamic>{
        'favBooks': favBooks,
        'favPosts': favPosts,
        'recentBooks': recentBooks,
        'recentPosts': recentPosts,
        'seenNews': seenNews.toList(),
        'sebhaTargets': sebhaTargets,
        'sebhaSeq': sebhaSeq,
        'sebhaLast': sebhaLast,
        'counts': counts,
        'daily': daily,
        'custom': custom.map((TasbeehItem t) => t.toJson()).toList(),
      });
    });
  }

  // ---- favourites
  bool isFavBook(String id) => favBooks.contains(id);
  bool isFavPost(String id) => favPosts.contains(id);

  void toggleFavBook(String id) {
    if (!favBooks.remove(id)) favBooks.insert(0, id);
    _save(now: true);
  }

  void toggleFavPost(String id) {
    if (!favPosts.remove(id)) favPosts.insert(0, id);
    _save(now: true);
  }

  // ---- recents
  void _touch(List<String> list, String id) {
    list.remove(id);
    list.insert(0, id);
    while (list.length > 30) {
      list.removeLast();
    }
  }

  void touchBook(String id) {
    _touch(recentBooks, id);
    _save();
  }

  void touchPost(String id) {
    _touch(recentPosts, id);
    _save();
  }

  void clearRecents() {
    recentBooks.clear();
    recentPosts.clear();
    _save(now: true);
  }

  // ---- announcements
  void markSeen(Iterable<String> ids) {
    final int before = seenNews.length;
    seenNews.addAll(ids);
    if (seenNews.length != before) _save();
  }

  // ---- sebha (bead counter) settings
  int targetOf(TasbeehItem t) => sebhaTargets[t.id] ?? t.target;

  void setTarget(String id, int v) {
    sebhaTargets[id] = v;
    _save(now: true);
  }

  void setSeq(bool v) {
    sebhaSeq = v;
    _save(now: true);
  }

  void setLast(String id) {
    if (sebhaLast == id) return;
    sebhaLast = id;
    _save();
  }

  // ---- tasbeeh
  int countOf(String id) => counts[id] ?? 0;

  int todayTotal() {
    final Map<String, int>? m = daily[dayKey(DateTime.now())];
    if (m == null) return 0;
    int s = 0;
    for (final int v in m.values) {
      s += v;
    }
    return s;
  }

  int todayOf(String id) => daily[dayKey(DateTime.now())]?[id] ?? 0;

  void tap(String id) {
    counts[id] = countOf(id) + 1;
    final Map<String, int> m = daily.putIfAbsent(dayKey(DateTime.now()), () => <String, int>{});
    m[id] = (m[id] ?? 0) + 1;
    _save();
  }

  void undo(String id) {
    final int c = countOf(id);
    if (c <= 0) return;
    counts[id] = c - 1;
    final Map<String, int>? m = daily[dayKey(DateTime.now())];
    if (m != null && (m[id] ?? 0) > 0) m[id] = m[id]! - 1;
    _save();
  }

  void resetCount(String id) {
    counts[id] = 0;
    _save(now: true);
  }

  void addCustom(String name, int target) {
    custom.add(TasbeehItem('c${DateTime.now().millisecondsSinceEpoch}', name, '', target, custom: true));
    _save(now: true);
  }

  void removeCustom(String id) {
    custom.removeWhere((TasbeehItem t) => t.id == id);
    counts.remove(id);
    _save(now: true);
  }

  void clearDaily() {
    daily.clear();
    _save(now: true);
  }
}

final UserData ud = UserData();
