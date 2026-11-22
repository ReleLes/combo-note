-- =============================================================================
-- Migration: 004_add_combo_title.sql
-- 目的: public.combos テーブルに任意タイトル用カラム title (text, NULL許容) を追加する（冪等）
-- =============================================================================

alter table public.combos
add column if not exists title text;
