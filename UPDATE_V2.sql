-- المکتبۃ الآفتابیہ : اپڈیٹ 2 (اعلانات اور شکایات)
-- Supabase > SQL Editor میں پورا چپکا کر Run کریں۔ دوبارہ چلانے سے کوئی نقصان نہیں۔

create table if not exists public.announcements (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  body        text not null default '',
  created_at  timestamptz not null default now()
);

create table if not exists public.feedback (
  id          uuid primary key default gen_random_uuid(),
  kind        text not null default 'complaint',
  message     text not null,
  contact     text not null default '',
  created_at  timestamptz not null default now()
);

alter table public.announcements enable row level security;
alter table public.feedback      enable row level security;

drop policy if exists "read announcements"  on public.announcements;
drop policy if exists "write announcements" on public.announcements;
drop policy if exists "send feedback"       on public.feedback;
drop policy if exists "owner reads feedback"   on public.feedback;
drop policy if exists "owner deletes feedback" on public.feedback;

create policy "read announcements" on public.announcements
  for select to anon, authenticated using (true);
create policy "write announcements" on public.announcements
  for all to authenticated using (true) with check (true);

create policy "send feedback" on public.feedback
  for insert to anon, authenticated
  with check (char_length(message) between 1 and 3000);
create policy "owner reads feedback" on public.feedback
  for select to authenticated using (true);
create policy "owner deletes feedback" on public.feedback
  for delete to authenticated using (true);

grant select on public.announcements to anon, authenticated;
grant insert, update, delete on public.announcements to authenticated;
grant insert on public.feedback to anon, authenticated;
grant select, delete on public.feedback to authenticated;
