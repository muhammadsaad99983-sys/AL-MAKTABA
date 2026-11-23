import 'package:flutter/material.dart' hide Text;
import 'i18n.dart';
import 'settings.dart';
import 'models.dart';
import 'settings.dart';
import 'state.dart';

const Color kGold = Color(0xFFC8962A);
const Color kRed = Color(0xFFC62828);

// Colours that change between light and dark mode.
bool get _dk => settings.dark;
Color get kGreen => _dk ? const Color(0xFF4DB59A) : const Color(0xFF0B5D4B);
Color get kBar => _dk ? const Color(0xFF0E3B31) : const Color(0xFF0B5D4B);
Color get kDark => _dk ? const Color(0xFFE6F0EC) : const Color(0xFF073B30);
Color get kBg => _dk ? const Color(0xFF0F1B18) : const Color(0xFFF6F4EC);
Color get kLight => _dk ? const Color(0xFF1D3A33) : const Color(0xFFE3F1EC);
Color get kCardBg => _dk ? const Color(0xFF172622) : const Color(0xFFFFFFFF);
Color get kMuted => _dk ? const Color(0xFFB4C2BD) : const Color(0xFF616161);
Color get kFaint => _dk ? const Color(0xFF5E6F69) : const Color(0xFFBDBDBD);
Color get kText => _dk ? const Color(0xFFE9EEEC) : const Color(0xFF212121);
Color get kWarm => _dk ? const Color(0xFF2B2A1C) : const Color(0xFFFFF8E1);
Color get kNoteBg => _dk ? const Color(0xFF3A2E1A) : const Color(0xFFFFF3E0);
IconData get kChevron => settings.rtl ? Icons.chevron_left : Icons.chevron_right;

void snack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

Future<bool> confirmDialog(BuildContext context, String title, String body) async {
  final bool? r = await showDialog<bool>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('نہیں')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ہاں')),
      ],
    ),
  );
  return r == true;
}

Future<String?> promptText(BuildContext context, String title, {String initial = ''}) async {
  final TextEditingController ctl = TextEditingController(text: initial);
  final String? r = await showDialog<String>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: Text(title),
      content: TextField(controller: ctl, autofocus: true),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('منسوخ')),
        FilledButton(onPressed: () => Navigator.pop(ctx, ctl.text.trim()), child: const Text('محفوظ کریں')),
      ],
    ),
  );
  return r;
}

PreferredSizeWidget appBar(String title, {List<Widget>? actions, PreferredSizeWidget? bottom}) {
  return AppBar(
    title: Text(title),
    backgroundColor: kBar,
    foregroundColor: Colors.white,
    actions: actions,
    bottom: bottom,
  );
}

IconData categoryIcon(String id) {
  switch (id) {
    case 'hadith':
      return Icons.format_quote;
    case 'dua':
      return Icons.volunteer_activism;
    case 'azkar':
      return Icons.auto_awesome;
    case 'quran':
      return Icons.menu_book;
    case 'fiqh':
      return Icons.balance;
    case 'seerat':
      return Icons.mosque;
    case 'aqaid':
      return Icons.lightbulb_outline;
    case 'tarikh':
      return Icons.history_edu;
    case 'akhlaq':
      return Icons.favorite_outline;
    case 'bachon':
      return Icons.child_care;
    case 'mazameen':
      return Icons.article;
    default:
      return Icons.folder_outlined;
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  const Pill(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(32),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const EmptyState(this.icon, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 60, color: kFaint),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: kMuted, fontSize: 15, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final VoidCallback? onMore;
  const SectionTitle(this.text, {super.key, this.onMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 14, 2, 8),
      child: Row(
        children: <Widget>[
          Container(width: 4, height: 20, color: kGold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kDark)),
          ),
          if (onMore != null) TextButton(onPressed: onMore, child: const Text('سب دیکھیں')),
        ],
      ),
    );
  }
}

class NoticeBanner extends StatelessWidget {
  final String text;
  final VoidCallback? onRetry;
  const NoticeBanner(this.text, {super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kNoteBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.cloud_off, color: Color(0xFFEF6C00)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(height: 1.6))),
          if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('دوبارہ')),
        ],
      ),
    );
  }
}

/// Row of choice chips, one of which is selected.
class ChipsRow extends StatelessWidget {
  final List<MapEntry<String, String>> items; // value -> label
  final String selected;
  final ValueChanged<String> onSelected;
  const ChipsRow({super.key, required this.items, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: items
            .map((MapEntry<String, String> e) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: selected == e.key,
                    onSelected: (bool _) => onSelected(e.key),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

/// LibCategory choice used in the admin forms.
class CategoryPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const CategoryPicker({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: <Widget>[
        ...lib.categories.map((LibCategory c) => ChoiceChip(
              label: Text(c.name),
              selected: selected == c.id,
              onSelected: (bool _) => onChanged(c.id),
            )),
        ChoiceChip(
          label: const Text('بغیر زمرہ'),
          selected: selected.isEmpty,
          onSelected: (bool _) => onChanged(''),
        ),
      ],
    );
  }
}

class BookTile extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  const BookTile({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final List<String> parts = <String>[];
    if (book.author.isNotEmpty) parts.add(book.author);
    parts.add(lib.categoryName(book.categoryId));
    final String size = formatSize(book.fileSize);
    if (size.isNotEmpty) parts.add(size);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 54,
          decoration: BoxDecoration(color: kLight, borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.picture_as_pdf, color: kGreen),
        ),
        title: Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, height: 1.5),
        ),
        subtitle: Text(parts.join('  •  '), maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: lib.isDownloaded(book.id)
            ? Icon(Icons.download_done, color: kGreen)
            : Icon(kChevron),
        onTap: onTap,
      ),
    );
  }
}

class PostTile extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  const PostTile({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final List<String> meta = <String>[];
    if (post.source.isNotEmpty) meta.add(post.source);
    if (post.number.isNotEmpty) meta.add('${tr('نمبر')} ${post.number}');
    final String preview = snippet(post.body.isNotEmpty ? post.body : post.arabic, 90);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Pill(kindLabel(post.kind), kGold),
                  const SizedBox(width: 8),
                  if (meta.isNotEmpty)
                    Expanded(
                      child: Text(
                        meta.join('  •  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: kMuted, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.5),
              ),
              if (preview.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: kMuted, height: 1.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
