import 'dart:io';
import 'package:flutter/material.dart' hide Text;
import 'api.dart';
import 'common.dart';
import 'i18n.dart';
import 'local.dart';
import 'models.dart';
import 'native.dart';
import 'settings.dart';
import 'state.dart';
import 'ui_admin.dart';

String _titleFromName(String name) {
  String n = name;
  if (n.toLowerCase().endsWith('.pdf')) n = n.substring(0, n.length - 4);
  n = n.replaceAll('_', ' ').replaceAll('%20', ' ').trim();
  return n.isEmpty ? 'کتاب' : n;
}

void _open(BuildContext context, List<PickedPdf> files) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (BuildContext _) => BatchUploadScreen(files: files)),
  );
}

/// Method: choose many PDF files at once from the phone.
Future<void> startPickMany(BuildContext context) async {
  try {
    final List<PickedPdf> files = await Native.pickPdfs();
    if (files.isEmpty || !context.mounted) return;
    _open(context, files);
  } catch (_) {
    if (context.mounted) snack(context, 'فائل منتخب نہیں ہو سکی');
  }
}

/// Method: type or paste a direct link of a PDF file.
Future<void> startUrlImport(BuildContext context) async {
  final TextEditingController ctl = TextEditingController();
  final String? url = await showDialog<String>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: const Text('لنک سے PDF شامل کریں'),
      content: TextField(
        controller: ctl,
        autofocus: true,
        keyboardType: TextInputType.url,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(hintText: 'https://example.com/book.pdf'),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('منسوخ')),
        FilledButton(onPressed: () => Navigator.pop(ctx, ctl.text.trim()), child: const Text('ڈاؤنلوڈ کریں')),
      ],
    ),
  );
  if (url == null || url.isEmpty || !context.mounted) return;
  final Uri? u = Uri.tryParse(url);
  if (u == null || !(u.scheme == 'http' || u.scheme == 'https')) {
    snack(context, 'یہ درست لنک نہیں ہے');
    return;
  }
  final ValueNotifier<double?> prog = ValueNotifier<double?>(null);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) => AlertDialog(
      content: ValueListenableBuilder<double?>(
        valueListenable: prog,
        builder: (BuildContext _, double? v, Widget? __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LinearProgressIndicator(value: v),
            const SizedBox(height: 14),
            const Text('ڈاؤنلوڈ ہو رہی ہے...'),
          ],
        ),
      ),
    ),
  );
  String? err;
  PickedPdf? got;
  try {
    final String dir = (await Local.root()).path;
    final String dest = '$dir/import_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await Api.download(url, dest, (int g, int t) => prog.value = t > 0 ? g / t : null);
    final File f = File(dest);
    final RandomAccessFile raf = await f.open();
    final List<int> head = await raf.read(5);
    await raf.close();
    if (String.fromCharCodes(head).startsWith('%PDF')) {
      String name = u.pathSegments.isNotEmpty ? Uri.decodeComponent(u.pathSegments.last) : 'book.pdf';
      if (name.isEmpty) name = 'book.pdf';
      got = PickedPdf(dest, name, await f.length());
    } else {
      await f.delete();
      err = 'یہ لنک PDF فائل کا نہیں ہے';
    }
  } on ApiException catch (e) {
    err = e.message;
  } catch (_) {
    err = 'ڈاؤنلوڈ نہیں ہو سکا';
  }
  if (!context.mounted) return;
  Navigator.pop(context); // close the progress dialog
  if (err != null) {
    snack(context, err);
    return;
  }
  if (got != null) _open(context, <PickedPdf>[got]);
}

/// Method: PDF shared from another app (WhatsApp, file manager, browser...).
Future<void> handleShared(BuildContext context) async {
  final List<PickedPdf> files = await Native.takeShared();
  if (files.isEmpty || !context.mounted) return;
  if (!Api.isAdmin) {
    for (final PickedPdf p in files) {
      try {
        await File(p.path).delete();
      } catch (_) {}
    }
    snack(context, 'کتاب شامل کرنے کے لیے پہلے ناظم کے طور پر لاگ اِن کریں');
    return;
  }
  _open(context, files);
}

class _Row {
  final PickedPdf file;
  final TextEditingController title;
  String status = ''; // '' | busy | done | fail
  String message = '';
  double? progress;
  bool include = true;
  _Row(this.file) : title = TextEditingController(text: _titleFromName(file.name));
}

class BatchUploadScreen extends StatefulWidget {
  final List<PickedPdf> files;
  const BatchUploadScreen({super.key, required this.files});

  @override
  State<BatchUploadScreen> createState() => _BatchUploadScreenState();
}

class _BatchUploadScreenState extends State<BatchUploadScreen> {
  late final List<_Row> rows;
  String categoryId = '';
  String language = 'ur';
  bool busy = false;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    rows = widget.files.map((PickedPdf f) => _Row(f)).toList();
    for (final _Row r in rows) {
      if (r.file.size > kMaxPdfBytes) {
        r.include = false;
        r.status = 'fail';
        r.message = 'یہ فائل 50 MB سے بڑی ہے۔ پہلے PDF چھوٹی کر لیں';
      }
    }
  }

  @override
  void dispose() {
    for (final _Row r in rows) {
      r.title.dispose();
    }
    super.dispose();
  }

  Future<void> _addMore() async {
    try {
      final List<PickedPdf> more = await Native.pickPdfs();
      if (!mounted || more.isEmpty) return;
      setState(() {
        for (final PickedPdf p in more) {
          final _Row r = _Row(p);
          if (p.size > kMaxPdfBytes) {
            r.include = false;
            r.status = 'fail';
            r.message = 'یہ فائل 50 MB سے بڑی ہے۔ پہلے PDF چھوٹی کر لیں';
          }
          rows.add(r);
        }
      });
    } catch (_) {
      if (mounted) snack(context, 'فائل منتخب نہیں ہو سکی');
    }
  }

  Future<void> _upload() async {
    setState(() => busy = true);
    for (final _Row r in rows) {
      if (!r.include || r.status == 'done') continue;
      final String t = r.title.text.trim();
      if (t.isEmpty) {
        setState(() {
          r.status = 'fail';
          r.message = 'کتاب کا نام لکھیں';
        });
        continue;
      }
      setState(() {
        r.status = 'busy';
        r.message = '';
        r.progress = null;
      });
      try {
        await lib.addBook(
          filePath: r.file.path,
          size: r.file.size,
          title: t,
          author: '',
          description: '',
          categoryId: categoryId,
          language: language,
          onProgress: (int s, int total) {
            if (mounted) setState(() => r.progress = total > 0 ? s / total : null);
          },
        );
        try {
          await File(r.file.path).delete();
        } catch (_) {}
        if (mounted) setState(() => r.status = 'done');
      } on ApiException catch (e) {
        if (mounted) {
          setState(() {
            r.status = 'fail';
            r.message = e.message;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            r.status = 'fail';
            r.message = 'کتاب محفوظ نہیں ہو سکی';
          });
        }
      }
    }
    if (mounted) {
      setState(() {
        busy = false;
        finished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int todo = rows.where((_Row r) => r.include && r.status != 'done').length;
    final int done = rows.where((_Row r) => r.status == 'done').length;
    return Scaffold(
      appBar: appBar('کتابیں شامل کریں'),
      body: AbsorbPointer(
        absorbing: busy,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: <Widget>[
            Text(tf('%s فائلیں منتخب ہیں', <Object>[rows.length]), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('نیچے ہر کتاب کا نام درست کر لیں۔ زمرہ اور زبان سب کتابوں کے لیے ایک ہی لگے گی۔',
                style: TextStyle(height: 1.8)),
            const SectionTitle('کتاب کی زبان'),
            ChipsRow(
              items: kLanguages.entries.toList(),
              selected: language,
              onSelected: (String v) => setState(() => language = v),
            ),
            const SectionTitle('زمرہ'),
            CategoryPicker(selected: categoryId, onChanged: (String v) => setState(() => categoryId = v)),
            const SectionTitle('فائلیں'),
            ...rows.map((_Row r) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.picture_as_pdf, color: kGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('${r.file.name}  (${formatSize(r.file.size)})',
                                maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: kMuted, fontSize: 12)),
                          ),
                          if (r.status == 'done') const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                          if (r.status == 'fail') const Icon(Icons.error, color: kRed),
                          if (r.status.isEmpty && !busy && !finished)
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() => rows.remove(r)),
                            ),
                        ],
                      ),
                      if (r.status != 'done')
                        TextField(
                          controller: r.title,
                          enabled: r.include,
                          decoration: InputDecoration(labelText: tr('کتاب کا نام')),
                        ),
                      if (r.status == 'busy')
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(value: r.progress),
                        ),
                      if (r.message.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(r.message, style: const TextStyle(color: kRed)),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            if (!finished || todo > 0)
              OutlinedButton.icon(
                onPressed: _addMore,
                icon: const Icon(Icons.add),
                label: const Text('مزید فائلیں شامل کریں'),
              ),
            const SizedBox(height: 10),
            if (finished && done > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(tf('%s کتابیں شامل ہو گئیں', <Object>[done]),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
              ),
            FilledButton.icon(
              onPressed: todo == 0 ? null : _upload,
              icon: busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Icon(Icons.cloud_upload),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(busy ? 'اپلوڈ ہو رہی ہے، ایپ بند نہ کریں...' : 'سب اپلوڈ کریں'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
