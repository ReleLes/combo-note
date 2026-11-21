-- =============================================================================
-- Migration: 002_upsert_juri_moves.sql
-- 目的: ジュリ（juri）の全技マスタ（クラシック53種＋モダン58種・全111技・公式フレームデータ準拠）を
--       既存の Supabase 本番 DB へ安全・冪等に UPSERT する
--       ※ モダンには P/K の概念がないため、モダン専用技はすべて弱/中/強・SP・攻撃表記で分離管理
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
  -- モダン通常技（9種: 110〜118）
  ('juri_m_5l', 'juri', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 4, 5, array['C']),
  ('juri_m_5m', 'juri', 'modern', 'normal', '5中', '中', '立ち中（立ち中K）', 111, 5, 3, array['C']),
  ('juri_m_5h', 'juri', 'modern', 'normal', '5強', '強', '立ち強（立ち強K）', 112, 17, 2, '{}'::text[]),
  ('juri_m_2l', 'juri', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱K）', 113, 5, 3, '{}'::text[]),
  ('juri_m_2m', 'juri', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 114, 8, 1, array['C']),
  ('juri_m_2h', 'juri', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 115, 8, 3, array['C']),
  ('juri_m_jl', 'juri', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱K）', 116, 4, null, '{}'::text[]),
  ('juri_m_jm', 'juri', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 117, 7, null, array['C']),
  ('juri_m_jh', 'juri', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 118, 10, null, '{}'::text[]),

  -- モダン特殊技：アシスト単発・コンボ＆方向入力特殊技（11種: 120〜130）
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

  -- モダン必殺技：ワンボタン＆OD版（10種: 135〜144）
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

  -- モダン必殺技：コマンド入力＆OD版（21種: 150〜170・弱/中/強表記）
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

  -- モダンスーパーアーツ（4種: 180〜183、CA除外）
  ('juri_m_sa1', 'juri', 'modern', 'super', 'SA1', 'SP+強', 'SA1 殺界風破斬', 180, 7, null, '{}'::text[]),
  ('juri_m_sa2', 'juri', 'modern', 'super', 'SA2(風水)', '←+SP+強', 'SA2 風水エンジン', 181, 7, null, '{}'::text[]),
  ('juri_m_sa2_dash', 'juri', 'modern', 'super', 'SA2(突進)', '←+SP+強 ホールド', 'SA2 風水エンジン（突進）', 182, 9, -4, array['C']),
  ('juri_m_sa3', 'juri', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 回旋断界落', 183, 10, null, '{}'::text[]),

  -- モダン通常投げ（3種: 190〜192）
  ('juri_m_throw_f', 'juri', 'modern', 'throw', '前投げ', '弱+中', '蜘穿脚（前投げ）', 190, 5, null, '{}'::text[]),
  ('juri_m_throw_b', 'juri', 'modern', 'throw', '後ろ投げ', '←+弱+中', '苛影脚（後ろ投げ）', 191, 5, null, '{}'::text[]),
  ('juri_m_throw_air', 'juri', 'modern', 'throw', '空投げ', '空中で弱+中', '斬架閃（空中投げ）', 192, 5, null, '{}'::text[])
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
