import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'common.dart';
import 'i18n.dart';
import 'settings.dart';
import 'userdata.dart';

class TasbeehListScreen extends StatelessWidget {
  const TasbeehListScreen({super.key});

  Future<void> _addCustom(BuildContext context) async {
    final TextEditingController name = TextEditingController();
    final TextEditingController target = TextEditingController(text: '100');
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('اپنی تسبیح بنائیں'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(controller: name, decoration: InputDecoration(labelText: tr('تسبیح / ذکر کا نام'))),
            const SizedBox(height: 10),
            TextField(
              controller: target,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: tr('ہدف (تعداد)')),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('منسوخ')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('محفوظ کریں')),
        ],
      ),
    );
    final String n = name.text.trim();
    final int t = int.tryParse(target.text.trim()) ?? 0;
    if (ok == true && n.isNotEmpty) {
      ud.addCustom(n, t <= 0 ? 33 : t);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ud,
      builder: (BuildContext context, Widget? _) {
        final List<TasbeehItem> items = ud.allTasbeeh;
        return Scaffold(
          appBar: appBar('ڈیجیٹل تسبیح', actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: tr('روزانہ کا ریکارڈ'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (BuildContext _) => const TasbeehHistoryScreen()),
              ),
            ),
          ]),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addCustom(context),
            icon: const Icon(Icons.add),
            label: const Text('اپنی تسبیح'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            children: <Widget>[
              Card(
                color: kLight,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.today, color: kGreen),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tf('آج کی کل گنتی: %s', <Object>[ud.todayTotal()]),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ...items.map((TasbeehItem t) {
                final int c = ud.countOf(t.id);
                final double p = t.target > 0 ? (c % t.target) / t.target : 0;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 6, 6, 6),
                    title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (t.arabic.isNotEmpty)
                          Text(t.arabic, style: TextStyle(color: kMuted, fontSize: 15, height: 1.8)),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(value: p, minHeight: 5),
                        const SizedBox(height: 4),
                        Text(tf('گنتی %s  •  ہدف %s', <Object>[c, t.target]),
                            style: TextStyle(color: kMuted, fontSize: 12)),
                      ],
                    ),
                    trailing: t.custom
                        ? IconButton(
                            icon: const Icon(Icons.delete_outline, color: kRed),
                            onPressed: () async {
                              final bool ok = await confirmDialog(
                                  context, 'تسبیح حذف کریں', 'یہ تسبیح اور اس کی گنتی حذف ہو جائے گی۔ کیا آپ حذف کرنا چاہتے ہیں؟');
                              if (ok) ud.removeCustom(t.id);
                            },
                          )
                        : Icon(kChevron),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (BuildContext _) => TasbeehCounterScreen(id: t.id)),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class TasbeehCounterScreen extends StatelessWidget {
  final String id;
  const TasbeehCounterScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final TasbeehItem? t = ud.tasbeehById(id);
    if (t == null) {
      return Scaffold(appBar: appBar('ڈیجیٹل تسبیح'), body: const EmptyState(Icons.auto_awesome, 'یہ تسبیح موجود نہیں۔'));
    }
    return AnimatedBuilder(
      animation: ud,
      builder: (BuildContext context, Widget? _) {
        final int c = ud.countOf(id);
        final int round = t.target > 0 ? c ~/ t.target : 0;
        final int inRound = t.target > 0 ? c % t.target : c;
        return Scaffold(
          appBar: appBar(t.name, actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: tr('ایک کم کریں'),
              onPressed: () => ud.undo(id),
            ),
            IconButton(
              icon: const Icon(Icons.restart_alt),
              tooltip: tr('ری سیٹ'),
              onPressed: () async {
                final bool ok = await confirmDialog(context, 'ری سیٹ', 'کیا گنتی صفر کر دی جائے؟');
                if (ok) ud.resetCount(id);
              },
            ),
          ]),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 14),
                if (t.arabic.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      t.arabic,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26, height: 1.9, color: kDark),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  tf('ہدف %s  •  مکمل چکر %s  •  آج %s', <Object>[t.target, round, ud.todayOf(id)]),
                  style: TextStyle(color: kMuted),
                ),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        ud.tap(id);
                        final int n = ud.countOf(id);
                        if (t.target > 0 && n % t.target == 0) {
                          HapticFeedback.heavyImpact();
                        } else {
                          HapticFeedback.selectionClick();
                        }
                      },
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[Color(0xFF117A63), Color(0xFF073B30)],
                          ),
                          border: Border.all(color: kGold, width: 4),
                          boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black26, blurRadius: 14, offset: Offset(0, 6))],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('$inRound',
                                style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold)),
                            Text(tf('کل %s', <Object>[c]), style: const TextStyle(color: Color(0xFFD7EBE4), fontSize: 15)),
                            const SizedBox(height: 4),
                            const Icon(Icons.touch_app, color: kGold, size: 28),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text('گننے کے لیے دائرے کو دبائیں'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TasbeehHistoryScreen extends StatelessWidget {
  const TasbeehHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ud,
      builder: (BuildContext context, Widget? _) {
        final List<String> days = ud.daily.keys.toList()..sort((String a, String b) => b.compareTo(a));
        return Scaffold(
          appBar: appBar('روزانہ کا ریکارڈ', actions: <Widget>[
            if (days.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () async {
                  final bool ok = await confirmDialog(context, 'ریکارڈ صاف کریں', 'روزانہ کا سارا ریکارڈ مٹا دیا جائے؟');
                  if (ok) ud.clearDaily();
                },
              ),
          ]),
          body: days.isEmpty
              ? const EmptyState(Icons.insights, 'ابھی کوئی ریکارڈ نہیں۔ تسبیح پڑھنا شروع کریں۔')
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: days.length,
                  itemBuilder: (BuildContext context, int i) {
                    final String day = days[i];
                    final Map<String, int> m = ud.daily[day] ?? <String, int>{};
                    int total = 0;
                    final List<String> lines = <String>[];
                    m.forEach((String k, int v) {
                      if (v <= 0) return;
                      total += v;
                      final TasbeehItem? t = ud.tasbeehById(k);
                      lines.add('${t == null ? '' : tr(t.name)}: $v');
                    });
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: kLight, child: Icon(Icons.event, color: kGreen)),
                        title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(lines.join('  •  '), style: const TextStyle(height: 1.6)),
                        trailing: Text('$total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kGreen)),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
