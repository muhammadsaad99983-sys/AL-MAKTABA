import 'package:flutter/material.dart' hide Text;
import 'common.dart';
import 'config.dart';
import 'i18n.dart';
import 'settings.dart';
import 'state.dart';
import 'ui_home.dart';
import 'userdata.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await settings.load();
  await ud.load();
  await lib.init();
  runApp(const MaktabaApp());
}

class MaktabaApp extends StatefulWidget {
  const MaktabaApp({super.key});

  @override
  State<MaktabaApp> createState() => _MaktabaAppState();
}

class _MaktabaAppState extends State<MaktabaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    settings.addListener(_changed);
  }

  @override
  void dispose() {
    settings.removeListener(_changed);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (settings.theme == 'auto') _changed();
  }

  void _changed() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => rebuildEverything());
  }

  ThemeData _theme(Brightness b) {
    final bool dark = b == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0B5D4B),
        brightness: b,
        primary: dark ? const Color(0xFF4DB59A) : const Color(0xFF0B5D4B),
      ),
      scaffoldBackgroundColor: dark ? const Color(0xFF0F1B18) : const Color(0xFFF6F4EC),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF172622) : Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'المکتبۃ الآفتابیہ',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: settings.themeMode,
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData mq = MediaQuery.of(context);
        final bool wide = mq.size.width > 820;
        Widget body = child ?? const SizedBox();
        if (wide) {
          body = ColoredBox(
            color: kBg,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 780), child: body),
            ),
          );
        }
        return Directionality(
          textDirection: settings.rtl ? TextDirection.rtl : TextDirection.ltr,
          child: MediaQuery(
            data: mq.copyWith(textScaler: TextScaler.linear(settings.fontScale)),
            child: body,
          ),
        );
      },
      home: Config.isConfigured ? const HomeShell() : const SetupNeededScreen(),
    );
  }
}

class SetupNeededScreen extends StatelessWidget {
  const SetupNeededScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('سیٹ اپ باقی ہے'),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'ایپ کی config.dart فائل میں Supabase کا URL اور key ابھی نہیں لکھی گئی۔\n\n'
            'GitHub میں config.dart کھول کر دونوں قدریں لکھیں اور Commit کریں، پھر نئی APK بنے گی۔',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.9),
          ),
        ),
      ),
    );
  }
}
