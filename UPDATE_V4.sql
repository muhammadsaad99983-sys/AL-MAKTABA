-- اسلام 960 - اپڈیٹ: نجی سوال و جواب
-- Supabase > SQL Editor میں پورا چسپاں کر کے Run دبائیں (ایک ہی بار)

create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  device text not null,
  name text not null default '',
  question text not null,
  answer text not null default '',
  created_at timestamptz not null default now(),
  answered_at timestamptz
);

alter table public.questions enable row level security;

drop policy if exists "owner manages questions" on public.questions;
create policy "owner manages questions" on public.questions
  for all to authenticated using (true) with check (true);

create or replace function public.ask_question(p_device text, p_name text, p_question text)
returns void language plpgsql security definer set search_path = public as $$
begin
  if length(coalesce(p_device, '')) < 16 or length(trim(coalesce(p_question, ''))) = 0 or length(p_question) > 2000 then
    raise exception 'bad input';
  end if;
  insert into public.questions(device, name, question)
  values (p_device, left(coalesce(p_name, ''), 60), trim(p_question));
end $$;

create or replace function public.my_questions(p_device text)
returns table(id uuid, question text, answer text, created_at timestamptz, answered_at timestamptz)
language sql security definer set search_path = public as $$
  select q.id, q.question, q.answer, q.created_at, q.answered_at
  from public.questions q
  where length(coalesce(p_device, '')) >= 16 and q.device = p_device
  order by q.created_at desc
$$;

grant execute on function public.ask_question(text, text, text) to anon, authenticated;
grant execute on function public.my_questions(text) to anon, authenticated;

notify pgrst, 'reload schema';
