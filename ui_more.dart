import 'package:flutter/material.dart' hide Text;
import 'i18n.dart';
import 'settings.dart';
import 'api.dart';
import 'common.dart';
import 'config.dart';
import 'native.dart';
import 'state.dart';
import 'texts.dart';
import 'ui_admin.dart';
import 'ui_feedback.dart';
import 'ui_import.dart';
import 'ui_lists.dart';
import 'ui_settings.dart';
import 'ui_reader.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext _) => page));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lib,
      builder: (BuildContext context, Widget? _) {
        return Scaffold(
          appBar: appBar('مزید'),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: <Widget>[
              _Tile(
                icon: Icons.download_done,
                title: 'میری ڈاؤنلوڈ شدہ کتابیں',
                subtitle: tf('%s کتابیں، بغیر انٹرنیٹ پڑھیں', <Object>[lib.downloads.length]),
                onTap: () => _push(context, const DownloadsScreen()),
              ),
              _Tile(
                icon: Icons.favorite_border,
                title: 'پسندیدہ',
                subtitle: '',
                onTap: () => _push(context, const ListsScreen(recent: false)),
              ),
              _Tile(
                icon: Icons.history,
                title: 'حالیہ مطالعہ',
                subtitle: '',
                onTap: () => _push(context, const ListsScreen(recent: true)),
              ),
              _Tile(
                icon: Icons.notifications_none,
                title: 'اعلانات',
                subtitle: '',
                onTap: () => _push(context, const NewsScreen()),
              ),
              _Tile(
                icon: Icons.feedback_outlined,
                title: 'شکایت / تجویز',
                subtitle: 'ہمیں اپنی رائے بھیجیں',
                onTap: () => _push(context, const FeedbackScreen()),
              ),
              _Tile(
                icon: Icons.settings_outlined,
                title: 'سیٹنگز',
                subtitle: 'زبان، ڈارک موڈ، لکھائی کا سائز',
                onTap: () => _push(context, const SettingsScreen()),
              ),
              if (Api.isAdmin) ...<Widget>[
                const SectionTitle('ناظم کا پینل'),
                Card(
                  color: kWarm,
                  margin: const EdgeInsets.only(bottom: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.verified_user, color: kGold),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${tr('آپ ناظم کے طور پر لاگ اِن ہیں')}\n${Api.adminEmail}',
                            style: const TextStyle(height: 1.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _Tile(
                  icon: Icons.upload_file,
                  title: 'نئی کتاب (PDF) شامل کریں',
                  subtitle: 'فون سے PDF منتخب کر کے اپلوڈ کریں',
                  onTap: () => _push(context, const BookForm()),
                ),
                _Tile(
                  icon: Icons.library_add,
                  title: 'کئی PDF ایک ساتھ شامل کریں',
                  subtitle: 'فون سے ایک بار میں بہت سی کتابیں منتخب کریں',
                  onTap: () => startPickMany(context),
                ),
                _Tile(
                  icon: Icons.link,
                  title: 'لنک سے PDF شامل کریں',
                  subtitle: 'انٹرنیٹ پر موجود PDF کا لنک ڈالیں',
                  onTap: () => startUrlImport(context),
                ),
                _Tile(
                  icon: Icons.share,
                  title: 'دوسری ایپ سے شیئر کر کے شامل کریں',
                  subtitle: 'WhatsApp / فائلز / براؤزر میں PDF کو شیئر کریں اور اسلام 960 چنیں',
                  onTap: () => snack(context, 'کسی بھی ایپ میں PDF کھول کر Share دبائیں، پھر فہرست میں اسلام 960 چنیں'),
                ),
                _Tile(
                  icon: Icons.campaign,
                  title: 'اعلانات شائع کریں',
                  subtitle: 'سب صارفین کو اعلان دکھائیں',
                  onTap: () => _push(context, const NewsScreen()),
                ),
                _Tile(
                  icon: Icons.inbox,
                  title: 'صارفین کی شکایات',
                  subtitle: 'آنے والی شکایات اور تجاویز دیکھیں',
                  onTap: () => _push(context, const FeedbackAdminScreen()),
                ),
                _Tile(
                  icon: Icons.edit_note,
                  title: 'نئی تحریر / حدیث / دعا / مسئلہ',
                  subtitle: 'مضمون یا چھوٹا مسئلہ شامل کریں',
                  onTap: () => _push(context, const PostForm()),
                ),
                _Tile(
                  icon: Icons.folder_open,
                  title: 'زمرے سنبھالیں',
                  subtitle: 'نیا زمرہ بنائیں، نام بدلیں یا حذف کریں',
                  onTap: () => _push(context, const CategoriesScreen()),
                ),
                _Tile(
                  icon: Icons.logout,
                  title: 'ناظم لاگ آؤٹ',
                  subtitle: '',
                  onTap: () async {
                    final bool ok = await confirmDialog(context, 'لاگ آؤٹ', 'کیا آپ لاگ آؤٹ ہونا چاہتے ہیں؟');
                    if (ok) await lib.logout();
                  },
                ),
              ],
              const SectionTitle('ایپ'),
              _Tile(
                icon: Icons.info_outline,
                title: 'ہمارے بارے میں',
                subtitle: 'ورژن 3.0.0',
                onTap: () => _push(context, const AboutScreen()),
              ),
              _Tile(
                icon: Icons.privacy_tip_outlined,
                title: 'پرائیویسی پالیسی',
                subtitle: '',
                onTap: () => _push(context, const PrivacyScreen()),
              ),
              if (!Api.isAdmin)
                _Tile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'ناظم لاگ اِن',
                  subtitle: 'صرف مکتبے کے مالک کے لیے',
                  onTap: () => _push(context, const AdminLoginScreen()),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _Tile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: kLight, child: Icon(icon, color: kGreen)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        trailing: Icon(kChevron),
        onTap: onTap,
      ),
    );
  }
}

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lib,
      builder: (BuildContext context, Widget? _) {
        final List<DownloadInfo> items = lib.downloads.values.toList();
        return Scaffold(
          appBar: appBar('ڈاؤنلوڈ شدہ کتابیں'),
          body: items.isEmpty
              ? const EmptyState(
                  Icons.download_for_offline_outlined,
                  'ابھی کوئی کتاب ڈاؤنلوڈ نہیں کی۔\nکسی کتاب کے صفحے پر "ڈاؤنلوڈ کریں" دبائیں۔',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int i) {
                    final DownloadInfo d = items[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Icon(Icons.picture_as_pdf, color: kGreen, size: 32),
                        title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(d.author.isEmpty ? 'آف لائن دستیاب' : d.author),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: kRed),
                          onPressed: () async {
                            final bool ok = await confirmDialog(context, 'ہٹائیں', 'فون سے یہ کتاب ہٹا دی جائے؟');
                            if (ok) await lib.removeDownload(d.id);
                          },
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext _) =>
                                ReaderScreen(bookId: d.id, title: d.title, path: lib.localPath(d.id)),
                          ),
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

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('ہمارے بارے میں'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(color: kGreen, shape: BoxShape.circle),
              child: const Icon(Icons.wb_sunny, color: kGold, size: 54),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'اسلام 960',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kDark, height: 1.7),
            ),
          ),
          Center(child: Text('ورژن 3.0.0', style: TextStyle(color: kMuted))),
          const SizedBox(height: 16),
          const Text(kAboutText, style: TextStyle(fontSize: 16, height: 2.0)),
          if (Config.contact.isNotEmpty) ...<Widget>[
            const SectionTitle('رابطہ'),
            SelectableText(Config.contact, style: const TextStyle(fontSize: 16, height: 1.9)),
          ],
          if (Config.privacyUrl.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Native.openUrl(Config.privacyUrl),
              icon: const Icon(Icons.open_in_new),
              label: const Text('پرائیویسی پالیسی (ویب لنک)'),
            ),
          ],
        ],
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('پرائیویسی پالیسی'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const <Widget>[
          Text(kPrivacyText, style: TextStyle(fontSize: 16, height: 2.0)),
        ],
      ),
    );
  }
}
