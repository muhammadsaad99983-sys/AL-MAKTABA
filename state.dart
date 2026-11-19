import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'api.dart';
import 'config.dart';
import 'local.dart';
import 'models.dart';

class DownloadInfo {
  final String id;
  final String title;
  final String author;
  final int size;

  DownloadInfo({required this.id, required this.title, this.author = '', this.size = 0});

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'id': id, 'title': title, 'author': author, 'size': size};

  factory DownloadInfo.fromJson(Map<String, dynamic> j) => DownloadInfo(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        author: (j['author'] ?? '').toString(),
        size: j['size'] is num ? (j['size'] as num).toInt() : 0,
      );
}

List<T> _mapList<T>(dynamic raw, T Function(Map<String, dynamic>) make) {
  final List<T> out = <T>[];
  if (raw is List) {
    for (final dynamic e in raw) {
      if (e is Map) {
        out.add(make(Map<String, dynamic>.from(e)));
      }
    }
  }
  return out;
}

class Lib extends ChangeNotifier {
  List<Category> categories = <Category>[];
  List<Book> books = <Book>[];
  List<Post> posts = <Post>[];

  bool loading = false;
  bool offline = false;
  bool loadedOnce = false;
  String? error;

  final Map<String, DownloadInfo> downloads = <String, DownloadInfo>{};
  final Map<String, int> _lastPage = <String, int>{};
  String _booksDir = '';
  bool _again = false;

  // ---------------------------------------------------------------
  //  start-up
  // ---------------------------------------------------------------

  Future<void> init() async {
    await Api.restore();
    _booksDir = await Local.booksDir();
    categories = _mapList<Category>(await Local.readJson('c_categories.json'), Category.fromJson);
    books = _mapList<Book>(await Local.readJson('c_books.json'), Book.fromJson);
    posts = _mapList<Post>(await Local.readJson('c_posts.json'), Post.fromJson);
    final dynamic d = await Local.readJson('downloads.json');
    for (final DownloadInfo i in _mapList<DownloadInfo>(d, DownloadInfo.fromJson)) {
      downloads[i.id] = i;
    }
    final dynamic lp = await Local.readJson('lastpage.json');
    if (lp is Map) {
      lp.forEach((dynamic k, dynamic v) {
        if (v is num) _lastPage[k.toString()] = v.toInt();
      });
    }
    notifyListeners();
    if (Config.isConfigured) {
      refresh();
      Api.verifySavedLogin().then((_) => notifyListeners());
    }
  }

  // ---------------------------------------------------------------
  //  loading from the server
  // ---------------------------------------------------------------

  Future<void> refresh() async {
    if (!Config.isConfigured) return;
    if (loading) {
      _again = true;
      return;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      final List<List<dynamic>> r = await Future.wait(<Future<List<dynamic>>>[
        Api.getList('categories', order: 'sort.asc'),
        Api.getList('books'),
        Api.getList('posts'),
      ]);
      categories = _mapList<Category>(r[0], Category.fromJson);
      books = _mapList<Book>(r[1], Book.fromJson);
      posts = _mapList<Post>(r[2], Post.fromJson);
      offline = false;
      Local.writeJson('c_categories.json', categories.map((Category c) => c.toJson()).toList());
      Local.writeJson('c_books.json', books.map((Book b) => b.toJson()).toList());
      Local.writeJson('c_posts.json', posts.map((Post p) => p.toJson()).toList());
    } on ApiException catch (e) {
      error = e.message;
      offline = true;
    } catch (_) {
      error = 'ڈیٹا لوڈ نہیں ہو سکا';
      offline = true;
    } finally {
      loading = false;
      loadedOnce = true;
      notifyListeners();
    }
    if (_again) {
      _again = false;
      await refresh();
    }
  }

  // ---------------------------------------------------------------
  //  lookups
  // ---------------------------------------------------------------

  Book? findBook(String id) {
    for (final Book b in books) {
      if (b.id == id) return b;
    }
    return null;
  }

  Post? findPost(String id) {
    for (final Post p in posts) {
      if (p.id == id) return p;
    }
    return null;
  }

  Category? findCategory(String id) {
    for (final Category c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  String categoryName(String id) {
    final Category? c = findCategory(id);
    return c == null ? 'متفرق' : c.name;
  }

  List<Book> booksIn(String categoryId) =>
      books.where((Book b) => b.categoryId == categoryId).toList();

  List<Post> postsIn(String categoryId) =>
      posts.where((Post p) => p.categoryId == categoryId).toList();

  // ---------------------------------------------------------------
  //  admin login
  // ---------------------------------------------------------------

  Future<void> login(String email, String password) async {
    await Api.login(email, password);
    notifyListeners();
  }

  Future<void> logout() async {
    await Api.logout();
    notifyListeners();
  }

  // ---------------------------------------------------------------
  //  admin: books
  // ---------------------------------------------------------------

  Future<void> addBook({
    required String filePath,
    required int size,
    required String title,
    required String author,
    required String description,
    required String categoryId,
    required void Function(int, int) onProgress,
  }) async {
    final String storageName =
        '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(900000) + 100000}.pdf';
    await Api.uploadFile(storageName, File(filePath), onProgress);
    try {
      await Api.insert('books', <String, dynamic>{
        'title': title,
        'author': author,
        'description': description,
        'category_id': categoryId.isEmpty ? null : categoryId,
        'file_path': storageName,
        'file_size': size,
      });
    } catch (_) {
      try {
        await Api.deleteFile(storageName);
      } catch (_) {}
      rethrow;
    }
    await refresh();
  }

  Future<void> updateBook(Book b, String title, String author, String description, String categoryId) async {
    await Api.update('books', b.id, <String, dynamic>{
      'title': title,
      'author': author,
      'description': description,
      'category_id': categoryId.isEmpty ? null : categoryId,
    });
    await refresh();
  }

  Future<void> deleteBook(Book b) async {
    await Api.deleteRow('books', b.id);
    try {
      await Api.deleteFile(b.filePath);
    } catch (_) {}
    await removeDownload(b.id);
    await refresh();
  }

  // ---------------------------------------------------------------
  //  admin: posts
  // ---------------------------------------------------------------

  Map<String, dynamic> _postRow(Map<String, String> f) => <String, dynamic>{
        'kind': f['kind'],
        'title': f['title'],
        'arabic': f['arabic'],
        'body': f['body'],
        'number': f['number'],
        'source': f['source'],
        'category_id': (f['category_id'] ?? '').isEmpty ? null : f['category_id'],
      };

  Future<void> addPost(Map<String, String> fields) async {
    await Api.insert('posts', _postRow(fields));
    await refresh();
  }

  Future<void> updatePost(String id, Map<String, String> fields) async {
    await Api.update('posts', id, _postRow(fields));
    await refresh();
  }

  Future<void> deletePost(String id) async {
    await Api.deleteRow('posts', id);
    await refresh();
  }

  // ---------------------------------------------------------------
  //  admin: categories
  // ---------------------------------------------------------------

  Future<void> addCategory(String name) async {
    int maxSort = 0;
    for (final Category c in categories) {
      if (c.sort > maxSort) maxSort = c.sort;
    }
    final String id = 'c${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
    await Api.insert('categories', <String, dynamic>{'id': id, 'name': name, 'sort': maxSort + 1});
    await refresh();
  }

  Future<void> renameCategory(String id, String name) async {
    await Api.update('categories', id, <String, dynamic>{'name': name});
    await refresh();
  }

  Future<void> deleteCategory(String id) async {
    await Api.deleteRow('categories', id);
    await refresh();
  }

  // ---------------------------------------------------------------
  //  offline copies of books
  // ---------------------------------------------------------------

  bool isDownloaded(String id) => downloads.containsKey(id);

  String localPath(String id) => '$_booksDir/$id.pdf';

  Future<String> ensureLocal(Book b, void Function(int, int) onProgress) async {
    final String path = localPath(b.id);
    if (downloads.containsKey(b.id) && await File(path).exists()) {
      return path;
    }
    await Api.download(Api.publicUrl(b.filePath), path, onProgress);
    downloads[b.id] =
        DownloadInfo(id: b.id, title: b.title, author: b.author, size: b.fileSize);
    await _saveDownloads();
    notifyListeners();
    return path;
  }

  Future<void> removeDownload(String id) async {
    downloads.remove(id);
    try {
      final File f = File(localPath(id));
      if (await f.exists()) await f.delete();
    } catch (_) {}
    await _saveDownloads();
    notifyListeners();
  }

  Future<void> _saveDownloads() {
    return Local.writeJson(
      'downloads.json',
      downloads.values.map((DownloadInfo d) => d.toJson()).toList(),
    );
  }

  // ---------------------------------------------------------------
  //  reading position
  // ---------------------------------------------------------------

  int lastPage(String id) => _lastPage[id] ?? 0;

  void setLastPage(String id, int page) {
    _lastPage[id] = page;
    Local.writeJson('lastpage.json', _lastPage);
  }
}

final Lib lib = Lib();
