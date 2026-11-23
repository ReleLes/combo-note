-- =============================================================================
-- Migration: 006_cviper_full_moves.sql
-- 目的: C.ヴァイパー（c-viper）の全技マスタ（全128技：クラシック55種＋モダン68種＋共通5種・
--       公式フレームデータ＆コマンドリスト準拠・CA除外）を既存の Supabase 本番 DB へ安全・冪等に UPSERT する
--       ※ 既存の技ID（21種）はすべて維持しつつ、公式コマンド・フレーム情報へ更新
-- 前提: 001_add_throw_category.sql を先に適用済みであること
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

  -- 1. 通常技（クラシック 19種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜36）
  ('cviper_5lp', 'c-viper', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（スナップナックル）', 10, 4, 4, array['C']),
  ('cviper_5lk', 'c-viper', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（ヒールキック）', 11, 5, 3, array['C']),
  ('cviper_5mp', 'c-viper', 'classic', 'normal', '5中P', '中P', '立ち中P（ハンマーフック）', 12, 8, 6, array['C']),
  ('cviper_5mk', 'c-viper', 'classic', 'normal', '5中K', '中K', '立ち中K（フロントキック）', 13, 8, 5, '{}'::text[]),
  ('cviper_5hp', 'c-viper', 'classic', 'normal', '5強P', '強P', '立ち強P（トマホークチョップ）', 14, 12, 3, '{}'::text[]),
  ('cviper_5hk', 'c-viper', 'classic', 'normal', '5強K', '強K', '立ち強K（ヴァイパーブレード）', 15, 10, 4, '{}'::text[]),
  ('cviper_2lp', 'c-viper', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（ジャブ）', 20, 4, 5, array['C']),
  ('cviper_2lk', 'c-viper', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（クラウチングヒールキック）', 21, 5, 4, '{}'::text[]),
  ('cviper_2mp', 'c-viper', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（ヴァイパーブロー）', 22, 6, 5, array['C']),
  ('cviper_2mk', 'c-viper', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（グランドキック）', 23, 8, 5, '{}'::text[]),
  ('cviper_2hp', 'c-viper', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（ヴァイパースライサー）', 24, 9, 2, array['C']),
  ('cviper_2hk', 'c-viper', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（ヴァイパースイープ）', 25, 10, null, '{}'::text[]),
  ('cviper_jlp', 'c-viper', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（エアリアルエルボー）', 30, 5, null, '{}'::text[]),
  ('cviper_jlk', 'c-viper', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（エアリアルプレスキック）', 31, 5, null, '{}'::text[]),
  ('cviper_jmp', 'c-viper', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（エアリアルヴァイパーブロー）', 32, 8, null, array['C']),
  ('cviper_jmk', 'c-viper', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（エアリアルトーキック）', 33, 7, null, '{}'::text[]),
  ('cviper_jhp', 'c-viper', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（エアリアルハンマー）', 34, 11, null, '{}'::text[]),
  ('cviper_jhk', 'c-viper', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（エアリアルクラッシュニー）', 35, 8, null, array['C']),
  ('cviper_njhk', 'c-viper', 'classic', 'normal', '垂直J強K', '垂直J中強K', '垂直ジャンプ強K（エアリアルジャベリン）', 36, 10, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 2種 + 共通 2種: 40〜43）
  ('cviper_6mp', 'c-viper', 'classic', 'unique', '6中P', '→+中P', 'ヴァイパーエルボー', 40, 22, 2, '{}'::text[]),
  ('cviper_6hk', 'c-viper', 'classic', 'unique', '6強K', '→+強K', 'ダブルキック', 41, 11, 4, '{}'::text[]),
  ('cviper_hj_f', 'c-viper', 'both', 'unique', '前HJ', '↓↗', 'ハイジャンプ（前方）', 42, null, null, '{}'::text[]),
  ('cviper_hj_v', 'c-viper', 'both', 'unique', '垂直HJ', '↓↑', 'ハイジャンプ（垂直）', 43, null, null, '{}'::text[]),

  -- 3. 必殺技（クラシック 29種 + 共通 1種: 50〜79）
  ('cviper_214lp', 'c-viper', 'classic', 'special', '214弱P', '↓↙←+弱P', '弱 サンダースラップ', 50, 17, 2, array['SA3']),
  ('cviper_214mp', 'c-viper', 'classic', 'special', '214中P', '↓↙←+中P', '中 サンダースラップ', 51, 16, 1, array['SA3']),
  ('cviper_214hp', 'c-viper', 'classic', 'special', '214強P', '↓↙←+強P', '強 サンダースラップ', 52, 7, null, '{}'::text[]),
  ('cviper_214odp', 'c-viper', 'classic', 'special', 'OD214PP', '↓↙←+PP', 'OD サンダースラップ', 53, 18, null, array['SA2']),
  ('cviper_trace_l', 'c-viper', 'classic', 'special', '弱トレース', '弱サンダー中→+PP', '弱 トレースコンビネーション', 54, 15, null, array['SA3']),
  ('cviper_trace_m', 'c-viper', 'classic', 'special', '中トレース', '中サンダー中→+PP', '中 トレースコンビネーション', 55, 21, null, array['SA3']),
  ('cviper_trace_h', 'c-viper', 'classic', 'special', '強トレース', '強サンダー中→+PP', '強 トレースコンビネーション', 56, 17, null, '{}'::text[]),
  ('cviper_thunder_feint', 'c-viper', 'classic', 'special', 'サンダーF', 'サンダー攻撃前K', '[サンダースラップ]フェイント', 57, null, null, '{}'::text[]),
  ('cviper_236lk', 'c-viper', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 バーニングキック', 58, 23, null, '{}'::text[]),
  ('cviper_236mk', 'c-viper', 'classic', 'special', '236中K', '↓↘→+中K', '中 バーニングキック', 59, 25, null, '{}'::text[]),
  ('cviper_214hk', 'c-viper', 'classic', 'special', '236強K', '↓↘→+強K', '強 バーニングキック', 60, 27, null, '{}'::text[]),
  ('cviper_236odk', 'c-viper', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD バーニングキック', 61, 8, null, array['SA2']),
  ('cviper_chase', 'c-viper', 'classic', 'special', 'チェイス', 'バーニング中PP', 'チェイスナックル', 62, 12, null, '{}'::text[]),
  ('cviper_double_burn', 'c-viper', 'classic', 'special', 'ダブルバーン', 'バーニング中KK', 'ダブルバーン', 63, 21, null, '{}'::text[]),
  ('cviper_air_236lk', 'c-viper', 'classic', 'special', '空中236弱K', '空中↓↘→+弱K', '弱 空中バーニングキック', 64, 22, null, '{}'::text[]),
  ('cviper_air_214mk', 'c-viper', 'classic', 'special', '空中236中K', '空中↓↘→+中K', '中 空中バーニングキック', 65, 20, null, '{}'::text[]),
  ('cviper_air_236hk', 'c-viper', 'classic', 'special', '空中236強K', '空中↓↘→+強K', '強 空中バーニングキック', 66, 18, null, '{}'::text[]),
  ('cviper_air_236odk', 'c-viper', 'classic', 'special', 'OD空中236KK', '空中↓↘→+KK', 'OD 空中バーニングキック', 67, 18, null, '{}'::text[]),
  ('cviper_623lp', 'c-viper', 'classic', 'special', '623弱P', '→↓↘+弱P', '弱 セイスモハンマー', 68, 24, null, array['SA3']),
  ('cviper_623mp', 'c-viper', 'classic', 'special', '623中P', '→↓↘+中P', '中 セイスモハンマー', 69, 24, null, array['SA3']),
  ('cviper_623hp', 'c-viper', 'classic', 'special', '623強P', '→↓↘+強P', '強 セイスモハンマー', 70, 24, null, array['SA3']),
  ('cviper_623odp', 'c-viper', 'classic', 'special', 'OD623PP', '→↓↘+PP', 'OD セイスモハンマー', 71, 19, null, array['SA2']),
  ('cviper_seismo_feint', 'c-viper', 'classic', 'special', 'セイスモF', 'セイスモ攻撃前K', '[セイスモハンマー]フェイント', 72, null, null, '{}'::text[]),
  ('cviper_saving_lv1', 'c-viper', 'classic', 'special', '214K(Lv1)', '↓↙←+K', 'セービングフォース(Lv1)', 73, 23, null, '{}'::text[]),
  ('cviper_saving_lv2', 'c-viper', 'classic', 'special', '214K(Lv2)', '↓↙←+Kホールド', 'セービングフォース(Lv2)', 74, 30, null, '{}'::text[]),
  ('cviper_saving_lv3', 'c-viper', 'classic', 'special', '214K(Lv3)', '↓↙←+Kホールド', 'セービングフォース(Lv3)', 75, 69, null, '{}'::text[]),
  ('cviper_saving_od_lv1', 'c-viper', 'classic', 'special', 'OD214KK(Lv1)', '↓↙←+KK', 'OD セービングフォース(Lv1)', 76, 20, null, '{}'::text[]),
  ('cviper_saving_od_lv2', 'c-viper', 'classic', 'special', 'OD214KK(Lv2)', '↓↙←+KKホールド', 'OD セービングフォース(Lv2)', 77, 30, null, '{}'::text[]),
  ('cviper_saving_od_lv3', 'c-viper', 'classic', 'special', 'OD214KK(Lv3)', '↓↙←+KKホールド', 'OD セービングフォース(Lv3)', 78, 67, null, '{}'::text[]),
  ('cviper_saving_step', 'c-viper', 'both', 'special', 'セービング前ステ', 'セービング中→→', '[セービングフォース]前方ステップ', 79, null, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 3種: 85〜87、CA除外）
  ('cviper_sa1', 'c-viper', 'classic', 'super', 'SA1', '↓↘→↓↘→+K', 'SA1 バウンサーステップ', 85, 8, null, '{}'::text[]),
  ('cviper_sa2', 'c-viper', 'classic', 'super', 'SA2', '↓↙←↓↙←+P', 'SA2 ミッションオーバー', 86, 7, null, '{}'::text[]),
  ('cviper_sa3', 'c-viper', 'classic', 'super', 'SA3', '↓↙←↓↙←+K', 'SA3 アンラックリジェクター', 87, 10, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 2種: 90〜91）
  ('cviper_throw_f', 'c-viper', 'classic', 'throw', '前投げ', '弱P+弱K', 'オーバーインパルス（前投げ）', 90, 5, null, '{}'::text[]),
  ('cviper_throw_b', 'c-viper', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'サンダークレイドル（後ろ投げ）', 91, 5, null, '{}'::text[]),

  -- 6. C.ヴァイパー固有システム・補助パーツ（共通 2種: 95〜96）
  ('cviper_fc', 'c-viper', 'both', 'system', 'FC', 'フェイント', 'フェイントキャンセル', 95, null, null, '{}'::text[]),
  ('cviper_hjc', 'c-viper', 'both', 'system', 'hjc', 'ハイジャンプ', 'ハイジャンプキャンセル', 96, null, null, '{}'::text[]),

  -- 7. モダン通常技（11種: 110〜120）
  ('cviper_m_5l', 'c-viper', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 4, 4, array['C']),
  ('cviper_m_5m', 'c-viper', 'modern', 'normal', '5中', '中', '立ち中（立ち中K）', 111, 8, 5, '{}'::text[]),
  ('cviper_m_5h', 'c-viper', 'modern', 'normal', '5強', '強', '立ち強（立ち強P）', 112, 12, 3, '{}'::text[]),
  ('cviper_m_2l', 'c-viper', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱K）', 113, 5, 4, '{}'::text[]),
  ('cviper_m_2l_2', 'c-viper', 'modern', 'normal', '2弱>2弱', '↓+弱>↓+弱', 'しゃがみ弱連打（しゃがみ弱P）', 114, 4, 5, array['C']),
  ('cviper_m_2m', 'c-viper', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 115, 8, 5, '{}'::text[]),
  ('cviper_m_2h', 'c-viper', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 116, 9, 2, array['C']),
  ('cviper_m_3h', 'c-viper', 'modern', 'normal', '3強', '↘+強', '右下強（ヴァイパースイープ）', 117, 10, null, '{}'::text[]),
  ('cviper_m_jl', 'c-viper', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 118, 5, null, '{}'::text[]),
  ('cviper_m_jm', 'c-viper', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 119, 8, null, array['C']),
  ('cviper_m_jh', 'c-viper', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強P）', 120, 11, null, '{}'::text[]),

  -- 8. モダン特殊技・アシスト（13種: 125〜137）
  ('cviper_m_auto_l', 'c-viper', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・立ち弱K）', 125, 5, 3, array['C']),
  ('cviper_m_auto_m', 'c-viper', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・しゃがみ中P）', 126, 6, 5, array['C']),
  ('cviper_m_auto_h', 'c-viper', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発）', 127, null, null, '{}'::text[]),
  ('cviper_m_j_auto_l', 'c-viper', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 128, 5, null, '{}'::text[]),
  ('cviper_m_j_auto_m', 'c-viper', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 129, 7, null, '{}'::text[]),
  ('cviper_m_j_auto_h', 'c-viper', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強K）', 130, 8, null, array['C']),
  ('cviper_m_nj_auto_h', 'c-viper', 'modern', 'unique', '垂直JA強', '垂直J中アシスト強', '垂直ジャンプアシスト強（垂直J強K）', 131, 10, null, '{}'::text[]),
  ('cviper_m_auto_l_combo', 'c-viper', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 132, 5, null, '{}'::text[]),
  ('cviper_m_auto_2l_combo', 'c-viper', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 133, 4, null, '{}'::text[]),
  ('cviper_m_auto_m_combo', 'c-viper', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 134, 6, null, '{}'::text[]),
  ('cviper_m_auto_h_combo', 'c-viper', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 135, null, null, '{}'::text[]),
  ('cviper_m_6m', 'c-viper', 'modern', 'unique', '6中', '→+中', 'ヴァイパーエルボー', 136, 22, 2, '{}'::text[]),
  ('cviper_m_6h', 'c-viper', 'modern', 'unique', '6強', '→+強', 'ダブルキック', 137, 11, 4, '{}'::text[]),

  -- 9. モダン必殺技：ワンボタンSP＆OD版（16種: 140〜155）
  ('cviper_m_sp', 'c-viper', 'modern', 'special', 'N必(Lv1)', 'SP', 'セービングフォース(Lv1)（N必）', 140, 23, null, '{}'::text[]),
  ('cviper_m_sp_lv2', 'c-viper', 'modern', 'special', 'N必(Lv2)', 'SPホールド', 'セービングフォース(Lv2)（N必）', 141, 30, null, '{}'::text[]),
  ('cviper_m_sp_lv3', 'c-viper', 'modern', 'special', 'N必(Lv3)', 'SPホールド', 'セービングフォース(Lv3)（N必）', 142, 69, null, '{}'::text[]),
  ('cviper_m_od_sp', 'c-viper', 'modern', 'special', 'A+N必(Lv1)', 'A+SP', 'OD セービングフォース(Lv1)（A+N必）', 143, 20, null, '{}'::text[]),
  ('cviper_m_od_sp_lv2', 'c-viper', 'modern', 'special', 'A+N必(Lv2)', 'A+SPホールド', 'OD セービングフォース(Lv2)（A+N必）', 144, 30, null, '{}'::text[]),
  ('cviper_m_od_sp_lv3', 'c-viper', 'modern', 'special', 'A+N必(Lv3)', 'A+SPホールド', 'OD セービングフォース(Lv3)（A+N必）', 145, 67, null, '{}'::text[]),
  ('cviper_m_6sp', 'c-viper', 'modern', 'special', '前必', '→+SP', '強 サンダースラップ（前必）', 146, 7, null, '{}'::text[]),
  ('cviper_m_od_6sp', 'c-viper', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD サンダースラップ（A+前必）', 147, 18, null, array['SA2']),
  ('cviper_m_4sp', 'c-viper', 'modern', 'special', '後必', '←+SP', '中 バーニングキック（後必）', 148, 25, null, '{}'::text[]),
  ('cviper_m_od_4sp', 'c-viper', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD バーニングキック（A+後必）', 149, 8, null, array['SA2']),
  ('cviper_m_1sp', 'c-viper', 'modern', 'special', '左下必', '↙+SP', '弱 セイスモハンマー（左下必）', 150, 24, null, array['SA3']),
  ('cviper_m_2sp', 'c-viper', 'modern', 'special', '下必', '↓+SP', '中 セイスモハンマー（下必）', 151, 24, null, array['SA3']),
  ('cviper_m_3sp', 'c-viper', 'modern', 'special', '右下必', '↘+SP', '強 セイスモハンマー（右下必）', 152, 24, null, array['SA3']),
  ('cviper_m_od_2sp', 'c-viper', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD セイスモハンマー（A+下必）', 153, 19, null, array['SA2']),
  ('cviper_m_air_sp', 'c-viper', 'modern', 'special', '空必', '空中でSP', '中 空中バーニングキック（空必）', 154, 20, null, '{}'::text[]),
  ('cviper_m_od_air_sp', 'c-viper', 'modern', 'special', 'A+空必', '空中でA+SP', 'OD 空中バーニングキック（A+空必）', 155, 18, null, '{}'::text[]),

  -- 10. モダン必殺技：コマンド入力＆派生技（23種: 160〜182・弱/中/強/攻撃表記）
  ('cviper_m_214l', 'c-viper', 'modern', 'special', '214弱', '↓↙←+弱', '弱 サンダースラップ', 160, 17, 2, array['SA3']),
  ('cviper_m_214m', 'c-viper', 'modern', 'special', '214中', '↓↙←+中', '中 サンダースラップ', 161, 16, 1, array['SA3']),
  ('cviper_m_214h', 'c-viper', 'modern', 'special', '214強', '↓↙←+強', '強 サンダースラップ', 162, 7, null, '{}'::text[]),
  ('cviper_m_214od', 'c-viper', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD サンダースラップ', 163, 18, null, array['SA2']),
  ('cviper_m_trace_l', 'c-viper', 'modern', 'special', '弱トレース', '弱サンダー中→+攻撃×2', '弱 トレースコンビネーション', 164, 15, null, array['SA3']),
  ('cviper_m_trace_m', 'c-viper', 'modern', 'special', '中トレース', '中サンダー中→+攻撃×2', '中 トレースコンビネーション', 165, 21, null, array['SA3']),
  ('cviper_m_trace_h', 'c-viper', 'modern', 'special', '強トレース', '強サンダー中→+攻撃×2', '強 トレースコンビネーション', 166, 17, null, '{}'::text[]),
  ('cviper_m_thunder_feint', 'c-viper', 'modern', 'special', 'サンダーF', 'サンダー攻撃前+攻撃', '[サンダースラップ]フェイント', 167, null, null, '{}'::text[]),
  ('cviper_m_236l', 'c-viper', 'modern', 'special', '236弱', '↓↘→+弱', '弱 バーニングキック', 168, 23, null, '{}'::text[]),
  ('cviper_m_236m', 'c-viper', 'modern', 'special', '236中', '↓↘→+中', '中 バーニングキック', 169, 25, null, '{}'::text[]),
  ('cviper_m_236h', 'c-viper', 'modern', 'special', '236強', '↓↘→+強', '強 バーニングキック', 170, 27, null, '{}'::text[]),
  ('cviper_m_236od', 'c-viper', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD バーニングキック', 171, 8, null, array['SA2']),
  ('cviper_m_chase', 'c-viper', 'modern', 'special', 'チェイス', 'バーニング中弱+中', 'チェイスナックル', 172, 12, null, '{}'::text[]),
  ('cviper_m_double_burn', 'c-viper', 'modern', 'special', 'ダブルバーン', 'バーニング中中+強', 'ダブルバーン', 173, 21, null, '{}'::text[]),
  ('cviper_m_air_236l', 'c-viper', 'modern', 'special', '空中236弱', '空中↓↘→+弱', '弱 空中バーニングキック', 174, 22, null, '{}'::text[]),
  ('cviper_m_air_236m', 'c-viper', 'modern', 'special', '空中236中', '空中↓↘→+中', '中 空中バーニングキック', 175, 20, null, '{}'::text[]),
  ('cviper_m_air_236h', 'c-viper', 'modern', 'special', '空中236強', '空中↓↘→+強', '強 空中バーニングキック', 176, 18, null, '{}'::text[]),
  ('cviper_m_air_236od', 'c-viper', 'modern', 'special', 'OD空中236', '空中↓↘→+攻撃×2', 'OD 空中バーニングキック', 177, 18, null, '{}'::text[]),
  ('cviper_m_623l', 'c-viper', 'modern', 'special', '623弱', '→↓↘+弱', '弱 セイスモハンマー', 178, 24, null, array['SA3']),
  ('cviper_m_623m', 'c-viper', 'modern', 'special', '623中', '→↓↘+中', '中 セイスモハンマー', 179, 24, null, array['SA3']),
  ('cviper_m_623h', 'c-viper', 'modern', 'special', '623強', '→↓↘+強', '強 セイスモハンマー', 180, 24, null, array['SA3']),
  ('cviper_m_623od', 'c-viper', 'modern', 'special', 'OD623', '→↓↘+攻撃×2', 'OD セイスモハンマー', 181, 19, null, array['SA2']),
  ('cviper_m_seismo_feint', 'c-viper', 'modern', 'special', 'セイスモF', 'セイスモ攻撃前+攻撃', '[セイスモハンマー]フェイント', 182, null, null, '{}'::text[]),

  -- 11. モダンスーパーアーツ（3種: 190〜192、CA除外）
  ('cviper_m_sa1', 'c-viper', 'modern', 'super', 'SA1', 'SP+強', 'SA1 バウンサーステップ', 190, 8, null, '{}'::text[]),
  ('cviper_m_sa2', 'c-viper', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 ミッションオーバー', 191, 7, null, '{}'::text[]),
  ('cviper_m_sa3', 'c-viper', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 アンラックリジェクター', 192, 10, null, '{}'::text[]),

  -- 12. モダン通常投げ（2種: 195〜196）
  ('cviper_m_throw_f', 'c-viper', 'modern', 'throw', '前投げ', '弱+中', 'オーバーインパルス（前投げ）', 195, 5, null, '{}'::text[]),
  ('cviper_m_throw_b', 'c-viper', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'サンダークレイドル（後ろ投げ）', 196, 5, null, '{}'::text[])
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
