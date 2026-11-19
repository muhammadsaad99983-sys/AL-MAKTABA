/// ============================================================
///  ONLY THIS FILE NEEDS YOUR OWN VALUES.
///  Replace the two lines marked (1) and (2) with the values
///  from your Supabase project (Project Settings -> API).
///  Keep the single quotes. Do not add spaces inside them.
/// ============================================================
class Config {
  // (1) Project URL, looks like: https://abcdefgh.supabase.co
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';

  // (2) The "anon" / "publishable" key (a long text)
  static const String supabaseKey = 'YOUR_SUPABASE_ANON_KEY';

  // Name of the storage bucket created by SUPABASE_SETUP.sql
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
