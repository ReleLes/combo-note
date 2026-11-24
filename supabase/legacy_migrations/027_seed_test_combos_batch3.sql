-- =============================================================================
-- Migration: 027_seed_test_combos_batch3.sql
-- 目的: 試験運用向け 動作確認用テストコンボデータ（バッチ3: 公式順17〜24キャラ）を投入する
-- 対象: zangief, dhalsim, rashid, aki, ed, akuma, vega, terry
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
  -- zangief
  ('b1000003-0000-4000-8000-000000000001'::uuid, 'zangief', 'classic', '【テスト】弱始動ダブラリの基本例', '["zangief_2lp","zangief_2lp","zangief_lariat"]'::jsonb, 'zangief:classic:zangief_2lp>zangief_2lp>zangief_lariat', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱P連打からダブルラリアットへ繋ぐ基本例です。'),
  ('b1000003-0000-4000-8000-000000000002'::uuid, 'zangief', 'classic', '【テスト】屈中Pラッシュダブラリ例', '["zangief_2mp","sys_dr","zangief_6hp","zangief_3mp","zangief_lariat"]'::jsonb, 'zangief:classic:zangief_2mp>sys_dr>zangief_6hp>zangief_3mp>zangief_lariat', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中Pラッシュからヘッドバット・ヘルスタブ経由で締める定番例です。'),
  ('b1000003-0000-4000-8000-000000000003'::uuid, 'zangief', 'classic', '【テスト】DI始動ODダブラリSA2例', '["sys_di","zangief_6hp","zangief_3mp","zangief_lariat_od","zangief_sa2"]'::jsonb, 'zangief:classic:sys_di>zangief_6hp>zangief_3mp>zangief_lariat_od>zangief_sa2', array['di_hit']::text[], 'optimal', null::int, 3.0, 2, 0, 0, false, '※動作確認用のテストデータです。DIヒットからODダブルラリアット経由でSA2へ繋ぐ高火力例です。'),
  ('b1000003-0000-4000-8000-000000000004'::uuid, 'zangief', 'modern', '【テスト】弱始動ダブラリの基本例', '["zangief_m_2l","zangief_m_2l","zangief_m_2sp"]'::jsonb, 'zangief:modern:zangief_m_2l>zangief_m_2l>zangief_m_2sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱から下必（ダブルラリアット）へ繋ぐモダン基本例です。'),
  ('b1000003-0000-4000-8000-000000000005'::uuid, 'zangief', 'modern', '【テスト】屈中ラッシュダブラリ例', '["zangief_m_2m","sys_dr","zangief_m_auto_h","zangief_m_3m","zangief_m_2sp"]'::jsonb, 'zangief:modern:zangief_m_2m>sys_dr>zangief_m_auto_h>zangief_m_3m>zangief_m_2sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中ラッシュからヘッドバット・ヘルスタブ・下必へ繋ぐ定番例です。'),
  ('b1000003-0000-4000-8000-000000000006'::uuid, 'zangief', 'modern', '【テスト】DI始動ODダブラリSA2例', '["sys_di","zangief_m_auto_h","zangief_m_3m","zangief_m_od_2sp","zangief_m_sa2"]'::jsonb, 'zangief:modern:sys_di>zangief_m_auto_h>zangief_m_3m>zangief_m_od_2sp>zangief_m_sa2', array['di_hit']::text[], 'optimal', null::int, 3.0, 2, 0, 0, false, '※動作確認用のテストデータです。DIヒットからOD下必（ダブラリ）経由でSA2へ繋ぐ高火力例です。'),
  -- dhalsim
  ('b1000003-0000-4000-8000-000000000007'::uuid, 'dhalsim', 'classic', '【テスト】弱始動ヨガブラスト基本例', '["dhalsim_5lp","dhalsim_5lp","dhalsim_63214lk"]'::jsonb, 'dhalsim:classic:dhalsim_5lp>dhalsim_5lp>dhalsim_63214lk', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱P連打から弱ヨガブラストへ繋ぐノーゲージ基本例です。'),
  ('b1000003-0000-4000-8000-000000000008'::uuid, 'dhalsim', 'classic', '【テスト】合掌キックラッシュ定番例', '["dhalsim_4mk","sys_dr","dhalsim_5lp","dhalsim_4mp","dhalsim_63214mp"]'::jsonb, 'dhalsim:classic:dhalsim_4mk>sys_dr>dhalsim_5lp>dhalsim_4mp>dhalsim_63214mp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。合掌キックラッシュからヨガアッパー・中フレイムへ繋ぐ定番例です。'),
  ('b1000003-0000-4000-8000-000000000009'::uuid, 'dhalsim', 'classic', '【テスト】DI始動フレイムSA3例', '["sys_di","dhalsim_1hp","dhalsim_63214hp","dhalsim_sa3"]'::jsonb, 'dhalsim:classic:sys_di>dhalsim_1hp>dhalsim_63214hp>dhalsim_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから涅槃パンチ・強ヨガフレイム経由でSA3へ繋ぐ例です。'),
  ('b1000003-0000-4000-8000-000000000010'::uuid, 'dhalsim', 'modern', '【テスト】弱始動ブラストの基本例', '["dhalsim_m_5l","dhalsim_m_5l","dhalsim_m_1sp"]'::jsonb, 'dhalsim:modern:dhalsim_m_5l>dhalsim_m_5l>dhalsim_m_1sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱から左下必（弱ヨガブラスト）で締めるモダン基本例です。'),
  ('b1000003-0000-4000-8000-000000000011'::uuid, 'dhalsim', 'modern', '【テスト】A中ラッシュフレイム例', '["dhalsim_m_auto_m","sys_dr","dhalsim_m_5l","dhalsim_m_4m","dhalsim_m_4sp"]'::jsonb, 'dhalsim:modern:dhalsim_m_auto_m>sys_dr>dhalsim_m_5l>dhalsim_m_4m>dhalsim_m_4sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。アシスト中ラッシュから後必（弱ヨガフレイム）で締める定番例です。'),
  ('b1000003-0000-4000-8000-000000000012'::uuid, 'dhalsim', 'modern', '【テスト】DI始動フレイムSA3例', '["sys_di","dhalsim_m_1h","dhalsim_m_4sp","dhalsim_m_sa3"]'::jsonb, 'dhalsim:modern:sys_di>dhalsim_m_1h>dhalsim_m_4sp>dhalsim_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから涅槃パンチ・後必（フレイム）経由でSA3へ繋ぐ例です。'),
  -- rashid
  ('b1000003-0000-4000-8000-000000000013'::uuid, 'rashid', 'classic', '【テスト】弱始動ミキサーの基本例', '["rashid_5lp","rashid_5lp","rashid_236mp"]'::jsonb, 'rashid:classic:rashid_5lp>rashid_5lp>rashid_236mp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱P連打から中スピニング・ミキサーへ繋ぐ基本例です。'),
  ('b1000003-0000-4000-8000-000000000014'::uuid, 'rashid', 'classic', '【テスト】中足ラッシュスパイク締め例', '["rashid_2mk","sys_dr","rashid_5mp","rashid_tc_mp_hk","rashid_214lk"]'::jsonb, 'rashid:classic:rashid_2mk>sys_dr>rashid_5mp>rashid_tc_mp_hk>rashid_214lk', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。中足ラッシュからライジング・キック・弱スパイクで運ぶ定番例です。'),
  ('b1000003-0000-4000-8000-000000000015'::uuid, 'rashid', 'classic', '【テスト】DI始動ミキサーSA3例', '["sys_di","rashid_5hp","rashid_236mp","rashid_sa3"]'::jsonb, 'rashid:classic:sys_di>rashid_5hp>rashid_236mp>rashid_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから5強P・中ミキサー経由でSA3へ繋ぐ高火力例です。'),
  ('b1000003-0000-4000-8000-000000000016'::uuid, 'rashid', 'modern', '【テスト】弱始動前必ミキサー例', '["rashid_m_5l","rashid_m_5l","rashid_m_6sp"]'::jsonb, 'rashid:modern:rashid_m_5l>rashid_m_5l>rashid_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱から前必（強ミキサー）で締めるモダン基本サンプルです。'),
  ('b1000003-0000-4000-8000-000000000017'::uuid, 'rashid', 'modern', '【テスト】屈中ラッシュスパイク締め例', '["rashid_m_2m","sys_dr","rashid_m_auto_m","rashid_m_tc_am_am","rashid_m_1sp"]'::jsonb, 'rashid:modern:rashid_m_2m>sys_dr>rashid_m_auto_m>rashid_m_tc_am_am>rashid_m_1sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中ラッシュから左下必（弱スパイク）で運ぶ定番例です。'),
  ('b1000003-0000-4000-8000-000000000018'::uuid, 'rashid', 'modern', '【テスト】DI始動スパイクSA3例', '["sys_di","rashid_m_auto_h","rashid_m_1sp","rashid_m_sa3"]'::jsonb, 'rashid:modern:sys_di>rashid_m_auto_h>rashid_m_1sp>rashid_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットからアシスト強・左下必経由でSA3へ繋ぐ高火力例です。'),
  -- aki
  ('b1000003-0000-4000-8000-000000000019'::uuid, 'aki', 'classic', '【テスト】弱始動の蛇頭鞭基本例', '["aki_2lp","aki_2lp","aki_236lp"]'::jsonb, 'aki:classic:aki_2lp>aki_2lp>aki_236lp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱Pから弱蛇頭鞭へ繋ぐノーゲージ基本サンプルです。'),
  ('b1000003-0000-4000-8000-000000000020'::uuid, 'aki', 'classic', '【テスト】立ち中Pラッシュ蛇頭鞭例', '["aki_5mp","sys_dr","aki_5hk","aki_2mp","aki_236mp"]'::jsonb, 'aki:classic:aki_5mp>sys_dr>aki_5hk>aki_2mp>aki_236mp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち中Pラッシュから5強K・2中P・中蛇頭鞭へ繋ぐ定番例です。'),
  ('b1000003-0000-4000-8000-000000000021'::uuid, 'aki', 'classic', '【テスト】DI始動の蛇頭鞭SA3例', '["sys_di","aki_5hk","aki_236hp","aki_sa3"]'::jsonb, 'aki:classic:sys_di>aki_5hk>aki_236hp>aki_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから5強K・強蛇頭鞭経由でSA3へ繋ぐ高火力例です。'),
  ('b1000003-0000-4000-8000-000000000022'::uuid, 'aki', 'modern', '【テスト】弱始動のワンボタン蛇頭鞭例', '["aki_m_2l","aki_m_2l","aki_m_6sp"]'::jsonb, 'aki:modern:aki_m_2l>aki_m_2l>aki_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱から前必（強蛇頭鞭）へ繋ぐモダン基本サンプルです。'),
  ('b1000003-0000-4000-8000-000000000023'::uuid, 'aki', 'modern', '【テスト】A中ラッシュ蛇頭鞭締め例', '["aki_m_auto_m","sys_dr","aki_m_auto_h","aki_m_auto_m","aki_m_6sp"]'::jsonb, 'aki:modern:aki_m_auto_m>sys_dr>aki_m_auto_h>aki_m_auto_m>aki_m_6sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。アシスト中ラッシュから前必（強蛇頭鞭）で締める定番例です。'),
  ('b1000003-0000-4000-8000-000000000024'::uuid, 'aki', 'modern', '【テスト】DI始動の蛇頭鞭SA3例', '["sys_di","aki_m_auto_h","aki_m_6sp","aki_m_sa3"]'::jsonb, 'aki:modern:sys_di>aki_m_auto_h>aki_m_6sp>aki_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットからアシスト強・前必（強蛇頭鞭）経由でSA3へ繋ぐ例です。'),
  -- ed
  ('b1000003-0000-4000-8000-000000000025'::uuid, 'ed', 'classic', '【テスト】中Pタゲコンブリッツ基本例', '["ed_5mp","ed_tc_mp_hp","ed_214hp"]'::jsonb, 'ed:classic:ed_5mp>ed_tc_mp_hp>ed_214hp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。ボディブローコンビネーションから強ブリッツで締める基本例です。'),
  ('b1000003-0000-4000-8000-000000000026'::uuid, 'ed', 'classic', '【テスト】中足ラッシュブリッツ例', '["ed_2mk","sys_dr","ed_5mp","ed_tc_mp_hp","ed_214mp"]'::jsonb, 'ed:classic:ed_2mk>sys_dr>ed_5mp>ed_tc_mp_hp>ed_214mp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。中足キャンセルラッシュから中サイコブリッツへ繋ぐ定番例です。'),
  ('b1000003-0000-4000-8000-000000000027'::uuid, 'ed', 'classic', '【テスト】DI始動ブリッツSA3例', '["sys_di","ed_5hp","ed_214hp","ed_sa3"]'::jsonb, 'ed:classic:sys_di>ed_5hp>ed_214hp>ed_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから5強P・強ブリッツ経由でSA3へ繋ぐ高火力例です。'),
  ('b1000003-0000-4000-8000-000000000028'::uuid, 'ed', 'modern', '【テスト】タゲコン後必ブリッツ例', '["ed_m_auto_m","ed_m_tc_am_m","ed_m_4sp"]'::jsonb, 'ed:modern:ed_m_auto_m>ed_m_tc_am_m>ed_m_4sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。タゲコンから後必（強サイコブリッツ）で締めるモダン基本例です。'),
  ('b1000003-0000-4000-8000-000000000029'::uuid, 'ed', 'modern', '【テスト】屈中ラッシュアッパー締め例', '["ed_m_2m","sys_dr","ed_m_auto_m","ed_m_tc_am_m","ed_m_6sp"]'::jsonb, 'ed:modern:ed_m_2m>sys_dr>ed_m_auto_m>ed_m_tc_am_m>ed_m_6sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中ラッシュからタゲコン・前必アッパーへ繋ぐ定番例です。'),
  ('b1000003-0000-4000-8000-000000000030'::uuid, 'ed', 'modern', '【テスト】DI始動ブリッツSA3例', '["sys_di","ed_m_auto_h","ed_m_4sp","ed_m_sa3"]'::jsonb, 'ed:modern:sys_di>ed_m_auto_h>ed_m_4sp>ed_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットからアシスト強・後必（ブリッツ）経由でSA3へ繋ぐ例です。'),
  -- akuma
  ('b1000003-0000-4000-8000-000000000031'::uuid, 'akuma', 'classic', '【テスト】弱始動の豪昇龍基本例', '["akuma_2lp","akuma_2lp","akuma_623hp"]'::jsonb, 'akuma:classic:akuma_2lp>akuma_2lp>akuma_623hp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱P連打から強豪昇龍拳で締めるノーゲージ基本例です。'),
  ('b1000003-0000-4000-8000-000000000032'::uuid, 'akuma', 'classic', '【テスト】中足ラッシュ金剛灼火例', '["akuma_2mk","sys_dr","akuma_2mp","akuma_2hp","akuma_214mp","akuma_214mp_2"]'::jsonb, 'akuma:classic:akuma_2mk>sys_dr>akuma_2mp>akuma_2hp>akuma_214mp>akuma_214mp_2', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。中足キャンセルラッシュから中金剛灼火2段目まで運ぶ定番例です。'),
  ('b1000003-0000-4000-8000-000000000033'::uuid, 'akuma', 'classic', '【テスト】DI始動の昇龍SA3締め例', '["sys_di","akuma_5hp","akuma_623hp","akuma_sa3"]'::jsonb, 'akuma:classic:sys_di>akuma_5hp>akuma_623hp>akuma_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから5強P・強豪昇龍拳経由でSA3へ繋ぐ高火力例です。'),
  ('b1000003-0000-4000-8000-000000000034'::uuid, 'akuma', 'modern', '【テスト】弱始動のワンボタン昇龍例', '["akuma_m_5l","akuma_m_5l","akuma_m_6sp"]'::jsonb, 'akuma:modern:akuma_m_5l>akuma_m_5l>akuma_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱連打から前必（強豪昇龍拳）で締めるモダン基本例です。'),
  ('b1000003-0000-4000-8000-000000000035'::uuid, 'akuma', 'modern', '【テスト】屈中ラッシュ金剛灼火例', '["akuma_m_2m","sys_dr","akuma_m_auto_m","akuma_m_2h","akuma_m_2sp","akuma_m_2sp_2"]'::jsonb, 'akuma:modern:akuma_m_2m>sys_dr>akuma_m_auto_m>akuma_m_2h>akuma_m_2sp>akuma_m_2sp_2', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中ラッシュから下必（中金剛灼火）2段目まで繋ぐ定番例です。'),
  ('b1000003-0000-4000-8000-000000000036'::uuid, 'akuma', 'modern', '【テスト】DI始動の昇龍SA3締め例', '["sys_di","akuma_m_5h","akuma_m_6sp","akuma_m_sa3"]'::jsonb, 'akuma:modern:sys_di>akuma_m_5h>akuma_m_6sp>akuma_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから5強・前必（強豪昇龍拳）経由でSA3へ繋ぐ例です。'),
  -- vega
  ('b1000003-0000-4000-8000-000000000037'::uuid, 'vega', 'classic', '【テスト】弱始動ダブルニー基本例', '["vega_2lp","vega_2lp","vega_236lk"]'::jsonb, 'vega:classic:vega_2lp>vega_2lp>vega_236lk', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱Pから弱ダブルニープレスへ繋ぐ基本サンプルです。'),
  ('b1000003-0000-4000-8000-000000000038'::uuid, 'vega', 'classic', '【テスト】中足ラッシュバックフィスト例', '["vega_2mk","sys_dr","vega_2mp","vega_5mp","vega_214mp"]'::jsonb, 'vega:classic:vega_2mk>sys_dr>vega_2mp>vega_5mp>vega_214mp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。中足ラッシュから中バックフィストコンボでマインを付与する定番例です。'),
  ('b1000003-0000-4000-8000-000000000039'::uuid, 'vega', 'classic', '【テスト】DI始動のSA3締め例', '["sys_di","vega_4hk","vega_214mp","vega_sa3"]'::jsonb, 'vega:classic:sys_di>vega_4hk>vega_214mp>vega_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットからイビルニー・中バックフィスト経由でSA3へ繋ぐ例です。'),
  ('b1000003-0000-4000-8000-000000000040'::uuid, 'vega', 'modern', '【テスト】弱始動ダブルニー基本例', '["vega_m_2l","vega_m_2l","vega_m_6sp"]'::jsonb, 'vega:modern:vega_m_2l>vega_m_2l>vega_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱から前必（弱ダブルニープレス）で締める基本例です。'),
  ('b1000003-0000-4000-8000-000000000041'::uuid, 'vega', 'modern', '【テスト】屈中ラッシュN必締め例', '["vega_m_2m","sys_dr","vega_m_auto_m","vega_m_auto_h","vega_m_sp"]'::jsonb, 'vega:modern:vega_m_2m>sys_dr>vega_m_auto_m>vega_m_auto_h>vega_m_sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中ラッシュからN必（中バックフィスト）で締める定番例です。'),
  ('b1000003-0000-4000-8000-000000000042'::uuid, 'vega', 'modern', '【テスト】DI始動のSA3締め例', '["sys_di","vega_m_4h","vega_m_sp","vega_m_sa3"]'::jsonb, 'vega:modern:sys_di>vega_m_4h>vega_m_sp>vega_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットからイビルニー・N必経由でSA3へ繋ぐ高火力例です。'),
  -- terry
  ('b1000003-0000-4000-8000-000000000043'::uuid, 'terry', 'classic', '【テスト】弱始動ライジング基本例', '["terry_2lp","terry_2lp","terry_623lp"]'::jsonb, 'terry:classic:terry_2lp>terry_2lp>terry_623lp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱Pから弱ライジングタックルへ繋ぐノーゲージ基本例です。'),
  ('b1000003-0000-4000-8000-000000000044'::uuid, 'terry', 'classic', '【テスト】中足ラッシュバーンナックル例', '["terry_2mk","sys_dr","terry_2mp","terry_5hp","terry_214mp"]'::jsonb, 'terry:classic:terry_2mk>sys_dr>terry_2mp>terry_5hp>terry_214mp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。中足キャンセルラッシュから中バーンナックルで運ぶ定番例です。'),
  ('b1000003-0000-4000-8000-000000000045'::uuid, 'terry', 'classic', '【テスト】DI始動バーンSA3締め例', '["sys_di","terry_5hp","terry_214mp","terry_sa3"]'::jsonb, 'terry:classic:sys_di>terry_5hp>terry_214mp>terry_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから5強P・中バーンナックル経由でSA3へ繋ぐ高火力例です。'),
  ('b1000003-0000-4000-8000-000000000046'::uuid, 'terry', 'modern', '【テスト】弱始動ライジング基本例', '["terry_m_2l","terry_m_2l","terry_m_6sp"]'::jsonb, 'terry:modern:terry_m_2l>terry_m_2l>terry_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱から前必（弱ライジングタックル）で締める基本例です。'),
  ('b1000003-0000-4000-8000-000000000047'::uuid, 'terry', 'modern', '【テスト】屈中ラッシュチャージ締め例', '["terry_m_2m","sys_dr","terry_m_auto_m","terry_m_auto_h","terry_m_2sp"]'::jsonb, 'terry:modern:terry_m_2m>sys_dr>terry_m_auto_m>terry_m_auto_h>terry_m_2sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中ラッシュから下必（中パワーチャージ）で締める定番例です。'),
  ('b1000003-0000-4000-8000-000000000048'::uuid, 'terry', 'modern', '【テスト】DI始動ライジングSA3例', '["sys_di","terry_m_auto_h","terry_m_6sp","terry_m_sa3"]'::jsonb, 'terry:modern:sys_di>terry_m_auto_h>terry_m_6sp>terry_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットからアシスト強・前必（ライジング）経由でSA3へ繋ぐ例です。')
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
