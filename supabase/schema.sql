-- =============================================================================
-- コンボノート (Combo Note) Supabase Schema (DDL + RLS + Triggers)
-- SPEC.md セクション 5-1, 5-3 準拠
-- =============================================================================

-- 1. キャラクターマスタ
create table if not exists public.characters (
  id text primary key,
  slug text unique not null,
  name_ja text not null,
  name_en text not null,
  sort_order int default 0,
  is_active boolean default true,
  stock_label text,
  stock_short_label text,
  stock_max_count int
);

-- 2. 技マスタ (character_id が NULL のレコードは全キャラ共通のシステムパーツ)
create table if not exists public.moves (
  id text primary key,
  character_id text references public.characters(id) on delete cascade,
  control_type text check (control_type in ('classic', 'modern', 'both')),
  category text check (category in ('normal', 'unique', 'special', 'super', 'system')),
  notation_numpad text not null,
  notation_command text not null,
  notation_name text not null,
  sort_order int default 0,
  startup_frames int,
  hit_advantage int,
  cancel_types text[]
);

create index if not exists idx_moves_character_sort
  on public.moves (character_id, sort_order);

-- 3. バージョンマスタ
create table if not exists public.game_versions (
  id text primary key,
  label text not null,
  released_at timestamptz not null
);

-- 4. 公開コンボ
-- ※ 初期シードデータ投入のため author_id は NULL 許容とする。
--    クライアントからの INSERT は下の RLS ポリシーにより auth.uid() = author_id を強制する。
create table if not exists public.combos (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references auth.users(id) on delete cascade,
  author_name text,
  character_id text references public.characters(id) on delete cascade not null,
  control_type text check (control_type in ('classic', 'modern')) not null,
  move_ids jsonb not null,
  recipe_signature text not null,
  situations text[] not null,
  category text check (category in ('beginner', 'standard', 'optimal', 'fun')) not null,
  damage int,
  drive_cost numeric(3,1) check (drive_cost >= 0 and drive_cost <= 6),
  sa_cost int check (sa_cost >= 0 and sa_cost <= 3),
  stock_cost int default 0 check (stock_cost >= 0),
  stock_gain int default 0 check (stock_gain >= 0),
  has_oki boolean default false,
  note text not null,
  version_id text references public.game_versions(id) not null,
  likes_count int default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_combos_character_control
  on public.combos (character_id, control_type);

create index if not exists idx_combos_recipe_signature
  on public.combos (recipe_signature);

-- 5. いいね履歴
create table if not exists public.combo_likes (
  user_id uuid references auth.users(id) on delete cascade,
  combo_id uuid references public.combos(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (user_id, combo_id)
);

-- =============================================================================
-- Triggers
-- =============================================================================

-- combo_likes の INSERT / DELETE に連動して combos.likes_count を自動増減
create or replace function public.handle_combo_like_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if (tg_op = 'INSERT') then
    update public.combos
    set likes_count = coalesce(likes_count, 0) + 1
    where id = new.combo_id;
    return new;
  elsif (tg_op = 'DELETE') then
    update public.combos
    set likes_count = greatest(0, coalesce(likes_count, 0) - 1)
    where id = old.combo_id;
    return old;
  end if;
  return null;
end;
$$;

drop trigger if exists on_combo_like_change on public.combo_likes;
create trigger on_combo_like_change
  after insert or delete on public.combo_likes
  for each row
  execute function public.handle_combo_like_change();

-- combos 更新時に updated_at を自動更新
create or replace function public.handle_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists on_combos_updated_at on public.combos;
create trigger on_combos_updated_at
  before update on public.combos
  for each row
  execute function public.handle_updated_at();

-- =============================================================================
-- Row Level Security (RLS)
-- =============================================================================

alter table public.characters enable row level security;
alter table public.moves enable row level security;
alter table public.game_versions enable row level security;
alter table public.combos enable row level security;
alter table public.combo_likes enable row level security;

-- characters: 全ユーザー（未ログイン含む）に SELECT 許可
drop policy if exists "characters_select_public" on public.characters;
create policy "characters_select_public"
  on public.characters
  for select
  using (true);

-- moves: 全ユーザー（未ログイン含む）に SELECT 許可
drop policy if exists "moves_select_public" on public.moves;
create policy "moves_select_public"
  on public.moves
  for select
  using (true);

-- game_versions: 全ユーザー（未ログイン含む）に SELECT 許可
drop policy if exists "game_versions_select_public" on public.game_versions;
create policy "game_versions_select_public"
  on public.game_versions
  for select
  using (true);

-- combos: SELECT は全ユーザー許可、INSERT / UPDATE / DELETE は認証済み本人のみ
drop policy if exists "combos_select_public" on public.combos;
create policy "combos_select_public"
  on public.combos
  for select
  using (true);

drop policy if exists "combos_insert_authenticated_own" on public.combos;
create policy "combos_insert_authenticated_own"
  on public.combos
  for insert
  to authenticated
  with check (auth.uid() is not null and auth.uid() = author_id);

drop policy if exists "combos_update_own" on public.combos;
create policy "combos_update_own"
  on public.combos
  for update
  to authenticated
  using (auth.uid() = author_id)
  with check (auth.uid() = author_id);

drop policy if exists "combos_delete_own" on public.combos;
create policy "combos_delete_own"
  on public.combos
  for delete
  to authenticated
  using (auth.uid() = author_id);

-- combo_likes: 認証済みユーザー自身のレコードのみ SELECT / INSERT / DELETE 許可
drop policy if exists "combo_likes_select_own" on public.combo_likes;
create policy "combo_likes_select_own"
  on public.combo_likes
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "combo_likes_insert_own" on public.combo_likes;
create policy "combo_likes_insert_own"
  on public.combo_likes
  for insert
  to authenticated
  with check (auth.uid() is not null and auth.uid() = user_id);

drop policy if exists "combo_likes_delete_own" on public.combo_likes;
create policy "combo_likes_delete_own"
  on public.combo_likes
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- =============================================================================
-- Grants (anon / authenticated ロールへの最小権限付与)
-- =============================================================================

grant usage on schema public to anon, authenticated;

grant select on public.characters to anon, authenticated;
grant select on public.moves to anon, authenticated;
grant select on public.game_versions to anon, authenticated;
grant select on public.combos to anon, authenticated;

grant insert, update, delete on public.combos to authenticated;
grant select, insert, delete on public.combo_likes to authenticated;
