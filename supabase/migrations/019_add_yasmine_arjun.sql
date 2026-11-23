-- =============================================================================
-- Migration: 019_add_yasmine_arjun.sql
-- 目的: 23人目「ヤスミン（yasmine）」・24人目「アルジュン（arjun）」のキャラクターマスタおよび
--       全技マスタ（ヤスミン全143技＋アルジュン全127技＝計270技・
--       公式フレームデータ＆コマンドリスト準拠・CA除外）を
--       既存の Supabase 本番 DB へ安全・冪等に UPSERT する
-- 前提: 001_add_throw_category.sql を先に適用済みであること
-- =============================================================================

-- 1. キャラクターマスタへヤスミン・アルジュンを追加・更新
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
  ('yasmine', 'yasmine', 'ヤスミン', 'Yasmine', 23, true, 'バヤニ・モード', 'バヤニ', 1),
  ('arjun', 'arjun', 'アルジュン', 'Arjun', 24, true, null, null, null)
on conflict (id) do update set
  slug = excluded.slug,
  name_ja = excluded.name_ja,
  name_en = excluded.name_en,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  stock_label = excluded.stock_label,
  stock_short_label = excluded.stock_short_label,
  stock_max_count = excluded.stock_max_count;

-- 2. ヤスミン・アルジュン全技マスタ（計270技）を UPSERT
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
  -- ヤスミン（yasmine）全143技（クラシック68種＋モダン75種）
  -- =========================================================================

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('yasmine_5lp', 'yasmine', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（マガアン・ナ・パグラスラス）', 10, 5, 4, array['C']),
  ('yasmine_5lk', 'yasmine', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（マババング・シパ）', 11, 5, 2, array['C']),
  ('yasmine_5mp', 'yasmine', 'classic', 'normal', '5中P', '中P', '立ち中P（パバリック・バリック・ナ・パグラスラス）', 12, 6, 2, '{}'::text[]),
  ('yasmine_5mk', 'yasmine', 'classic', 'normal', '5中K', '中K', '立ち中K（タギリラング・シパ）', 13, 10, 3, '{}'::text[]),
  ('yasmine_5hp', 'yasmine', 'classic', 'normal', '5強P', '強P', '立ち強P（トリップレング・パグラスラス）', 14, 9, 2, array['C']),
  ('yasmine_5hk', 'yasmine', 'classic', 'normal', '5強K', '強K', '立ち強K（トゥマタロン・ナ・シパ）', 15, 14, 1, '{}'::text[]),
  ('yasmine_2lp', 'yasmine', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（マビリサング・パグラスラス）', 20, 4, 4, array['C']),
  ('yasmine_2lk', 'yasmine', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（マガアン・ナ・シパ）', 21, 5, 2, '{}'::text[]),
  ('yasmine_2mp', 'yasmine', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（カルモット）', 22, 6, 4, array['C']),
  ('yasmine_2mk', 'yasmine', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（パンドゥログ・ナン・ルロッド）', 23, 8, -1, array['C']),
  ('yasmine_2hp', 'yasmine', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（マミミツィン）', 24, 8, 2, array['C']),
  ('yasmine_2hk', 'yasmine', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（グンティング・ナ・パバサ）', 25, 10, null, '{}'::text[]),
  ('yasmine_jlp', 'yasmine', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（マガアン・ナ・パンヒンパパウィド・パグラスラス）', 30, 4, null, '{}'::text[]),
  ('yasmine_jlk', 'yasmine', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（パンヒンパパウィド・ナ・シパ・ガミット・アング・トゥホッド）', 31, 4, null, '{}'::text[]),
  ('yasmine_jmp', 'yasmine', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（パビログ・ナ・パグラスラス）', 32, 7, null, '{}'::text[]),
  ('yasmine_jmk', 'yasmine', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（パンヒンパパウィド・ナ・シパ・サ・ハラップ）', 33, 7, null, '{}'::text[]),
  ('yasmine_jhp', 'yasmine', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（ナママロング・マガ・パクパク）', 34, 9, null, '{}'::text[]),
  ('yasmine_jhk', 'yasmine', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（パンヒンパパウィド・ナ・マラカス・ナ・シパ）', 35, 10, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 7種: 40〜46）
  ('yasmine_6mp', 'yasmine', 'classic', 'unique', '6中P', '→+中P', 'ヒワン・パババ', 40, 22, 3, '{}'::text[]),
  ('yasmine_4hk', 'yasmine', 'classic', 'unique', '4強K', '←+強K', 'ワリス・ナ・パバグサ', 41, 22, null, array['C']),
  ('yasmine_tc_lp_lp', 'yasmine', 'classic', 'unique', '5弱P>弱P', '弱P>弱P', 'キドラット・ナ・ヒワ', 42, 8, 1, array['C']),
  ('yasmine_tc_mp_mp', 'yasmine', 'classic', 'unique', '5中P>中P', '中P>中P', 'タッロング・ヒワ', 43, 12, null, array['C']),
  ('yasmine_tc_mk2', 'yasmine', 'classic', 'unique', '5中K>中K', '中K>中K', 'スノスノッド・ナ・シパ（1段目）', 44, 13, -13, '{}'::text[]),
  ('yasmine_tc_mk3', 'yasmine', 'classic', 'unique', '5中K>中K>強K', '中K>中K>強K', 'スノスノッド・ナ・シパ（2段目）', 45, 16, null, '{}'::text[]),
  ('yasmine_tc_2mk_hk', 'yasmine', 'classic', 'unique', '2中K>強K', '↓+中K>強K', 'コンビナション・パムパバッグサ', 46, 8, null, '{}'::text[]),

  -- 3. 必殺技（クラシック 38種: 50〜87）
  ('yasmine_236lp', 'yasmine', 'classic', 'special', '236弱P', '↓↘→+弱P', '弱 ダロイ・ン・トゥビグ', 50, 12, 1, array['SA3']),
  ('yasmine_aron_l', 'yasmine', 'classic', 'special', '弱アロン', '弱ダロイ中→+P', '弱 アロン', 51, 13, 1, array['SA3']),
  ('yasmine_aron_l_ex', 'yasmine', 'classic', 'special', '[強化]弱アロン', '[強化]弱ダロイ中→+P', '[強化版]弱 アロン', 52, 16, null, array['SA3']),
  ('yasmine_236mp', 'yasmine', 'classic', 'special', '236中P', '↓↘→+中P', '中 ダロイ・ン・トゥビグ', 53, 16, 1, array['SA3']),
  ('yasmine_aron_m', 'yasmine', 'classic', 'special', '中アロン', '中ダロイ中→+P', '中 アロン', 54, 13, null, array['SA3']),
  ('yasmine_aron_m_ex', 'yasmine', 'classic', 'special', '[強化]中アロン', '[強化]中ダロイ中→+P', '[強化版]中 アロン', 55, 22, null, array['SA3']),
  ('yasmine_236hp', 'yasmine', 'classic', 'special', '236強P', '↓↘→+強P', '強 ダロイ・ン・トゥビグ', 56, 21, 3, array['SA3']),
  ('yasmine_aron_h', 'yasmine', 'classic', 'special', '強アロン', '強ダロイ中→+P', '強 アロン', 57, 13, null, array['SA3']),
  ('yasmine_aron_h_ex', 'yasmine', 'classic', 'special', '[強化]強アロン', '[強化]強ダロイ中→+P', '[強化版]強 アロン', 58, 22, null, array['SA3']),
  ('yasmine_236odp', 'yasmine', 'classic', 'special', 'OD236PP', '↓↘→+PP', 'OD ダロイ・ン・トゥビグ', 59, 12, -2, array['SA2']),
  ('yasmine_aron_od', 'yasmine', 'classic', 'special', 'ODアロン', 'ODダロイ中→+P', 'OD アロン', 60, 13, null, array['SA2']),
  ('yasmine_aron_od_ex', 'yasmine', 'classic', 'special', '[強化]ODアロン', '[強化]ODダロイ中→+P', '[強化版]OD アロン', 61, 56, null, array['SA2']),
  ('yasmine_aron_od_sa2', 'yasmine', 'classic', 'special', '[SA2中][強化]ODアロン', '[ナカタゴン中]ODダロイ中→+P', '[ナカタゴン・ラカス中][強化版]OD アロン', 62, 47, null, '{}'::text[]),
  ('yasmine_214lp', 'yasmine', 'classic', 'special', '214弱P', '↓↙←+弱P', '弱 タリム・ン・ハンギン', 63, null, null, '{}'::text[]),
  ('yasmine_214mp', 'yasmine', 'classic', 'special', '214中P', '↓↙←+中P', '中 タリム・ン・ハンギン', 64, 21, null, array['SA3']),
  ('yasmine_214hp', 'yasmine', 'classic', 'special', '214強P', '↓↙←+強P', '強 タリム・ン・ハンギン', 65, 30, null, array['SA3']),
  ('yasmine_214odp', 'yasmine', 'classic', 'special', 'OD214PP', '↓↙←+PP', 'OD タリム・ン・ハンギン', 66, 20, null, array['SA2']),
  ('yasmine_236lk', 'yasmine', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 ムカ・ン・ランギット', 67, null, null, '{}'::text[]),
  ('yasmine_236mk', 'yasmine', 'classic', 'special', '236中K', '↓↘→+中K', '中 ムカ・ン・ランギット', 68, null, null, '{}'::text[]),
  ('yasmine_236hk', 'yasmine', 'classic', 'special', '236強K', '↓↘→+強K', '強 ムカ・ン・ランギット', 69, null, null, '{}'::text[]),
  ('yasmine_236odk', 'yasmine', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD ムカ・ン・ランギット', 70, null, null, '{}'::text[]),
  ('yasmine_ulan', 'yasmine', 'classic', 'special', 'ウラン', 'ムカ中P', 'ウラン', 71, 17, 3, '{}'::text[]),
  ('yasmine_ulan_od_from_n', 'yasmine', 'classic', 'special', 'ODウラン(通常から)', 'ムカ中PP', 'OD ウラン（通常ムカ派生）', 72, 17, 5, '{}'::text[]),
  ('yasmine_ulan_od_from_od', 'yasmine', 'classic', 'special', 'ODウラン(ODから)', 'ODムカ中P', 'OD ウラン（ODムカ派生）', 73, 17, 5, '{}'::text[]),
  ('yasmine_kulog', 'yasmine', 'classic', 'special', 'クロッグ', 'ムカ中K', 'クロッグ', 74, 17, 4, '{}'::text[]),
  ('yasmine_kulog_od_from_n', 'yasmine', 'classic', 'special', 'ODクロッグ(通常から)', 'ムカ中KK', 'OD クロッグ（通常ムカ派生）', 75, 17, 7, '{}'::text[]),
  ('yasmine_kulog_od_from_od', 'yasmine', 'classic', 'special', 'ODクロッグ(ODから)', 'ODムカ中K', 'OD クロッグ（ODムカ派生）', 76, 17, 7, '{}'::text[]),
  ('yasmine_623lk', 'yasmine', 'classic', 'special', '623弱K', '→↓↘+弱K', '弱 リパ・ン・アギラ', 77, 5, null, '{}'::text[]),
  ('yasmine_623mk', 'yasmine', 'classic', 'special', '623中K', '→↓↘+中K', '中 リパ・ン・アギラ', 78, 6, null, '{}'::text[]),
  ('yasmine_623hk', 'yasmine', 'classic', 'special', '623強K', '→↓↘+強K', '強 リパ・ン・アギラ', 79, 7, null, '{}'::text[]),
  ('yasmine_623odk', 'yasmine', 'classic', 'special', 'OD623KK', '→↓↘+KK', 'OD リパ・ン・アギラ', 80, 6, null, '{}'::text[]),
  ('yasmine_22lp', 'yasmine', 'classic', 'special', '22弱P', '↓↓+弱P', '弱 パンギル・サ・リクラン', 81, 25, 1, array['SA3']),
  ('yasmine_22mp', 'yasmine', 'classic', 'special', '22中P', '↓↓+中P', '中 パンギル・サ・リクラン', 82, 25, 1, array['SA3']),
  ('yasmine_22hp', 'yasmine', 'classic', 'special', '22強P', '↓↓+強P', '強 パンギル・サ・リクラン', 83, 25, 1, array['SA3']),
  ('yasmine_22od_lm', 'yasmine', 'classic', 'special', 'OD22弱中P', '↓↓+弱P中P', 'OD 弱 パンギル・サ・リクラン', 84, 25, 2, array['SA2']),
  ('yasmine_22od_lh', 'yasmine', 'classic', 'special', 'OD22弱強P', '↓↓+弱P強P', 'OD 中 パンギル・サ・リクラン', 85, 25, 2, array['SA2']),
  ('yasmine_22od_mh', 'yasmine', 'classic', 'special', 'OD22中強P', '↓↓+中P強P', 'OD 強 パンギル・サ・リクラン', 86, 25, 2, array['SA2']),
  ('yasmine_linya', 'yasmine', 'classic', 'special', '[SA2中]4KK', 'ナカタゴン中←+KK', 'リニャ・ン・リワナグ', 87, 22, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 3種: 90〜92、CA除外）
  ('yasmine_sa1', 'yasmine', 'classic', 'super', 'SA1', '↓↘→↓↘→+K', 'SA1 ヒワン・ン・カラヒタン', 90, 7, null, '{}'::text[]),
  ('yasmine_sa2', 'yasmine', 'classic', 'super', 'SA2', '↓↙←↓↙←+P', 'SA2 ナカタゴン・ラカス', 91, null, null, '{}'::text[]),
  ('yasmine_sa3', 'yasmine', 'classic', 'super', 'SA3', '↓↘→↓↘→+P', 'SA3 パムムカドカッド・ン・サンパギータ', 92, 10, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 2種: 95〜96）
  ('yasmine_throw_f', 'yasmine', 'classic', 'throw', '前投げ', '弱P+弱K', 'ピギル・ウロ（前投げ）', 95, 5, null, '{}'::text[]),
  ('yasmine_throw_b', 'yasmine', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'ヒラ・カマイ（後ろ投げ）', 96, 5, null, '{}'::text[]),

  -- 6. モダン通常技（10種: 110〜119）
  ('yasmine_m_5l', 'yasmine', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱K）', 110, 5, 2, array['C']),
  ('yasmine_m_5m', 'yasmine', 'modern', 'normal', '5中', '中', '立ち中（立ち中P）', 111, 6, 2, '{}'::text[]),
  ('yasmine_m_5h', 'yasmine', 'modern', 'normal', '5強', '強', '立ち強（立ち強K）', 112, 14, 1, '{}'::text[]),
  ('yasmine_m_2l', 'yasmine', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱P）', 113, 4, 4, array['C']),
  ('yasmine_m_2m', 'yasmine', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 114, 8, -1, array['C']),
  ('yasmine_m_2h', 'yasmine', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 115, 8, 2, array['C']),
  ('yasmine_m_3h', 'yasmine', 'modern', 'normal', '3強', '↘+強', '右下強（グンティング・ナ・パバサ）', 116, 10, null, '{}'::text[]),
  ('yasmine_m_jl', 'yasmine', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 117, 4, null, '{}'::text[]),
  ('yasmine_m_jm', 'yasmine', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 118, 7, null, '{}'::text[]),
  ('yasmine_m_jh', 'yasmine', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 119, 10, null, '{}'::text[]),

  -- 7. モダン特殊技・アシスト（16種: 125〜140）
  ('yasmine_m_auto_l', 'yasmine', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・しゃがみ弱K）', 125, 5, 2, '{}'::text[]),
  ('yasmine_m_auto_m', 'yasmine', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・しゃがみ中P）', 126, 6, 4, array['C']),
  ('yasmine_m_auto_h', 'yasmine', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち強P）', 127, 9, 2, array['C']),
  ('yasmine_m_j_auto_l', 'yasmine', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 128, 4, null, '{}'::text[]),
  ('yasmine_m_j_auto_m', 'yasmine', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 129, 7, null, '{}'::text[]),
  ('yasmine_m_j_auto_h', 'yasmine', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 130, 9, null, '{}'::text[]),
  ('yasmine_m_auto_l_combo', 'yasmine', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 131, 5, null, '{}'::text[]),
  ('yasmine_m_auto_2l_combo', 'yasmine', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 132, 4, null, '{}'::text[]),
  ('yasmine_m_auto_m_combo', 'yasmine', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 133, 6, null, '{}'::text[]),
  ('yasmine_m_auto_h_combo', 'yasmine', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 134, 9, null, '{}'::text[]),
  ('yasmine_m_2l_5l', 'yasmine', 'modern', 'unique', '2弱>弱', '↓+弱>弱', '連打キャンセル立ち弱P', 135, 5, 4, array['C']),
  ('yasmine_m_6m', 'yasmine', 'modern', 'unique', '6中', '→+中', 'ヒワン・パババ', 136, 22, 3, '{}'::text[]),
  ('yasmine_m_4h', 'yasmine', 'modern', 'unique', '4強', '←+強', 'ワリス・ナ・パバグサ', 137, 22, null, array['C']),
  ('yasmine_m_tc_2l_l_l', 'yasmine', 'modern', 'unique', '2弱>弱>弱', '↓+弱>弱>弱', 'キドラット・ナ・ヒワ', 138, 8, 1, array['C']),
  ('yasmine_m_tc_m_m', 'yasmine', 'modern', 'unique', '5中>中', '中>中', 'タッロング・ヒワ', 139, 12, null, array['C']),
  ('yasmine_m_tc_2m_m', 'yasmine', 'modern', 'unique', '2中>中', '↓+中>中', 'コンビナション・パムパバッグサ', 140, 8, null, '{}'::text[]),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（10種: 150〜159）
  ('yasmine_m_sp', 'yasmine', 'modern', 'special', 'N必', 'SP', '中 ダロイ・ン・トゥビグ（N必）', 150, 16, 1, array['SA3']),
  ('yasmine_m_od_sp', 'yasmine', 'modern', 'special', 'A+N必', 'A+SP', 'OD ダロイ・ン・トゥビグ（A+N必）', 151, 12, -2, array['SA2']),
  ('yasmine_m_4sp', 'yasmine', 'modern', 'special', '後必', '←+SP', '中 タリム・ン・ハンギン（後必）', 152, 21, null, array['SA3']),
  ('yasmine_m_od_4sp', 'yasmine', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD タリム・ン・ハンギン（A+後必）', 153, 20, null, array['SA2']),
  ('yasmine_m_1sp', 'yasmine', 'modern', 'special', '左下必', '↙+SP', '弱 ムカ・ン・ランギット（左下必）', 154, null, null, '{}'::text[]),
  ('yasmine_m_2sp', 'yasmine', 'modern', 'special', '下必', '↓+SP', '中 ムカ・ン・ランギット（下必）', 155, null, null, '{}'::text[]),
  ('yasmine_m_3sp', 'yasmine', 'modern', 'special', '右下必', '↘+SP', '強 ムカ・ン・ランギット（右下必）', 156, null, null, '{}'::text[]),
  ('yasmine_m_od_2sp', 'yasmine', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD ムカ・ン・ランギット（A+下必）', 157, null, null, '{}'::text[]),
  ('yasmine_m_6sp', 'yasmine', 'modern', 'special', '前必', '→+SP', '弱 リパ・ン・アギラ（前必）', 158, 5, null, '{}'::text[]),
  ('yasmine_m_od_6sp', 'yasmine', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD リパ・ン・アギラ（A+前必）', 159, 6, null, '{}'::text[]),

  -- 9. モダン必殺技：コマンド入力版＆派生技（34種: 165〜198）
  ('yasmine_m_236l', 'yasmine', 'modern', 'special', '236弱', '↓↘→+弱', '弱 ダロイ・ン・トゥビグ', 165, 12, 1, array['SA3']),
  ('yasmine_m_aron_l', 'yasmine', 'modern', 'special', '弱アロン', '弱ダロイ中→+攻撃', '弱 アロン', 166, 13, 1, array['SA3']),
  ('yasmine_m_aron_l_ex', 'yasmine', 'modern', 'special', '[強化]弱アロン', '[強化]弱ダロイ中→+攻撃', '[強化版]弱 アロン', 167, 16, null, array['SA3']),
  ('yasmine_m_236m', 'yasmine', 'modern', 'special', '236中', '↓↘→+中', '中 ダロイ・ン・トゥビグ', 168, 16, 1, array['SA3']),
  ('yasmine_m_aron_m', 'yasmine', 'modern', 'special', '中アロン', '中ダロイ中→+攻撃', '中 アロン', 169, 13, null, array['SA3']),
  ('yasmine_m_aron_m_ex', 'yasmine', 'modern', 'special', '[強化]中アロン', '[強化]中ダロイ中→+攻撃', '[強化版]中 アロン', 170, 22, null, array['SA3']),
  ('yasmine_m_236h', 'yasmine', 'modern', 'special', '236強', '↓↘→+強', '強 ダロイ・ン・トゥビグ', 171, 21, 3, array['SA3']),
  ('yasmine_m_aron_h', 'yasmine', 'modern', 'special', '強アロン', '強ダロイ中→+攻撃', '強 アロン', 172, 13, null, array['SA3']),
  ('yasmine_m_aron_h_ex', 'yasmine', 'modern', 'special', '[強化]強アロン', '[強化]強ダロイ中→+攻撃', '[強化版]強 アロン', 173, 22, null, array['SA3']),
  ('yasmine_m_236od', 'yasmine', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD ダロイ・ン・トゥビグ', 174, 12, -2, array['SA2']),
  ('yasmine_m_aron_od', 'yasmine', 'modern', 'special', 'ODアロン', 'ODダロイ中→+攻撃', 'OD アロン', 175, 13, null, array['SA2']),
  ('yasmine_m_aron_od_ex', 'yasmine', 'modern', 'special', '[強化]ODアロン', '[強化]ODダロイ中→+攻撃', '[強化版]OD アロン', 176, 56, null, array['SA2']),
  ('yasmine_m_aron_od_sa2', 'yasmine', 'modern', 'special', '[SA2中][強化]ODアロン', '[ナカタゴン中]ODダロイ中→+攻撃', '[ナカタゴン・ラカス中][強化版]OD アロン', 177, 47, null, '{}'::text[]),
  ('yasmine_m_214l', 'yasmine', 'modern', 'special', '214弱', '↓↙←+弱', '弱 タリム・ン・ハンギン', 178, null, null, '{}'::text[]),
  ('yasmine_m_214m', 'yasmine', 'modern', 'special', '214中', '↓↙←+中', '中 タリム・ン・ハンギン', 179, 21, null, array['SA3']),
  ('yasmine_m_214h', 'yasmine', 'modern', 'special', '214強', '↓↙←+強', '強 タリム・ン・ハンギン', 180, 30, null, array['SA3']),
  ('yasmine_m_214od', 'yasmine', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD タリム・ン・ハンギン', 181, 20, null, array['SA2']),
  ('yasmine_m_ulan', 'yasmine', 'modern', 'special', 'ウラン', 'ムカ中↓+攻撃', 'ウラン', 182, 17, 3, '{}'::text[]),
  ('yasmine_m_ulan_od_from_n', 'yasmine', 'modern', 'special', 'ODウラン(通常から)', 'ムカ中↓+攻撃×2', 'OD ウラン（通常ムカ派生）', 183, 17, 5, '{}'::text[]),
  ('yasmine_m_ulan_od_from_od', 'yasmine', 'modern', 'special', 'ODウラン(ODから)', 'ODムカ中↓+攻撃', 'OD ウラン（ODムカ派生）', 184, 17, 5, '{}'::text[]),
  ('yasmine_m_kulog', 'yasmine', 'modern', 'special', 'クロッグ', 'ムカ中攻撃', 'クロッグ', 185, 17, 4, '{}'::text[]),
  ('yasmine_m_kulog_od_from_n', 'yasmine', 'modern', 'special', 'ODクロッグ(通常から)', 'ムカ中攻撃×2', 'OD クロッグ（通常ムカ派生）', 186, 17, 7, '{}'::text[]),
  ('yasmine_m_kulog_od_from_od', 'yasmine', 'modern', 'special', 'ODクロッグ(ODから)', 'ODムカ中攻撃', 'OD クロッグ（ODムカ派生）', 187, 17, 7, '{}'::text[]),
  ('yasmine_m_623l', 'yasmine', 'modern', 'special', '623弱', '→↓↘+弱', '弱 リパ・ン・アギラ', 188, 5, null, '{}'::text[]),
  ('yasmine_m_623m', 'yasmine', 'modern', 'special', '623中', '→↓↘+中', '中 リパ・ン・アギラ', 189, 6, null, '{}'::text[]),
  ('yasmine_m_623h', 'yasmine', 'modern', 'special', '623強', '→↓↘+強', '強 リパ・ン・アギラ', 190, 7, null, '{}'::text[]),
  ('yasmine_m_623od', 'yasmine', 'modern', 'special', 'OD623', '→↓↘+攻撃×2', 'OD リパ・ン・アギラ', 191, 6, null, '{}'::text[]),
  ('yasmine_m_22l', 'yasmine', 'modern', 'special', '22弱', '↓↓+弱', '弱 パンギル・サ・リクラン', 192, 25, 1, array['SA3']),
  ('yasmine_m_22m', 'yasmine', 'modern', 'special', '22中', '↓↓+中', '中 パンギル・サ・リクラン', 193, 25, 1, array['SA3']),
  ('yasmine_m_22h', 'yasmine', 'modern', 'special', '22強', '↓↓+強', '強 パンギル・サ・リクラン', 194, 25, 1, array['SA3']),
  ('yasmine_m_22od_lm', 'yasmine', 'modern', 'special', 'OD22弱中', '↓↓+弱+中', 'OD 弱 パンギル・サ・リクラン', 195, 25, 2, array['SA2']),
  ('yasmine_m_22od_lh', 'yasmine', 'modern', 'special', 'OD22弱強', '↓↓+弱+強', 'OD 中 パンギル・サ・リクラン', 196, 25, 2, array['SA2']),
  ('yasmine_m_22od_mh', 'yasmine', 'modern', 'special', 'OD22中強', '↓↓+中+強', 'OD 強 パンギル・サ・リクラン', 197, 25, 2, array['SA2']),
  ('yasmine_m_linya', 'yasmine', 'modern', 'special', '[SA2中]4中強', 'ナカタゴン中←+中+強', 'リニャ・ン・リワナグ', 198, 22, null, '{}'::text[]),

  -- 10. モダンスーパーアーツ（3種: 205〜207、CA除外）
  ('yasmine_m_sa1', 'yasmine', 'modern', 'super', 'SA1', 'SP+強', 'SA1 ヒワン・ン・カラヒタン', 205, 7, null, '{}'::text[]),
  ('yasmine_m_sa2', 'yasmine', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 ナカタゴン・ラカス', 206, null, null, '{}'::text[]),
  ('yasmine_m_sa3', 'yasmine', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 パムムカドカッド・ン・サンパギータ', 207, 10, null, '{}'::text[]),

  -- 11. モダン通常投げ（2種: 210〜211）
  ('yasmine_m_throw_f', 'yasmine', 'modern', 'throw', '前投げ', '弱+中', 'ピギル・ウロ（前投げ）', 210, 5, null, '{}'::text[]),
  ('yasmine_m_throw_b', 'yasmine', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'ヒラ・カマイ（後ろ投げ）', 211, 5, null, '{}'::text[]),

  -- =========================================================================
  -- アルジュン（arjun）全127技（クラシック61種＋モダン66種）
  -- =========================================================================

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('arjun_5lp', 'arjun', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（ぶつ）', 10, 4, 4, array['C']),
  ('arjun_5lk', 'arjun', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（蹴る）', 11, 6, 1, array['C']),
  ('arjun_5mp', 'arjun', 'classic', 'normal', '5中P', '中P', '立ち中P（ぶん殴る）', 12, 11, 4, array['C']),
  ('arjun_5mk', 'arjun', 'classic', 'normal', '5中K', '中K', '立ち中K（引っ掛ける）', 13, 7, 2, array['C']),
  ('arjun_5hp', 'arjun', 'classic', 'normal', '5強P', '強P', '立ち強P（打ち砕く）', 14, 15, 2, '{}'::text[]),
  ('arjun_5hk', 'arjun', 'classic', 'normal', '5強K', '強K', '立ち強K（ぶっ飛ばす）', 15, 14, null, '{}'::text[]),
  ('arjun_2lp', 'arjun', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（小突く）', 20, 5, 5, array['C']),
  ('arjun_2lk', 'arjun', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（突く）', 21, 5, 2, '{}'::text[]),
  ('arjun_2mp', 'arjun', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（はらう）', 22, 9, null, '{}'::text[]),
  ('arjun_2mk', 'arjun', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（伸ばす）', 23, 8, 5, '{}'::text[]),
  ('arjun_2hp', 'arjun', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（かちあげる）', 24, 10, -1, array['C']),
  ('arjun_2hk', 'arjun', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（踏み潰す）', 25, 14, null, array['C']),
  ('arjun_jlp', 'arjun', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（打つ）', 30, 5, null, '{}'::text[]),
  ('arjun_jlk', 'arjun', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（踏む）', 31, 7, null, '{}'::text[]),
  ('arjun_jmp', 'arjun', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（すくい上げる）', 32, 8, null, '{}'::text[]),
  ('arjun_jmk', 'arjun', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（突き破る）', 33, 9, null, '{}'::text[]),
  ('arjun_jhp', 'arjun', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（振り回す）', 34, 10, null, '{}'::text[]),
  ('arjun_jhk', 'arjun', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（叩き壊す）', 35, 10, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 8種: 40〜47）
  ('arjun_6hp', 'arjun', 'classic', 'unique', '6強P', '→+強P', '仁義の一刀', 40, 22, null, '{}'::text[]),
  ('arjun_6hk', 'arjun', 'classic', 'unique', '6強K', '→+強K', '頑強な跳舞', 41, 19, null, '{}'::text[]),
  ('arjun_tc_mk_hk', 'arjun', 'classic', 'unique', '5中K>強K', '中K>強K', '規律の躍動', 42, 17, 3, array['SA']),
  ('arjun_tc_hp2', 'arjun', 'classic', 'unique', '5強P>強P', '強P>強P', '不敵の調べ', 43, 16, null, array['SA']),
  ('arjun_tc_hp3', 'arjun', 'classic', 'unique', '5強P>強P>強P', '強P>強P>強P', '鎮圧', 44, 18, null, array['SA3']),
  ('arjun_tc_hp2_hk', 'arjun', 'classic', 'unique', '5強P>強P>強K', '強P>強P>強K', '追跡', 45, null, null, '{}'::text[]),
  ('arjun_tc_hk_hp', 'arjun', 'classic', 'unique', '5強K>強P', '強K>強P', '無情の拳', 46, 24, null, array['C']),
  ('arjun_tc_hk_hp_hold', 'arjun', 'classic', 'unique', '5強K>強P(ホールド)', '強K>強Pホールド', '無情の拳（ホールド）', 47, 41, null, array['C']),

  -- 3. 必殺技（クラシック 30種: 50〜79）
  ('arjun_236lp', 'arjun', 'classic', 'special', '236弱P', '↓↘→+弱P', '弱 大義の巨腕', 50, 15, 2, array['SA3']),
  ('arjun_236mp', 'arjun', 'classic', 'special', '236中P', '↓↘→+中P', '中 大義の巨腕', 51, 20, 2, array['SA3']),
  ('arjun_236hp', 'arjun', 'classic', 'special', '236強P', '↓↘→+強P', '強 大義の巨腕', 52, 28, null, array['SA3']),
  ('arjun_236p_followup', 'arjun', 'classic', 'special', '追撃', '大義の巨腕中→+P', '追撃（大義の巨腕派生）', 53, 20, null, array['SA3']),
  ('arjun_236odp', 'arjun', 'classic', 'special', 'OD236PP', '↓↘→+PP', 'OD 大義の巨腕', 54, 23, null, array['SA2']),
  ('arjun_236odp_followup', 'arjun', 'classic', 'special', 'OD追撃', 'OD大義の巨腕中→+P', 'OD 追撃（OD大義の巨腕派生）', 55, 20, null, array['SA2']),
  ('arjun_623lp', 'arjun', 'classic', 'special', '623弱P', '→↓↘+弱P', '弱 厳酷な岩肩', 56, 19, null, array['SA3']),
  ('arjun_623mp', 'arjun', 'classic', 'special', '623中P', '→↓↘+中P', '中 厳酷な岩肩', 57, 23, null, array['SA3']),
  ('arjun_623hp', 'arjun', 'classic', 'special', '623強P', '→↓↘+強P', '強 厳酷な岩肩', 58, 28, null, array['SA3']),
  ('arjun_kajo', 'arjun', 'classic', 'special', '過剰な正義', '岩肩で岩接触自動派生', '過剰な正義', 59, 11, null, '{}'::text[]),
  ('arjun_623odp', 'arjun', 'classic', 'special', 'OD623PP', '→↓↘+PP', 'OD 厳酷な岩肩', 60, 22, null, array['SA3']),
  ('arjun_kajo_od', 'arjun', 'classic', 'special', 'OD過剰な正義', 'OD岩肩で岩接触自動派生', 'OD 過剰な正義', 61, 11, null, '{}'::text[]),
  ('arjun_236k', 'arjun', 'classic', 'special', '236K', '↓↘→+K', '息吹の円筒', 62, 17, null, array['SA3']),
  ('arjun_shinkan_l', 'arjun', 'classic', 'special', '弱息吹の震撼', '円筒中→+弱P', '弱 息吹の震撼', 63, 15, null, array['SA3']),
  ('arjun_shinkan_m', 'arjun', 'classic', 'special', '中息吹の震撼', '円筒中→+中P', '中 息吹の震撼', 64, 15, null, array['SA3']),
  ('arjun_shinkan_h', 'arjun', 'classic', 'special', '強息吹の震撼', '円筒中→+強P', '強 息吹の震撼', 65, 15, null, array['SA3']),
  ('arjun_236odk', 'arjun', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD 息吹の円筒', 66, 17, null, array['SA2']),
  ('arjun_shinkan_od_l', 'arjun', 'classic', 'special', 'OD弱息吹の震撼', 'OD円筒中→+弱P', 'OD 弱 息吹の震撼', 67, 15, null, array['SA2']),
  ('arjun_shinkan_od_m', 'arjun', 'classic', 'special', 'OD中息吹の震撼', 'OD円筒中→+中P', 'OD 中 息吹の震撼', 68, 15, null, array['SA2']),
  ('arjun_shinkan_od_h', 'arjun', 'classic', 'special', 'OD強息吹の震撼', 'OD円筒中→+強P', 'OD 強 息吹の震撼', 69, 15, null, array['SA2']),
  ('arjun_214lk', 'arjun', 'classic', 'special', '214弱K', '↓↙←+弱K', '弱 神気の巨巌', 70, 25, null, array['SA3']),
  ('arjun_214mk', 'arjun', 'classic', 'special', '214中K', '↓↙←+中K', '中 神気の巨巌', 71, 25, null, array['SA3']),
  ('arjun_214hk', 'arjun', 'classic', 'special', '214強K', '↓↙←+強K', '強 神気の巨巌', 72, 25, null, array['SA3']),
  ('arjun_214od_lm', 'arjun', 'classic', 'special', 'OD214弱中K', '↓↙←+弱K中K', 'OD 弱 神気の巨巌', 73, 20, null, array['SA2']),
  ('arjun_214od_lh', 'arjun', 'classic', 'special', 'OD214弱強K', '↓↙←+弱K強K', 'OD 中 神気の巨巌', 74, 20, null, array['SA2']),
  ('arjun_214od_mh', 'arjun', 'classic', 'special', 'OD214中強K', '↓↙←+中K強K', 'OD 強 神気の巨巌', 75, 20, null, array['SA2']),
  ('arjun_63214p', 'arjun', 'classic', 'special', '63214P', '→↘↓↙←+P', '鬼気迫る尋問', 76, 8, null, '{}'::text[]),
  ('arjun_63214odp', 'arjun', 'classic', 'special', 'OD63214PP', '→↘↓↙←+PP', 'OD 鬼気迫る尋問', 77, 26, null, '{}'::text[]),
  ('arjun_22hk', 'arjun', 'classic', 'special', '22強K', '↓↓+強K', '不撓の警衛', 78, 3, null, '{}'::text[]),
  ('arjun_rinri', 'arjun', 'classic', 'special', '倫理の崩壊', '警衛中P', '倫理の崩壊', 79, 28, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 3種: 85〜87、CA除外）
  ('arjun_sa1', 'arjun', 'classic', 'super', 'SA1', '↓↘→↓↘→+K', 'SA1 破壊の蛮声', 85, 8, null, '{}'::text[]),
  ('arjun_sa2', 'arjun', 'classic', 'super', 'SA2', '↓↙←↓↙←+P', 'SA2 忘却の一槌', 86, 9, null, '{}'::text[]),
  ('arjun_sa3', 'arjun', 'classic', 'super', 'SA3', '↓↘→↓↘→+P', 'SA3 秩序の鬼神', 87, 13, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 2種: 95〜96）
  ('arjun_throw_f', 'arjun', 'classic', 'throw', '前投げ', '弱P+弱K', '豪胆な制裁（前投げ）', 95, 5, null, '{}'::text[]),
  ('arjun_throw_b', 'arjun', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', '処罰の天秤（後ろ投げ）', 96, 5, null, '{}'::text[]),

  -- 6. モダン通常技（10種: 110〜119）
  ('arjun_m_5l', 'arjun', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 4, 4, array['C']),
  ('arjun_m_5m', 'arjun', 'modern', 'normal', '5中', '中', '立ち中（立ち中K）', 111, 7, 2, array['C']),
  ('arjun_m_5h', 'arjun', 'modern', 'normal', '5強', '強', '立ち強（立ち強K）', 112, 14, null, '{}'::text[]),
  ('arjun_m_2l', 'arjun', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱P）', 113, 5, 5, array['C']),
  ('arjun_m_2m', 'arjun', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中P）', 114, 9, null, '{}'::text[]),
  ('arjun_m_2h', 'arjun', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 115, 10, -1, array['C']),
  ('arjun_m_3h', 'arjun', 'modern', 'normal', '3強', '↘+強', '右下強（踏み潰す）', 116, 14, null, array['C']),
  ('arjun_m_jl', 'arjun', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 117, 5, null, '{}'::text[]),
  ('arjun_m_jm', 'arjun', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 118, 8, null, '{}'::text[]),
  ('arjun_m_jh', 'arjun', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 119, 10, null, '{}'::text[]),

  -- 7. モダン特殊技・アシスト（17種: 125〜141）
  ('arjun_m_auto_l', 'arjun', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・しゃがみ弱K）', 125, 5, 2, '{}'::text[]),
  ('arjun_m_auto_m', 'arjun', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・立ち中P）', 126, 11, 4, array['C']),
  ('arjun_m_auto_h', 'arjun', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち強P）', 127, 15, 2, '{}'::text[]),
  ('arjun_m_j_auto_l', 'arjun', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 128, 7, null, '{}'::text[]),
  ('arjun_m_j_auto_m', 'arjun', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 129, 9, null, '{}'::text[]),
  ('arjun_m_j_auto_h', 'arjun', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 130, 10, null, '{}'::text[]),
  ('arjun_m_auto_l_combo', 'arjun', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 131, 5, null, '{}'::text[]),
  ('arjun_m_auto_2l_combo', 'arjun', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 132, 5, null, '{}'::text[]),
  ('arjun_m_auto_m_combo', 'arjun', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 133, 11, null, '{}'::text[]),
  ('arjun_m_auto_h_combo', 'arjun', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 134, 15, null, '{}'::text[]),
  ('arjun_m_6h', 'arjun', 'modern', 'unique', '6強', '→+強', '仁義の一刀', 135, 22, null, '{}'::text[]),
  ('arjun_m_tc_m_m', 'arjun', 'modern', 'unique', '5中>中', '中>中', '規律の躍動', 136, 17, 3, array['SA']),
  ('arjun_m_tc_ah2', 'arjun', 'modern', 'unique', 'A強>A強', 'アシスト強>アシスト強', '不敵の調べ', 137, 16, null, array['SA']),
  ('arjun_m_tc_ah3', 'arjun', 'modern', 'unique', 'A強>A強>強', 'アシスト強>アシスト強>強', '鎮圧', 138, 18, null, array['SA3']),
  ('arjun_m_tc_ah2_6h', 'arjun', 'modern', 'unique', 'A強>A強>6強', 'アシスト強>アシスト強>→+強', '追跡', 139, null, null, '{}'::text[]),
  ('arjun_m_tc_h_h', 'arjun', 'modern', 'unique', '5強>強', '強>強', '無情の拳', 140, 24, null, array['C']),
  ('arjun_m_tc_h_h_hold', 'arjun', 'modern', 'unique', '5強>強(ホールド)', '強>強ホールド', '無情の拳（ホールド）', 141, 41, null, array['C']),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（12種: 150〜161）
  ('arjun_m_sp', 'arjun', 'modern', 'special', 'N必', 'SP', '弱 大義の巨腕（N必）', 150, 15, 2, array['SA3']),
  ('arjun_m_od_sp', 'arjun', 'modern', 'special', 'A+N必', 'A+SP', 'OD 大義の巨腕（A+N必）', 151, 23, null, array['SA2']),
  ('arjun_m_6sp', 'arjun', 'modern', 'special', '前必', '→+SP', '中 厳酷な岩肩（前必）', 152, 23, null, array['SA3']),
  ('arjun_m_od_6sp', 'arjun', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD 厳酷な岩肩（A+前必）', 153, 22, null, array['SA3']),
  ('arjun_m_4sp', 'arjun', 'modern', 'special', '後必', '←+SP', '息吹の円筒（後必）', 154, 17, null, array['SA3']),
  ('arjun_m_od_4sp', 'arjun', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD 息吹の円筒（A+後必）', 155, 17, null, array['SA2']),
  ('arjun_m_1sp', 'arjun', 'modern', 'special', '左下必', '↙+SP', '弱 神気の巨巌（左下必）', 156, 25, null, array['SA3']),
  ('arjun_m_2sp', 'arjun', 'modern', 'special', '下必', '↓+SP', '中 神気の巨巌（下必）', 157, 25, null, array['SA3']),
  ('arjun_m_3sp', 'arjun', 'modern', 'special', '右下必', '↘+SP', '強 神気の巨巌（右下必）', 158, 25, null, array['SA3']),
  ('arjun_m_od_1sp', 'arjun', 'modern', 'special', 'A+左下必', 'A+↙+SP', 'OD 弱 神気の巨巌（A+左下必）', 159, 20, null, array['SA2']),
  ('arjun_m_od_2sp', 'arjun', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD 中 神気の巨巌（A+下必）', 160, 20, null, array['SA2']),
  ('arjun_m_od_3sp', 'arjun', 'modern', 'special', 'A+右下必', 'A+↘+SP', 'OD 強 神気の巨巌（A+右下必）', 161, 20, null, array['SA2']),

  -- 9. モダン必殺技：コマンド入力版＆派生技（22種: 165〜186）
  ('arjun_m_236l', 'arjun', 'modern', 'special', '236弱', '↓↘→+弱', '弱 大義の巨腕', 165, 15, 2, array['SA3']),
  ('arjun_m_236m', 'arjun', 'modern', 'special', '236中', '↓↘→+中', '中 大義の巨腕', 166, 20, 2, array['SA3']),
  ('arjun_m_236h', 'arjun', 'modern', 'special', '236強', '↓↘→+強', '強 大義の巨腕', 167, 28, null, array['SA3']),
  ('arjun_m_236_followup', 'arjun', 'modern', 'special', '追撃', '大義の巨腕中→+攻撃', '追撃（大義の巨腕派生）', 168, 20, null, array['SA3']),
  ('arjun_m_236od', 'arjun', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD 大義の巨腕', 169, 23, null, array['SA2']),
  ('arjun_m_236od_followup', 'arjun', 'modern', 'special', 'OD追撃', 'OD大義の巨腕中→+攻撃', 'OD 追撃（OD大義の巨腕派生）', 170, 20, null, array['SA2']),
  ('arjun_m_623l', 'arjun', 'modern', 'special', '623弱', '→↓↘+弱', '弱 厳酷な岩肩', 171, 19, null, array['SA3']),
  ('arjun_m_623m', 'arjun', 'modern', 'special', '623中', '→↓↘+中', '中 厳酷な岩肩', 172, 23, null, array['SA3']),
  ('arjun_m_623h', 'arjun', 'modern', 'special', '623強', '→↓↘+強', '強 厳酷な岩肩', 173, 28, null, array['SA3']),
  ('arjun_m_kajo', 'arjun', 'modern', 'special', '過剰な正義', '岩肩で岩接触自動派生', '過剰な正義', 174, 11, null, '{}'::text[]),
  ('arjun_m_623od', 'arjun', 'modern', 'special', 'OD623', '→↓↘+攻撃×2', 'OD 厳酷な岩肩', 175, 22, null, array['SA3']),
  ('arjun_m_kajo_od', 'arjun', 'modern', 'special', 'OD過剰な正義', 'OD岩肩で岩接触自動派生', 'OD 過剰な正義', 176, 11, null, '{}'::text[]),
  ('arjun_m_shinkan_l', 'arjun', 'modern', 'special', '弱息吹の震撼', '円筒中→+弱/SP', '弱 息吹の震撼', 177, 15, null, array['SA3']),
  ('arjun_m_shinkan_m', 'arjun', 'modern', 'special', '中息吹の震撼', '円筒中→+中', '中 息吹の震撼', 178, 15, null, array['SA3']),
  ('arjun_m_shinkan_h', 'arjun', 'modern', 'special', '強息吹の震撼', '円筒中→+強', '強 息吹の震撼', 179, 15, null, array['SA3']),
  ('arjun_m_shinkan_od_l', 'arjun', 'modern', 'special', 'OD弱息吹の震撼', 'OD円筒中→+弱/SP', 'OD 弱 息吹の震撼', 180, 15, null, array['SA2']),
  ('arjun_m_shinkan_od_m', 'arjun', 'modern', 'special', 'OD中息吹の震撼', 'OD円筒中→+中', 'OD 中 息吹の震撼', 181, 15, null, array['SA2']),
  ('arjun_m_shinkan_od_h', 'arjun', 'modern', 'special', 'OD強息吹の震撼', 'OD円筒中→+強', 'OD 強 息吹の震撼', 182, 15, null, array['SA2']),
  ('arjun_m_63214', 'arjun', 'modern', 'special', '63214攻撃', '→↘↓↙←+攻撃', '鬼気迫る尋問', 183, 8, null, '{}'::text[]),
  ('arjun_m_63214od', 'arjun', 'modern', 'special', 'OD63214', '→↘↓↙←+攻撃×2', 'OD 鬼気迫る尋問', 184, 26, null, '{}'::text[]),
  ('arjun_m_22h', 'arjun', 'modern', 'special', '22強', '↓↓+強', '不撓の警衛', 185, 3, null, '{}'::text[]),
  ('arjun_m_rinri', 'arjun', 'modern', 'special', '倫理の崩壊', '警衛中攻撃', '倫理の崩壊', 186, 28, null, '{}'::text[]),

  -- 10. モダンスーパーアーツ（3種: 195〜197、CA除外）
  ('arjun_m_sa1', 'arjun', 'modern', 'super', 'SA1', 'SP+強', 'SA1 破壊の蛮声', 195, 8, null, '{}'::text[]),
  ('arjun_m_sa2', 'arjun', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 忘却の一槌', 196, 9, null, '{}'::text[]),
  ('arjun_m_sa3', 'arjun', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 秩序の鬼神', 197, 13, null, '{}'::text[]),

  -- 11. モダン通常投げ（2種: 205〜206）
  ('arjun_m_throw_f', 'arjun', 'modern', 'throw', '前投げ', '弱+中', '豪胆な制裁（前投げ）', 205, 5, null, '{}'::text[]),
  ('arjun_m_throw_b', 'arjun', 'modern', 'throw', '後ろ投げ', '←+弱+中', '処罰の天秤（後ろ投げ）', 206, 5, null, '{}'::text[])
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
