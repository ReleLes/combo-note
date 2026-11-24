-- =============================================================================
-- Migration: 016_add_sagat_deejay.sql
-- 目的: 17人目「サガット（sagat）」・18人目「ディージェイ（deejay）」のキャラクターマスタおよび
--       全技マスタ（サガット全128技＋ディージェイ全141技＝計269技・
--       公式フレームデータ＆コマンドリスト準拠・CA除外）を
--       既存の Supabase 本番 DB へ安全・冪等に UPSERT する
-- 前提: 001_add_throw_category.sql を先に適用済みであること
-- =============================================================================

-- 1. キャラクターマスタへサガット・ディージェイを追加・更新
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
  ('sagat', 'sagat', 'サガット', 'Sagat', 17, true, null, null, null),
  ('deejay', 'deejay', 'ディージェイ', 'Dee Jay', 18, true, null, null, null)
on conflict (id) do update set
  slug = excluded.slug,
  name_ja = excluded.name_ja,
  name_en = excluded.name_en,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  stock_label = excluded.stock_label,
  stock_short_label = excluded.stock_short_label,
  stock_max_count = excluded.stock_max_count;

-- 2. サガット・ディージェイ全技マスタ（計269技）を UPSERT
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
  -- サガット（sagat）全128技（クラシック59種＋モダン69種）
  -- =========================================================================

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('sagat_5lp', 'sagat', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（タイガージャブ）', 10, 5, 4, array['C']),
  ('sagat_5lk', 'sagat', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（ローキック）', 11, 7, 0, array['C']),
  ('sagat_5mp', 'sagat', 'classic', 'normal', '5中P', '中P', '立ち中P（タイガーソーク）', 12, 6, 6, '{}'::text[]),
  ('sagat_5mk', 'sagat', 'classic', 'normal', '5中K', '中K', '立ち中K（ミドルキック）', 13, 11, 3, '{}'::text[]),
  ('sagat_5hp', 'sagat', 'classic', 'normal', '5強P', '強P', '立ち強P（タイガーストレート）', 14, 15, 0, '{}'::text[]),
  ('sagat_5hk', 'sagat', 'classic', 'normal', '5強K', '強K', '立ち強K（ハイキック）', 15, 10, 1, array['C']),
  ('sagat_2lp', 'sagat', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（ローナックル）', 20, 4, 5, array['C']),
  ('sagat_2lk', 'sagat', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（ローカーフ）', 21, 5, 1, '{}'::text[]),
  ('sagat_2mp', 'sagat', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（ミドルフック）', 22, 7, 4, array['C']),
  ('sagat_2mk', 'sagat', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（タイガースラストキック）', 23, 9, 5, '{}'::text[]),
  ('sagat_2hp', 'sagat', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（グランドストレート）', 24, 11, 1, array['C']),
  ('sagat_2hk', 'sagat', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（タイガーキック）', 25, 11, null, '{}'::text[]),
  ('sagat_jlp', 'sagat', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（ジャンピングジャブ）', 30, 4, null, '{}'::text[]),
  ('sagat_jlk', 'sagat', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（ジャンピングタイガードロップ）', 31, 5, null, '{}'::text[]),
  ('sagat_jmp', 'sagat', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（ジャンピングアッパー）', 32, 8, null, '{}'::text[]),
  ('sagat_jmk', 'sagat', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（ジャンピングタイガーキック）', 33, 8, null, '{}'::text[]),
  ('sagat_jhp', 'sagat', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（ジャンピングヘビーエルボー）', 34, 10, null, '{}'::text[]),
  ('sagat_jhk', 'sagat', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（ジャンピングタイガーハイキック）', 35, 10, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 8種: 40〜47）
  ('sagat_6mp', 'sagat', 'classic', 'unique', '6中P', '→+中P', 'タイガーヘビーエルボー', 40, 22, 3, '{}'::text[]),
  ('sagat_4hp', 'sagat', 'classic', 'unique', '4強P', '←+強P', 'タイガーモノリス', 41, 8, null, array['C']),
  ('sagat_6lk', 'sagat', 'classic', 'unique', '6弱K', '→+弱K', 'ステップローキック', 42, 18, 3, '{}'::text[]),
  ('sagat_6hk', 'sagat', 'classic', 'unique', '6強K', '→+強K', 'ステップハイキック', 43, 16, 7, '{}'::text[]),
  ('sagat_tc_mk_hk', 'sagat', 'classic', 'unique', '5中K>強K', '中K>強K', 'ステップミドルキック', 44, 16, null, '{}'::text[]),
  ('sagat_tc_hp_hk', 'sagat', 'classic', 'unique', '5強P>強K', '強P>強K', 'タイガースティング', 45, 16, null, '{}'::text[]),
  ('sagat_tc_2mp_hp', 'sagat', 'classic', 'unique', '2中P>強P', '↓+中P>強P', 'タイガースラッシュ', 46, 20, -2, array['C']),
  ('sagat_tc_2mp_hk', 'sagat', 'classic', 'unique', '2中P>強K', '↓+中P>強K', 'タイガーライズ', 47, 18, null, array['SA']),

  -- 3. 必殺技（クラシック 24種: 50〜73）
  ('sagat_236mp', 'sagat', 'classic', 'special', '236中P', '↓↘→+中P', '中 タイガーショット（上段）', 50, 16, 3, array['SA3']),
  ('sagat_236hp', 'sagat', 'classic', 'special', '236強P', '↓↘→+強P', '強 タイガーショット（上段）', 51, 12, -1, array['SA3']),
  ('sagat_236odp', 'sagat', 'classic', 'special', 'OD236中強P', '↓↘→+中P強P', 'OD タイガーショット（上段）', 52, 21, null, array['SA2']),
  ('sagat_236lp', 'sagat', 'classic', 'special', '236弱P', '↓↘→+弱P', 'グランドタイガーショット（下段）', 53, 14, -3, array['SA3']),
  ('sagat_236od_ground', 'sagat', 'classic', 'special', 'OD236弱P+P', '↓↘→+弱P+中or強P', 'OD グランドタイガーショット（下段）', 54, 12, null, array['SA2']),
  ('sagat_623lp', 'sagat', 'classic', 'special', '623弱P', '→↓↘+弱P', '弱 タイガーアッパーカット', 55, 5, null, array['SA3']),
  ('sagat_623mp', 'sagat', 'classic', 'special', '623中P', '→↓↘+中P', '中 タイガーアッパーカット', 56, 10, null, array['SA3']),
  ('sagat_623hp', 'sagat', 'classic', 'special', '623強P', '→↓↘+強P', '強 タイガーアッパーカット', 57, 18, null, array['SA3']),
  ('sagat_623hp_hold', 'sagat', 'classic', 'special', '623強P(ホールド)', '→↓↘+強Pホールド', '強 タイガーアッパーカット（ホールド）', 58, 35, null, array['SA3']),
  ('sagat_623odp', 'sagat', 'classic', 'special', 'OD623PP', '→↓↘+PP', 'OD タイガーアッパーカット', 59, 8, null, '{}'::text[]),
  ('sagat_236lk', 'sagat', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 タイガーニークラッシュ', 60, 14, null, '{}'::text[]),
  ('sagat_236mk', 'sagat', 'classic', 'special', '236中K', '↓↘→+中K', '中 タイガーニークラッシュ', 61, 18, null, '{}'::text[]),
  ('sagat_236hk', 'sagat', 'classic', 'special', '236強K', '↓↘→+強K', '強 タイガーニークラッシュ', 62, 22, null, array['SA3']),
  ('sagat_236odk', 'sagat', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD タイガーニークラッシュ', 63, 19, null, array['SA2']),
  ('sagat_214lk', 'sagat', 'classic', 'special', '214弱K', '↓↙←+弱K', '弱 タイガーネクサス', 64, 17, 2, array['SA3']),
  ('sagat_214mk', 'sagat', 'classic', 'special', '214中K', '↓↙←+中K', '中 タイガーネクサス', 65, 20, 2, array['SA3']),
  ('sagat_214hk', 'sagat', 'classic', 'special', '214強K', '↓↙←+強K', '強 タイガーネクサス', 66, 28, 4, array['SA3']),
  ('sagat_214odk', 'sagat', 'classic', 'special', 'OD214KK', '↓↙←+KK', 'OD タイガーネクサス', 67, 23, 4, array['SA2']),
  ('sagat_nexus_might', 'sagat', 'classic', 'special', 'タイガーマイト', 'ネクサス中→+弱K', 'タイガーマイト', 68, 15, 3, array['SA3']),
  ('sagat_nexus_od_might', 'sagat', 'classic', 'special', 'ODタイガーマイト', 'ODネクサス中→+弱K', 'OD タイガーマイト', 69, 15, 3, array['SA2']),
  ('sagat_nexus_greed', 'sagat', 'classic', 'special', 'タイガーグリード', 'ネクサス中→+中K', 'タイガーグリード', 70, 17, null, array['SA3']),
  ('sagat_nexus_od_greed', 'sagat', 'classic', 'special', 'ODタイガーグリード', 'ODネクサス中→+中K', 'OD タイガーグリード', 71, 17, null, array['SA2']),
  ('sagat_nexus_nova', 'sagat', 'classic', 'special', 'タイガーノヴァ', 'ネクサス中→+強K', 'タイガーノヴァ', 72, 21, null, array['SA3']),
  ('sagat_nexus_od_nova', 'sagat', 'classic', 'special', 'ODタイガーノヴァ', 'ODネクサス中→+強K', 'OD タイガーノヴァ', 73, 21, null, array['SA2']),

  -- 4. スーパーアーツ（クラシック 7種: 80〜86、SA2の4方向派生含む・CA除外）
  ('sagat_sa1', 'sagat', 'classic', 'super', 'SA1', '↓↘→↓↘→+P', 'SA1 タイガーキャノン', 80, 13, null, '{}'::text[]),
  ('sagat_sa2', 'sagat', 'classic', 'super', 'SA2', '↓↙←↓↙←+K', 'SA2 サベージタイガー', 81, 10, null, '{}'::text[]),
  ('sagat_sa2_raid', 'sagat', 'classic', 'super', 'サベージ・レイド', 'SA2中N', 'サベージタイガーレイド（SA2派生）', 82, null, null, '{}'::text[]),
  ('sagat_sa2_zenith', 'sagat', 'classic', 'super', 'サベージ・ゼニス', 'SA2中→', 'サベージタイガーゼニス（SA2派生）', 83, null, null, '{}'::text[]),
  ('sagat_sa2_pendulum', 'sagat', 'classic', 'super', 'サベージ・ペンデュラム', 'SA2中←', 'サベージタイガーペンデュラム（SA2派生）', 84, null, null, '{}'::text[]),
  ('sagat_sa2_stamp', 'sagat', 'classic', 'super', 'サベージ・スタンプ', 'SA2中↓', 'サベージタイガースタンプ（SA2派生）', 85, null, null, '{}'::text[]),
  ('sagat_sa3', 'sagat', 'classic', 'super', 'SA3', '↓↘→↓↘→+K', 'SA3 タイガーヴァンキッシュ', 86, 12, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 2種: 95〜96）
  ('sagat_throw_f', 'sagat', 'classic', 'throw', '前投げ', '弱P+弱K', 'タイガーハング（前投げ）', 95, 5, null, '{}'::text[]),
  ('sagat_throw_b', 'sagat', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'タイガーキャリー（後ろ投げ）', 96, 5, null, '{}'::text[]),

  -- 6. モダン通常技（10種: 110〜119）
  ('sagat_m_5l', 'sagat', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱K）', 110, 7, 0, array['C']),
  ('sagat_m_5m', 'sagat', 'modern', 'normal', '5中', '中', '立ち中（立ち中K）', 111, 11, 3, '{}'::text[]),
  ('sagat_m_5h', 'sagat', 'modern', 'normal', '5強', '強', '立ち強（立ち強P）', 112, 15, 0, '{}'::text[]),
  ('sagat_m_2l', 'sagat', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱P）', 113, 4, 5, array['C']),
  ('sagat_m_2m', 'sagat', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 114, 9, 5, '{}'::text[]),
  ('sagat_m_2h', 'sagat', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 115, 11, 1, array['C']),
  ('sagat_m_3h', 'sagat', 'modern', 'normal', '3強', '↘+強', '右下強（タイガーキック）', 116, 11, null, '{}'::text[]),
  ('sagat_m_jl', 'sagat', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 117, 4, null, '{}'::text[]),
  ('sagat_m_jm', 'sagat', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 118, 8, null, '{}'::text[]),
  ('sagat_m_jh', 'sagat', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 119, 10, null, '{}'::text[]),

  -- 7. モダン特殊技・アシスト（20種: 125〜144）
  ('sagat_m_auto_l', 'sagat', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・しゃがみ弱K）', 125, 5, 1, '{}'::text[]),
  ('sagat_m_auto_m', 'sagat', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・しゃがみ中P）', 126, 7, 4, array['C']),
  ('sagat_m_auto_h', 'sagat', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち強K）', 127, 10, 1, array['C']),
  ('sagat_m_j_auto_l', 'sagat', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 128, 5, null, '{}'::text[]),
  ('sagat_m_j_auto_m', 'sagat', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 129, 8, null, '{}'::text[]),
  ('sagat_m_j_auto_h', 'sagat', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 130, 10, null, '{}'::text[]),
  ('sagat_m_auto_l_combo', 'sagat', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 131, 5, null, '{}'::text[]),
  ('sagat_m_auto_2l_combo', 'sagat', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 132, 4, null, '{}'::text[]),
  ('sagat_m_auto_m_combo', 'sagat', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 133, 7, null, '{}'::text[]),
  ('sagat_m_auto_h_combo', 'sagat', 'modern', 'unique', 'A強コンボ(1段目)', 'アシスト強連打(1段目)', 'アシストコンボ3（1段目）', 134, 10, null, '{}'::text[]),
  ('sagat_m_auto_h_combo2', 'sagat', 'modern', 'unique', 'A強コンボ(2段目)', 'アシスト強連打(2段目)', 'アシストコンボ3（2段目）', 135, 10, null, '{}'::text[]),
  ('sagat_m_2l_5l', 'sagat', 'modern', 'unique', '2弱>弱', '↓+弱>弱', '連打キャンセル立ち弱P（タイガージャブ）', 136, 5, 4, array['C']),
  ('sagat_m_6m', 'sagat', 'modern', 'unique', '6中', '→+中', 'タイガーヘビーエルボー', 137, 22, 3, '{}'::text[]),
  ('sagat_m_4h', 'sagat', 'modern', 'unique', '4強', '←+強', 'タイガーモノリス', 138, 8, null, array['C']),
  ('sagat_m_6l', 'sagat', 'modern', 'unique', '6弱', '→+弱', 'ステップローキック', 139, 18, 3, '{}'::text[]),
  ('sagat_m_6h', 'sagat', 'modern', 'unique', '6強', '→+強', 'ステップハイキック', 140, 16, 7, '{}'::text[]),
  ('sagat_m_tc_m_m', 'sagat', 'modern', 'unique', '5中>中', '中>中', 'ステップミドルキック', 141, 16, null, '{}'::text[]),
  ('sagat_m_tc_h_h', 'sagat', 'modern', 'unique', '5強>強', '強>強', 'タイガースティング', 142, 16, null, '{}'::text[]),
  ('sagat_m_tc_am_h', 'sagat', 'modern', 'unique', 'A中>強', 'アシスト中>強', 'タイガースラッシュ', 143, 20, -2, array['C']),
  ('sagat_m_tc_am_2h', 'sagat', 'modern', 'unique', 'A中>2強', 'アシスト中>↓+強', 'タイガーライズ', 144, 18, null, array['SA']),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（11種: 150〜160）
  ('sagat_m_1sp', 'sagat', 'modern', 'special', '左下必', '↙+SP', 'グランドタイガーショット（下段・左下必）', 150, 14, -3, array['SA3']),
  ('sagat_m_od_1sp', 'sagat', 'modern', 'special', 'A+左下必', 'A+↙+SP', 'OD グランドタイガーショット（下段・A+左下必）', 151, 12, null, array['SA2']),
  ('sagat_m_2sp', 'sagat', 'modern', 'special', '下必', '↓+SP', '中 タイガーショット（上段・下必）', 152, 16, 3, array['SA3']),
  ('sagat_m_3sp', 'sagat', 'modern', 'special', '右下必', '↘+SP', '強 タイガーショット（上段・右下必）', 153, 12, -1, array['SA3']),
  ('sagat_m_od_2sp', 'sagat', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD タイガーショット（上段・A+下必）', 154, 21, null, array['SA2']),
  ('sagat_m_6sp', 'sagat', 'modern', 'special', '前必', '→+SP', '弱 タイガーアッパーカット（前必）', 155, 5, null, array['SA3']),
  ('sagat_m_od_6sp', 'sagat', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD タイガーアッパーカット（A+前必）', 156, 8, null, '{}'::text[]),
  ('sagat_m_sp', 'sagat', 'modern', 'special', 'N必', 'SP', '中 タイガーニークラッシュ（N必）', 157, 18, null, '{}'::text[]),
  ('sagat_m_od_sp', 'sagat', 'modern', 'special', 'A+N必', 'A+SP', 'OD タイガーニークラッシュ（A+N必）', 158, 19, null, array['SA2']),
  ('sagat_m_4sp', 'sagat', 'modern', 'special', '後必', '←+SP', '中 タイガーネクサス（後必）', 159, 20, 2, array['SA3']),
  ('sagat_m_od_4sp', 'sagat', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD タイガーネクサス（A+後必）', 160, 23, 4, array['SA2']),

  -- 9. モダン必殺技：コマンド入力版＆ネクサス派生（19種: 165〜183）
  ('sagat_m_623l', 'sagat', 'modern', 'special', '623弱', '→↓↘+弱', '弱 タイガーアッパーカット', 165, 5, null, array['SA3']),
  ('sagat_m_623m', 'sagat', 'modern', 'special', '623中', '→↓↘+中', '中 タイガーアッパーカット', 166, 10, null, array['SA3']),
  ('sagat_m_623h', 'sagat', 'modern', 'special', '623強', '→↓↘+強', '強 タイガーアッパーカット', 167, 18, null, array['SA3']),
  ('sagat_m_623h_hold', 'sagat', 'modern', 'special', '623強(ホールド)', '→↓↘+強ホールド', '強 タイガーアッパーカット（ホールド）', 168, 35, null, array['SA3']),
  ('sagat_m_623od', 'sagat', 'modern', 'special', 'OD623', '→↓↘+攻撃×2', 'OD タイガーアッパーカット', 169, 8, null, '{}'::text[]),
  ('sagat_m_236l', 'sagat', 'modern', 'special', '236弱', '↓↘→+弱', '弱 タイガーニークラッシュ', 170, 14, null, '{}'::text[]),
  ('sagat_m_236m', 'sagat', 'modern', 'special', '236中', '↓↘→+中', '中 タイガーニークラッシュ', 171, 18, null, '{}'::text[]),
  ('sagat_m_236h', 'sagat', 'modern', 'special', '236強', '↓↘→+強', '強 タイガーニークラッシュ', 172, 22, null, array['SA3']),
  ('sagat_m_236od', 'sagat', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD タイガーニークラッシュ', 173, 19, null, array['SA2']),
  ('sagat_m_214l', 'sagat', 'modern', 'special', '214弱', '↓↙←+弱', '弱 タイガーネクサス', 174, 17, 2, array['SA3']),
  ('sagat_m_214m', 'sagat', 'modern', 'special', '214中', '↓↙←+中', '中 タイガーネクサス', 175, 20, 2, array['SA3']),
  ('sagat_m_214h', 'sagat', 'modern', 'special', '214強', '↓↙←+強', '強 タイガーネクサス', 176, 28, 4, array['SA3']),
  ('sagat_m_214od', 'sagat', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD タイガーネクサス', 177, 23, 4, array['SA2']),
  ('sagat_m_nexus_might', 'sagat', 'modern', 'special', 'タイガーマイト', 'ネクサス中→+弱', 'タイガーマイト', 178, 15, 3, array['SA3']),
  ('sagat_m_nexus_od_might', 'sagat', 'modern', 'special', 'ODタイガーマイト', 'ODネクサス中→+弱', 'OD タイガーマイト', 179, 15, 3, array['SA2']),
  ('sagat_m_nexus_greed', 'sagat', 'modern', 'special', 'タイガーグリード', 'ネクサス中→+中', 'タイガーグリード', 180, 17, null, array['SA3']),
  ('sagat_m_nexus_od_greed', 'sagat', 'modern', 'special', 'ODタイガーグリード', 'ODネクサス中→+中', 'OD タイガーグリード', 181, 17, null, array['SA2']),
  ('sagat_m_nexus_nova', 'sagat', 'modern', 'special', 'タイガーノヴァ', 'ネクサス中→+強', 'タイガーノヴァ', 182, 21, null, array['SA3']),
  ('sagat_m_nexus_od_nova', 'sagat', 'modern', 'special', 'ODタイガーノヴァ', 'ODネクサス中→+強', 'OD タイガーノヴァ', 183, 21, null, array['SA2']),

  -- 10. モダンスーパーアーツ（7種: 190〜196、SA2の4方向派生含む・CA除外）
  ('sagat_m_sa1', 'sagat', 'modern', 'super', 'SA1', 'SP+強', 'SA1 タイガーキャノン', 190, 13, null, '{}'::text[]),
  ('sagat_m_sa2', 'sagat', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 サベージタイガー', 191, 10, null, '{}'::text[]),
  ('sagat_m_sa2_raid', 'sagat', 'modern', 'super', 'サベージ・レイド', 'SA2中N', 'サベージタイガーレイド（SA2派生）', 192, null, null, '{}'::text[]),
  ('sagat_m_sa2_zenith', 'sagat', 'modern', 'super', 'サベージ・ゼニス', 'SA2中→', 'サベージタイガーゼニス（SA2派生）', 193, null, null, '{}'::text[]),
  ('sagat_m_sa2_pendulum', 'sagat', 'modern', 'super', 'サベージ・ペンデュラム', 'SA2中←', 'サベージタイガーペンデュラム（SA2派生）', 194, null, null, '{}'::text[]),
  ('sagat_m_sa2_stamp', 'sagat', 'modern', 'super', 'サベージ・スタンプ', 'SA2中↓', 'サベージタイガースタンプ（SA2派生）', 195, null, null, '{}'::text[]),
  ('sagat_m_sa3', 'sagat', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 タイガーヴァンキッシュ', 196, 12, null, '{}'::text[]),

  -- 11. モダン通常投げ（2種: 205〜206）
  ('sagat_m_throw_f', 'sagat', 'modern', 'throw', '前投げ', '弱+中', 'タイガーハング（前投げ）', 205, 5, null, '{}'::text[]),
  ('sagat_m_throw_b', 'sagat', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'タイガーキャリー（後ろ投げ）', 206, 5, null, '{}'::text[]),

  -- =========================================================================
  -- ディージェイ（deejay）全141技（クラシック67種＋モダン74種）
  -- =========================================================================

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('deejay_5lp', 'deejay', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（ジャブ）', 10, 4, 4, array['C']),
  ('deejay_5lk', 'deejay', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（ローキック）', 11, 5, 2, array['C']),
  ('deejay_5mp', 'deejay', 'classic', 'normal', '5中P', '中P', '立ち中P（フロントフック）', 12, 7, 5, '{}'::text[]),
  ('deejay_5mk', 'deejay', 'classic', 'normal', '5中K', '中K', '立ち中K（ミドルキック）', 13, 9, 6, '{}'::text[]),
  ('deejay_5hp', 'deejay', 'classic', 'normal', '5強P', '強P', '立ち強P（ブラストアッパー）', 14, 9, 3, array['C']),
  ('deejay_5hk', 'deejay', 'classic', 'normal', '5強K', '強K', '立ち強K（マキシマムキック）', 15, 12, 1, '{}'::text[]),
  ('deejay_2lp', 'deejay', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（アンダージャブ）', 20, 5, 4, array['C']),
  ('deejay_2lk', 'deejay', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（アンダーウィップ）', 21, 5, 2, '{}'::text[]),
  ('deejay_2mp', 'deejay', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（レッグクラッシュエルボー）', 22, 6, 5, array['C']),
  ('deejay_2mk', 'deejay', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（グランドスクラッチ）', 23, 8, null, '{}'::text[]),
  ('deejay_2hp', 'deejay', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（バーストフック）', 24, 8, 6, '{}'::text[]),
  ('deejay_2hk', 'deejay', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（スライディングヒールアッパー）', 25, 14, null, '{}'::text[]),
  ('deejay_jlp', 'deejay', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（ファンクストレート）', 30, 4, null, '{}'::text[]),
  ('deejay_jlk', 'deejay', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（ファンクウィップ）', 31, 4, null, '{}'::text[]),
  ('deejay_jmp', 'deejay', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（ファンクアッパー）', 32, 6, null, '{}'::text[]),
  ('deejay_jmk', 'deejay', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（フライングムエタイキック）', 33, 8, null, '{}'::text[]),
  ('deejay_jhp', 'deejay', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（ファンクバウンド）', 34, 9, null, '{}'::text[]),
  ('deejay_jhk', 'deejay', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（フライングカリビアンソバット）', 35, 10, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 12種: 40〜51）
  ('deejay_j2lk', 'deejay', 'classic', 'unique', '前J2弱K', '前ジャンプ中↓+弱K', 'ニーショット', 40, 6, null, '{}'::text[]),
  ('deejay_6mk', 'deejay', 'classic', 'unique', '6中K', '→+中K', 'サンライズヒール', 41, 19, 5, array['SA']),
  ('deejay_4hk', 'deejay', 'classic', 'unique', '4強K', '←+強K', 'フェイスブレイカー', 42, 7, 1, array['C']),
  ('deejay_tc_3beat2', 'deejay', 'classic', 'unique', '5弱P>中K', '弱P>中K', '3ビートコンボ（2段目）', 43, 9, 2, '{}'::text[]),
  ('deejay_tc_3beat3', 'deejay', 'classic', 'unique', '5弱P>中K>中K', '弱P>中K>中K', '3ビートコンボ（3段目）', 44, 14, 3, '{}'::text[]),
  ('deejay_tc_djsp2', 'deejay', 'classic', 'unique', '5中P>強P', '中P>強P', 'ディージェイスペシャル（2段目）', 45, 11, -2, '{}'::text[]),
  ('deejay_tc_djsp3', 'deejay', 'classic', 'unique', '5中P>強P>強K', '中P>強P>強K', 'ディージェイスペシャル（3段目）', 46, 13, null, array['SA']),
  ('deejay_tc_funky2', 'deejay', 'classic', 'unique', '5中P>中P', '中P>中P', 'ファンキーダンス（2段目）', 47, 12, 2, '{}'::text[]),
  ('deejay_tc_funky3', 'deejay', 'classic', 'unique', '5中P>中P>強P', '中P>中P>強P', 'ファンキーダンス（3段目）', 48, 20, null, '{}'::text[]),
  ('deejay_tc_funky_fake', 'deejay', 'classic', 'unique', '5中P>中P>4強P', '中P>中P>←+強P', 'ファンキーダンス・フェイク', 49, null, null, '{}'::text[]),
  ('deejay_j_party', 'deejay', 'classic', 'unique', 'J中P>強P', '空中で中P>強P', 'フライングパーティー', 50, 8, null, '{}'::text[]),
  ('deejay_maracas', 'deejay', 'classic', 'unique', '22PP', '↓↓+PP', 'マラカスビート', 51, null, null, '{}'::text[]),

  -- 3. 必殺技（クラシック 28種: 55〜82）
  ('deejay_46lp', 'deejay', 'classic', 'special', '[4]6弱P', '←タメ→+弱P', '弱 エアスラッシャー（フェイント）', 55, null, null, '{}'::text[]),
  ('deejay_46mp', 'deejay', 'classic', 'special', '[4]6中P', '←タメ→+中P', '中 エアスラッシャー', 56, 17, 0, array['SA3']),
  ('deejay_46hp', 'deejay', 'classic', 'special', '[4]6強P', '←タメ→+強P', '強 エアスラッシャー', 57, 17, 3, array['SA3']),
  ('deejay_46odp', 'deejay', 'classic', 'special', 'OD[4]6PP', '←タメ→+PP', 'OD エアスラッシャー', 58, 10, 5, array['SA2']),
  ('deejay_28lk', 'deejay', 'classic', 'special', '[2]8弱K', '↓タメ↑+弱K', '弱 ジャックナイフマキシマム', 59, null, null, '{}'::text[]),
  ('deejay_28mk', 'deejay', 'classic', 'special', '[2]8中K', '↓タメ↑+中K', '中 ジャックナイフマキシマム', 60, 6, null, '{}'::text[]),
  ('deejay_28hk', 'deejay', 'classic', 'special', '[2]8強K', '↓タメ↑+強K', '強 ジャックナイフマキシマム', 61, 5, null, '{}'::text[]),
  ('deejay_28odk', 'deejay', 'classic', 'special', 'OD[2]8KK', '↓タメ↑+KK', 'OD ジャックナイフマキシマム', 62, 6, null, '{}'::text[]),
  ('deejay_236lk', 'deejay', 'classic', 'special', '236弱K', '↓↘→+弱K', 'フェイクロールステップ', 63, null, null, '{}'::text[]),
  ('deejay_236mk', 'deejay', 'classic', 'special', '236中K', '↓↘→+中K', 'クイックローリングソバット', 64, 12, null, array['SA3']),
  ('deejay_236hk', 'deejay', 'classic', 'special', '236強K', '↓↘→+強K', 'ダブルローリングソバット', 65, 15, 2, array['SA3']),
  ('deejay_236odk', 'deejay', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD ダブルローリングソバット', 66, 17, null, array['SA2']),
  ('deejay_214lp', 'deejay', 'classic', 'special', '214弱P', '↓↙←+弱P', '弱 マシンガンアッパー', 67, 15, null, array['SA3']),
  ('deejay_214mp', 'deejay', 'classic', 'special', '214中P', '↓↙←+中P', '中 マシンガンアッパー', 68, 22, null, array['SA3']),
  ('deejay_214hp', 'deejay', 'classic', 'special', '214強P', '↓↙←+強P', '強 マシンガンアッパー', 69, 28, null, array['SA3']),
  ('deejay_214odp', 'deejay', 'classic', 'special', 'OD214PP', '↓↙←+PP', 'OD マシンガンアッパー', 70, 26, null, array['SA2']),
  ('deejay_214k', 'deejay', 'classic', 'special', '214K', '↓↙←+K', 'ジョスクール', 71, null, null, '{}'::text[]),
  ('deejay_214odk', 'deejay', 'classic', 'special', 'OD214KK', '↓↙←+KK', 'OD ジョスクール', 72, 8, null, '{}'::text[]),
  ('deejay_jos_lk', 'deejay', 'classic', 'special', 'ファンキースライサー', 'ジョスクール中弱K', 'ファンキースライサー', 73, 12, 2, array['SA3']),
  ('deejay_jos_od_lk', 'deejay', 'classic', 'special', 'ODファンキースライサー', 'ODジョスクール中弱K', 'OD ファンキースライサー', 74, 9, 6, array['SA2']),
  ('deejay_jos_mk', 'deejay', 'classic', 'special', 'ワニングムーン', 'ジョスクール中中K', 'ワニングムーン', 75, 25, null, '{}'::text[]),
  ('deejay_jos_od_mk', 'deejay', 'classic', 'special', 'ODワニングムーン', 'ODジョスクール中中K', 'OD ワニングムーン', 76, 19, 7, '{}'::text[]),
  ('deejay_jos_hk', 'deejay', 'classic', 'special', 'マキシマムストライク', 'ジョスクール中強K', 'マキシマムストライク', 77, 15, null, array['SA3']),
  ('deejay_jos_od_hk', 'deejay', 'classic', 'special', 'ODマキシマムストライク', 'ODジョスクール中強K', 'OD マキシマムストライク', 78, 11, null, array['SA2']),
  ('deejay_jos_step', 'deejay', 'classic', 'special', 'ジャグリンステップ', 'ジョスクール中→+P', 'ジャグリンステップ', 79, null, null, '{}'::text[]),
  ('deejay_jos_od_step', 'deejay', 'classic', 'special', 'ODジャグリンステップ', 'ODジョスクール中→+P', 'OD ジャグリンステップ', 80, null, null, '{}'::text[]),
  ('deejay_jos_sway', 'deejay', 'classic', 'special', 'ジャグリンスウェイ', 'ステップ中←+P', 'ジャグリンスウェイ', 81, null, null, '{}'::text[]),
  ('deejay_jos_od_sway', 'deejay', 'classic', 'special', 'ODジャグリンスウェイ', 'ODステップ中←+P', 'OD ジャグリンスウェイ', 82, null, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 7種: 85〜91、SA2の3種＆フィニッシュ派生2種含む・CA除外）
  ('deejay_sa1', 'deejay', 'classic', 'super', 'SA1', '↓↘→↓↘→+K', 'SA1 グレイテストソバット', 85, 7, null, '{}'::text[]),
  ('deejay_sa2_light', 'deejay', 'classic', 'super', 'SA2(ライト)', '↓↘→↓↘→+弱P', 'SA2 サンライズフェスティバル・ライト', 86, 12, 6, '{}'::text[]),
  ('deejay_sa2_marvelous', 'deejay', 'classic', 'super', 'SA2(マーベラス)', '↓↘→↓↘→+中P', 'SA2 サンライズフェスティバル・マーベラス', 87, 12, 6, '{}'::text[]),
  ('deejay_sa2_maximum', 'deejay', 'classic', 'super', 'SA2(マキシマム)', '↓↘→↓↘→+強P', 'SA2 サンライズフェスティバル・マキシマム', 88, 12, 6, '{}'::text[]),
  ('deejay_sa2_climax', 'deejay', 'classic', 'super', 'クライマックスブロー', 'SA2完走後強P', 'クライマックスブロー（SA2派生）', 89, 11, null, '{}'::text[]),
  ('deejay_sa2_encore', 'deejay', 'classic', 'super', 'アンコールビート', 'SA2完走後強K', 'アンコールビート（SA2派生）', 90, 33, null, '{}'::text[]),
  ('deejay_sa3', 'deejay', 'classic', 'super', 'SA3', '↓↙←↓↙←+P', 'SA3 サタデーナイト', 91, 9, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 2種: 95〜96）
  ('deejay_throw_f', 'deejay', 'classic', 'throw', '前投げ', '弱P+弱K', 'スタンプ・ザ・ビート（前投げ）', 95, 5, null, '{}'::text[]),
  ('deejay_throw_b', 'deejay', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'フリップスルー（後ろ投げ）', 96, 5, null, '{}'::text[]),

  -- 6. モダン通常技（10種: 110〜119）
  ('deejay_m_5l', 'deejay', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 4, 4, array['C']),
  ('deejay_m_5m', 'deejay', 'modern', 'normal', '5中', '中', '立ち中（立ち中P）', 111, 7, 5, '{}'::text[]),
  ('deejay_m_5h', 'deejay', 'modern', 'normal', '5強', '強', '立ち強（立ち強K）', 112, 12, 1, '{}'::text[]),
  ('deejay_m_2l', 'deejay', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱K）', 113, 5, 2, '{}'::text[]),
  ('deejay_m_2m', 'deejay', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 114, 8, null, '{}'::text[]),
  ('deejay_m_2h', 'deejay', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 115, 8, 6, '{}'::text[]),
  ('deejay_m_3h', 'deejay', 'modern', 'normal', '3強', '↘+強', '右下強（スライディングヒールアッパー）', 116, 14, null, '{}'::text[]),
  ('deejay_m_jl', 'deejay', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱K）', 117, 4, null, '{}'::text[]),
  ('deejay_m_jm', 'deejay', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 118, 6, null, '{}'::text[]),
  ('deejay_m_jh', 'deejay', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 119, 10, null, '{}'::text[]),

  -- 7. モダン特殊技・アシスト（22種: 125〜146）
  ('deejay_m_auto_l', 'deejay', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・立ち弱K）', 125, 5, 2, array['C']),
  ('deejay_m_auto_m', 'deejay', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・しゃがみ中P）', 126, 6, 5, array['C']),
  ('deejay_m_j_auto_l', 'deejay', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱P）', 127, 4, null, '{}'::text[]),
  ('deejay_m_j_auto_m', 'deejay', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 128, 8, null, '{}'::text[]),
  ('deejay_m_j_auto_h', 'deejay', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 129, 9, null, '{}'::text[]),
  ('deejay_m_auto_l_combo', 'deejay', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 130, 5, null, '{}'::text[]),
  ('deejay_m_auto_2l_combo', 'deejay', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 131, 5, null, '{}'::text[]),
  ('deejay_m_auto_m_combo', 'deejay', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 132, 6, null, '{}'::text[]),
  ('deejay_m_auto_h_combo', 'deejay', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 133, 9, null, '{}'::text[]),
  ('deejay_m_2l_2l', 'deejay', 'modern', 'unique', '2弱>2弱', '↓+弱>↓+弱', '連打キャンセルしゃがみ弱P（アンダージャブ）', 134, 5, 4, array['C']),
  ('deejay_m_j2l', 'deejay', 'modern', 'unique', '前J2弱', '前ジャンプ中↓+弱', 'ニーショット', 135, 6, null, '{}'::text[]),
  ('deejay_m_6m', 'deejay', 'modern', 'unique', '6中', '→+中', 'サンライズヒール', 136, 19, 5, array['SA']),
  ('deejay_m_4h', 'deejay', 'modern', 'unique', '4強', '←+強', 'フェイスブレイカー', 137, 7, 1, array['C']),
  ('deejay_m_tc_3beat2', 'deejay', 'modern', 'unique', '5弱>中', '弱>中', '3ビートコンボ（2段目）', 138, 9, 2, '{}'::text[]),
  ('deejay_m_tc_3beat3', 'deejay', 'modern', 'unique', '5弱>中>中', '弱>中>中', '3ビートコンボ（3段目）', 139, 14, 3, '{}'::text[]),
  ('deejay_m_tc_djsp2', 'deejay', 'modern', 'unique', '5中>強', '中>強', 'ディージェイスペシャル（2段目）', 140, 11, -2, '{}'::text[]),
  ('deejay_m_tc_djsp3', 'deejay', 'modern', 'unique', '5中>強>強', '中>強>強', 'ディージェイスペシャル（3段目）', 141, 13, null, array['SA']),
  ('deejay_m_tc_funky2', 'deejay', 'modern', 'unique', '5中>中', '中>中', 'ファンキーダンス（2段目）', 142, 12, 2, '{}'::text[]),
  ('deejay_m_tc_funky3', 'deejay', 'modern', 'unique', '5中>中>中', '中>中>中', 'ファンキーダンス（3段目）', 143, 20, null, '{}'::text[]),
  ('deejay_m_tc_funky_fake', 'deejay', 'modern', 'unique', '5中>中>4中', '中>中>←+中', 'ファンキーダンス・フェイク', 144, null, null, '{}'::text[]),
  ('deejay_m_j_party', 'deejay', 'modern', 'unique', 'J中>中', '空中で中>中', 'フライングパーティー', 145, 8, null, '{}'::text[]),
  ('deejay_m_maracas', 'deejay', 'modern', 'unique', '22中強', '↓↓+中+強', 'マラカスビート', 146, null, null, '{}'::text[]),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（7種: 150〜156）
  ('deejay_m_4sp', 'deejay', 'modern', 'special', '[4]後必', '←タメ+SP', '中 エアスラッシャー（後必）', 150, 17, 0, array['SA3']),
  ('deejay_m_od_4sp', 'deejay', 'modern', 'special', 'A+[4]後必', '←タメ+A+SP', 'OD エアスラッシャー（A+後必）', 151, 10, 5, array['SA2']),
  ('deejay_m_2sp', 'deejay', 'modern', 'special', '[2]下必', '↓タメ+SP', '強 ジャックナイフマキシマム（下必）', 152, 5, null, '{}'::text[]),
  ('deejay_m_od_2sp', 'deejay', 'modern', 'special', 'A+[2]下必', '↓タメ+A+SP', 'OD ジャックナイフマキシマム（A+下必）', 153, 6, null, '{}'::text[]),
  ('deejay_m_6sp', 'deejay', 'modern', 'special', '前必', '→+SP', 'クイックローリングソバット（前必）', 154, 12, null, array['SA3']),
  ('deejay_m_sp', 'deejay', 'modern', 'special', 'N必', 'SP', 'ジョスクール（N必）', 155, null, null, '{}'::text[]),
  ('deejay_m_od_sp', 'deejay', 'modern', 'special', 'A+N必', 'A+SP', 'OD ジョスクール（A+N必）', 156, 8, null, '{}'::text[]),

  -- 9. モダン必殺技：コマンド入力版＆ジョスクール派生（26種: 160〜185）
  ('deejay_m_46l', 'deejay', 'modern', 'special', '[4]6弱', '←タメ→+弱', '弱 エアスラッシャー（フェイント）', 160, null, null, '{}'::text[]),
  ('deejay_m_46m', 'deejay', 'modern', 'special', '[4]6中', '←タメ→+中', '中 エアスラッシャー', 161, 17, 0, array['SA3']),
  ('deejay_m_46h', 'deejay', 'modern', 'special', '[4]6強', '←タメ→+強', '強 エアスラッシャー', 162, 17, 3, array['SA3']),
  ('deejay_m_46od', 'deejay', 'modern', 'special', 'OD[4]6', '←タメ→+攻撃×2', 'OD エアスラッシャー', 163, 10, 5, array['SA2']),
  ('deejay_m_28l', 'deejay', 'modern', 'special', '[2]8弱', '↓タメ↑+弱', '弱 ジャックナイフマキシマム', 164, null, null, '{}'::text[]),
  ('deejay_m_28m', 'deejay', 'modern', 'special', '[2]8中', '↓タメ↑+中', '中 ジャックナイフマキシマム', 165, 6, null, '{}'::text[]),
  ('deejay_m_28h', 'deejay', 'modern', 'special', '[2]8強', '↓タメ↑+強', '強 ジャックナイフマキシマム', 166, 5, null, '{}'::text[]),
  ('deejay_m_28od', 'deejay', 'modern', 'special', 'OD[2]8', '↓タメ↑+攻撃×2', 'OD ジャックナイフマキシマム', 167, 6, null, '{}'::text[]),
  ('deejay_m_236l', 'deejay', 'modern', 'special', '236弱', '↓↘→+弱', 'フェイクロールステップ', 168, null, null, '{}'::text[]),
  ('deejay_m_236m', 'deejay', 'modern', 'special', '236中', '↓↘→+中', 'クイックローリングソバット', 169, 12, null, array['SA3']),
  ('deejay_m_236h', 'deejay', 'modern', 'special', '236強', '↓↘→+強', 'ダブルローリングソバット', 170, 15, 2, array['SA3']),
  ('deejay_m_236od', 'deejay', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD ダブルローリングソバット', 171, 17, null, array['SA2']),
  ('deejay_m_214l', 'deejay', 'modern', 'special', '214弱', '↓↙←+弱', '弱 マシンガンアッパー', 172, 15, null, array['SA3']),
  ('deejay_m_214m', 'deejay', 'modern', 'special', '214中', '↓↙←+中', '中 マシンガンアッパー', 173, 22, null, array['SA3']),
  ('deejay_m_214h', 'deejay', 'modern', 'special', '214強', '↓↙←+強', '強 マシンガンアッパー', 174, 28, null, array['SA3']),
  ('deejay_m_214od', 'deejay', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD マシンガンアッパー', 175, 26, null, array['SA2']),
  ('deejay_m_jos_l', 'deejay', 'modern', 'special', 'ファンキースライサー', 'ジョスクール中弱', 'ファンキースライサー', 176, 12, 2, array['SA3']),
  ('deejay_m_jos_od_l', 'deejay', 'modern', 'special', 'ODファンキースライサー', 'ODジョスクール中弱', 'OD ファンキースライサー', 177, 9, 6, array['SA2']),
  ('deejay_m_jos_m', 'deejay', 'modern', 'special', 'ワニングムーン', 'ジョスクール中中', 'ワニングムーン', 178, 25, null, '{}'::text[]),
  ('deejay_m_jos_od_m', 'deejay', 'modern', 'special', 'ODワニングムーン', 'ODジョスクール中中', 'OD ワニングムーン', 179, 19, 7, '{}'::text[]),
  ('deejay_m_jos_h', 'deejay', 'modern', 'special', 'マキシマムストライク', 'ジョスクール中強', 'マキシマムストライク', 180, 15, null, array['SA3']),
  ('deejay_m_jos_od_h', 'deejay', 'modern', 'special', 'ODマキシマムストライク', 'ODジョスクール中強', 'OD マキシマムストライク', 181, 11, null, array['SA2']),
  ('deejay_m_jos_step', 'deejay', 'modern', 'special', 'ジャグリンステップ', 'ジョスクール中→+SP', 'ジャグリンステップ', 182, null, null, '{}'::text[]),
  ('deejay_m_jos_od_step', 'deejay', 'modern', 'special', 'ODジャグリンステップ', 'ODジョスクール中→+SP', 'OD ジャグリンステップ', 183, null, null, '{}'::text[]),
  ('deejay_m_jos_sway', 'deejay', 'modern', 'special', 'ジャグリンスウェイ', 'ステップ中SP', 'ジャグリンスウェイ', 184, null, null, '{}'::text[]),
  ('deejay_m_jos_od_sway', 'deejay', 'modern', 'special', 'ODジャグリンスウェイ', 'ODステップ中SP', 'OD ジャグリンスウェイ', 185, null, null, '{}'::text[]),

  -- 10. モダンスーパーアーツ（7種: 190〜196、SA2の3種＆フィニッシュ派生2種含む・CA除外）
  ('deejay_m_sa1', 'deejay', 'modern', 'super', 'SA1', 'SP+強', 'SA1 グレイテストソバット', 190, 7, null, '{}'::text[]),
  ('deejay_m_sa2_light', 'deejay', 'modern', 'super', 'SA2(ライト)', '←+SP+強>SPホールド', 'SA2 サンライズフェスティバル・ライト', 191, 12, 6, '{}'::text[]),
  ('deejay_m_sa2_marvelous', 'deejay', 'modern', 'super', 'SA2(マーベラス)', '←+SP+強>←', 'SA2 サンライズフェスティバル・マーベラス', 192, 12, 6, '{}'::text[]),
  ('deejay_m_sa2_maximum', 'deejay', 'modern', 'super', 'SA2(マキシマム)', '←+SP+強>→', 'SA2 サンライズフェスティバル・マキシマム', 193, 12, 6, '{}'::text[]),
  ('deejay_m_sa2_climax', 'deejay', 'modern', 'super', 'クライマックスブロー', 'SA2完走後←+強', 'クライマックスブロー（SA2派生）', 194, 11, null, '{}'::text[]),
  ('deejay_m_sa2_encore', 'deejay', 'modern', 'super', 'アンコールビート', 'SA2完走後強', 'アンコールビート（SA2派生）', 195, 33, null, '{}'::text[]),
  ('deejay_m_sa3', 'deejay', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 サタデーナイト', 196, 9, null, '{}'::text[]),

  -- 11. モダン通常投げ（2種: 205〜206）
  ('deejay_m_throw_f', 'deejay', 'modern', 'throw', '前投げ', '弱+中', 'スタンプ・ザ・ビート（前投げ）', 205, 5, null, '{}'::text[]),
  ('deejay_m_throw_b', 'deejay', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'フリップスルー（後ろ投げ）', 206, 5, null, '{}'::text[])
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
