/// Makes Urdu / Arabic text comparable: removes diacritics, unifies
/// look-alike letters and converts all digits to 0-9.
String normalizeText(String input) {
  final StringBuffer b = StringBuffer();
  for (final int r in input.runes) {
    // diacritics, tatweel, zero-width marks
    if ((r >= 0x064B && r <= 0x065F) ||
        r == 0x0670 ||
        r == 0x0640 ||
        r == 0x200C ||
        r == 0x200D) {
      continue;
    }
    // Arabic-Indic digits
    if (r >= 0x0660 && r <= 0x0669) {
      b.writeCharCode(0x30 + (r - 0x0660));
      continue;
    }
    // Extended Arabic-Indic (Urdu) digits
    if (r >= 0x06F0 && r <= 0x06F9) {
      b.writeCharCode(0x30 + (r - 0x06F0));
      continue;
    }
    int c = r;
    if (c == 0x064A || c == 0x0649 || c == 0x06D0 || c == 0x06D2 || c == 0x06CC) {
      c = 0x06CC; // ی
    } else if (c == 0x0643) {
      c = 0x06A9; // ک
    } else if (c == 0x0629 || c == 0x06C3 || c == 0x0647 || c == 0x06BE || c == 0x06C1) {
      c = 0x06C1; // ہ
    } else if (c == 0x0623 || c == 0x0625 || c == 0x0622 || c == 0x0671) {
      c = 0x0627; // ا
    }
    b.writeCharCode(c);
  }
  return b.toString().toLowerCase();
}

List<String> tokensOf(String query) {
  final String n = normalizeText(query).trim();
  if (n.isEmpty) return <String>[];
  return n.split(RegExp(r'\s+')).where((String t) => t.isNotEmpty).toList();
}

bool containsAll(String normalizedHaystack, List<String> tokens) {
  for (final String t in tokens) {
    if (!normalizedHaystack.contains(t)) return false;
  }
  return true;
}

/// True when the stored hadith number contains exactly the number typed.
bool numberMatches(String storedNumber, String typed) {
  final String q = normalizeText(typed).trim();
  if (q.isEmpty) return false;
  final String s = normalizeText(storedNumber);
  for (final RegExpMatch m in RegExp(r'\d+').allMatches(s)) {
    if (m.group(0) == q) return true;
  }
  return false;
}
