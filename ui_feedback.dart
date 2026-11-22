import 'package:flutter/material.dart' hide Text;
import 'api.dart';
import 'common.dart';
import 'i18n.dart';
import 'models.dart';
import 'settings.dart';
import 'state.dart';
import 'userdata.dart';

const Map<String, String> kFeedbackKinds = <String, String>{
  'complaint': 'شکایت',
  'suggestion': 'تجویز',
  'bug': 'ایپ میں خرابی',
};

// ---------------------------------------------------------------
//  announcements
// ---------------------------------------------------------------

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  void initState() {
    super.initState();
    final List<String> ids = lib.news.map((News n) => n.id).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) => ud.markSeen(ids));
  }

  Future<void> _add() async {
    final TextEditingController t = TextEditingController();
    final TextEditingController b = TextEditingController();
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('نیا اعلان'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(controller: t, decoration: InputDecoration(labelText: tr('عنوان'))),
              const SizedBox(height: 10),
              TextField(controller: b, maxLines: 4, decoration: InputDecoration(labelText: tr('تفصیل'))),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('منسوخ')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('شائع کریں')),
        ],
      ),
    );
    final String title = t.text.trim();
    final String body = b.text.trim();
    if (ok != true || title.isEmpty) return;
    try {
      await lib.addNews(title, body);
      if (mounted) snack(context, 'اعلان شائع ہو گیا');
    } on ApiException catch (e) {
      if (mounted) snack(context, e.message);
    } catch (_) {
      if (mounted) snack(context, 'کام مکمل نہیں ہو سکا');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lib,
      builder: (BuildContext context, Widget? _) {
        return Scaffold(
          appBar: appBar('اعلانات'),
          floatingActionButton: Api.isAdmin
              ? FloatingActionButton.extended(
                  onPressed: _add,
                  icon: const Icon(Icons.campaign),
                  label: const Text('نیا اعلان'),
                )
              : null,
          body: RefreshIndicator(
            onRefresh: lib.refresh,
            child: lib.news.isEmpty
                ? ListView(children: const <Widget>[SizedBox(height: 80), EmptyState(Icons.notifications_none, 'ابھی کوئی اعلان نہیں۔')])
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                    itemCount: lib.news.length,
                    itemBuilder: (BuildContext context, int i) {
                      final News n = lib.news[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(Icons.campaign, color: kGold),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.5)),
                                  ),
                                  if (Api.isAdmin)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: kRed),
                                      onPressed: () async {
                                        final bool ok = await confirmDialog(context, 'اعلان حذف کریں', 'کیا یہ اعلان حذف کریں؟');
                                        if (!ok) return;
                                        try {
                                          await lib.deleteNews(n.id);
                                        } catch (_) {
                                          if (context.mounted) snack(context, 'حذف نہیں ہو سکی');
                                        }
                                      },
                                    ),
                                ],
                              ),
                              if (n.body.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: SelectableText(n.body, style: TextStyle(height: 1.9, color: kText)),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(formatDate(n.createdAt), style: TextStyle(color: kMuted, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------
//  user: send a complaint / suggestion
// ---------------------------------------------------------------

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController msg = TextEditingController();
  final TextEditingController contact = TextEditingController();
  String kind = 'complaint';
  bool busy = false;
  String error = '';

  @override
  void dispose() {
    msg.dispose();
    contact.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String m = msg.text.trim();
    if (m.isEmpty) {
      setState(() => error = 'اپنا پیغام لکھیں');
      return;
    }
    setState(() {
      busy = true;
      error = '';
    });
    try {
      await Api.insertPublic('feedback', <String, dynamic>{
        'kind': kind,
        'message': m,
        'contact': contact.text.trim(),
      });
      if (mounted) {
        Navigator.pop(context);
        snack(context, 'آپ کا پیغام بھیج دیا گیا، شکریہ');
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) setState(() => error = 'پیغام نہیں بھیجا جا سکا');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('شکایت / تجویز'),
      body: AbsorbPointer(
        absorbing: busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text('اپنی شکایت، تجویز یا ایپ کی خرابی ہمیں بتائیں۔ یہ صرف مکتبے کے ناظم کو نظر آئے گی۔',
                style: TextStyle(height: 1.9)),
            const SizedBox(height: 12),
            ChipsRow(
              items: kFeedbackKinds.entries.toList(),
              selected: kind,
              onSelected: (String v) => setState(() => kind = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: msg,
              maxLines: 6,
              maxLength: 2000,
              decoration: InputDecoration(labelText: tr('آپ کا پیغام'), border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contact,
              decoration: InputDecoration(
                labelText: tr('رابطے کے لیے ای میل / فون (اختیاری)'),
                border: const OutlineInputBorder(),
              ),
            ),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(error, style: const TextStyle(color: kRed)),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _send,
              icon: busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Icon(Icons.send),
              label: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('بھیجیں')),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
//  admin: read complaints
// ---------------------------------------------------------------

class FeedbackAdminScreen extends StatefulWidget {
  const FeedbackAdminScreen({super.key});

  @override
  State<FeedbackAdminScreen> createState() => _FeedbackAdminScreenState();
}

class _FeedbackAdminScreenState extends State<FeedbackAdminScreen> {
  List<FeedbackItem> items = <FeedbackItem>[];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final List<dynamic> raw = await Api.getListAuth('feedback');
      items = raw
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> e) => FeedbackItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'ڈیٹا لوڈ نہیں ہو سکا';
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('صارفین کی شکایات', actions: <Widget>[
        IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
      ]),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Padding(padding: const EdgeInsets.all(16), child: NoticeBanner(error, onRetry: _load))
              : items.isEmpty
                  ? const EmptyState(Icons.inbox_outlined, 'ابھی کوئی شکایت یا تجویز نہیں آئی۔')
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int i) {
                        final FeedbackItem f = items[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Pill(kFeedbackKinds[f.kind] ?? 'شکایت', kGold),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(formatDate(f.createdAt), style: TextStyle(color: kMuted, fontSize: 12))),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: kRed),
                                      onPressed: () async {
                                        final bool ok = await confirmDialog(context, 'حذف کریں', 'کیا یہ پیغام حذف کریں؟');
                                        if (!ok) return;
                                        try {
                                          await Api.deleteRow('feedback', f.id);
                                          if (mounted) setState(() => items.removeWhere((FeedbackItem x) => x.id == f.id));
                                        } catch (_) {
                                          if (context.mounted) snack(context, 'حذف نہیں ہو سکی');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                SelectableText(f.message, style: TextStyle(height: 1.9, color: kText)),
                                if (f.contact.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: SelectableText('${tr('رابطہ')}: ${f.contact}', style: TextStyle(color: kMuted)),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
