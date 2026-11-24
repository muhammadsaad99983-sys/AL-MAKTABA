-- اسلام 960 - اپڈیٹ 3: دعاؤں کے حصے
-- Supabase > SQL Editor میں پورا چسپاں کر کے Run دبائیں (ایک ہی بار)
alter table public.posts add column if not exists section text not null default '';
notify pgrst, 'reload schema';
