-- =============================================================================
-- Migration: 001_add_throw_category.sql
-- 目的: public.moves.category の CHECK 制約に 'throw' を追加する（冪等）
-- 対象: すでに構築済みの Supabase (PostgreSQL) DB
-- =============================================================================

do $$
declare
  constraint_rec record;
begin
  -- 環境によって制約名が異なる可能性があるため、public.moves の category カラムに
  -- 紐づく既存の CHECK 制約をすべて検出して DROP する
  for constraint_rec in
    select con.conname
    from pg_constraint con
    join pg_class rel on rel.oid = con.conrelid
    join pg_namespace nsp on nsp.oid = rel.relnamespace
    where nsp.nspname = 'public'
      and rel.relname = 'moves'
      and con.contype = 'c'
      and (
        exists (
          select 1
          from pg_attribute att
          where att.attrelid = rel.oid
            and att.attnum = any(con.conkey)
            and att.attname = 'category'
        )
        or pg_get_constraintdef(con.oid) ilike '%category%'
      )
  loop
    execute format(
      'alter table public.moves drop constraint if exists %I',
      constraint_rec.conname
    );
  end loop;

  -- 'throw' を含む CHECK 制約を再作成する
  alter table public.moves
    add constraint moves_category_check
    check (category in ('normal', 'unique', 'special', 'super', 'throw', 'system'));
end $$;
