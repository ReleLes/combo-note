-- =============================================================================
-- Migration: 011_add_cammy_chunli.sql
-- 目的: 9人目「キャミィ（cammy）」・10人目「春麗（chun-li）」のキャラクターマスタおよび
--       全技マスタ（キャミィ全138技＋春麗全143技＝計281技・
--       公式フレームデータ＆コマンドリスト準拠・CA除外）を
--       既存の Supabase 本番 DB へ安全・冪等に UPSERT する
-- 前提: 001_add_throw_category.sql を先に適用済みであること
-- =============================================================================

-- 1. キャラクターマスタへキャミィ・春麗を追加・更新
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
  ('cammy', 'cammy', 'キャミィ', 'Cammy', 9, true, null, null, null),
  ('chun-li', 'chun-li', '春麗', 'Chun-Li', 10, true, null, null, null)
on conflict (id) do update set
  slug = excluded.slug,
  name_ja = excluded.name_ja,
  name_en = excluded.name_en,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  stock_label = excluded.stock_label,
  stock_short_label = excluded.stock_short_label,
  stock_max_count = excluded.stock_max_count;

-- 2. キャミィ・春麗全技マスタ（計281技）を UPSERT
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
  -- キャミィ（cammy）全138技（クラシック64種＋モダン74種）
  -- =========================================================================

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('cammy_5lp', 'cammy', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（フーリガンジャブ）', 10, 4, 5, array['C']),
  ('cammy_5lk', 'cammy', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（フーリガンローキック）', 11, 5, 2, array['C']),
  ('cammy_5mp', 'cammy', 'classic', 'normal', '5中P', '中P', '立ち中P（フーリガンストレート）', 12, 6, 6, '{}'::text[]),
  ('cammy_5mk', 'cammy', 'classic', 'normal', '5中K', '中K', '立ち中K（トゥースマッシュ）', 13, 8, 3, '{}'::text[]),
  ('cammy_5hp', 'cammy', 'classic', 'normal', '5強P', '強P', '立ち強P（スイングナックル）', 14, 8, 2, array['C']),
  ('cammy_5hk', 'cammy', 'classic', 'normal', '5強K', '強K', '立ち強K（スティールスライサー）', 15, 11, 2, '{}'::text[]),
  ('cammy_2lp', 'cammy', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（ラピッドショット）', 20, 4, 5, array['C']),
  ('cammy_2lk', 'cammy', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（スタンレイピア）', 21, 5, 3, '{}'::text[]),
  ('cammy_2mp', 'cammy', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（ライトグレネード）', 22, 7, 5, array['C']),
  ('cammy_2mk', 'cammy', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（トゥーバズソー）', 23, 8, 1, array['C']),
  ('cammy_2hp', 'cammy', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（トーピードーシェル）', 24, 10, 7, '{}'::text[]),
  ('cammy_2hk', 'cammy', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（グランドスイープ）', 25, 9, null, '{}'::text[]),
  ('cammy_jlp', 'cammy', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（ダガーショット）', 30, 4, null, '{}'::text[]),
  ('cammy_jlk', 'cammy', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（レイダーニー）', 31, 4, null, '{}'::text[]),
  ('cammy_jmp', 'cammy', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（アラウンドブレード）', 32, 6, null, array['C']),
  ('cammy_jmk', 'cammy', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（スナイピングスピア）', 33, 7, null, '{}'::text[]),
  ('cammy_jhp', 'cammy', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（フィストボム）', 34, 8, null, '{}'::text[]),
  ('cammy_jhk', 'cammy', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（クリティカルストライク）', 35, 10, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 5種: 40〜44）
  ('cammy_4mp', 'cammy', 'classic', 'unique', '4中P', '←+中P', 'リフトアッパー', 40, 5, 4, array['C']),
  ('cammy_6hk', 'cammy', 'classic', 'unique', '6強K', '→+強K', 'ディレイリーパー', 41, 18, null, array['C']),
  ('cammy_4hk', 'cammy', 'classic', 'unique', '4強K', '←+強K', 'アサルトブレード', 42, 9, null, array['C']),
  ('cammy_tc_4mp', 'cammy', 'classic', 'unique', '4中P>強K', '←+中P>強K', 'リフトコンビネーション', 43, 9, null, array['C']),
  ('cammy_tc_5hp', 'cammy', 'classic', 'unique', '5強P>強K', '強P>強K', 'スイングコンビネーション', 44, 13, null, array['C']),

  -- 3. 必殺技（クラシック 34種: 50〜83）
  ('cammy_236lk', 'cammy', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 スパイラルアロー', 50, 9, null, '{}'::text[]),
  ('cammy_236mk', 'cammy', 'classic', 'special', '236中K', '↓↘→+中K', '中 スパイラルアロー', 51, 9, null, '{}'::text[]),
  ('cammy_236hk', 'cammy', 'classic', 'special', '236強K', '↓↘→+強K', '強 スパイラルアロー', 52, 15, null, array['SA3']),
  ('cammy_236hk_h', 'cammy', 'classic', 'special', '236強K(H)', '↓↘→+強Kホールド', '強 スパイラルアロー（ホールド）', 53, 25, null, array['SA3']),
  ('cammy_236odk', 'cammy', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD スパイラルアロー', 54, 13, null, array['SA2']),
  ('cammy_623lk', 'cammy', 'classic', 'special', '623弱K', '→↓↘+弱K', '弱 キャノンスパイク', 55, 5, null, array['SA3']),
  ('cammy_623mk', 'cammy', 'classic', 'special', '623中K', '→↓↘+中K', '中 キャノンスパイク', 56, 6, null, array['SA3']),
  ('cammy_623hk', 'cammy', 'classic', 'special', '623強K', '→↓↘+強K', '強 キャノンスパイク', 57, 7, null, array['SA3']),
  ('cammy_623hk_h', 'cammy', 'classic', 'special', '623強K(H)', '→↓↘+強Kホールド', '強 キャノンスパイク（ホールド）', 58, 22, null, array['SA3']),
  ('cammy_623odk', 'cammy', 'classic', 'special', 'OD623KK', '→↓↘+KK', 'OD キャノンスパイク', 59, 6, null, '{}'::text[]),
  ('cammy_214lp', 'cammy', 'classic', 'special', '214弱P', '↓↙←+弱P', '弱 アクセルスピンナックル', 60, 21, 2, array['SA3']),
  ('cammy_214mp', 'cammy', 'classic', 'special', '214中P', '↓↙←+中P', '中 アクセルスピンナックル', 61, 24, 3, array['SA3']),
  ('cammy_214hp', 'cammy', 'classic', 'special', '214強P', '↓↙←+強P', '強 アクセルスピンナックル', 62, 28, 5, array['SA3']),
  ('cammy_214odp', 'cammy', 'classic', 'special', 'OD214PP', '↓↙←+PP', 'OD アクセルスピンナックル', 63, 25, 7, array['SA2']),
  ('cammy_air_214k', 'cammy', 'classic', 'special', '空中214K', '前J中↓↙←+K', 'キャノンストライク', 64, 13, null, '{}'::text[]),
  ('cammy_air_214odk', 'cammy', 'classic', 'special', 'OD空中214KK', '前J中↓↙←+KK', 'OD キャノンストライク', 65, 13, null, array['SA2']),
  ('cammy_236p', 'cammy', 'classic', 'special', '236P', '↓↘→+P', 'フーリガンコンビネーション', 66, null, null, '{}'::text[]),
  ('cammy_236hp_h', 'cammy', 'classic', 'special', '236強P(H)', '↓↘→+強Pホールド', 'フーリガンコンビネーション（ホールド）', 67, null, null, '{}'::text[]),
  ('cammy_236odp', 'cammy', 'classic', 'special', 'OD236PP', '↓↘→+PP', 'OD フーリガンコンビネーション', 68, null, null, '{}'::text[]),
  ('cammy_hooligan_razor', 'cammy', 'classic', 'special', 'レイザーエッジ', 'フーリガン中入力なし', 'レイザーエッジスライサー', 69, 10, null, array['SA3']),
  ('cammy_hooligan_razor_h', 'cammy', 'classic', 'special', 'レイザーエッジ(H)', 'フーリガン(H)中入力なし', 'レイザーエッジスライサー（ホールド）', 70, 10, null, array['SA3']),
  ('cammy_hooligan_od_razor', 'cammy', 'classic', 'special', 'ODレイザーエッジ', 'ODフーリガン中入力なし', 'OD レイザーエッジスライサー', 71, 10, null, array['SA2']),
  ('cammy_hooligan_strike', 'cammy', 'classic', 'special', 'フーリガンストライク', 'フーリガン中K', 'キャノンストライク（フーリガン派生）', 72, 13, null, '{}'::text[]),
  ('cammy_hooligan_strike_h', 'cammy', 'classic', 'special', 'フーリガンストライク(H)', 'フーリガン(H)中K', 'キャノンストライク（フーリガンホールド派生）', 73, 13, null, '{}'::text[]),
  ('cammy_hooligan_od_strike', 'cammy', 'classic', 'special', 'ODフーリガンストライク', 'ODフーリガン中K', 'OD キャノンストライク（ODフーリガン派生）', 74, 13, null, array['SA2']),
  ('cammy_hooligan_reverse', 'cammy', 'classic', 'special', 'リバースエッジ', 'フーリガン中↓+K', 'リバースエッジ', 75, 18, null, '{}'::text[]),
  ('cammy_hooligan_reverse_h', 'cammy', 'classic', 'special', 'リバースエッジ(H)', 'フーリガン(H)中↓+K', 'リバースエッジ（ホールド）', 76, 18, 8, '{}'::text[]),
  ('cammy_hooligan_od_reverse', 'cammy', 'classic', 'special', 'ODリバースエッジ', 'ODフーリガン中↓+K', 'OD リバースエッジ', 77, 18, 8, array['SA2']),
  ('cammy_hooligan_fatal', 'cammy', 'classic', 'special', 'フェイタルレッグ', 'フーリガン中弱P+弱K', 'フェイタルレッグツイスター', 78, 10, null, '{}'::text[]),
  ('cammy_hooligan_fatal_h', 'cammy', 'classic', 'special', 'フェイタルレッグ(H)', 'フーリガン(H)中弱P+弱K', 'フェイタルレッグツイスター（ホールド）', 79, 10, null, '{}'::text[]),
  ('cammy_hooligan_od_fatal', 'cammy', 'classic', 'special', 'ODフェイタルレッグ', 'ODフーリガン中弱P+弱K', 'OD フェイタルレッグツイスター', 80, 10, null, '{}'::text[]),
  ('cammy_hooligan_silent', 'cammy', 'classic', 'special', 'サイレントステップ', 'フーリガン中P', 'サイレントステップ', 81, null, null, '{}'::text[]),
  ('cammy_hooligan_silent_h', 'cammy', 'classic', 'special', 'サイレントステップ(H)', 'フーリガン(H)中P', 'サイレントステップ（ホールド）', 82, null, null, '{}'::text[]),
  ('cammy_hooligan_od_silent', 'cammy', 'classic', 'special', 'ODサイレントステップ', 'ODフーリガン中P', 'OD サイレントステップ', 83, null, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 4種: 90〜93、CA除外）
  ('cammy_sa1', 'cammy', 'classic', 'super', 'SA1', '↓↘→↓↘→+K', 'SA1 スピンドライブスマッシャー', 90, 9, null, '{}'::text[]),
  ('cammy_sa2', 'cammy', 'classic', 'super', 'SA2', '↓↙←↓↙←+P', 'SA2 キラービースピン', 91, 13, null, '{}'::text[]),
  ('cammy_air_sa2', 'cammy', 'classic', 'super', '空中SA2', '前J中↓↙←↓↙←+P', 'SA2 エアキラービースピン', 92, 13, null, '{}'::text[]),
  ('cammy_sa3', 'cammy', 'classic', 'super', 'SA3', '↓↘→↓↘→+P', 'SA3 デルタレッドアサルト', 93, 9, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 3種: 95〜97）
  ('cammy_throw_f', 'cammy', 'classic', 'throw', '前投げ', '弱P+弱K', 'ラフランディング（前投げ）', 95, 5, null, '{}'::text[]),
  ('cammy_throw_b', 'cammy', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'デルタスルー（後ろ投げ）', 96, 5, null, '{}'::text[]),
  ('cammy_throw_air', 'cammy', 'classic', 'throw', '空投げ', '空中で弱P+弱K', 'レッグシザースチョーク（空中投げ）', 97, 5, null, '{}'::text[]),

  -- 6. モダン通常技（11種: 110〜120）
  ('cammy_m_5l', 'cammy', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 4, 5, array['C']),
  ('cammy_m_5m', 'cammy', 'modern', 'normal', '5中', '中', '立ち中（立ち中P）', 111, 6, 6, '{}'::text[]),
  ('cammy_m_5h', 'cammy', 'modern', 'normal', '5強', '強', '立ち強（立ち強K）', 112, 11, 2, '{}'::text[]),
  ('cammy_m_2l', 'cammy', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱K）', 113, 5, 3, '{}'::text[]),
  ('cammy_m_2l_2', 'cammy', 'modern', 'normal', '2弱>2弱', '↓+弱>↓+弱', 'しゃがみ弱連打（しゃがみ弱P）', 114, 4, 5, array['C']),
  ('cammy_m_2m', 'cammy', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 115, 8, 1, array['C']),
  ('cammy_m_2h', 'cammy', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 116, 10, 7, '{}'::text[]),
  ('cammy_m_3h', 'cammy', 'modern', 'normal', '3強', '↘+強', '右下強（グランドスイープ）', 117, 9, null, '{}'::text[]),
  ('cammy_m_jl', 'cammy', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 118, 4, null, '{}'::text[]),
  ('cammy_m_jm', 'cammy', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 119, 6, null, array['C']),
  ('cammy_m_jh', 'cammy', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 120, 10, null, '{}'::text[]),

  -- 7. モダン特殊技・アシスト（14種: 125〜138）
  ('cammy_m_auto_m', 'cammy', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・しゃがみ中P）', 125, 7, 5, array['C']),
  ('cammy_m_auto_h', 'cammy', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち強P）', 126, 8, 2, array['C']),
  ('cammy_m_j_auto_l', 'cammy', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 127, 4, null, '{}'::text[]),
  ('cammy_m_j_auto_m', 'cammy', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 128, 7, null, '{}'::text[]),
  ('cammy_m_j_auto_h', 'cammy', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 129, 8, null, '{}'::text[]),
  ('cammy_m_auto_l_combo', 'cammy', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 130, 4, null, '{}'::text[]),
  ('cammy_m_auto_2l_combo', 'cammy', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 131, 4, null, '{}'::text[]),
  ('cammy_m_auto_m_combo', 'cammy', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 132, 7, null, '{}'::text[]),
  ('cammy_m_auto_h_combo', 'cammy', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 133, 8, null, '{}'::text[]),
  ('cammy_m_4m', 'cammy', 'modern', 'unique', '4中', '←+中', 'リフトアッパー', 134, 5, 4, array['C']),
  ('cammy_m_6h', 'cammy', 'modern', 'unique', '6強', '→+強', 'ディレイリーパー', 135, 18, null, array['C']),
  ('cammy_m_4h', 'cammy', 'modern', 'unique', '4強', '←+強', 'アサルトブレード', 136, 9, null, array['C']),
  ('cammy_m_tc_4m', 'cammy', 'modern', 'unique', '4中>中', '←+中>中', 'リフトコンビネーション', 137, 9, null, array['C']),
  ('cammy_m_tc_ah', 'cammy', 'modern', 'unique', 'A強>強', 'アシスト強>強', 'スイングコンビネーション', 138, 13, null, array['C']),

  -- 8. モダン必殺技：ワンボタンSP＆OD・フーリガン派生（26種: 145〜170）
  ('cammy_m_sp', 'cammy', 'modern', 'special', 'N必', 'SP', '中 スパイラルアロー（N必）', 145, 9, null, '{}'::text[]),
  ('cammy_m_od_sp', 'cammy', 'modern', 'special', 'A+N必', 'A+SP', 'OD スパイラルアロー（A+N必）', 146, 13, null, array['SA2']),
  ('cammy_m_6sp', 'cammy', 'modern', 'special', '前必', '→+SP', '中 キャノンスパイク（前必）', 147, 6, null, array['SA3']),
  ('cammy_m_od_6sp', 'cammy', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD キャノンスパイク（A+前必）', 148, 6, null, '{}'::text[]),
  ('cammy_m_4sp', 'cammy', 'modern', 'special', '後必', '←+SP', '強 アクセルスピンナックル（後必）', 149, 28, 5, array['SA3']),
  ('cammy_m_od_4sp', 'cammy', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD アクセルスピンナックル（A+後必）', 150, 25, 7, array['SA2']),
  ('cammy_m_air_sp', 'cammy', 'modern', 'special', '空必', '前J中SP', 'キャノンストライク（空必）', 151, 13, null, '{}'::text[]),
  ('cammy_m_od_air_sp', 'cammy', 'modern', 'special', 'A+空必', '前J中A+SP', 'OD キャノンストライク（A+空必）', 152, 13, null, array['SA2']),
  ('cammy_m_2sp', 'cammy', 'modern', 'special', '下必', '↓+SP', 'フーリガンコンビネーション（下必）', 153, null, null, '{}'::text[]),
  ('cammy_m_3sp_h', 'cammy', 'modern', 'special', '右下必(H)', '↘+SPホールド', 'フーリガンコンビネーション（ホールド・右下必）', 154, null, null, '{}'::text[]),
  ('cammy_m_od_2sp', 'cammy', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD フーリガンコンビネーション（A+下必）', 155, null, null, '{}'::text[]),
  ('cammy_m_hooligan_razor', 'cammy', 'modern', 'special', 'レイザーエッジ', 'フーリガン中入力なし', 'レイザーエッジスライサー', 156, 10, null, array['SA3']),
  ('cammy_m_hooligan_razor_h', 'cammy', 'modern', 'special', 'レイザーエッジ(H)', 'フーリガン(H)中入力なし', 'レイザーエッジスライサー（ホールド）', 157, 10, null, array['SA3']),
  ('cammy_m_hooligan_od_razor', 'cammy', 'modern', 'special', 'ODレイザーエッジ', 'ODフーリガン中入力なし', 'OD レイザーエッジスライサー', 158, 10, null, array['SA2']),
  ('cammy_m_hooligan_strike', 'cammy', 'modern', 'special', 'フーリガンストライク', 'フーリガン中攻撃', 'キャノンストライク（フーリガン派生）', 159, 13, null, '{}'::text[]),
  ('cammy_m_hooligan_strike_h', 'cammy', 'modern', 'special', 'フーリガンストライク(H)', 'フーリガン(H)中攻撃', 'キャノンストライク（フーリガンホールド派生）', 160, 13, null, '{}'::text[]),
  ('cammy_m_hooligan_od_strike', 'cammy', 'modern', 'special', 'ODフーリガンストライク', 'ODフーリガン中攻撃', 'OD キャノンストライク（ODフーリガン派生）', 161, 13, null, array['SA2']),
  ('cammy_m_hooligan_reverse', 'cammy', 'modern', 'special', 'リバースエッジ', 'フーリガン中↓+攻撃', 'リバースエッジ', 162, 18, null, '{}'::text[]),
  ('cammy_m_hooligan_reverse_h', 'cammy', 'modern', 'special', 'リバースエッジ(H)', 'フーリガン(H)中↓+攻撃', 'リバースエッジ（ホールド）', 163, 18, 8, '{}'::text[]),
  ('cammy_m_hooligan_od_reverse', 'cammy', 'modern', 'special', 'ODリバースエッジ', 'ODフーリガン中↓+攻撃', 'OD リバースエッジ', 164, 18, 8, array['SA2']),
  ('cammy_m_hooligan_fatal', 'cammy', 'modern', 'special', 'フェイタルレッグ', 'フーリガン中→+攻撃', 'フェイタルレッグツイスター', 165, 10, null, '{}'::text[]),
  ('cammy_m_hooligan_fatal_h', 'cammy', 'modern', 'special', 'フェイタルレッグ(H)', 'フーリガン(H)中→+攻撃', 'フェイタルレッグツイスター（ホールド）', 166, 10, null, '{}'::text[]),
  ('cammy_m_hooligan_od_fatal', 'cammy', 'modern', 'special', 'ODフェイタルレッグ', 'ODフーリガン中→+攻撃', 'OD フェイタルレッグツイスター', 167, 10, null, '{}'::text[]),
  ('cammy_m_hooligan_silent', 'cammy', 'modern', 'special', 'サイレントステップ', 'フーリガン中←+攻撃', 'サイレントステップ', 168, null, null, '{}'::text[]),
  ('cammy_m_hooligan_silent_h', 'cammy', 'modern', 'special', 'サイレントステップ(H)', 'フーリガン(H)中←+攻撃', 'サイレントステップ（ホールド）', 169, null, null, '{}'::text[]),
  ('cammy_m_hooligan_od_silent', 'cammy', 'modern', 'special', 'ODサイレントステップ', 'ODフーリガン中←+攻撃', 'OD サイレントステップ', 170, null, null, '{}'::text[]),

  -- 9. モダン必殺技：コマンド入力版（16種: 175〜190）
  ('cammy_m_236l', 'cammy', 'modern', 'special', '236弱', '↓↘→+弱', '弱 スパイラルアロー', 175, 9, null, '{}'::text[]),
  ('cammy_m_236m', 'cammy', 'modern', 'special', '236中', '↓↘→+中', '中 スパイラルアロー', 176, 9, null, '{}'::text[]),
  ('cammy_m_236h', 'cammy', 'modern', 'special', '236強', '↓↘→+強', '強 スパイラルアロー', 177, 15, null, array['SA3']),
  ('cammy_m_236h_h', 'cammy', 'modern', 'special', '236強(H)', '↓↘→+強ホールド', '強 スパイラルアロー（ホールド）', 178, 25, null, array['SA3']),
  ('cammy_m_236od', 'cammy', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD スパイラルアロー', 179, 13, null, array['SA2']),
  ('cammy_m_623l', 'cammy', 'modern', 'special', '623弱', '→↓↘+弱', '弱 キャノンスパイク', 180, 5, null, array['SA3']),
  ('cammy_m_623m', 'cammy', 'modern', 'special', '623中', '→↓↘+中', '中 キャノンスパイク', 181, 6, null, array['SA3']),
  ('cammy_m_623h', 'cammy', 'modern', 'special', '623強', '→↓↘+強', '強 キャノンスパイク', 182, 7, null, array['SA3']),
  ('cammy_m_623h_h', 'cammy', 'modern', 'special', '623強(H)', '→↓↘+強ホールド', '強 キャノンスパイク（ホールド）', 183, 22, null, array['SA3']),
  ('cammy_m_623od', 'cammy', 'modern', 'special', 'OD623', '→↓↘+攻撃×2', 'OD キャノンスパイク', 184, 6, null, '{}'::text[]),
  ('cammy_m_214l', 'cammy', 'modern', 'special', '214弱', '↓↙←+弱', '弱 アクセルスピンナックル', 185, 21, 2, array['SA3']),
  ('cammy_m_214m', 'cammy', 'modern', 'special', '214中', '↓↙←+中', '中 アクセルスピンナックル', 186, 24, 3, array['SA3']),
  ('cammy_m_214h', 'cammy', 'modern', 'special', '214強', '↓↙←+強', '強 アクセルスピンナックル', 187, 28, 5, array['SA3']),
  ('cammy_m_214od', 'cammy', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD アクセルスピンナックル', 188, 25, 7, array['SA2']),
  ('cammy_m_air_214', 'cammy', 'modern', 'special', '空中214', '前J中↓↙←+攻撃', 'キャノンストライク', 189, 13, null, '{}'::text[]),
  ('cammy_m_air_214od', 'cammy', 'modern', 'special', 'OD空中214', '前J中↓↙←+攻撃×2', 'OD キャノンストライク', 190, 13, null, array['SA2']),

  -- 10. モダンスーパーアーツ（4種: 195〜198、CA除外）
  ('cammy_m_sa1', 'cammy', 'modern', 'super', 'SA1', 'SP+強', 'SA1 スピンドライブスマッシャー', 195, 9, null, '{}'::text[]),
  ('cammy_m_sa2', 'cammy', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 キラービースピン', 196, 13, null, '{}'::text[]),
  ('cammy_m_air_sa2', 'cammy', 'modern', 'super', '空中SA2', '前J中SP+強', 'SA2 エアキラービースピン', 197, 13, null, '{}'::text[]),
  ('cammy_m_sa3', 'cammy', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 デルタレッドアサルト', 198, 9, null, '{}'::text[]),

  -- 11. モダン通常投げ（3種: 205〜207）
  ('cammy_m_throw_f', 'cammy', 'modern', 'throw', '前投げ', '弱+中', 'ラフランディング（前投げ）', 205, 5, null, '{}'::text[]),
  ('cammy_m_throw_b', 'cammy', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'デルタスルー（後ろ投げ）', 206, 5, null, '{}'::text[]),
  ('cammy_m_throw_air', 'cammy', 'modern', 'throw', '空投げ', '空中で弱+中', 'レッグシザースチョーク（空中投げ）', 207, 5, null, '{}'::text[]),

  -- =========================================================================
  -- 春麗（chun-li）全143技（クラシック67種＋モダン76種）
  -- =========================================================================

  -- 1. 通常技（クラシック 19種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜36）
  ('chunli_5lp', 'chun-li', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（手突）', 10, 4, 5, array['C']),
  ('chunli_5lk', 'chun-li', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（斧刃脚）', 11, 5, 2, array['C']),
  ('chunli_5mp', 'chun-li', 'classic', 'normal', '5中P', '中P', '立ち中P（頸穿刀）', 12, 5, 6, array['C']),
  ('chunli_5mk', 'chun-li', 'classic', 'normal', '5中K', '中K', '立ち中K（外擺脚）', 13, 7, 4, array['C']),
  ('chunli_5hp', 'chun-li', 'classic', 'normal', '5強P', '強P', '立ち強P（顎狙突拳）', 14, 13, 2, '{}'::text[]),
  ('chunli_5hk', 'chun-li', 'classic', 'normal', '5強K', '強K', '立ち強K（前周脚）', 15, 14, 4, '{}'::text[]),
  ('chunli_2lp', 'chun-li', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（尖打）', 20, 4, 4, array['C']),
  ('chunli_2lk', 'chun-li', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（前掃腿）', 21, 4, 0, array['C']),
  ('chunli_2mp', 'chun-li', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（丹頂拳）', 22, 6, 4, array['C']),
  ('chunli_2mk', 'chun-li', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（後掃旋腿）', 23, 7, -2, array['C']),
  ('chunli_2hp', 'chun-li', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（孔雀掌）', 24, 11, 1, array['C']),
  ('chunli_2hk', 'chun-li', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（元伝暗殺蹴）', 25, 9, null, '{}'::text[]),
  ('chunli_jlp', 'chun-li', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（鶴嘴拳）', 30, 4, null, '{}'::text[]),
  ('chunli_jlk', 'chun-li', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（鶴脚打）', 31, 4, null, '{}'::text[]),
  ('chunli_jmp', 'chun-li', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（落昇旋）', 32, 7, null, array['C']),
  ('chunli_jmk', 'chun-li', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（飛翔脚）', 33, 6, null, '{}'::text[]),
  ('chunli_jhp', 'chun-li', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（鷹嘴拳）', 34, 9, null, '{}'::text[]),
  ('chunli_jhk', 'chun-li', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（鷹翔脚）', 35, 8, null, '{}'::text[]),
  ('chunli_njhk', 'chun-li', 'classic', 'normal', '垂直J強K', '垂直J中強K', '垂直ジャンプ強K（鶴翼脚）', 36, 8, null, '{}'::text[]),

  -- 2. 特殊技・行雲流水＆派生（クラシック 16種: 40〜55）
  ('chunli_6mp', 'chun-li', 'classic', 'unique', '4or6中P', '←or→+中P', '追突拳', 40, 7, 2, array['C']),
  ('chunli_4hp', 'chun-li', 'classic', 'unique', '4強P', '←+強P', '発勁', 41, 8, 5, array['C']),
  ('chunli_3hp', 'chun-li', 'classic', 'unique', '3強P', '↘+強P', '水蓮掌', 42, 21, 2, '{}'::text[]),
  ('chunli_6hk', 'chun-li', 'classic', 'unique', '6強K', '→+強K', '翼旋脚', 43, 16, -1, '{}'::text[]),
  ('chunli_3hk', 'chun-li', 'classic', 'unique', '3強K', '↘+強K', '鶴脚落', 44, 37, 7, '{}'::text[]),
  ('chunli_j2mk_1', 'chun-li', 'classic', 'unique', 'J2中K', '空中で↓+中K', '鷹爪脚（1段目）', 45, 3, null, array['C']),
  ('chunli_j2mk_2', 'chun-li', 'classic', 'unique', 'J2中K×2', '空中で↓+中K>↓+中K', '鷹爪脚（2段目）', 46, 6, null, array['C']),
  ('chunli_j2mk_3', 'chun-li', 'classic', 'unique', 'J2中K×3', '空中で↓+中K×3', '鷹爪脚（3段目）', 47, 6, null, array['C']),
  ('chunli_jhp_tc', 'chun-li', 'classic', 'unique', 'J強P>強P', '空中で強P>強P', '鷹嘴連拳', 48, 6, null, '{}'::text[]),
  ('chunli_kamae', 'chun-li', 'classic', 'unique', '行雲流水(214P)', '↓↙←+P', '行雲流水', 49, null, null, '{}'::text[]),
  ('chunli_kamae_lp', 'chun-li', 'classic', 'unique', '蘭華(構え弱P)', '行雲中弱P', '蘭華（行雲流水派生）', 50, 5, -3, array['C']),
  ('chunli_kamae_mp', 'chun-li', 'classic', 'unique', '這蛇突(構え中P)', '行雲中中P', '這蛇突（行雲流水派生）', 51, 6, null, '{}'::text[]),
  ('chunli_kamae_hp', 'chun-li', 'classic', 'unique', '蓮掌(構え強P)', '行雲中強P', '蓮掌（行雲流水派生）', 52, 23, 2, array['C']),
  ('chunli_kamae_lk', 'chun-li', 'classic', 'unique', '前突(構え弱K)', '行雲中弱K', '前突（行雲流水派生）', 53, 8, -1, array['C']),
  ('chunli_kamae_mk', 'chun-li', 'classic', 'unique', '仙風(構え中K)', '行雲中中K', '仙風（行雲流水派生）', 54, 10, -4, array['C']),
  ('chunli_kamae_hk', 'chun-li', 'classic', 'unique', '天空脚(構え強K)', '行雲中強K', '天空脚（行雲流水派生）', 55, 8, null, '{}'::text[]),

  -- 3. 必殺技（クラシック 25種: 60〜84）
  ('chunli_46lp', 'chun-li', 'classic', 'special', '[4]6弱P', '←タメ→+弱P', '弱 気功拳', 60, 15, -3, array['SA3']),
  ('chunli_46mp', 'chun-li', 'classic', 'special', '[4]6中P', '←タメ→+中P', '中 気功拳', 61, 12, -3, array['SA3']),
  ('chunli_46hp', 'chun-li', 'classic', 'special', '[4]6強P', '←タメ→+強P', '強 気功拳', 62, 11, -2, array['SA3']),
  ('chunli_46odp', 'chun-li', 'classic', 'special', 'OD[4]6PP', '←タメ→+PP', 'OD 気功拳', 63, 11, 5, array['SA2']),
  ('chunli_236lk', 'chun-li', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 百裂脚', 64, 5, 3, array['SA3']),
  ('chunli_236mk', 'chun-li', 'classic', 'special', '236中K', '↓↘→+中K', '中 百裂脚', 65, 12, 3, array['SA3']),
  ('chunli_236hk', 'chun-li', 'classic', 'special', '236強K', '↓↘→+強K', '強 百裂脚', 66, 23, null, array['SA3']),
  ('chunli_236odk', 'chun-li', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD 百裂脚', 67, 8, 3, array['SA2']),
  ('chunli_hyaku_renkyaku', 'chun-li', 'classic', 'special', '百裂連脚', 'OD百裂脚後KK', '百裂連脚（OD百裂脚派生）', 68, 11, null, '{}'::text[]),
  ('chunli_air_236lk', 'chun-li', 'classic', 'special', '空中236弱K', '垂直/前J中↓↘→+弱K', '弱 空中百裂脚', 69, 8, null, '{}'::text[]),
  ('chunli_air_236mk', 'chun-li', 'classic', 'special', '空中236中K', '垂直/前J中↓↘→+中K', '中 空中百裂脚', 70, 10, null, '{}'::text[]),
  ('chunli_air_236hk', 'chun-li', 'classic', 'special', '空中236強K', '垂直/前J中↓↘→+強K', '強 空中百裂脚', 71, 12, null, '{}'::text[]),
  ('chunli_air_236odk', 'chun-li', 'classic', 'special', 'OD空中236KK', '垂直/前J中↓↘→+KK', 'OD 空中百裂脚', 72, 6, null, '{}'::text[]),
  ('chunli_28lk', 'chun-li', 'classic', 'special', '[2]8弱K', '↓タメ↑+弱K', '弱 スピニングバードキック', 73, 9, null, '{}'::text[]),
  ('chunli_28mk', 'chun-li', 'classic', 'special', '[2]8中K', '↓タメ↑+中K', '中 スピニングバードキック', 74, 16, null, '{}'::text[]),
  ('chunli_28hk', 'chun-li', 'classic', 'special', '[2]8強K', '↓タメ↑+強K', '強 スピニングバードキック', 75, 20, null, '{}'::text[]),
  ('chunli_28odk', 'chun-li', 'classic', 'special', 'OD[2]8KK', '↓タメ↑+KK', 'OD スピニングバードキック', 76, 16, null, '{}'::text[]),
  ('chunli_214lk', 'chun-li', 'classic', 'special', '214弱K', '↓↙←+弱K', '弱 覇山蹴', 77, 23, null, array['SA3']),
  ('chunli_214mk', 'chun-li', 'classic', 'special', '214中K', '↓↙←+中K', '中 覇山蹴', 78, 27, 2, array['SA3']),
  ('chunli_214hk', 'chun-li', 'classic', 'special', '214強K', '↓↙←+強K', '強 覇山蹴', 79, 32, 6, array['SA3']),
  ('chunli_214odk', 'chun-li', 'classic', 'special', 'OD214KK', '↓↙←+KK', 'OD 覇山蹴', 80, 26, null, array['SA2']),
  ('chunli_22lk', 'chun-li', 'classic', 'special', '22弱K', '↓↓+弱K', '弱 天昇脚', 81, 5, null, '{}'::text[]),
  ('chunli_22mk', 'chun-li', 'classic', 'special', '22中K', '↓↓+中K', '中 天昇脚', 82, 7, null, '{}'::text[]),
  ('chunli_22hk', 'chun-li', 'classic', 'special', '22強K', '↓↓+強K', '強 天昇脚', 83, 9, null, '{}'::text[]),
  ('chunli_22odk', 'chun-li', 'classic', 'special', 'OD22KK', '↓↓+KK', 'OD 天昇脚', 84, 6, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 4種: 90〜93、CA除外）
  ('chunli_sa1', 'chun-li', 'classic', 'super', 'SA1', '↓↘→↓↘→+P', 'SA1 気功掌', 90, 7, null, '{}'::text[]),
  ('chunli_air_sa1', 'chun-li', 'classic', 'super', '空中SA1', '空中で↓↘→↓↘→+P', 'SA1 空中気功掌', 91, 7, null, '{}'::text[]),
  ('chunli_sa2', 'chun-li', 'classic', 'super', 'SA2', '↓↘→↓↘→+K', 'SA2 鳳翼扇', 92, 11, null, '{}'::text[]),
  ('chunli_sa3', 'chun-li', 'classic', 'super', 'SA3', '↓↙←↓↙←+K', 'SA3 蒼天乱華', 93, 8, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 3種: 95〜97）
  ('chunli_throw_f', 'chun-li', 'classic', 'throw', '前投げ', '弱P+弱K', '虎襲倒（前投げ）', 95, 5, null, '{}'::text[]),
  ('chunli_throw_b', 'chun-li', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', '太極扇（後ろ投げ）', 96, 5, null, '{}'::text[]),
  ('chunli_throw_air', 'chun-li', 'classic', 'throw', '空投げ', '空中で弱P+弱K', '龍星落（空中投げ）', 97, 5, null, '{}'::text[]),

  -- 6. モダン通常技（12種: 110〜121）
  ('chunli_m_5l', 'chun-li', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 4, 5, array['C']),
  ('chunli_m_5m', 'chun-li', 'modern', 'normal', '5中', '中', '立ち中（立ち中P）', 111, 5, 6, array['C']),
  ('chunli_m_5h', 'chun-li', 'modern', 'normal', '5強', '強', '立ち強（立ち強P）', 112, 13, 2, '{}'::text[]),
  ('chunli_m_2l', 'chun-li', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱K）', 113, 4, 0, array['C']),
  ('chunli_m_2l_2', 'chun-li', 'modern', 'normal', '2弱>2弱', '↓+弱>↓+弱', 'しゃがみ弱連打（しゃがみ弱P）', 114, 4, 4, array['C']),
  ('chunli_m_2m', 'chun-li', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 115, 7, -2, array['C']),
  ('chunli_m_2h', 'chun-li', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 116, 11, 1, array['C']),
  ('chunli_m_3h', 'chun-li', 'modern', 'normal', '3強', '↘+強', '右下強（元伝暗殺蹴）', 117, 9, null, '{}'::text[]),
  ('chunli_m_jl', 'chun-li', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 118, 4, null, '{}'::text[]),
  ('chunli_m_jm', 'chun-li', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 119, 7, null, array['C']),
  ('chunli_m_jh', 'chun-li', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 120, 8, null, '{}'::text[]),
  ('chunli_m_njh', 'chun-li', 'modern', 'normal', '垂直J強', '垂直J中強', '垂直ジャンプ強（鶴翼脚）', 121, 8, null, '{}'::text[]),

  -- 7. モダン特殊技・アシスト・行雲流水＆派生（23種: 125〜147）
  ('chunli_m_auto_l', 'chun-li', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・立ち弱K）', 125, 5, 2, array['C']),
  ('chunli_m_auto_m', 'chun-li', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・しゃがみ中P）', 126, 6, 4, array['C']),
  ('chunli_m_j_auto_l', 'chun-li', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 127, 4, null, '{}'::text[]),
  ('chunli_m_j_auto_m', 'chun-li', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 128, 6, null, '{}'::text[]),
  ('chunli_m_j_auto_h', 'chun-li', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 129, 9, null, '{}'::text[]),
  ('chunli_m_auto_l_combo', 'chun-li', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 130, 5, null, '{}'::text[]),
  ('chunli_m_auto_2l_combo', 'chun-li', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 131, 4, null, '{}'::text[]),
  ('chunli_m_auto_m_combo', 'chun-li', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 132, 6, null, '{}'::text[]),
  ('chunli_m_auto_h_combo', 'chun-li', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 133, 8, null, '{}'::text[]),
  ('chunli_m_6m', 'chun-li', 'modern', 'unique', '4or6中', '←or→+中', '追突拳', 134, 7, 2, array['C']),
  ('chunli_m_4h', 'chun-li', 'modern', 'unique', '4強', '←+強', '発勁', 135, 8, 5, array['C']),
  ('chunli_m_6h', 'chun-li', 'modern', 'unique', '6強', '→+強', '翼旋脚', 136, 16, -1, '{}'::text[]),
  ('chunli_m_j2m_1', 'chun-li', 'modern', 'unique', 'J2中', '空中で↓+中', '鷹爪脚（1段目）', 137, 3, null, array['C']),
  ('chunli_m_j2m_2', 'chun-li', 'modern', 'unique', 'J2中×2', '空中で↓+中>↓+中', '鷹爪脚（2段目）', 138, 6, null, array['C']),
  ('chunli_m_j2m_3', 'chun-li', 'modern', 'unique', 'J2中×3', '空中で↓+中×3', '鷹爪脚（3段目）', 139, 6, null, array['C']),
  ('chunli_m_jah_tc', 'chun-li', 'modern', 'unique', 'JA強>強', '空中でアシスト強>強', '鷹嘴連拳', 140, 6, null, '{}'::text[]),
  ('chunli_m_kamae', 'chun-li', 'modern', 'unique', '行雲流水(214攻撃)', '↓↙←+攻撃', '行雲流水', 141, null, null, '{}'::text[]),
  ('chunli_m_kamae_l', 'chun-li', 'modern', 'unique', '蘭華(構え弱)', '行雲中弱', '蘭華（行雲流水派生）', 142, 5, -3, array['C']),
  ('chunli_m_kamae_m', 'chun-li', 'modern', 'unique', '這蛇突(構え中)', '行雲中中', '這蛇突（行雲流水派生）', 143, 6, null, '{}'::text[]),
  ('chunli_m_kamae_h', 'chun-li', 'modern', 'unique', '蓮掌(構え強)', '行雲中強', '蓮掌（行雲流水派生）', 144, 23, 2, array['C']),
  ('chunli_m_kamae_2l', 'chun-li', 'modern', 'unique', '前突(構え2弱)', '行雲中↓+弱', '前突（行雲流水派生）', 145, 8, -1, array['C']),
  ('chunli_m_kamae_2m', 'chun-li', 'modern', 'unique', '仙風(構え2中)', '行雲中↓+中', '仙風（行雲流水派生）', 146, 10, -4, array['C']),
  ('chunli_m_kamae_2h', 'chun-li', 'modern', 'unique', '天空脚(構え2強)', '行雲中↓+強', '天空脚（行雲流水派生）', 147, 8, null, '{}'::text[]),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（13種: 150〜162）
  ('chunli_m_4sp', 'chun-li', 'modern', 'special', '[4]後必', '←タメ+SP', '強 気功拳（後必）', 150, 11, -2, array['SA3']),
  ('chunli_m_od_4sp', 'chun-li', 'modern', 'special', 'A+[4]後必', '←タメ+A+SP', 'OD 気功拳（A+後必）', 151, 11, 5, array['SA2']),
  ('chunli_m_sp', 'chun-li', 'modern', 'special', 'N必', 'SP', '弱 百裂脚（N必）', 152, 5, 3, array['SA3']),
  ('chunli_m_od_sp', 'chun-li', 'modern', 'special', 'A+N必', 'A+SP', 'OD 百裂脚（A+N必）', 153, 8, 3, array['SA2']),
  ('chunli_m_sp_hyaku_renkyaku', 'chun-li', 'modern', 'special', '百裂連脚(SP)', 'OD百裂脚後SP', '百裂連脚（OD百裂脚派生・SP）', 154, 11, null, '{}'::text[]),
  ('chunli_m_air_sp', 'chun-li', 'modern', 'special', '空必', '垂直/前J中SP', '弱 空中百裂脚（空必）', 155, 8, null, '{}'::text[]),
  ('chunli_m_od_air_sp', 'chun-li', 'modern', 'special', 'A+空必', '垂直/前J中A+SP', 'OD 空中百裂脚（A+空必）', 156, 6, null, '{}'::text[]),
  ('chunli_m_1sp', 'chun-li', 'modern', 'special', '左下必', '↙+SP', '弱 覇山蹴（左下必）', 157, 23, null, array['SA3']),
  ('chunli_m_2sp', 'chun-li', 'modern', 'special', '下必', '↓+SP', '中 覇山蹴（下必）', 158, 27, 2, array['SA3']),
  ('chunli_m_3sp', 'chun-li', 'modern', 'special', '右下必', '↘+SP', '強 覇山蹴（右下必）', 159, 32, 6, array['SA3']),
  ('chunli_m_od_2sp', 'chun-li', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD 覇山蹴（A+下必）', 160, 26, null, array['SA2']),
  ('chunli_m_6sp', 'chun-li', 'modern', 'special', '前必', '→+SP', '強 天昇脚（前必）', 161, 9, null, '{}'::text[]),
  ('chunli_m_od_6sp', 'chun-li', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD 天昇脚（A+前必）', 162, 6, null, '{}'::text[]),

  -- 9. モダン必殺技：コマンド入力版（21種: 165〜185）
  ('chunli_m_46l', 'chun-li', 'modern', 'special', '[4]6弱', '←タメ→+弱', '弱 気功拳', 165, 15, -3, array['SA3']),
  ('chunli_m_46m', 'chun-li', 'modern', 'special', '[4]6中', '←タメ→+中', '中 気功拳', 166, 12, -3, array['SA3']),
  ('chunli_m_46h', 'chun-li', 'modern', 'special', '[4]6強', '←タメ→+強', '強 気功拳', 167, 11, -2, array['SA3']),
  ('chunli_m_46od', 'chun-li', 'modern', 'special', 'OD[4]6', '←タメ→+攻撃×2', 'OD 気功拳', 168, 11, 5, array['SA2']),
  ('chunli_m_236l', 'chun-li', 'modern', 'special', '236弱', '↓↘→+弱', '弱 百裂脚', 169, 5, 3, array['SA3']),
  ('chunli_m_236m', 'chun-li', 'modern', 'special', '236中', '↓↘→+中', '中 百裂脚', 170, 12, 3, array['SA3']),
  ('chunli_m_236h', 'chun-li', 'modern', 'special', '236強', '↓↘→+強', '強 百裂脚', 171, 23, null, array['SA3']),
  ('chunli_m_236od', 'chun-li', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD 百裂脚', 172, 8, 3, array['SA2']),
  ('chunli_m_hyaku_renkyaku', 'chun-li', 'modern', 'special', '百裂連脚', 'OD百裂脚後攻撃×2', '百裂連脚（OD百裂脚派生）', 173, 11, null, '{}'::text[]),
  ('chunli_m_air_236l', 'chun-li', 'modern', 'special', '空中236弱', '垂直/前J中↓↘→+弱', '弱 空中百裂脚', 174, 8, null, '{}'::text[]),
  ('chunli_m_air_236m', 'chun-li', 'modern', 'special', '空中236中', '垂直/前J中↓↘→+中', '中 空中百裂脚', 175, 10, null, '{}'::text[]),
  ('chunli_m_air_236h', 'chun-li', 'modern', 'special', '空中236強', '垂直/前J中↓↘→+強', '強 空中百裂脚', 176, 12, null, '{}'::text[]),
  ('chunli_m_air_236od', 'chun-li', 'modern', 'special', 'OD空中236', '垂直/前J中↓↘→+攻撃×2', 'OD 空中百裂脚', 177, 6, null, '{}'::text[]),
  ('chunli_m_28l', 'chun-li', 'modern', 'special', '[2]8弱', '↓タメ↑+弱', '弱 スピニングバードキック', 178, 9, null, '{}'::text[]),
  ('chunli_m_28m', 'chun-li', 'modern', 'special', '[2]8中', '↓タメ↑+中', '中 スピニングバードキック', 179, 16, null, '{}'::text[]),
  ('chunli_m_28h', 'chun-li', 'modern', 'special', '[2]8強', '↓タメ↑+強', '強 スピニングバードキック', 180, 20, null, '{}'::text[]),
  ('chunli_m_28od', 'chun-li', 'modern', 'special', 'OD[2]8', '↓タメ↑+攻撃×2', 'OD スピニングバードキック', 181, 16, null, '{}'::text[]),
  ('chunli_m_22l', 'chun-li', 'modern', 'special', '22弱', '↓↓+弱', '弱 天昇脚', 182, 5, null, '{}'::text[]),
  ('chunli_m_22m', 'chun-li', 'modern', 'special', '22中', '↓↓+中', '中 天昇脚', 183, 7, null, '{}'::text[]),
  ('chunli_m_22h', 'chun-li', 'modern', 'special', '22強', '↓↓+強', '強 天昇脚', 184, 9, null, '{}'::text[]),
  ('chunli_m_22od', 'chun-li', 'modern', 'special', 'OD22', '↓↓+攻撃×2', 'OD 天昇脚', 185, 6, null, '{}'::text[]),

  -- 10. モダンスーパーアーツ（4種: 190〜193、CA除外）
  ('chunli_m_sa1', 'chun-li', 'modern', 'super', 'SA1', 'SP+強', 'SA1 気功掌', 190, 7, null, '{}'::text[]),
  ('chunli_m_air_sa1', 'chun-li', 'modern', 'super', '空中SA1', '空中でSP+強', 'SA1 空中気功掌', 191, 7, null, '{}'::text[]),
  ('chunli_m_sa2', 'chun-li', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 鳳翼扇', 192, 11, null, '{}'::text[]),
  ('chunli_m_sa3', 'chun-li', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 蒼天乱華', 193, 8, null, '{}'::text[]),

  -- 11. モダン通常投げ（3種: 200〜202）
  ('chunli_m_throw_f', 'chun-li', 'modern', 'throw', '前投げ', '弱+中', '虎襲倒（前投げ）', 200, 5, null, '{}'::text[]),
  ('chunli_m_throw_b', 'chun-li', 'modern', 'throw', '後ろ投げ', '←+弱+中', '太極扇（後ろ投げ）', 201, 5, null, '{}'::text[]),
  ('chunli_m_throw_air', 'chun-li', 'modern', 'throw', '空投げ', '空中で弱+中', '龍星落（空中投げ）', 202, 5, null, '{}'::text[])
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
