-- ============================================================
-- HORMON EŞLEŞTİRME — SUPABASE ŞEMASI (ortak skor tablosu)
-- ============================================================
-- KULLANIM
--   1) Supabase panelinde sol menüden "SQL Editor" > "New query"
--   2) Bu dosyanın TAMAMINI yapıştırıp "Run" deyin
--   3) "Success. No rows returned" görmelisiniz
--
-- Tablo "he_" önekiyle başlar; aynı Supabase projesindeki diğer
-- oyunların tabloları ile (örn. Hormon-Kartlari'nin "hk_" tabloları)
-- ÇAKIŞMAZ. Aynı projeyi güvenle paylaşabilirsiniz.
--
-- Bu dosyayı tekrar çalıştırmak güvenlidir (idempotent).
-- ============================================================

create table if not exists public.he_scores (
  id         bigserial primary key,
  ad         text not null check (char_length(trim(ad)) between 2 and 80),
  no         text not null check (char_length(trim(no)) between 1 and 30),
  skor       int  not null check (skor >= 0),
  dogru      int  not null check (dogru between 0 and 21),
  sure       int  not null check (sure between 0 and 180),
  created_at timestamptz not null default now()
);

create index if not exists he_scores_siralama_idx
  on public.he_scores (skor desc, dogru desc, sure asc);

-- ------------------------------------------------------------
-- ROW LEVEL SECURITY
-- ------------------------------------------------------------
-- Bu oyunun kendi sunucusu yoktur (tek bir statik HTML dosyasıdır),
-- bu yüzden tarayıcı doğrudan "anon" anahtarıyla yazar/okur.
-- Politikalar şunu garanti eder: herkes skor EKLEYEBİLİR ve
-- TÜM skorları OKUYABİLİR, ama var olan bir skoru DEĞİŞTİREMEZ
-- veya SİLEMEZ (update/delete politikası yok = anon için kapalı).
alter table public.he_scores enable row level security;

drop policy if exists "he_scores okunabilir" on public.he_scores;
create policy "he_scores okunabilir"
  on public.he_scores for select to anon, authenticated
  using (true);

drop policy if exists "he_scores eklenebilir" on public.he_scores;
create policy "he_scores eklenebilir"
  on public.he_scores for insert to anon, authenticated
  with check (true);

grant select, insert on public.he_scores to anon;
grant usage, select on sequence public.he_scores_id_seq to anon;

-- ============================================================
-- ÖĞRETMEN İÇİN KULLANIŞLI SORGULAR
-- ============================================================
-- Genel sıralama:
--   select ad, no, skor, dogru, sure, created_at
--   from public.he_scores order by skor desc, dogru desc, sure asc;
--
-- Bu oturumun skorlarını tamamen sıfırlamak (DİKKAT: geri alınamaz):
--   delete from public.he_scores;
