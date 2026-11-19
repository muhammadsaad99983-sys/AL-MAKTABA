import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api.dart';
import 'common.dart';
import 'models.dart';
import 'native.dart';
import 'state.dart';
import 'ui_admin.dart';

String postAsText(Post p) {
  final StringBuffer b = StringBuffer();
  b.writeln(p.title);
  if (p.arabic.isNotEmpty) {
    b.writeln();
    b.writeln(p.arabic);
  }
  if (p.body.isNotEmpty) {
    b.writeln();
    b.writeln(p.body);
  }
  final List<String> meta = <String>[];
  if (p.source.isNotEmpty) meta.add('ماخذ: ${p.source}');
  if (p.number.isNotEmpty) meta.add('نمبر: ${p.number}');
  if (meta.isNotEmpty) {
    b.writeln();
    b.writeln(meta.join('، '));
  }
  b.writeln();
  b.write('— المکتبۃ الآفتابیہ');
  return b.toString();
}

class PostDetail extends StatelessWidget {
  final String postId;
  const PostDetail({super.key, required this.postId});

  Future<void> _delete(BuildContext context, Post p) async {
    final bool ok = await confirmDialog(context, 'تحریر حذف کریں', 'یہ تحریر سب کے لیے حذف ہو جائے گی۔ کیا آپ واقعی حذف کرنا چاہتے ہیں؟');
    if (!ok) return;
    try {
      await lib.deletePost(p.id);
      if (context.mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (context.mounted) snack(context, e.message);
    } catch (_) {
      if (context.mounted) snack(context, 'حذف نہیں ہو سکی');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lib,
      builder: (BuildContext context, Widget? _) {
        final Post? p = lib.findPost(postId);
        if (p == null) {
          return Scaffold(appBar: appBar('تحریر'), body: const EmptyState(Icons.article_outlined, 'یہ تحریر اب موجود نہیں۔'));
        }
        final List<String> meta = <String>[];
        if (p.source.isNotEmpty) meta.add('ماخذ: ${p.source}');
        if (p.number.isNotEmpty) meta.add('نمبر: ${p.number}');

        return Scaffold(
          appBar: appBar(
            kindLabel(p.kind),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'کاپی',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: postAsText(p)));
                  if (context.mounted) snack(context, 'کاپی ہو گیا');
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'شیئر',
                onPressed: () => Native.shareText(postAsText(p), 'شیئر کریں'),
              ),
              if (Api.isAdmin)
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'ترمیم',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (BuildContext _) => PostForm(post: p)),
                  ),
                ),
              if (Api.isAdmin)
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'حذف',
                  onPressed: () => _delete(context, p),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(14),
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: <Widget>[
                  Pill(kindLabel(p.kind), kGold),
                  Pill(lib.categoryName(p.categoryId), kGreen),
                  if (p.createdAt.isNotEmpty) Pill(formatDate(p.createdAt), Colors.blueGrey),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                p.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kDark, height: 1.7),
              ),
              if (meta.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(meta.join('   •   '), style: const TextStyle(color: Colors.black54)),
                ),
              const SizedBox(height: 12),
              if (p.arabic.isNotEmpty)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: const Color(0xFFFFFBEF),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      p.arabic,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, height: 2.1, color: Colors.black87),
                    ),
                  ),
                ),
              if (p.body.isNotEmpty)
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(p.body, style: const TextStyle(fontSize: 18, height: 2.0)),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
