-- =============================================================================
-- Migration: 021_add_marisa_manon.sql
-- 目的: 27人目「マリーザ（marisa）」・28人目「マノン（manon）」のキャラクターマスタおよび
--       全技マスタ（マリーザ全163技＋マノン全102技＝計265技・
--       公式フレームデータ＆コマンドリスト準拠・CA除外）を
--       既存の Supabase 本番 DB へ安全・冪等に UPSERT する
-- 前提: 001_add_throw_category.sql を先に適用済みであること
-- =============================================================================

-- 1. キャラクターマスタへマリーザ・マノンを追加・更新
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
  ('marisa', 'marisa', 'マリーザ', 'Marisa', 27, true, null, null, null),
  ('manon', 'manon', 'マノン', 'Manon', 28, true, null, null, null)
on conflict (id) do update set
  slug = excluded.slug,
  name_ja = excluded.name_ja,
  name_en = excluded.name_en,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  stock_label = excluded.stock_label,
  stock_short_label = excluded.stock_short_label,
  stock_max_count = excluded.stock_max_count;

-- 2. マリーザ・マノン全技マスタ（計265技）を UPSERT
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
  -- マリーザ（marisa）全163技（クラシック80種＋モダン83種）
  -- =========================================================================

  -- 1. 通常技（クラシック 24種: 立ち 10〜17 / しゃがみ 20〜27 / ジャンプ 30〜37、ホールド版含む）
  ('marisa_5lp', 'marisa', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（ライトパンチ）', 10, 6, 0, array[]::text[]),
  ('marisa_5lk', 'marisa', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（ティビアブレイク）', 11, 6, 0, array['C']),
  ('marisa_5mp', 'marisa', 'classic', 'normal', '5中P', '中P', '立ち中P（ミドルパンチ）', 12, 7, 2, array[]::text[]),
  ('marisa_5mk', 'marisa', 'classic', 'normal', '5中K', '中K', '立ち中K（スターナムブレイク）', 13, 11, 4, array[]::text[]),
  ('marisa_5hp', 'marisa', 'classic', 'normal', '5強P', '強P', '立ち強P（ヘビィーパンチ）', 14, 12, 3, array[]::text[]),
  ('marisa_5hp_hold', 'marisa', 'classic', 'normal', '5強P(ホールド)', '強Pホールド', '立ち強P（ヘビィーパンチ）（ホールド）', 15, 23, 7, array[]::text[]),
  ('marisa_5hk', 'marisa', 'classic', 'normal', '5強K', '強K', '立ち強K（リブブレイク）', 16, 15, 1, array[]::text[]),
  ('marisa_5hk_hold', 'marisa', 'classic', 'normal', '5強K(ホールド)', '強Kホールド', '立ち強K（リブブレイク）（ホールド）', 17, 24, null, array[]::text[]),
  ('marisa_2lp', 'marisa', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（アンダーライト）', 20, 4, 4, array['C']),
  ('marisa_2lk', 'marisa', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（フットバッシュ）', 21, 5, 2, array[]::text[]),
  ('marisa_2mp', 'marisa', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（アンダーミドル）', 22, 8, 3, array['C']),
  ('marisa_2mk', 'marisa', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（レッグバッシュ）', 23, 9, 5, array[]::text[]),
  ('marisa_2hp', 'marisa', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（ハーフハート）', 24, 9, null, array[]::text[]),
  ('marisa_2hp_hold', 'marisa', 'classic', 'normal', '2強P(ホールド)', '↓+強Pホールド', 'しゃがみ強P（ハーフハート）（ホールド）', 25, 21, null, array['SA']),
  ('marisa_2hk', 'marisa', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（ガイアバッシュ）', 26, 11, null, array[]::text[]),
  ('marisa_2hk_hold', 'marisa', 'classic', 'normal', '2強K(ホールド)', '↓+強Kホールド', 'しゃがみ強K（ガイアバッシュ）（ホールド）', 27, 20, null, array[]::text[]),
  ('marisa_jlp', 'marisa', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（ノックフィスト）', 30, 4, null, array[]::text[]),
  ('marisa_jlk', 'marisa', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（シグナスフォール）', 31, 5, null, array[]::text[]),
  ('marisa_jmp', 'marisa', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（ヴォラーレフィスト）', 32, 7, null, array[]::text[]),
  ('marisa_jmk', 'marisa', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（ラブリュスフォール）', 33, 8, null, array[]::text[]),
  ('marisa_jhp', 'marisa', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（アイテルフィスト）', 34, 10, null, array[]::text[]),
  ('marisa_jhp_hold', 'marisa', 'classic', 'normal', 'J強P(ホールド)', '空中で強Pホールド', 'ジャンプ強P（アイテルフィスト）（ホールド）', 35, 28, null, array[]::text[]),
  ('marisa_jhk', 'marisa', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（ウラノスフォール）', 36, 10, null, array[]::text[]),
  ('marisa_jhk_hold', 'marisa', 'classic', 'normal', 'J強K(ホールド)', '空中で強Kホールド', 'ジャンプ強K（ウラノスフォール）（ホールド）', 37, 29, null, array[]::text[]),

  -- 2. 特殊技＆ターゲットコンボ（クラシック 17種: 40〜56、ホールド版含む）
  ('marisa_tc_lp', 'marisa', 'classic', 'unique', '5弱P>弱P', '弱P>弱P', 'ライトワンツー', 40, 14, -3, array['C']),
  ('marisa_tc_mp', 'marisa', 'classic', 'unique', '5中P>中P', '中P>中P', 'ミドルワンツー', 41, 14, -3, array['C']),
  ('marisa_tc_hp', 'marisa', 'classic', 'unique', '5強P>強P', '強P>強P', 'ヘビィーワンツー', 42, 24, null, array[]::text[]),
  ('marisa_tc_jmp', 'marisa', 'classic', 'unique', 'J中P>中P', '空中で中P>中P', 'ヴォラーレコンボ', 43, 10, null, array[]::text[]),
  ('marisa_j2hp', 'marisa', 'classic', 'unique', '垂直J2強P', '垂直J中↓+強P', 'カエルムアーク', 44, 9, null, array[]::text[]),
  ('marisa_j2hp_hold', 'marisa', 'classic', 'unique', '垂直J2強P(ホールド)', '垂直J中↓+強Pホールド', 'カエルムアーク（ホールド）', 45, 28, null, array[]::text[]),
  ('marisa_4hp', 'marisa', 'classic', 'unique', '4強P', '←+強P', 'マグナバンカー', 46, 8, 3, array['C']),
  ('marisa_4hp_hold', 'marisa', 'classic', 'unique', '4強P(ホールド)', '←+強Pホールド', 'マグナバンカー（ホールド）', 47, 20, 13, array['C']),
  ('marisa_6mp', 'marisa', 'classic', 'unique', '6中P', '→+中P', 'ノバキュラスワイプ/シュート（1段目）', 48, 9, 2, array[]::text[]),
  ('marisa_tc_swipe', 'marisa', 'classic', 'unique', '6中P>強P', '→+中P>強P', 'ノバキュラスワイプ', 49, 11, null, array[]::text[]),
  ('marisa_tc_shoot', 'marisa', 'classic', 'unique', '6中P>強K', '→+中P>強K', 'ノバキュラシュート', 50, 11, null, array['SA']),
  ('marisa_3hp', 'marisa', 'classic', 'unique', '3強P', '↘+強P', 'マレウスビート（1段目）', 51, 21, 0, array[]::text[]),
  ('marisa_3hp_hold', 'marisa', 'classic', 'unique', '3強P(ホールド)', '↘+強Pホールド', 'マレウスビート（1段目）（ホールド）', 52, 28, 5, array[]::text[]),
  ('marisa_tc_malleus2', 'marisa', 'classic', 'unique', '3強P>3強P', '↘+強P>↘+強P', 'マレウスビート（2段目）', 53, 18, null, array[]::text[]),
  ('marisa_6hk', 'marisa', 'classic', 'unique', '6強K', '→+強K', 'ファルクスクラッシュ（1段目）', 54, 14, 4, array['C']),
  ('marisa_6hk_hold', 'marisa', 'classic', 'unique', '6強K(ホールド)', '→+強Kホールド', 'ファルクスクラッシュ（1段目）（ホールド）', 55, 27, 10, array['C']),
  ('marisa_tc_falx2', 'marisa', 'classic', 'unique', '6強K>6強K', '→+強K>→+強K', 'ファルクスクラッシュ（2段目）', 56, 16, null, array[]::text[]),

  -- 3. 必殺技（クラシック 32種: 60〜91）
  ('marisa_236lp', 'marisa', 'classic', 'special', '236弱P', '↓↘→+弱P', '弱 グラディウス', 60, 17, null, array['SA3']),
  ('marisa_236lp_hold', 'marisa', 'classic', 'special', '236弱P(ホールド)', '↓↘→+弱Pホールド', '弱 グラディウス（ホールド）', 61, 30, null, array['SA3']),
  ('marisa_236mp', 'marisa', 'classic', 'special', '236中P', '↓↘→+中P', '中 グラディウス', 62, 19, null, array['SA3']),
  ('marisa_236mp_hold', 'marisa', 'classic', 'special', '236中P(ホールド)', '↓↘→+中Pホールド', '中 グラディウス（ホールド）', 63, 35, null, array['SA3']),
  ('marisa_236hp', 'marisa', 'classic', 'special', '236強P', '↓↘→+強P', '強 グラディウス', 64, 22, null, array['SA3']),
  ('marisa_236hp_hold', 'marisa', 'classic', 'special', '236強P(ホールド)', '↓↘→+強Pホールド', '強 グラディウス（ホールド）', 65, 41, null, array['SA3']),
  ('marisa_236odp', 'marisa', 'classic', 'special', 'OD236PP', '↓↘→+PP', 'OD グラディウス', 66, 19, null, array['SA2']),
  ('marisa_236odp_hold', 'marisa', 'classic', 'special', 'OD236PP(ホールド)', '↓↘→+PPホールド', 'OD グラディウス（ホールド）', 67, 35, null, array['SA2']),
  ('marisa_214lp', 'marisa', 'classic', 'special', '214弱P', '↓↙←+弱P', '弱 ディマカイルス（1段目）', 68, 12, -3, array['SA3']),
  ('marisa_dimachaerus_l_2', 'marisa', 'classic', 'special', '弱ディマカ2段目', '弱ディマカ>→+P', '弱 ディマカイルス（2段目）', 69, 13, null, array[]::text[]),
  ('marisa_214mp', 'marisa', 'classic', 'special', '214中P', '↓↙←+中P', '中 ディマカイルス（1段目）', 70, 16, 0, array['SA3']),
  ('marisa_dimachaerus_m_2', 'marisa', 'classic', 'special', '中ディマカ2段目', '中ディマカ>→+P', '中 ディマカイルス（2段目）', 71, 13, null, array[]::text[]),
  ('marisa_214hp', 'marisa', 'classic', 'special', '214強P', '↓↙←+強P', '強 ディマカイルス（1段目）', 72, 22, null, array['SA3']),
  ('marisa_dimachaerus_h_2', 'marisa', 'classic', 'special', '強ディマカ2段目', '強ディマカ>→+P', '強 ディマカイルス（2段目）', 73, 18, null, array[]::text[]),
  ('marisa_214odp', 'marisa', 'classic', 'special', 'OD214PP', '↓↙←+PP', 'OD ディマカイルス（1段目）', 74, 16, null, array['SA2']),
  ('marisa_dimachaerus_od_2', 'marisa', 'classic', 'special', 'ODディマカ2段目', 'ODディマカ>→+P', 'OD ディマカイルス（2段目）', 75, 13, null, array[]::text[]),
  ('marisa_623lp', 'marisa', 'classic', 'special', '623弱P', '→↓↘+弱P', '弱 ファランクス', 76, 25, null, array[]::text[]),
  ('marisa_623mp', 'marisa', 'classic', 'special', '623中P', '→↓↘+中P', '中 ファランクス', 77, 28, null, array[]::text[]),
  ('marisa_623hp', 'marisa', 'classic', 'special', '623強P', '→↓↘+強P', '強 ファランクス', 78, 32, null, array[]::text[]),
  ('marisa_623odp', 'marisa', 'classic', 'special', 'OD623PP', '→↓↘+PP', 'OD ファランクス', 79, 28, null, array[]::text[]),
  ('marisa_236lk', 'marisa', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 クアドリガ', 80, 20, null, array['SA3']),
  ('marisa_236mk', 'marisa', 'classic', 'special', '236中K', '↓↘→+中K', '中 クアドリガ', 81, 24, null, array['SA3']),
  ('marisa_236hk', 'marisa', 'classic', 'special', '236強K', '↓↘→+強K', '強 クアドリガ', 82, 29, null, array['SA3']),
  ('marisa_236odk', 'marisa', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD クアドリガ', 83, 24, null, array['SA2']),
  ('marisa_214k', 'marisa', 'classic', 'special', '214K', '↓↙←+K', 'スクトゥム', 84, null, null, array[]::text[]),
  ('marisa_scutum_counter', 'marisa', 'classic', 'special', 'スクトゥム(当身)', 'スクトゥム中打撃受け', 'スクトゥム（当身派生版）', 85, 7, -1, array[]::text[]),
  ('marisa_214odk', 'marisa', 'classic', 'special', 'OD214KK', '↓↙←+KK', 'OD スクトゥム', 86, null, null, array[]::text[]),
  ('marisa_scutum_od_counter', 'marisa', 'classic', 'special', 'ODスクトゥム(当身)', 'ODスクトゥム中打撃受け', 'OD スクトゥム（当身派生版）', 87, 7, -1, array[]::text[]),
  ('marisa_tonitrus_1', 'marisa', 'classic', 'special', 'トニトルス1段目', 'スクトゥム中P', 'トニトルス（1段目）', 88, 15, 1, array[]::text[]),
  ('marisa_tonitrus_2', 'marisa', 'classic', 'special', 'トニトルス2段目', 'スクトゥム中P>P', 'トニトルス（2段目）', 89, 19, null, array[]::text[]),
  ('marisa_procella', 'marisa', 'classic', 'special', 'プロケッラ', 'スクトゥム中K', 'プロケッラ', 90, 16, null, array[]::text[]),
  ('marisa_enfold', 'marisa', 'classic', 'special', 'エンフォルド', 'スクトゥム中弱P+弱K', 'エンフォルド', 91, 5, null, array[]::text[]),

  -- 4. スーパーアーツ（クラシック 5種: 95〜99、SA1ホールド＆当身派生含む・CA除外）
  ('marisa_sa1', 'marisa', 'classic', 'super', 'SA1', '↓↘→↓↘→+P', 'SA1 マリーザジャベリン', 95, 19, null, array[]::text[]),
  ('marisa_sa1_hold', 'marisa', 'classic', 'super', 'SA1(ホールド)', '↓↘→↓↘→+Pホールド', 'SA1 マリーザジャベリン（ホールド）', 96, 42, null, array[]::text[]),
  ('marisa_sa1_counter', 'marisa', 'classic', 'super', 'SA1(当身派生)', 'SA1ホールド中打撃受け', 'SA1 マリーザジャベリン（当身派生版）', 97, 7, null, array[]::text[]),
  ('marisa_sa2', 'marisa', 'classic', 'super', 'SA2', '↓↙←↓↙←+P', 'SA2 メテオリティス', 98, 9, null, array[]::text[]),
  ('marisa_sa3', 'marisa', 'classic', 'super', 'SA3', '↓↘→↓↘→+K', 'SA3 アポロウーサ', 99, 13, null, array[]::text[]),

  -- 5. 通常投げ（クラシック 2種: 105〜106）
  ('marisa_throw_f', 'marisa', 'classic', 'throw', '前投げ', '弱P+弱K', 'マウントグレイズ（前投げ）', 105, 5, null, array[]::text[]),
  ('marisa_throw_b', 'marisa', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'ミルヴィオブリッジ（後ろ投げ）', 106, 5, null, array[]::text[]),

  -- 6. モダン通常技（14種: 110〜123、ホールド版含む）
  ('marisa_m_5l', 'marisa', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 6, 0, array[]::text[]),
  ('marisa_m_5m', 'marisa', 'modern', 'normal', '5中', '中', '立ち中（立ち中K）', 111, 11, 4, array[]::text[]),
  ('marisa_m_5h', 'marisa', 'modern', 'normal', '5強', '強', '立ち強（立ち強P）', 112, 12, 3, array[]::text[]),
  ('marisa_m_5h_hold', 'marisa', 'modern', 'normal', '5強(ホールド)', '強ホールド', '立ち強（立ち強P・ホールド）', 113, 23, 7, array[]::text[]),
  ('marisa_m_2l', 'marisa', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱P）', 114, 4, 4, array['C']),
  ('marisa_m_2m', 'marisa', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中P）', 115, 8, 3, array['C']),
  ('marisa_m_2h', 'marisa', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 116, 9, null, array[]::text[]),
  ('marisa_m_2h_hold', 'marisa', 'modern', 'normal', '2強(ホールド)', '↓+強ホールド', 'しゃがみ強（しゃがみ強P・ホールド）', 117, 21, null, array['SA']),
  ('marisa_m_3h', 'marisa', 'modern', 'normal', '3強', '↘+強', '右下強（ガイアバッシュ）', 118, 11, null, array[]::text[]),
  ('marisa_m_3h_hold', 'marisa', 'modern', 'normal', '3強(ホールド)', '↘+強ホールド', '右下強（ガイアバッシュ・ホールド）', 119, 20, null, array[]::text[]),
  ('marisa_m_jl', 'marisa', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 120, 4, null, array[]::text[]),
  ('marisa_m_jm', 'marisa', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 121, 7, null, array[]::text[]),
  ('marisa_m_jh', 'marisa', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強P）', 122, 10, null, array[]::text[]),
  ('marisa_m_jh_hold', 'marisa', 'modern', 'normal', 'J強(ホールド)', '空中で強ホールド', 'ジャンプ強（ジャンプ強P・ホールド）', 123, 28, null, array[]::text[]),

  -- 7. モダン特殊技・アシスト・TC（24種: 130〜153、ホールド版含む）
  ('marisa_m_auto_l', 'marisa', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・しゃがみ弱K）', 130, 5, 2, array[]::text[]),
  ('marisa_m_auto_m', 'marisa', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・立ち中P）', 131, 7, 2, array[]::text[]),
  ('marisa_m_j_auto_l', 'marisa', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 132, 5, null, array[]::text[]),
  ('marisa_m_j_auto_m', 'marisa', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 133, 8, null, array[]::text[]),
  ('marisa_m_j_auto_h', 'marisa', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強K）', 134, 10, null, array[]::text[]),
  ('marisa_m_j_auto_h_hold', 'marisa', 'modern', 'unique', 'JA強(ホールド)', '空中でアシスト強ホールド', 'ジャンプアシスト強（ジャンプ強K・ホールド）', 135, 29, null, array[]::text[]),
  ('marisa_m_auto_l_combo', 'marisa', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 136, 5, null, array[]::text[]),
  ('marisa_m_auto_2l_combo', 'marisa', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 137, 4, null, array[]::text[]),
  ('marisa_m_auto_m_combo', 'marisa', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 138, 7, null, array[]::text[]),
  ('marisa_m_auto_h_combo', 'marisa', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 139, null, null, array[]::text[]),
  ('marisa_m_tc_l', 'marisa', 'modern', 'unique', '5弱>弱', '弱>弱', 'ライトワンツー', 140, 14, -3, array['C']),
  ('marisa_m_tc_m', 'marisa', 'modern', 'unique', 'A中>中', 'アシスト中>中', 'ミドルワンツー', 141, 14, -3, array['C']),
  ('marisa_m_tc_h', 'marisa', 'modern', 'unique', '5強>強', '強>強', 'ヘビィーワンツー', 142, 24, null, array[]::text[]),
  ('marisa_m_tc_jm', 'marisa', 'modern', 'unique', 'J中>中', '空中で中>中', 'ヴォラーレコンボ', 143, 10, null, array[]::text[]),
  ('marisa_m_j2h', 'marisa', 'modern', 'unique', '垂直J2強', '垂直J中↓+強', 'カエルムアーク', 144, 9, null, array[]::text[]),
  ('marisa_m_j2h_hold', 'marisa', 'modern', 'unique', '垂直J2強(ホールド)', '垂直J中↓+強ホールド', 'カエルムアーク（ホールド）', 145, 28, null, array[]::text[]),
  ('marisa_m_4h', 'marisa', 'modern', 'unique', '4強', '←+強', 'マグナバンカー', 146, 8, 3, array['C']),
  ('marisa_m_4h_hold', 'marisa', 'modern', 'unique', '4強(ホールド)', '←+強ホールド', 'マグナバンカー（ホールド）', 147, 20, 13, array['C']),
  ('marisa_m_6m', 'marisa', 'modern', 'unique', '6中', '→+中', 'ノバキュラスワイプ/シュート（1段目）', 148, 9, 2, array[]::text[]),
  ('marisa_m_tc_swipe', 'marisa', 'modern', 'unique', '6中>中', '→+中>中', 'ノバキュラスワイプ', 149, 11, null, array[]::text[]),
  ('marisa_m_tc_shoot', 'marisa', 'modern', 'unique', '6中>強', '→+中>強', 'ノバキュラシュート', 150, 11, null, array['SA']),
  ('marisa_m_6h', 'marisa', 'modern', 'unique', '6強', '→+強', 'ファルクスクラッシュ（1段目）', 151, 14, 4, array['C']),
  ('marisa_m_6h_hold', 'marisa', 'modern', 'unique', '6強(ホールド)', '→+強ホールド', 'ファルクスクラッシュ（1段目）（ホールド）', 152, 27, 10, array['C']),
  ('marisa_m_tc_falx2', 'marisa', 'modern', 'unique', '6強>6強', '→+強>→+強', 'ファルクスクラッシュ（2段目）', 153, 16, null, array[]::text[]),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（12種: 160〜171）
  ('marisa_m_sp', 'marisa', 'modern', 'special', 'N必', 'SP', '弱 グラディウス（N必）', 160, 17, null, array['SA3']),
  ('marisa_m_sp_hold', 'marisa', 'modern', 'special', 'N必(ホールド)', 'SPホールド', '弱 グラディウス（ホールド・N必）', 161, 30, null, array['SA3']),
  ('marisa_m_od_sp', 'marisa', 'modern', 'special', 'A+N必', 'A+SP', 'OD グラディウス（A+N必）', 162, 19, null, array['SA2']),
  ('marisa_m_od_sp_hold', 'marisa', 'modern', 'special', 'A+N必(ホールド)', 'A+SPホールド', 'OD グラディウス（ホールド・A+N必）', 163, 35, null, array['SA2']),
  ('marisa_m_4sp', 'marisa', 'modern', 'special', '後必', '←+SP', '中 ファランクス（後必）', 164, 28, null, array[]::text[]),
  ('marisa_m_od_4sp', 'marisa', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD ファランクス（A+後必）', 165, 28, null, array[]::text[]),
  ('marisa_m_1sp', 'marisa', 'modern', 'special', '左下必', '↙+SP', '弱 クアドリガ（左下必）', 166, 20, null, array['SA3']),
  ('marisa_m_2sp', 'marisa', 'modern', 'special', '下必', '↓+SP', '中 クアドリガ（下必）', 167, 24, null, array['SA3']),
  ('marisa_m_3sp', 'marisa', 'modern', 'special', '右下必', '↘+SP', '強 クアドリガ（右下必）', 168, 29, null, array['SA3']),
  ('marisa_m_od_2sp', 'marisa', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD クアドリガ（A+下必）', 169, 24, null, array['SA2']),
  ('marisa_m_6sp', 'marisa', 'modern', 'special', '前必', '→+SP', 'スクトゥム（前必）', 170, null, null, array[]::text[]),
  ('marisa_m_od_6sp', 'marisa', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD スクトゥム（A+前必）', 171, null, null, array[]::text[]),

  -- 9. モダン必殺技：コマンド入力版＆派生技（26種: 175〜200）
  ('marisa_m_236l', 'marisa', 'modern', 'special', '236弱', '↓↘→+弱', '弱 グラディウス', 175, 17, null, array['SA3']),
  ('marisa_m_236l_hold', 'marisa', 'modern', 'special', '236弱(ホールド)', '↓↘→+弱ホールド', '弱 グラディウス（ホールド）', 176, 30, null, array['SA3']),
  ('marisa_m_236m', 'marisa', 'modern', 'special', '236中', '↓↘→+中', '中 グラディウス', 177, 19, null, array['SA3']),
  ('marisa_m_236m_hold', 'marisa', 'modern', 'special', '236中(ホールド)', '↓↘→+中ホールド', '中 グラディウス（ホールド）', 178, 35, null, array['SA3']),
  ('marisa_m_236h', 'marisa', 'modern', 'special', '236強', '↓↘→+強', '強 グラディウス', 179, 22, null, array['SA3']),
  ('marisa_m_236h_hold', 'marisa', 'modern', 'special', '236強(ホールド)', '↓↘→+強ホールド', '強 グラディウス（ホールド）', 180, 41, null, array['SA3']),
  ('marisa_m_236od', 'marisa', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD グラディウス', 181, 19, null, array['SA2']),
  ('marisa_m_236od_hold', 'marisa', 'modern', 'special', 'OD236(ホールド)', '↓↘→+攻撃×2ホールド', 'OD グラディウス（ホールド）', 182, 35, null, array['SA2']),
  ('marisa_m_214l', 'marisa', 'modern', 'special', '214弱', '↓↙←+弱', '弱 ディマカイルス（1段目）', 183, 12, -3, array['SA3']),
  ('marisa_m_dimachaerus_l_2', 'marisa', 'modern', 'special', '弱ディマカ2段目', '弱ディマカ>→+攻撃', '弱 ディマカイルス（2段目）', 184, 13, null, array[]::text[]),
  ('marisa_m_214m', 'marisa', 'modern', 'special', '214中', '↓↙←+中', '中 ディマカイルス（1段目）', 185, 16, 0, array['SA3']),
  ('marisa_m_dimachaerus_m_2', 'marisa', 'modern', 'special', '中ディマカ2段目', '中ディマカ>→+攻撃', '中 ディマカイルス（2段目）', 186, 13, null, array[]::text[]),
  ('marisa_m_214h', 'marisa', 'modern', 'special', '214強', '↓↙←+強', '強 ディマカイルス（1段目）', 187, 22, null, array['SA3']),
  ('marisa_m_dimachaerus_h_2', 'marisa', 'modern', 'special', '強ディマカ2段目', '強ディマカ>→+攻撃', '強 ディマカイルス（2段目）', 188, 18, null, array[]::text[]),
  ('marisa_m_214od', 'marisa', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD ディマカイルス（1段目）', 189, 16, null, array['SA2']),
  ('marisa_m_dimachaerus_od_2', 'marisa', 'modern', 'special', 'ODディマカ2段目', 'ODディマカ>→+攻撃', 'OD ディマカイルス（2段目）', 190, 13, null, array[]::text[]),
  ('marisa_m_623l', 'marisa', 'modern', 'special', '623弱', '→↓↘+弱', '弱 ファランクス', 191, 25, null, array[]::text[]),
  ('marisa_m_623m', 'marisa', 'modern', 'special', '623中', '→↓↘+中', '中 ファランクス', 192, 28, null, array[]::text[]),
  ('marisa_m_623h', 'marisa', 'modern', 'special', '623強', '→↓↘+強', '強 ファランクス', 193, 32, null, array[]::text[]),
  ('marisa_m_623od', 'marisa', 'modern', 'special', 'OD623', '→↓↘+攻撃×2', 'OD ファランクス', 194, 28, null, array[]::text[]),
  ('marisa_m_scutum_counter', 'marisa', 'modern', 'special', 'スクトゥム(当身)', 'スクトゥム中打撃受け', 'スクトゥム（当身派生版）', 195, 7, -1, array[]::text[]),
  ('marisa_m_scutum_od_counter', 'marisa', 'modern', 'special', 'ODスクトゥム(当身)', 'ODスクトゥム中打撃受け', 'OD スクトゥム（当身派生版）', 196, 7, -1, array[]::text[]),
  ('marisa_m_tonitrus_1', 'marisa', 'modern', 'special', 'トニトルス1段目', 'スクトゥム中N/→+攻撃', 'トニトルス（1段目）', 197, 15, 1, array[]::text[]),
  ('marisa_m_tonitrus_2', 'marisa', 'modern', 'special', 'トニトルス2段目', 'スクトゥム中N/→+攻撃×2', 'トニトルス（2段目）', 198, 19, null, array[]::text[]),
  ('marisa_m_procella', 'marisa', 'modern', 'special', 'プロケッラ', 'スクトゥム中←+攻撃', 'プロケッラ', 199, 16, null, array[]::text[]),
  ('marisa_m_enfold', 'marisa', 'modern', 'special', 'エンフォルド', 'スクトゥム中↓+攻撃', 'エンフォルド', 200, 5, null, array[]::text[]),

  -- 10. モダンスーパーアーツ（5種: 205〜209、SA1ホールド＆当身派生含む・CA除外）
  ('marisa_m_sa1', 'marisa', 'modern', 'super', 'SA1', 'SP+強', 'SA1 マリーザジャベリン', 205, 19, null, array[]::text[]),
  ('marisa_m_sa1_hold', 'marisa', 'modern', 'super', 'SA1(ホールド)', 'SP+強ホールド', 'SA1 マリーザジャベリン（ホールド）', 206, 42, null, array[]::text[]),
  ('marisa_m_sa1_counter', 'marisa', 'modern', 'super', 'SA1(当身派生)', 'SA1ホールド中打撃受け', 'SA1 マリーザジャベリン（当身派生版）', 207, 7, null, array[]::text[]),
  ('marisa_m_sa2', 'marisa', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 メテオリティス', 208, 9, null, array[]::text[]),
  ('marisa_m_sa3', 'marisa', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 アポロウーサ', 209, 13, null, array[]::text[]),

  -- 11. モダン通常投げ（2種: 215〜216）
  ('marisa_m_throw_f', 'marisa', 'modern', 'throw', '前投げ', '弱+中', 'マウントグレイズ（前投げ）', 215, 5, null, array[]::text[]),
  ('marisa_m_throw_b', 'marisa', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'ミルヴィオブリッジ（後ろ投げ）', 216, 5, null, array[]::text[]),

  -- =========================================================================
  -- マノン（manon）全102技（クラシック49種＋モダン53種）
  -- =========================================================================

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('manon_5lp', 'manon', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（ハジメ）', 10, 4, 4, array['C']),
  ('manon_5lk', 'manon', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（タンジュ）', 11, 5, 2, array['C']),
  ('manon_5mp', 'manon', 'classic', 'normal', '5中P', '中P', '立ち中P（ツリテ）', 12, 7, 2, array['C']),
  ('manon_5mk', 'manon', 'classic', 'normal', '5中K', '中K', '立ち中K（ラ・シェーヌ）', 13, 10, 0, array['C']),
  ('manon_5hp', 'manon', 'classic', 'normal', '5強P', '強P', '立ち強P（ランドリ）', 14, 10, 0, array['SA']),
  ('manon_5hk', 'manon', 'classic', 'normal', '5強K', '強K', '立ち強K（ピエ・ドンジュ）', 15, 15, null, array[]::text[]),
  ('manon_2lp', 'manon', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（ソデキリ）', 20, 4, 3, array['C']),
  ('manon_2lk', 'manon', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（シーニュ・ナジェ）', 21, 5, -1, array[]::text[]),
  ('manon_2mp', 'manon', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（ヒキテ）', 22, 7, 6, array['C']),
  ('manon_2mk', 'manon', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（ストゥニュー）', 23, 8, 4, array[]::text[]),
  ('manon_2hp', 'manon', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（ヴィクトワール・ポーム）', 24, 10, -2, array[]::text[]),
  ('manon_2hk', 'manon', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（クロワゼ）', 25, 11, null, array[]::text[]),
  ('manon_jlp', 'manon', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（シエル・クーデ）', 30, 5, null, array[]::text[]),
  ('manon_jlk', 'manon', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（シエル・パッセ）', 31, 6, null, array[]::text[]),
  ('manon_jmp', 'manon', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（クロワゼ・ドゥヴァン）', 32, 8, null, array[]::text[]),
  ('manon_jmk', 'manon', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（アレグロ）', 33, 7, null, array[]::text[]),
  ('manon_jhp', 'manon', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（グロワール・ポーム）', 34, 9, null, array[]::text[]),
  ('manon_jhk', 'manon', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（カブリオール）', 35, 11, null, array[]::text[]),

  -- 2. 特殊技＆ターゲットコンボ（クラシック 7種: 40〜46）
  ('manon_4hp', 'manon', 'classic', 'unique', '4強P', '←+強P', 'レベランス', 40, 8, 3, array['C']),
  ('manon_3hk', 'manon', 'classic', 'unique', '3強K', '↘+強K', 'トモエ・デリエール', 41, 11, 26, array[]::text[]),
  ('manon_tc_aterre', 'manon', 'classic', 'unique', '5中P>中K', '中P>中K', 'ア・テール', 42, 10, 2, array[]::text[]),
  ('manon_4mk', 'manon', 'classic', 'unique', '4中K', '←+中K', 'アン・オー（1段目）', 43, 10, -1, array[]::text[]),
  ('manon_tc_enhaut2', 'manon', 'classic', 'unique', '4中K>中K', '←+中K>中K', 'アン・オー（2段目）', 44, 14, -3, array['C']),
  ('manon_tc_tempslie', 'manon', 'classic', 'unique', '5強P>強P', '強P>強P', 'タン・リエ', 45, 5, 3, array[]::text[]),
  ('manon_tc_allonge', 'manon', 'classic', 'unique', '2強P>強P', '↓+強P>強P', 'アロンジェ', 46, 4, 1, array[]::text[]),

  -- 3. 必殺技（クラシック 19種: 50〜68）
  ('manon_63214lp', 'manon', 'classic', 'special', '63214弱P', '→↘↓↙←+弱P', '弱 マネージュ・ドレ', 50, 10, null, array[]::text[]),
  ('manon_63214mp', 'manon', 'classic', 'special', '63214中P', '→↘↓↙←+中P', '中 マネージュ・ドレ', 51, 8, null, array[]::text[]),
  ('manon_63214hp', 'manon', 'classic', 'special', '63214強P', '→↘↓↙←+強P', '強 マネージュ・ドレ', 52, 5, null, array[]::text[]),
  ('manon_63214odp', 'manon', 'classic', 'special', 'OD63214PP', '→↘↓↙←+PP', 'OD マネージュ・ドレ', 53, 8, null, array[]::text[]),
  ('manon_236lk', 'manon', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 ロン・ポワン', 54, 9, 3, array['SA3']),
  ('manon_236mk', 'manon', 'classic', 'special', '236中K', '↓↘→+中K', '中 ロン・ポワン', 55, 11, null, array['SA3']),
  ('manon_236hk', 'manon', 'classic', 'special', '236強K', '↓↘→+強K', '強 ロン・ポワン', 56, 14, null, array['SA3']),
  ('manon_236odk', 'manon', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD ロン・ポワン', 57, 8, null, array['SA2']),
  ('manon_214lk', 'manon', 'classic', 'special', '214弱K', '↓↙←+弱K', '弱 デガジェ', 58, 16, null, array[]::text[]),
  ('manon_214mk', 'manon', 'classic', 'special', '214中K', '↓↙←+中K', '中 デガジェ', 59, 16, null, array[]::text[]),
  ('manon_214hk', 'manon', 'classic', 'special', '214強K', '↓↙←+強K', '強 デガジェ', 60, 20, 3, array[]::text[]),
  ('manon_214odk', 'manon', 'classic', 'special', 'OD214KK', '↓↙←+KK', 'OD デガジェ', 61, 22, 6, array[]::text[]),
  ('manon_236lp', 'manon', 'classic', 'special', '236弱P', '↓↘→+弱P', '弱 ランヴェルセ', 62, 22, null, array['SA3']),
  ('manon_236mp', 'manon', 'classic', 'special', '236中P', '↓↘→+中P', '中 ランヴェルセ', 63, 25, null, array['SA3']),
  ('manon_236hp', 'manon', 'classic', 'special', '236強P', '↓↘→+強P', '強 ランヴェルセ', 64, 29, null, array['SA3']),
  ('manon_236odp', 'manon', 'classic', 'special', 'OD236PP', '↓↘→+PP', 'OD ランヴェルセ', 65, 25, null, array[]::text[]),
  ('manon_renverse_feint', 'manon', 'classic', 'special', 'ランヴェルセ(フェイント)', 'ランヴェルセ中Pホールド', 'ランヴェルセ（フェイント）', 66, null, null, array[]::text[]),
  ('manon_grand_fouette', 'manon', 'classic', 'special', 'グラン・フェッテ', 'ランヴェルセ中K', 'グラン・フェッテ', 67, 11, null, array['SA3']),
  ('manon_grand_fouette_od', 'manon', 'classic', 'special', 'ODグラン・フェッテ', 'ODランヴェルセ中K', 'OD グラン・フェッテ', 68, 10, null, array['SA2']),

  -- 4. スーパーアーツ（クラシック 3種: 75〜77、CA除外）
  ('manon_sa1', 'manon', 'classic', 'super', 'SA1', '↓↘→↓↘→+K', 'SA1 アラベスク', 75, 10, null, array[]::text[]),
  ('manon_sa2', 'manon', 'classic', 'super', 'SA2', '↓↙←↓↙←+K', 'SA2 エトワール', 76, 7, null, array[]::text[]),
  ('manon_sa3', 'manon', 'classic', 'super', 'SA3', '↓↘→↓↘→+P', 'SA3 パ・ド・ドゥ', 77, 7, null, array[]::text[]),

  -- 5. 通常投げ（クラシック 2種: 80〜81）
  ('manon_throw_f', 'manon', 'classic', 'throw', '前投げ', '弱P+弱K', 'オーウチガリ（前投げ）', 80, 5, null, array[]::text[]),
  ('manon_throw_b', 'manon', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'ウチマタ（後ろ投げ）', 81, 5, null, array[]::text[]),

  -- 6. モダン通常技（10種: 90〜99）
  ('manon_m_5l', 'manon', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 90, 4, 4, array['C']),
  ('manon_m_5m', 'manon', 'modern', 'normal', '5中', '中', '立ち中（立ち中P）', 91, 7, 2, array['C']),
  ('manon_m_5h', 'manon', 'modern', 'normal', '5強', '強', '立ち強（立ち強P）', 92, 10, 0, array['SA']),
  ('manon_m_2l', 'manon', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱K）', 93, 5, -1, array[]::text[]),
  ('manon_m_2m', 'manon', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 94, 8, 4, array[]::text[]),
  ('manon_m_2h', 'manon', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 95, 10, -2, array[]::text[]),
  ('manon_m_3h', 'manon', 'modern', 'normal', '3強', '↘+強', '右下強（クロワゼ）', 96, 11, null, array[]::text[]),
  ('manon_m_jl', 'manon', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 97, 5, null, array[]::text[]),
  ('manon_m_jm', 'manon', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 98, 8, null, array[]::text[]),
  ('manon_m_jh', 'manon', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 99, 11, null, array[]::text[]),

  -- 7. モダン特殊技・アシスト・TC（15種: 105〜119）
  ('manon_m_auto_l', 'manon', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・立ち弱K）', 105, 5, 2, array['C']),
  ('manon_m_auto_m', 'manon', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・立ち中K）', 106, 10, 0, array['C']),
  ('manon_m_j_auto_l', 'manon', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 107, 6, null, array[]::text[]),
  ('manon_m_j_auto_m', 'manon', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 108, 7, null, array[]::text[]),
  ('manon_m_j_auto_h', 'manon', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 109, 9, null, array[]::text[]),
  ('manon_m_auto_l_combo', 'manon', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 110, 5, null, array[]::text[]),
  ('manon_m_auto_2l_combo', 'manon', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 111, 5, null, array[]::text[]),
  ('manon_m_auto_m_combo', 'manon', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 112, 10, null, array[]::text[]),
  ('manon_m_auto_h_combo', 'manon', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 113, null, null, array[]::text[]),
  ('manon_m_4h', 'manon', 'modern', 'unique', '4強', '←+強', 'レベランス', 114, 8, 3, array['C']),
  ('manon_m_tc_aterre', 'manon', 'modern', 'unique', '5中>中', '中>中', 'ア・テール', 115, 10, 2, array[]::text[]),
  ('manon_m_4m', 'manon', 'modern', 'unique', '4中', '←+中', 'アン・オー（1段目）', 116, 10, -1, array[]::text[]),
  ('manon_m_tc_enhaut2', 'manon', 'modern', 'unique', '4中>中', '←+中>中', 'アン・オー（2段目）', 117, 14, -3, array['C']),
  ('manon_m_tc_tempslie', 'manon', 'modern', 'unique', '5強>強', '強>強', 'タン・リエ', 118, 5, 3, array[]::text[]),
  ('manon_m_tc_allonge', 'manon', 'modern', 'unique', '2強>強', '↓+強>強', 'アロンジェ', 119, 4, 1, array[]::text[]),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（8種: 125〜132）
  ('manon_m_sp', 'manon', 'modern', 'special', 'N必', 'SP', '強 マネージュ・ドレ（N必）', 125, 5, null, array[]::text[]),
  ('manon_m_od_sp', 'manon', 'modern', 'special', 'A+N必', 'A+SP', 'OD マネージュ・ドレ（A+N必）', 126, 8, null, array[]::text[]),
  ('manon_m_6sp', 'manon', 'modern', 'special', '前必', '→+SP', '中 ロン・ポワン（前必）', 127, 11, null, array['SA3']),
  ('manon_m_od_6sp', 'manon', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD ロン・ポワン（A+前必）', 128, 8, null, array['SA2']),
  ('manon_m_4sp', 'manon', 'modern', 'special', '後必', '←+SP', '弱 デガジェ（後必）', 129, 16, null, array[]::text[]),
  ('manon_m_od_4sp', 'manon', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD デガジェ（A+後必）', 130, 22, 6, array[]::text[]),
  ('manon_m_2sp', 'manon', 'modern', 'special', '下必', '↓+SP', '弱 ランヴェルセ（下必）', 131, 22, null, array['SA3']),
  ('manon_m_od_2sp', 'manon', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD ランヴェルセ（A+下必）', 132, 25, null, array[]::text[]),

  -- 9. モダン必殺技：コマンド入力版＆派生技（15種: 135〜149）
  ('manon_m_63214l', 'manon', 'modern', 'special', '63214弱', '→↘↓↙←+弱', '弱 マネージュ・ドレ', 135, 10, null, array[]::text[]),
  ('manon_m_63214m', 'manon', 'modern', 'special', '63214中', '→↘↓↙←+中', '中 マネージュ・ドレ', 136, 8, null, array[]::text[]),
  ('manon_m_63214h', 'manon', 'modern', 'special', '63214強', '→↘↓↙←+強', '強 マネージュ・ドレ', 137, 5, null, array[]::text[]),
  ('manon_m_63214od', 'manon', 'modern', 'special', 'OD63214', '→↘↓↙←+攻撃×2', 'OD マネージュ・ドレ', 138, 8, null, array[]::text[]),
  ('manon_m_236l', 'manon', 'modern', 'special', '236弱', '↓↘→+弱', '弱 ロン・ポワン', 139, 9, 3, array['SA3']),
  ('manon_m_236m', 'manon', 'modern', 'special', '236中', '↓↘→+中', '中 ロン・ポワン', 140, 11, null, array['SA3']),
  ('manon_m_236h', 'manon', 'modern', 'special', '236強', '↓↘→+強', '強 ロン・ポワン', 141, 14, null, array['SA3']),
  ('manon_m_236od', 'manon', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD ロン・ポワン', 142, 8, null, array['SA2']),
  ('manon_m_214l', 'manon', 'modern', 'special', '214弱', '↓↙←+弱', '弱 デガジェ', 143, 16, null, array[]::text[]),
  ('manon_m_214m', 'manon', 'modern', 'special', '214中', '↓↙←+中', '中 デガジェ', 144, 16, null, array[]::text[]),
  ('manon_m_214h', 'manon', 'modern', 'special', '214強', '↓↙←+強', '強 デガジェ', 145, 20, 3, array[]::text[]),
  ('manon_m_214od', 'manon', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD デガジェ', 146, 22, 6, array[]::text[]),
  ('manon_m_renverse_feint', 'manon', 'modern', 'special', 'ランヴェルセ(フェイント)', 'ランヴェルセ中弱ホールド', 'ランヴェルセ（フェイント）', 147, null, null, array[]::text[]),
  ('manon_m_grand_fouette', 'manon', 'modern', 'special', 'グラン・フェッテ', 'ランヴェルセ中攻撃', 'グラン・フェッテ', 148, 11, null, array['SA3']),
  ('manon_m_grand_fouette_od', 'manon', 'modern', 'special', 'ODグラン・フェッテ', 'ODランヴェルセ中攻撃', 'OD グラン・フェッテ', 149, 10, null, array['SA2']),

  -- 10. モダンスーパーアーツ（3種: 155〜157、CA除外）
  ('manon_m_sa1', 'manon', 'modern', 'super', 'SA1', 'SP+強', 'SA1 アラベスク', 155, 10, null, array[]::text[]),
  ('manon_m_sa2', 'manon', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 エトワール', 156, 7, null, array[]::text[]),
  ('manon_m_sa3', 'manon', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 パ・ド・ドゥ', 157, 7, null, array[]::text[]),

  -- 11. モダン通常投げ（2種: 160〜161）
  ('manon_m_throw_f', 'manon', 'modern', 'throw', '前投げ', '弱+中', 'オーウチガリ（前投げ）', 160, 5, null, array[]::text[]),
  ('manon_m_throw_b', 'manon', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'ウチマタ（後ろ投げ）', 161, 5, null, array[]::text[])
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
