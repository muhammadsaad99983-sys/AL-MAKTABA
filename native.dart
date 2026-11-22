import 'dart:typed_data';
import 'package:flutter/services.dart';

class PickedPdf {
  final String path;
  final String name;
  final int size;
  PickedPdf(this.path, this.name, this.size);
}

class RenderedPage {
  final Uint8List bytes;
  final bool blank;
  RenderedPage(this.bytes, this.blank);
}

/// Thin wrapper around the Kotlin code in MainActivity.kt.
/// It gives us: private folder, PDF picker, PDF page renderer,
/// save to Downloads, share and open link - without any plugin.
class Native {
  static const MethodChannel _ch = MethodChannel('aftabia/native');

  static Future<String> dir() async {
    final String? d = await _ch.invokeMethod<String>('dir');
    return d ?? '';
  }

  static Future<PickedPdf?> pickPdf() async {
    final Map<dynamic, dynamic>? r = await _ch.invokeMethod<Map<dynamic, dynamic>>('pickPdf');
    if (r == null) return null;
    final int size = (r['size'] is num) ? (r['size'] as num).toInt() : 0;
    return PickedPdf((r['path'] ?? '').toString(), (r['name'] ?? 'book.pdf').toString(), size);
  }

  static List<PickedPdf> _list(List<dynamic>? raw) {
    final List<PickedPdf> out = <PickedPdf>[];
    if (raw == null) return out;
    for (final dynamic e in raw) {
      if (e is Map) {
        final int size = (e['size'] is num) ? (e['size'] as num).toInt() : 0;
        out.add(PickedPdf((e['path'] ?? '').toString(), (e['name'] ?? 'book.pdf').toString(), size));
      }
    }
    return out;
  }

  /// Several PDF files at once.
  static Future<List<PickedPdf>> pickPdfs() async {
    final List<dynamic>? r = await _ch.invokeMethod<List<dynamic>>('pickPdfs');
    return _list(r);
  }

  /// PDF files that another app shared to this app (Share > Al-Maktaba).
  static Future<List<PickedPdf>> takeShared() async {
    try {
      final List<dynamic>? r = await _ch.invokeMethod<List<dynamic>>('takeShared');
      return _list(r);
    } catch (_) {
      return <PickedPdf>[];
    }
  }

  /// Returns [pageCount, firstPageWidth, firstPageHeight].
  static Future<List<dynamic>> pdfOpen(String path) async {
    final List<dynamic>? r = await _ch.invokeMethod<List<dynamic>>('pdfOpen', <String, dynamic>{'path': path});
    return r ?? <dynamic>[0, 0, 0];
  }

  static Future<RenderedPage> pdfRender(String path, int page, int width) async {
    final Map<dynamic, dynamic>? r = await _ch.invokeMethod<Map<dynamic, dynamic>>(
      'pdfRender',
      <String, dynamic>{'path': path, 'page': page, 'width': width},
    );
    if (r == null || r['bytes'] == null) {
      throw Exception('render failed');
    }
    return RenderedPage(r['bytes'] as Uint8List, r['blank'] == true);
  }

  /// Opens the book in another PDF app installed on the phone.
  static Future<void> viewPdf(String path, String name) async {
    await _ch.invokeMethod<bool>('viewPdf', <String, dynamic>{'path': path, 'name': name});
  }

  static Future<void> pdfClose() async {
    try {
      await _ch.invokeMethod<bool>('pdfClose');
    } catch (_) {}
  }

  static Future<String> saveToDownloads(String path, String name) async {
    final String? r = await _ch.invokeMethod<String>(
      'saveToDownloads',
      <String, dynamic>{'path': path, 'name': name},
    );
    return r ?? '';
  }

  static Future<void> shareText(String text, String title) async {
    try {
      await _ch.invokeMethod<bool>('shareText', <String, dynamic>{'text': text, 'title': title});
    } catch (_) {}
  }

  static Future<void> openUrl(String url) async {
    try {
      await _ch.invokeMethod<bool>('openUrl', <String, dynamic>{'url': url});
    } catch (_) {}
  }
}
