-- =============================================================================
-- Migration: 017_add_rashid_aki.sql
-- 目的: 19人目「ラシード（rashid）」・20人目「A.K.I.（aki）」のキャラクターマスタおよび
--       全技マスタ（ラシード全151技＋A.K.I.全106技＝計257技・
--       公式フレームデータ＆コマンドリスト準拠・CA除外）を
--       既存の Supabase 本番 DB へ安全・冪等に UPSERT する
-- 前提: 001_add_throw_category.sql を先に適用済みであること
-- =============================================================================

-- 1. キャラクターマスタへラシード・A.K.I.を追加・更新
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
  ('rashid', 'rashid', 'ラシード', 'Rashid', 19, true, null, null, null),
  ('aki', 'aki', 'A.K.I.', 'A.K.I.', 20, true, null, null, null)
on conflict (id) do update set
  slug = excluded.slug,
  name_ja = excluded.name_ja,
  name_en = excluded.name_en,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  stock_label = excluded.stock_label,
  stock_short_label = excluded.stock_short_label,
  stock_max_count = excluded.stock_max_count;

-- 2. ラシード・A.K.I.全技マスタ（計257技）を UPSERT
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
  -- ラシード（rashid）全151技（クラシック74種＋モダン77種）
  -- =========================================================================

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('rashid_5lp', 'rashid', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（スタンドスラップ）', 10, 4, 4, array['C']),
  ('rashid_5lk', 'rashid', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（ニースマッシュ）', 11, 4, 3, array['C']),
  ('rashid_5mp', 'rashid', 'classic', 'normal', '5中P', '中P', '立ち中P（スタッブエルボー）', 12, 6, 5, array['C']),
  ('rashid_5mk', 'rashid', 'classic', 'normal', '5中K', '中K', '立ち中K（スコーピオンテイル）', 13, 8, 6, '{}'::text[]),
  ('rashid_5hp', 'rashid', 'classic', 'normal', '5強P', '強P', '立ち強P（ウインドスラスト）', 14, 9, 1, array['C']),
  ('rashid_5hk', 'rashid', 'classic', 'normal', '5強K', '強K', '立ち強K（レッグツイスター）', 15, 13, -1, '{}'::text[]),
  ('rashid_2lp', 'rashid', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（グランドスラップ）', 20, 5, 5, array['C']),
  ('rashid_2lk', 'rashid', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（スティングロー）', 21, 5, 3, '{}'::text[]),
  ('rashid_2mp', 'rashid', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（ライジングビーク）', 22, 6, 4, array['C']),
  ('rashid_2mk', 'rashid', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（ファルコンキック）', 23, 7, -1, array['C']),
  ('rashid_2hp', 'rashid', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（グランドスラスト）', 24, 12, 5, array['SA']),
  ('rashid_2hk', 'rashid', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（サイクロンスライサー）', 25, 9, null, '{}'::text[]),
  ('rashid_jlp', 'rashid', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（エリアルスマッシュ）', 30, 4, null, '{}'::text[]),
  ('rashid_jlk', 'rashid', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（エリアルエッジ）', 31, 5, null, '{}'::text[]),
  ('rashid_jmp', 'rashid', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（エリアルビーク）', 32, 9, null, array['C']),
  ('rashid_jmk', 'rashid', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（グライダードロップ）', 33, 7, null, '{}'::text[]),
  ('rashid_jhp', 'rashid', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（エリアルダブルスラスト）', 34, 8, null, '{}'::text[]),
  ('rashid_jhk', 'rashid', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（サンライズキック）', 35, 10, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 12種: 40〜51）
  ('rashid_run', 'rashid', 'classic', 'unique', 'ラン', '→→(→ホールド)', 'ラン', 40, null, null, '{}'::text[]),
  ('rashid_run_backup', 'rashid', 'classic', 'unique', 'ラン>6P', 'ラン中→+P', 'バックアップ', 41, 8, 7, array['SA']),
  ('rashid_run_tempest', 'rashid', 'classic', 'unique', 'ラン>6K', 'ラン中→+K', 'テンペスト・ムーン', 42, 16, 3, array['SA']),
  ('rashid_run_tempest_wind', 'rashid', 'classic', 'unique', '[気流]ラン>6K', '[気流]ラン中→+K', '【気流強化】テンペスト・ムーン', 43, 9, null, '{}'::text[]),
  ('rashid_6mp', 'rashid', 'classic', 'unique', '6中P', '→+中P', 'フラップ・スピン', 44, 8, 1, array['C']),
  ('rashid_6hp', 'rashid', 'classic', 'unique', '6強P', '→+強P', 'アサルト・ビーク', 45, 22, 3, '{}'::text[]),
  ('rashid_6hk', 'rashid', 'classic', 'unique', '6強K', '→+強K', 'クレセントキック', 46, 16, 3, '{}'::text[]),
  ('rashid_j2hp', 'rashid', 'classic', 'unique', '前J2強P', '前ジャンプ中↓+強P', 'ブリッツストライク', 47, 10, null, array['C']),
  ('rashid_8hk', 'rashid', 'classic', 'unique', '垂直J8強K', '垂直ジャンプ中↑+強K', 'エリアルシュート', 48, 8, null, '{}'::text[]),
  ('rashid_tc_mp_hk', 'rashid', 'classic', 'unique', '5中P>強K', '中P>強K', 'ライジング・キック', 49, 13, null, array['C']),
  ('rashid_side_flip', 'rashid', 'classic', 'unique', '6KK', '→+KK', 'サイド・フリップ', 50, null, null, '{}'::text[]),
  ('rashid_front_flip', 'rashid', 'classic', 'unique', 'フロント・フリップ', 'サイドフリップ中KK', 'フロント・フリップ', 51, null, null, '{}'::text[]),

  -- 3. 必殺技（クラシック 38種: 55〜92）
  ('rashid_236lp', 'rashid', 'classic', 'special', '236弱P', '↓↘→+弱P', '弱 スピニング・ミキサー', 55, 8, 2, array['SA3']),
  ('rashid_236lp_wind', 'rashid', 'classic', 'special', '[気流]236弱P', '[気流]↓↘→+弱P', '【気流強化】弱 スピニング・ミキサー', 56, 6, 4, array['SA3']),
  ('rashid_236mp', 'rashid', 'classic', 'special', '236中P', '↓↘→+中P', '中 スピニング・ミキサー', 57, 8, null, array['SA3']),
  ('rashid_236mp_wind', 'rashid', 'classic', 'special', '[気流]236中P', '[気流]↓↘→+中P', '【気流強化】中 スピニング・ミキサー', 58, 5, null, array['SA3']),
  ('rashid_236hp', 'rashid', 'classic', 'special', '236強P', '↓↘→+強P', '強 スピニング・ミキサー', 59, 6, null, '{}'::text[]),
  ('rashid_236hp_wind', 'rashid', 'classic', 'special', '[気流]236強P', '[気流]↓↘→+強P', '【気流強化】強 スピニング・ミキサー', 60, 5, null, '{}'::text[]),
  ('rashid_236odp', 'rashid', 'classic', 'special', 'OD236PP', '↓↘→+PP', 'OD スピニング・ミキサー', 61, 6, null, '{}'::text[]),
  ('rashid_236odp_wind', 'rashid', 'classic', 'special', '[気流]OD236PP', '[気流]↓↘→+PP', '【気流強化】OD スピニング・ミキサー', 62, 4, null, '{}'::text[]),
  ('rashid_214lk', 'rashid', 'classic', 'special', '214弱K', '↓↙←+弱K', '弱 イーグル・スパイク', 63, 15, null, array['SA3']),
  ('rashid_214lk_wind', 'rashid', 'classic', 'special', '[気流]214弱K', '[気流]↓↙←+弱K', '【気流強化】弱 イーグル・スパイク', 64, 14, null, array['SA3']),
  ('rashid_214mk', 'rashid', 'classic', 'special', '214中K', '↓↙←+中K', '中 イーグル・スパイク', 65, 21, null, '{}'::text[]),
  ('rashid_214mk_wind', 'rashid', 'classic', 'special', '[気流]214中K', '[気流]↓↙←+中K', '【気流強化】中 イーグル・スパイク', 66, 17, null, '{}'::text[]),
  ('rashid_214hk', 'rashid', 'classic', 'special', '214強K', '↓↙←+強K', '強 イーグル・スパイク', 67, 26, null, '{}'::text[]),
  ('rashid_214hk_wind', 'rashid', 'classic', 'special', '[気流]214強K', '[気流]↓↙←+強K', '【気流強化】強 イーグル・スパイク', 68, 17, null, '{}'::text[]),
  ('rashid_214odk', 'rashid', 'classic', 'special', 'OD214KK', '↓↙←+KK', 'OD イーグル・スパイク', 69, 21, null, '{}'::text[]),
  ('rashid_214odk_wind', 'rashid', 'classic', 'special', '[気流]OD214KK', '[気流]↓↙←+KK', '【気流強化】OD イーグル・スパイク', 70, 18, null, '{}'::text[]),
  ('rashid_236lk', 'rashid', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 ワールウインド・ショット', 71, 17, -1, array['SA3']),
  ('rashid_236lk_hold', 'rashid', 'classic', 'special', '236弱K(ホールド)', '↓↘→+弱Kホールド', '弱 ワールウインド・ショット（ホールド）', 72, 34, 5, array['SA3']),
  ('rashid_236lk_max', 'rashid', 'classic', 'special', '236弱K(MAX)', '↓↘→+弱KホールドMAX', '弱 ワールウインド・ショット（ホールドMAX）', 73, 53, 16, array['SA3']),
  ('rashid_236mk', 'rashid', 'classic', 'special', '236中K', '↓↘→+中K', '中 ワールウインド・ショット', 74, 17, -1, array['SA3']),
  ('rashid_236mk_hold', 'rashid', 'classic', 'special', '236中K(ホールド)', '↓↘→+中Kホールド', '中 ワールウインド・ショット（ホールド）', 75, 34, 5, array['SA3']),
  ('rashid_236mk_max', 'rashid', 'classic', 'special', '236中K(MAX)', '↓↘→+中KホールドMAX', '中 ワールウインド・ショット（ホールドMAX）', 76, 53, 16, array['SA3']),
  ('rashid_236hk', 'rashid', 'classic', 'special', '236強K', '↓↘→+強K', '強 ワールウインド・ショット', 77, 17, -1, array['SA3']),
  ('rashid_236hk_hold', 'rashid', 'classic', 'special', '236強K(ホールド)', '↓↘→+強Kホールド', '強 ワールウインド・ショット（ホールド）', 78, 34, 5, array['SA3']),
  ('rashid_236hk_max', 'rashid', 'classic', 'special', '236強K(MAX)', '↓↘→+強KホールドMAX', '強 ワールウインド・ショット（ホールドMAX）', 79, 53, 16, array['SA3']),
  ('rashid_236odk', 'rashid', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD ワールウインド・ショット', 80, 17, null, array['SA2']),
  ('rashid_236odk_hold', 'rashid', 'classic', 'special', 'OD236KK(ホールド)', '↓↘→+KKホールド', 'OD ワールウインド・ショット（ホールド）', 81, 38, null, array['SA2']),
  ('rashid_214lp', 'rashid', 'classic', 'special', '214弱P', '↓↙←+弱P', '弱 アラビアン・サイクロン', 82, 15, 2, array['SA3']),
  ('rashid_214mp', 'rashid', 'classic', 'special', '214中P', '↓↙←+中P', '中 アラビアン・サイクロン', 83, 20, 4, array['SA3']),
  ('rashid_214hp', 'rashid', 'classic', 'special', '214強P', '↓↙←+強P', '強 アラビアン・サイクロン', 84, 27, null, array['SA3']),
  ('rashid_214odp', 'rashid', 'classic', 'special', 'OD214PP', '↓↙←+PP', 'OD アラビアン・サイクロン', 85, 20, null, array['SA2']),
  ('rashid_wing_stroke', 'rashid', 'classic', 'special', 'ウイング・ストローク', 'サイクロン中←+K', 'ウイング・ストローク', 86, null, null, '{}'::text[]),
  ('rashid_assault_roll', 'rashid', 'classic', 'special', 'アサルト・ロール', 'サイクロン中→+K', 'アサルト・ロール', 87, null, null, '{}'::text[]),
  ('rashid_assault_nail', 'rashid', 'classic', 'special', 'アサルト・ネイル', 'ロール中K', 'アサルト・ネイル', 88, 17, null, array['SA3']),
  ('rashid_j214lk', 'rashid', 'classic', 'special', '前J214弱K', '前J中↓↙←+弱K', '弱 アラビアン・スカイハイ', 89, 13, null, '{}'::text[]),
  ('rashid_j214mk', 'rashid', 'classic', 'special', '前J214中K', '前J中↓↙←+中K', '中 アラビアン・スカイハイ', 90, 18, null, '{}'::text[]),
  ('rashid_j214hk', 'rashid', 'classic', 'special', '前J214強K', '前J中↓↙←+強K', '強 アラビアン・スカイハイ', 91, 21, null, '{}'::text[]),
  ('rashid_j214odk', 'rashid', 'classic', 'special', '前JOD214KK', '前J中↓↙←+KK', 'OD アラビアン・スカイハイ', 92, 13, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 3種: 95〜97、CA除外）
  ('rashid_sa1', 'rashid', 'classic', 'super', 'SA1', '↓↘→↓↘→+K', 'SA1 スーパー・ラシード・キック', 95, 9, null, '{}'::text[]),
  ('rashid_sa2', 'rashid', 'classic', 'super', 'SA2', '↓↙←↓↙←+K', 'SA2 イウサール', 96, 11, null, '{}'::text[]),
  ('rashid_sa3', 'rashid', 'classic', 'super', 'SA3', '↓↘→↓↘→+P', 'SA3 アルタイル', 97, 11, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 3種: 100〜102）
  ('rashid_throw_f', 'rashid', 'classic', 'throw', '前投げ', '弱P+弱K', 'ライディング・グライド（前投げ）', 100, 5, null, '{}'::text[]),
  ('rashid_throw_b', 'rashid', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'サンセット・ドロップ（後ろ投げ）', 101, 5, null, '{}'::text[]),
  ('rashid_throw_air', 'rashid', 'classic', 'throw', '空投げ', '空中で弱P+弱K', 'デザート・スライダー（空中投げ）', 102, 5, null, '{}'::text[]),

  -- 6. モダン通常技（10種: 110〜119）
  ('rashid_m_5l', 'rashid', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 4, 4, array['C']),
  ('rashid_m_5m', 'rashid', 'modern', 'normal', '5中', '中', '立ち中（立ち中K）', 111, 8, 6, '{}'::text[]),
  ('rashid_m_5h', 'rashid', 'modern', 'normal', '5強', '強', '立ち強（立ち強K）', 112, 13, -1, '{}'::text[]),
  ('rashid_m_2l', 'rashid', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱K）', 113, 5, 3, '{}'::text[]),
  ('rashid_m_2m', 'rashid', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 114, 7, -1, array['C']),
  ('rashid_m_2h', 'rashid', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 115, 12, 5, array['SA']),
  ('rashid_m_3h', 'rashid', 'modern', 'normal', '3強', '↘+強', '右下強（サイクロンスライサー）', 116, 9, null, '{}'::text[]),
  ('rashid_m_jl', 'rashid', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 117, 4, null, '{}'::text[]),
  ('rashid_m_jm', 'rashid', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 118, 9, null, array['C']),
  ('rashid_m_jh', 'rashid', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 119, 10, null, '{}'::text[]),

  -- 7. モダン特殊技・アシスト（21種: 125〜145）
  ('rashid_m_auto_l', 'rashid', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・しゃがみ弱P）', 125, 5, 5, array['C']),
  ('rashid_m_auto_m', 'rashid', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・立ち中P）', 126, 6, 5, array['C']),
  ('rashid_m_auto_h', 'rashid', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち強P）', 127, 9, 1, array['C']),
  ('rashid_m_j_auto_l', 'rashid', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 128, 5, null, '{}'::text[]),
  ('rashid_m_j_auto_m', 'rashid', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 129, 7, null, '{}'::text[]),
  ('rashid_m_j_auto_h', 'rashid', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 130, 8, null, '{}'::text[]),
  ('rashid_m_auto_l_combo', 'rashid', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 131, 5, null, '{}'::text[]),
  ('rashid_m_auto_2l_combo', 'rashid', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 132, 5, null, '{}'::text[]),
  ('rashid_m_auto_m_combo', 'rashid', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 133, 6, null, '{}'::text[]),
  ('rashid_m_auto_h_combo', 'rashid', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 134, 9, null, '{}'::text[]),
  ('rashid_m_run', 'rashid', 'modern', 'unique', 'ラン', '→→(→ホールド)', 'ラン', 135, null, null, '{}'::text[]),
  ('rashid_m_run_backup', 'rashid', 'modern', 'unique', 'ラン>6弱', 'ラン中→+弱', 'バックアップ', 136, 8, 7, array['SA']),
  ('rashid_m_run_tempest', 'rashid', 'modern', 'unique', 'ラン>6中or強', 'ラン中→+中or強', 'テンペスト・ムーン', 137, 16, 3, array['SA']),
  ('rashid_m_run_tempest_wind', 'rashid', 'modern', 'unique', '[気流]ラン>6中or強', '[気流]ラン中→+中or強', '【気流強化】テンペスト・ムーン', 138, 9, null, '{}'::text[]),
  ('rashid_m_6m', 'rashid', 'modern', 'unique', '6中', '→+中', 'フラップ・スピン', 139, 8, 1, array['C']),
  ('rashid_m_6h', 'rashid', 'modern', 'unique', '6強', '→+強', 'アサルト・ビーク', 140, 22, 3, '{}'::text[]),
  ('rashid_m_j2h', 'rashid', 'modern', 'unique', '前J2強', '前ジャンプ中↓+強', 'ブリッツストライク', 141, 10, null, array['C']),
  ('rashid_m_8h', 'rashid', 'modern', 'unique', '垂直J8強', '垂直ジャンプ中↑+強', 'エリアルシュート', 142, 8, null, '{}'::text[]),
  ('rashid_m_tc_am_am', 'rashid', 'modern', 'unique', 'A中>A中', 'アシスト中>アシスト中', 'ライジング・キック', 143, 13, null, array['C']),
  ('rashid_m_side_flip', 'rashid', 'modern', 'unique', '6中強', '→+中+強', 'サイド・フリップ', 144, null, null, '{}'::text[]),
  ('rashid_m_front_flip', 'rashid', 'modern', 'unique', 'フロント・フリップ', 'サイドフリップ中中+強', 'フロント・フリップ', 145, null, null, '{}'::text[]),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（21種: 150〜170）
  ('rashid_m_6sp', 'rashid', 'modern', 'special', '前必', '→+SP', '強 スピニング・ミキサー（前必）', 150, 6, null, '{}'::text[]),
  ('rashid_m_6sp_wind', 'rashid', 'modern', 'special', '[気流]前必', '[気流]→+SP', '【気流強化】強 スピニング・ミキサー（前必）', 151, 5, null, '{}'::text[]),
  ('rashid_m_od_6sp', 'rashid', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD スピニング・ミキサー（A+前必）', 152, 6, null, '{}'::text[]),
  ('rashid_m_od_6sp_wind', 'rashid', 'modern', 'special', '[気流]A+前必', '[気流]A+→+SP', '【気流強化】OD スピニング・ミキサー（A+前必）', 153, 4, null, '{}'::text[]),
  ('rashid_m_1sp', 'rashid', 'modern', 'special', '左下必', '↙+SP', '弱 イーグル・スパイク（左下必）', 154, 15, null, array['SA3']),
  ('rashid_m_1sp_wind', 'rashid', 'modern', 'special', '[気流]左下必', '[気流]↙+SP', '【気流強化】弱 イーグル・スパイク（左下必）', 155, 14, null, array['SA3']),
  ('rashid_m_2sp', 'rashid', 'modern', 'special', '下必', '↓+SP', '中 イーグル・スパイク（下必）', 156, 21, null, '{}'::text[]),
  ('rashid_m_2sp_wind', 'rashid', 'modern', 'special', '[気流]下必', '[気流]↓+SP', '【気流強化】中 イーグル・スパイク（下必）', 157, 17, null, '{}'::text[]),
  ('rashid_m_3sp', 'rashid', 'modern', 'special', '右下必', '↘+SP', '強 イーグル・スパイク（右下必）', 158, 26, null, '{}'::text[]),
  ('rashid_m_3sp_wind', 'rashid', 'modern', 'special', '[気流]右下必', '[気流]↘+SP', '【気流強化】強 イーグル・スパイク（右下必）', 159, 17, null, '{}'::text[]),
  ('rashid_m_od_2sp', 'rashid', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD イーグル・スパイク（A+下必）', 160, 21, null, '{}'::text[]),
  ('rashid_m_od_2sp_wind', 'rashid', 'modern', 'special', '[気流]A+下必', '[気流]A+↓+SP', '【気流強化】OD イーグル・スパイク（A+下必）', 161, 18, null, '{}'::text[]),
  ('rashid_m_sp', 'rashid', 'modern', 'special', 'N必', 'SP', '中 ワールウインド・ショット（N必）', 162, 17, -1, array['SA3']),
  ('rashid_m_sp_hold', 'rashid', 'modern', 'special', 'N必(ホールド)', 'SPホールド', '中 ワールウインド・ショット（ホールド・N必）', 163, 34, 5, array['SA3']),
  ('rashid_m_sp_max', 'rashid', 'modern', 'special', 'N必(MAX)', 'SPホールドMAX', '中 ワールウインド・ショット（ホールドMAX・N必）', 164, 53, 16, array['SA3']),
  ('rashid_m_od_sp', 'rashid', 'modern', 'special', 'A+N必', 'A+SP', 'OD ワールウインド・ショット（A+N必）', 165, 17, null, array['SA2']),
  ('rashid_m_od_sp_hold', 'rashid', 'modern', 'special', 'A+N必(ホールド)', 'A+SPホールド', 'OD ワールウインド・ショット（ホールド・A+N必）', 166, 38, null, array['SA2']),
  ('rashid_m_4sp', 'rashid', 'modern', 'special', '後必', '←+SP', '弱 アラビアン・サイクロン（後必）', 167, 15, 2, array['SA3']),
  ('rashid_m_od_4sp', 'rashid', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD アラビアン・サイクロン（A+後必）', 168, 20, null, array['SA2']),
  ('rashid_m_j_sp', 'rashid', 'modern', 'special', '空N必', '前J中SP', '弱 アラビアン・スカイハイ（空N必）', 169, 13, null, '{}'::text[]),
  ('rashid_m_j_od_sp', 'rashid', 'modern', 'special', '空A+N必', '前J中A+SP', 'OD アラビアン・スカイハイ（空A+N必）', 170, 13, null, '{}'::text[]),

  -- 9. モダン必殺技：コマンド入力版＆派生技（19種: 175〜193）
  ('rashid_m_236l', 'rashid', 'modern', 'special', '236弱', '↓↘→+弱', '弱 スピニング・ミキサー', 175, 8, 2, array['SA3']),
  ('rashid_m_236l_wind', 'rashid', 'modern', 'special', '[気流]236弱', '[気流]↓↘→+弱', '【気流強化】弱 スピニング・ミキサー', 176, 6, 4, array['SA3']),
  ('rashid_m_236m', 'rashid', 'modern', 'special', '236中', '↓↘→+中', '中 スピニング・ミキサー', 177, 8, null, array['SA3']),
  ('rashid_m_236m_wind', 'rashid', 'modern', 'special', '[気流]236中', '[気流]↓↘→+中', '【気流強化】中 スピニング・ミキサー', 178, 5, null, array['SA3']),
  ('rashid_m_236h', 'rashid', 'modern', 'special', '236強', '↓↘→+強', '強 スピニング・ミキサー', 179, 6, null, '{}'::text[]),
  ('rashid_m_236h_wind', 'rashid', 'modern', 'special', '[気流]236強', '[気流]↓↘→+強', '【気流強化】強 スピニング・ミキサー', 180, 5, null, '{}'::text[]),
  ('rashid_m_236od', 'rashid', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD スピニング・ミキサー', 181, 6, null, '{}'::text[]),
  ('rashid_m_236od_wind', 'rashid', 'modern', 'special', '[気流]OD236', '[気流]↓↘→+攻撃×2', '【気流強化】OD スピニング・ミキサー', 182, 4, null, '{}'::text[]),
  ('rashid_m_214l', 'rashid', 'modern', 'special', '214弱', '↓↙←+弱', '弱 アラビアン・サイクロン', 183, 15, 2, array['SA3']),
  ('rashid_m_214m', 'rashid', 'modern', 'special', '214中', '↓↙←+中', '中 アラビアン・サイクロン', 184, 20, 4, array['SA3']),
  ('rashid_m_214h', 'rashid', 'modern', 'special', '214強', '↓↙←+強', '強 アラビアン・サイクロン', 185, 27, null, array['SA3']),
  ('rashid_m_214od', 'rashid', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD アラビアン・サイクロン', 186, 20, null, array['SA2']),
  ('rashid_m_wing_stroke', 'rashid', 'modern', 'special', 'ウイング・ストローク', 'サイクロン中←+攻撃', 'ウイング・ストローク', 187, null, null, '{}'::text[]),
  ('rashid_m_assault_roll', 'rashid', 'modern', 'special', 'アサルト・ロール', 'サイクロン中→+攻撃', 'アサルト・ロール', 188, null, null, '{}'::text[]),
  ('rashid_m_assault_nail', 'rashid', 'modern', 'special', 'アサルト・ネイル', 'ロール中攻撃', 'アサルト・ネイル', 189, 17, null, array['SA3']),
  ('rashid_m_j214l', 'rashid', 'modern', 'special', '前J214弱', '前J中↓↙←+弱', '弱 アラビアン・スカイハイ', 190, 13, null, '{}'::text[]),
  ('rashid_m_j214m', 'rashid', 'modern', 'special', '前J214中', '前J中↓↙←+中', '中 アラビアン・スカイハイ', 191, 18, null, '{}'::text[]),
  ('rashid_m_j214h', 'rashid', 'modern', 'special', '前J214強', '前J中↓↙←+強', '強 アラビアン・スカイハイ', 192, 21, null, '{}'::text[]),
  ('rashid_m_j214od', 'rashid', 'modern', 'special', '前JOD214', '前J中↓↙←+攻撃×2', 'OD アラビアン・スカイハイ', 193, 13, null, '{}'::text[]),

  -- 10. モダンスーパーアーツ（3種: 200〜202、CA除外）
  ('rashid_m_sa1', 'rashid', 'modern', 'super', 'SA1', 'SP+強', 'SA1 スーパー・ラシード・キック', 200, 9, null, '{}'::text[]),
  ('rashid_m_sa2', 'rashid', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 イウサール', 201, 11, null, '{}'::text[]),
  ('rashid_m_sa3', 'rashid', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 アルタイル', 202, 11, null, '{}'::text[]),

  -- 11. モダン通常投げ（3種: 205〜207）
  ('rashid_m_throw_f', 'rashid', 'modern', 'throw', '前投げ', '弱+中', 'ライディング・グライド（前投げ）', 205, 5, null, '{}'::text[]),
  ('rashid_m_throw_b', 'rashid', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'サンセット・ドロップ（後ろ投げ）', 206, 5, null, '{}'::text[]),
  ('rashid_m_throw_air', 'rashid', 'modern', 'throw', '空投げ', '空中で弱+中', 'デザート・スライダー（空中投げ）', 207, 5, null, '{}'::text[]),

  -- =========================================================================
  -- A.K.I.（aki）全106技（クラシック51種＋モダン54種＋共通1種）
  -- =========================================================================

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('aki_5lp', 'aki', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（蛇突）', 10, 5, 4, array['C']),
  ('aki_5lk', 'aki', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（蛇咬脚）', 11, 4, 3, array['C']),
  ('aki_5mp', 'aki', 'classic', 'normal', '5中P', '中P', '立ち中P（蛇咬手）', 12, 6, 3, array['C']),
  ('aki_5mk', 'aki', 'classic', 'normal', '5中K', '中K', '立ち中K（蛇蝎蹴）', 13, 8, 6, '{}'::text[]),
  ('aki_5hp', 'aki', 'classic', 'normal', '5強P', '強P', '立ち強P（蛇突牙）', 14, 12, 1, '{}'::text[]),
  ('aki_5hk', 'aki', 'classic', 'normal', '5強K', '強K', '立ち強K（蛇旋脚）', 15, 9, 4, array['C']),
  ('aki_2lp', 'aki', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（潜蛇突）', 20, 4, 4, array['C']),
  ('aki_2lk', 'aki', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（蹴突蛇）', 21, 5, 3, '{}'::text[]),
  ('aki_2mp', 'aki', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（蛇伸突）', 22, 7, 1, array['C']),
  ('aki_2mk', 'aki', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（蛇落蹴）', 23, 7, 5, array['SA']),
  ('aki_2hp', 'aki', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（修蛇）', 24, 10, null, '{}'::text[]),
  ('aki_2hk', 'aki', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（蛇尾脚）', 25, 10, 0, array['SA']),
  ('aki_jlp', 'aki', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（空蛇突）', 30, 5, null, '{}'::text[]),
  ('aki_jlk', 'aki', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（空蛇蹴）', 31, 5, null, '{}'::text[]),
  ('aki_jmp', 'aki', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（回旋蛇）', 32, 7, null, '{}'::text[]),
  ('aki_jmk', 'aki', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（蛇天蹴）', 33, 7, null, '{}'::text[]),
  ('aki_jhp', 'aki', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（騰空双蛇突）', 34, 11, null, '{}'::text[]),
  ('aki_jhk', 'aki', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（騰空双蹴蛇）', 35, 8, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 6種: 40〜45）
  ('aki_3mp', 'aki', 'classic', 'unique', '3中P', '↘+中P', '蒲牢', 40, 24, 3, '{}'::text[]),
  ('aki_6hp', 'aki', 'classic', 'unique', '6強P', '→+強P', '螭吻', 41, 16, 3, array['SA']),
  ('aki_6hk', 'aki', 'classic', 'unique', '6強K', '→+強K', '囚牛', 42, 14, 4, '{}'::text[]),
  ('aki_j2hp', 'aki', 'classic', 'unique', '前J2強P', '前ジャンプ中↓+強P', '蚣蝮', 43, 9, null, '{}'::text[]),
  ('aki_tc_lp_lp', 'aki', 'classic', 'unique', '5弱P>弱P', '弱P>弱P', '渾沌（2段目）', 44, 8, 1, array['C']),
  ('aki_tc_hp_hp', 'aki', 'classic', 'unique', '5強P>強P', '強P>強P', '窮奇（2段目・毒破裂対応）', 45, 14, null, '{}'::text[]),

  -- 3. 必殺技（クラシック 22種: 50〜71）
  ('aki_214lp', 'aki', 'classic', 'special', '214弱P', '↓↙←+弱P', '紫煙砲', 50, 17, -5, array['SA3']),
  ('aki_214odp', 'aki', 'classic', 'special', 'OD214PP', '↓↙←+PP', 'OD 紫煙砲', 51, 16, null, array['SA2']),
  ('aki_shientsui', 'aki', 'classic', 'special', '紫煙追', '紫煙砲中→+P', '紫煙追（毒破裂対応）', 52, 13, -4, array['SA3']),
  ('aki_shientsui_od', 'aki', 'classic', 'special', 'OD紫煙追', 'OD紫煙砲中→+P', 'OD 紫煙追（毒破裂対応）', 53, 13, null, array['SA2']),
  ('aki_214mp', 'aki', 'classic', 'special', '214中P', '↓↙←+中P', '紫泡泉', 54, 26, null, '{}'::text[]),
  ('aki_214hp', 'aki', 'classic', 'special', '214強P', '↓↙←+強P', '紫泡撒', 55, 13, null, array['SA3']),
  ('aki_236lp', 'aki', 'classic', 'special', '236弱P', '↓↘→+弱P', '弱 蛇頭鞭（毒破裂対応）', 56, 14, 1, array['SA3']),
  ('aki_236mp', 'aki', 'classic', 'special', '236中P', '↓↘→+中P', '中 蛇頭鞭（毒破裂対応）', 57, 14, null, array['SA3']),
  ('aki_236hp', 'aki', 'classic', 'special', '236強P', '↓↘→+強P', '強 蛇頭鞭（毒破裂対応）', 58, 11, null, array['SA3']),
  ('aki_236odp', 'aki', 'classic', 'special', 'OD236PP', '↓↘→+PP', 'OD 蛇頭鞭（毒破裂対応）', 59, 21, 4, array['SA2']),
  ('aki_214lk', 'aki', 'classic', 'special', '214弱K', '↓↙←+弱K', '弱 凶襲突', 60, 24, 2, array['SA3']),
  ('aki_214mk', 'aki', 'classic', 'special', '214中K', '↓↙←+中K', '中 凶襲突', 61, 28, 3, array['SA3']),
  ('aki_214hk', 'aki', 'classic', 'special', '214強K', '↓↙←+強K', '強 凶襲突', 62, 33, 4, array['SA3']),
  ('aki_214odk', 'aki', 'classic', 'special', 'OD214KK', '↓↙←+KK', 'OD 凶襲突', 63, 28, null, array['SA2']),
  ('aki_236lk', 'aki', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 蛇軽功', 64, null, null, '{}'::text[]),
  ('aki_236mk', 'aki', 'classic', 'special', '236中K', '↓↘→+中K', '中 蛇軽功', 65, null, null, '{}'::text[]),
  ('aki_236hk', 'aki', 'classic', 'special', '236強K', '↓↘→+強K', '強 蛇軽功', 66, null, null, '{}'::text[]),
  ('aki_236odk', 'aki', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD 蛇軽功', 67, null, null, '{}'::text[]),
  ('aki_dakou', 'aki', 'classic', 'special', '2PP(悪鬼蛇行)', '↓+PP', '悪鬼蛇行', 68, null, null, '{}'::text[]),
  ('aki_dakou_p', 'aki', 'classic', 'special', '猛毒牙', '悪鬼蛇行中P', '猛毒牙（毒破裂対応）', 69, 19, null, '{}'::text[]),
  ('aki_dakou_k', 'aki', 'classic', 'special', '蛇連咬', '悪鬼蛇行中K', '蛇連咬', 70, 11, 4, array['SA3']),
  ('aki_dakou_throw', 'aki', 'classic', 'special', '雁字搦', '悪鬼蛇行中弱P+弱K', '雁字搦', 71, 23, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 3種: 80〜82、CA除外）
  ('aki_sa1', 'aki', 'classic', 'super', 'SA1', '↓↘→↓↘→+K', 'SA1 死屍累々', 80, 10, null, '{}'::text[]),
  ('aki_sa2', 'aki', 'classic', 'super', 'SA2', '↓↙←↓↙←+P', 'SA2 紫煙裂爪', 81, 7, null, '{}'::text[]),
  ('aki_sa3', 'aki', 'classic', 'super', 'SA3', '↓↘→↓↘→+P', 'SA3 睚眦', 82, 10, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 2種: 95〜96）
  ('aki_throw_f', 'aki', 'classic', 'throw', '前投げ', '弱P+弱K', '贔屓（前投げ）', 95, 5, null, '{}'::text[]),
  ('aki_throw_b', 'aki', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', '饕餮（後ろ投げ）', 96, 5, null, '{}'::text[]),

  -- 6. A.K.I.固有システム補助パーツ（共通 1種: 100）
  ('aki_poison_burst', 'aki', 'both', 'system', '毒破裂', '毒破裂', '毒破裂（毒状態ヒット時）', 100, null, null, '{}'::text[]),

  -- 7. モダン通常技（10種: 110〜119）
  ('aki_m_5l', 'aki', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 5, 4, array['C']),
  ('aki_m_5m', 'aki', 'modern', 'normal', '5中', '中', '立ち中（立ち中K）', 111, 8, 6, '{}'::text[]),
  ('aki_m_5h', 'aki', 'modern', 'normal', '5強', '強', '立ち強（立ち強P）', 112, 12, 1, '{}'::text[]),
  ('aki_m_2l', 'aki', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱P）', 113, 4, 4, array['C']),
  ('aki_m_2m', 'aki', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 114, 7, 5, array['SA']),
  ('aki_m_2h', 'aki', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強K）', 115, 10, 0, array['SA']),
  ('aki_m_3h', 'aki', 'modern', 'normal', '3強', '↘+強', '右下強（修蛇）', 116, 10, null, '{}'::text[]),
  ('aki_m_jl', 'aki', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 117, 5, null, '{}'::text[]),
  ('aki_m_jm', 'aki', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 118, 7, null, '{}'::text[]),
  ('aki_m_jh', 'aki', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強P）', 119, 11, null, '{}'::text[]),

  -- 8. モダン特殊技・アシスト（15種: 125〜139）
  ('aki_m_auto_l', 'aki', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・しゃがみ弱K）', 125, 5, 3, '{}'::text[]),
  ('aki_m_auto_m', 'aki', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・立ち中P）', 126, 6, 3, array['C']),
  ('aki_m_auto_h', 'aki', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち強K）', 127, 9, 4, array['C']),
  ('aki_m_j_auto_l', 'aki', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 128, 5, null, '{}'::text[]),
  ('aki_m_j_auto_m', 'aki', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 129, 7, null, '{}'::text[]),
  ('aki_m_j_auto_h', 'aki', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強K）', 130, 8, null, '{}'::text[]),
  ('aki_m_auto_l_combo', 'aki', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 131, 5, null, '{}'::text[]),
  ('aki_m_auto_2l_combo', 'aki', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 132, 4, null, '{}'::text[]),
  ('aki_m_auto_m_combo', 'aki', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 133, 6, null, '{}'::text[]),
  ('aki_m_auto_h_combo', 'aki', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 134, 9, null, '{}'::text[]),
  ('aki_m_3m', 'aki', 'modern', 'unique', '3中', '↘+中', '蒲牢', 135, 24, 3, '{}'::text[]),
  ('aki_m_6h', 'aki', 'modern', 'unique', '6強', '→+強', '囚牛', 136, 14, 4, '{}'::text[]),
  ('aki_m_j2h', 'aki', 'modern', 'unique', '前J2強', '前ジャンプ中↓+強', '蚣蝮', 137, 9, null, '{}'::text[]),
  ('aki_m_tc_l_l', 'aki', 'modern', 'unique', '5弱>弱', '弱>弱', '渾沌（2段目）', 138, 8, 1, array['C']),
  ('aki_m_tc_h_h', 'aki', 'modern', 'unique', '5強>強', '強>強', '窮奇（2段目・毒破裂対応）', 139, 14, null, '{}'::text[]),

  -- 9. モダン必殺技：ワンボタンSP＆OD版（10種: 150〜159）
  ('aki_m_4sp', 'aki', 'modern', 'special', '後必', '←+SP', '紫煙砲（後必）', 150, 17, -5, array['SA3']),
  ('aki_m_od_4sp', 'aki', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD 紫煙砲（A+後必）', 151, 16, null, array['SA2']),
  ('aki_m_6sp', 'aki', 'modern', 'special', '前必', '→+SP', '強 蛇頭鞭（前必・毒破裂対応）', 152, 11, null, array['SA3']),
  ('aki_m_od_6sp', 'aki', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD 蛇頭鞭（A+前必・毒破裂対応）', 153, 21, 4, array['SA2']),
  ('aki_m_1sp', 'aki', 'modern', 'special', '左下必', '↙+SP', '弱 凶襲突（左下必）', 154, 24, 2, array['SA3']),
  ('aki_m_2sp', 'aki', 'modern', 'special', '下必', '↓+SP', '中 凶襲突（下必）', 155, 28, 3, array['SA3']),
  ('aki_m_3sp', 'aki', 'modern', 'special', '右下必', '↘+SP', '強 凶襲突（右下必）', 156, 33, 4, array['SA3']),
  ('aki_m_od_2sp', 'aki', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD 凶襲突（A+下必）', 157, 28, null, array['SA2']),
  ('aki_m_sp', 'aki', 'modern', 'special', 'N必', 'SP', '中 蛇軽功（N必）', 158, null, null, '{}'::text[]),
  ('aki_m_od_sp', 'aki', 'modern', 'special', 'A+N必', 'A+SP', 'OD 蛇軽功（A+N必）', 159, null, null, '{}'::text[]),

  -- 10. モダン必殺技：コマンド入力版＆派生技（14種: 165〜178）
  ('aki_m_214l', 'aki', 'modern', 'special', '214弱', '↓↙←+弱', '紫煙砲', 165, 17, -5, array['SA3']),
  ('aki_m_214od', 'aki', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD 紫煙砲', 166, 16, null, array['SA2']),
  ('aki_m_shientsui', 'aki', 'modern', 'special', '紫煙追', '紫煙砲中→+攻撃', '紫煙追（毒破裂対応）', 167, 13, -4, array['SA3']),
  ('aki_m_shientsui_od', 'aki', 'modern', 'special', 'OD紫煙追', 'OD紫煙砲中→+攻撃', 'OD 紫煙追（毒破裂対応）', 168, 13, null, array['SA2']),
  ('aki_m_214m', 'aki', 'modern', 'special', '214中', '↓↙←+中', '紫泡泉', 169, 26, null, '{}'::text[]),
  ('aki_m_214h', 'aki', 'modern', 'special', '214強', '↓↙←+強', '紫泡撒', 170, 13, null, array['SA3']),
  ('aki_m_236l', 'aki', 'modern', 'special', '236弱', '↓↘→+弱', '弱 蛇頭鞭（毒破裂対応）', 171, 14, 1, array['SA3']),
  ('aki_m_236m', 'aki', 'modern', 'special', '236中', '↓↘→+中', '中 蛇頭鞭（毒破裂対応）', 172, 14, null, array['SA3']),
  ('aki_m_236h', 'aki', 'modern', 'special', '236強', '↓↘→+強', '強 蛇頭鞭（毒破裂対応）', 173, 11, null, array['SA3']),
  ('aki_m_236od', 'aki', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD 蛇頭鞭（毒破裂対応）', 174, 21, 4, array['SA2']),
  ('aki_m_dakou', 'aki', 'modern', 'special', '2中強(悪鬼蛇行)', '↓+中+強', '悪鬼蛇行', 175, null, null, '{}'::text[]),
  ('aki_m_dakou_p', 'aki', 'modern', 'special', '猛毒牙', '悪鬼蛇行中攻撃', '猛毒牙（毒破裂対応）', 176, 19, null, '{}'::text[]),
  ('aki_m_dakou_k', 'aki', 'modern', 'special', '蛇連咬', '悪鬼蛇行中↓+攻撃', '蛇連咬', 177, 11, 4, array['SA3']),
  ('aki_m_dakou_throw', 'aki', 'modern', 'special', '雁字搦', '悪鬼蛇行中←+攻撃', '雁字搦', 178, 23, null, '{}'::text[]),

  -- 11. モダンスーパーアーツ（3種: 190〜192、CA除外）
  ('aki_m_sa1', 'aki', 'modern', 'super', 'SA1', 'SP+強', 'SA1 死屍累々', 190, 10, null, '{}'::text[]),
  ('aki_m_sa2', 'aki', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 紫煙裂爪', 191, 7, null, '{}'::text[]),
  ('aki_m_sa3', 'aki', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 睚眦', 192, 10, null, '{}'::text[]),

  -- 12. モダン通常投げ（2種: 200〜201）
  ('aki_m_throw_f', 'aki', 'modern', 'throw', '前投げ', '弱+中', '贔屓（前投げ）', 200, 5, null, '{}'::text[]),
  ('aki_m_throw_b', 'aki', 'modern', 'throw', '後ろ投げ', '←+弱+中', '饕餮（後ろ投げ）', 201, 5, null, '{}'::text[])
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
