class Config {
  static const String supabaseUrl = 'https://hjjvtzlyzmclfgtxivkp.supabase.co';

  static const String supabaseKey = 'sb_publishable_hvsuIBI_Ej86mZQX7325bg_iZOb-rvx';

  static const String bucket = 'books';

  // Shown on the About screen. Write your phone / WhatsApp / email.
  static const String contact = '';

  // Link of your privacy policy page (needed for Play Store). Optional here.
  static const String privacyUrl = '';

  static bool get isConfigured =>
      supabaseUrl.startsWith('https://') &&
      !supabaseUrl.contains('YOUR_') &&
      supabaseKey.length > 20 &&
      !supabaseKey.contains('YOUR_');

  static String get baseUrl {
    String u = supabaseUrl.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }
}
