-- =============================================================================
-- Migration: 009_add_ryu_character_and_moves.sql
-- 目的: 6人目の対応キャラクター「リュウ（ryu）」のキャラクターマスタおよび
--       全技マスタ（全135技：クラシック64種＋モダン71種・
--       公式フレームデータ＆コマンドリスト準拠・CA除外）を
--       既存の Supabase 本番 DB へ安全・冪等に UPSERT する
-- 前提: 001_add_throw_category.sql を先に適用済みであること
-- =============================================================================

-- 1. キャラクターマスタへリュウを追加・更新
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
  ('ryu', 'ryu', 'リュウ', 'Ryu', 6, true, '電刃練気', '電刃', 1)
on conflict (id) do update set
  slug = excluded.slug,
  name_ja = excluded.name_ja,
  name_en = excluded.name_en,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  stock_label = excluded.stock_label,
  stock_short_label = excluded.stock_short_label,
  stock_max_count = excluded.stock_max_count;

-- 2. リュウ全技マスタ（全135技）を UPSERT
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

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('ryu_5lp', 'ryu', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（ジャブ）', 10, 4, 4, array['C']),
  ('ryu_5lk', 'ryu', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（ローキック）', 11, 5, 2, array['C']),
  ('ryu_5mp', 'ryu', 'classic', 'normal', '5中P', '中P', '立ち中P（鉤突き）', 12, 6, 7, array['C']),
  ('ryu_5mk', 'ryu', 'classic', 'normal', '5中K', '中K', '立ち中K（横蹴り）', 13, 9, 4, '{}'::text[]),
  ('ryu_5hp', 'ryu', 'classic', 'normal', '5強P', '強P', '立ち強P（正拳突き）', 14, 10, 4, array['C']),
  ('ryu_5hk', 'ryu', 'classic', 'normal', '5強K', '強K', '立ち強K（後ろ回し蹴り）', 15, 12, 9, '{}'::text[]),
  ('ryu_2lp', 'ryu', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（ジャブ）', 20, 4, 4, array['C']),
  ('ryu_2lk', 'ryu', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（キック）', 21, 5, 3, '{}'::text[]),
  ('ryu_2mp', 'ryu', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（ストレート）', 22, 6, 5, array['C']),
  ('ryu_2mk', 'ryu', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（くるぶしキック）', 23, 8, 1, array['C']),
  ('ryu_2hp', 'ryu', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（突き上げアッパー）', 24, 9, 1, array['C']),
  ('ryu_2hk', 'ryu', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（回転足払い）', 25, 9, null, '{}'::text[]),
  ('ryu_jlp', 'ryu', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（肘落とし）', 30, 4, null, '{}'::text[]),
  ('ryu_jlk', 'ryu', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（ひざ蹴り）', 31, 6, null, '{}'::text[]),
  ('ryu_jmp', 'ryu', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（すくい突き）', 32, 8, null, array['C']),
  ('ryu_jmk', 'ryu', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（飛び蹴り）', 33, 7, null, '{}'::text[]),
  ('ryu_jhp', 'ryu', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（ストレート）', 34, 9, null, '{}'::text[]),
  ('ryu_jhk', 'ryu', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（跳び前蹴り）', 35, 10, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 8種: 40〜47）
  ('ryu_6mp', 'ryu', 'classic', 'unique', '6中P', '→+中P', '鎖骨割り', 40, 20, 3, '{}'::text[]),
  ('ryu_6hp', 'ryu', 'classic', 'unique', '6強P', '→+強P', '鳩尾砕き', 41, 20, 6, '{}'::text[]),
  ('ryu_4hp', 'ryu', 'classic', 'unique', '4強P', '←+強P', '上げ突き', 42, 7, 1, array['C']),
  ('ryu_4hk', 'ryu', 'classic', 'unique', '4強K', '←+強K', 'かかと落とし', 43, 10, 0, array['C']),
  ('ryu_6hk', 'ryu', 'classic', 'unique', '6強K', '→+強K', '旋風脚', 44, 16, 2, '{}'::text[]),
  ('ryu_tc_5hp_5hk', 'ryu', 'classic', 'unique', '5強P>強K', '強P>強K', '上段二連撃', 45, 9, null, '{}'::text[]),
  ('ryu_tc_5mp_5lk', 'ryu', 'classic', 'unique', '5中P>弱K', '中P>弱K', '不破三連撃（2段目）', 46, 5, 1, '{}'::text[]),
  ('ryu_tc_5mp_5lk_5hk', 'ryu', 'classic', 'unique', '5中P>弱K>強K', '中P>弱K>強K', '不破三連撃（3段目）', 47, 17, null, '{}'::text[]),

  -- 3. 必殺技（クラシック 27種: 50〜76）
  ('ryu_236lp', 'ryu', 'classic', 'special', '236弱P', '↓↘→+弱P', '弱 波動拳', 50, 16, 2, array['SA3']),
  ('ryu_236mp', 'ryu', 'classic', 'special', '236中P', '↓↘→+中P', '中 波動拳', 51, 14, 0, array['SA3']),
  ('ryu_236hp', 'ryu', 'classic', 'special', '236強P', '↓↘→+強P', '強 波動拳', 52, 12, -2, array['SA3']),
  ('ryu_236p_ex', 'ryu', 'classic', 'special', '[強化]236P', '[強化]↓↘→+P', '[強化版]波動拳', 53, 12, null, array['SA3']),
  ('ryu_236odp', 'ryu', 'classic', 'special', 'OD236PP', '↓↘→+PP', 'OD 波動拳', 54, 12, null, array['SA2']),
  ('ryu_236odp_ex', 'ryu', 'classic', 'special', '[強化]OD236PP', '[強化]↓↘→+PP', '[強化版]OD 波動拳', 55, 12, null, array['SA2']),
  ('ryu_623lp', 'ryu', 'classic', 'special', '623弱P', '→↓↘+弱P', '弱 昇龍拳', 56, 5, null, array['SA3']),
  ('ryu_623mp', 'ryu', 'classic', 'special', '623中P', '→↓↘+中P', '中 昇龍拳', 57, 6, null, array['SA3']),
  ('ryu_623hp', 'ryu', 'classic', 'special', '623強P', '→↓↘+強P', '強 昇龍拳', 58, 7, null, array['SA3']),
  ('ryu_623odp', 'ryu', 'classic', 'special', 'OD623PP', '→↓↘+PP', 'OD 昇龍拳', 59, 6, null, '{}'::text[]),
  ('ryu_214lk', 'ryu', 'classic', 'special', '214弱K', '↓↙←+弱K', '弱 竜巻旋風脚', 60, 12, null, '{}'::text[]),
  ('ryu_214mk', 'ryu', 'classic', 'special', '214中K', '↓↙←+中K', '中 竜巻旋風脚', 61, 14, null, '{}'::text[]),
  ('ryu_214hk', 'ryu', 'classic', 'special', '214強K', '↓↙←+強K', '強 竜巻旋風脚', 62, 16, null, '{}'::text[]),
  ('ryu_214odk', 'ryu', 'classic', 'special', 'OD214KK', '↓↙←+KK', 'OD 竜巻旋風脚', 63, 13, null, '{}'::text[]),
  ('ryu_air_214k', 'ryu', 'classic', 'special', '空中214K', '前J中↓↙←+K', '空中竜巻旋風脚', 64, 11, null, '{}'::text[]),
  ('ryu_air_214odk', 'ryu', 'classic', 'special', 'OD空中214KK', '前J中↓↙←+KK', 'OD 空中竜巻旋風脚', 65, 11, null, '{}'::text[]),
  ('ryu_236lk', 'ryu', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 上段足刀蹴り', 66, 14, null, array['SA3']),
  ('ryu_236mk', 'ryu', 'classic', 'special', '236中K', '↓↘→+中K', '中 上段足刀蹴り', 67, 18, null, array['SA3']),
  ('ryu_236hk', 'ryu', 'classic', 'special', '236強K', '↓↘→+強K', '強 上段足刀蹴り', 68, 27, null, array['SA3']),
  ('ryu_236odk', 'ryu', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD 上段足刀蹴り', 69, 17, null, array['SA2']),
  ('ryu_214lp', 'ryu', 'classic', 'special', '214弱P', '↓↙←+弱P', '弱 波掌撃', 70, 12, 2, array['SA3']),
  ('ryu_214mp', 'ryu', 'classic', 'special', '214中P', '↓↙←+中P', '中 波掌撃', 71, 19, 2, array['SA3']),
  ('ryu_214hp', 'ryu', 'classic', 'special', '214強P', '↓↙←+強P', '強 波掌撃', 72, 30, null, array['SA3']),
  ('ryu_214p_ex', 'ryu', 'classic', 'special', '[強化]214P', '[強化]↓↙←+P', '[強化版]波掌撃', 73, 20, null, array['SA3']),
  ('ryu_214odp', 'ryu', 'classic', 'special', 'OD214PP', '↓↙←+PP', 'OD 波掌撃', 74, 18, 3, array['SA2']),
  ('ryu_214odp_ex', 'ryu', 'classic', 'special', '[強化]OD214PP', '[強化]↓↙←+PP', '[強化版]OD 波掌撃', 75, 18, null, array['SA2']),
  ('ryu_22p', 'ryu', 'classic', 'special', '22P', '↓↓+P', '電刃錬気', 76, null, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 9種: 80〜88、CA除外）
  ('ryu_sa1', 'ryu', 'classic', 'super', 'SA1', '↓↘→↓↘→+P', 'SA1 真空波動拳', 80, 7, null, '{}'::text[]),
  ('ryu_sa1_ex', 'ryu', 'classic', 'super', '[強化]SA1', '[強化]↓↘→↓↘→+P', '[強化版]SA1 真空波動拳', 81, 7, null, '{}'::text[]),
  ('ryu_sa2_lv1', 'ryu', 'classic', 'super', 'SA2(Lv1)', '↓↙←↓↙←+P', 'SA2 真・波掌撃（Lv1）', 82, 12, null, '{}'::text[]),
  ('ryu_sa2_lv2', 'ryu', 'classic', 'super', 'SA2(Lv2)', '↓↙←↓↙←+Pホールド', 'SA2 真・波掌撃（Lv2）', 83, 20, null, '{}'::text[]),
  ('ryu_sa2_lv3', 'ryu', 'classic', 'super', 'SA2(Lv3)', '↓↙←↓↙←+P最大ホールド', 'SA2 真・波掌撃（Lv3）', 84, 70, null, '{}'::text[]),
  ('ryu_sa2_lv1_ex', 'ryu', 'classic', 'super', '[強化]SA2(Lv1)', '[強化]↓↙←↓↙←+P', '[強化版]SA2 真・波掌撃（Lv1）', 85, 12, null, '{}'::text[]),
  ('ryu_sa2_lv2_ex', 'ryu', 'classic', 'super', '[強化]SA2(Lv2)', '[強化]↓↙←↓↙←+Pホールド', '[強化版]SA2 真・波掌撃（Lv2）', 86, 20, null, '{}'::text[]),
  ('ryu_sa2_lv3_ex', 'ryu', 'classic', 'super', '[強化]SA2(Lv3)', '[強化]↓↙←↓↙←+P最大ホールド', '[強化版]SA2 真・波掌撃（Lv3）', 87, 70, null, '{}'::text[]),
  ('ryu_sa3', 'ryu', 'classic', 'super', 'SA3', '↓↘→↓↘→+K', 'SA3 真・昇龍拳', 88, 5, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 2種: 95〜96）
  ('ryu_throw_f', 'ryu', 'classic', 'throw', '前投げ', '弱P+弱K', '背負い投げ（前投げ）', 95, 5, null, '{}'::text[]),
  ('ryu_throw_b', 'ryu', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', '巴投げ（後ろ投げ）', 96, 5, null, '{}'::text[]),

  -- 6. モダン通常技（11種: 110〜120）
  ('ryu_m_5l', 'ryu', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 4, 4, array['C']),
  ('ryu_m_5m', 'ryu', 'modern', 'normal', '5中', '中', '立ち中（立ち中P）', 111, 6, 7, array['C']),
  ('ryu_m_5h', 'ryu', 'modern', 'normal', '5強', '強', '立ち強（立ち強P）', 112, 10, 4, array['C']),
  ('ryu_m_2l', 'ryu', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱K）', 113, 5, 3, '{}'::text[]),
  ('ryu_m_2l_2', 'ryu', 'modern', 'normal', '2弱>2弱', '↓+弱>↓+弱', 'しゃがみ弱連打（しゃがみ弱P）', 114, 4, 4, array['C']),
  ('ryu_m_2m', 'ryu', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 115, 8, 1, array['C']),
  ('ryu_m_2h', 'ryu', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 116, 9, 1, array['C']),
  ('ryu_m_3h', 'ryu', 'modern', 'normal', '3強', '↘+強', '右下強（回転足払い）', 117, 9, null, '{}'::text[]),
  ('ryu_m_jl', 'ryu', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 118, 4, null, '{}'::text[]),
  ('ryu_m_jm', 'ryu', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 119, 8, null, array['C']),
  ('ryu_m_jh', 'ryu', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 120, 10, null, '{}'::text[]),

  -- 7. モダン特殊技・アシスト（16種: 125〜140）
  ('ryu_m_auto_l', 'ryu', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・立ち弱K）', 125, 5, 2, array['C']),
  ('ryu_m_auto_m', 'ryu', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・しゃがみ中P）', 126, 6, 5, array['C']),
  ('ryu_m_auto_h', 'ryu', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・鳩尾砕き）', 127, 20, 6, '{}'::text[]),
  ('ryu_m_j_auto_l', 'ryu', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 128, 6, null, '{}'::text[]),
  ('ryu_m_j_auto_m', 'ryu', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 129, 7, null, '{}'::text[]),
  ('ryu_m_j_auto_h', 'ryu', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 130, 9, null, '{}'::text[]),
  ('ryu_m_auto_l_combo', 'ryu', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 131, 5, null, '{}'::text[]),
  ('ryu_m_auto_2l_combo', 'ryu', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 132, 4, null, '{}'::text[]),
  ('ryu_m_auto_m_combo', 'ryu', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 133, 6, null, '{}'::text[]),
  ('ryu_m_auto_h_combo', 'ryu', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 134, 20, null, '{}'::text[]),
  ('ryu_m_6m', 'ryu', 'modern', 'unique', '6中', '→+中', '鎖骨割り', 135, 20, 3, '{}'::text[]),
  ('ryu_m_4h', 'ryu', 'modern', 'unique', '4強', '←+強', 'かかと落とし', 136, 10, 0, array['C']),
  ('ryu_m_6h', 'ryu', 'modern', 'unique', '6強', '→+強', '旋風脚', 137, 16, 2, '{}'::text[]),
  ('ryu_m_tc_5h_5h', 'ryu', 'modern', 'unique', '5強>強', '強>強', '上段二連撃', 138, 9, null, '{}'::text[]),
  ('ryu_m_tc_5m_5m', 'ryu', 'modern', 'unique', '5中>中', '中>中', '不破三連撃（2段目）', 139, 5, 1, '{}'::text[]),
  ('ryu_m_tc_5m_5m_5m', 'ryu', 'modern', 'unique', '5中>中>中', '中>中>中', '不破三連撃（3段目）', 140, 17, null, '{}'::text[]),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（14種: 145〜158）
  ('ryu_m_sp', 'ryu', 'modern', 'special', 'N必', 'SP', '強 波動拳（N必）', 145, 12, -2, array['SA3']),
  ('ryu_m_sp_ex', 'ryu', 'modern', 'special', '[強化]N必', '[強化]SP', '[強化版]波動拳（N必）', 146, 12, null, array['SA3']),
  ('ryu_m_od_sp', 'ryu', 'modern', 'special', 'A+N必', 'A+SP', 'OD 波動拳（A+N必）', 147, 12, null, array['SA2']),
  ('ryu_m_od_sp_ex', 'ryu', 'modern', 'special', '[強化]A+N必', '[強化]A+SP', '[強化版]OD 波動拳（A+N必）', 148, 12, null, array['SA2']),
  ('ryu_m_6sp', 'ryu', 'modern', 'special', '前必', '→+SP', '強 昇龍拳（前必）', 149, 7, null, array['SA3']),
  ('ryu_m_od_6sp', 'ryu', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD 昇龍拳（A+前必）', 150, 6, null, '{}'::text[]),
  ('ryu_m_4sp', 'ryu', 'modern', 'special', '後必', '←+SP', '中 竜巻旋風脚（後必）', 151, 14, null, '{}'::text[]),
  ('ryu_m_od_4sp', 'ryu', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD 竜巻旋風脚（A+後必）', 152, 13, null, '{}'::text[]),
  ('ryu_m_air_sp', 'ryu', 'modern', 'special', '空必', '前J中SP', '空中竜巻旋風脚（空必）', 153, 11, null, '{}'::text[]),
  ('ryu_m_od_air_sp', 'ryu', 'modern', 'special', 'A+空必', '前J中A+SP', 'OD 空中竜巻旋風脚（A+空必）', 154, 11, null, '{}'::text[]),
  ('ryu_m_1sp', 'ryu', 'modern', 'special', '左下必', '↙+SP', '弱 上段足刀蹴り（左下必）', 155, 14, null, array['SA3']),
  ('ryu_m_2sp', 'ryu', 'modern', 'special', '下必', '↓+SP', '中 上段足刀蹴り（下必）', 156, 18, null, array['SA3']),
  ('ryu_m_3sp', 'ryu', 'modern', 'special', '右下必', '↘+SP', '強 上段足刀蹴り（右下必）', 157, 27, null, array['SA3']),
  ('ryu_m_od_2sp', 'ryu', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD 上段足刀蹴り（A+下必）', 158, 17, null, array['SA2']),

  -- 9. モダン必殺技：コマンド入力版（19種: 165〜183）
  ('ryu_m_236l', 'ryu', 'modern', 'special', '236弱', '↓↘→+弱', '弱 波動拳', 165, 16, 2, array['SA3']),
  ('ryu_m_236m', 'ryu', 'modern', 'special', '236中', '↓↘→+中', '中 波動拳', 166, 14, 0, array['SA3']),
  ('ryu_m_236h', 'ryu', 'modern', 'special', '236強', '↓↘→+強', '強 波動拳', 167, 12, -2, array['SA3']),
  ('ryu_m_236_ex', 'ryu', 'modern', 'special', '[強化]236攻撃', '[強化]↓↘→+攻撃', '[強化版]波動拳', 168, 12, null, array['SA3']),
  ('ryu_m_236od', 'ryu', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD 波動拳', 169, 12, null, array['SA2']),
  ('ryu_m_236od_ex', 'ryu', 'modern', 'special', '[強化]OD236', '[強化]↓↘→+攻撃×2', '[強化版]OD 波動拳', 170, 12, null, array['SA2']),
  ('ryu_m_623l', 'ryu', 'modern', 'special', '623弱', '→↓↘+弱', '弱 昇龍拳', 171, 5, null, array['SA3']),
  ('ryu_m_623m', 'ryu', 'modern', 'special', '623中', '→↓↘+中', '中 昇龍拳', 172, 6, null, array['SA3']),
  ('ryu_m_623h', 'ryu', 'modern', 'special', '623強', '→↓↘+強', '強 昇龍拳', 173, 7, null, array['SA3']),
  ('ryu_m_623od', 'ryu', 'modern', 'special', 'OD623', '→↓↘+攻撃×2', 'OD 昇龍拳', 174, 6, null, '{}'::text[]),
  ('ryu_m_air_214', 'ryu', 'modern', 'special', '空中214', '前J中↓↙←+攻撃', '空中竜巻旋風脚', 175, 11, null, '{}'::text[]),
  ('ryu_m_air_214od', 'ryu', 'modern', 'special', 'OD空中214', '前J中↓↙←+攻撃×2', 'OD 空中竜巻旋風脚', 176, 11, null, '{}'::text[]),
  ('ryu_m_214l', 'ryu', 'modern', 'special', '214弱', '↓↙←+弱', '弱 波掌撃', 177, 12, 2, array['SA3']),
  ('ryu_m_214m', 'ryu', 'modern', 'special', '214中', '↓↙←+中', '中 波掌撃', 178, 19, 2, array['SA3']),
  ('ryu_m_214h', 'ryu', 'modern', 'special', '214強', '↓↙←+強', '強 波掌撃', 179, 30, null, array['SA3']),
  ('ryu_m_214_ex', 'ryu', 'modern', 'special', '[強化]214攻撃', '[強化]↓↙←+攻撃', '[強化版]波掌撃', 180, 20, null, array['SA3']),
  ('ryu_m_214od', 'ryu', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD 波掌撃', 181, 18, 3, array['SA2']),
  ('ryu_m_214od_ex', 'ryu', 'modern', 'special', '[強化]OD214', '[強化]↓↙←+攻撃×2', '[強化版]OD 波掌撃', 182, 18, null, array['SA2']),
  ('ryu_m_22', 'ryu', 'modern', 'special', '22攻撃', '↓↓+攻撃', '電刃錬気', 183, null, null, '{}'::text[]),

  -- 10. モダンスーパーアーツ（9種: 190〜198、CA除外）
  ('ryu_m_sa1', 'ryu', 'modern', 'super', 'SA1', 'SP+強', 'SA1 真空波動拳', 190, 7, null, '{}'::text[]),
  ('ryu_m_sa1_ex', 'ryu', 'modern', 'super', '[強化]SA1', '[強化]SP+強', '[強化版]SA1 真空波動拳', 191, 7, null, '{}'::text[]),
  ('ryu_m_sa2_lv1', 'ryu', 'modern', 'super', 'SA2(Lv1)', '←+SP+強', 'SA2 真・波掌撃（Lv1）', 192, 12, null, '{}'::text[]),
  ('ryu_m_sa2_lv2', 'ryu', 'modern', 'super', 'SA2(Lv2)', '←+SP+強ホールド', 'SA2 真・波掌撃（Lv2）', 193, 20, null, '{}'::text[]),
  ('ryu_m_sa2_lv3', 'ryu', 'modern', 'super', 'SA2(Lv3)', '←+SP+強最大ホールド', 'SA2 真・波掌撃（Lv3）', 194, 70, null, '{}'::text[]),
  ('ryu_m_sa2_lv1_ex', 'ryu', 'modern', 'super', '[強化]SA2(Lv1)', '[強化]←+SP+強', '[強化版]SA2 真・波掌撃（Lv1）', 195, 12, null, '{}'::text[]),
  ('ryu_m_sa2_lv2_ex', 'ryu', 'modern', 'super', '[強化]SA2(Lv2)', '[強化]←+SP+強ホールド', '[強化版]SA2 真・波掌撃（Lv2）', 196, 20, null, '{}'::text[]),
  ('ryu_m_sa2_lv3_ex', 'ryu', 'modern', 'super', '[強化]SA2(Lv3)', '[強化]←+SP+強最大ホールド', '[強化版]SA2 真・波掌撃（Lv3）', 197, 70, null, '{}'::text[]),
  ('ryu_m_sa3', 'ryu', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 真・昇龍拳', 198, 5, null, '{}'::text[]),

  -- 11. モダン通常投げ（2種: 205〜206）
  ('ryu_m_throw_f', 'ryu', 'modern', 'throw', '前投げ', '弱+中', '背負い投げ（前投げ）', 205, 5, null, '{}'::text[]),
  ('ryu_m_throw_b', 'ryu', 'modern', 'throw', '後ろ投げ', '←+弱+中', '巴投げ（後ろ投げ）', 206, 5, null, '{}'::text[])
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
