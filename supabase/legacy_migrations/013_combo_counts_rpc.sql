-- =============================================================================
-- Migration: 013_combo_counts_rpc.sql
-- 目的: トップ画面のキャラ別・操作タイプ別コンボ件数集計を Supabase 側（RPC）で実行し、
--       全コンボ行のネットワーク転送をなくす（30キャラ・数千コンボ規模へのスケーリング対応）
-- =============================================================================

create or replace function public.get_combo_counts_by_character()
returns table (
  character_id text,
  total_count bigint,
  classic_count bigint,
  modern_count bigint
)
language sql
stable
security invoker
as $$
  select
    c.character_id,
    count(*)::bigint as total_count,
    count(*) filter (where c.control_type = 'classic')::bigint as classic_count,
    count(*) filter (where c.control_type = 'modern')::bigint as modern_count
  from public.combos as c
  group by c.character_id;
$$;

grant execute on function public.get_combo_counts_by_character() to anon, authenticated;
