import 'package:flutter/material.dart';
import 'api.dart';
import 'common.dart';
import 'models.dart';
import 'native.dart';
import 'state.dart';
import 'ui_admin.dart';
import 'ui_reader.dart';

String safePdfName(String title) {
  String n = title.replaceAll(RegExp(r'[\\/:*?"<>|\r\n]'), '_').trim();
  if (n.isEmpty) n = 'book';
  if (n.length > 80) n = n.substring(0, 80);
  return '$n.pdf';
}

class BookDetail extends StatefulWidget {
  final String bookId;
  const BookDetail({super.key, required this.bookId});

  @override
  State<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  bool busy = false;
  String busyText = '';
  double? progress;

  void _onProgress(int got, int total) {
    if (!mounted) return;
    setState(() => progress = total > 0 ? got / total : null);
  }

  /// Makes sure the book is on the phone. Returns its path or null on error.
  Future<String?> _fetch(Book b) async {
    setState(() {
      busy = true;
      busyText = 'ڈاؤنلوڈ ہو رہی ہے...';
      progress = null;
    });
    try {
      return await lib.ensureLocal(b, _onProgress);
    } on ApiException catch (e) {
      if (mounted) snack(context, e.message);
    } catch (_) {
      if (mounted) snack(context, 'کتاب ڈاؤنلوڈ نہیں ہو سکی');
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
          progress = null;
        });
      }
    }
    return null;
  }

  Future<void> _read(Book b) async {
    final String? path = await _fetch(b);
    if (path == null || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext _) => ReaderScreen(bookId: b.id, title: b.title, path: path),
      ),
    );
  }

  Future<void> _download(Book b) async {
    final String? path = await _fetch(b);
    if (path != null && mounted) {
      snack(context, 'کتاب آپ کے فون میں محفوظ ہو گئی، اب بغیر انٹرنیٹ بھی پڑھ سکتے ہیں');
    }
  }

  Future<void> _saveCopy(Book b) async {
    final String? path = await _fetch(b);
    if (path == null || !mounted) return;
    try {
      final String shown = await Native.saveToDownloads(path, safePdfName(b.title));
      if (mounted) snack(context, 'محفوظ ہو گئی: $shown');
    } catch (_) {
      if (mounted) snack(context, 'فون میں محفوظ نہیں ہو سکی');
    }
  }

  Future<void> _removeOffline(Book b) async {
    final bool ok = await confirmDialog(context, 'آف لائن کاپی ہٹائیں', 'فون سے یہ کتاب ہٹا دی جائے؟ آپ اسے دوبارہ ڈاؤنلوڈ کر سکتے ہیں۔');
    if (ok) await lib.removeDownload(b.id);
  }

  Future<void> _delete(Book b) async {
    final bool ok = await confirmDialog(context, 'کتاب حذف کریں', 'یہ کتاب سب کے لیے ہمیشہ کے لیے حذف ہو جائے گی۔ کیا آپ واقعی حذف کرنا چاہتے ہیں؟');
    if (!ok) return;
    setState(() {
      busy = true;
      busyText = 'حذف ہو رہی ہے...';
      progress = null;
    });
    try {
      await lib.deleteBook(b);
      if (mounted) {
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) {
        snack(context, e.message);
        setState(() => busy = false);
      }
    } catch (_) {
      if (mounted) {
        snack(context, 'حذف نہیں ہو سکی');
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lib,
      builder: (BuildContext context, Widget? _) {
        final Book? b = lib.findBook(widget.bookId);
        if (b == null) {
          return Scaffold(appBar: appBar('کتاب'), body: const EmptyState(Icons.menu_book_outlined, 'یہ کتاب اب موجود نہیں۔'));
        }
        final bool have = lib.isDownloaded(b.id);
        final String size = formatSize(b.fileSize);

        return Scaffold(
          appBar: appBar(
            'کتاب کی تفصیل',
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'شیئر',
                onPressed: () => Native.shareText('${b.title}\n${Api.publicUrl(b.filePath)}', 'کتاب شیئر کریں'),
              ),
              if (Api.isAdmin)
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'ترمیم',
                  onPressed: busy
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(builder: (BuildContext _) => BookForm(book: b)),
                          ),
                ),
              if (Api.isAdmin)
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'حذف',
                  onPressed: busy ? null : () => _delete(b),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(14),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFF117A63), Color(0xFF073B30)],
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 62,
                      height: 78,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.picture_as_pdf, color: kGreen, size: 34),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            b.title,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.6),
                          ),
                          if (b.author.isNotEmpty)
                            Text(b.author, style: const TextStyle(color: Color(0xFFD7EBE4), fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: <Widget>[
                  Pill(lib.categoryName(b.categoryId), kGreen),
                  if (size.isNotEmpty) Pill(size, kGold),
                  if (b.createdAt.isNotEmpty) Pill(formatDate(b.createdAt), Colors.blueGrey),
                  if (have) const Pill('فون میں محفوظ', kGreen),
                ],
              ),
              if (b.description.isNotEmpty) ...<Widget>[
                const SectionTitle('تعارف'),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: SelectableText(b.description, style: const TextStyle(fontSize: 16, height: 1.9)),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              if (busy) ...<Widget>[
                Text(busyText, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: progress),
                if (progress != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${(progress! * 100).round()}%', style: const TextStyle(color: Colors.black54)),
                  ),
              ] else ...<Widget>[
                FilledButton.icon(
                  onPressed: () => _read(b),
                  icon: const Icon(Icons.auto_stories),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('کتاب پڑھیں', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 8),
                if (!have)
                  OutlinedButton.icon(
                    onPressed: () => _download(b),
                    icon: const Icon(Icons.download),
                    label: const Text('ڈاؤنلوڈ کریں (بغیر انٹرنیٹ پڑھنے کے لیے)'),
                  ),
                if (have) ...<Widget>[
                  OutlinedButton.icon(
                    onPressed: () => _saveCopy(b),
                    icon: const Icon(Icons.save_alt),
                    label: const Text('فون کی Downloads میں PDF محفوظ کریں'),
                  ),
                  TextButton.icon(
                    onPressed: () => _removeOffline(b),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('فون سے آف لائن کاپی ہٹائیں'),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
