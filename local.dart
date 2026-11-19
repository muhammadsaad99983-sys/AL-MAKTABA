import 'dart:convert';
import 'dart:io';
import 'native.dart';

/// Small JSON files and downloaded books inside the app's private folder.
class Local {
  static Directory? _root;
  static final Map<String, Future<void>> _chains = <String, Future<void>>{};

  static Future<Directory> root() async {
    final Directory? cached = _root;
    if (cached != null) return cached;
    String base;
    try {
      base = await Native.dir();
      if (base.isEmpty) base = Directory.systemTemp.path;
    } catch (_) {
      base = Directory.systemTemp.path;
    }
    final Directory d = Directory('$base/aftabia');
    if (!await d.exists()) {
      await d.create(recursive: true);
    }
    _root = d;
    return d;
  }

  static Future<File> _file(String name) async {
    final Directory d = await root();
    return File('${d.path}/$name');
  }

  static Future<dynamic> readJson(String name) async {
    try {
      final File f = await _file(name);
      if (await f.exists()) {
        return jsonDecode(await f.readAsString());
      }
    } catch (_) {}
    return null;
  }

  static Future<void> writeJson(String name, Object data) {
    final String text = jsonEncode(data);
    final Future<void> prev = _chains[name] ?? Future<void>.value();
    final Future<void> next = prev.then((_) => _write(name, text));
    _chains[name] = next;
    return next;
  }

  static Future<void> _write(String name, String text) async {
    try {
      final File f = await _file(name);
      final File tmp = File('${f.path}.tmp');
      await tmp.writeAsString(text, flush: true);
      await tmp.rename(f.path);
    } catch (_) {}
  }

  static Future<void> delete(String name) async {
    try {
      final File f = await _file(name);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  static Future<String> booksDir() async {
    final Directory r = await root();
    final Directory d = Directory('${r.path}/books');
    if (!await d.exists()) {
      await d.create(recursive: true);
    }
    return d.path;
  }
}
