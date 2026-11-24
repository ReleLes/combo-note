-- =============================================================================
-- Migration: 014_add_vega_jp.sql
-- 目的: 13人目「ベガ（vega）」・14人目「JP（jp）」のキャラクターマスタおよび
--       全技マスタ（ベガ全140技＋JP全122技＝計262技・
--       公式フレームデータ＆コマンドリスト準拠・CA除外）を
--       既存の Supabase 本番 DB へ安全・冪等に UPSERT する
-- 前提: 001_add_throw_category.sql を先に適用済みであること
-- =============================================================================

-- 1. キャラクターマスタへベガ・JPを追加・更新
insert into public.characters (
  id,
  slug,
  name_ja,
  name_en,
  sort_order,
  is_active,
  stock_label,
  stock_short_label,
  stock_max_count
)
values
  ('vega', 'vega', 'ベガ', 'M. Bison', 13, true, null, null, null),
  ('jp', 'jp', 'JP', 'JP', 14, true, null, null, null)
on conflict (id) do update set
  slug = excluded.slug,
  name_ja = excluded.name_ja,
  name_en = excluded.name_en,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  stock_label = excluded.stock_label,
  stock_short_label = excluded.stock_short_label,
  stock_max_count = excluded.stock_max_count;

-- 2. ベガ・JP全技マスタ（計262技）を UPSERT
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

  -- =========================================================================
  -- ベガ（vega）全140技（クラシック63種＋モダン76種＋共通1種）
  -- =========================================================================

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('vega_5lp', 'vega', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（ジャブ）', 10, 5, 4, array['C']),
  ('vega_5lk', 'vega', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（ヘルニーキック）', 11, 4, 3, array['C']),
  ('vega_5mp', 'vega', 'classic', 'normal', '5中P', '中P', '立ち中P（ヘルボディーブロー）', 12, 8, 6, array['C']),
  ('vega_5mk', 'vega', 'classic', 'normal', '5中K', '中K', '立ち中K（シャドーミドルキック）', 13, 10, 2, '{}'::text[]),
  ('vega_5hp', 'vega', 'classic', 'normal', '5強P', '強P', '立ち強P（サイコパイル）', 14, 19, 5, array['SA']),
  ('vega_5hk', 'vega', 'classic', 'normal', '5強K', '強K', '立ち強K（シャドーサイス）', 15, 13, 6, '{}'::text[]),
  ('vega_2lp', 'vega', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（ジャブ）', 20, 4, 4, array['C']),
  ('vega_2lk', 'vega', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（ヘルレッグ）', 21, 5, 4, '{}'::text[]),
  ('vega_2mp', 'vega', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（ストレート）', 22, 6, 5, array['C']),
  ('vega_2mk', 'vega', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（デスレッグ）', 23, 8, -2, array['C']),
  ('vega_2hp', 'vega', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（サイコアッパー）', 24, 10, 0, array['C']),
  ('vega_2hk', 'vega', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（シャドースイープ）', 25, 11, null, '{}'::text[]),
  ('vega_jlp', 'vega', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（ヘルフック）', 30, 5, null, '{}'::text[]),
  ('vega_jlk', 'vega', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（ヒールスタンプ）', 31, 5, null, '{}'::text[]),
  ('vega_jmp', 'vega', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（ヘルナックル）', 32, 8, null, '{}'::text[]),
  ('vega_jmk', 'vega', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（ニーミサイル）', 33, 7, null, '{}'::text[]),
  ('vega_jhp', 'vega', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（サイコエルボー）', 34, 9, null, '{}'::text[]),
  ('vega_jhk', 'vega', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（トマホークキック）', 35, 10, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 6種: 40〜45）
  ('vega_6hp', 'vega', 'classic', 'unique', '6強P', '→+強P', 'サイコハンマー', 40, 22, 3, '{}'::text[]),
  ('vega_4hk', 'vega', 'classic', 'unique', '4強K', '←+強K', 'イビルニー', 41, 10, 4, array['C']),
  ('vega_3hk', 'vega', 'classic', 'unique', '3強K', '↘+強K', 'ホバーキック', 42, 15, null, '{}'::text[]),
  ('vega_tc_5mp_6hp', 'vega', 'classic', 'unique', '5中P>6強P', '中P>→+強P', 'シャドウハンマー', 43, 22, 3, '{}'::text[]),
  ('vega_tc_5mp_2hk', 'vega', 'classic', 'unique', '5中P>2強K', '中P>↓+強K', 'シャドウスピア', 44, 16, 3, '{}'::text[]),
  ('vega_jmp_tc', 'vega', 'classic', 'unique', 'J中P>中P', '空中で中P>中P', 'ヘルアタック', 45, 7, null, '{}'::text[]),

  -- 3. 必殺技（クラシック 34種: 50〜83）
  ('vega_46lp', 'vega', 'classic', 'special', '[4]6弱P', '←タメ→+弱P', '弱 サイコクラッシャーアタック', 50, 14, null, array['SA3']),
  ('vega_46lp_mine', 'vega', 'classic', 'special', '[マイン][4]6弱P', '[マイン]←タメ→+弱P', '[マイン]弱 サイコクラッシャーアタック', 51, 14, null, array['SA3']),
  ('vega_46mp', 'vega', 'classic', 'special', '[4]6中P', '←タメ→+中P', '中 サイコクラッシャーアタック', 52, 20, null, array['SA3']),
  ('vega_46mp_mine', 'vega', 'classic', 'special', '[マイン][4]6中P', '[マイン]←タメ→+中P', '[マイン]中 サイコクラッシャーアタック', 53, 20, null, array['SA3']),
  ('vega_46hp', 'vega', 'classic', 'special', '[4]6強P', '←タメ→+強P', '強 サイコクラッシャーアタック', 54, 24, null, array['SA3']),
  ('vega_46hp_mine', 'vega', 'classic', 'special', '[マイン][4]6強P', '[マイン]←タメ→+強P', '[マイン]強 サイコクラッシャーアタック', 55, 24, null, array['SA3']),
  ('vega_46odp', 'vega', 'classic', 'special', 'OD[4]6PP', '←タメ→+PP', 'OD サイコクラッシャーアタック', 56, 16, null, array['SA2']),
  ('vega_46odp_mine', 'vega', 'classic', 'special', '[マイン]OD[4]6PP', '[マイン]←タメ→+PP', '[マイン]OD サイコクラッシャーアタック', 57, 16, null, '{}'::text[]),
  ('vega_236lk', 'vega', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 ダブルニープレス', 58, 13, 2, array['SA3']),
  ('vega_236mk', 'vega', 'classic', 'special', '236中K', '↓↘→+中K', '中 ダブルニープレス', 59, 17, 3, array['SA3']),
  ('vega_236hk', 'vega', 'classic', 'special', '236強K', '↓↘→+強K', '強 ダブルニープレス', 60, 22, 3, array['SA3']),
  ('vega_236odk', 'vega', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD ダブルニープレス', 61, 17, null, array['SA2']),
  ('vega_214lp', 'vega', 'classic', 'special', '214弱P', '↓↙←+弱P', '弱 バックフィストコンボ', 62, 13, null, array['SA3']),
  ('vega_214lp_mine', 'vega', 'classic', 'special', '[マイン]214弱P', '[マイン]↓↙←+弱P', '[マイン]弱 バックフィストコンボ', 63, 13, null, array['SA3']),
  ('vega_214mp', 'vega', 'classic', 'special', '214中P', '↓↙←+中P', '中 バックフィストコンボ', 64, 17, null, array['SA3']),
  ('vega_214mp_mine', 'vega', 'classic', 'special', '[マイン]214中P', '[マイン]↓↙←+中P', '[マイン]中 バックフィストコンボ', 65, 17, null, array['SA3']),
  ('vega_214hp', 'vega', 'classic', 'special', '214強P', '↓↙←+強P', '強 バックフィストコンボ', 66, 22, null, array['SA3']),
  ('vega_214hp_mine', 'vega', 'classic', 'special', '[マイン]214強P', '[マイン]↓↙←+強P', '[マイン]強 バックフィストコンボ', 67, 22, null, array['SA3']),
  ('vega_214odp', 'vega', 'classic', 'special', 'OD214PP', '↓↙←+PP', 'OD バックフィストコンボ', 68, 14, null, array['SA2']),
  ('vega_214odp_mine', 'vega', 'classic', 'special', '[マイン]OD214PP', '[マイン]↓↙←+PP', '[マイン]OD バックフィストコンボ', 69, 14, null, array['SA2']),
  ('vega_28lk', 'vega', 'classic', 'special', '[2]8弱K', '↓タメ↑+弱K', '弱 シャドウライズ', 70, null, null, '{}'::text[]),
  ('vega_28mk', 'vega', 'classic', 'special', '[2]8中K', '↓タメ↑+中K', '中 シャドウライズ', 71, null, null, '{}'::text[]),
  ('vega_28hk', 'vega', 'classic', 'special', '[2]8強K', '↓タメ↑+強K', '強 シャドウライズ', 72, null, null, '{}'::text[]),
  ('vega_28odk', 'vega', 'classic', 'special', 'OD[2]8KK', '↓タメ↑+KK', 'OD シャドウライズ', 73, null, null, '{}'::text[]),
  ('vega_headpress', 'vega', 'classic', 'special', 'ヘッドプレス', 'ライズ中K', 'ヘッドプレス', 74, 15, null, '{}'::text[]),
  ('vega_headpress_od_from_n', 'vega', 'classic', 'special', 'ODヘッドプレス(通常から)', 'ライズ中KK', 'OD ヘッドプレス（通常ライズ派生）', 75, 15, null, '{}'::text[]),
  ('vega_headpress_od_from_od', 'vega', 'classic', 'special', 'ODヘッドプレス(ODから)', 'ODライズ中K', 'OD ヘッドプレス（ODライズ派生）', 76, 15, null, '{}'::text[]),
  ('vega_skull', 'vega', 'classic', 'special', 'スカルダイバー', 'ヘッドプレス後P', 'サマーソルトスカルダイバー', 77, 12, null, '{}'::text[]),
  ('vega_devil', 'vega', 'classic', 'special', 'デビルリバース', 'ライズ中P', 'デビルリバース', 78, 16, null, '{}'::text[]),
  ('vega_devil_mine', 'vega', 'classic', 'special', '[マイン]デビルリバース', '[マイン]ライズ中P', '[マイン]デビルリバース', 79, 16, null, '{}'::text[]),
  ('vega_devil_od_from_n', 'vega', 'classic', 'special', 'ODデビル(通常から)', 'ライズ中PP', 'OD デビルリバース（通常ライズ派生）', 80, 21, null, '{}'::text[]),
  ('vega_devil_od_mine_from_n', 'vega', 'classic', 'special', '[マイン]ODデビル(通常から)', '[マイン]ライズ中PP', '[マイン]OD デビルリバース（通常ライズ派生）', 81, 21, null, '{}'::text[]),
  ('vega_devil_od_from_od', 'vega', 'classic', 'special', 'ODデビル(ODから)', 'ODライズ中P', 'OD デビルリバース（ODライズ派生）', 82, 21, null, '{}'::text[]),
  ('vega_devil_od_mine_from_od', 'vega', 'classic', 'special', '[マイン]ODデビル(ODから)', '[マイン]ODライズ中P', '[マイン]OD デビルリバース（ODライズ派生）', 83, 21, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 3種: 90〜92、CA除外）
  ('vega_sa1', 'vega', 'classic', 'super', 'SA1', '↓↘→↓↘→+K', 'SA1 ニープレスナイトメア', 90, 10, null, '{}'::text[]),
  ('vega_sa2', 'vega', 'classic', 'super', 'SA2', '↓↙←↓↙←+K', 'SA2 サイコパニッシャー', 91, 24, null, '{}'::text[]),
  ('vega_sa3', 'vega', 'classic', 'super', 'SA3', '↓↘→↓↘→+P', 'SA3 アンリミテッドサイコクラッシャー', 92, 10, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 2種: 95〜96）
  ('vega_throw_f', 'vega', 'classic', 'throw', '前投げ', '弱P+弱K', 'デッドリースルー（前投げ）', 95, 5, null, '{}'::text[]),
  ('vega_throw_b', 'vega', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'デスタワー（後ろ投げ）', 96, 5, null, '{}'::text[]),

  -- 6. ベガ固有システム補助パーツ（共通 1種: 100）
  ('vega_mine_explode', 'vega', 'both', 'system', 'マイン起爆', 'マイン起爆', 'サイコマイン（自動爆発）', 100, null, null, '{}'::text[]),

  -- 7. モダン通常技（10種: 110〜119）
  ('vega_m_5l', 'vega', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 5, 4, array['C']),
  ('vega_m_5m', 'vega', 'modern', 'normal', '5中', '中', '立ち中（立ち中K）', 111, 10, 2, '{}'::text[]),
  ('vega_m_5h', 'vega', 'modern', 'normal', '5強', '強', '立ち強（立ち強P）', 112, 19, 5, array['SA']),
  ('vega_m_2l', 'vega', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱P）', 113, 4, 4, array['C']),
  ('vega_m_2m', 'vega', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 114, 8, -2, array['C']),
  ('vega_m_2h', 'vega', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 115, 10, 0, array['C']),
  ('vega_m_3h', 'vega', 'modern', 'normal', '3強', '↘+強', '右下強（シャドースイープ）', 116, 11, null, '{}'::text[]),
  ('vega_m_jl', 'vega', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 117, 5, null, '{}'::text[]),
  ('vega_m_jm', 'vega', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 118, 8, null, '{}'::text[]),
  ('vega_m_jh', 'vega', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 119, 10, null, '{}'::text[]),

  -- 8. モダン特殊技・アシスト（15種: 125〜139）
  ('vega_m_auto_l', 'vega', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・しゃがみ弱K）', 125, 5, 4, '{}'::text[]),
  ('vega_m_auto_m', 'vega', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・しゃがみ中P）', 126, 6, 5, array['C']),
  ('vega_m_auto_h', 'vega', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち中P）', 127, 8, 6, array['C']),
  ('vega_m_j_auto_l', 'vega', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 128, 5, null, '{}'::text[]),
  ('vega_m_j_auto_m', 'vega', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 129, 7, null, '{}'::text[]),
  ('vega_m_j_auto_h', 'vega', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 130, 9, null, '{}'::text[]),
  ('vega_m_auto_l_combo', 'vega', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 131, 5, null, '{}'::text[]),
  ('vega_m_auto_2l_combo', 'vega', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 132, 4, null, '{}'::text[]),
  ('vega_m_auto_m_combo', 'vega', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 133, 6, null, '{}'::text[]),
  ('vega_m_auto_h_combo', 'vega', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 134, 8, null, '{}'::text[]),
  ('vega_m_6h', 'vega', 'modern', 'unique', '6強', '→+強', 'サイコハンマー', 135, 22, 3, '{}'::text[]),
  ('vega_m_4h', 'vega', 'modern', 'unique', '4強', '←+強', 'イビルニー', 136, 10, 4, array['C']),
  ('vega_m_tc_ah_6h', 'vega', 'modern', 'unique', 'A強>6強', 'アシスト強>→+強', 'シャドウハンマー', 137, 22, 3, '{}'::text[]),
  ('vega_m_tc_ah_2h', 'vega', 'modern', 'unique', 'A強>2強', 'アシスト強>↓+強', 'シャドウスピア', 138, 16, 3, '{}'::text[]),
  ('vega_m_jm_tc', 'vega', 'modern', 'unique', 'J中>中', '空中で中>中', 'ヘルアタック', 139, 7, null, '{}'::text[]),

  -- 9. モダン必殺技：ワンボタンSP＆OD版（12種: 145〜156）
  ('vega_m_4sp', 'vega', 'modern', 'special', '[4]後必', '←タメ+SP', '弱 サイコクラッシャーアタック（後必）', 145, 14, null, array['SA3']),
  ('vega_m_4sp_mine', 'vega', 'modern', 'special', '[マイン][4]後必', '[マイン]←タメ+SP', '[マイン]弱 サイコクラッシャー（後必）', 146, 14, null, array['SA3']),
  ('vega_m_od_4sp', 'vega', 'modern', 'special', 'A+[4]後必', '←タメ+A+SP', 'OD サイコクラッシャーアタック（A+後必）', 147, 16, null, array['SA2']),
  ('vega_m_od_4sp_mine', 'vega', 'modern', 'special', '[マイン]A+[4]後必', '[マイン]←タメ+A+SP', '[マイン]OD サイコクラッシャー（A+後必）', 148, 16, null, '{}'::text[]),
  ('vega_m_6sp', 'vega', 'modern', 'special', '前必', '→+SP', '弱 ダブルニープレス（前必）', 149, 13, 2, array['SA3']),
  ('vega_m_od_6sp', 'vega', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD ダブルニープレス（A+前必）', 150, 17, null, array['SA2']),
  ('vega_m_sp', 'vega', 'modern', 'special', 'N必', 'SP', '中 バックフィストコンボ（N必）', 151, 17, null, array['SA3']),
  ('vega_m_sp_mine', 'vega', 'modern', 'special', '[マイン]N必', '[マイン]SP', '[マイン]中 バックフィストコンボ（N必）', 152, 17, null, array['SA3']),
  ('vega_m_od_sp', 'vega', 'modern', 'special', 'A+N必', 'A+SP', 'OD バックフィストコンボ（A+N必）', 153, 14, null, array['SA2']),
  ('vega_m_od_sp_mine', 'vega', 'modern', 'special', '[マイン]A+N必', '[マイン]A+SP', '[マイン]OD バックフィストコンボ（A+N必）', 154, 14, null, array['SA2']),
  ('vega_m_2sp', 'vega', 'modern', 'special', '[2]下必', '↓タメ+SP', '中 シャドウライズ（下必）', 155, null, null, '{}'::text[]),
  ('vega_m_od_2sp', 'vega', 'modern', 'special', 'A+[2]下必', '↓タメ+A+SP', 'OD シャドウライズ（A+下必）', 156, null, null, '{}'::text[]),

  -- 10. モダン必殺技：コマンド入力版＆ライズ派生（34種: 160〜193）
  ('vega_m_46l', 'vega', 'modern', 'special', '[4]6弱', '←タメ→+弱', '弱 サイコクラッシャーアタック', 160, 14, null, array['SA3']),
  ('vega_m_46l_mine', 'vega', 'modern', 'special', '[マイン][4]6弱', '[マイン]←タメ→+弱', '[マイン]弱 サイコクラッシャーアタック', 161, 14, null, array['SA3']),
  ('vega_m_46m', 'vega', 'modern', 'special', '[4]6中', '←タメ→+中', '中 サイコクラッシャーアタック', 162, 20, null, array['SA3']),
  ('vega_m_46m_mine', 'vega', 'modern', 'special', '[マイン][4]6中', '[マイン]←タメ→+中', '[マイン]中 サイコクラッシャーアタック', 163, 20, null, array['SA3']),
  ('vega_m_46h', 'vega', 'modern', 'special', '[4]6強', '←タメ→+強', '強 サイコクラッシャーアタック', 164, 24, null, array['SA3']),
  ('vega_m_46h_mine', 'vega', 'modern', 'special', '[マイン][4]6強', '[マイン]←タメ→+強', '[マイン]強 サイコクラッシャーアタック', 165, 24, null, array['SA3']),
  ('vega_m_46od', 'vega', 'modern', 'special', 'OD[4]6', '←タメ→+攻撃×2', 'OD サイコクラッシャーアタック', 166, 16, null, array['SA2']),
  ('vega_m_46od_mine', 'vega', 'modern', 'special', '[マイン]OD[4]6', '[マイン]←タメ→+攻撃×2', '[マイン]OD サイコクラッシャーアタック', 167, 16, null, '{}'::text[]),
  ('vega_m_236l', 'vega', 'modern', 'special', '236弱', '↓↘→+弱', '弱 ダブルニープレス', 168, 13, 2, array['SA3']),
  ('vega_m_236m', 'vega', 'modern', 'special', '236中', '↓↘→+中', '中 ダブルニープレス', 169, 17, 3, array['SA3']),
  ('vega_m_236h', 'vega', 'modern', 'special', '236強', '↓↘→+強', '強 ダブルニープレス', 170, 22, 3, array['SA3']),
  ('vega_m_236od', 'vega', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD ダブルニープレス', 171, 17, null, array['SA2']),
  ('vega_m_214l', 'vega', 'modern', 'special', '214弱', '↓↙←+弱', '弱 バックフィストコンボ', 172, 13, null, array['SA3']),
  ('vega_m_214l_mine', 'vega', 'modern', 'special', '[マイン]214弱', '[マイン]↓↙←+弱', '[マイン]弱 バックフィストコンボ', 173, 13, null, array['SA3']),
  ('vega_m_214m', 'vega', 'modern', 'special', '214中', '↓↙←+中', '中 バックフィストコンボ', 174, 17, null, array['SA3']),
  ('vega_m_214m_mine', 'vega', 'modern', 'special', '[マイン]214中', '[マイン]↓↙←+中', '[マイン]中 バックフィストコンボ', 175, 17, null, array['SA3']),
  ('vega_m_214h', 'vega', 'modern', 'special', '214強', '↓↙←+強', '強 バックフィストコンボ', 176, 22, null, array['SA3']),
  ('vega_m_214h_mine', 'vega', 'modern', 'special', '[マイン]214強', '[マイン]↓↙←+強', '[マイン]強 バックフィストコンボ', 177, 22, null, array['SA3']),
  ('vega_m_214od', 'vega', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD バックフィストコンボ', 178, 14, null, array['SA2']),
  ('vega_m_214od_mine', 'vega', 'modern', 'special', '[マイン]OD214', '[マイン]↓↙←+攻撃×2', '[マイン]OD バックフィストコンボ', 179, 14, null, array['SA2']),
  ('vega_m_28l', 'vega', 'modern', 'special', '[2]8弱', '↓タメ↑+弱', '弱 シャドウライズ', 180, null, null, '{}'::text[]),
  ('vega_m_28m', 'vega', 'modern', 'special', '[2]8中', '↓タメ↑+中', '中 シャドウライズ', 181, null, null, '{}'::text[]),
  ('vega_m_28h', 'vega', 'modern', 'special', '[2]8強', '↓タメ↑+強', '強 シャドウライズ', 182, null, null, '{}'::text[]),
  ('vega_m_28od', 'vega', 'modern', 'special', 'OD[2]8', '↓タメ↑+攻撃×2', 'OD シャドウライズ', 183, null, null, '{}'::text[]),
  ('vega_m_headpress', 'vega', 'modern', 'special', 'ヘッドプレス', 'ライズ中攻撃', 'ヘッドプレス', 184, 15, null, '{}'::text[]),
  ('vega_m_headpress_od_from_n', 'vega', 'modern', 'special', 'ODヘッドプレス(通常から)', 'ライズ中攻撃×2', 'OD ヘッドプレス（通常ライズ派生）', 185, 15, null, '{}'::text[]),
  ('vega_m_headpress_od_from_od', 'vega', 'modern', 'special', 'ODヘッドプレス(ODから)', 'ODライズ中攻撃', 'OD ヘッドプレス（ODライズ派生）', 186, 15, null, '{}'::text[]),
  ('vega_m_skull', 'vega', 'modern', 'special', 'スカルダイバー', 'ヘッドプレス後攻撃', 'サマーソルトスカルダイバー', 187, 12, null, '{}'::text[]),
  ('vega_m_devil', 'vega', 'modern', 'special', 'デビルリバース', 'ライズ中SP', 'デビルリバース', 188, 16, null, '{}'::text[]),
  ('vega_m_devil_mine', 'vega', 'modern', 'special', '[マイン]デビルリバース', '[マイン]ライズ中SP', '[マイン]デビルリバース', 189, 16, null, '{}'::text[]),
  ('vega_m_devil_od_from_n', 'vega', 'modern', 'special', 'ODデビル(通常から)', 'ライズ中A+SP', 'OD デビルリバース（通常ライズ派生）', 190, 21, null, '{}'::text[]),
  ('vega_m_devil_od_mine_from_n', 'vega', 'modern', 'special', '[マイン]ODデビル(通常から)', '[マイン]ライズ中A+SP', '[マイン]OD デビルリバース（通常ライズ派生）', 191, 21, null, '{}'::text[]),
  ('vega_m_devil_od_from_od', 'vega', 'modern', 'special', 'ODデビル(ODから)', 'ODライズ中SP', 'OD デビルリバース（ODライズ派生）', 192, 21, null, '{}'::text[]),
  ('vega_m_devil_od_mine_from_od', 'vega', 'modern', 'special', '[マイン]ODデビル(ODから)', '[マイン]ODライズ中SP', '[マイン]OD デビルリバース（ODライズ派生）', 193, 21, null, '{}'::text[]),

  -- 11. モダンスーパーアーツ（3種: 200〜202、CA除外）
  ('vega_m_sa1', 'vega', 'modern', 'super', 'SA1', 'SP+強', 'SA1 ニープレスナイトメア', 200, 10, null, '{}'::text[]),
  ('vega_m_sa2', 'vega', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 サイコパニッシャー', 201, 24, null, '{}'::text[]),
  ('vega_m_sa3', 'vega', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 アンリミテッドサイコクラッシャー', 202, 10, null, '{}'::text[]),

  -- 12. モダン通常投げ（2種: 205〜206）
  ('vega_m_throw_f', 'vega', 'modern', 'throw', '前投げ', '弱+中', 'デッドリースルー（前投げ）', 205, 5, null, '{}'::text[]),
  ('vega_m_throw_b', 'vega', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'デスタワー（後ろ投げ）', 206, 5, null, '{}'::text[]),

  -- =========================================================================
  -- JP（jp）全122技（クラシック59種＋モダン62種＋共通1種）
  -- =========================================================================

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('jp_5lp', 'jp', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（ノーシ）', 10, 6, 4, array['C']),
  ('jp_5lk', 'jp', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（ニージニイ・ウダール）', 11, 5, 3, array['C']),
  ('jp_5mp', 'jp', 'classic', 'normal', '5中P', '中P', '立ち中P（シュトゥールム）', 12, 12, 1, '{}'::text[]),
  ('jp_5mk', 'jp', 'classic', 'normal', '5中K', '中K', '立ち中K（ウームヌィ・ウダール）', 13, 8, 3, array['C']),
  ('jp_5hp', 'jp', 'classic', 'normal', '5強P', '強P', '立ち強P（キンターヴル）', 14, 12, 3, array['C']),
  ('jp_5hk', 'jp', 'classic', 'normal', '5強K', '強K', '立ち強K（オボロートニ）', 15, 12, 7, '{}'::text[]),
  ('jp_2lp', 'jp', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（ブィストルイ・ウダール）', 20, 4, 4, array['C']),
  ('jp_2lk', 'jp', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（リョーフキー・ウダール）', 21, 6, 2, '{}'::text[]),
  ('jp_2mp', 'jp', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（ズミヤー）', 22, 7, 6, array['C']),
  ('jp_2mk', 'jp', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（ズローバ）', 23, 9, 3, '{}'::text[]),
  ('jp_2hp', 'jp', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（マリートヴァ）', 24, 9, 1, array['C']),
  ('jp_2hk', 'jp', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（ジョーキル）', 25, 10, null, '{}'::text[]),
  ('jp_jlp', 'jp', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（ルイースイ）', 30, 5, null, '{}'::text[]),
  ('jp_jlk', 'jp', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（ヴァローナ）', 31, 6, null, '{}'::text[]),
  ('jp_jmp', 'jp', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（ローシャッチ）', 32, 12, null, '{}'::text[]),
  ('jp_jmk', 'jp', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（コンダ）', 33, 7, null, '{}'::text[]),
  ('jp_jhp', 'jp', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（イディナローク）', 34, 9, null, '{}'::text[]),
  ('jp_jhk', 'jp', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（ジャール・プチーツァ）', 35, 11, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 8種: 40〜47）
  ('jp_6mk', 'jp', 'classic', 'unique', '6中K', '→+中K', 'ギリオチーナ', 40, 22, 3, '{}'::text[]),
  ('jp_3hp', 'jp', 'classic', 'unique', '3強P', '↘+強P', 'シャーロスチ', 41, 16, null, '{}'::text[]),
  ('jp_6hk', 'jp', 'classic', 'unique', '6強K', '→+強K', 'ヴィリーナ', 42, 11, null, array['C']),
  ('jp_4mp', 'jp', 'classic', 'unique', '4中P', '←+中P', 'グロームストレルカ（1段目）', 43, 8, 5, array['C']),
  ('jp_4mp_2', 'jp', 'classic', 'unique', '4中P>中P', '←+中P>中P', 'グロームストレルカ（2段目）', 44, 10, 3, array['C']),
  ('jp_tc_hk_hp', 'jp', 'classic', 'unique', '5強K>強P', '強K>強P', 'ジラント', 45, 20, 3, array['C']),
  ('jp_tc_hk_hp_hp', 'jp', 'classic', 'unique', '5強K>強P>強P', '強K>強P>強P', 'ジラントルカー', 46, 21, 3, '{}'::text[]),
  ('jp_tc_hk_hp_hk', 'jp', 'classic', 'unique', '5強K>強P>強K', '強K>強P>強K', 'ジラントナガー', 47, 21, 3, '{}'::text[]),

  -- 3. 必殺技（クラシック 27種: 50〜76）
  ('jp_22lp', 'jp', 'classic', 'special', '22弱P', '↓↓+弱P', '弱 トリグラフ', 50, 22, null, array['SA3']),
  ('jp_22mp', 'jp', 'classic', 'special', '22中P', '↓↓+中P', '中 トリグラフ', 51, 22, null, array['SA3']),
  ('jp_22hp', 'jp', 'classic', 'special', '22強P', '↓↓+強P', '強 トリグラフ', 52, 22, null, array['SA3']),
  ('jp_22od_lm', 'jp', 'classic', 'special', 'OD22弱中P', '↓↓+弱P中P', 'OD 弱 トリグラフ', 53, 20, null, array['SA2']),
  ('jp_22od_lh', 'jp', 'classic', 'special', 'OD22弱強P', '↓↓+弱P強P', 'OD 中 トリグラフ', 54, 20, null, array['SA2']),
  ('jp_22od_mh', 'jp', 'classic', 'special', 'OD22中強P', '↓↓+中P強P', 'OD 強 トリグラフ', 55, 20, null, array['SA2']),
  ('jp_236lp', 'jp', 'classic', 'special', '236弱P', '↓↘→+弱P', '弱 ストリボーグ', 56, 16, null, array['SA3']),
  ('jp_236mp', 'jp', 'classic', 'special', '236中P', '↓↘→+中P', '中 ストリボーグ', 57, 20, null, array['SA3']),
  ('jp_236hp', 'jp', 'classic', 'special', '236強P', '↓↘→+強P', '強 ストリボーグ', 58, 28, null, array['SA3']),
  ('jp_236odp', 'jp', 'classic', 'special', 'OD236PP', '↓↘→+PP', 'OD ストリボーグ', 59, 19, null, array['SA2']),
  ('jp_214lp', 'jp', 'classic', 'special', '214弱P', '↓↙←+弱P', '弱 ヴィーハト（設置）', 60, 150, null, '{}'::text[]),
  ('jp_214mp', 'jp', 'classic', 'special', '214中P', '↓↙←+中P', '中 ヴィーハト（設置）', 61, 150, null, '{}'::text[]),
  ('jp_214hp', 'jp', 'classic', 'special', '214強P', '↓↙←+強P', '強 ヴィーハト（設置）', 62, 150, null, '{}'::text[]),
  ('jp_214od_lm', 'jp', 'classic', 'special', 'OD214弱中P', '↓↙←+弱P中P', 'OD 弱 ヴィーハト（設置）', 63, 110, null, '{}'::text[]),
  ('jp_214od_lh', 'jp', 'classic', 'special', 'OD214弱強P', '↓↙←+弱P強P', 'OD 中 ヴィーハト（設置）', 64, 110, null, '{}'::text[]),
  ('jp_214od_mh', 'jp', 'classic', 'special', 'OD214中強P', '↓↙←+中P強P', 'OD 強 ヴィーハト（設置）', 65, 110, null, '{}'::text[]),
  ('jp_vihat_akno', 'jp', 'classic', 'special', 'アクノ(ワープ)', '設置中↓↙←+弱or中P', 'ヴィーハト・アクノ（ワープ）', 66, null, null, '{}'::text[]),
  ('jp_vihat_cheni', 'jp', 'classic', 'special', 'チェーニ(フェイント)', '設置中↓↙←+強P', 'ヴィーハト・チェーニ（フェイント）', 67, null, null, '{}'::text[]),
  ('jp_22k', 'jp', 'classic', 'special', '22K', '↓↓+K', 'アムネジア', 68, 3, null, '{}'::text[]),
  ('jp_22odk', 'jp', 'classic', 'special', 'OD22KK', '↓↓+KK', 'OD アムネジア', 69, 1, null, '{}'::text[]),
  ('jp_236lk', 'jp', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 トルバラン', 70, 22, null, array['SA3']),
  ('jp_236mk', 'jp', 'classic', 'special', '236中K', '↓↘→+中K', '中 トルバラン', 71, 26, 6, array['SA3']),
  ('jp_236hk', 'jp', 'classic', 'special', '236強K', '↓↘→+強K', '強 トルバラン', 72, 26, 6, array['SA3']),
  ('jp_236k_feint', 'jp', 'classic', 'special', '236K(フェイント)', '↓↘→+Kホールド', 'トルバラン（フェイント）', 73, null, null, '{}'::text[]),
  ('jp_236odk', 'jp', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD トルバラン', 74, 22, null, array['SA2']),
  ('jp_214k', 'jp', 'classic', 'special', '214K', '↓↙←+K', 'アブニマーチ', 75, 26, null, '{}'::text[]),
  ('jp_214odk', 'jp', 'classic', 'special', 'OD214KK', '↓↙←+KK', 'OD アブニマーチ', 76, 26, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 3種: 85〜87、CA除外）
  ('jp_sa1', 'jp', 'classic', 'super', 'SA1', '↓↘→↓↘→+P', 'SA1 チェルノボーグ', 85, 8, null, '{}'::text[]),
  ('jp_sa2', 'jp', 'classic', 'super', 'SA2', '↓↙←↓↙←+P', 'SA2 ラヴーシュカ', 86, 29, null, '{}'::text[]),
  ('jp_sa3', 'jp', 'classic', 'super', 'SA3', '↓↘→↓↘→+K', 'SA3 ザプリェット', 87, 18, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 3種: 95〜97）
  ('jp_throw_f', 'jp', 'classic', 'throw', '前投げ', '弱P+弱K', 'ラヴィーナ（前投げ）', 95, 5, null, '{}'::text[]),
  ('jp_throw_b', 'jp', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'ウラガーン（後ろ投げ）', 96, 5, null, '{}'::text[]),
  ('jp_throw_air', 'jp', 'classic', 'throw', '空投げ', '空中で弱P+弱K', 'タルナード（空中投げ）', 97, 5, null, '{}'::text[]),

  -- 6. JP固有システム補助パーツ（共通 1種: 100）
  ('jp_vihat_explode', 'jp', 'both', 'system', 'ヴィーハト爆発', 'ヴィーハト爆発', 'ヴィーハト（時間差爆発）', 100, null, null, '{}'::text[]),

  -- 7. モダン通常技（9種: 110〜118）
  ('jp_m_5l', 'jp', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 6, 4, array['C']),
  ('jp_m_5m', 'jp', 'modern', 'normal', '5中', '中', '立ち中（立ち中K）', 111, 8, 3, array['C']),
  ('jp_m_5h', 'jp', 'modern', 'normal', '5強', '強', '立ち強（立ち強K）', 112, 12, 7, '{}'::text[]),
  ('jp_m_2l', 'jp', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱P）', 113, 4, 4, array['C']),
  ('jp_m_2m', 'jp', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 114, 9, 3, '{}'::text[]),
  ('jp_m_2h', 'jp', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 115, 9, 1, array['C']),
  ('jp_m_jl', 'jp', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 116, 5, null, '{}'::text[]),
  ('jp_m_jm', 'jp', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中K）', 117, 7, null, '{}'::text[]),
  ('jp_m_jh', 'jp', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 118, 11, null, '{}'::text[]),

  -- 8. モダン特殊技・アシスト（18種: 125〜142）
  ('jp_m_auto_l', 'jp', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・しゃがみ弱K）', 125, 6, 2, '{}'::text[]),
  ('jp_m_auto_m', 'jp', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・しゃがみ中P）', 126, 7, 6, array['C']),
  ('jp_m_auto_h', 'jp', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち強P）', 127, 12, 3, array['C']),
  ('jp_m_j_auto_l', 'jp', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 128, 6, null, '{}'::text[]),
  ('jp_m_j_auto_m', 'jp', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中P）', 129, 12, null, '{}'::text[]),
  ('jp_m_j_auto_h', 'jp', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 130, 9, null, '{}'::text[]),
  ('jp_m_auto_l_combo', 'jp', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 131, 6, null, '{}'::text[]),
  ('jp_m_auto_2l_combo', 'jp', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 132, 4, null, '{}'::text[]),
  ('jp_m_auto_m_combo', 'jp', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 133, 7, null, '{}'::text[]),
  ('jp_m_auto_h_combo', 'jp', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 134, 12, null, '{}'::text[]),
  ('jp_m_6m', 'jp', 'modern', 'unique', '6中', '→+中', 'ギリオチーナ', 135, 22, 3, '{}'::text[]),
  ('jp_m_3h', 'jp', 'modern', 'unique', '3強', '↘+強', 'シャーロスチ', 136, 16, null, '{}'::text[]),
  ('jp_m_6h', 'jp', 'modern', 'unique', '6強', '→+強', 'ヴィリーナ', 137, 11, null, array['C']),
  ('jp_m_4m', 'jp', 'modern', 'unique', '4中', '←+中', 'グロームストレルカ（1段目）', 138, 8, 5, array['C']),
  ('jp_m_4m_2', 'jp', 'modern', 'unique', '4中>中', '←+中>中', 'グロームストレルカ（2段目）', 139, 10, 3, array['C']),
  ('jp_m_tc_5h_h', 'jp', 'modern', 'unique', '5強>強', '強>強', 'ジラント', 140, 20, 3, array['C']),
  ('jp_m_tc_5h_h_h', 'jp', 'modern', 'unique', '5強>強>強', '強>強>強', 'ジラントルカー', 141, 21, 3, '{}'::text[]),
  ('jp_m_tc_5h_h_4h', 'jp', 'modern', 'unique', '5強>強>4強', '強>強>←+強', 'ジラントナガー', 142, 21, 3, '{}'::text[]),

  -- 9. モダン必殺技：ワンボタンSP＆OD版（10種: 150〜159）
  ('jp_m_sp', 'jp', 'modern', 'special', 'N必', 'SP', '中 トリグラフ（N必）', 150, 22, null, array['SA3']),
  ('jp_m_od_sp', 'jp', 'modern', 'special', 'A+N必', 'A+SP', 'OD 中 トリグラフ（A+N必）', 151, 20, null, array['SA2']),
  ('jp_m_1sp', 'jp', 'modern', 'special', '左下必', '↙+SP', '弱 ストリボーグ（左下必）', 152, 16, null, array['SA3']),
  ('jp_m_2sp', 'jp', 'modern', 'special', '下必', '↓+SP', '中 ストリボーグ（下必）', 153, 20, null, array['SA3']),
  ('jp_m_3sp', 'jp', 'modern', 'special', '右下必', '↘+SP', '強 ストリボーグ（右下必）', 154, 28, null, array['SA3']),
  ('jp_m_od_2sp', 'jp', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD ストリボーグ（A+下必）', 155, 19, null, array['SA2']),
  ('jp_m_6sp', 'jp', 'modern', 'special', '前必', '→+SP', 'アムネジア（前必）', 156, 3, null, '{}'::text[]),
  ('jp_m_od_6sp', 'jp', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD アムネジア（A+前必）', 157, 1, null, '{}'::text[]),
  ('jp_m_4sp', 'jp', 'modern', 'special', '後必', '←+SP', 'アブニマーチ（後必）', 158, 26, null, '{}'::text[]),
  ('jp_m_od_4sp', 'jp', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD アブニマーチ（A+後必）', 159, 26, null, '{}'::text[]),

  -- 10. モダン必殺技：コマンド入力版（19種: 165〜183）
  ('jp_m_22l', 'jp', 'modern', 'special', '22弱', '↓↓+弱', '弱 トリグラフ', 165, 22, null, array['SA3']),
  ('jp_m_22m', 'jp', 'modern', 'special', '22中', '↓↓+中', '中 トリグラフ', 166, 22, null, array['SA3']),
  ('jp_m_22h', 'jp', 'modern', 'special', '22強', '↓↓+強', '強 トリグラフ', 167, 22, null, array['SA3']),
  ('jp_m_22od_lm', 'jp', 'modern', 'special', 'OD22弱中', '↓↓+弱+中', 'OD 弱 トリグラフ', 168, 20, null, array['SA2']),
  ('jp_m_22od_lh', 'jp', 'modern', 'special', 'OD22弱強', '↓↓+弱+強', 'OD 中 トリグラフ', 169, 20, null, array['SA2']),
  ('jp_m_22od_mh', 'jp', 'modern', 'special', 'OD22中強', '↓↓+中+強', 'OD 強 トリグラフ', 170, 20, null, array['SA2']),
  ('jp_m_214l', 'jp', 'modern', 'special', '214弱', '↓↙←+弱', '弱 ヴィーハト（設置）', 171, 150, null, '{}'::text[]),
  ('jp_m_214m', 'jp', 'modern', 'special', '214中', '↓↙←+中', '中 ヴィーハト（設置）', 172, 150, null, '{}'::text[]),
  ('jp_m_214h', 'jp', 'modern', 'special', '214強', '↓↙←+強', '強 ヴィーハト（設置）', 173, 150, null, '{}'::text[]),
  ('jp_m_214od_lm', 'jp', 'modern', 'special', 'OD214弱中', '↓↙←+弱+中', 'OD 弱 ヴィーハト（設置）', 174, 110, null, '{}'::text[]),
  ('jp_m_214od_lh', 'jp', 'modern', 'special', 'OD214弱強', '↓↙←+弱+強', 'OD 中 ヴィーハト（設置）', 175, 110, null, '{}'::text[]),
  ('jp_m_214od_mh', 'jp', 'modern', 'special', 'OD214中強', '↓↙←+中+強', 'OD 強 ヴィーハト（設置）', 176, 110, null, '{}'::text[]),
  ('jp_m_vihat_akno', 'jp', 'modern', 'special', 'アクノ(ワープ)', '設置中↓↙←+弱or中', 'ヴィーハト・アクノ（ワープ）', 177, null, null, '{}'::text[]),
  ('jp_m_vihat_cheni', 'jp', 'modern', 'special', 'チェーニ(フェイント)', '設置中↓↙←+強', 'ヴィーハト・チェーニ（フェイント）', 178, null, null, '{}'::text[]),
  ('jp_m_236l', 'jp', 'modern', 'special', '236弱', '↓↘→+弱', '弱 トルバラン', 179, 22, null, array['SA3']),
  ('jp_m_236m', 'jp', 'modern', 'special', '236中', '↓↘→+中', '中 トルバラン', 180, 26, 6, array['SA3']),
  ('jp_m_236h', 'jp', 'modern', 'special', '236強', '↓↘→+強', '強 トルバラン', 181, 26, 6, array['SA3']),
  ('jp_m_236_feint', 'jp', 'modern', 'special', '236攻撃(フェイント)', '↓↘→+攻撃ホールド', 'トルバラン（フェイント）', 182, null, null, '{}'::text[]),
  ('jp_m_236od', 'jp', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD トルバラン', 183, 22, null, array['SA2']),

  -- 11. モダンスーパーアーツ（3種: 190〜192、CA除外）
  ('jp_m_sa1', 'jp', 'modern', 'super', 'SA1', 'SP+強', 'SA1 チェルノボーグ', 190, 8, null, '{}'::text[]),
  ('jp_m_sa2', 'jp', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 ラヴーシュカ', 191, 29, null, '{}'::text[]),
  ('jp_m_sa3', 'jp', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 ザプリェット', 192, 18, null, '{}'::text[]),

  -- 12. モダン通常投げ（3種: 200〜202）
  ('jp_m_throw_f', 'jp', 'modern', 'throw', '前投げ', '弱+中', 'ラヴィーナ（前投げ）', 200, 5, null, '{}'::text[]),
  ('jp_m_throw_b', 'jp', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'ウラガーン（後ろ投げ）', 201, 5, null, '{}'::text[]),
  ('jp_m_throw_air', 'jp', 'modern', 'throw', '空投げ', '空中で弱+中', 'タルナード（空中投げ）', 202, 5, null, '{}'::text[])
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
