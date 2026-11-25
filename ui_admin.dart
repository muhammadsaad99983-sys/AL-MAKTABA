import 'dart:io';
import 'package:flutter/material.dart' hide Text;
import 'i18n.dart';
import 'settings.dart';
import 'api.dart';
import 'common.dart';
import 'duas_data.dart';
import 'models.dart';
import 'native.dart';
import 'state.dart';

const int kMaxPdfBytes = 50 * 1024 * 1024;

// =====================================================================
//  Owner login
// =====================================================================

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();
  bool busy = false;
  bool hide = true;
  String error = '';

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (email.text.trim().isEmpty || pass.text.isEmpty) {
      setState(() => error = 'ای میل اور پاس ورڈ دونوں لکھیں');
      return;
    }
    setState(() {
      busy = true;
      error = '';
    });
    try {
      await lib.login(email.text, pass.text);
      if (mounted) {
        Navigator.pop(context);
        snack(context, 'ناظم کے طور پر لاگ اِن ہو گئے');
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) setState(() => error = 'لاگ اِن نہیں ہو سکا');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('ناظم لاگ اِن'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(
            'یہ حصہ صرف مکتبے کے مالک کے لیے ہے۔ لاگ اِن کے بعد آپ کتابیں اور تحریریں شامل یا حذف کر سکیں گے۔',
            style: TextStyle(height: 1.9, color: kText),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: tr('ای میل'),
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: pass,
            obscureText: hide,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: tr('پاس ورڈ'),
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(hide ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => hide = !hide),
              ),
            ),
          ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(error, style: const TextStyle(color: kRed, height: 1.6)),
            ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: busy ? null : _login,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: busy
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('لاگ اِن', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
//  Add / edit a book
// =====================================================================

class BookForm extends StatefulWidget {
  final Book? book;
  final String initialCategory;
  final String initialLanguage;
  const BookForm({super.key, this.book, this.initialCategory = '', this.initialLanguage = 'ur'});

  @override
  State<BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {
  late final TextEditingController title;
  late final TextEditingController author;
  late final TextEditingController desc;
  String categoryId = '';
  String language = 'ur';
  PickedPdf? picked;
  bool busy = false;
  double? progress;
  String error = '';

  bool get editing => widget.book != null;

  @override
  void initState() {
    super.initState();
    final Book? b = widget.book;
    title = TextEditingController(text: b?.title ?? '');
    author = TextEditingController(text: b?.author ?? '');
    desc = TextEditingController(text: b?.description ?? '');
    categoryId = b?.categoryId ?? widget.initialCategory;
    language = b?.language ?? widget.initialLanguage;
  }

  @override
  void dispose() {
    title.dispose();
    author.dispose();
    desc.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    try {
      final PickedPdf? p = await Native.pickPdf();
      if (p == null || !mounted) return;
      setState(() {
        picked = p;
        error = '';
        if (title.text.trim().isEmpty) {
          String n = p.name;
          if (n.toLowerCase().endsWith('.pdf')) n = n.substring(0, n.length - 4);
          title.text = n.replaceAll('_', ' ').trim();
        }
      });
    } catch (_) {
      if (mounted) setState(() => error = 'فائل منتخب نہیں ہو سکی');
    }
  }

  Future<void> _save() async {
    final String t = title.text.trim();
    if (t.isEmpty) {
      setState(() => error = 'کتاب کا نام لکھیں');
      return;
    }
    final PickedPdf? p = picked;
    if (!editing) {
      if (p == null) {
        setState(() => error = 'پہلے PDF فائل منتخب کریں');
        return;
      }
      if (p.size > kMaxPdfBytes) {
        setState(() => error = 'یہ فائل 50 MB سے بڑی ہے۔ پہلے PDF چھوٹی کر لیں');
        return;
      }
    }
    setState(() {
      busy = true;
      error = '';
      progress = null;
    });
    try {
      if (editing) {
        await lib.updateBook(widget.book!, t, author.text.trim(), desc.text.trim(), categoryId, language);
      } else {
        await lib.addBook(
          filePath: p!.path,
          size: p.size,
          title: t,
          author: author.text.trim(),
          description: desc.text.trim(),
          categoryId: categoryId,
          language: language,
          onProgress: (int sent, int total) {
            if (mounted) setState(() => progress = total > 0 ? sent / total : null);
          },
        );
        try {
          final File f = File(p.path);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
      if (mounted) {
        Navigator.pop(context);
        snack(context, editing ? 'تبدیلی محفوظ ہو گئی' : 'کتاب شامل ہو گئی');
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) setState(() => error = 'کتاب محفوظ نہیں ہو سکی');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PickedPdf? p = picked;
    return Scaffold(
      appBar: appBar(editing ? 'کتاب میں ترمیم' : 'نئی کتاب شامل کریں'),
      body: AbsorbPointer(
        absorbing: busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            if (!editing) ...<Widget>[
              OutlinedButton.icon(
                onPressed: _pick,
                icon: const Icon(Icons.upload_file),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(p == null ? 'PDF فائل منتخب کریں' : 'دوسری فائل منتخب کریں'),
                ),
              ),
              if (p != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('${p.name}  (${formatSize(p.size)})', style: TextStyle(color: kGreen, fontWeight: FontWeight.w600)),
                ),
              const SizedBox(height: 14),
            ],
            TextField(
              controller: title,
              decoration: InputDecoration(
                labelText: tr('کتاب کا نام'),
                prefixIcon: Icon(Icons.menu_book),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: author,
              decoration: InputDecoration(
                labelText: tr('مصنف (اختیاری)'),
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: desc,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: tr('کتاب کا تعارف (اختیاری)'),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('کتاب کی زبان', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: kLanguages.entries
                  .map((MapEntry<String, String> e) => ChoiceChip(
                        label: Text(e.value),
                        selected: language == e.key,
                        onSelected: (bool _) => setState(() => language = e.key),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('زمرہ', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            CategoryPicker(selected: categoryId, onChanged: (String id) => setState(() => categoryId = id)),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error, style: const TextStyle(color: kRed, height: 1.6)),
              ),
            if (busy && !editing) ...<Widget>[
              const SizedBox(height: 16),
              const Text('اپلوڈ ہو رہی ہے، ایپ بند نہ کریں...'),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: progress),
              if (progress != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${(progress! * 100).round()}%'),
                ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: busy ? null : _save,
              icon: const Icon(Icons.cloud_upload),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(editing ? 'محفوظ کریں' : 'اپلوڈ کریں', style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
//  Add / edit a post (hadith, dua, zikr, masla, article)
// =====================================================================

class PostForm extends StatefulWidget {
  final Post? post;
  final String initialKind;
  final String initialSection;
  final String initialSource;
  const PostForm({super.key, this.post, this.initialKind = 'article', this.initialSection = '', this.initialSource = ''});

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  late final TextEditingController title;
  late final TextEditingController number;
  late final TextEditingController source;
  late final TextEditingController arabic;
  late final TextEditingController body;
  String kind = 'article';
  String categoryId = '';
  String section = '';
  bool busy = false;
  String error = '';

  bool get editing => widget.post != null;

  @override
  void initState() {
    super.initState();
    final Post? p = widget.post;
    title = TextEditingController(text: p?.title ?? '');
    number = TextEditingController(text: p?.number ?? '');
    source = TextEditingController(text: p?.source ?? widget.initialSource);
    arabic = TextEditingController(text: p?.arabic ?? '');
    body = TextEditingController(text: p?.body ?? '');
    kind = p?.kind ?? widget.initialKind;
    categoryId = p?.categoryId ?? '';
    section = p?.section ?? widget.initialSection;
  }

  @override
  void dispose() {
    title.dispose();
    number.dispose();
    source.dispose();
    arabic.dispose();
    body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (title.text.trim().isEmpty) {
      setState(() => error = 'عنوان لکھیں');
      return;
    }
    if (arabic.text.trim().isEmpty && body.text.trim().isEmpty) {
      setState(() => error = 'متن لکھیں (عربی متن یا ترجمہ/تحریر)');
      return;
    }
    setState(() {
      busy = true;
      error = '';
    });
    final Map<String, String> f = <String, String>{
      'kind': kind,
      'title': title.text.trim(),
      'arabic': arabic.text.trim(),
      'body': body.text.trim(),
      'number': number.text.trim(),
      'source': source.text.trim(),
      'category_id': categoryId,
      'section': (kind == 'dua' || kind == 'zikr') ? section : '',
    };
    try {
      if (editing) {
        await lib.updatePost(widget.post!.id, f);
      } else {
        await lib.addPost(f);
      }
      if (mounted) {
        Navigator.pop(context);
        snack(context, editing ? 'تبدیلی محفوظ ہو گئی' : 'تحریر شامل ہو گئی');
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) setState(() => error = 'تحریر محفوظ نہیں ہو سکی');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(editing ? 'تحریر میں ترمیم' : 'نئی تحریر'),
      body: AbsorbPointer(
        absorbing: busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text('قسم', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: kKinds.entries
                  .map((MapEntry<String, String> e) => ChoiceChip(
                        label: Text(e.value),
                        selected: kind == e.key,
                        onSelected: (bool _) => setState(() => kind = e.key),
                      ))
                  .toList(),
            ),
            if (kind == 'dua' || kind == 'zikr') ...<Widget>[
              const SizedBox(height: 14),
              const Text('دعا کا حصہ', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  ChoiceChip(
                    label: const Text('کوئی نہیں (عمومی)'),
                    selected: section.isEmpty,
                    onSelected: (bool _) => setState(() => section = ''),
                  ),
                  ...kDuaCats.entries.map((MapEntry<String, String> e) => ChoiceChip(
                        label: Text(e.value),
                        selected: section == e.key,
                        onSelected: (bool _) => setState(() => section = e.key),
                      )),
                ],
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: title,
              decoration: InputDecoration(
                labelText: tr('عنوان'),
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: number,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: tr('حدیث نمبر (اختیاری)'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: source,
                    decoration: InputDecoration(
                      labelText: tr('ماخذ / کتاب (اختیاری)'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: arabic,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: tr('عربی متن (اختیاری)'),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: body,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: tr('ترجمہ / مضمون / مسئلہ'),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('زمرہ', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            CategoryPicker(selected: categoryId, onChanged: (String id) => setState(() => categoryId = id)),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error, style: const TextStyle(color: kRed, height: 1.6)),
              ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: busy ? null : _save,
              icon: busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Icon(Icons.save),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('محفوظ کریں', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
//  Manage categories
// =====================================================================

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Future<void> _run(BuildContext context, Future<void> Function() job) async {
    try {
      await job();
    } on ApiException catch (e) {
      if (context.mounted) snack(context, e.message);
    } catch (_) {
      if (context.mounted) snack(context, 'کام مکمل نہیں ہو سکا');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lib,
      builder: (BuildContext context, Widget? _) {
        return Scaffold(
          appBar: appBar('زمرے سنبھالیں'),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('نیا زمرہ'),
            onPressed: () async {
              final String? n = await promptText(context, 'نئے زمرے کا نام');
              if (n != null && n.isNotEmpty && context.mounted) {
                await _run(context, () => lib.addCategory(n));
              }
            },
          ),
          body: lib.categories.isEmpty
              ? const EmptyState(Icons.folder_outlined, 'کوئی زمرہ نہیں۔ نیچے والے بٹن سے بنائیں۔')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                  itemCount: lib.categories.length,
                  itemBuilder: (BuildContext context, int i) {
                    final LibCategory c = lib.categories[i];
                    final int used = lib.booksIn(c.id).length + lib.postsIn(c.id).length;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: kLight,
                          child: Icon(categoryIcon(c.id), color: kGreen),
                        ),
                        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(tf('%s اندراجات', <Object>[used])),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final String? n = await promptText(context, 'زمرے کا نام بدلیں', initial: c.name);
                                if (n != null && n.isNotEmpty && context.mounted) {
                                  await _run(context, () => lib.renameCategory(c.id, n));
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: kRed),
                              onPressed: () async {
                                final bool ok = await confirmDialog(
                                  context,
                                  'زمرہ حذف کریں',
                                  used > 0
                                      ? tf('اس زمرے کی %s کتابیں/تحریریں حذف نہیں ہوں گی، وہ "متفرق" میں چلی جائیں گی۔ زمرہ حذف کریں؟', <Object>[used])
                                      : 'کیا یہ زمرہ حذف کریں؟',
                                );
                                if (ok && context.mounted) {
                                  await _run(context, () => lib.deleteCategory(c.id));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
