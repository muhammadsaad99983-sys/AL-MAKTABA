# المکتبۃ الآفتابیہ (Al-Maktaba Al-Aftabia)

Islamic digital library app (Flutter). Everyone can read, search and download
books; only the owner (Supabase login) can add or delete books and articles.
No Flutter plugins are used. The APK is built by GitHub Actions
(`.github/workflows/build.yml`). Before the first build:

1. Run `SUPABASE_SETUP.sql` in the Supabase SQL Editor.
2. Put your Supabase URL and key into `config.dart`.
