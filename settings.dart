import 'package:flutter/material.dart';
import 'local.dart';

/// App-wide look and language choices, saved on the phone.
class Settings extends ChangeNotifier {
  String lang = 'ur'; // ur | ar | en
  String theme = 'light'; // auto | light | dark
  double fontScale = 1.0;

  bool get rtl => lang != 'en';

  bool get dark {
    if (theme == 'dark') return true;
    if (theme == 'light') return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  ThemeMode get themeMode =>
      theme == 'dark' ? ThemeMode.dark : (theme == 'light' ? ThemeMode.light : ThemeMode.system);

  Future<void> load() async {
    final dynamic j = await Local.readJson('settings.json');
    if (j is Map) {
      final String l = (j['lang'] ?? 'ur').toString();
      if (l == 'ur' || l == 'ar' || l == 'en') lang = l;
      final String t = (j['theme'] ?? 'light').toString();
      if (t == 'auto' || t == 'light' || t == 'dark') theme = t;
      final dynamic f = j['font'];
      if (f is num) fontScale = f.toDouble().clamp(0.8, 1.6).toDouble();
    }
  }

  void _save() {
    Local.writeJson('settings.json', <String, dynamic>{'lang': lang, 'theme': theme, 'font': fontScale});
    notifyListeners();
  }

  void setLang(String v) {
    lang = v;
    _save();
  }

  void setTheme(String v) {
    theme = v;
    _save();
  }

  void setFont(double v) {
    fontScale = v;
    _save();
  }
}

final Settings settings = Settings();
