-- =============================================================================
-- Migration: 029_add_admin_role.sql
-- 目的:
--   試験運用・一般公開に向けて、テストデータの修正・削除や悪質な投稿の即時削除を
--   DB の RLS ベースで安全に行えるよう、管理者ユーザー管理テーブル (`public.admin_users`)、
--   管理者判定関数 (`public.is_admin()`)、および `public.combos` の UPDATE / DELETE
--   RLS ポリシーを冪等に定義・更新する。
-- =============================================================================

-- 1. 管理者ユーザーテーブル作成
--    クライアントからの INSERT / UPDATE / DELETE は許可しない（SQL Editor / service_role のみ登録可能）。
create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz default now()
);

alter table public.admin_users enable row level security;

-- 最小権限: 認証済みユーザーには SELECT のみ付与し、RLS で自分自身の行のみ参照可能にする
revoke all on public.admin_users from anon, authenticated;
grant select on public.admin_users to authenticated;

drop policy if exists "admin_users_select_own" on public.admin_users;
create policy "admin_users_select_own"
  on public.admin_users
  for select
  to authenticated
  using (auth.uid() = user_id);

-- 2. 管理者判定関数 public.is_admin() 作成
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.admin_users
    where user_id = auth.uid()
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

-- 3. public.combos の UPDATE / DELETE RLS ポリシー更新
--    既存の SELECT ("combos_select_public") / INSERT ("combos_insert_authenticated_own") は維持し、
--    UPDATE / DELETE を「投稿者本人 OR 管理者」に拡張する。
--    ※ author_id が NULL のシード／テストコンボも、public.is_admin() が true なら編集・削除可能。
drop policy if exists "combos_update_own" on public.combos;
drop policy if exists "combos_update_own_or_admin" on public.combos;
create policy "combos_update_own_or_admin"
  on public.combos
  for update
  to authenticated
  using (auth.uid() = author_id or public.is_admin())
  with check (auth.uid() = author_id or public.is_admin());

drop policy if exists "combos_delete_own" on public.combos;
drop policy if exists "combos_delete_own_or_admin" on public.combos;
create policy "combos_delete_own_or_admin"
  on public.combos
  for delete
  to authenticated
  using (auth.uid() = author_id or public.is_admin());
