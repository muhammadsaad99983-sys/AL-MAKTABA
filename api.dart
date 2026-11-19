import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'config.dart';
import 'local.dart';

class ApiException implements Exception {
  final String message;
  final bool auth;
  ApiException(this.message, {this.auth = false});

  @override
  String toString() => message;
}

class Session {
  String access;
  String refresh;
  DateTime expires;
  String email;
  Session(this.access, this.refresh, this.expires, this.email);
}

class _Resp {
  final int status;
  final String body;
  _Resp(this.status, this.body);

  dynamic get json {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }
}

/// Talks to Supabase over plain HTTPS (dart:io only, no plugins).
class Api {
  static final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 20);

  static Session? session;
  static bool get isAdmin => session != null;
  static String get adminEmail => session?.email ?? '';
  static Future<void>? _refreshing;

  // ------------------------------------------------------------
  //  low level
  // ------------------------------------------------------------

  static Future<_Resp> _raw(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    String? token,
    Map<String, String>? headers,
  }) async {
    Uri uri = Uri.parse('${Config.baseUrl}$path');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: query);
    }
    try {
      final HttpClientRequest req =
          await _client.openUrl(method, uri).timeout(const Duration(seconds: 25));
      req.headers.set('apikey', Config.supabaseKey);
      if (token != null) {
        req.headers.set('Authorization', 'Bearer $token');
      }
      if (headers != null) {
        headers.forEach((String k, String v) => req.headers.set(k, v));
      }
      if (body != null) {
        final List<int> bytes = utf8.encode(jsonEncode(body));
        req.headers.set('Content-Type', 'application/json; charset=utf-8');
        req.contentLength = bytes.length;
        req.add(bytes);
      }
      final HttpClientResponse resp = await req.close().timeout(const Duration(seconds: 40));
      final String text =
          await resp.transform(utf8.decoder).join().timeout(const Duration(seconds: 60));
      return _Resp(resp.statusCode, text);
    } on SocketException {
      throw ApiException('انٹرنیٹ سے رابطہ نہیں ہو سکا');
    } on TimeoutException {
      throw ApiException('انٹرنیٹ بہت سست ہے، دوبارہ کوشش کریں');
    } on HandshakeException {
      throw ApiException('محفوظ رابطہ قائم نہیں ہو سکا۔ فون کی تاریخ اور وقت درست کریں');
    } on HttpException {
      throw ApiException('سرور سے رابطے میں خرابی');
    }
  }

  static String _msg(_Resp r) {
    if (r.status == 401 || r.status == 403) {
      return 'اجازت نہیں ہے۔ ناظم کے طور پر دوبارہ لاگ اِن کریں۔';
    }
    if (r.status == 413) return 'فائل بہت بڑی ہے';
    final dynamic j = r.json;
    String m = '';
    if (j is Map) {
      for (final String k in <String>['error_description', 'message', 'msg', 'error']) {
        final dynamic v = j[k];
        if (v != null && v.toString().isNotEmpty) {
          m = v.toString();
          break;
        }
      }
    }
    if (r.status == 404) {
      return 'مطلوبہ چیز نہیں ملی۔ کیا Supabase کا سیٹ اپ (SQL) مکمل ہے؟';
    }
    return m.isEmpty ? 'خرابی (${r.status})' : 'خرابی: $m';
  }

  static void _check(_Resp r) {
    if (r.status >= 200 && r.status < 300) return;
    throw ApiException(_msg(r), auth: r.status == 401 || r.status == 403);
  }

  // ------------------------------------------------------------
  //  admin login
  // ------------------------------------------------------------

  static Future<void> restore() async {
    final dynamic j = await Local.readJson('session.json');
    if (j is Map) {
      final String refresh = (j['refresh'] ?? '').toString();
      if (refresh.isNotEmpty) {
        session = Session(
          '',
          refresh,
          DateTime.fromMillisecondsSinceEpoch(0),
          (j['email'] ?? '').toString(),
        );
      }
    }
  }

  static Future<void> _persist() async {
    final Session? s = session;
    if (s == null) {
      await Local.delete('session.json');
    } else {
      await Local.writeJson('session.json', <String, dynamic>{'refresh': s.refresh, 'email': s.email});
    }
  }

  static void _applyTokens(dynamic j, String email) {
    if (j is! Map) throw ApiException('سرور کا جواب سمجھ نہیں آیا');
    final String access = (j['access_token'] ?? '').toString();
    final String refresh = (j['refresh_token'] ?? '').toString();
    final dynamic exp = j['expires_in'];
    final int secs = exp is num ? exp.toInt() : 3600;
    if (access.isEmpty || refresh.isEmpty) {
      throw ApiException('لاگ اِن کا جواب نامکمل ہے');
    }
    session = Session(access, refresh, DateTime.now().add(Duration(seconds: secs)), email);
  }

  static Future<void> login(String email, String password) async {
    final _Resp r = await _raw(
      'POST',
      '/auth/v1/token',
      query: <String, String>{'grant_type': 'password'},
      body: <String, dynamic>{'email': email.trim(), 'password': password},
    );
    if (r.status == 400 || r.status == 401 || r.status == 422) {
      throw ApiException('ای میل یا پاس ورڈ درست نہیں');
    }
    if (r.status < 200 || r.status >= 300) {
      throw ApiException(_msg(r));
    }
    _applyTokens(r.json, email.trim());
    await _persist();
  }

  static Future<void> logout() async {
    session = null;
    await _persist();
  }

  static Future<void> _refresh() async {
    final Session? s = session;
    if (s == null) {
      throw ApiException('پہلے ناظم کے طور پر لاگ اِن کریں', auth: true);
    }
    final _Resp r = await _raw(
      'POST',
      '/auth/v1/token',
      query: <String, String>{'grant_type': 'refresh_token'},
      body: <String, dynamic>{'refresh_token': s.refresh},
    );
    if (r.status >= 200 && r.status < 300) {
      _applyTokens(r.json, s.email);
      await _persist();
      return;
    }
    if (r.status == 400 || r.status == 401 || r.status == 403) {
      session = null;
      await _persist();
      throw ApiException('لاگ اِن کی مدت ختم ہو گئی، دوبارہ لاگ اِن کریں', auth: true);
    }
    throw ApiException(_msg(r));
  }

  static Future<String> _token() async {
    final Session? s = session;
    if (s == null) {
      throw ApiException('پہلے ناظم کے طور پر لاگ اِن کریں', auth: true);
    }
    if (s.access.isNotEmpty && s.expires.isAfter(DateTime.now().add(const Duration(seconds: 60)))) {
      return s.access;
    }
    final Future<void> running = _refreshing ??= _refresh().whenComplete(() {
      _refreshing = null;
    });
    await running;
    final Session? s2 = session;
    if (s2 == null) {
      throw ApiException('لاگ اِن کی مدت ختم ہو گئی، دوبارہ لاگ اِن کریں', auth: true);
    }
    return s2.access;
  }

  /// Quietly checks that a saved login is still valid.
  static Future<void> verifySavedLogin() async {
    if (session == null) return;
    try {
      await _token();
    } on ApiException {
      // offline or expired: _token already cleared an invalid session
    }
  }

  // ------------------------------------------------------------
  //  database (PostgREST)
  // ------------------------------------------------------------

  static Future<List<dynamic>> getList(String table, {String order = 'created_at.desc'}) async {
    final _Resp r = await _raw(
      'GET',
      '/rest/v1/$table',
      query: <String, String>{'select': '*', 'order': order, 'limit': '1000'},
    );
    _check(r);
    final dynamic j = r.json;
    return j is List ? j : <dynamic>[];
  }

  static Future<void> insert(String table, Map<String, dynamic> row) async {
    final String token = await _token();
    final _Resp r = await _raw(
      'POST',
      '/rest/v1/$table',
      body: row,
      token: token,
      headers: <String, String>{'Prefer': 'return=minimal'},
    );
    _check(r);
  }

  static Future<void> update(String table, String id, Map<String, dynamic> row) async {
    final String token = await _token();
    final _Resp r = await _raw(
      'PATCH',
      '/rest/v1/$table',
      query: <String, String>{'id': 'eq.$id'},
      body: row,
      token: token,
      headers: <String, String>{'Prefer': 'return=minimal'},
    );
    _check(r);
  }

  static Future<void> deleteRow(String table, String id) async {
    final String token = await _token();
    final _Resp r = await _raw(
      'DELETE',
      '/rest/v1/$table',
      query: <String, String>{'id': 'eq.$id'},
      token: token,
    );
    _check(r);
  }

  // ------------------------------------------------------------
  //  files (Supabase Storage)
  // ------------------------------------------------------------

  static String publicUrl(String path) =>
      '${Config.baseUrl}/storage/v1/object/public/${Config.bucket}/$path';

  static Future<void> uploadFile(
    String storagePath,
    File file,
    void Function(int sent, int total) onProgress,
  ) async {
    final String token = await _token();
    final int total = await file.length();
    final Uri uri =
        Uri.parse('${Config.baseUrl}/storage/v1/object/${Config.bucket}/$storagePath');
    try {
      final HttpClientRequest req = await _client.postUrl(uri);
      req.headers.set('apikey', Config.supabaseKey);
      req.headers.set('Authorization', 'Bearer $token');
      req.headers.set('Content-Type', 'application/pdf');
      req.headers.set('x-upsert', 'false');
      req.contentLength = total;
      int sent = 0;
      await req.addStream(file.openRead().map((List<int> chunk) {
        sent += chunk.length;
        onProgress(sent, total);
        return chunk;
      }));
      final HttpClientResponse resp = await req.close();
      final String text = await resp.transform(utf8.decoder).join();
      _check(_Resp(resp.statusCode, text));
    } on SocketException {
      throw ApiException('اپلوڈ کے دوران انٹرنیٹ بند ہو گیا');
    } on HttpException {
      throw ApiException('اپلوڈ میں سرور کی خرابی');
    }
  }

  static Future<void> deleteFile(String storagePath) async {
    final String token = await _token();
    final _Resp r = await _raw(
      'DELETE',
      '/storage/v1/object/${Config.bucket}/$storagePath',
      token: token,
    );
    if (r.status == 404) return;
    _check(r);
  }

  static Future<void> download(
    String url,
    String destPath,
    void Function(int got, int total) onProgress,
  ) async {
    final File tmp = File('$destPath.part');
    IOSink? sink;
    try {
      final HttpClientRequest req =
          await _client.getUrl(Uri.parse(url)).timeout(const Duration(seconds: 25));
      final HttpClientResponse resp = await req.close().timeout(const Duration(seconds: 40));
      if (resp.statusCode != 200) {
        await resp.drain<void>();
        throw ApiException(resp.statusCode == 404 ? 'یہ کتاب سرور پر نہیں ملی' : 'ڈاؤنلوڈ نہیں ہو سکا (${resp.statusCode})');
      }
      final int total = resp.contentLength;
      int got = 0;
      sink = tmp.openWrite();
      await for (final List<int> chunk in resp.timeout(const Duration(seconds: 60))) {
        sink.add(chunk);
        got += chunk.length;
        onProgress(got, total);
      }
      await sink.flush();
      await sink.close();
      sink = null;
      if (got == 0) {
        throw ApiException('فائل خالی ملی');
      }
      await tmp.rename(destPath);
    } on SocketException {
      await _cleanup(sink, tmp);
      throw ApiException('ڈاؤنلوڈ کے دوران انٹرنیٹ بند ہو گیا');
    } on TimeoutException {
      await _cleanup(sink, tmp);
      throw ApiException('انٹرنیٹ بہت سست ہے، دوبارہ کوشش کریں');
    } on HttpException {
      await _cleanup(sink, tmp);
      throw ApiException('ڈاؤنلوڈ میں سرور کی خرابی');
    } catch (_) {
      await _cleanup(sink, tmp);
      rethrow;
    }
  }

  static Future<void> _cleanup(IOSink? sink, File tmp) async {
    try {
      await sink?.close();
    } catch (_) {}
    try {
      if (await tmp.exists()) await tmp.delete();
    } catch (_) {}
  }
}
