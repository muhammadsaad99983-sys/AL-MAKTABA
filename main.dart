import 'package:flutter/material.dart';
import 'common.dart';
import 'config.dart';
import 'state.dart';
import 'ui_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await lib.init();
  runApp(const MaktabaApp());
}

class MaktabaApp extends StatelessWidget {
  const MaktabaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'المکتبۃ الآفتابیہ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kGreen, primary: kGreen),
        scaffoldBackgroundColor: kBg,
      ),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
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
