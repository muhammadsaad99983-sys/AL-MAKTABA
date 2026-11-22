import 'package:flutter/material.dart' hide Text;
import 'package:flutter/material.dart' as m show Text;
import 'i18n_data.dart';
import 'settings.dart';

/// Translates an Urdu UI string into the chosen app language.
/// Urdu is the source language, so Urdu returns the text unchanged.
String tr(String ur) {
  final String l = settings.lang;
  if (l == 'ur') return ur;
  final Map<String, String> d = l == 'ar' ? kAr : kEn;
  return d[ur] ?? ur;
}

/// Same as tr(), then replaces every %s with the given values in order.
String tf(String key, List<Object?> args) {
  String s = tr(key);
  for (final Object? a in args) {
    s = s.replaceFirst('%s', '$a');
  }
  return s;
}

/// Drop-in replacement for Flutter's Text that translates automatically.
class Text extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const Text(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context) {
    return m.Text(
      tr(data),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

/// Forces every widget to rebuild (used after language / theme changes).
void rebuildEverything() {
  final Element? root = WidgetsBinding.instance.rootElement;
  if (root == null) return;
  void visit(Element e) {
    e.markNeedsBuild();
    e.visitChildren(visit);
  }

  root.visitChildren(visit);
}
