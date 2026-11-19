-- =====================================================================
--  Al-Maktaba Al-Aftabia  -  one-time database setup
--  Supabase dashboard -> SQL Editor -> New query -> paste ALL of this
--  -> press RUN. It is safe to run twice.
-- =====================================================================

-- 1) Tables -----------------------------------------------------------

create table if not exists public.categories (
  id         text primary key,
  name       text not null,
  sort       integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.books (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  author      text not null default '',
  description text not null default '',
  category_id text references public.categories(id) on delete set null,
  file_path   text not null,
  file_size   bigint not null default 0,
  created_at  timestamptz not null default now()
);

create table if not exists public.posts (
  id          uuid primary key default gen_random_uuid(),
  kind        text not null default 'article',
  title       text not null,
  arabic      text not null default '',
  body        text not null default '',
  number      text not null default '',
  source      text not null default '',
  category_id text references public.categories(id) on delete set null,
  created_at  timestamptz not null default now()
);

-- 2) Security: everybody may READ, only the logged-in owner may WRITE --

alter table public.categories enable row level security;
alter table public.books      enable row level security;
alter table public.posts      enable row level security;

drop policy if exists "read categories" on public.categories;
drop policy if exists "write categories" on public.categories;
drop policy if exists "read books" on public.books;
drop policy if exists "write books" on public.books;
drop policy if exists "read posts" on public.posts;
drop policy if exists "write posts" on public.posts;

create policy "read categories" on public.categories
  for select to anon, authenticated using (true);
create policy "write categories" on public.categories
  for all to authenticated using (true) with check (true);

create policy "read books" on public.books
  for select to anon, authenticated using (true);
create policy "write books" on public.books
  for all to authenticated using (true) with check (true);

create policy "read posts" on public.posts
  for select to anon, authenticated using (true);
create policy "write posts" on public.posts
  for all to authenticated using (true) with check (true);

grant usage on schema public to anon, authenticated;
grant select on public.categories, public.books, public.posts to anon, authenticated;
grant insert, update, delete on public.categories, public.books, public.posts to authenticated;

-- 3) Storage bucket for the PDF files (public read) -------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('books', 'books', true, 52428800, array['application/pdf'])
on conflict (id) do update
  set public = true,
      file_size_limit = 52428800,
      allowed_mime_types = array['application/pdf'];

drop policy if exists "books public read" on storage.objects;
drop policy if exists "books owner upload" on storage.objects;
drop policy if exists "books owner update" on storage.objects;
drop policy if exists "books owner delete" on storage.objects;

create policy "books public read" on storage.objects
  for select to anon, authenticated using (bucket_id = 'books');
create policy "books owner upload" on storage.objects
  for insert to authenticated with check (bucket_id = 'books');
create policy "books owner update" on storage.objects
  for update to authenticated using (bucket_id = 'books') with check (bucket_id = 'books');
create policy "books owner delete" on storage.objects
  for delete to authenticated using (bucket_id = 'books');

-- 4) Starting categories (you can add / delete more inside the app) ---

insert into public.categories (id, name, sort) values
  ('hadith',   'حدیث',                 1),
  ('dua',      'دعائیں',               2),
  ('azkar',    'اذکار',                3),
  ('quran',    'قرآن اور تفسیر',       4),
  ('fiqh',     'فقہ و مسائل',          5),
  ('seerat',   'سیرتِ نبوی ﷺ',        6),
  ('aqaid',    'عقائد',                7),
  ('tarikh',   'تاریخ و سوانح',        8),
  ('akhlaq',   'اخلاق و آداب',         9),
  ('bachon',   'بچوں کے لیے',          10),
  ('mazameen', 'مضامین و مقالات',      11),
  ('other',    'متفرق',                12)
on conflict (id) do nothing;
