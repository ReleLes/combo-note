-- =============================================================================
-- Migration: 025_seed_test_combos_batch1.sql
-- 目的: 試験運用向け 動作確認用テストコンボデータ（バッチ1: 公式順1〜8キャラ）を投入する
-- 対象: luke, jamie, manon, kimberly, marisa, lily, jp, juri
-- 内訳: 各キャラ クラシック3件・モダン3件（計48件）
-- 備考: 全件 damage = NULL / title 先頭「【テスト】」 / note 先頭「※動作確認用のテストデータです。」
--       author_id / version_id はサブクエリで動的解決し、ON CONFLICT & NOT EXISTS で冪等に投入
-- =============================================================================

with seed_data (
  id,
  character_id,
  control_type,
  title,
  move_ids,
  recipe_signature,
  situations,
  category,
  damage,
  drive_cost,
  sa_cost,
  stock_cost,
  stock_gain,
  has_oki,
  note
) as (
  values
  -- luke
  ('b1000001-0000-4000-8000-000000000001'::uuid, 'luke', 'classic', '【テスト】弱始動の基本サンプル', '["luke_2lp","luke_2lp","luke_214lp"]'::jsonb, 'luke:classic:luke_2lp>luke_2lp>luke_214lp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。表記切替やマイノート保存のお試し用基本ルートです。'),
  ('b1000001-0000-4000-8000-000000000002'::uuid, 'luke', 'classic', '【テスト】中足ラッシュ定番例', '["luke_2mk","sys_dr","luke_2mp","luke_2hp","luke_214mp"]'::jsonb, 'luke:classic:luke_2mk>sys_dr>luke_2mp>luke_2hp>luke_214mp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。キャンセルラッシュから中フラッシュナックルへ繋ぐ定番構成の例です。'),
  ('b1000001-0000-4000-8000-000000000003'::uuid, 'luke', 'classic', '【テスト】DIヒット時のSA3締め例', '["sys_di","luke_5hp","luke_214hp","luke_sa3"]'::jsonb, 'luke:classic:sys_di>luke_5hp>luke_214hp>luke_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。ドライブインパクトヒットからSA3まで繋ぐ高火力サンプルです。'),
  ('b1000001-0000-4000-8000-000000000004'::uuid, 'luke', 'modern', '【テスト】弱始動のワンボタン必殺例', '["luke_m_2l","luke_m_2l","luke_m_6sp"]'::jsonb, 'luke:modern:luke_m_2l>luke_m_2l>luke_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱連打から前必（ライジングアッパー）で締める基本例です。'),
  ('b1000001-0000-4000-8000-000000000005'::uuid, 'luke', 'modern', '【テスト】しゃがみ中ラッシュ定番例', '["luke_m_2m","sys_dr","luke_m_auto_m","luke_m_2h","luke_m_4sp"]'::jsonb, 'luke:modern:luke_m_2m>sys_dr>luke_m_auto_m>luke_m_2h>luke_m_4sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中キャンセルラッシュから後必へ繋ぐモダン定番例です。'),
  ('b1000001-0000-4000-8000-000000000006'::uuid, 'luke', 'modern', '【テスト】DI始動SA3締めサンプル', '["sys_di","luke_m_auto_h","luke_m_4sp","luke_m_sa3"]'::jsonb, 'luke:modern:sys_di>luke_m_auto_h>luke_m_4sp>luke_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットからアシスト強・後必経由でSA3へ繋ぐサンプルです。'),
  -- jamie
  ('b1000001-0000-4000-8000-000000000007'::uuid, 'jamie', 'classic', '【テスト】弱始動の飲み基本サンプル', '["jamie_2lp","jamie_2lp","jamie_236lp","jamie_ryusuikyaku_l_2","jamie_ryusuikyaku_l_3"]'::jsonb, 'jamie:classic:jamie_2lp>jamie_2lp>jamie_236lp>jamie_ryusuikyaku_l_2>jamie_ryusuikyaku_l_3', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。小技から流酔脚派生で酔いレベルを上げる基本ルート例です。'),
  ('b1000001-0000-4000-8000-000000000008'::uuid, 'jamie', 'classic', '【テスト】中足ラッシュ酔疾歩締め例', '["jamie_2mk","sys_dr","jamie_2mp","jamie_5hp","jamie_214lp"]'::jsonb, 'jamie:classic:jamie_2mk>sys_dr>jamie_2mp>jamie_5hp>jamie_214lp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。中足ラッシュから弱酔疾歩でダウンを奪う定番ルート例です。'),
  ('b1000001-0000-4000-8000-000000000009'::uuid, 'jamie', 'classic', '【テスト】DI始動Lv2爆廻SA3例', '["sys_di","jamie_5hp","jamie_236hk","jamie_sa3"]'::jsonb, 'jamie:classic:sys_di>jamie_5hp>jamie_236hk>jamie_sa3', array['di_hit', 'jamie_drink_level']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。酔いLv2以降の爆廻からSA3へ繋ぐ高火力サンプルです。'),
  ('b1000001-0000-4000-8000-000000000010'::uuid, 'jamie', 'modern', '【テスト】弱始動の流酔脚飲み例', '["jamie_m_2l","jamie_m_2l","jamie_m_sp","jamie_m_ryusuikyaku_m_2","jamie_m_ryusuikyaku_m_3"]'::jsonb, 'jamie:modern:jamie_m_2l>jamie_m_2l>jamie_m_sp>jamie_m_ryusuikyaku_m_2>jamie_m_ryusuikyaku_m_3', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱からN必経由の流酔脚で飲みまで繋ぐ基本例です。'),
  ('b1000001-0000-4000-8000-000000000011'::uuid, 'jamie', 'modern', '【テスト】屈中ラッシュ張弓腿締め例', '["jamie_m_2m","sys_dr","jamie_m_5m","jamie_m_5h","jamie_m_6sp"]'::jsonb, 'jamie:modern:jamie_m_2m>sys_dr>jamie_m_5m>jamie_m_5h>jamie_m_6sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中ラッシュから前必（強張弓腿）で締める定番例です。'),
  ('b1000001-0000-4000-8000-000000000012'::uuid, 'jamie', 'modern', '【テスト】DI始動Lv2爆廻SA3例', '["sys_di","jamie_m_5h","jamie_m_3sp","jamie_m_sa3"]'::jsonb, 'jamie:modern:sys_di>jamie_m_5h>jamie_m_3sp>jamie_m_sa3', array['di_hit', 'jamie_drink_level']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。酔いLv2時の右下必（強爆廻）からSA3へ繋ぐ高火力例です。'),
  -- manon
  ('b1000001-0000-4000-8000-000000000013'::uuid, 'manon', 'classic', '【テスト】弱始動デガジェ締め例', '["manon_5lp","manon_5lp","manon_214lk"]'::jsonb, 'manon:classic:manon_5lp>manon_5lp>manon_214lk', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱P連打から弱デガジェへ繋ぐ表記確認向けの基本例です。'),
  ('b1000001-0000-4000-8000-000000000014'::uuid, 'manon', 'classic', '【テスト】屈中Pラッシュメダル獲得例', '["manon_2mp","sys_dr","manon_2mp","manon_4hp","manon_236mp"]'::jsonb, 'manon:classic:manon_2mp>sys_dr>manon_2mp>manon_4hp>manon_236mp', array['midscreen', 'manon_medal']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中Pラッシュから中ランヴェルセで締める定番例です。'),
  ('b1000001-0000-4000-8000-000000000015'::uuid, 'manon', 'classic', '【テスト】DIヒット時のSA3締め例', '["sys_di","manon_4hp","manon_236mk","manon_sa3"]'::jsonb, 'manon:classic:sys_di>manon_4hp>manon_236mk>manon_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから4強P・中ロン・ポワン経由でSA3へ繋ぐ例です。'),
  ('b1000001-0000-4000-8000-000000000016'::uuid, 'manon', 'modern', '【テスト】弱始動のワンボタン必殺例', '["manon_m_5l","manon_m_5l","manon_m_4sp"]'::jsonb, 'manon:modern:manon_m_5l>manon_m_5l>manon_m_4sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱から後必（弱デガジェ）へ繋ぐモダン基本サンプルです。'),
  ('b1000001-0000-4000-8000-000000000017'::uuid, 'manon', 'modern', '【テスト】立ち中ラッシュメダル獲得例', '["manon_m_5m","sys_dr","manon_m_2m","manon_m_4h","manon_m_2sp"]'::jsonb, 'manon:modern:manon_m_5m>sys_dr>manon_m_2m>manon_m_4h>manon_m_2sp', array['midscreen', 'manon_medal']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち中ラッシュから下必（弱ランヴェルセ）へ繋ぐ定番例です。'),
  ('b1000001-0000-4000-8000-000000000018'::uuid, 'manon', 'modern', '【テスト】DI始動SA3締めサンプル', '["sys_di","manon_m_4h","manon_m_6sp","manon_m_sa3"]'::jsonb, 'manon:modern:sys_di>manon_m_4h>manon_m_6sp>manon_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから4強・前必経由でSA3へ繋ぐ高火力サンプルです。'),
  -- kimberly
  ('b1000001-0000-4000-8000-000000000019'::uuid, 'kimberly', 'classic', '【テスト】タゲコン旋風脚の基本例', '["kimberly_5mp","kimberly_tc_mp_hp","kimberly_214hk"]'::jsonb, 'kimberly:classic:kimberly_5mp>kimberly_tc_mp_hp>kimberly_214hk', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。武神虎連牙から強武神旋風脚へ繋ぐノーゲージ基本例です。'),
  ('b1000001-0000-4000-8000-000000000020'::uuid, 'kimberly', 'classic', '【テスト】屈中Pラッシュ疾駆け締め例', '["kimberly_2mp","sys_dr","kimberly_2mp","kimberly_5hp","kimberly_236k","kimberly_hayagake_kage"]'::jsonb, 'kimberly:classic:kimberly_2mp>sys_dr>kimberly_2mp>kimberly_5hp>kimberly_236k>kimberly_hayagake_kage', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中Pラッシュから疾駆け・影すくいで締める定番例です。'),
  ('b1000001-0000-4000-8000-000000000021'::uuid, 'kimberly', 'classic', '【テスト】DI始動SA1雷譜(手裏剣)例', '["sys_di","kimberly_5mp","kimberly_tc_mp_hp","kimberly_sa1_raifu"]'::jsonb, 'kimberly:classic:sys_di>kimberly_5mp>kimberly_tc_mp_hp>kimberly_sa1_raifu', array['di_hit', 'kimberly_shuriken']::text[], 'optimal', null::int, 1.0, 1, 1, 0, true, '※動作確認用のテストデータです。細工手裏剣ストックを1消費してSA1雷譜で締めるサンプルです。'),
  ('b1000001-0000-4000-8000-000000000022'::uuid, 'kimberly', 'modern', '【テスト】タゲコン後必の基本例', '["kimberly_m_5m","kimberly_m_tc_m_m","kimberly_m_4sp"]'::jsonb, 'kimberly:modern:kimberly_m_5m>kimberly_m_tc_m_m>kimberly_m_4sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。武神虎連牙から後必（強武神旋風脚）で締めるモダン基本例です。'),
  ('b1000001-0000-4000-8000-000000000023'::uuid, 'kimberly', 'modern', '【テスト】A中ラッシュ旋風脚締め例', '["kimberly_m_auto_m","sys_dr","kimberly_m_2m","kimberly_m_2h","kimberly_m_4sp"]'::jsonb, 'kimberly:modern:kimberly_m_auto_m>sys_dr>kimberly_m_2m>kimberly_m_2h>kimberly_m_4sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。アシスト中キャンセルラッシュから後必へ繋ぐ定番例です。'),
  ('b1000001-0000-4000-8000-000000000024'::uuid, 'kimberly', 'modern', '【テスト】DI始動SA3締めサンプル', '["sys_di","kimberly_m_5h","kimberly_m_6sp","kimberly_m_hayagake_kage","kimberly_m_sa3"]'::jsonb, 'kimberly:modern:sys_di>kimberly_m_5h>kimberly_m_6sp>kimberly_m_hayagake_kage>kimberly_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから疾駆け・影すくい経由でSA3へ繋ぐ高火力例です。'),
  -- marisa
  ('b1000001-0000-4000-8000-000000000025'::uuid, 'marisa', 'classic', '【テスト】中Pタゲコン基本サンプル', '["marisa_5mp","marisa_tc_mp","marisa_236mp"]'::jsonb, 'marisa:classic:marisa_5mp>marisa_tc_mp>marisa_236mp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。ミドルワンツーから中グラディウスへ繋ぐ基本ルート例です。'),
  ('b1000001-0000-4000-8000-000000000026'::uuid, 'marisa', 'classic', '【テスト】屈中Pラッシュディマカ例', '["marisa_2mp","sys_dr","marisa_4hp","marisa_214mp","marisa_dimachaerus_m_2"]'::jsonb, 'marisa:classic:marisa_2mp>sys_dr>marisa_4hp>marisa_214mp>marisa_dimachaerus_m_2', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中Pラッシュから中ディマカイルス2段目まで繋ぐ例です。'),
  ('b1000001-0000-4000-8000-000000000027'::uuid, 'marisa', 'classic', '【テスト】DI始動グラディウスSA3例', '["sys_di","marisa_4hp","marisa_236hp","marisa_sa3"]'::jsonb, 'marisa:classic:sys_di>marisa_4hp>marisa_236hp>marisa_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから4強P・強グラディウス経由でSA3へ繋ぐ例です。'),
  ('b1000001-0000-4000-8000-000000000028'::uuid, 'marisa', 'modern', '【テスト】タゲコンN必の基本例', '["marisa_m_auto_m","marisa_m_tc_m","marisa_m_sp"]'::jsonb, 'marisa:modern:marisa_m_auto_m>marisa_m_tc_m>marisa_m_sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。ミドルワンツーからN必（弱グラディウス）で締める基本例です。'),
  ('b1000001-0000-4000-8000-000000000029'::uuid, 'marisa', 'modern', '【テスト】屈中ラッシュディマカ例', '["marisa_m_2m","sys_dr","marisa_m_4h","marisa_m_214m","marisa_m_dimachaerus_m_2"]'::jsonb, 'marisa:modern:marisa_m_2m>sys_dr>marisa_m_4h>marisa_m_214m>marisa_m_dimachaerus_m_2', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中ラッシュから4強・中ディマカイルスへ繋ぐ定番例です。'),
  ('b1000001-0000-4000-8000-000000000030'::uuid, 'marisa', 'modern', '【テスト】DI始動クアドリガSA3例', '["sys_di","marisa_m_4h","marisa_m_2sp","marisa_m_sa3"]'::jsonb, 'marisa:modern:sys_di>marisa_m_4h>marisa_m_2sp>marisa_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから4強・下必経由でSA3へ繋ぐ高火力サンプルです。'),
  -- lily
  ('b1000001-0000-4000-8000-000000000031'::uuid, 'lily', 'classic', '【テスト】弱始動トマホーク基本例', '["lily_2lp","lily_5lk","lily_623lp"]'::jsonb, 'lily:classic:lily_2lp>lily_5lk>lily_623lp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。小技から弱トマホークバスターで締めるノーゲージ基本例です。'),
  ('b1000001-0000-4000-8000-000000000032'::uuid, 'lily', 'classic', '【テスト】屈強Pラッシュ強化スパイア例', '["lily_2hp","sys_dr","lily_2hp","lily_236hk_ex"]'::jsonb, 'lily:classic:lily_2hp>sys_dr>lily_2hp>lily_236hk_ex', array['midscreen', 'lily_windclad']::text[], 'standard', null::int, 3.0, 0, 1, 0, true, '※動作確認用のテストデータです。風纏いを1消費して強化版強スパイアへ繋ぐ定番ルート例です。'),
  ('b1000001-0000-4000-8000-000000000033'::uuid, 'lily', 'classic', '【テスト】DI始動の風纏いSA2締め例', '["sys_di","lily_2hp","lily_236odk_h_ex","lily_sa2_ex"]'::jsonb, 'lily:classic:sys_di>lily_2hp>lily_236odk_h_ex>lily_sa2_ex', array['di_hit', 'lily_windclad']::text[], 'optimal', null::int, 3.0, 2, 2, 0, true, '※動作確認用のテストデータです。風纏い強化ODスパイアから強化SA2へ繋ぐ高火力サンプルです。'),
  ('b1000001-0000-4000-8000-000000000034'::uuid, 'lily', 'modern', '【テスト】弱連打トマホーク基本例', '["lily_m_5l","lily_m_5l_2","lily_m_6sp"]'::jsonb, 'lily:modern:lily_m_5l>lily_m_5l_2>lily_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱連打から前必（中トマホークバスター）で締める基本例です。'),
  ('b1000001-0000-4000-8000-000000000035'::uuid, 'lily', 'modern', '【テスト】A中ラッシュ強化スパイア例', '["lily_m_auto_m","sys_dr","lily_m_2h","lily_m_2sp_ex"]'::jsonb, 'lily:modern:lily_m_auto_m>sys_dr>lily_m_2h>lily_m_2sp_ex', array['midscreen', 'lily_windclad']::text[], 'standard', null::int, 3.0, 0, 1, 0, true, '※動作確認用のテストデータです。アシスト中ラッシュから強化版下必へ繋ぐモダン定番例です。'),
  ('b1000001-0000-4000-8000-000000000036'::uuid, 'lily', 'modern', '【テスト】DI始動SA3締めサンプル', '["sys_di","lily_m_2h","lily_m_4sp","lily_m_sa3"]'::jsonb, 'lily:modern:sys_di>lily_m_2h>lily_m_4sp>lily_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 1, false, '※動作確認用のテストデータです。DIヒットから2強・後必経由でSA3へ繋ぐ高火力サンプルです。'),
  -- jp
  ('b1000001-0000-4000-8000-000000000037'::uuid, 'jp', 'classic', '【テスト】弱始動ストリボーグ基本例', '["jp_2lp","jp_2lp","jp_236lp"]'::jsonb, 'jp:classic:jp_2lp>jp_2lp>jp_236lp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱Pから弱ストリボーグで締める基本サンプルです。'),
  ('b1000001-0000-4000-8000-000000000038'::uuid, 'jp', 'classic', '【テスト】屈中Pラッシュ定番ルート例', '["jp_2mp","sys_dr","jp_5hp","jp_236mp","jp_22mp"]'::jsonb, 'jp:classic:jp_2mp>sys_dr>jp_5hp>jp_236mp>jp_22mp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中Pラッシュからストリボーグ・トリグラフへ繋ぐ定番例です。'),
  ('b1000001-0000-4000-8000-000000000039'::uuid, 'jp', 'classic', '【テスト】DI始動強KからのSA3例', '["sys_di","jp_5hk","jp_2mp","jp_236hp","jp_sa3"]'::jsonb, 'jp:classic:sys_di>jp_5hk>jp_2mp>jp_236hp>jp_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから5強K・2中P・強ストリボーグ経由でSA3へ繋ぐ例です。'),
  ('b1000001-0000-4000-8000-000000000040'::uuid, 'jp', 'modern', '【テスト】弱始動ストリボーグ例', '["jp_m_2l","jp_m_2l","jp_m_1sp"]'::jsonb, 'jp:modern:jp_m_2l>jp_m_2l>jp_m_1sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱から左下必（弱ストリボーグ）へ繋ぐモダン基本例です。'),
  ('b1000001-0000-4000-8000-000000000041'::uuid, 'jp', 'modern', '【テスト】A中ラッシュ定番ルート例', '["jp_m_auto_m","sys_dr","jp_m_auto_h","jp_m_2sp","jp_m_sp"]'::jsonb, 'jp:modern:jp_m_auto_m>sys_dr>jp_m_auto_h>jp_m_2sp>jp_m_sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。アシスト中ラッシュから下必・N必で締めるモダン定番例です。'),
  ('b1000001-0000-4000-8000-000000000042'::uuid, 'jp', 'modern', '【テスト】DI始動SA3締めサンプル', '["sys_di","jp_m_5h","jp_m_auto_m","jp_m_3sp","jp_m_sa3"]'::jsonb, 'jp:modern:sys_di>jp_m_5h>jp_m_auto_m>jp_m_3sp>jp_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから5強・A中・右下必経由でSA3へ繋ぐ高火力例です。'),
  -- juri
  ('b1000001-0000-4000-8000-000000000043'::uuid, 'juri', 'classic', '【テスト】弱始動の風破刃基本例', '["juri_2lp","juri_2lp","juri_214mk"]'::jsonb, 'juri:classic:juri_2lp>juri_2lp>juri_214mk', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 1, true, '※動作確認用のテストデータです。しゃがみ弱Pから中風破刃で風破ストックを1溜める基本例です。'),
  ('b1000001-0000-4000-8000-000000000044'::uuid, 'juri', 'classic', '【テスト】中足ラッシュ風破締め例', '["juri_2mk","sys_dr","juri_5mp","juri_2mp","juri_214mk"]'::jsonb, 'juri:classic:juri_2mk>sys_dr>juri_5mp>juri_2mp>juri_214mk', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 1, true, '※動作確認用のテストデータです。中足キャンセルラッシュから中風破刃で締める定番サンプルです。'),
  ('b1000001-0000-4000-8000-000000000045'::uuid, 'juri', 'classic', '【テスト】DI始動風破SA3締め例', '["sys_di","juri_5hp","juri_214mk","juri_sa3"]'::jsonb, 'juri:classic:sys_di>juri_5hp>juri_214mk>juri_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 1, false, '※動作確認用のテストデータです。DIヒットから5強P・中風破刃経由でSA3へ繋ぐ高火力例です。'),
  ('b1000001-0000-4000-8000-000000000046'::uuid, 'juri', 'modern', '【テスト】弱始動の風破刃基本例', '["juri_m_5l","juri_m_5l","juri_m_2sp"]'::jsonb, 'juri:modern:juri_m_5l>juri_m_5l>juri_m_2sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 1, true, '※動作確認用のテストデータです。立ち弱から下必（風破刃）でストックを溜めるモダン基本例です。'),
  ('b1000001-0000-4000-8000-000000000047'::uuid, 'juri', 'modern', '【テスト】屈中ラッシュ風破締め例', '["juri_m_2m","sys_dr","juri_m_auto_m","juri_m_2h","juri_m_2sp"]'::jsonb, 'juri:modern:juri_m_2m>sys_dr>juri_m_auto_m>juri_m_2h>juri_m_2sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 1, true, '※動作確認用のテストデータです。しゃがみ中ラッシュから下必（風破刃）で締めるモダン定番例です。'),
  ('b1000001-0000-4000-8000-000000000048'::uuid, 'juri', 'modern', '【テスト】DI始動五黄殺SA3締め例', '["sys_di","juri_m_auto_h","juri_m_4sp","juri_m_sa3"]'::jsonb, 'juri:modern:sys_di>juri_m_auto_h>juri_m_4sp>juri_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットからアシスト強・後必（五黄殺）経由でSA3へ繋ぐ例です。')
)
insert into public.combos (
  id,
  author_id,
  author_name,
  character_id,
  control_type,
  title,
  move_ids,
  recipe_signature,
  situations,
  category,
  damage,
  drive_cost,
  sa_cost,
  stock_cost,
  stock_gain,
  has_oki,
  note,
  version_id,
  likes_count
)
select
  s.id,
  (select id from auth.users order by created_at asc limit 1),
  'テストデータ',
  s.character_id,
  s.control_type,
  s.title,
  s.move_ids,
  s.recipe_signature,
  s.situations,
  s.category,
  s.damage,
  s.drive_cost,
  s.sa_cost,
  s.stock_cost,
  s.stock_gain,
  s.has_oki,
  s.note,
  (select id from public.game_versions order by released_at desc limit 1),
  0
from seed_data s
where not exists (
  select 1 from public.combos c where c.recipe_signature = s.recipe_signature
)
on conflict (id) do nothing;
