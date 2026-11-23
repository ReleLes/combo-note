-- =============================================================================
-- Migration: 012_add_guile_zangief.sql
-- 目的: 11人目「ガイル（guile）」・12人目「ザンギエフ（zangief）」のキャラクターマスタおよび
--       全技マスタ（ガイル全150技＋ザンギエフ全126技＝計276技・
--       公式フレームデータ＆コマンドリスト準拠・CA除外）を
--       既存の Supabase 本番 DB へ安全・冪等に UPSERT する
-- 前提: 001_add_throw_category.sql を先に適用済みであること
-- =============================================================================

-- 1. キャラクターマスタへガイル・ザンギエフを追加・更新
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
  ('guile', 'guile', 'ガイル', 'Guile', 11, true, null, null, null),
  ('zangief', 'zangief', 'ザンギエフ', 'Zangief', 12, true, null, null, null)
on conflict (id) do update set
  slug = excluded.slug,
  name_ja = excluded.name_ja,
  name_en = excluded.name_en,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  stock_label = excluded.stock_label,
  stock_short_label = excluded.stock_short_label,
  stock_max_count = excluded.stock_max_count;

-- 2. ガイル・ザンギエフ全技マスタ（計276技）を UPSERT
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
  -- ガイル（guile）全150技（クラシック70種＋モダン80種）
  -- =========================================================================

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('guile_5lp', 'guile', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（ジャブ）', 10, 5, 4, array['C']),
  ('guile_5lk', 'guile', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（ムエタイキック）', 11, 5, 3, array['C']),
  ('guile_5mp', 'guile', 'classic', 'normal', '5中P', '中P', '立ち中P（フック）', 12, 7, 6, array['C']),
  ('guile_5mk', 'guile', 'classic', 'normal', '5中K', '中K', '立ち中K（トラースキック）', 13, 7, 1, '{}'::text[]),
  ('guile_5hp', 'guile', 'classic', 'normal', '5強P', '強P', '立ち強P（サイクロンフック）', 14, 7, -1, array['C']),
  ('guile_5hk', 'guile', 'classic', 'normal', '5強K', '強K', '立ち強K（ヘビースタブキック）', 15, 12, 4, array['SA']),
  ('guile_2lp', 'guile', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（ジャブ）', 20, 4, 5, array['C']),
  ('guile_2lk', 'guile', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（キック）', 21, 5, 1, '{}'::text[]),
  ('guile_2mp', 'guile', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（ストレート）', 22, 6, 4, array['C']),
  ('guile_2mk', 'guile', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（スライドスイープ）', 23, 8, 4, '{}'::text[]),
  ('guile_2hp', 'guile', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（リフトアッパー）', 24, 9, 0, array['C']),
  ('guile_2hk', 'guile', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（ドラゴンスイープ）', 25, 9, null, '{}'::text[]),
  ('guile_jlp', 'guile', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（ジャンプパンチ）', 30, 4, null, '{}'::text[]),
  ('guile_jlk', 'guile', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（ジャンピングニーアタック）', 31, 6, null, '{}'::text[]),
  ('guile_jmp', 'guile', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（ジャンプストレート）', 32, 7, null, '{}'::text[]),
  ('guile_jmk', 'guile', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（ガイルキック）', 33, 7, null, '{}'::text[]),
  ('guile_jhp', 'guile', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（ジャンプチョップ）', 34, 9, null, '{}'::text[]),
  ('guile_jhk', 'guile', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（アンチラウンドキック）', 35, 10, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 12種: 40〜51）
  ('guile_6mp', 'guile', 'classic', 'unique', '6中P', '→+中P', 'フルブレットマグナム', 40, 20, 2, '{}'::text[]),
  ('guile_4hp', 'guile', 'classic', 'unique', '4強P', '←+強P', 'バーンストレート', 41, 9, 1, array['C']),
  ('guile_6hp', 'guile', 'classic', 'unique', '6強P', '→+強P', 'スピニングバックナックル', 42, 16, 5, '{}'::text[]),
  ('guile_4lk', 'guile', 'classic', 'unique', '4弱K', '←+弱K', 'ニーバズーカ', 43, 8, 0, '{}'::text[]),
  ('guile_4mk', 'guile', 'classic', 'unique', '4中K', '←+中K', 'ローリングソバット（後）', 44, 11, 3, '{}'::text[]),
  ('guile_6mk', 'guile', 'classic', 'unique', '6中K', '→+中K', 'ローリングソバット（前）', 45, 11, 3, '{}'::text[]),
  ('guile_6hk', 'guile', 'classic', 'unique', '6強K', '→+強K', 'リバーススピンキック', 46, 17, -1, '{}'::text[]),
  ('guile_3hk', 'guile', 'classic', 'unique', '3強K', '↘+強K', 'ガイルハイキック', 47, 10, 0, array['C']),
  ('guile_tc_5mp', 'guile', 'classic', 'unique', '5中P>4強P', '中P>←+強P', 'リコイルキャノン', 48, 16, null, array['C']),
  ('guile_tc_2mp', 'guile', 'classic', 'unique', '2中P>2中P', '↓+中P>↓+中P', 'ダブルバレット', 49, 12, null, array['C']),
  ('guile_tc_2mk', 'guile', 'classic', 'unique', '2中K>6中P', '↓+中K>→+中P', 'ドレイクファング', 50, 20, 1, '{}'::text[]),
  ('guile_tc_2hk', 'guile', 'classic', 'unique', '2強K>3強K', '↓+強K>↘+強K', 'ファントムカッター', 51, 10, null, array['C']),

  -- 3. 必殺技（クラシック 32種: 55〜86）
  ('guile_46lp', 'guile', 'classic', 'special', '[4]6弱P', '←タメ→+弱P', '弱 ソニックブーム', 55, 10, 3, array['SA3']),
  ('guile_46lp_j', 'guile', 'classic', 'special', '[4]6弱P(ジャスト)', '←タメ→+弱Pジャスト', '【ジャスト】弱 ソニックブーム', 56, 10, 4, array['SA3']),
  ('guile_46mp', 'guile', 'classic', 'special', '[4]6中P', '←タメ→+中P', '中 ソニックブーム', 57, 10, 3, array['SA3']),
  ('guile_46mp_j', 'guile', 'classic', 'special', '[4]6中P(ジャスト)', '←タメ→+中Pジャスト', '【ジャスト】中 ソニックブーム', 58, 10, 4, array['SA3']),
  ('guile_46hp', 'guile', 'classic', 'special', '[4]6強P', '←タメ→+強P', '強 ソニックブーム', 59, 10, 3, array['SA3']),
  ('guile_46hp_j', 'guile', 'classic', 'special', '[4]6強P(ジャスト)', '←タメ→+強Pジャスト', '【ジャスト】強 ソニックブーム', 60, 10, 4, array['SA3']),
  ('guile_46odp', 'guile', 'classic', 'special', 'OD[4]6PP', '←タメ→+PP', 'OD ソニックブーム', 61, 10, null, array['SA2']),
  ('guile_28lk', 'guile', 'classic', 'special', '[2]8弱K', '↓タメ↑+弱K', '弱 サマーソルトキック', 62, 5, null, array['SA3']),
  ('guile_28lk_j', 'guile', 'classic', 'special', '[2]8弱K(ジャスト)', '↓タメ↑+弱Kジャスト', '【ジャスト】弱 サマーソルトキック', 63, 5, null, array['SA3']),
  ('guile_28mk', 'guile', 'classic', 'special', '[2]8中K', '↓タメ↑+中K', '中 サマーソルトキック', 64, 6, null, array['SA3']),
  ('guile_28mk_j', 'guile', 'classic', 'special', '[2]8中K(ジャスト)', '↓タメ↑+中Kジャスト', '【ジャスト】中 サマーソルトキック', 65, 6, null, array['SA3']),
  ('guile_28hk', 'guile', 'classic', 'special', '[2]8強K', '↓タメ↑+強K', '強 サマーソルトキック', 66, 7, null, array['SA3']),
  ('guile_28hk_j', 'guile', 'classic', 'special', '[2]8強K(ジャスト)', '↓タメ↑+強Kジャスト', '【ジャスト】強 サマーソルトキック', 67, 7, null, array['SA3']),
  ('guile_28odk', 'guile', 'classic', 'special', 'OD[2]8KK', '↓タメ↑+KK', 'OD サマーソルトキック', 68, 6, null, '{}'::text[]),
  ('guile_214lp', 'guile', 'classic', 'special', '214弱P', '↓↙←+弱P', '弱 ソニックブレイド', 69, 16, -3, array['SA3']),
  ('guile_214mp', 'guile', 'classic', 'special', '214中P', '↓↙←+中P', '中 ソニックブレイド', 70, 21, -6, array['SA3']),
  ('guile_214hp', 'guile', 'classic', 'special', '214強P', '↓↙←+強P', '強 ソニックブレイド', 71, 31, 1, array['SA3']),
  ('guile_214od_lm', 'guile', 'classic', 'special', 'OD214弱中P', '↓↙←+弱P中P', 'OD 弱 ソニックブレイド', 72, 15, null, array['SA2']),
  ('guile_214od_lh', 'guile', 'classic', 'special', 'OD214弱強P', '↓↙←+弱P強P', 'OD 中 ソニックブレイド', 73, 15, null, array['SA2']),
  ('guile_214od_mh', 'guile', 'classic', 'special', 'OD214中強P', '↓↙←+中P強P', 'OD 強 ソニックブレイド', 74, 15, null, array['SA2']),
  ('guile_cross_l', 'guile', 'classic', 'special', '弱クロス', 'ブレイド中→+弱P', '弱 ソニッククロス', 75, 10, null, '{}'::text[]),
  ('guile_cross_l_j', 'guile', 'classic', 'special', '弱クロス(ジャスト)', 'ブレイド中→+弱Pジャスト', '【ジャスト】弱 ソニッククロス', 76, 10, null, '{}'::text[]),
  ('guile_cross_m', 'guile', 'classic', 'special', '中クロス', 'ブレイド中→+中P', '中 ソニッククロス', 77, 10, null, '{}'::text[]),
  ('guile_cross_m_j', 'guile', 'classic', 'special', '中クロス(ジャスト)', 'ブレイド中→+中Pジャスト', '【ジャスト】中 ソニッククロス', 78, 10, null, '{}'::text[]),
  ('guile_cross_h', 'guile', 'classic', 'special', '強クロス', 'ブレイド中→+強P', '強 ソニッククロス', 79, 10, null, '{}'::text[]),
  ('guile_cross_h_j', 'guile', 'classic', 'special', '強クロス(ジャスト)', 'ブレイド中→+強Pジャスト', '【ジャスト】強 ソニッククロス', 80, 10, null, '{}'::text[]),
  ('guile_cross_od_from_n', 'guile', 'classic', 'special', 'ODクロス(通常から)', 'ブレイド中→+PP', 'OD ソニッククロス1（通常ブレイド派生）', 81, 10, null, '{}'::text[]),
  ('guile_cross_od_from_od', 'guile', 'classic', 'special', 'ODクロス(ODから)', 'ODブレイド中→+P', 'OD ソニッククロス1（ODブレイド派生）', 82, 10, null, '{}'::text[]),
  ('guile_cross_od2', 'guile', 'classic', 'special', 'ODクロス2', 'ODブレイド中→+PP', 'OD ソニッククロス2（壁やられ）', 83, 10, null, '{}'::text[]),
  ('guile_break_single', 'guile', 'classic', 'special', 'ブレイク(単発)', 'SA2中PP', 'ソニックブレイク（単発）', 84, 11, 2, '{}'::text[]),
  ('guile_break_chain', 'guile', 'classic', 'special', 'ブレイク(派生)', 'SA2中ソニック後P', 'ソニックブレイク（派生）', 85, 11, 2, '{}'::text[]),
  ('guile_break_od', 'guile', 'classic', 'special', 'ODブレイク', 'SA2中ODソニック後P', 'OD ソニックブレイク', 86, 11, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 4種: 90〜93、CA除外）
  ('guile_sa1_h', 'guile', 'classic', 'super', 'SA1(横)', '←タメ→←→+弱or中P', 'SA1 ソニックハリケーン（横）', 90, 8, null, '{}'::text[]),
  ('guile_sa1_u', 'guile', 'classic', 'super', 'SA1(上)', '←タメ→←→+強P', 'SA1 ソニックハリケーン（上）', 91, 7, null, '{}'::text[]),
  ('guile_sa2', 'guile', 'classic', 'super', 'SA2', '↓↙←↓↙←+P', 'SA2 ソリッドパンチャー', 92, null, null, '{}'::text[]),
  ('guile_sa3', 'guile', 'classic', 'super', 'SA3', '←タメ→←→+K', 'SA3 クロスファイアサマーソルト', 93, 9, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 4種: 95〜98）
  ('guile_throw_f', 'guile', 'classic', 'throw', '前投げ', '弱P+弱K', 'ドラゴンスープレックス（前投げ）', 95, 5, null, '{}'::text[]),
  ('guile_throw_b', 'guile', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'ジュードースルー（後ろ投げ）', 96, 5, null, '{}'::text[]),
  ('guile_throw_air_f', 'guile', 'classic', 'throw', '空中前投げ', '空中で弱P+弱K', 'フライングメイヤー（空中前投げ）', 97, 5, null, '{}'::text[]),
  ('guile_throw_air_b', 'guile', 'classic', 'throw', '空中後ろ投げ', '空中で←+弱P+弱K', 'フライングバスタードロップ（空中後ろ投げ）', 98, 5, null, '{}'::text[]),

  -- 6. モダン通常技（10種: 110〜119）
  ('guile_m_5l', 'guile', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 5, 4, array['C']),
  ('guile_m_5m', 'guile', 'modern', 'normal', '5中', '中', '立ち中（立ち中K）', 111, 7, 1, '{}'::text[]),
  ('guile_m_5h', 'guile', 'modern', 'normal', '5強', '強', '立ち強（立ち強K）', 112, 12, 4, array['SA']),
  ('guile_m_2l', 'guile', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱P）', 113, 4, 5, array['C']),
  ('guile_m_2m', 'guile', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 114, 8, 4, '{}'::text[]),
  ('guile_m_2h', 'guile', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 115, 9, 0, array['C']),
  ('guile_m_3h', 'guile', 'modern', 'normal', '3強', '↘+強', '右下強（ドラゴンスイープ）', 116, 9, null, '{}'::text[]),
  ('guile_m_jl', 'guile', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 117, 4, null, '{}'::text[]),
  ('guile_m_jm', 'guile', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 118, 7, null, '{}'::text[]),
  ('guile_m_jh', 'guile', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 119, 10, null, '{}'::text[]),

  -- 7. モダン特殊技・アシスト（19種: 125〜143）
  ('guile_m_auto_l', 'guile', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・しゃがみ弱K）', 125, 5, 1, '{}'::text[]),
  ('guile_m_auto_m', 'guile', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・しゃがみ中P）', 126, 6, 4, array['C']),
  ('guile_m_auto_h', 'guile', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち中P）', 127, 7, 6, array['C']),
  ('guile_m_j_auto_l', 'guile', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 128, 6, null, '{}'::text[]),
  ('guile_m_j_auto_m', 'guile', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 129, 7, null, '{}'::text[]),
  ('guile_m_j_auto_h', 'guile', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 130, 9, null, '{}'::text[]),
  ('guile_m_auto_l_combo', 'guile', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 131, 5, null, '{}'::text[]),
  ('guile_m_auto_2l_combo', 'guile', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 132, 4, null, '{}'::text[]),
  ('guile_m_auto_m_combo', 'guile', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 133, 6, null, '{}'::text[]),
  ('guile_m_auto_h_combo', 'guile', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 134, 7, null, '{}'::text[]),
  ('guile_m_4h', 'guile', 'modern', 'unique', '4強', '←+強', 'バーンストレート', 135, 9, 1, array['C']),
  ('guile_m_6h', 'guile', 'modern', 'unique', '6強', '→+強', 'スピニングバックナックル', 136, 16, 5, '{}'::text[]),
  ('guile_m_4l', 'guile', 'modern', 'unique', '4弱', '←+弱', 'ニーバズーカ', 137, 8, 0, '{}'::text[]),
  ('guile_m_4m', 'guile', 'modern', 'unique', '4中', '←+中', 'ローリングソバット（後）', 138, 11, 3, '{}'::text[]),
  ('guile_m_6m', 'guile', 'modern', 'unique', '6中', '→+中', 'ローリングソバット（前）', 139, 11, 3, '{}'::text[]),
  ('guile_m_tc_ah', 'guile', 'modern', 'unique', 'A強>強', 'アシスト強>強', 'リコイルキャノン', 140, 16, null, array['C']),
  ('guile_m_tc_am', 'guile', 'modern', 'unique', 'A中>中', 'アシスト中>中', 'ダブルバレット', 141, 12, null, array['C']),
  ('guile_m_tc_2m', 'guile', 'modern', 'unique', '2中>6中', '↓+中>→+中', 'ドレイクファング', 142, 20, 1, '{}'::text[]),
  ('guile_m_tc_3h', 'guile', 'modern', 'unique', '3強>3強', '↘+強>↘+強', 'ファントムカッター', 143, 10, null, array['C']),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（11種: 150〜160）
  ('guile_m_4sp', 'guile', 'modern', 'special', '[4]後必', '←タメ+SP', '弱 ソニックブーム（後必）', 150, 10, 3, array['SA3']),
  ('guile_m_4sp_j', 'guile', 'modern', 'special', '[4]6後必(ジャスト)', '←タメ→+SP', '【ジャスト】弱 ソニックブーム（SP）', 151, 10, 4, array['SA3']),
  ('guile_m_od_4sp', 'guile', 'modern', 'special', 'A+[4]後必', '←タメ+A+SP', 'OD ソニックブーム（A+後必）', 152, 10, null, array['SA2']),
  ('guile_m_2sp', 'guile', 'modern', 'special', '[2]下必', '↓タメ+SP', '中 サマーソルトキック（下必）', 153, 6, null, array['SA3']),
  ('guile_m_2sp_j', 'guile', 'modern', 'special', '[2]8下必(ジャスト)', '↓タメ↑+SP', '【ジャスト】中 サマーソルトキック（SP）', 154, 6, null, array['SA3']),
  ('guile_m_od_2sp', 'guile', 'modern', 'special', 'A+[2]下必', '↓タメ+A+SP', 'OD サマーソルトキック（A+下必）', 155, 6, null, '{}'::text[]),
  ('guile_m_sp', 'guile', 'modern', 'special', 'N必', 'SP', '弱 ソニックブレイド（N必）', 156, 16, -3, array['SA3']),
  ('guile_m_od_sp', 'guile', 'modern', 'special', 'A+N必', 'A+SP', 'OD 中 ソニックブレイド（A+N必）', 157, 15, null, array['SA2']),
  ('guile_m_sp_cross', 'guile', 'modern', 'special', '弱クロス(SP)', 'ブレイド中SP', '弱 ソニッククロス（SP）', 158, 10, null, '{}'::text[]),
  ('guile_m_sp_cross_j', 'guile', 'modern', 'special', '弱クロス(ジャストSP)', 'ブレイド中→+SP', '【ジャスト】弱 ソニッククロス（SP）', 159, 10, null, '{}'::text[]),
  ('guile_m_sp_cross_od2', 'guile', 'modern', 'special', 'ODクロス2(SP)', 'ODブレイド中A+SP', 'OD ソニッククロス2（壁やられ・SP）', 160, 10, null, '{}'::text[]),

  -- 9. モダン必殺技：コマンド入力版＆ソニックブレイク（32種: 165〜196）
  ('guile_m_46l', 'guile', 'modern', 'special', '[4]6弱', '←タメ→+弱', '弱 ソニックブーム', 165, 10, 3, array['SA3']),
  ('guile_m_46l_j', 'guile', 'modern', 'special', '[4]6弱(ジャスト)', '←タメ→+弱ジャスト', '【ジャスト】弱 ソニックブーム', 166, 10, 4, array['SA3']),
  ('guile_m_46m', 'guile', 'modern', 'special', '[4]6中', '←タメ→+中', '中 ソニックブーム', 167, 10, 3, array['SA3']),
  ('guile_m_46m_j', 'guile', 'modern', 'special', '[4]6中(ジャスト)', '←タメ→+中ジャスト', '【ジャスト】中 ソニックブーム', 168, 10, 4, array['SA3']),
  ('guile_m_46h', 'guile', 'modern', 'special', '[4]6強', '←タメ→+強', '強 ソニックブーム', 169, 10, 3, array['SA3']),
  ('guile_m_46h_j', 'guile', 'modern', 'special', '[4]6強(ジャスト)', '←タメ→+強ジャスト', '【ジャスト】強 ソニックブーム', 170, 10, 4, array['SA3']),
  ('guile_m_46od', 'guile', 'modern', 'special', 'OD[4]6', '←タメ→+攻撃×2', 'OD ソニックブーム', 171, 10, null, array['SA2']),
  ('guile_m_28l', 'guile', 'modern', 'special', '[2]8弱', '↓タメ↑+弱', '弱 サマーソルトキック', 172, 5, null, array['SA3']),
  ('guile_m_28l_j', 'guile', 'modern', 'special', '[2]8弱(ジャスト)', '↓タメ↑+弱ジャスト', '【ジャスト】弱 サマーソルトキック', 173, 5, null, array['SA3']),
  ('guile_m_28m', 'guile', 'modern', 'special', '[2]8中', '↓タメ↑+中', '中 サマーソルトキック', 174, 6, null, array['SA3']),
  ('guile_m_28m_j', 'guile', 'modern', 'special', '[2]8中(ジャスト)', '↓タメ↑+中ジャスト', '【ジャスト】中 サマーソルトキック', 175, 6, null, array['SA3']),
  ('guile_m_28h', 'guile', 'modern', 'special', '[2]8強', '↓タメ↑+強', '強 サマーソルトキック', 176, 7, null, array['SA3']),
  ('guile_m_28h_j', 'guile', 'modern', 'special', '[2]8強(ジャスト)', '↓タメ↑+強ジャスト', '【ジャスト】強 サマーソルトキック', 177, 7, null, array['SA3']),
  ('guile_m_28od', 'guile', 'modern', 'special', 'OD[2]8', '↓タメ↑+攻撃×2', 'OD サマーソルトキック', 178, 6, null, '{}'::text[]),
  ('guile_m_214l', 'guile', 'modern', 'special', '214弱', '↓↙←+弱', '弱 ソニックブレイド', 179, 16, -3, array['SA3']),
  ('guile_m_214m', 'guile', 'modern', 'special', '214中', '↓↙←+中', '中 ソニックブレイド', 180, 21, -6, array['SA3']),
  ('guile_m_214h', 'guile', 'modern', 'special', '214強', '↓↙←+強', '強 ソニックブレイド', 181, 31, 1, array['SA3']),
  ('guile_m_214od_lm', 'guile', 'modern', 'special', 'OD214弱中', '↓↙←+弱+中', 'OD 弱 ソニックブレイド', 182, 15, null, array['SA2']),
  ('guile_m_214od_lh', 'guile', 'modern', 'special', 'OD214弱強', '↓↙←+弱+強', 'OD 中 ソニックブレイド', 183, 15, null, array['SA2']),
  ('guile_m_214od_mh', 'guile', 'modern', 'special', 'OD214中強', '↓↙←+中+強', 'OD 強 ソニックブレイド', 184, 15, null, array['SA2']),
  ('guile_m_cross_l', 'guile', 'modern', 'special', '弱クロス', 'ブレイド中→+弱', '弱 ソニッククロス', 185, 10, null, '{}'::text[]),
  ('guile_m_cross_l_j', 'guile', 'modern', 'special', '弱クロス(ジャスト)', 'ブレイド中→+弱ジャスト', '【ジャスト】弱 ソニッククロス', 186, 10, null, '{}'::text[]),
  ('guile_m_cross_m', 'guile', 'modern', 'special', '中クロス', 'ブレイド中→+中', '中 ソニッククロス', 187, 10, null, '{}'::text[]),
  ('guile_m_cross_m_j', 'guile', 'modern', 'special', '中クロス(ジャスト)', 'ブレイド中→+中ジャスト', '【ジャスト】中 ソニッククロス', 188, 10, null, '{}'::text[]),
  ('guile_m_cross_h', 'guile', 'modern', 'special', '強クロス', 'ブレイド中→+強', '強 ソニッククロス', 189, 10, null, '{}'::text[]),
  ('guile_m_cross_h_j', 'guile', 'modern', 'special', '強クロス(ジャスト)', 'ブレイド中→+強ジャスト', '【ジャスト】強 ソニッククロス', 190, 10, null, '{}'::text[]),
  ('guile_m_cross_od_from_n', 'guile', 'modern', 'special', 'ODクロス(通常から)', 'ブレイド中→+攻撃×2', 'OD ソニッククロス1（通常ブレイド派生）', 191, 10, null, '{}'::text[]),
  ('guile_m_cross_od_from_od', 'guile', 'modern', 'special', 'ODクロス(ODから)', 'ODブレイド中攻撃', 'OD ソニッククロス1（ODブレイド派生）', 192, 10, null, '{}'::text[]),
  ('guile_m_cross_od2', 'guile', 'modern', 'special', 'ODクロス2', 'ODブレイド中→+攻撃×2', 'OD ソニッククロス2（壁やられ）', 193, 10, null, '{}'::text[]),
  ('guile_m_break_single', 'guile', 'modern', 'special', 'ブレイク(単発)', 'SA2中中+強', 'ソニックブレイク（単発）', 194, 11, 2, '{}'::text[]),
  ('guile_m_break_chain', 'guile', 'modern', 'special', 'ブレイク(派生)', 'SA2中ソニック後攻撃', 'ソニックブレイク（派生）', 195, 11, 2, '{}'::text[]),
  ('guile_m_break_od', 'guile', 'modern', 'special', 'ODブレイク', 'SA2中ODソニック後攻撃', 'OD ソニックブレイク', 196, 11, null, '{}'::text[]),

  -- 10. モダンスーパーアーツ（4種: 200〜203、CA除外）
  ('guile_m_sa1_h', 'guile', 'modern', 'super', 'SA1(横)', '←タメ+SP+強', 'SA1 ソニックハリケーン（横）', 200, 8, null, '{}'::text[]),
  ('guile_m_sa1_u', 'guile', 'modern', 'super', 'SA1(上)', '←タメ→←→+弱', 'SA1 ソニックハリケーン（上）', 201, 7, null, '{}'::text[]),
  ('guile_m_sa2', 'guile', 'modern', 'super', 'SA2', 'SP+強', 'SA2 ソリッドパンチャー', 202, null, null, '{}'::text[]),
  ('guile_m_sa3', 'guile', 'modern', 'super', 'SA3', '↓タメ+SP+強', 'SA3 クロスファイアサマーソルト', 203, 9, null, '{}'::text[]),

  -- 11. モダン通常投げ（4種: 205〜208）
  ('guile_m_throw_f', 'guile', 'modern', 'throw', '前投げ', '弱+中', 'ドラゴンスープレックス（前投げ）', 205, 5, null, '{}'::text[]),
  ('guile_m_throw_b', 'guile', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'ジュードースルー（後ろ投げ）', 206, 5, null, '{}'::text[]),
  ('guile_m_throw_air_f', 'guile', 'modern', 'throw', '空中前投げ', '空中で弱+中', 'フライングメイヤー（空中前投げ）', 207, 5, null, '{}'::text[]),
  ('guile_m_throw_air_b', 'guile', 'modern', 'throw', '空中後ろ投げ', '空中で←+弱+中', 'フライングバスタードロップ（空中後ろ投げ）', 208, 5, null, '{}'::text[]),

  -- =========================================================================
  -- ザンギエフ（zangief）全126技（クラシック57種＋モダン69種）
  -- =========================================================================

  -- 1. 通常技（クラシック 20種: 立ち 10〜16 / しゃがみ 20〜25 / ジャンプ 30〜36）
  ('zangief_5lp', 'zangief', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（ブレーンチョップ）', 10, 7, 4, array['C']),
  ('zangief_5lk', 'zangief', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（ローキック）', 11, 7, -2, array['C']),
  ('zangief_5mp', 'zangief', 'classic', 'normal', '5中P', '中P', '立ち中P（カウンターチョップ）', 12, 9, 2, '{}'::text[]),
  ('zangief_5mk', 'zangief', 'classic', 'normal', '5中K', '中K', '立ち中K（ミドルキック）', 13, 10, 1, '{}'::text[]),
  ('zangief_5hp', 'zangief', 'classic', 'normal', '5強P', '強P', '立ち強P（ダイナマイトパンチ）', 14, 16, 3, '{}'::text[]),
  ('zangief_5hp_h', 'zangief', 'classic', 'normal', '5強P(H)', '強Pホールド', '立ち強P（ダイナマイトパンチ・ホールド）', 15, 32, null, '{}'::text[]),
  ('zangief_5hk', 'zangief', 'classic', 'normal', '5強K', '強K', '立ち強K（ロシアンハイキック）', 16, 13, 3, '{}'::text[]),
  ('zangief_2lp', 'zangief', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（ヘルフィンガー）', 20, 6, 6, array['C']),
  ('zangief_2lk', 'zangief', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（ショートスタンプ）', 21, 4, 0, '{}'::text[]),
  ('zangief_2mp', 'zangief', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（ロシアンフィスト）', 22, 8, 3, array['C']),
  ('zangief_2mk', 'zangief', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（ダイナマイトキック）', 23, 9, 3, '{}'::text[]),
  ('zangief_2hp', 'zangief', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（ダイナマイトエルボー）', 24, 11, null, '{}'::text[]),
  ('zangief_2hk', 'zangief', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（ビッグスタンプ）', 25, 12, null, '{}'::text[]),
  ('zangief_jlp', 'zangief', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（ジャンピングフィンガー）', 30, 5, null, '{}'::text[]),
  ('zangief_jlk', 'zangief', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（ダブルニードロップ）', 31, 5, null, '{}'::text[]),
  ('zangief_jmp', 'zangief', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（ジャンピングフィスト）', 32, 8, null, '{}'::text[]),
  ('zangief_jmk', 'zangief', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（ジャンピングロシアンスタンプ）', 33, 8, null, '{}'::text[]),
  ('zangief_jhp', 'zangief', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（ジャンピングロシアンチョップ）', 34, 9, null, '{}'::text[]),
  ('zangief_jhk', 'zangief', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（ドロップキック）', 35, 10, null, '{}'::text[]),
  ('zangief_jhk_h', 'zangief', 'classic', 'normal', 'J強K(H)', '空中で強Kホールド', 'ジャンプ強K（ドロップキック・ホールド）', 36, 32, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 12種: 40〜51）
  ('zangief_3mp', 'zangief', 'classic', 'unique', '3中P', '↘+中P', 'ヘルスタブ', 40, 7, -1, array['C']),
  ('zangief_6mk', 'zangief', 'classic', 'unique', '6中K', '→+中K', 'ニーバット', 41, 14, 1, '{}'::text[]),
  ('zangief_6hp', 'zangief', 'classic', 'unique', '6強P', '→+強P', 'ヘッドバット', 42, 14, 8, array['C']),
  ('zangief_6hk', 'zangief', 'classic', 'unique', '6強K', '→+強K', 'サイクロンニールキック', 43, 22, null, '{}'::text[]),
  ('zangief_3hk', 'zangief', 'classic', 'unique', '3強K', '↘+強K', 'スメタナドロップキック', 44, 16, null, '{}'::text[]),
  ('zangief_j2hp', 'zangief', 'classic', 'unique', 'J2強P', '空中で↓+強P', 'フライングボディプレス', 45, 9, null, '{}'::text[]),
  ('zangief_nj8hp', 'zangief', 'classic', 'unique', '垂直J8強P', '垂直J中↑+強P', 'フライングヘッドバット', 46, 8, null, array['C']),
  ('zangief_tc_5mp_2', 'zangief', 'classic', 'unique', '5中P>中P', '中P>中P', 'マシンガンチョップ（2段目）', 47, 9, 2, '{}'::text[]),
  ('zangief_tc_5mp_3', 'zangief', 'classic', 'unique', '5中P>中P>中P', '中P>中P>中P', 'マシンガンチョップ（3段目）', 48, 15, null, '{}'::text[]),
  ('zangief_22mk_1', 'zangief', 'classic', 'unique', '22中K', '↓↓+中K', 'ストンピング（1段目）', 49, 9, 4, array['C']),
  ('zangief_22mk_2', 'zangief', 'classic', 'unique', '22中K>中K', '↓↓+中K>中K', 'ストンピング（2段目）', 50, 9, -3, array['C']),
  ('zangief_22mk_3', 'zangief', 'classic', 'unique', '22中K>中K>中K', '↓↓+中K>中K>中K', 'ストンピング（3段目）', 51, 10, -2, array['C']),

  -- 3. 必殺技（クラシック 15種: 55〜69）
  ('zangief_lariat', 'zangief', 'classic', 'special', 'PP', 'PP', 'ダブルラリアット', 55, 15, null, array['SA3']),
  ('zangief_lariat_od', 'zangief', 'classic', 'special', 'OD PPP', 'PPP', 'OD ダブルラリアット', 56, 12, null, array['SA2']),
  ('zangief_360lp', 'zangief', 'classic', 'special', '360弱P', '1回転+弱P', '弱 スクリューパイルドライバー', 57, 5, null, '{}'::text[]),
  ('zangief_360mp', 'zangief', 'classic', 'special', '360中P', '1回転+中P', '中 スクリューパイルドライバー', 58, 5, null, '{}'::text[]),
  ('zangief_360hp', 'zangief', 'classic', 'special', '360強P', '1回転+強P', '強 スクリューパイルドライバー', 59, 5, null, '{}'::text[]),
  ('zangief_360odp', 'zangief', 'classic', 'special', 'OD360PP', '1回転+PP', 'OD スクリューパイルドライバー', 60, 5, null, '{}'::text[]),
  ('zangief_air_360k', 'zangief', 'classic', 'special', '空中360K', '空中1回転+K', 'ボルシチダイナマイト', 61, 4, null, '{}'::text[]),
  ('zangief_air_360odk', 'zangief', 'classic', 'special', 'OD空中360KK', '空中1回転+KK', 'OD ボルシチダイナマイト', 62, 4, null, '{}'::text[]),
  ('zangief_63214k_r', 'zangief', 'classic', 'special', '63214K(近)', '→↘↓↙←+K(近距離)', 'ロシアンスープレックス', 63, 10, null, '{}'::text[]),
  ('zangief_63214odk_r', 'zangief', 'classic', 'special', 'OD63214KK(近)', '→↘↓↙←+KK(近距離)', 'OD ロシアンスープレックス', 64, 10, null, '{}'::text[]),
  ('zangief_63214k_sn', 'zangief', 'classic', 'special', '63214K(近シベ)', '→↘↓↙←+弱or中K(近)', 'シベリアンエクスプレス（近距離版）', 65, 28, null, '{}'::text[]),
  ('zangief_63214odk_sn', 'zangief', 'classic', 'special', 'OD63214KK(近シベ)', '→↘↓↙←+KK(近)', 'OD シベリアンエクスプレス（近距離版）', 66, 23, null, '{}'::text[]),
  ('zangief_63214k_sf', 'zangief', 'classic', 'special', '63214K(遠シベ)', '→↘↓↙←+K(遠距離)', 'シベリアンエクスプレス（遠距離版）', 67, 55, null, '{}'::text[]),
  ('zangief_63214odk_sf', 'zangief', 'classic', 'special', 'OD63214KK(遠シベ)', '→↘↓↙←+KK(遠距離)', 'OD シベリアンエクスプレス（遠距離版）', 68, 54, null, '{}'::text[]),
  ('zangief_22hk', 'zangief', 'classic', 'special', '22強K', '↓↓+強K', 'ツンドラストーム', 69, 5, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 4種: 75〜78、CA除外）
  ('zangief_sa1', 'zangief', 'classic', 'super', 'SA1', '↓↘→↓↘→+K', 'SA1 エリアルロシアンスラム', 75, 11, null, '{}'::text[]),
  ('zangief_sa2', 'zangief', 'classic', 'super', 'SA2', '↓↘→↓↘→+P', 'SA2 サイクロンラリアット', 76, 18, null, '{}'::text[]),
  ('zangief_sa2_h', 'zangief', 'classic', 'super', 'SA2(H)', '↓↘→↓↘→+Pホールド', 'SA2 サイクロンラリアット（ホールド）', 77, 18, null, '{}'::text[]),
  ('zangief_sa3', 'zangief', 'classic', 'super', 'SA3(720)', '2回転+P', 'SA3 ボリショイストームバスター', 78, 6, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 6種: 85〜90）
  ('zangief_throw_n', 'zangief', 'classic', 'throw', 'N投げ', '弱P+弱K', 'ボディスラム（N投げ）', 85, 5, null, '{}'::text[]),
  ('zangief_throw_4', 'zangief', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'キャプチュード（後ろ投げ）', 86, 5, null, '{}'::text[]),
  ('zangief_throw_6', 'zangief', 'classic', 'throw', '前投げ', '→+弱P+弱K', 'ジャーマンスープレックス（前投げ）', 87, 5, null, '{}'::text[]),
  ('zangief_throw_3', 'zangief', 'classic', 'throw', '右下投げ', '↘+弱P+弱K', 'スパインバスター（右下投げ）', 88, 5, null, '{}'::text[]),
  ('zangief_throw_1', 'zangief', 'classic', 'throw', '左下投げ', '↙+弱P+弱K', 'ロシアンドロップ（左下投げ）', 89, 5, null, '{}'::text[]),
  ('zangief_throw_2', 'zangief', 'classic', 'throw', '下投げ', '↓+弱P+弱K', 'ブレーンバスター（下投げ）', 90, 5, null, '{}'::text[]),

  -- 6. モダン通常技（12種: 110〜121）
  ('zangief_m_5l', 'zangief', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱K）', 110, 7, -2, array['C']),
  ('zangief_m_5m', 'zangief', 'modern', 'normal', '5中', '中', '立ち中（立ち中P）', 111, 9, 2, '{}'::text[]),
  ('zangief_m_5h', 'zangief', 'modern', 'normal', '5強', '強', '立ち強（立ち強P）', 112, 16, 3, '{}'::text[]),
  ('zangief_m_5h_h', 'zangief', 'modern', 'normal', '5強(H)', '強ホールド', '立ち強（立ち強P・ホールド）', 113, 32, null, '{}'::text[]),
  ('zangief_m_2l', 'zangief', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱P）', 114, 6, 6, array['C']),
  ('zangief_m_2m', 'zangief', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中P）', 115, 8, 3, array['C']),
  ('zangief_m_2h', 'zangief', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 116, 11, null, '{}'::text[]),
  ('zangief_m_3h', 'zangief', 'modern', 'normal', '3強', '↘+強', '右下強（ビッグスタンプ）', 117, 12, null, '{}'::text[]),
  ('zangief_m_jl', 'zangief', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 118, 5, null, '{}'::text[]),
  ('zangief_m_jm', 'zangief', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 119, 8, null, '{}'::text[]),
  ('zangief_m_jh', 'zangief', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 120, 10, null, '{}'::text[]),
  ('zangief_m_jh_h', 'zangief', 'modern', 'normal', 'J強(H)', '空中で強ホールド', 'ジャンプ強（ジャンプ強K・ホールド）', 121, 32, null, '{}'::text[]),

  -- 7. モダン特殊技・アシスト（20種: 125〜144）
  ('zangief_m_auto_l', 'zangief', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・しゃがみ弱K）', 125, 4, 0, '{}'::text[]),
  ('zangief_m_auto_h', 'zangief', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・ヘッドバット）', 126, 14, 8, array['C']),
  ('zangief_m_j_auto_l', 'zangief', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 127, 5, null, '{}'::text[]),
  ('zangief_m_j_auto_m', 'zangief', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 128, 8, null, '{}'::text[]),
  ('zangief_m_j_auto_h', 'zangief', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 129, 9, null, '{}'::text[]),
  ('zangief_m_auto_l_combo', 'zangief', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 130, 4, null, '{}'::text[]),
  ('zangief_m_auto_2l_combo', 'zangief', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 131, 3, null, '{}'::text[]),
  ('zangief_m_auto_m_combo', 'zangief', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 132, 9, null, '{}'::text[]),
  ('zangief_m_auto_h_combo', 'zangief', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 133, 14, null, '{}'::text[]),
  ('zangief_m_3m', 'zangief', 'modern', 'unique', '3中', '↘+中', 'ヘルスタブ', 134, 7, -1, array['C']),
  ('zangief_m_6m', 'zangief', 'modern', 'unique', '6中', '→+中', 'ニーバット', 135, 14, 1, '{}'::text[]),
  ('zangief_m_6h', 'zangief', 'modern', 'unique', '6強', '→+強', 'サイクロンニールキック', 136, 22, null, '{}'::text[]),
  ('zangief_m_j2h', 'zangief', 'modern', 'unique', 'J2強', '空中で↓+強', 'フライングボディプレス', 137, 9, null, '{}'::text[]),
  ('zangief_m_nj8h', 'zangief', 'modern', 'unique', '垂直J8強', '垂直J中↑+強', 'フライングヘッドバット', 138, 8, null, array['C']),
  ('zangief_m_tc_5m_2', 'zangief', 'modern', 'unique', '5中>中', '中>中', 'マシンガンチョップ（2段目）', 139, 9, 2, '{}'::text[]),
  ('zangief_m_tc_5m_3', 'zangief', 'modern', 'unique', '5中>中>中', '中>中>中', 'マシンガンチョップ（3段目）', 140, 15, null, '{}'::text[]),
  ('zangief_m_22m_1', 'zangief', 'modern', 'unique', '22中', '↓↓+中', 'ストンピング（1段目）', 141, 9, 4, array['C']),
  ('zangief_m_22m_2', 'zangief', 'modern', 'unique', '22中>中', '↓↓+中>中', 'ストンピング（2段目）', 142, 9, -3, array['C']),
  ('zangief_m_22m_3', 'zangief', 'modern', 'unique', '22中>中>中', '↓↓+中>中>中', 'ストンピング（3段目）', 143, 10, -2, array['C']),
  ('zangief_m_rc_5lp', 'zangief', 'modern', 'unique', 'A弱>弱', 'アシスト弱>弱', '連打立ち弱P（ブレーンチョップ）', 144, 4, 4, array['C']),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（12種: 150〜161）
  ('zangief_m_2sp', 'zangief', 'modern', 'special', '下必', '↓+SP', 'ダブルラリアット（下必）', 150, 15, null, array['SA3']),
  ('zangief_m_od_2sp', 'zangief', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD ダブルラリアット（A+下必）', 151, 12, null, array['SA2']),
  ('zangief_m_sp', 'zangief', 'modern', 'special', 'N必', 'SP', '強 スクリューパイルドライバー（N必）', 152, 5, null, '{}'::text[]),
  ('zangief_m_od_sp', 'zangief', 'modern', 'special', 'A+N必', 'A+SP', 'OD スクリューパイルドライバー（A+N必）', 153, 5, null, '{}'::text[]),
  ('zangief_m_air_sp', 'zangief', 'modern', 'special', '空必', '空中でSP', 'ボルシチダイナマイト（空必）', 154, 4, null, '{}'::text[]),
  ('zangief_m_od_air_sp', 'zangief', 'modern', 'special', 'A+空必', '空中でA+SP', 'OD ボルシチダイナマイト（A+空必）', 155, 4, null, '{}'::text[]),
  ('zangief_m_4sp_r', 'zangief', 'modern', 'special', '後必(近)', '←+SP(近距離)', 'ロシアンスープレックス（後必）', 156, 10, null, '{}'::text[]),
  ('zangief_m_od_4sp_r', 'zangief', 'modern', 'special', 'A+後必(近)', 'A+←+SP(近距離)', 'OD ロシアンスープレックス（A+後必）', 157, 10, null, '{}'::text[]),
  ('zangief_m_4sp_sn', 'zangief', 'modern', 'special', '後必(近シベ)', '←+SP(近距離)', 'シベリアンエクスプレス（近距離版・後必）', 158, 28, null, '{}'::text[]),
  ('zangief_m_od_4sp_sn', 'zangief', 'modern', 'special', 'A+後必(近シベ)', 'A+←+SP(近距離)', 'OD シベリアンエクスプレス（近距離版・A+後必）', 159, 23, null, '{}'::text[]),
  ('zangief_m_4sp_sf', 'zangief', 'modern', 'special', '後必(遠シベ)', '←+SP(遠距離)', 'シベリアンエクスプレス（遠距離版・後必）', 160, 55, null, '{}'::text[]),
  ('zangief_m_od_4sp_sf', 'zangief', 'modern', 'special', 'A+後必(遠シベ)', 'A+←+SP(遠距離)', 'OD シベリアンエクスプレス（遠距離版・A+後必）', 161, 54, null, '{}'::text[]),

  -- 9. モダン必殺技：コマンド入力版（15種: 165〜179）
  ('zangief_m_lariat', 'zangief', 'modern', 'special', '中+強', '中+強', 'ダブルラリアット', 165, 15, null, array['SA3']),
  ('zangief_m_lariat_od', 'zangief', 'modern', 'special', 'OD 弱+中+強', '弱+中+強', 'OD ダブルラリアット', 166, 12, null, array['SA2']),
  ('zangief_m_360l', 'zangief', 'modern', 'special', '360弱', '1回転+弱', '弱 スクリューパイルドライバー', 167, 5, null, '{}'::text[]),
  ('zangief_m_360m', 'zangief', 'modern', 'special', '360中', '1回転+中', '中 スクリューパイルドライバー', 168, 5, null, '{}'::text[]),
  ('zangief_m_360h', 'zangief', 'modern', 'special', '360強', '1回転+強', '強 スクリューパイルドライバー', 169, 5, null, '{}'::text[]),
  ('zangief_m_360od', 'zangief', 'modern', 'special', 'OD360', '1回転+攻撃×2', 'OD スクリューパイルドライバー', 170, 5, null, '{}'::text[]),
  ('zangief_m_air_360', 'zangief', 'modern', 'special', '空中360', '空中1回転+攻撃', 'ボルシチダイナマイト', 171, 4, null, '{}'::text[]),
  ('zangief_m_air_360od', 'zangief', 'modern', 'special', 'OD空中360', '空中1回転+攻撃×2', 'OD ボルシチダイナマイト', 172, 4, null, '{}'::text[]),
  ('zangief_m_63214_r', 'zangief', 'modern', 'special', '63214攻撃(近)', '→↘↓↙←+攻撃(近)', 'ロシアンスープレックス', 173, 10, null, '{}'::text[]),
  ('zangief_m_63214od_r', 'zangief', 'modern', 'special', 'OD63214(近)', '→↘↓↙←+攻撃×2(近)', 'OD ロシアンスープレックス', 174, 10, null, '{}'::text[]),
  ('zangief_m_63214_sn', 'zangief', 'modern', 'special', '63214(近シベ)', '→↘↓↙←+弱or中(近)', 'シベリアンエクスプレス（近距離版）', 175, 28, null, '{}'::text[]),
  ('zangief_m_63214od_sn', 'zangief', 'modern', 'special', 'OD63214(近シベ)', '→↘↓↙←+攻撃×2(近)', 'OD シベリアンエクスプレス（近距離版）', 176, 23, null, '{}'::text[]),
  ('zangief_m_63214_sf', 'zangief', 'modern', 'special', '63214(遠シベ)', '→↘↓↙←+弱or中(遠)', 'シベリアンエクスプレス（遠距離版）', 177, 55, null, '{}'::text[]),
  ('zangief_m_63214od_sf', 'zangief', 'modern', 'special', 'OD63214(遠シベ)', '→↘↓↙←+攻撃×2(遠)', 'OD シベリアンエクスプレス（遠距離版）', 178, 54, null, '{}'::text[]),
  ('zangief_m_22h', 'zangief', 'modern', 'special', '22強', '↓↓+強', 'ツンドラストーム', 179, 5, null, '{}'::text[]),

  -- 10. モダンスーパーアーツ（4種: 185〜188、CA除外）
  ('zangief_m_sa1', 'zangief', 'modern', 'super', 'SA1', 'SP+強', 'SA1 エリアルロシアンスラム', 185, 11, null, '{}'::text[]),
  ('zangief_m_sa2', 'zangief', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 サイクロンラリアット', 186, 18, null, '{}'::text[]),
  ('zangief_m_sa2_h', 'zangief', 'modern', 'super', 'SA2(H)', '←+SP+強ホールド', 'SA2 サイクロンラリアット（ホールド）', 187, 18, null, '{}'::text[]),
  ('zangief_m_sa3', 'zangief', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 ボリショイストームバスター', 188, 6, null, '{}'::text[]),

  -- 11. モダン通常投げ（6種: 195〜200）
  ('zangief_m_throw_n', 'zangief', 'modern', 'throw', 'N投げ', '弱+中', 'ボディスラム（N投げ）', 195, 5, null, '{}'::text[]),
  ('zangief_m_throw_4', 'zangief', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'キャプチュード（後ろ投げ）', 196, 5, null, '{}'::text[]),
  ('zangief_m_throw_6', 'zangief', 'modern', 'throw', '前投げ', '→+弱+中', 'ジャーマンスープレックス（前投げ）', 197, 5, null, '{}'::text[]),
  ('zangief_m_throw_3', 'zangief', 'modern', 'throw', '右下投げ', '↘+弱+中', 'スパインバスター（右下投げ）', 198, 5, null, '{}'::text[]),
  ('zangief_m_throw_1', 'zangief', 'modern', 'throw', '左下投げ', '↙+弱+中', 'ロシアンドロップ（左下投げ）', 199, 5, null, '{}'::text[]),
  ('zangief_m_throw_2', 'zangief', 'modern', 'throw', '下投げ', '↓+弱+中', 'ブレーンバスター（下投げ）', 200, 5, null, '{}'::text[])
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
