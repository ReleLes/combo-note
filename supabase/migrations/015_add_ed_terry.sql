-- =============================================================================
-- Migration: 015_add_ed_terry.sql
-- 目的: 15人目「エド（ed）」・16人目「テリー（terry）」のキャラクターマスタおよび
--       全技マスタ（エド全127技＋テリー全113技＝計240技・
--       公式フレームデータ＆コマンドリスト準拠・CA除外）を
--       既存の Supabase 本番 DB へ安全・冪等に UPSERT する
-- 前提: 001_add_throw_category.sql を先に適用済みであること
-- =============================================================================

-- 1. キャラクターマスタへエド・テリーを追加・更新
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
  ('ed', 'ed', 'エド', 'Ed', 15, true, null, null, null),
  ('terry', 'terry', 'テリー', 'Terry', 16, true, null, null, null)
on conflict (id) do update set
  slug = excluded.slug,
  name_ja = excluded.name_ja,
  name_en = excluded.name_en,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  stock_label = excluded.stock_label,
  stock_short_label = excluded.stock_short_label,
  stock_max_count = excluded.stock_max_count;

-- 2. エド・テリー全技マスタ（計240技）を UPSERT
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
  -- エド（ed）全127技（クラシック59種＋モダン68種）
  -- =========================================================================

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('ed_5lp', 'ed', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（ジャブ）', 10, 4, 4, array['C']),
  ('ed_5lk', 'ed', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（フリッカー）', 11, 6, 3, '{}'::text[]),
  ('ed_5mp', 'ed', 'classic', 'normal', '5中P', '中P', '立ち中P（ボディブロー）', 12, 7, 6, array['C']),
  ('ed_5mk', 'ed', 'classic', 'normal', '5中K', '中K', '立ち中K（ヒットマンフリッカー）', 13, 10, 0, array['C']),
  ('ed_5hp', 'ed', 'classic', 'normal', '5強P', '強P', '立ち強P（ソリッドナックル）', 14, 10, 5, array['C']),
  ('ed_5hk', 'ed', 'classic', 'normal', '5強K', '強K', '立ち強K（ライジングフリッカー）', 15, 10, 8, array['C']),
  ('ed_2lp', 'ed', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（アンダーブロー）', 20, 4, 3, '{}'::text[]),
  ('ed_2lk', 'ed', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（ジャブフリッカー）', 21, 5, 2, array['C']),
  ('ed_2mp', 'ed', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（アンダーフック）', 22, 8, 2, array['C']),
  ('ed_2mk', 'ed', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（オーバーフリッカー）', 23, 9, 8, array['C']),
  ('ed_2hp', 'ed', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（ローフックパンチ）', 24, 10, null, '{}'::text[]),
  ('ed_2hk', 'ed', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（ローフリッカー）', 25, 12, -1, array['C']),
  ('ed_jlp', 'ed', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（エアナックル）', 30, 5, null, '{}'::text[]),
  ('ed_jlk', 'ed', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（アンダーフリッカー）', 31, 8, null, '{}'::text[]),
  ('ed_jmp', 'ed', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（バーティカルナックル）', 32, 8, null, '{}'::text[]),
  ('ed_jmk', 'ed', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（ミドルフリッカー）', 33, 10, null, '{}'::text[]),
  ('ed_jhp', 'ed', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（ソリッドダイブ）', 34, 9, null, '{}'::text[]),
  ('ed_jhk', 'ed', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（ハイフリッカー）', 35, 8, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 9種: 40〜48）
  ('ed_knuckle_lv1', 'ed', 'classic', 'unique', '5強Pホールド(Lv1)', '強Pホールド(Lv1)', 'サイコナックル（Lv1）', 40, 39, null, '{}'::text[]),
  ('ed_knuckle_lv2', 'ed', 'classic', 'unique', '5強Pホールド(Lv2)', '強Pホールド(Lv2)', 'サイコナックル（Lv2）', 41, 69, null, '{}'::text[]),
  ('ed_6hp', 'ed', 'classic', 'unique', '6強P', '→+強P', 'コブラパンチ', 42, 17, 1, '{}'::text[]),
  ('ed_tc_lk2', 'ed', 'classic', 'unique', '5弱K>弱K', '弱K>弱K', 'フリッカーコンビネーション（2段目）', 43, 7, 3, '{}'::text[]),
  ('ed_tc_lk3', 'ed', 'classic', 'unique', '5弱K>弱K>弱K', '弱K>弱K>弱K', 'フリッカーコンビネーション（3段目）', 44, 7, 1, '{}'::text[]),
  ('ed_tc_mp_hp', 'ed', 'classic', 'unique', '5中P>強P', '中P>強P', 'ボディブローコンビネーション', 45, 13, null, array['C']),
  ('ed_tc_mk2', 'ed', 'classic', 'unique', '5中K>中K', '中K>中K', 'ヒットマンコンビネーション（2段目）', 46, 7, 0, '{}'::text[]),
  ('ed_tc_mk3', 'ed', 'classic', 'unique', '5中K>中K>強P', '中K>中K>強P', 'ヒットマンコンビネーション（3段目）', 47, 11, null, '{}'::text[]),
  ('ed_tc_2hk_hp', 'ed', 'classic', 'unique', '2強K>強P', '↓+強K>強P', 'ロースマッシュコンビネーション', 48, 10, null, array['SA']),

  -- 3. 必殺技（クラシック 27種: 50〜76）
  ('ed_236p', 'ed', 'classic', 'special', '236P', '↓↘→+P', 'サイコスパーク', 50, 14, 3, array['SA3']),
  ('ed_236odp', 'ed', 'classic', 'special', 'OD236PP', '↓↘→+PP', 'OD サイコスパーク', 51, 14, null, array['SA2']),
  ('ed_shoot_l', 'ed', 'classic', 'special', '6弱P(スパーク後)', 'スパーク中→+弱P', '弱 サイコシュート', 52, 12, 3, array['SA3']),
  ('ed_shoot_m', 'ed', 'classic', 'special', '6中P(スパーク後)', 'スパーク中→+中P', '中 サイコシュート', 53, 12, 3, array['SA3']),
  ('ed_shoot_h', 'ed', 'classic', 'special', '6強P(スパーク後)', 'スパーク中→+強P', '強 サイコシュート', 54, 12, 3, array['SA3']),
  ('ed_shoot_od_l', 'ed', 'classic', 'special', 'OD6弱P(スパーク後)', 'ODスパーク中→+弱P', 'OD 弱 サイコシュート', 55, 12, null, array['SA2']),
  ('ed_shoot_od_m', 'ed', 'classic', 'special', 'OD6中P(スパーク後)', 'ODスパーク中→+中P', 'OD 中 サイコシュート', 56, 12, null, array['SA2']),
  ('ed_shoot_od_h', 'ed', 'classic', 'special', 'OD6強P(スパーク後)', 'ODスパーク中→+強P', 'OD 強 サイコシュート', 57, 12, null, array['SA2']),
  ('ed_623lp', 'ed', 'classic', 'special', '623弱P', '→↓↘+弱P', '弱 サイコアッパー', 58, 10, null, array['SA3']),
  ('ed_623mp', 'ed', 'classic', 'special', '623中P', '→↓↘+中P', '中 サイコアッパー', 59, 14, null, array['SA3']),
  ('ed_623hp', 'ed', 'classic', 'special', '623強P', '→↓↘+強P', '強 サイコアッパー', 60, 16, null, array['SA3']),
  ('ed_623odp', 'ed', 'classic', 'special', 'OD623PP', '→↓↘+PP', 'OD サイコアッパー', 61, 13, null, '{}'::text[]),
  ('ed_214lp', 'ed', 'classic', 'special', '214弱P', '↓↙←+弱P', '弱 サイコブリッツ', 62, 11, 3, array['SA3']),
  ('ed_214mp', 'ed', 'classic', 'special', '214中P', '↓↙←+中P', '中 サイコブリッツ', 63, 13, null, array['SA3']),
  ('ed_214hp', 'ed', 'classic', 'special', '214強P', '↓↙←+強P', '強 サイコブリッツ', 64, 15, null, array['SA3']),
  ('ed_214odp', 'ed', 'classic', 'special', 'OD214PP', '↓↙←+PP', 'OD サイコブリッツ', 65, 13, null, array['SA2']),
  ('ed_236lk', 'ed', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 サイコフリッカー', 66, 16, 1, array['SA3']),
  ('ed_236lk_hold', 'ed', 'classic', 'special', '236弱K(ホールド)', '↓↘→+弱Kホールド', '弱 サイコフリッカー（ホールド）', 67, 31, null, '{}'::text[]),
  ('ed_236mk', 'ed', 'classic', 'special', '236中K', '↓↘→+中K', '中 サイコフリッカー', 68, 20, 3, array['SA3']),
  ('ed_236mk_hold', 'ed', 'classic', 'special', '236中K(ホールド)', '↓↘→+中Kホールド', '中 サイコフリッカー（ホールド）', 69, 35, null, '{}'::text[]),
  ('ed_236hk', 'ed', 'classic', 'special', '236強K', '↓↘→+強K', '強 サイコフリッカー', 70, 17, null, array['SA3']),
  ('ed_236hk_hold', 'ed', 'classic', 'special', '236強K(ホールド)', '↓↘→+強Kホールド', '強 サイコフリッカー（ホールド）', 71, 35, null, '{}'::text[]),
  ('ed_236odk', 'ed', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD サイコフリッカー', 72, 25, null, array['SA2']),
  ('ed_killstep_f', 'ed', 'classic', 'special', 'キルステップ前', 'KK', 'キルステップ（前方）', 73, null, null, '{}'::text[]),
  ('ed_killswitch_break', 'ed', 'classic', 'special', 'キルスイッチ・ブレイク', '前ステップ前半→+P', 'キルスイッチ・ブレイク', 74, 11, null, array['SA3']),
  ('ed_killswitch_chase', 'ed', 'classic', 'special', 'キルスイッチ・チェイス', '前ステップ後半→+P', 'キルスイッチ・チェイス', 75, 11, null, array['SA3']),
  ('ed_killstep_b', 'ed', 'classic', 'special', 'キルステップ後', '←+KK', 'キルステップ（後方）', 76, null, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 3種: 85〜87、CA除外）
  ('ed_sa1', 'ed', 'classic', 'super', 'SA1', '↓↘→↓↘→+K', 'SA1 サイコストーム', 85, 13, null, '{}'::text[]),
  ('ed_sa2', 'ed', 'classic', 'super', 'SA2', '↓↙←↓↙←+P', 'SA2 サイコキャノン', 86, 8, null, '{}'::text[]),
  ('ed_sa3', 'ed', 'classic', 'super', 'SA3', '↓↘→↓↘→+P', 'SA3 サイコチェンバー', 87, 10, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 2種: 95〜96）
  ('ed_throw_f', 'ed', 'classic', 'throw', '前投げ', '弱P+弱K', 'フェイスバスター（前投げ）', 95, 5, null, '{}'::text[]),
  ('ed_throw_b', 'ed', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'リブクラッシャー（後ろ投げ）', 96, 5, null, '{}'::text[]),

  -- 6. モダン通常技（10種: 110〜119）
  ('ed_m_5l', 'ed', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱K）', 110, 6, 3, '{}'::text[]),
  ('ed_m_5m', 'ed', 'modern', 'normal', '5中', '中', '立ち中（立ち中K）', 111, 10, 0, array['C']),
  ('ed_m_5h', 'ed', 'modern', 'normal', '5強', '強', '立ち強（立ち強K）', 112, 10, 8, array['C']),
  ('ed_m_2l', 'ed', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱P）', 113, 4, 3, '{}'::text[]),
  ('ed_m_2m', 'ed', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中P）', 114, 8, 2, array['C']),
  ('ed_m_2h', 'ed', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強K）', 115, 12, -1, array['C']),
  ('ed_m_3h', 'ed', 'modern', 'normal', '3強', '↘+強', '右下強（ローフックパンチ）', 116, 10, null, '{}'::text[]),
  ('ed_m_jl', 'ed', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 117, 5, null, '{}'::text[]),
  ('ed_m_jm', 'ed', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中K）', 118, 10, null, '{}'::text[]),
  ('ed_m_jh', 'ed', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 119, 8, null, '{}'::text[]),

  -- 7. モダン特殊技・アシスト（19種: 125〜143）
  ('ed_m_auto_l', 'ed', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・立ち弱P）', 125, 4, 4, array['C']),
  ('ed_m_auto_m', 'ed', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・立ち中P）', 126, 7, 6, array['C']),
  ('ed_m_auto_h', 'ed', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち強P）', 127, 10, 5, array['C']),
  ('ed_m_j_auto_l', 'ed', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 128, 8, null, '{}'::text[]),
  ('ed_m_j_auto_m', 'ed', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中P）', 129, 8, null, '{}'::text[]),
  ('ed_m_j_auto_h', 'ed', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 130, 9, null, '{}'::text[]),
  ('ed_m_auto_l_combo', 'ed', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 131, 4, null, '{}'::text[]),
  ('ed_m_auto_2l_combo', 'ed', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 132, 4, null, '{}'::text[]),
  ('ed_m_auto_m_combo', 'ed', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 133, 7, null, '{}'::text[]),
  ('ed_m_auto_h_combo', 'ed', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 134, 10, null, '{}'::text[]),
  ('ed_m_knuckle_lv1', 'ed', 'modern', 'unique', 'A強ホールド(Lv1)', 'アシスト強ホールド(Lv1)', 'サイコナックル（Lv1）', 135, 39, null, '{}'::text[]),
  ('ed_m_knuckle_lv2', 'ed', 'modern', 'unique', 'A強ホールド(Lv2)', 'アシスト強ホールド(Lv2)', 'サイコナックル（Lv2）', 136, 69, null, '{}'::text[]),
  ('ed_m_6h', 'ed', 'modern', 'unique', '6強', '→+強', 'コブラパンチ', 137, 17, 1, '{}'::text[]),
  ('ed_m_tc_l2', 'ed', 'modern', 'unique', '5弱>弱', '弱>弱', 'フリッカーコンビネーション（2段目）', 138, 7, 3, '{}'::text[]),
  ('ed_m_tc_l3', 'ed', 'modern', 'unique', '5弱>弱>弱', '弱>弱>弱', 'フリッカーコンビネーション（3段目）', 139, 7, 1, '{}'::text[]),
  ('ed_m_tc_am_m', 'ed', 'modern', 'unique', 'A中>中', 'アシスト中>中', 'ボディブローコンビネーション', 140, 13, null, array['C']),
  ('ed_m_tc_m2', 'ed', 'modern', 'unique', '5中>中', '中>中', 'ヒットマンコンビネーション（2段目）', 141, 7, 0, '{}'::text[]),
  ('ed_m_tc_m3', 'ed', 'modern', 'unique', '5中>中>中', '中>中>中', 'ヒットマンコンビネーション（3段目）', 142, 11, null, '{}'::text[]),
  ('ed_m_tc_2h_h', 'ed', 'modern', 'unique', '2強>強', '↓+強>強', 'ロースマッシュコンビネーション', 143, 10, null, array['SA']),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（9種: 150〜158）
  ('ed_m_sp', 'ed', 'modern', 'special', 'N必', 'SP', 'サイコスパーク（N必）', 150, 14, 3, array['SA3']),
  ('ed_m_od_sp', 'ed', 'modern', 'special', 'A+N必', 'A+SP', 'OD サイコスパーク（A+N必）', 151, 14, null, array['SA2']),
  ('ed_m_6sp', 'ed', 'modern', 'special', '前必', '→+SP', '弱 サイコアッパー（前必）', 152, 10, null, array['SA3']),
  ('ed_m_od_6sp', 'ed', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD サイコアッパー（A+前必）', 153, 13, null, '{}'::text[]),
  ('ed_m_4sp', 'ed', 'modern', 'special', '後必', '←+SP', '強 サイコブリッツ（後必）', 154, 15, null, array['SA3']),
  ('ed_m_od_4sp', 'ed', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD サイコブリッツ（A+後必）', 155, 13, null, array['SA2']),
  ('ed_m_2sp', 'ed', 'modern', 'special', '下必', '↓+SP', '弱 サイコフリッカー（下必）', 156, 16, 1, array['SA3']),
  ('ed_m_2sp_hold', 'ed', 'modern', 'special', '下必(ホールド)', '↓+SPホールド', '弱 サイコフリッカー（ホールド・下必）', 157, 31, null, '{}'::text[]),
  ('ed_m_od_2sp', 'ed', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD サイコフリッカー（A+下必）', 158, 25, null, array['SA2']),

  -- 9. モダン必殺技：コマンド入力版＆派生技（25種: 165〜189）
  ('ed_m_shoot_l', 'ed', 'modern', 'special', '6弱(スパーク後)', 'スパーク中→+弱', '弱 サイコシュート', 165, 12, 3, array['SA3']),
  ('ed_m_shoot_m', 'ed', 'modern', 'special', '6中(スパーク後)', 'スパーク中→+中/SP', '中 サイコシュート', 166, 12, 3, array['SA3']),
  ('ed_m_shoot_h', 'ed', 'modern', 'special', '6強(スパーク後)', 'スパーク中→+強', '強 サイコシュート', 167, 12, 3, array['SA3']),
  ('ed_m_shoot_od_l', 'ed', 'modern', 'special', 'OD6弱(スパーク後)', 'ODスパーク中→+弱', 'OD 弱 サイコシュート', 168, 12, null, array['SA2']),
  ('ed_m_shoot_od_m', 'ed', 'modern', 'special', 'OD6中(スパーク後)', 'ODスパーク中→+中/SP', 'OD 中 サイコシュート', 169, 12, null, array['SA2']),
  ('ed_m_shoot_od_h', 'ed', 'modern', 'special', 'OD6強(スパーク後)', 'ODスパーク中→+強', 'OD 強 サイコシュート', 170, 12, null, array['SA2']),
  ('ed_m_623l', 'ed', 'modern', 'special', '623弱', '→↓↘+弱', '弱 サイコアッパー', 171, 10, null, array['SA3']),
  ('ed_m_623m', 'ed', 'modern', 'special', '623中', '→↓↘+中', '中 サイコアッパー', 172, 14, null, array['SA3']),
  ('ed_m_623h', 'ed', 'modern', 'special', '623強', '→↓↘+強', '強 サイコアッパー', 173, 16, null, array['SA3']),
  ('ed_m_623od', 'ed', 'modern', 'special', 'OD623', '→↓↘+攻撃×2', 'OD サイコアッパー', 174, 13, null, '{}'::text[]),
  ('ed_m_214l', 'ed', 'modern', 'special', '214弱', '↓↙←+弱', '弱 サイコブリッツ', 175, 11, 3, array['SA3']),
  ('ed_m_214m', 'ed', 'modern', 'special', '214中', '↓↙←+中', '中 サイコブリッツ', 176, 13, null, array['SA3']),
  ('ed_m_214h', 'ed', 'modern', 'special', '214強', '↓↙←+強', '強 サイコブリッツ', 177, 15, null, array['SA3']),
  ('ed_m_214od', 'ed', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD サイコブリッツ', 178, 13, null, array['SA2']),
  ('ed_m_236l', 'ed', 'modern', 'special', '236弱', '↓↘→+弱', '弱 サイコフリッカー', 179, 16, 1, array['SA3']),
  ('ed_m_236l_hold', 'ed', 'modern', 'special', '236弱(ホールド)', '↓↘→+弱ホールド', '弱 サイコフリッカー（ホールド）', 180, 31, null, '{}'::text[]),
  ('ed_m_236m', 'ed', 'modern', 'special', '236中', '↓↘→+中', '中 サイコフリッカー', 181, 20, 3, array['SA3']),
  ('ed_m_236m_hold', 'ed', 'modern', 'special', '236中(ホールド)', '↓↘→+中ホールド', '中 サイコフリッカー（ホールド）', 182, 35, null, '{}'::text[]),
  ('ed_m_236h', 'ed', 'modern', 'special', '236強', '↓↘→+強', '強 サイコフリッカー', 183, 17, null, array['SA3']),
  ('ed_m_236h_hold', 'ed', 'modern', 'special', '236強(ホールド)', '↓↘→+強ホールド', '強 サイコフリッカー（ホールド）', 184, 35, null, '{}'::text[]),
  ('ed_m_236od', 'ed', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD サイコフリッカー', 185, 25, null, array['SA2']),
  ('ed_m_killstep_f', 'ed', 'modern', 'special', 'キルステップ前', '→+攻撃×2', 'キルステップ（前方）', 186, null, null, '{}'::text[]),
  ('ed_m_killswitch_break', 'ed', 'modern', 'special', 'キルスイッチ・ブレイク', '前ステップ前半→+攻撃', 'キルスイッチ・ブレイク', 187, 11, null, array['SA3']),
  ('ed_m_killswitch_chase', 'ed', 'modern', 'special', 'キルスイッチ・チェイス', '前ステップ後半→+攻撃', 'キルスイッチ・チェイス', 188, 11, null, array['SA3']),
  ('ed_m_killstep_b', 'ed', 'modern', 'special', 'キルステップ後', '←+攻撃×2', 'キルステップ（後方）', 189, null, null, '{}'::text[]),

  -- 10. モダンスーパーアーツ（3種: 195〜197、CA除外）
  ('ed_m_sa1', 'ed', 'modern', 'super', 'SA1', 'SP+強', 'SA1 サイコストーム', 195, 13, null, '{}'::text[]),
  ('ed_m_sa2', 'ed', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 サイコキャノン', 196, 8, null, '{}'::text[]),
  ('ed_m_sa3', 'ed', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 サイコチェンバー', 197, 10, null, '{}'::text[]),

  -- 11. モダン通常投げ（2種: 205〜206）
  ('ed_m_throw_f', 'ed', 'modern', 'throw', '前投げ', '弱+中', 'フェイスバスター（前投げ）', 205, 5, null, '{}'::text[]),
  ('ed_m_throw_b', 'ed', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'リブクラッシャー（後ろ投げ）', 206, 5, null, '{}'::text[]),

  -- =========================================================================
  -- テリー（terry）全113技（クラシック54種＋モダン59種）
  -- =========================================================================

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('terry_5lp', 'terry', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（ジャブ）', 10, 4, 4, array['C']),
  ('terry_5lk', 'terry', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（ローキック）', 11, 5, 2, array['C']),
  ('terry_5mp', 'terry', 'classic', 'normal', '5中P', '中P', '立ち中P（ストレート）', 12, 7, 2, array['C']),
  ('terry_5mk', 'terry', 'classic', 'normal', '5中K', '中K', '立ち中K（ミドルキック）', 13, 9, 5, '{}'::text[]),
  ('terry_5hp', 'terry', 'classic', 'normal', '5強P', '強P', '立ち強P（ボディ）', 14, 9, 2, array['C']),
  ('terry_5hk', 'terry', 'classic', 'normal', '5強K', '強K', '立ち強K（回し蹴り）', 15, 12, 1, '{}'::text[]),
  ('terry_2lp', 'terry', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（しゃがみジャブ）', 20, 4, 4, array['C']),
  ('terry_2lk', 'terry', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（足払い蹴り）', 21, 5, 3, '{}'::text[]),
  ('terry_2mp', 'terry', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（しゃがみストレート）', 22, 6, 5, array['C']),
  ('terry_2mk', 'terry', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（ヒールキック）', 23, 8, -2, array['C']),
  ('terry_2hp', 'terry', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（ワイルドアッパー）', 24, 8, 1, array['C']),
  ('terry_2hk', 'terry', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（スライドキック）', 25, 10, null, '{}'::text[]),
  ('terry_jlp', 'terry', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（ジャンプ手刀）', 30, 4, null, '{}'::text[]),
  ('terry_jlk', 'terry', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（ジャンプ前蹴り）', 31, 5, null, '{}'::text[]),
  ('terry_jmp', 'terry', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（ジャンプバックナックル）', 32, 7, null, '{}'::text[]),
  ('terry_jmk', 'terry', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（ナイト・ブレイカー）', 33, 7, null, '{}'::text[]),
  ('terry_jhp', 'terry', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（ジャンプ正拳突き）', 34, 9, null, '{}'::text[]),
  ('terry_jhk', 'terry', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（ジャンプテリーキック）', 35, 10, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 8種: 40〜47）
  ('terry_6hp', 'terry', 'classic', 'unique', '6強P', '→+強P', 'ハンマーパンチ', 40, 22, 2, '{}'::text[]),
  ('terry_tc_mp_hp', 'terry', 'classic', 'unique', '5中P>強P', '中P>強P', 'パワードライブ', 41, 15, null, '{}'::text[]),
  ('terry_tc_mp_hk', 'terry', 'classic', 'unique', '5中P>強K', '中P>強K', 'パワーシュート', 42, 18, null, '{}'::text[]),
  ('terry_tc_mp_hk_hk', 'terry', 'classic', 'unique', '5中P>強K>強K', '中P>強K>強K', 'パワーダンク', 43, 18, null, '{}'::text[]),
  ('terry_tc_sway', 'terry', 'classic', 'unique', '5中P>中K', '中P>中K', 'パッシングスウェー', 44, 13, -3, '{}'::text[]),
  ('terry_tc_sway_lariat', 'terry', 'classic', 'unique', '5中P>中K>中P', 'スウェー後中P', 'ジャンプラリアットパンチ', 45, 24, 4, '{}'::text[]),
  ('terry_tc_sway_knee', 'terry', 'classic', 'unique', '5中P>中K>中K', 'スウェー後中K', 'ジャンプニーアタック', 46, 24, 3, '{}'::text[]),
  ('terry_tc_2mk_2hk', 'terry', 'classic', 'unique', '2中K>2強K', '↓+中K>↓+強K', 'ファイヤーキック', 47, 13, null, array['C']),

  -- 3. 必殺技（クラシック 21種: 50〜70）
  ('terry_236lp', 'terry', 'classic', 'special', '236弱P', '↓↘→+弱P', '弱 パワーウェイブ', 50, 14, -3, array['SA3']),
  ('terry_236mp', 'terry', 'classic', 'special', '236中P', '↓↘→+中P', '中 パワーウェイブ', 51, 16, 0, array['SA3']),
  ('terry_236hp', 'terry', 'classic', 'special', '236強P', '↓↘→+強P', 'ラウンドウェイブ', 52, 29, 8, array['SA3']),
  ('terry_236odp', 'terry', 'classic', 'special', 'OD236PP', '↓↘→+PP', 'OD パワーウェイブ', 53, 15, 2, array['SA2']),
  ('terry_214lp', 'terry', 'classic', 'special', '214弱P', '↓↙←+弱P', 'クイックバーン', 54, 10, 3, array['SA3']),
  ('terry_214od_qb', 'terry', 'classic', 'special', 'OD214弱中P', '↓↙←+弱P中P', 'OD クイックバーン', 55, 10, null, array['SA2']),
  ('terry_214mp', 'terry', 'classic', 'special', '214中P', '↓↙←+中P', '中 バーンナックル', 56, 14, null, array['SA3']),
  ('terry_214hp', 'terry', 'classic', 'special', '214強P', '↓↙←+強P', '強 バーンナックル', 57, 23, null, array['SA3']),
  ('terry_214od_bn', 'terry', 'classic', 'special', 'OD214弱強or中強P', '↓↙←+弱P強P or 中P強P', 'OD バーンナックル', 58, 19, null, array['SA2']),
  ('terry_236lk', 'terry', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 パワーチャージ', 59, 14, 3, array['SA3']),
  ('terry_236mk', 'terry', 'classic', 'special', '236中K', '↓↘→+中K', '中 パワーチャージ', 60, 20, null, array['SA3']),
  ('terry_236hk', 'terry', 'classic', 'special', '236強K', '↓↘→+強K', '強 パワーチャージ', 61, 25, null, array['SA3']),
  ('terry_236odk', 'terry', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD パワーチャージ', 62, 19, null, array['SA2']),
  ('terry_214lk', 'terry', 'classic', 'special', '214弱K', '↓↙←+弱K', '弱 クラックシュート', 63, 16, 1, '{}'::text[]),
  ('terry_214mk', 'terry', 'classic', 'special', '214中K', '↓↙←+中K', '中 クラックシュート', 64, 17, 3, '{}'::text[]),
  ('terry_214hk', 'terry', 'classic', 'special', '214強K', '↓↙←+強K', '強 クラックシュート', 65, 23, null, '{}'::text[]),
  ('terry_214odk', 'terry', 'classic', 'special', 'OD214KK', '↓↙←+KK', 'OD クラックシュート', 66, 20, null, '{}'::text[]),
  ('terry_623lp', 'terry', 'classic', 'special', '623弱P', '→↓↘+弱P', '弱 ライジングタックル', 67, 5, null, array['SA3']),
  ('terry_623mp', 'terry', 'classic', 'special', '623中P', '→↓↘+中P', '中 ライジングタックル', 68, 6, null, array['SA3']),
  ('terry_623hp', 'terry', 'classic', 'special', '623強P', '→↓↘+強P', '強 ライジングタックル', 69, 7, null, array['SA3']),
  ('terry_623odp', 'terry', 'classic', 'special', 'OD623PP', '→↓↘+PP', 'OD ライジングタックル', 70, 6, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 5種: 85〜89、SA2派生2種含む・CA除外）
  ('terry_sa1', 'terry', 'classic', 'super', 'SA1', '↓↘→↓↘→+K', 'SA1 バスターウルフ', 85, 7, null, '{}'::text[]),
  ('terry_sa2', 'terry', 'classic', 'super', 'SA2', '↓↙←↓↙←+P', 'SA2 パワーゲイザー', 86, 13, null, '{}'::text[]),
  ('terry_sa2_twin', 'terry', 'classic', 'super', 'ツインゲイザー', 'SA2ヒット後PP', 'ツインゲイザー（SA2派生・D3）', 87, 22, null, '{}'::text[]),
  ('terry_sa2_triple', 'terry', 'classic', 'super', 'トリプルゲイザー', 'ツイン後PP', 'トリプルゲイザー（SA2派生・SA+1）', 88, 14, null, '{}'::text[]),
  ('terry_sa3', 'terry', 'classic', 'super', 'SA3', '↓↘→↓↘→+P', 'SA3 ライジングファング', 89, 8, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 2種: 95〜96）
  ('terry_throw_f', 'terry', 'classic', 'throw', '前投げ', '弱P+弱K', 'グラスピングアッパー（前投げ）', 95, 5, null, '{}'::text[]),
  ('terry_throw_b', 'terry', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'バスタースルー（後ろ投げ）', 96, 5, null, '{}'::text[]),

  -- 6. モダン通常技（10種: 110〜119）
  ('terry_m_5l', 'terry', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 4, 4, array['C']),
  ('terry_m_5m', 'terry', 'modern', 'normal', '5中', '中', '立ち中（立ち中P）', 111, 7, 2, array['C']),
  ('terry_m_5h', 'terry', 'modern', 'normal', '5強', '強', '立ち強（立ち強K）', 112, 12, 1, '{}'::text[]),
  ('terry_m_2l', 'terry', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱P）', 113, 4, 4, array['C']),
  ('terry_m_2m', 'terry', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 114, 8, -2, array['C']),
  ('terry_m_2h', 'terry', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 115, 8, 1, array['C']),
  ('terry_m_3h', 'terry', 'modern', 'normal', '3強', '↘+強', '右下強（スライドキック）', 116, 10, null, '{}'::text[]),
  ('terry_m_jl', 'terry', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱K）', 117, 5, null, '{}'::text[]),
  ('terry_m_jm', 'terry', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 118, 7, null, '{}'::text[]),
  ('terry_m_jh', 'terry', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 119, 10, null, '{}'::text[]),

  -- 7. モダン特殊技・アシスト（19種: 125〜143）
  ('terry_m_auto_l', 'terry', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・しゃがみ弱K）', 125, 5, 3, '{}'::text[]),
  ('terry_m_auto_m', 'terry', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・しゃがみ中P）', 126, 6, 5, array['C']),
  ('terry_m_auto_h', 'terry', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち強P）', 127, 9, 2, array['C']),
  ('terry_m_j_auto_l', 'terry', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱P）', 128, 4, null, '{}'::text[]),
  ('terry_m_j_auto_m', 'terry', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 129, 7, null, '{}'::text[]),
  ('terry_m_j_auto_h', 'terry', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 130, 9, null, '{}'::text[]),
  ('terry_m_auto_l_combo', 'terry', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 131, 5, null, '{}'::text[]),
  ('terry_m_auto_2l_combo', 'terry', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 132, 4, null, '{}'::text[]),
  ('terry_m_auto_m_combo', 'terry', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 133, 6, null, '{}'::text[]),
  ('terry_m_auto_h_combo', 'terry', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 134, 9, null, '{}'::text[]),
  ('terry_m_auto_h_combo2', 'terry', 'modern', 'unique', 'A強コンボ(2段目)', 'アシスト強連打(2段目)', 'アシストコンボ3（2段目）', 135, 9, null, '{}'::text[]),
  ('terry_m_6h', 'terry', 'modern', 'unique', '6強', '→+強', 'ハンマーパンチ', 136, 22, 2, '{}'::text[]),
  ('terry_m_tc_m_h', 'terry', 'modern', 'unique', '5中>強', '中>強', 'パワードライブ', 137, 15, null, '{}'::text[]),
  ('terry_m_tc_m_6h', 'terry', 'modern', 'unique', '5中>6強', '中>→+強', 'パワーシュート', 138, 18, null, '{}'::text[]),
  ('terry_m_tc_m_6h_h', 'terry', 'modern', 'unique', '5中>6強>強', '中>→+強>強', 'パワーダンク', 139, 18, null, '{}'::text[]),
  ('terry_m_tc_sway', 'terry', 'modern', 'unique', '5中>中', '中>中', 'パッシングスウェー', 140, 13, -3, '{}'::text[]),
  ('terry_m_tc_sway_lariat', 'terry', 'modern', 'unique', '5中>中>中', 'スウェー後中', 'ジャンプラリアットパンチ', 141, 24, 4, '{}'::text[]),
  ('terry_m_tc_sway_knee', 'terry', 'modern', 'unique', '5中>中>強', 'スウェー後強', 'ジャンプニーアタック', 142, 24, 3, '{}'::text[]),
  ('terry_m_tc_2m_2m', 'terry', 'modern', 'unique', '2中>2中', '↓+中>↓+中', 'ファイヤーキック', 143, 13, null, array['C']),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（10種: 150〜159）
  ('terry_m_sp', 'terry', 'modern', 'special', 'N必', 'SP', '中 パワーウェイブ（N必）', 150, 16, 0, array['SA3']),
  ('terry_m_od_sp', 'terry', 'modern', 'special', 'A+N必', 'A+SP', 'OD パワーウェイブ（A+N必）', 151, 15, 2, array['SA2']),
  ('terry_m_1sp', 'terry', 'modern', 'special', '左下必', '↙+SP', '弱 パワーチャージ（左下必）', 152, 14, 3, array['SA3']),
  ('terry_m_2sp', 'terry', 'modern', 'special', '下必', '↓+SP', '中 パワーチャージ（下必）', 153, 20, null, array['SA3']),
  ('terry_m_3sp', 'terry', 'modern', 'special', '右下必', '↘+SP', '強 パワーチャージ（右下必）', 154, 25, null, array['SA3']),
  ('terry_m_od_2sp', 'terry', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD パワーチャージ（A+下必）', 155, 19, null, array['SA2']),
  ('terry_m_4sp', 'terry', 'modern', 'special', '後必', '←+SP', '強 クラックシュート（後必）', 156, 23, null, '{}'::text[]),
  ('terry_m_od_4sp', 'terry', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD クラックシュート（A+後必）', 157, 20, null, '{}'::text[]),
  ('terry_m_6sp', 'terry', 'modern', 'special', '前必', '→+SP', '弱 ライジングタックル（前必）', 158, 5, null, array['SA3']),
  ('terry_m_od_6sp', 'terry', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD ライジングタックル（A+前必）', 159, 6, null, '{}'::text[]),

  -- 9. モダン必殺技：コマンド入力版（13種: 165〜177）
  ('terry_m_236l', 'terry', 'modern', 'special', '236弱', '↓↘→+弱', '弱 パワーウェイブ', 165, 14, -3, array['SA3']),
  ('terry_m_236m', 'terry', 'modern', 'special', '236中', '↓↘→+中', '中 パワーウェイブ', 166, 16, 0, array['SA3']),
  ('terry_m_236h', 'terry', 'modern', 'special', '236強', '↓↘→+強', 'ラウンドウェイブ', 167, 29, 8, array['SA3']),
  ('terry_m_236od', 'terry', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD パワーウェイブ', 168, 15, 2, array['SA2']),
  ('terry_m_214l', 'terry', 'modern', 'special', '214弱', '↓↙←+弱', 'クイックバーン', 169, 10, 3, array['SA3']),
  ('terry_m_214od_qb', 'terry', 'modern', 'special', 'OD214弱中', '↓↙←+弱+中', 'OD クイックバーン', 170, 10, null, array['SA2']),
  ('terry_m_214m', 'terry', 'modern', 'special', '214中', '↓↙←+中', '中 バーンナックル', 171, 14, null, array['SA3']),
  ('terry_m_214h', 'terry', 'modern', 'special', '214強', '↓↙←+強', '強 バーンナックル', 172, 23, null, array['SA3']),
  ('terry_m_214od_bn', 'terry', 'modern', 'special', 'OD214弱強or中強', '↓↙←+弱強 or 中強', 'OD バーンナックル', 173, 19, null, array['SA2']),
  ('terry_m_623l', 'terry', 'modern', 'special', '623弱', '→↓↘+弱', '弱 ライジングタックル', 174, 5, null, array['SA3']),
  ('terry_m_623m', 'terry', 'modern', 'special', '623中', '→↓↘+中', '中 ライジングタックル', 175, 6, null, array['SA3']),
  ('terry_m_623h', 'terry', 'modern', 'special', '623強', '→↓↘+強', '強 ライジングタックル', 176, 7, null, array['SA3']),
  ('terry_m_623od', 'terry', 'modern', 'special', 'OD623', '→↓↘+攻撃×2', 'OD ライジングタックル', 177, 6, null, '{}'::text[]),

  -- 10. モダンスーパーアーツ（5種: 185〜189、SA2派生2種含む・CA除外）
  ('terry_m_sa1', 'terry', 'modern', 'super', 'SA1', 'SP+強', 'SA1 バスターウルフ', 185, 7, null, '{}'::text[]),
  ('terry_m_sa2', 'terry', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 パワーゲイザー', 186, 13, null, '{}'::text[]),
  ('terry_m_sa2_twin', 'terry', 'modern', 'super', 'ツインゲイザー', 'SA2ヒット後攻撃×2', 'ツインゲイザー（SA2派生・D3）', 187, 22, null, '{}'::text[]),
  ('terry_m_sa2_triple', 'terry', 'modern', 'super', 'トリプルゲイザー', 'ツイン後攻撃×2', 'トリプルゲイザー（SA2派生・SA+1）', 188, 14, null, '{}'::text[]),
  ('terry_m_sa3', 'terry', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 ライジングファング', 189, 8, null, '{}'::text[]),

  -- 11. モダン通常投げ（2種: 195〜196）
  ('terry_m_throw_f', 'terry', 'modern', 'throw', '前投げ', '弱+中', 'グラスピングアッパー（前投げ）', 195, 5, null, '{}'::text[]),
  ('terry_m_throw_b', 'terry', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'バスタースルー（後ろ投げ）', 196, 5, null, '{}'::text[])
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
