-- =============================================================================
-- コンボノート (Combo Note) 初期シードデータ投入 SQL
-- 対象: 初期4キャラクター（豪鬼・ジュリ・イングリッド・C.ヴァイパー）
-- ※ ON CONFLICT DO NOTHING により何度実行しても冪等に動作します
-- =============================================================================

-- 1. キャラクターマスタ
insert into public.characters (id, slug, name_ja, name_en, sort_order, is_active, stock_label, stock_short_label, stock_max_count)
values
  ('akuma', 'akuma', '豪鬼', 'Akuma', 1, true, null, null, null),
  ('juri', 'juri', 'ジュリ', 'Juri', 2, true, '風破ストック', '風破', 3),
  ('ingrid', 'ingrid', 'イングリッド', 'Ingrid', 3, true, 'サンシンボル', 'サンシンボル', 4),
  ('c-viper', 'c-viper', 'C.ヴァイパー', 'C. Viper', 4, true, null, null, null)
on conflict (id) do nothing;

-- 2. バージョンマスタ
insert into public.game_versions (id, label, released_at)
values
  ('year2', 'Year 2', '2024-05-22T00:00:00Z'),
  ('year3', 'Year 3', '2025-06-05T00:00:00Z'),
  ('year4', 'Year 4 / Ver.2026', '2026-06-01T00:00:00Z')
on conflict (id) do nothing;

-- 3. 技マスタ（システム共通パーツ: character_id = null）
insert into public.moves (id, character_id, control_type, category, notation_numpad, notation_command, notation_name, sort_order, startup_frames, hit_advantage, cancel_types)
values
  ('sys_dr', null, 'both', 'system', 'CDR', 'CDR', 'キャンセルドライブラッシュ', 1, null, null, null),
  ('sys_raw_dr', null, 'both', 'system', 'DR', 'DR', 'ドライブラッシュ', 2, null, null, null),
  ('sys_di', null, 'both', 'system', 'DI', 'DI', 'ドライブインパクト', 3, null, null, null),
  ('sys_micro_walk', null, 'both', 'system', '微歩き', '微歩き', '微歩き', 4, null, null, null),
  ('sys_dash', null, 'both', 'system', '前ステップ', '前ステップ', '前ステップ', 5, null, null, null),
  ('sys_delay', null, 'both', 'system', 'ディレイ', 'ディレイ', 'ディレイ', 6, null, null, null),
  ('sys_jump', null, 'both', 'system', 'J', '↑', 'ジャンプ', 7, null, null, null),
  ('sys_f_jump', null, 'both', 'system', '前J', '↗', '前ジャンプ', 8, null, null, null),
  ('sys_jc', null, 'both', 'system', 'Jキャン', 'Jキャン', 'ジャンプキャンセル', 9, null, null, null)
on conflict (id) do nothing;

-- 3-1. 技マスタ（豪鬼 / akuma）
insert into public.moves (id, character_id, control_type, category, notation_numpad, notation_command, notation_name, sort_order, startup_frames, hit_advantage, cancel_types)
values
  ('akuma_2lp', 'akuma', 'classic', 'normal', '2弱P', '屈弱P', 'しゃがみ弱P', 10, 4, 4, array['special', 'super']),
  ('akuma_5lk', 'akuma', 'classic', 'normal', '5弱K', '立弱K', '立ち弱K', 11, 5, 2, array['special', 'super']),
  ('akuma_5mp', 'akuma', 'classic', 'normal', '5中P', '立中P', '立ち中P', 12, 6, 7, array['special', 'super']),
  ('akuma_2mp', 'akuma', 'classic', 'normal', '2中P', '屈中P', 'しゃがみ中P', 13, 6, 5, array['special', 'super']),
  ('akuma_2mk', 'akuma', 'classic', 'normal', '2中K', '屈中K', 'しゃがみ中K', 14, 8, 2, array['special', 'super']),
  ('akuma_5hp', 'akuma', 'classic', 'normal', '5大P', '立強P', '立ち強P', 15, 9, 3, array['special', 'super']),
  ('akuma_5hk', 'akuma', 'classic', 'normal', '5大K', '立強K', '立ち強K', 16, 13, 4, null),
  ('akuma_4hk', 'akuma', 'classic', 'unique', '4大K', '←+強K', '羅漢（後ろ強K）', 30, null, null, null),
  ('akuma_m_auto_m', 'akuma', 'modern', 'normal', 'A中', 'アシスト中', 'アシスト中（立中P）', 40, null, null, null),
  ('akuma_m_2m', 'akuma', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（屈中K）', 41, null, null, null),
  ('akuma_m_auto_h', 'akuma', 'modern', 'normal', 'A強', 'アシスト強', 'アシスト強（立強P）', 42, null, null, null),
  ('akuma_214lk', 'akuma', 'classic', 'special', '214弱K', '↓↙←+弱K', '弱竜巻斬空脚', 50, null, null, null),
  ('akuma_214hk', 'akuma', 'classic', 'special', '214大K', '↓↙←+強K', '強竜巻斬空脚', 51, null, null, null),
  ('akuma_214hp', 'akuma', 'classic', 'special', '214大P', '↓↙←+強P', '強金剛灼火', 52, null, null, null),
  ('akuma_214odp', 'akuma', 'classic', 'special', '214PP', '↓↙←+PP', 'OD金剛灼火', 53, null, null, null),
  ('akuma_623hp', 'akuma', 'classic', 'special', '623大P', '→↓↘+強P', '強豪昇龍拳', 54, null, null, null),
  ('akuma_236hk_dive', 'akuma', 'classic', 'special', '236大K>P', '↓↘→+強K>P', '百鬼襲〜百鬼豪刃', 55, null, null, null),
  ('akuma_m_4sp', 'akuma', 'modern', 'special', '4SP', '←+SP', '竜巻斬空脚（後SP）', 60, null, null, null),
  ('akuma_m_6sp', 'akuma', 'modern', 'special', '6SP', '→+SP', '豪昇龍拳（前SP）', 61, null, null, null),
  ('akuma_sa1', 'akuma', 'both', 'super', 'SA1', '↓↘→↓↘→+P', '滅殺豪波動（SA1）', 70, null, null, null),
  ('akuma_sa3', 'akuma', 'both', 'super', 'SA3', '↓↙←↓↙←+K', '禍坏（SA3）', 71, null, null, null)
on conflict (id) do nothing;

-- 3-2. 技マスタ（ジュリ / juri: 全111技・クラシック53種＋モダン58種・公式フレームデータ準拠・CA除外）
insert into public.moves (id, character_id, control_type, category, notation_numpad, notation_command, notation_name, sort_order, startup_frames, hit_advantage, cancel_types)
values
  -- 1. 通常技（クラシック 19種: 立ち 10〜19 / しゃがみ 20〜29 / ジャンプ 30〜39）
  ('juri_5lp', 'juri', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（首甲殺）', 10, 4, 5, array['C']),
  ('juri_5lk', 'juri', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（微弄脚）', 11, 5, 2, array['C']),
  ('juri_5mp', 'juri', 'classic', 'normal', '5中P', '中P', '立ち中P（胸破殺）', 12, 6, 7, array['C']),
  ('juri_5mk', 'juri', 'classic', 'normal', '5中K', '中K', '立ち中K（伸腿蹴）', 13, 5, 3, array['C']),
  ('juri_5hp', 'juri', 'classic', 'normal', '5強P', '強P', '立ち強P（蜘殺）', 14, 10, -1, array['C']),
  ('juri_5hk', 'juri', 'classic', 'normal', '5強K', '強K', '立ち強K（空耀脚）', 15, 17, 2, '{}'::text[]),
  ('juri_2lp', 'juri', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（狙腓打）', 20, 4, 4, array['C']),
  ('juri_2lk', 'juri', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（踵打）', 21, 5, 3, '{}'::text[]),
  ('juri_2mp', 'juri', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（妖撞）', 22, 6, 5, array['C']),
  ('juri_2mk', 'juri', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（剥影脚）', 23, 8, 1, array['C']),
  ('juri_2hp', 'juri', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（穿開脚）', 24, 8, 3, array['C']),
  ('juri_2hk', 'juri', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（刈脚）', 25, 10, null, '{}'::text[]),
  ('juri_jlp', 'juri', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（空形殺）', 30, 5, null, '{}'::text[]),
  ('juri_jlk', 'juri', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（膝空打）', 31, 4, null, '{}'::text[]),
  ('juri_jmp', 'juri', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（空洛刃）', 32, 7, null, array['C']),
  ('juri_jmk', 'juri', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（被陰脚）', 33, 6, null, '{}'::text[]),
  ('juri_jhp', 'juri', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（空震脚）', 34, 12, null, '{}'::text[]),
  ('juri_jhk', 'juri', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（玄空蹴）', 35, 10, null, '{}'::text[]),
  ('juri_njhk', 'juri', 'classic', 'normal', '垂直J強K', '垂直J中強K', '垂直ジャンプ強K（横圧殺）', 36, 10, null, '{}'::text[]),
  -- 2. 特殊技（クラシック 6種: 40〜49）
  ('juri_6mp', 'juri', 'classic', 'unique', '6中P', '→+中P', '狂背掌', 40, 8, 4, array['C']),
  ('juri_6mk', 'juri', 'classic', 'unique', '6中K', '→+中K', '殲廻脚', 41, 21, 2, '{}'::text[]),
  ('juri_6hp', 'juri', 'classic', 'unique', '6強P', '→+強P', '連剋脚', 42, 15, 2, array['C']),
  ('juri_4hk', 'juri', 'classic', 'unique', '4強K', '←+強K', '鉤鎌斬', 43, 10, 3, array['C']),
  ('juri_tc_shimon2', 'juri', 'classic', 'unique', '死紋蹴(2段)', '中K>←+強K', '死紋蹴（2段目）', 44, 12, null, '{}'::text[]),
  ('juri_tc_shimon3', 'juri', 'classic', 'unique', '死紋蹴(3段)', '中K>←+強K>強K', '死紋蹴（3段目）', 45, 17, null, array['SA']),
  -- 3. 必殺技（クラシック 21種: 50〜79）
  ('juri_214lk', 'juri', 'classic', 'special', '214弱K', '↓↙←+弱K', '弱 風破刃', 50, 10, null, array['SA3']),
  ('juri_214mk', 'juri', 'classic', 'special', '214中K', '↓↙←+中K', '中 風破刃', 51, 13, null, array['SA3']),
  ('juri_214hk', 'juri', 'classic', 'special', '214強K', '↓↙←+強K', '強 風破刃', 52, 25, null, array['SA3']),
  ('juri_214odk', 'juri', 'classic', 'special', 'OD214KK', '↓↙←+KK', 'OD 風破刃', 53, 12, null, array['SA2']),
  ('juri_236lk', 'juri', 'classic', 'special', '236弱K', '↓↘→+弱K', '歳破衝', 54, 16, -2, array['SA3']),
  ('juri_236lk_ex', 'juri', 'classic', 'special', '[強化]236弱K', '[強化]↓↘→+弱K', '[強化版]歳破衝', 55, 16, 1, array['SA3']),
  ('juri_236od_lk_mk', 'juri', 'classic', 'special', 'OD236弱中K', '↓↘→+弱K中K', 'OD 歳破衝', 56, 11, null, array['SA2']),
  ('juri_236mk', 'juri', 'classic', 'special', '236中K', '↓↘→+中K', '暗剣殺', 57, 24, 5, array['SA3']),
  ('juri_236mk_ex', 'juri', 'classic', 'special', '[強化]236中K', '[強化]↓↘→+中K', '[強化版]暗剣殺', 58, 24, 8, array['SA3']),
  ('juri_236odk', 'juri', 'classic', 'special', 'OD236弱強K', '↓↘→+弱K強K', 'OD 暗剣殺', 59, 24, 9, array['SA2']),
  ('juri_236hk', 'juri', 'classic', 'special', '236強K', '↓↘→+強K', '五黄殺', 60, 18, null, array['SA3']),
  ('juri_236hk_ex', 'juri', 'classic', 'special', '[強化]236強K', '[強化]↓↘→+強K', '[強化版]五黄殺', 61, 18, null, array['SA3']),
  ('juri_236od_mk_hk', 'juri', 'classic', 'special', 'OD236中強K', '↓↘→+中K強K', 'OD 五黄殺', 62, 18, null, array['SA2']),
  ('juri_623lp', 'juri', 'classic', 'special', '623弱P', '→↓↘+弱P', '弱 天穿輪', 63, 11, null, array['SA3']),
  ('juri_623mp', 'juri', 'classic', 'special', '623中P', '→↓↘+中P', '中 天穿輪', 64, 5, null, '{}'::text[]),
  ('juri_623hp', 'juri', 'classic', 'special', '623強P', '→↓↘+強P', '強 天穿輪', 65, 5, null, '{}'::text[]),
  ('juri_623odp', 'juri', 'classic', 'special', 'OD623PP', '→↓↘+PP', 'OD 天穿輪', 66, 6, null, '{}'::text[]),
  ('juri_air_214k', 'juri', 'classic', 'special', '空中214K', '前J中↓↙←+K', '疾空閃', 67, 18, null, '{}'::text[]),
  ('juri_air_214odk', 'juri', 'classic', 'special', 'OD空中214KK', '前J中↓↙←+KK', 'OD 疾空閃', 68, 16, null, '{}'::text[]),
  ('juri_shiku_k', 'juri', 'classic', 'special', '派生K', '疾空閃後K', '死連閃', 69, 6, null, '{}'::text[]),
  ('juri_shiku_odkk', 'juri', 'classic', 'special', 'OD派生KK', 'OD疾空閃後KK', 'OD 死連閃', 70, 6, null, '{}'::text[]),
  -- 4. スーパーアーツ（クラシック 4種: 80〜89、CA除外）
  ('juri_sa1', 'juri', 'classic', 'super', 'SA1', '↓↘→↓↘→+K', 'SA1 殺界風破斬', 80, 7, null, '{}'::text[]),
  ('juri_sa2', 'juri', 'classic', 'super', 'SA2(風水)', '↓↙←↓↙←+P', 'SA2 風水エンジン', 81, 7, null, '{}'::text[]),
  ('juri_sa2_dash', 'juri', 'classic', 'super', 'SA2(突進)', '↓↙←↓↙←+Pホールド', 'SA2 風水エンジン（突進）', 82, 9, -4, array['C']),
  ('juri_sa3', 'juri', 'classic', 'super', 'SA3', '↓↙←↓↙←+K', 'SA3 回旋断界落', 83, 10, null, '{}'::text[]),
  -- 5. 通常投げ（クラシック 3種: 90〜99）
  ('juri_throw_f', 'juri', 'classic', 'throw', '前投げ', '弱P+弱K', '蜘穿脚（前投げ）', 90, 5, null, '{}'::text[]),
  ('juri_throw_b', 'juri', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', '苛影脚（後ろ投げ）', 91, 5, null, '{}'::text[]),
  ('juri_throw_air', 'juri', 'classic', 'throw', '空投げ', '空中で弱P+弱K', '斬架閃（空中投げ）', 92, 5, null, '{}'::text[]),
  -- 6. モダン専用パーツ（58種: modern / 110〜199・P/K表記なし）
  ('juri_m_5l', 'juri', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 4, 5, array['C']),
  ('juri_m_5m', 'juri', 'modern', 'normal', '5中', '中', '立ち中（立ち中K）', 111, 5, 3, array['C']),
  ('juri_m_5h', 'juri', 'modern', 'normal', '5強', '強', '立ち強（立ち強K）', 112, 17, 2, '{}'::text[]),
  ('juri_m_2l', 'juri', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱K）', 113, 5, 3, '{}'::text[]),
  ('juri_m_2m', 'juri', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 114, 8, 1, array['C']),
  ('juri_m_2h', 'juri', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 115, 8, 3, array['C']),
  ('juri_m_jl', 'juri', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱K）', 116, 4, null, '{}'::text[]),
  ('juri_m_jm', 'juri', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 117, 7, null, array['C']),
  ('juri_m_jh', 'juri', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 118, 10, null, '{}'::text[]),
  ('juri_m_auto_l', 'juri', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・しゃがみ弱P）', 120, 4, 4, array['C']),
  ('juri_m_auto_m', 'juri', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・立ち中P）', 121, 6, 7, array['C']),
  ('juri_m_auto_h', 'juri', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち強P）', 122, 10, -1, array['C']),
  ('juri_m_auto_l_combo', 'juri', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ弱', 123, 4, null, '{}'::text[]),
  ('juri_m_auto_m_combo', 'juri', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ中', 124, 6, null, '{}'::text[]),
  ('juri_m_auto_h_combo', 'juri', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ強', 125, 10, null, '{}'::text[]),
  ('juri_m_6m', 'juri', 'modern', 'unique', '6中', '→+中', '殲廻脚', 126, 21, 2, '{}'::text[]),
  ('juri_m_6h', 'juri', 'modern', 'unique', '6強', '→+強', '連剋脚', 127, 15, 2, array['C']),
  ('juri_m_4h', 'juri', 'modern', 'unique', '4強', '←+強', '鉤鎌斬', 128, 10, 3, array['C']),
  ('juri_m_tc_shimon2', 'juri', 'modern', 'unique', '死紋蹴(2段)', '中>←+強', '死紋蹴（2段目）', 129, 12, null, '{}'::text[]),
  ('juri_m_tc_shimon3', 'juri', 'modern', 'unique', '死紋蹴(3段)', '中>←+強>強', '死紋蹴（3段目）', 130, 17, null, array['SA']),
  ('juri_m_sp', 'juri', 'modern', 'special', 'N必', 'SP', '歳破衝（N必）', 135, 16, -2, array['SA3']),
  ('juri_m_6sp', 'juri', 'modern', 'special', '前必', '→+SP', '天穿輪（前必）', 136, 5, null, '{}'::text[]),
  ('juri_m_2sp', 'juri', 'modern', 'special', '下必', '↓+SP', '風破刃（下必）', 137, 13, null, array['SA3']),
  ('juri_m_4sp', 'juri', 'modern', 'special', '後必', '←+SP', '五黄殺（後必）', 138, 18, null, array['SA3']),
  ('juri_m_air_sp', 'juri', 'modern', 'special', '空必', '空中でSP', '疾空閃（空必）', 139, 18, null, '{}'::text[]),
  ('juri_m_od_sp', 'juri', 'modern', 'special', 'A+N必', 'A+SP', 'OD 歳破衝（A+N必）', 140, 11, null, array['SA2']),
  ('juri_m_od_6sp', 'juri', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD 天穿輪（A+前必）', 141, 6, null, '{}'::text[]),
  ('juri_m_od_2sp', 'juri', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD 風破刃（A+下必）', 142, 12, null, array['SA2']),
  ('juri_m_od_4sp', 'juri', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD 五黄殺（A+後必）', 143, 18, null, array['SA2']),
  ('juri_m_od_air_sp', 'juri', 'modern', 'special', 'A+空必', '空中でA+SP', 'OD 疾空閃（A+空必）', 144, 16, null, '{}'::text[]),
  ('juri_m_214l', 'juri', 'modern', 'special', '214弱', '↓↙←+弱', '弱 風破刃', 150, 10, null, array['SA3']),
  ('juri_m_214m', 'juri', 'modern', 'special', '214中', '↓↙←+中', '中 風破刃', 151, 13, null, array['SA3']),
  ('juri_m_214h', 'juri', 'modern', 'special', '214強', '↓↙←+強', '強 風破刃', 152, 25, null, array['SA3']),
  ('juri_m_214od', 'juri', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD 風破刃', 153, 12, null, array['SA2']),
  ('juri_m_236l', 'juri', 'modern', 'special', '236弱', '↓↘→+弱', '歳破衝', 154, 16, -2, array['SA3']),
  ('juri_m_236l_ex', 'juri', 'modern', 'special', '[強化]236弱', '[強化]↓↘→+弱', '[強化版]歳破衝', 155, 16, 1, array['SA3']),
  ('juri_m_236od_lm', 'juri', 'modern', 'special', 'OD236弱+中', '↓↘→+弱+中', 'OD 歳破衝', 156, 11, null, array['SA2']),
  ('juri_m_236m', 'juri', 'modern', 'special', '236中', '↓↘→+中', '暗剣殺', 157, 24, 5, array['SA3']),
  ('juri_m_236m_ex', 'juri', 'modern', 'special', '[強化]236中', '[強化]↓↘→+中', '[強化版]暗剣殺', 158, 24, 8, array['SA3']),
  ('juri_m_236od_lh', 'juri', 'modern', 'special', 'OD236弱+強', '↓↘→+弱+強', 'OD 暗剣殺', 159, 24, 9, array['SA2']),
  ('juri_m_236h', 'juri', 'modern', 'special', '236強', '↓↘→+強', '五黄殺', 160, 18, null, array['SA3']),
  ('juri_m_236h_ex', 'juri', 'modern', 'special', '[強化]236強', '[強化]↓↘→+強', '[強化版]五黄殺', 161, 18, null, array['SA3']),
  ('juri_m_236od_mh', 'juri', 'modern', 'special', 'OD236中+強', '↓↘→+中+強', 'OD 五黄殺', 162, 18, null, array['SA2']),
  ('juri_m_623l', 'juri', 'modern', 'special', '623弱', '→↓↘+弱', '弱 天穿輪', 163, 11, null, array['SA3']),
  ('juri_m_623m', 'juri', 'modern', 'special', '623中', '→↓↘+中', '中 天穿輪', 164, 5, null, '{}'::text[]),
  ('juri_m_623h', 'juri', 'modern', 'special', '623強', '→↓↘+強', '強 天穿輪', 165, 5, null, '{}'::text[]),
  ('juri_m_623od', 'juri', 'modern', 'special', 'OD623', '→↓↘+攻撃×2', 'OD 天穿輪', 166, 6, null, '{}'::text[]),
  ('juri_m_air_214', 'juri', 'modern', 'special', '空中214', '前J中↓↙←+攻撃', '疾空閃', 167, 18, null, '{}'::text[]),
  ('juri_m_air_214od', 'juri', 'modern', 'special', 'OD空中214', '前J中↓↙←+攻撃×2', 'OD 疾空閃', 168, 16, null, '{}'::text[]),
  ('juri_m_shiku', 'juri', 'modern', 'special', '派生攻撃', '疾空閃後+攻撃', '死連閃', 169, 6, null, '{}'::text[]),
  ('juri_m_shiku_od', 'juri', 'modern', 'special', 'OD派生', 'OD疾空閃後+攻撃×2', 'OD 死連閃', 170, 6, null, '{}'::text[]),
  ('juri_m_sa1', 'juri', 'modern', 'super', 'SA1', 'SP+強', 'SA1 殺界風破斬', 180, 7, null, '{}'::text[]),
  ('juri_m_sa2', 'juri', 'modern', 'super', 'SA2(風水)', '←+SP+強', 'SA2 風水エンジン', 181, 7, null, '{}'::text[]),
  ('juri_m_sa2_dash', 'juri', 'modern', 'super', 'SA2(突進)', '←+SP+強 ホールド', 'SA2 風水エンジン（突進）', 182, 9, -4, array['C']),
  ('juri_m_sa3', 'juri', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 回旋断界落', 183, 10, null, '{}'::text[]),
  ('juri_m_throw_f', 'juri', 'modern', 'throw', '前投げ', '弱+中', '蜘穿脚（前投げ）', 190, 5, null, '{}'::text[]),
  ('juri_m_throw_b', 'juri', 'modern', 'throw', '後ろ投げ', '←+弱+中', '苛影脚（後ろ投げ）', 191, 5, null, '{}'::text[]),
  ('juri_m_throw_air', 'juri', 'modern', 'throw', '空投げ', '空中で弱+中', '斬架閃（空中投げ）', 192, 5, null, '{}'::text[])
on conflict (id) do nothing;

-- 3-3. 技マスタ（イングリッド / ingrid）
insert into public.moves (id, character_id, control_type, category, notation_numpad, notation_command, notation_name, sort_order, startup_frames, hit_advantage, cancel_types)
values
  ('ingrid_2lp', 'ingrid', 'classic', 'normal', '2弱P', '屈弱P', 'しゃがみ弱P', 10, 4, 4, array['special', 'super']),
  ('ingrid_5mp', 'ingrid', 'classic', 'normal', '5中P', '立中P', '立ち中P', 11, 6, 6, array['special', 'super']),
  ('ingrid_2mp', 'ingrid', 'classic', 'normal', '2中P', '屈中P', 'しゃがみ中P', 12, 6, 5, array['special', 'super']),
  ('ingrid_2mk', 'ingrid', 'classic', 'normal', '2中K', '屈中K', 'しゃがみ中K', 13, 7, 2, array['special', 'super']),
  ('ingrid_5hp', 'ingrid', 'classic', 'normal', '5大P', '立強P', '立ち強P', 14, 9, 3, array['special', 'super']),
  ('ingrid_2hp', 'ingrid', 'classic', 'normal', '2大P', '屈強P', 'しゃがみ強P', 15, 8, 1, array['special', 'super']),
  ('ingrid_jhk', 'ingrid', 'both', 'normal', 'J大K', 'J強K', 'ジャンプ強K', 16, null, null, null),
  ('ingrid_6mk', 'ingrid', 'classic', 'unique', '6中K', '→+中K', 'サンステップキック', 30, null, null, null),
  ('ingrid_m_auto_m', 'ingrid', 'modern', 'normal', 'A中', 'アシスト中', 'アシスト中（立中P）', 40, null, null, null),
  ('ingrid_m_2m', 'ingrid', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（屈中K）', 41, null, null, null),
  ('ingrid_m_auto_h', 'ingrid', 'modern', 'normal', 'A強', 'アシスト強', 'アシスト強（立強P）', 42, null, null, null),
  ('ingrid_236mp', 'ingrid', 'classic', 'special', '236中P', '↓↘→+中P', '中サンシュート', 50, null, null, null),
  ('ingrid_623hk', 'ingrid', 'classic', 'special', '623大K', '→↓↘+強K', '強サンライズ', 51, null, null, null),
  ('ingrid_214mk', 'ingrid', 'classic', 'special', '214中K', '↓↙←+中K', '中サンアーチ', 52, null, null, null),
  ('ingrid_214odk', 'ingrid', 'classic', 'special', '214KK', '↓↙←+KK', 'ODサンアーチ', 53, null, null, null),
  ('ingrid_air_214k', 'ingrid', 'classic', 'special', '空中214K', '空中↓↙←+K', 'サンダイブ', 54, null, null, null),
  ('ingrid_m_6sp', 'ingrid', 'modern', 'special', '6SP', '→+SP', 'サンライズ（前SP）', 60, null, null, null),
  ('ingrid_m_4sp', 'ingrid', 'modern', 'special', '4SP', '←+SP', 'サンアーチ（後SP）', 61, null, null, null),
  ('ingrid_sa1', 'ingrid', 'both', 'super', 'SA1', '↓↘→↓↘→+P', 'サンバースト（SA1）', 70, null, null, null),
  ('ingrid_sa3', 'ingrid', 'both', 'super', 'SA3', '↓↙←↓↙←+K', 'サンデルタ（SA3）', 71, null, null, null)
on conflict (id) do nothing;

-- 3-4. 技マスタ（C.ヴァイパー / c-viper）
insert into public.moves (id, character_id, control_type, category, notation_numpad, notation_command, notation_name, sort_order, startup_frames, hit_advantage, cancel_types)
values
  ('cviper_2lp', 'c-viper', 'classic', 'normal', '2弱P', '屈弱P', 'しゃがみ弱P', 10, 4, 4, array['special', 'super']),
  ('cviper_5mp', 'c-viper', 'classic', 'normal', '5中P', '立中P', '立ち中P', 11, 6, 6, array['special', 'super']),
  ('cviper_2mp', 'c-viper', 'classic', 'normal', '2中P', '屈中P', 'しゃがみ中P', 12, 6, 5, array['special', 'super']),
  ('cviper_2mk', 'c-viper', 'classic', 'normal', '2中K', '屈中K', 'しゃがみ中K', 13, 7, 1, array['special', 'super']),
  ('cviper_5hp', 'c-viper', 'classic', 'normal', '5大P', '立強P', '立ち強P', 14, 9, 3, array['special', 'super']),
  ('cviper_2hp', 'c-viper', 'classic', 'normal', '2大P', '屈強P', 'しゃがみ強P', 15, 8, 2, array['special', 'super']),
  ('cviper_fc', 'c-viper', 'classic', 'system', 'FC', 'フェイント', 'サンダーフェイントキャンセル', 25, null, null, null),
  ('cviper_hjc', 'c-viper', 'both', 'system', 'hjc', 'ハイジャンプ', 'ハイジャンプキャンセル', 26, null, null, null),
  ('cviper_m_auto_m', 'c-viper', 'modern', 'normal', 'A中', 'アシスト中', 'アシスト中（立中P）', 40, null, null, null),
  ('cviper_m_2m', 'c-viper', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（屈中K）', 41, null, null, null),
  ('cviper_m_auto_h', 'c-viper', 'modern', 'normal', 'A強', 'アシスト強', 'アシスト強（立強P）', 42, null, null, null),
  ('cviper_214mp', 'c-viper', 'classic', 'special', '214中P', '↓↙←+中P', '中サンダーナックル', 50, null, null, null),
  ('cviper_214hp', 'c-viper', 'classic', 'special', '214大P', '↓↙←+強P', '強サンダーナックル', 51, null, null, null),
  ('cviper_623hp', 'c-viper', 'classic', 'special', '623大P', '→↓↘+強P', '強セイスモハンマー', 52, null, null, null),
  ('cviper_623odp', 'c-viper', 'classic', 'special', '623PP', '→↓↘+PP', 'ODセイスモハンマー', 53, null, null, null),
  ('cviper_214hk', 'c-viper', 'classic', 'special', '214大K', '↓↙←+強K', '強バーニングキック', 54, null, null, null),
  ('cviper_air_214mk', 'c-viper', 'classic', 'special', '空中214中K', '空中↓↙←+中K', '空中バーニングキック', 55, null, null, null),
  ('cviper_m_sp', 'c-viper', 'modern', 'special', 'SP', 'SP', 'サンダーナックル（SP）', 60, null, null, null),
  ('cviper_m_4sp', 'c-viper', 'modern', 'special', '4SP', '←+SP', 'バーニングキック（後SP）', 61, null, null, null),
  ('cviper_sa1', 'c-viper', 'both', 'super', 'SA1', '↓↘→↓↘→+P', 'エマージェンシーコンビネーション（SA1）', 70, null, null, null),
  ('cviper_sa3', 'c-viper', 'both', 'super', 'SA3', '↓↙←↓↙←+P', 'バーストタイム（SA3）', 71, null, null, null)
on conflict (id) do nothing;

-- 4. 公開コンボ（初期サンプル 19件、author_id = null）
insert into public.combos (
  id, author_id, author_name, character_id, control_type,
  move_ids, recipe_signature, situations, category,
  damage, drive_cost, sa_cost, stock_cost, stock_gain,
  has_oki, note, version_id, likes_count, created_at, updated_at
)
values
  -- 豪鬼 (akuma)
  (
    '10000000-0000-4000-8000-000000000001',
    null, '運営シード', 'akuma', 'classic',
    '["akuma_2mk","sys_dr","akuma_2mp","akuma_5hp","akuma_214lk","akuma_623hp"]'::jsonb,
    'akuma:classic:akuma_2mk>sys_dr>akuma_2mp>akuma_5hp>akuma_214lk>akuma_623hp',
    array['midscreen'], 'standard',
    2740, 3.0, 0, 0, 0,
    true, '豪鬼の中央定番ラッシュコンボ。弱竜巻で浮かせてから強豪昇龍拳で締める。画面端が近ければ214大K（強竜巻）締めも強力。',
    'year4', 51, '2026-11-10T11:00:00Z', '2026-11-10T11:00:00Z'
  ),
  (
    '10000000-0000-4000-8000-000000000002',
    null, '運営シード', 'akuma', 'classic',
    '["akuma_5mp","akuma_5hp","akuma_214odp","akuma_4hk","akuma_214hk"]'::jsonb,
    'akuma:classic:akuma_5mp>akuma_5hp>akuma_214odp>akuma_4hk>akuma_214hk',
    array['corner'], 'optimal',
    3680, 2.0, 0, 0, 0,
    true, '画面端OD金剛灼火の壁バウンドから4大K（羅漢）で拾って強竜巻で締める高火力ルート。起き攻め状況が非常に良い。',
    'year4', 38, '2026-11-11T14:20:00Z', '2026-11-11T14:20:00Z'
  ),
  (
    '10000000-0000-4000-8000-000000000003',
    null, '運営シード', 'akuma', 'classic',
    '["akuma_5hk","sys_micro_walk","akuma_5hp","akuma_214hp","akuma_sa3"]'::jsonb,
    'akuma:classic:akuma_5hk>sys_micro_walk>akuma_5hp>akuma_214hp>akuma_sa3',
    array['punish_counter', 'midscreen'], 'optimal',
    5320, 0.0, 3, 0, 0,
    false, '無敵技ガード後の立ち強Kパニカン始動。微歩き立ち強Pから強金剛灼火2段目キャンセルSA3でDゲージ消費ゼロのリーサル火力。',
    'year4', 44, '2026-11-13T16:40:00Z', '2026-11-13T16:40:00Z'
  ),
  (
    '10000000-0000-4000-8000-000000000004',
    null, '運営シード', 'akuma', 'modern',
    '["akuma_m_2m","sys_dr","akuma_m_auto_m","akuma_m_auto_h","akuma_m_6sp"]'::jsonb,
    'akuma:modern:akuma_m_2m>sys_dr>akuma_m_auto_m>akuma_m_auto_h>akuma_m_6sp',
    array['midscreen'], 'beginner',
    2410, 3.0, 0, 0, 0,
    true, 'モダン豪鬼の安定ラッシュコンボ。複雑なコマンド不要で屈中からしっかりダメージを取れる。',
    'year4', 22, '2026-11-15T10:10:00Z', '2026-11-15T10:10:00Z'
  ),

  -- ジュリ (juri)
  (
    '20000000-0000-4000-8000-000000000001',
    null, '運営シード', 'juri', 'classic',
    '["juri_2mk","sys_dr","juri_2mp","juri_5mp","juri_2mp","juri_214lk"]'::jsonb,
    'juri:classic:juri_2mk>sys_dr>juri_2mp>juri_5mp>juri_2mp>juri_214lk',
    array['midscreen'], 'standard',
    2280, 3.0, 0, 0, 1,
    true, 'ジュリの基本となる屈中Kラッシュ始動。風破刃締めでストックを1つ溜めつつ、前ステから起き攻めに行ける。',
    'year4', 42, '2026-11-10T10:00:00Z', '2026-11-10T10:00:00Z'
  ),
  (
    '20000000-0000-4000-8000-000000000002',
    null, '運営シード', 'juri', 'classic',
    '["juri_5mp","juri_2mp","juri_236mk","juri_236hk","juri_623hp"]'::jsonb,
    'juri:classic:juri_5mp>juri_2mp>juri_236mk>juri_236hk>juri_623hp',
    array['corner'], 'optimal',
    3340, 0.0, 0, 2, 0,
    true, '風破ストック2本消費の画面端ノーゲージ高火力ルート。暗剣殺→五黄殺→強天穿輪でダウンを奪い柔道へ移行可能。',
    'year4', 31, '2026-11-11T12:00:00Z', '2026-11-11T12:00:00Z'
  ),
  (
    '20000000-0000-4000-8000-000000000003',
    null, '運営シード', 'juri', 'classic',
    '["juri_5hp","juri_236mk","juri_236hk","juri_214mk","juri_sa3"]'::jsonb,
    'juri:classic:juri_5hp>juri_236mk>juri_236hk>juri_214mk>juri_sa3',
    array['corner', 'punish_counter'], 'optimal',
    5410, 0.0, 3, 3, 0,
    false, '風破ストック最大（3本）時の画面端パニカン・リーサルコンボ。Dゲージを使わずに暗剣殺→五黄殺→中疾空閃→SA3で大ダメージを奪える。',
    'year4', 36, '2026-11-15T15:00:00Z', '2026-11-15T15:00:00Z'
  ),
  (
    '20000000-0000-4000-8000-000000000004',
    null, '運営シード', 'juri', 'classic',
    '["sys_di","juri_5hp","juri_236hk","juri_623hp"]'::jsonb,
    'juri:classic:sys_di>juri_5hp>juri_236hk>juri_623hp',
    array['di_hit', 'di_wall_splat', 'corner'], 'beginner',
    2920, 1.0, 0, 1, 0,
    true, '画面端のDIヒット・壁ドン共通で安定する簡単レシピ。風破ストックが無い場合は236大Kを214弱K（風破刃）に代用可能。',
    'year4', 27, '2026-11-12T09:30:00Z', '2026-11-12T09:30:00Z'
  ),
  (
    '20000000-0000-4000-8000-000000000005',
    null, '運営シード', 'juri', 'classic',
    '["juri_5mp","juri_2mp","juri_sa2","sys_raw_dr","juri_5lp","juri_5mp","juri_2mk","juri_5hp","sys_jc","sys_f_jump","juri_jmp","juri_jmk","juri_jhk","juri_214lk"]'::jsonb,
    'juri:classic:juri_5mp>juri_2mp>juri_sa2>sys_raw_dr>juri_5lp>juri_5mp>juri_2mk>juri_5hp>sys_jc>sys_f_jump>juri_jmp>juri_jmk>juri_jhk>juri_214lk',
    array['midscreen', 'juri_feng_shui'], 'standard',
    3480, 1.0, 2, 0, 1,
    true, '風水エンジン発動からの中央運び＆起き攻め重視の長尺チェーンコンボ。立ち強P後のジャンプキャンセルは最速で前ジャンプし、J中P→J中K→J強Kをテンポよく繋ぐ。',
    'year4', 58, '2026-11-14T18:00:00Z', '2026-11-14T18:00:00Z'
  ),
  (
    '20000000-0000-4000-8000-000000000006',
    null, '運営シード', 'juri', 'classic',
    '["juri_5hp","juri_sa2","juri_5lk","juri_5mp","juri_5hp","juri_6hp","sys_jc","juri_jmp","juri_jmk","juri_jhp","juri_214mk","sys_delay","juri_623hp"]'::jsonb,
    'juri:classic:juri_5hp>juri_sa2>juri_5lk>juri_5mp>juri_5hp>juri_6hp>sys_jc>juri_jmp>juri_jmk>juri_jhp>juri_214mk>sys_delay>juri_623hp',
    array['corner', 'punish_counter', 'juri_feng_shui'], 'optimal',
    4210, 0.0, 2, 0, 0,
    true, '画面端パニカン立ち強Pからの風水エンジン高火力チェーン。6大P（狂背掌）を挟んで浮かせ、空中チェーン後に着地ディレイ強天穿輪で締める。ゲージ温存しつつ大ダメージを狙える。',
    'year4', 49, '2026-11-15T20:15:00Z', '2026-11-15T20:15:00Z'
  ),
  (
    '20000000-0000-4000-8000-000000000007',
    null, '運営シード', 'juri', 'modern',
    '["juri_m_2m","sys_dr","juri_m_auto_m","juri_m_auto_h","juri_m_4sp"]'::jsonb,
    'juri:modern:juri_m_2m>sys_dr>juri_m_auto_m>juri_m_auto_h>juri_m_4sp',
    array['midscreen'], 'beginner',
    2050, 3.0, 0, 0, 1,
    true, 'モダンジュリの基本ラッシュコンボ。屈中ヒット確認からラッシュし、アシスト中→アシスト強→後SP（風破刃）でストックを溜めつつ安全に起き攻めへ。',
    'year4', 19, '2026-11-16T08:00:00Z', '2026-11-16T08:00:00Z'
  ),

  -- イングリッド (ingrid)
  (
    '30000000-0000-4000-8000-000000000001',
    null, '運営シード', 'ingrid', 'classic',
    '["ingrid_2mk","sys_dr","ingrid_5mp","ingrid_5hp","ingrid_214mk"]'::jsonb,
    'ingrid:classic:ingrid_2mk>sys_dr>ingrid_5mp>ingrid_5hp>ingrid_214mk',
    array['midscreen'], 'standard',
    2390, 3.0, 0, 0, 1,
    true, 'イングリッドの中央基本ラッシュコンボ。サンアーチ締めで運びつつ前ステから起き攻めが可能。',
    'year4', 28, '2026-11-12T11:00:00Z', '2026-11-12T11:00:00Z'
  ),
  (
    '30000000-0000-4000-8000-000000000002',
    null, '運営シード', 'ingrid', 'classic',
    '["ingrid_5hp","ingrid_214odk","sys_f_jump","ingrid_jhk","ingrid_air_214k","ingrid_623hk"]'::jsonb,
    'ingrid:classic:ingrid_5hp>ingrid_214odk>sys_f_jump>ingrid_jhk>ingrid_air_214k>ingrid_623hk',
    array['corner', 'ingrid_sun_install'], 'optimal',
    3560, 2.0, 0, 1, 0,
    true, '画面端ODサンアーチで浮かせてから空中追撃→サンダイブ着地後に強サンライズで拾う高火力ルート。',
    'year4', 34, '2026-11-13T15:00:00Z', '2026-11-13T15:00:00Z'
  ),
  (
    '30000000-0000-4000-8000-000000000003',
    null, '運営シード', 'ingrid', 'classic',
    '["sys_di","ingrid_5hp","ingrid_623hk","ingrid_sa3"]'::jsonb,
    'ingrid:classic:sys_di>ingrid_5hp>ingrid_623hk>ingrid_sa3',
    array['di_hit', 'punish_counter'], 'optimal',
    4680, 1.0, 3, 0, 0,
    false, 'DIパニカン確定時のシンプルかつ高火力なリーサルルート。強サンライズの初段をSA3キャンセルする。',
    'year4', 25, '2026-11-14T13:10:00Z', '2026-11-14T13:10:00Z'
  ),
  (
    '30000000-0000-4000-8000-000000000004',
    null, '運営シード', 'ingrid', 'modern',
    '["ingrid_m_2m","sys_dr","ingrid_m_auto_m","ingrid_m_auto_h","ingrid_m_6sp"]'::jsonb,
    'ingrid:modern:ingrid_m_2m>sys_dr>ingrid_m_auto_m>ingrid_m_auto_h>ingrid_m_6sp',
    array['midscreen'], 'beginner',
    2180, 3.0, 0, 0, 0,
    true, 'モダンイングリッドの基本コンボ。アシスト強から前SP（サンライズ）で確実にダウンを奪える。',
    'year4', 16, '2026-11-16T09:00:00Z', '2026-11-16T09:00:00Z'
  ),

  -- C.ヴァイパー (c-viper)
  (
    '40000000-0000-4000-8000-000000000001',
    null, '運営シード', 'c-viper', 'classic',
    '["cviper_2mk","sys_dr","cviper_5mp","cviper_5hp","cviper_214mp"]'::jsonb,
    'c-viper:classic:cviper_2mk>sys_dr>cviper_5mp>cviper_5hp>cviper_214mp',
    array['midscreen'], 'standard',
    2450, 3.0, 0, 0, 0,
    true, 'C.ヴァイパーの中央安定ラッシュコンボ。フェイント不要で安定するため、まず最初に覚えたい基本ルート。',
    'year4', 33, '2026-11-12T17:00:00Z', '2026-11-12T17:00:00Z'
  ),
  (
    '40000000-0000-4000-8000-000000000002',
    null, '運営シード', 'c-viper', 'classic',
    '["cviper_5hp","cviper_fc","cviper_2hp","cviper_623hp","cviper_hjc","cviper_air_214mk","cviper_214hp"]'::jsonb,
    'c-viper:classic:cviper_5hp>cviper_fc>cviper_2hp>cviper_623hp>cviper_hjc>cviper_air_214mk>cviper_214hp',
    array['corner', 'c_viper_feint'], 'optimal',
    3890, 0.0, 0, 0, 0,
    true, '立ち強P→サンダーフェイントキャンセル→屈強P→強セイスモ→ハイジャンプキャンセル空中バーニング→強サンダーナックルのヴァイパーらしいノーゲージ高火力ルート。',
    'year4', 47, '2026-11-14T19:30:00Z', '2026-11-14T19:30:00Z'
  ),
  (
    '40000000-0000-4000-8000-000000000003',
    null, '運営シード', 'c-viper', 'classic',
    '["cviper_5hp","cviper_623odp","cviper_hjc","cviper_air_214mk","cviper_sa3"]'::jsonb,
    'c-viper:classic:cviper_5hp>cviper_623odp>cviper_hjc>cviper_air_214mk>cviper_sa3',
    array['punish_counter', 'midscreen'], 'optimal',
    5180, 2.0, 3, 0, 0,
    false, 'パニカン立ち強PからのODセイスモ→ハイジャンプ空中バーニング→SA3のリーサルルート。',
    'year4', 29, '2026-11-15T21:00:00Z', '2026-11-15T21:00:00Z'
  ),
  (
    '40000000-0000-4000-8000-000000000004',
    null, '運営シード', 'c-viper', 'modern',
    '["cviper_m_2m","sys_dr","cviper_m_auto_m","cviper_m_auto_h","cviper_m_sp"]'::jsonb,
    'c-viper:modern:cviper_m_2m>sys_dr>cviper_m_auto_m>cviper_m_auto_h>cviper_m_sp',
    array['midscreen'], 'beginner',
    2190, 3.0, 0, 0, 0,
    true, 'モダンC.ヴァイパー向けの簡単ラッシュコンボ。屈中ヒットからアシスト強→SP（サンダーナックル）まで繋いでダウンを奪う。',
    'year4', 18, '2026-11-16T11:20:00Z', '2026-11-16T11:20:00Z'
  )
on conflict (id) do nothing;
