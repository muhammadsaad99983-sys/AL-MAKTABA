const Map<String, String> kKinds = <String, String>{
  'hadith': 'حدیث',
  'dua': 'دعا',
  'zikr': 'ذکر',
  'masla': 'مسئلہ',
  'article': 'مضمون',
};

String kindLabel(String k) => kKinds[k] ?? 'مضمون';

/// Book languages, in the order shown in the app.
const Map<String, String> kLanguages = <String, String>{
  'ur': 'اردو',
  'en': 'English',
  'ar': 'عربی',
  'ps': 'پښتو',
  'other': 'دیگر',
};

String languageLabel(String k) => kLanguages[k] ?? 'دیگر';


String _s(Map<String, dynamic> j, String k) {
  final dynamic v = j[k];
  return v == null ? '' : v.toString();
}

int _n(Map<String, dynamic> j, String k) {
  final dynamic v = j[k];
  if (v is num) return v.toInt();
  return int.tryParse(v == null ? '' : v.toString()) ?? 0;
}

String two(int n) => n < 10 ? '0$n' : '$n';

String formatSize(int bytes) {
  if (bytes <= 0) return '';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String formatDate(String iso) {
  final DateTime? d = DateTime.tryParse(iso);
  if (d == null) return '';
  final DateTime l = d.toLocal();
  return '${two(l.day)}/${two(l.month)}/${l.year}';
}

String snippet(String s, int max) {
  final String t = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (t.length <= max) return t;
  return '${t.substring(0, max)}...';
}

class LibCategory {
  final String id;
  String name;
  int sort;

  LibCategory({required this.id, required this.name, this.sort = 0});

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'name': name, 'sort': sort};

  factory LibCategory.fromJson(Map<String, dynamic> j) =>
      LibCategory(id: _s(j, 'id'), name: _s(j, 'name'), sort: _n(j, 'sort'));
}

class Book {
  final String id;
  String title;
  String author;
  String description;
  String categoryId;
  String language;
  final String filePath;
  final int fileSize;
  final String createdAt;

  Book({
    required this.id,
    required this.title,
    this.author = '',
    this.description = '',
    this.categoryId = '',
    this.language = 'ur',
    required this.filePath,
    this.fileSize = 0,
    this.createdAt = '',
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'author': author,
        'description': description,
        'category_id': categoryId,
        'language': language,
        'file_path': filePath,
        'file_size': fileSize,
        'created_at': createdAt,
      };

  factory Book.fromJson(Map<String, dynamic> j) => Book(
        id: _s(j, 'id'),
        title: _s(j, 'title'),
        author: _s(j, 'author'),
        description: _s(j, 'description'),
        categoryId: _s(j, 'category_id'),
        language: _s(j, 'language').isEmpty ? 'ur' : _s(j, 'language'),
        filePath: _s(j, 'file_path'),
        fileSize: _n(j, 'file_size'),
        createdAt: _s(j, 'created_at'),
      );
}

class Post {
  final String id;
  String kind;
  String title;
  String arabic;
  String body;
  String number;
  String source;
  String categoryId;
  final String createdAt;

  Post({
    required this.id,
    this.kind = 'article',
    required this.title,
    this.arabic = '',
    this.body = '',
    this.number = '',
    this.source = '',
    this.categoryId = '',
    this.createdAt = '',
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'kind': kind,
        'title': title,
        'arabic': arabic,
        'body': body,
        'number': number,
        'source': source,
        'category_id': categoryId,
        'created_at': createdAt,
      };

  factory Post.fromJson(Map<String, dynamic> j) => Post(
        id: _s(j, 'id'),
        kind: _s(j, 'kind').isEmpty ? 'article' : _s(j, 'kind'),
        title: _s(j, 'title'),
        arabic: _s(j, 'arabic'),
        body: _s(j, 'body'),
        number: _s(j, 'number'),
        source: _s(j, 'source'),
        categoryId: _s(j, 'category_id'),
        createdAt: _s(j, 'created_at'),
      );
}
