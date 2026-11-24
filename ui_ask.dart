import 'dart:math' as math;
import 'package:flutter/material.dart' hide Text;
import 'api.dart';
import 'common.dart';
import 'i18n.dart';
import 'local.dart';

/// Secret random id of this phone. Only this phone can read its own answers.
String? _deviceId;

Future<String> deviceId() async {
  final String? cached = _deviceId;
  if (cached != null) return cached;
  String id = '';
  final dynamic j = await Local.readJson('askdev.json');
  if (j is Map && j['id'] is String && (j['id'] as String).length >= 16) {
    id = j['id'] as String;
  }
  if (id.isEmpty) {
    final math.Random r = math.Random.secure();
    id = List<String>.generate(32, (int _) => r.nextInt(16).toRadixString(16)).join();
    await Local.writeJson('askdev.json', <String, dynamic>{'id': id});
  }
  _deviceId = id;
  return id;
}

String _fmt(dynamic v) {
  final DateTime? d = DateTime.tryParse((v ?? '').toString())?.toLocal();
  if (d == null) return '';
  String two(int n) => n < 10 ? '0$n' : '$n';
  return '${d.year}-${two(d.month)}-${two(d.day)}  ${two(d.hour)}:${two(d.minute)}';
}

class AskScreen extends StatefulWidget {
  const AskScreen({super.key});

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  final TextEditingController q = TextEditingController();
  final TextEditingController name = TextEditingController();
  List<dynamic> items = <dynamic>[];
  bool loading = true;
  bool busy = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    q.dispose();
    name.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      List<dynamic> list;
      if (Api.isAdmin) {
        list = await Api.getListAuth('questions');
        list.sort((dynamic a, dynamic b) {
          final bool aa = (a['answer'] ?? '').toString().isNotEmpty;
          final bool bb = (b['answer'] ?? '').toString().isNotEmpty;
          if (aa != bb) return aa ? 1 : -1;
          return 0;
        });
      } else {
        final dynamic r = await Api.rpc('my_questions', <String, dynamic>{'p_device': await deviceId()});
        list = r is List ? r : <dynamic>[];
      }
      if (!mounted) return;
      setState(() {
        items = list;
        loading = false;
        error = '';
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'فہرست نہیں کھل سکی';
        });
      }
    }
  }

  Future<void> _send() async {
    final String t = q.text.trim();
    if (t.isEmpty) {
      setState(() => error = 'اپنا سوال لکھیں');
      return;
    }
    setState(() {
      busy = true;
      error = '';
    });
    try {
      await Api.rpc('ask_question', <String, dynamic>{
        'p_device': await deviceId(),
        'p_name': name.text.trim(),
        'p_question': t,
      });
      q.clear();
      if (mounted) snack(context, 'آپ کا سوال بھیج دیا گیا۔ جواب اسی صفحے پر آئے گا۔');
      await _load();
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) setState(() => error = 'سوال نہیں بھیجا جا سکا');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _answer(dynamic row) async {
    final String? a = await promptText(context, 'جواب لکھیں', initial: (row['answer'] ?? '').toString());
    if (a == null) return;
    try {
      await Api.update('questions', row['id'].toString(), <String, dynamic>{
        'answer': a.trim(),
        'answered_at': a.trim().isEmpty ? null : DateTime.now().toUtc().toIso8601String(),
      });
      if (mounted) snack(context, 'جواب محفوظ ہو گیا');
      await _load();
    } on ApiException catch (e) {
      if (mounted) snack(context, e.message);
    } catch (_) {
      if (mounted) snack(context, 'جواب محفوظ نہیں ہو سکا');
    }
  }

  Future<void> _delete(dynamic row) async {
    final bool ok = await confirmDialog(context, 'سوال حذف کریں', 'کیا یہ سوال حذف کریں؟');
    if (!ok) return;
    try {
      await Api.deleteRow('questions', row['id'].toString());
      await _load();
    } catch (_) {
      if (mounted) snack(context, 'حذف نہیں ہو سکا');
    }
  }

  Widget _card(dynamic row) {
    final String qs = (row['question'] ?? '').toString();
    final String an = (row['answer'] ?? '').toString();
    final String who = (row['name'] ?? '').toString();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: an.isEmpty ? Colors.black12 : const Color(0xFF2E9E6E)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.help_outline, color: Color(0xFFE08A1E), size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(Api.isAdmin && who.isNotEmpty ? who : tr('سوال'),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              Text(_fmt(row['created_at']), style: TextStyle(color: kMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(qs, style: const TextStyle(fontSize: 16, height: 1.8)),
          const Divider(height: 22),
          if (an.isEmpty)
            Text('جواب کا انتظار ہے...', style: TextStyle(color: kMuted))
          else ...<Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.check_circle, color: Color(0xFF2E9E6E), size: 20),
                const SizedBox(width: 6),
                const Text('جواب', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E9E6E))),
              ],
            ),
            const SizedBox(height: 6),
            Text(an, style: const TextStyle(fontSize: 16, height: 1.9)),
          ],
          if (Api.isAdmin)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton.icon(
                  onPressed: () => _answer(row),
                  icon: const Icon(Icons.reply, size: 18),
                  label: Text(an.isEmpty ? 'جواب دیں' : 'جواب بدلیں'),
                ),
                IconButton(icon: const Icon(Icons.delete_outline, color: kRed), onPressed: () => _delete(row)),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(Api.isAdmin ? 'لوگوں کے سوالات' : 'سوال پوچھیں'),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: <Widget>[
            if (!Api.isAdmin) ...<Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFE3F4EC), borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  'آپ کا سوال صرف مکتبے کے مالک تک پہنچتا ہے۔ جواب بھی صرف آپ کو نظر آئے گا، کسی اور کو نہیں۔',
                  style: TextStyle(height: 1.8, color: Color(0xFF0B3D2E)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: name,
                decoration: InputDecoration(labelText: tr('آپ کا نام (اختیاری)'), border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: q,
                maxLines: 5,
                maxLength: 2000,
                decoration: InputDecoration(labelText: tr('آپ کا سوال'), border: const OutlineInputBorder()),
              ),
              if (error.isNotEmpty) Text(error, style: const TextStyle(color: kRed)),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: busy ? null : _send,
                icon: busy
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: const Text('سوال بھیجیں'),
              ),
              const SizedBox(height: 18),
              const SectionTitle('میرے سوالات اور جوابات'),
            ] else if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: kRed)),
            if (loading)
              const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator()))
            else if (items.isEmpty)
              const Padding(padding: EdgeInsets.only(top: 20), child: EmptyState(Icons.question_answer_outlined, 'ابھی کوئی سوال نہیں۔'))
            else
              for (final dynamic row in items) _card(row),
          ],
        ),
      ),
    );
  }
}
