-- =============================================================================
-- Migration: 005_add_counter_system_moves.sql
-- 目的: 全キャラ共通のシステム技マスタに (CH) / (PC) を追加する（冪等）
-- =============================================================================

insert into public.moves (
  id,
  character_id,
  control_type,
  category,
  notation_numpad,
  notation_command,
  notation_name,
  sort_order,
  startup_frames,
  hit_advantage,
  cancel_types
)
values
  ('sys_ch', null, 'both', 'system', '(CH)', '(CH)', 'カウンターヒット', 10, null, null, null),
  ('sys_pc', null, 'both', 'system', '(PC)', '(PC)', 'パニッシュカウンター', 11, null, null, null)
on conflict (id) do update set
  character_id = excluded.character_id,
  control_type = excluded.control_type,
  category = excluded.category,
  notation_numpad = excluded.notation_numpad,
  notation_command = excluded.notation_command,
  notation_name = excluded.notation_name,
  sort_order = excluded.sort_order,
  startup_frames = excluded.startup_frames,
  hit_advantage = excluded.hit_advantage,
  cancel_types = excluded.cancel_types;
