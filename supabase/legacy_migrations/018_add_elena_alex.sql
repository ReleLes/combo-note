-- =============================================================================
-- Migration: 018_add_elena_alex.sql
-- 目的: 21人目「エレナ（elena）」・22人目「アレックス（alex）」のキャラクターマスタおよび
--       全技マスタ（エレナ全141技＋アレックス全138技＝計279技・
--       公式フレームデータ＆コマンドリスト準拠・CA除外）を
--       既存の Supabase 本番 DB へ安全・冪等に UPSERT する
-- 前提: 001_add_throw_category.sql を先に適用済みであること
-- =============================================================================

-- 1. キャラクターマスタへエレナ・アレックスを追加・更新
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
  ('elena', 'elena', 'エレナ', 'Elena', 21, true, null, null, null),
  ('alex', 'alex', 'アレックス', 'Alex', 22, true, null, null, null)
on conflict (id) do update set
  slug = excluded.slug,
  name_ja = excluded.name_ja,
  name_en = excluded.name_en,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  stock_label = excluded.stock_label,
  stock_short_label = excluded.stock_short_label,
  stock_max_count = excluded.stock_max_count;

-- 2. エレナ・アレックス全技マスタ（計279技）を UPSERT
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
  -- エレナ（elena）全141技（クラシック69種＋モダン72種）
  -- =========================================================================

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('elena_5lp', 'elena', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（チークスパン）', 10, 5, 4, array['C']),
  ('elena_5lk', 'elena', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（スタンドロー）', 11, 5, 2, array['C']),
  ('elena_5mp', 'elena', 'classic', 'normal', '5中P', '中P', '立ち中P（ブレイズパーチ）', 12, 8, 3, array['SA']),
  ('elena_5mk', 'elena', 'classic', 'normal', '5中K', '中K', '立ち中K（スプルースベンド）', 13, 6, 5, array['C']),
  ('elena_5hp', 'elena', 'classic', 'normal', '5強P', '強P', '立ち強P（ラウンドホップ）', 14, 12, 2, '{}'::text[]),
  ('elena_5hk', 'elena', 'classic', 'normal', '5強K', '強K', '立ち強K（ラウンドステップ）', 15, 12, 2, '{}'::text[]),
  ('elena_2lp', 'elena', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（クラウチングフロント）', 20, 4, 5, array['C']),
  ('elena_2lk', 'elena', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（リトルラップ）', 21, 5, 3, '{}'::text[]),
  ('elena_2mp', 'elena', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（リングカッター）', 22, 8, 1, array['C']),
  ('elena_2mk', 'elena', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（サーフェスキック）', 23, 9, 4, '{}'::text[]),
  ('elena_2hp', 'elena', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（アカシアブランチ）', 24, 9, 6, array['C']),
  ('elena_2hk', 'elena', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（ルートブレイク）', 25, 11, null, '{}'::text[]),
  ('elena_jlp', 'elena', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（ニーアタック）', 30, 5, null, '{}'::text[]),
  ('elena_jlk', 'elena', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（ジャンプキック）', 31, 5, null, '{}'::text[]),
  ('elena_jmp', 'elena', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（クレストフラップ）', 32, 8, null, '{}'::text[]),
  ('elena_jmk', 'elena', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（ロージャベリン）', 33, 7, null, '{}'::text[]),
  ('elena_jhp', 'elena', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（ハイソバット）', 34, 10, null, '{}'::text[]),
  ('elena_jhk', 'elena', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（オーバーヘッドキック）', 35, 10, null, '{}'::text[]),

  -- 2. 特殊技（クラシック 13種: 40〜52）
  ('elena_3hk', 'elena', 'classic', 'unique', '3強K', '↘+強K', 'スライディング', 40, 14, null, '{}'::text[]),
  ('elena_4hk', 'elena', 'classic', 'unique', '4強K', '←+強K', 'ラウンドアーチ', 41, 14, 3, '{}'::text[]),
  ('elena_tc_mp_mp', 'elena', 'classic', 'unique', '5中P>中P', '中P>中P', 'スターリングビーク（2段目）', 42, 17, -4, array['C']),
  ('elena_6mk', 'elena', 'classic', 'unique', '6中K', '→+中K', 'ハンドスタンドウィップ（1段目）', 43, 20, 2, '{}'::text[]),
  ('elena_tc_6mk_mk', 'elena', 'classic', 'unique', '6中K>中K', '→+中K>中K', 'ハンドスタンドウィップ（2段目）', 44, 14, null, '{}'::text[]),
  ('elena_tc_mk_hk', 'elena', 'classic', 'unique', '5中K>強K', '中K>強K', 'ハインドキック（2段目）', 45, 12, null, array['C']),
  ('elena_tc_2mk_hk', 'elena', 'classic', 'unique', '2中K>強K', '↓+中K>強K', 'ラークフラッター（2段目）', 46, 15, 4, array['C']),
  ('elena_tc_hp_hp', 'elena', 'classic', 'unique', '5強P>強P', '強P>強P', 'ターニングテイル（2段目）', 47, 17, null, '{}'::text[]),
  ('elena_6hp', 'elena', 'classic', 'unique', '6強P', '→+強P', 'トランクスラップ（1段目）', 48, 16, 1, '{}'::text[]),
  ('elena_tc_6hp_2', 'elena', 'classic', 'unique', '6強P>強P', '→+強P>強P', 'トランクスラップ（2段目）', 49, 13, -2, '{}'::text[]),
  ('elena_tc_6hp_3', 'elena', 'classic', 'unique', '6強P>強P>強P', '→+強P>強P>強P', 'トランクスラップ（3段目）', 50, 7, null, '{}'::text[]),
  ('elena_j_lp_mk', 'elena', 'classic', 'unique', 'J弱P>中K', '空中で弱P>中K', 'ソアーレイド', 51, 6, null, '{}'::text[]),
  ('elena_j_mp_hp', 'elena', 'classic', 'unique', 'J中P>強P', '空中で中P>強P', 'ラプターレンジ', 52, 12, null, '{}'::text[]),

  -- 3. 必殺技（クラシック 32種: 55〜86）
  ('elena_236lk', 'elena', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 ライノホーン', 55, 13, null, array['SA3']),
  ('elena_236mk', 'elena', 'classic', 'special', '236中K', '↓↘→+中K', '中 ライノホーン', 56, 17, null, array['SA3']),
  ('elena_236hk', 'elena', 'classic', 'special', '236強K', '↓↘→+強K', '強 ライノホーン', 57, 21, null, array['SA3']),
  ('elena_236odk', 'elena', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD ライノホーン', 58, 11, null, array['SA2']),
  ('elena_623lk', 'elena', 'classic', 'special', '623弱K', '→↓↘+弱K', '弱 スクラッチホイール', 59, 5, null, '{}'::text[]),
  ('elena_623mk', 'elena', 'classic', 'special', '623中K', '→↓↘+中K', '中 スクラッチホイール', 60, 6, null, '{}'::text[]),
  ('elena_623hk', 'elena', 'classic', 'special', '623強K', '→↓↘+強K', '強 スクラッチホイール', 61, 7, null, '{}'::text[]),
  ('elena_623odk', 'elena', 'classic', 'special', 'OD623KK', '→↓↘+KK', 'OD スクラッチホイール', 62, 6, null, '{}'::text[]),
  ('elena_236lp', 'elena', 'classic', 'special', '236弱P', '↓↘→+弱P', '弱 リンクシング', 63, null, null, '{}'::text[]),
  ('elena_236mp', 'elena', 'classic', 'special', '236中P', '↓↘→+中P', '中 リンクシング', 64, null, null, '{}'::text[]),
  ('elena_236hp', 'elena', 'classic', 'special', '236強P', '↓↘→+強P', '強 リンクシング', 65, null, null, '{}'::text[]),
  ('elena_236odp', 'elena', 'classic', 'special', 'OD236PP', '↓↘→+PP', 'OD リンクシング', 66, null, null, '{}'::text[]),
  ('elena_leopard', 'elena', 'classic', 'special', 'レオパードスナップ', 'リンクシング中→+弱K', 'レオパードスナップ', 67, 10, null, array['SA3']),
  ('elena_leopard_ex', 'elena', 'classic', 'special', '[強化]レオパードスナップ', 'OD/スワール中→+弱K', '[強化版]レオパードスナップ', 68, 10, null, array['SA3']),
  ('elena_harvest', 'elena', 'classic', 'special', 'ハーベストサークル', 'リンクシング中→+中K', 'ハーベストサークル', 69, 8, null, '{}'::text[]),
  ('elena_harvest_ex', 'elena', 'classic', 'special', '[強化]ハーベストサークル', 'OD/スワール中→+中K', '[強化版]ハーベストサークル', 70, 8, null, '{}'::text[]),
  ('elena_mallet', 'elena', 'classic', 'special', 'マレットスマッシュ', 'リンクシング中→+強K', 'マレットスマッシュ', 71, 22, 2, '{}'::text[]),
  ('elena_mallet_ex', 'elena', 'classic', 'special', '[強化]マレットスマッシュ', 'OD/スワール中→+強K', '[強化版]マレットスマッシュ', 72, 22, 4, '{}'::text[]),
  ('elena_swirl_l', 'elena', 'classic', 'special', '弱リンクスワール', 'リンクシング/サイズ中→+弱P', '弱 リンクスワール', 73, null, null, '{}'::text[]),
  ('elena_swirl_m', 'elena', 'classic', 'special', '中リンクスワール', 'リンクシング/サイズ中→+中P', '中 リンクスワール', 74, null, null, '{}'::text[]),
  ('elena_swirl_h', 'elena', 'classic', 'special', '強リンクスワール', 'リンクシング/サイズ中→+強P', '強 リンクスワール', 75, null, null, '{}'::text[]),
  ('elena_swirl_od', 'elena', 'classic', 'special', 'ODリンクスワール', 'ODリンクシング中→+P', 'OD リンクスワール', 76, null, null, '{}'::text[]),
  ('elena_214lk', 'elena', 'classic', 'special', '214弱K', '↓↙←+弱K', '弱 スピンサイズ', 77, 15, null, array['SA3']),
  ('elena_214mk', 'elena', 'classic', 'special', '214中K', '↓↙←+中K', '中 スピンサイズ', 78, 20, null, array['SA3']),
  ('elena_214hk', 'elena', 'classic', 'special', '214強K', '↓↙←+強K', '強 スピンサイズ', 79, 24, null, array['SA3']),
  ('elena_214odk', 'elena', 'classic', 'special', 'OD214KK', '↓↙←+KK', 'OD スピンサイズ', 80, 18, null, array['SA2']),
  ('elena_214lp', 'elena', 'classic', 'special', '214弱P', '↓↙←+弱P', '弱 ムーングライド（1段目）', 81, 20, 1, array['SA3']),
  ('elena_214mp', 'elena', 'classic', 'special', '214中P', '↓↙←+中P', '中 ムーングライド（1段目）', 82, 24, 2, array['SA3']),
  ('elena_214hp', 'elena', 'classic', 'special', '214強P', '↓↙←+強P', '強 ムーングライド（1段目）', 83, 28, 2, array['SA3']),
  ('elena_moonglide_2', 'elena', 'classic', 'special', 'ムーングライド2段目', 'ムーングライド中→+P', 'ムーングライド（2段目）', 84, 16, null, array['SA3']),
  ('elena_214odp', 'elena', 'classic', 'special', 'OD214PP', '↓↙←+PP', 'OD ムーングライド（1段目）', 85, 23, 1, array['SA2']),
  ('elena_moonglide_od_2', 'elena', 'classic', 'special', 'ODムーングライド2段目', 'ODムーングライド中→+P', 'OD ムーングライド（2段目）', 86, 16, null, array['SA2']),

  -- 4. スーパーアーツ（クラシック 4種: 90〜93、SA2回復版含む・CA除外）
  ('elena_sa1', 'elena', 'classic', 'super', 'SA1', '↓↘→↓↘→+K', 'SA1 ミーティアボレー', 90, 7, null, '{}'::text[]),
  ('elena_sa2', 'elena', 'classic', 'super', 'SA2', '↓↘→↓↘→+P', 'SA2 リヴァイブダンス', 91, 12, null, '{}'::text[]),
  ('elena_sa2_heal', 'elena', 'classic', 'super', 'SA2(回復)', '↓↘→↓↘→+P(↓ホールド)', 'SA2 リヴァイブダンス（回復・↓ホールド）', 92, 12, null, '{}'::text[]),
  ('elena_sa3', 'elena', 'classic', 'super', 'SA3', '↓↙←↓↙←+K', 'SA3 グラスランドソング', 93, 8, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 2種: 95〜96）
  ('elena_throw_f', 'elena', 'classic', 'throw', '前投げ', '弱P+弱K', 'レッグスタック（前投げ）', 95, 5, null, '{}'::text[]),
  ('elena_throw_b', 'elena', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'レッグリフトスルー（後ろ投げ）', 96, 5, null, '{}'::text[]),

  -- 6. モダン通常技（10種: 110〜119）
  ('elena_m_5l', 'elena', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱K）', 110, 5, 2, array['C']),
  ('elena_m_5m', 'elena', 'modern', 'normal', '5中', '中', '立ち中（立ち中P）', 111, 8, 3, array['SA']),
  ('elena_m_5h', 'elena', 'modern', 'normal', '5強', '強', '立ち強（立ち強P）', 112, 12, 2, '{}'::text[]),
  ('elena_m_2l', 'elena', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱P）', 113, 4, 5, array['C']),
  ('elena_m_2m', 'elena', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 114, 9, 4, '{}'::text[]),
  ('elena_m_2h', 'elena', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 115, 9, 6, array['C']),
  ('elena_m_3h', 'elena', 'modern', 'normal', '3強', '↘+強', '右下強（ルートブレイク）', 116, 11, null, '{}'::text[]),
  ('elena_m_jl', 'elena', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 117, 5, null, '{}'::text[]),
  ('elena_m_jm', 'elena', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 118, 8, null, '{}'::text[]),
  ('elena_m_jh', 'elena', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 119, 10, null, '{}'::text[]),

  -- 7. モダン特殊技・アシスト（22種: 125〜146）
  ('elena_m_auto_l', 'elena', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・しゃがみ弱K）', 125, 5, 3, '{}'::text[]),
  ('elena_m_auto_m', 'elena', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・しゃがみ中P）', 126, 8, 1, array['C']),
  ('elena_m_auto_h', 'elena', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち中K）', 127, 6, 5, array['C']),
  ('elena_m_j_auto_l', 'elena', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 128, 5, null, '{}'::text[]),
  ('elena_m_j_auto_m', 'elena', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 129, 7, null, '{}'::text[]),
  ('elena_m_j_auto_h', 'elena', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 130, 10, null, '{}'::text[]),
  ('elena_m_auto_l_combo', 'elena', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 131, 5, null, '{}'::text[]),
  ('elena_m_auto_2l_combo', 'elena', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 132, 4, null, '{}'::text[]),
  ('elena_m_auto_m_combo', 'elena', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 133, 8, null, '{}'::text[]),
  ('elena_m_auto_h_combo', 'elena', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 134, 6, null, '{}'::text[]),
  ('elena_m_4h', 'elena', 'modern', 'unique', '4強', '←+強', 'ラウンドアーチ', 135, 14, 3, '{}'::text[]),
  ('elena_m_tc_m_m', 'elena', 'modern', 'unique', '5中>中', '中>中', 'スターリングビーク（2段目）', 136, 17, -4, array['C']),
  ('elena_m_6m', 'elena', 'modern', 'unique', '6中', '→+中', 'ハンドスタンドウィップ（1段目）', 137, 20, 2, '{}'::text[]),
  ('elena_m_tc_6m_m', 'elena', 'modern', 'unique', '6中>中', '→+中>中', 'ハンドスタンドウィップ（2段目）', 138, 14, null, '{}'::text[]),
  ('elena_m_tc_ah_h', 'elena', 'modern', 'unique', 'A強>強', 'アシスト強>強', 'ハインドキック（2段目）', 139, 12, null, array['C']),
  ('elena_m_tc_2m_m', 'elena', 'modern', 'unique', '2中>中', '↓+中>中', 'ラークフラッター（2段目）', 140, 15, 4, array['C']),
  ('elena_m_tc_h_h', 'elena', 'modern', 'unique', '5強>強', '強>強', 'ターニングテイル（2段目）', 141, 17, null, '{}'::text[]),
  ('elena_m_6h', 'elena', 'modern', 'unique', '6強', '→+強', 'トランクスラップ（1段目）', 142, 16, 1, '{}'::text[]),
  ('elena_m_tc_6h_2', 'elena', 'modern', 'unique', '6強>強', '→+強>強', 'トランクスラップ（2段目）', 143, 13, -2, '{}'::text[]),
  ('elena_m_tc_6h_3', 'elena', 'modern', 'unique', '6強>強>強', '→+強>強>強', 'トランクスラップ（3段目）', 144, 7, null, '{}'::text[]),
  ('elena_m_j_l_l', 'elena', 'modern', 'unique', 'J弱>弱', '空中で弱>弱', 'ソアーレイド', 145, 6, null, '{}'::text[]),
  ('elena_m_j_m_m', 'elena', 'modern', 'unique', 'J中>中', '空中で中>中', 'ラプターレンジ', 146, 12, null, '{}'::text[]),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（10種: 150〜159）
  ('elena_m_sp', 'elena', 'modern', 'special', 'N必', 'SP', '弱 ライノホーン（N必）', 150, 13, null, array['SA3']),
  ('elena_m_od_sp', 'elena', 'modern', 'special', 'A+N必', 'A+SP', 'OD ライノホーン（A+N必）', 151, 11, null, array['SA2']),
  ('elena_m_6sp', 'elena', 'modern', 'special', '前必', '→+SP', '中 スクラッチホイール（前必）', 152, 6, null, '{}'::text[]),
  ('elena_m_od_6sp', 'elena', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD スクラッチホイール（A+前必）', 153, 6, null, '{}'::text[]),
  ('elena_m_1sp', 'elena', 'modern', 'special', '左下必', '↙+SP', '弱 リンクシング（左下必）', 154, null, null, '{}'::text[]),
  ('elena_m_2sp', 'elena', 'modern', 'special', '下必', '↓+SP', '中 リンクシング（下必）', 155, null, null, '{}'::text[]),
  ('elena_m_3sp', 'elena', 'modern', 'special', '右下必', '↘+SP', '強 リンクシング（右下必）', 156, null, null, '{}'::text[]),
  ('elena_m_od_2sp', 'elena', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD リンクシング（A+下必）', 157, null, null, '{}'::text[]),
  ('elena_m_4sp', 'elena', 'modern', 'special', '後必', '←+SP', '弱 ムーングライド（1段目・後必）', 158, 20, 1, array['SA3']),
  ('elena_m_od_4sp', 'elena', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD ムーングライド（1段目・A+後必）', 159, 23, 1, array['SA2']),

  -- 9. モダン必殺技：コマンド入力版＆派生技（24種: 165〜188）
  ('elena_m_236l', 'elena', 'modern', 'special', '236弱', '↓↘→+弱', '弱 ライノホーン', 165, 13, null, array['SA3']),
  ('elena_m_236m', 'elena', 'modern', 'special', '236中', '↓↘→+中', '中 ライノホーン', 166, 17, null, array['SA3']),
  ('elena_m_236h', 'elena', 'modern', 'special', '236強', '↓↘→+強', '強 ライノホーン', 167, 21, null, array['SA3']),
  ('elena_m_236od', 'elena', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD ライノホーン', 168, 11, null, array['SA2']),
  ('elena_m_623l', 'elena', 'modern', 'special', '623弱', '→↓↘+弱', '弱 スクラッチホイール', 169, 5, null, '{}'::text[]),
  ('elena_m_623m', 'elena', 'modern', 'special', '623中', '→↓↘+中', '中 スクラッチホイール', 170, 6, null, '{}'::text[]),
  ('elena_m_623h', 'elena', 'modern', 'special', '623強', '→↓↘+強', '強 スクラッチホイール', 171, 7, null, '{}'::text[]),
  ('elena_m_623od', 'elena', 'modern', 'special', 'OD623', '→↓↘+攻撃×2', 'OD スクラッチホイール', 172, 6, null, '{}'::text[]),
  ('elena_m_leopard', 'elena', 'modern', 'special', 'レオパードスナップ', 'リンクシング中→+弱', 'レオパードスナップ', 173, 10, null, array['SA3']),
  ('elena_m_leopard_ex', 'elena', 'modern', 'special', '[強化]レオパードスナップ', 'OD/スワール中→+弱', '[強化版]レオパードスナップ', 174, 10, null, array['SA3']),
  ('elena_m_harvest', 'elena', 'modern', 'special', 'ハーベストサークル', 'リンクシング中→+中', 'ハーベストサークル', 175, 8, null, '{}'::text[]),
  ('elena_m_harvest_ex', 'elena', 'modern', 'special', '[強化]ハーベストサークル', 'OD/スワール中→+中', '[強化版]ハーベストサークル', 176, 8, null, '{}'::text[]),
  ('elena_m_mallet', 'elena', 'modern', 'special', 'マレットスマッシュ', 'リンクシング中→+強', 'マレットスマッシュ', 177, 22, 2, '{}'::text[]),
  ('elena_m_mallet_ex', 'elena', 'modern', 'special', '[強化]マレットスマッシュ', 'OD/スワール中→+強', '[強化版]マレットスマッシュ', 178, 22, 4, '{}'::text[]),
  ('elena_m_swirl_l', 'elena', 'modern', 'special', '弱リンクスワール', 'リンクシング/サイズ中↙+SP', '弱 リンクスワール', 179, null, null, '{}'::text[]),
  ('elena_m_swirl_m', 'elena', 'modern', 'special', '中リンクスワール', 'リンクシング/サイズ中↓+SP', '中 リンクスワール', 180, null, null, '{}'::text[]),
  ('elena_m_swirl_h', 'elena', 'modern', 'special', '強リンクスワール', 'リンクシング/サイズ中↘+SP', '強 リンクスワール', 181, null, null, '{}'::text[]),
  ('elena_m_swirl_od', 'elena', 'modern', 'special', 'ODリンクスワール', 'ODリンクシング中↓+SP', 'OD リンクスワール', 182, null, null, '{}'::text[]),
  ('elena_m_214l', 'elena', 'modern', 'special', '214弱', '↓↙←+弱', '弱 スピンサイズ', 183, 15, null, array['SA3']),
  ('elena_m_214m', 'elena', 'modern', 'special', '214中', '↓↙←+中', '中 スピンサイズ', 184, 20, null, array['SA3']),
  ('elena_m_214h', 'elena', 'modern', 'special', '214強', '↓↙←+強', '強 スピンサイズ', 185, 24, null, array['SA3']),
  ('elena_m_214od', 'elena', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD スピンサイズ', 186, 18, null, array['SA2']),
  ('elena_m_moonglide_2', 'elena', 'modern', 'special', 'ムーングライド2段目', 'ムーングライド中→+攻撃', 'ムーングライド（2段目）', 187, 16, null, array['SA3']),
  ('elena_m_moonglide_od_2', 'elena', 'modern', 'special', 'ODムーングライド2段目', 'ODムーングライド中→+攻撃', 'OD ムーングライド（2段目）', 188, 16, null, array['SA2']),

  -- 10. モダンスーパーアーツ（4種: 195〜198、SA2回復版含む・CA除外）
  ('elena_m_sa1', 'elena', 'modern', 'super', 'SA1', 'SP+強', 'SA1 ミーティアボレー', 195, 7, null, '{}'::text[]),
  ('elena_m_sa2', 'elena', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 リヴァイブダンス', 196, 12, null, '{}'::text[]),
  ('elena_m_sa2_heal', 'elena', 'modern', 'super', 'SA2(回復)', '←+SP+強(↓ホールド)', 'SA2 リヴァイブダンス（回復・↓ホールド）', 197, 12, null, '{}'::text[]),
  ('elena_m_sa3', 'elena', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 グラスランドソング', 198, 8, null, '{}'::text[]),

  -- 11. モダン通常投げ（2種: 205〜206）
  ('elena_m_throw_f', 'elena', 'modern', 'throw', '前投げ', '弱+中', 'レッグスタック（前投げ）', 205, 5, null, '{}'::text[]),
  ('elena_m_throw_b', 'elena', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'レッグリフトスルー（後ろ投げ）', 206, 5, null, '{}'::text[]),

  -- =========================================================================
  -- アレックス（alex）全138技（クラシック63種＋モダン75種）
  -- =========================================================================

  -- 1. 通常技（クラシック 18種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜35）
  ('alex_5lp', 'alex', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（クイックジャブ）', 10, 4, 5, array['C']),
  ('alex_5lk', 'alex', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（ローキック）', 11, 6, 1, array['C']),
  ('alex_5mp', 'alex', 'classic', 'normal', '5中P', '中P', '立ち中P（ボディーブロー）', 12, 7, 4, array['C']),
  ('alex_5mk', 'alex', 'classic', 'normal', '5中K', '中K', '立ち中K（ミドルキック）', 13, 9, 3, '{}'::text[]),
  ('alex_5hp', 'alex', 'classic', 'normal', '5強P', '強P', '立ち強P（フェイスクラッシャー）', 14, 12, 4, array['SA']),
  ('alex_5hk', 'alex', 'classic', 'normal', '5強K', '強K', '立ち強K（ロングキック）', 15, 16, 1, '{}'::text[]),
  ('alex_2lp', 'alex', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（ロークロー）', 20, 5, 5, array['C']),
  ('alex_2lk', 'alex', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（グランドロー）', 21, 5, 2, '{}'::text[]),
  ('alex_2mp', 'alex', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（地獄突き）', 22, 8, 1, array['C']),
  ('alex_2mk', 'alex', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（シンキック）', 23, 8, 5, '{}'::text[]),
  ('alex_2hp', 'alex', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（ビッグスワイプ）', 24, 9, -3, array['C']),
  ('alex_2hk', 'alex', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（ラウンドキック）', 25, 10, null, '{}'::text[]),
  ('alex_jlp', 'alex', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（ハイジャブ）', 30, 5, null, '{}'::text[]),
  ('alex_jlk', 'alex', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（フライングニー）', 31, 6, null, '{}'::text[]),
  ('alex_jmp', 'alex', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（フライングニーチョップ）', 32, 7, null, '{}'::text[]),
  ('alex_jmk', 'alex', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（ニールキック）', 33, 8, null, '{}'::text[]),
  ('alex_jhp', 'alex', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（スカイハンマー）', 34, 9, null, '{}'::text[]),
  ('alex_jhk', 'alex', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（ドロップキック）', 35, 10, null, '{}'::text[]),

  -- 2. 特殊技＆ブレイカー・スタンス派生（クラシック 23種: 40〜62）
  ('alex_5hp_hold', 'alex', 'classic', 'unique', '5強P(ホールド)', '強Pホールド', '立ち強P（フェイスクラッシャー・ホールド）', 40, 23, 5, array['C']),
  ('alex_5hk_hold', 'alex', 'classic', 'unique', '5強K(ホールド)', '強Kホールド', '立ち強K（ロングキック・ホールド）', 41, 25, null, '{}'::text[]),
  ('alex_breaker', 'alex', 'classic', 'unique', 'ブレイカー・スタンス', '↓+PP', 'ブレイカー・スタンス', 42, null, null, '{}'::text[]),
  ('alex_breaker_step_in', 'alex', 'classic', 'unique', 'ステップイン', '構え中→', 'ステップイン', 43, null, null, '{}'::text[]),
  ('alex_breaker_step_out', 'alex', 'classic', 'unique', 'ステップアウト', '構え中←', 'ステップアウト', 44, null, null, '{}'::text[]),
  ('alex_slash_l', 'alex', 'classic', 'unique', '弱スラッシュエルボー', '構え/ステップ中→+弱P', '弱 スラッシュエルボー', 45, 12, 3, '{}'::text[]),
  ('alex_slash_m', 'alex', 'classic', 'unique', '中スラッシュエルボー', '構え/ステップ中→+中P', '中 スラッシュエルボー', 46, 15, 3, '{}'::text[]),
  ('alex_slash_h', 'alex', 'classic', 'unique', '強スラッシュエルボー', '構え/ステップ中→+強P', '強 スラッシュエルボー', 47, 18, 3, '{}'::text[]),
  ('alex_breaker_lp', 'alex', 'classic', 'unique', 'パームコンタクト', '構え中弱P', 'パームコンタクト', 48, 4, 7, array['C']),
  ('alex_breaker_mp', 'alex', 'classic', 'unique', 'ショルダーランチャー', '構え中中P', 'ショルダーランチャー', 49, 7, null, '{}'::text[]),
  ('alex_breaker_hp', 'alex', 'classic', 'unique', 'ヘビーラリアット', '構え中強P', 'ヘビーラリアット', 50, 12, 6, '{}'::text[]),
  ('alex_breaker_hp_hold', 'alex', 'classic', 'unique', 'ヘビーラリアット(ホールド)', '構え中強Pホールド', 'ヘビーラリアット（ホールド）', 51, 21, 6, '{}'::text[]),
  ('alex_breaker_lk', 'alex', 'classic', 'unique', 'タクティカルリープ', '構え中弱K', 'タクティカルリープ', 52, null, null, '{}'::text[]),
  ('alex_breaker_mk', 'alex', 'classic', 'unique', 'エアスタンピート', '構え中中K', 'エアスタンピート', 53, 30, null, '{}'::text[]),
  ('alex_breaker_hk1', 'alex', 'classic', 'unique', 'スイープコンビ(1段目)', '構え中強K', 'スイープコンビネーション（1段目）', 54, 11, null, '{}'::text[]),
  ('alex_breaker_hk2', 'alex', 'classic', 'unique', 'スイープコンビ(2段目)', '構え中強K>強K', 'スイープコンビネーション（2段目）', 55, 11, null, '{}'::text[]),
  ('alex_breaker_throw', 'alex', 'classic', 'unique', 'ハイパーリフト', '構え中弱P+弱K', 'ハイパーリフト', 56, 5, null, '{}'::text[]),
  ('alex_breaker_2throw', 'alex', 'classic', 'unique', 'デンジャラスアプローチ', '構え中↓+弱P+弱K', 'デンジャラスアプローチ', 57, 21, null, '{}'::text[]),
  ('alex_6mp', 'alex', 'classic', 'unique', '6中P', '→+中P', 'チョップ', 58, 22, 3, '{}'::text[]),
  ('alex_4mk', 'alex', 'classic', 'unique', '4中K', '←+中K', 'オブリークスタンプ', 59, 7, 5, '{}'::text[]),
  ('alex_j2hp', 'alex', 'classic', 'unique', '前J2強P', '前ジャンプ中↓+強P', 'フライングクロスチョップ', 60, 21, null, '{}'::text[]),
  ('alex_tc_mp_hp', 'alex', 'classic', 'unique', '5中P>強P', '中P>強P', 'パームストライク', 61, 15, null, '{}'::text[]),
  ('alex_tc_2lk_2hk', 'alex', 'classic', 'unique', '2弱K>2強K', '↓+弱K>↓+強K', 'ツイストドロップ', 62, 15, null, '{}'::text[]),

  -- 3. 必殺技（クラシック 15種: 65〜79）
  ('alex_236lp', 'alex', 'classic', 'special', '236弱P', '↓↘→+弱P', '弱 フラッシュアックス', 65, 13, 3, array['SA3']),
  ('alex_236mp', 'alex', 'classic', 'special', '236中P', '↓↘→+中P', '中 フラッシュアックス', 66, 17, null, array['SA3']),
  ('alex_236hp', 'alex', 'classic', 'special', '236強P', '↓↘→+強P', 'フラッシュチョップ', 67, 26, 5, array['SA3']),
  ('alex_236odp', 'alex', 'classic', 'special', 'OD236PP', '↓↘→+PP', 'OD フラッシュチョップ', 68, 15, null, array['SA2']),
  ('alex_623lk', 'alex', 'classic', 'special', '623弱K', '→↓↘+弱K', '弱 エアニースマッシュ', 69, 6, null, '{}'::text[]),
  ('alex_623mk', 'alex', 'classic', 'special', '623中K', '→↓↘+中K', '中 エアニースマッシュ', 70, 8, null, '{}'::text[]),
  ('alex_623hk', 'alex', 'classic', 'special', '623強K', '→↓↘+強K', '強 エアニースマッシュ', 71, 14, null, '{}'::text[]),
  ('alex_623odk', 'alex', 'classic', 'special', 'OD623KK', '→↓↘+KK', 'OD エアニースマッシュ', 72, 10, null, '{}'::text[]),
  ('alex_63214lp', 'alex', 'classic', 'special', '63214弱P', '→↘↓↙←+弱P', '弱 パワーボム', 73, 9, null, '{}'::text[]),
  ('alex_63214mp', 'alex', 'classic', 'special', '63214中P', '→↘↓↙←+中P', '中 パワーボム', 74, 7, null, '{}'::text[]),
  ('alex_63214hp', 'alex', 'classic', 'special', '63214強P', '→↘↓↙←+強P', '強 パワーボム', 75, 5, null, '{}'::text[]),
  ('alex_63214odp', 'alex', 'classic', 'special', 'OD63214PP', '→↘↓↙←+PP', 'OD パワーボム', 76, 5, null, '{}'::text[]),
  ('alex_powerdrop', 'alex', 'classic', 'special', '[背面]63214P', '背面から→↘↓↙←+P', 'パワードロップ（背面）', 77, 5, null, '{}'::text[]),
  ('alex_powerdrop_od', 'alex', 'classic', 'special', '[背面]OD63214PP', '背面から→↘↓↙←+PP', 'OD パワードロップ（背面）', 78, 5, null, '{}'::text[]),
  ('alex_hyperbomb', 'alex', 'classic', 'special', 'ハイパーボム', 'ODパワードロップ中→', 'ハイパーボム', 79, null, null, '{}'::text[]),

  -- 4. スーパーアーツ（クラシック 4種: 85〜88、オメガウィングバスター含む・CA除外）
  ('alex_sa1', 'alex', 'classic', 'super', 'SA1', '↓↘→↓↘→+K', 'SA1 レイジングスピアー', 85, 9, null, '{}'::text[]),
  ('alex_sa2', 'alex', 'classic', 'super', 'SA2', '↓↙←↓↙←+P', 'SA2 スレッジクロスハンマー', 86, 13, null, '{}'::text[]),
  ('alex_sa2_omega', 'alex', 'classic', 'super', 'SA2(オメガウィング)', 'ODパワードロップ中PP', 'SA2 オメガウィングバスター', 87, null, null, '{}'::text[]),
  ('alex_sa3', 'alex', 'classic', 'super', 'SA3', '↓↘→↓↘→+P', 'SA3 ファイナルキャプチュード', 88, 12, null, '{}'::text[]),

  -- 5. 通常投げ（クラシック 3種: 95〜97）
  ('alex_throw_f', 'alex', 'classic', 'throw', '前投げ', '弱P+弱K', 'アームロック（前投げ）', 95, 5, null, '{}'::text[]),
  ('alex_throw_b', 'alex', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'ギロチンハンマー（後ろ投げ）', 96, 5, null, '{}'::text[]),
  ('alex_throw_2', 'alex', 'classic', 'throw', '下投げ', '↓+弱P+弱K', 'イリーガルキック（下投げ）', 97, 5, null, '{}'::text[]),

  -- 6. モダン通常技（10種: 110〜119）
  ('alex_m_5l', 'alex', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 110, 4, 5, array['C']),
  ('alex_m_5m', 'alex', 'modern', 'normal', '5中', '中', '立ち中（立ち中P）', 111, 7, 4, array['C']),
  ('alex_m_5h', 'alex', 'modern', 'normal', '5強', '強', '立ち強（立ち強K）', 112, 16, 1, '{}'::text[]),
  ('alex_m_2l', 'alex', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱K）', 113, 5, 2, '{}'::text[]),
  ('alex_m_2m', 'alex', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 114, 8, 5, '{}'::text[]),
  ('alex_m_2h', 'alex', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 115, 9, -3, array['C']),
  ('alex_m_3h', 'alex', 'modern', 'normal', '3強', '↘+強', '右下強（ラウンドキック）', 116, 10, null, '{}'::text[]),
  ('alex_m_jl', 'alex', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 117, 5, null, '{}'::text[]),
  ('alex_m_jm', 'alex', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 118, 7, null, '{}'::text[]),
  ('alex_m_jh', 'alex', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 119, 10, null, '{}'::text[]),

  -- 7. モダン特殊技・アシスト・ブレイカー・スタンス派生（34種: 125〜158）
  ('alex_m_auto_l', 'alex', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・立ち弱K）', 125, 6, 1, array['C']),
  ('alex_m_auto_m', 'alex', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・しゃがみ中P）', 126, 8, 1, array['C']),
  ('alex_m_auto_h', 'alex', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち強P）', 127, 12, 4, array['SA']),
  ('alex_m_j_auto_l', 'alex', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 128, 6, null, '{}'::text[]),
  ('alex_m_j_auto_m', 'alex', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 129, 8, null, '{}'::text[]),
  ('alex_m_j_auto_h', 'alex', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 130, 9, null, '{}'::text[]),
  ('alex_m_auto_l_combo', 'alex', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 131, 6, null, '{}'::text[]),
  ('alex_m_auto_2l_combo', 'alex', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 132, 5, null, '{}'::text[]),
  ('alex_m_auto_m_combo', 'alex', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 133, 8, null, '{}'::text[]),
  ('alex_m_auto_h_combo', 'alex', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 134, 12, null, '{}'::text[]),
  ('alex_m_2l_2l', 'alex', 'modern', 'unique', '2弱>2弱', '↓+弱>↓+弱', '連打キャンセルしゃがみ弱P（ロークロー）', 135, 5, 5, array['C']),
  ('alex_m_ah_hold', 'alex', 'modern', 'unique', 'A強(ホールド)', 'アシスト強ホールド', '立ち強P（フェイスクラッシャー・ホールド）', 136, 23, 5, array['C']),
  ('alex_m_5h_hold', 'alex', 'modern', 'unique', '5強(ホールド)', '強ホールド', '立ち強K（ロングキック・ホールド）', 137, 25, null, '{}'::text[]),
  ('alex_m_breaker', 'alex', 'modern', 'unique', 'ブレイカー・スタンス', '↓+中+強', 'ブレイカー・スタンス', 138, null, null, '{}'::text[]),
  ('alex_m_breaker_step_in', 'alex', 'modern', 'unique', 'ステップイン', '構え中→', 'ステップイン', 139, null, null, '{}'::text[]),
  ('alex_m_breaker_step_out', 'alex', 'modern', 'unique', 'ステップアウト', '構え中←', 'ステップアウト', 140, null, null, '{}'::text[]),
  ('alex_m_slash_l', 'alex', 'modern', 'unique', '弱スラッシュエルボー', '構え/ステップ中→+弱', '弱 スラッシュエルボー', 141, 12, 3, '{}'::text[]),
  ('alex_m_slash_m', 'alex', 'modern', 'unique', '中スラッシュエルボー', '構え/ステップ中→+中', '中 スラッシュエルボー', 142, 15, 3, '{}'::text[]),
  ('alex_m_slash_h', 'alex', 'modern', 'unique', '強スラッシュエルボー', '構え/ステップ中→+強', '強 スラッシュエルボー', 143, 18, 3, '{}'::text[]),
  ('alex_m_breaker_l', 'alex', 'modern', 'unique', 'パームコンタクト', '構え中弱', 'パームコンタクト', 144, 4, 7, array['C']),
  ('alex_m_breaker_m', 'alex', 'modern', 'unique', 'ショルダーランチャー', '構え中中', 'ショルダーランチャー', 145, 7, null, '{}'::text[]),
  ('alex_m_breaker_h', 'alex', 'modern', 'unique', 'ヘビーラリアット', '構え中強', 'ヘビーラリアット', 146, 12, 6, '{}'::text[]),
  ('alex_m_breaker_h_hold', 'alex', 'modern', 'unique', 'ヘビーラリアット(ホールド)', '構え中強ホールド', 'ヘビーラリアット（ホールド）', 147, 21, 6, '{}'::text[]),
  ('alex_m_breaker_2l', 'alex', 'modern', 'unique', 'タクティカルリープ', '構え中↓+弱', 'タクティカルリープ', 148, null, null, '{}'::text[]),
  ('alex_m_breaker_2m', 'alex', 'modern', 'unique', 'エアスタンピート', '構え中↓+中', 'エアスタンピート', 149, 30, null, '{}'::text[]),
  ('alex_m_breaker_2h1', 'alex', 'modern', 'unique', 'スイープコンビ(1段目)', '構え中↓+強', 'スイープコンビネーション（1段目）', 150, 11, null, '{}'::text[]),
  ('alex_m_breaker_2h2', 'alex', 'modern', 'unique', 'スイープコンビ(2段目)', '構え中↓+強>↓+強', 'スイープコンビネーション（2段目）', 151, 11, null, '{}'::text[]),
  ('alex_m_breaker_throw', 'alex', 'modern', 'unique', 'ハイパーリフト', '構え中弱+中', 'ハイパーリフト', 152, 5, null, '{}'::text[]),
  ('alex_m_breaker_2throw', 'alex', 'modern', 'unique', 'デンジャラスアプローチ', '構え中↓+弱+中', 'デンジャラスアプローチ', 153, 21, null, '{}'::text[]),
  ('alex_m_6m', 'alex', 'modern', 'unique', '6中', '→+中', 'チョップ', 154, 22, 3, '{}'::text[]),
  ('alex_m_4m', 'alex', 'modern', 'unique', '4中', '←+中', 'オブリークスタンプ', 155, 7, 5, '{}'::text[]),
  ('alex_m_j2h', 'alex', 'modern', 'unique', '前J2強', '前ジャンプ中↓+強', 'フライングクロスチョップ', 156, 21, null, '{}'::text[]),
  ('alex_m_tc_m_m', 'alex', 'modern', 'unique', '5中>中', '中>中', 'パームストライク', 157, 15, null, '{}'::text[]),
  ('alex_m_tc_2l_2h', 'alex', 'modern', 'unique', '2弱>2強', '↓+弱>↓+強', 'ツイストドロップ', 158, 15, null, '{}'::text[]),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（9種: 165〜173）
  ('alex_m_sp', 'alex', 'modern', 'special', 'N必', 'SP', '中 フラッシュアックス（N必）', 165, 17, null, array['SA3']),
  ('alex_m_od_sp', 'alex', 'modern', 'special', 'A+N必', 'A+SP', 'OD フラッシュチョップ（A+N必）', 166, 15, null, array['SA2']),
  ('alex_m_6sp', 'alex', 'modern', 'special', '前必', '→+SP', '弱 エアニースマッシュ（前必）', 167, 6, null, '{}'::text[]),
  ('alex_m_2sp', 'alex', 'modern', 'special', '下必', '↓+SP', '強 エアニースマッシュ（下必）', 168, 14, null, '{}'::text[]),
  ('alex_m_od_6sp', 'alex', 'modern', 'special', 'A+前/下必', 'A+→or↓+SP', 'OD エアニースマッシュ（A+前/下必）', 169, 10, null, '{}'::text[]),
  ('alex_m_4sp', 'alex', 'modern', 'special', '後必', '←+SP', '中 パワーボム（後必）', 170, 7, null, '{}'::text[]),
  ('alex_m_od_4sp', 'alex', 'modern', 'special', 'A+後必', 'A+←+SP', 'OD パワーボム（A+後必）', 171, 5, null, '{}'::text[]),
  ('alex_m_4sp_drop', 'alex', 'modern', 'special', '[背面]後必', '背面から←+SP', 'パワードロップ（背面・後必）', 172, 5, null, '{}'::text[]),
  ('alex_m_od_4sp_drop', 'alex', 'modern', 'special', '[背面]A+後必', '背面からA+←+SP', 'OD パワードロップ（背面・A+後必）', 173, 5, null, '{}'::text[]),

  -- 9. モダン必殺技：コマンド入力版＆派生技（15種: 175〜189）
  ('alex_m_236l', 'alex', 'modern', 'special', '236弱', '↓↘→+弱', '弱 フラッシュアックス', 175, 13, 3, array['SA3']),
  ('alex_m_236m', 'alex', 'modern', 'special', '236中', '↓↘→+中', '中 フラッシュアックス', 176, 17, null, array['SA3']),
  ('alex_m_236h', 'alex', 'modern', 'special', '236強', '↓↘→+強', 'フラッシュチョップ', 177, 26, 5, array['SA3']),
  ('alex_m_236od', 'alex', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD フラッシュチョップ', 178, 15, null, array['SA2']),
  ('alex_m_623l', 'alex', 'modern', 'special', '623弱', '→↓↘+弱', '弱 エアニースマッシュ', 179, 6, null, '{}'::text[]),
  ('alex_m_623m', 'alex', 'modern', 'special', '623中', '→↓↘+中', '中 エアニースマッシュ', 180, 8, null, '{}'::text[]),
  ('alex_m_623h', 'alex', 'modern', 'special', '623強', '→↓↘+強', '強 エアニースマッシュ', 181, 14, null, '{}'::text[]),
  ('alex_m_623od', 'alex', 'modern', 'special', 'OD623', '→↓↘+攻撃×2', 'OD エアニースマッシュ', 182, 10, null, '{}'::text[]),
  ('alex_m_63214l', 'alex', 'modern', 'special', '63214弱', '→↘↓↙←+弱', '弱 パワーボム', 183, 9, null, '{}'::text[]),
  ('alex_m_63214m', 'alex', 'modern', 'special', '63214中', '→↘↓↙←+中', '中 パワーボム', 184, 7, null, '{}'::text[]),
  ('alex_m_63214h', 'alex', 'modern', 'special', '63214強', '→↘↓↙←+強', '強 パワーボム', 185, 5, null, '{}'::text[]),
  ('alex_m_63214od', 'alex', 'modern', 'special', 'OD63214', '→↘↓↙←+攻撃×2', 'OD パワーボム', 186, 5, null, '{}'::text[]),
  ('alex_m_powerdrop', 'alex', 'modern', 'special', '[背面]63214攻撃', '背面から→↘↓↙←+攻撃', 'パワードロップ（背面）', 187, 5, null, '{}'::text[]),
  ('alex_m_powerdrop_od', 'alex', 'modern', 'special', '[背面]OD63214', '背面から→↘↓↙←+攻撃×2', 'OD パワードロップ（背面）', 188, 5, null, '{}'::text[]),
  ('alex_m_hyperbomb', 'alex', 'modern', 'special', 'ハイパーボム', 'ODパワードロップ中→', 'ハイパーボム', 189, null, null, '{}'::text[]),

  -- 10. モダンスーパーアーツ（4種: 195〜198、オメガウィングバスター含む・CA除外）
  ('alex_m_sa1', 'alex', 'modern', 'super', 'SA1', 'SP+強', 'SA1 レイジングスピアー', 195, 9, null, '{}'::text[]),
  ('alex_m_sa2', 'alex', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 スレッジクロスハンマー', 196, 13, null, '{}'::text[]),
  ('alex_m_sa2_omega', 'alex', 'modern', 'super', 'SA2(オメガウィング)', 'ODパワードロップ中SP+強', 'SA2 オメガウィングバスター', 197, null, null, '{}'::text[]),
  ('alex_m_sa3', 'alex', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 ファイナルキャプチュード', 198, 12, null, '{}'::text[]),

  -- 11. モダン通常投げ（3種: 205〜207）
  ('alex_m_throw_f', 'alex', 'modern', 'throw', '前投げ', '弱+中', 'アームロック（前投げ）', 205, 5, null, '{}'::text[]),
  ('alex_m_throw_b', 'alex', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'ギロチンハンマー（後ろ投げ）', 206, 5, null, '{}'::text[]),
  ('alex_m_throw_2', 'alex', 'modern', 'throw', '下投げ', '↓+弱+中', 'イリーガルキック（下投げ）', 207, 5, null, '{}'::text[])
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
