import 'package:flutter/material.dart' hide Text;
import 'common.dart';
import 'i18n.dart';
import 'settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (BuildContext context, Widget? _) {
        return Scaffold(
          appBar: appBar('سیٹنگز'),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const SectionTitle('ایپ کی زبان'),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final MapEntry<String, String> e in const <String, String>{
                    'ur': 'اردو',
                    'ar': 'العربية',
                    'en': 'English',
                  }.entries)
                    ChoiceChip(
                      label: Text(e.value),
                      selected: settings.lang == e.key,
                      onSelected: (bool _) => settings.setLang(e.key),
                    ),
                ],
              ),
              const SectionTitle('ظاہری انداز'),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final MapEntry<String, String> e in const <String, String>{
                    'auto': 'خودکار',
                    'light': 'روشن (Light)',
                    'dark': 'تاریک (Dark)',
                  }.entries)
                    ChoiceChip(
                      label: Text(e.value),
                      selected: settings.theme == e.key,
                      onSelected: (bool _) => settings.setTheme(e.key),
                    ),
                ],
              ),
              const SectionTitle('لکھائی کا سائز'),
              Row(
                children: <Widget>[
                  const Icon(Icons.text_decrease),
                  Expanded(
                    child: Slider(
                      value: settings.fontScale,
                      min: 0.8,
                      max: 1.6,
                      divisions: 8,
                      label: '${(settings.fontScale * 100).round()}%',
                      onChanged: (double v) => settings.setFont(v),
                    ),
                  ),
                  const Icon(Icons.text_increase),
                ],
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nاسلام 960',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, height: 2, color: kDark),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => settings.setFont(1.0),
                icon: const Icon(Icons.restore),
                label: const Text('سائز پہلے جیسا کریں'),
              ),
            ],
          ),
        );
      },
    );
  }
}
