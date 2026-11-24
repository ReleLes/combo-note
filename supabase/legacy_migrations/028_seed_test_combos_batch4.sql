-- =============================================================================
-- Migration: 028_seed_test_combos_batch4.sql
-- 目的: 試験運用向け 動作確認用テストコンボデータ（バッチ4: 公式順25〜32キャラ）を投入する
-- 対象: mai, elena, sagat, c-viper, alex, ingrid, yasmine, arjun
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
  -- mai
  ('b1000004-0000-4000-8000-000000000001'::uuid, 'mai', 'classic', '【テスト】弱始動の忍蜂基本例', '["mai_5lp","mai_5lp","mai_236lk"]'::jsonb, 'mai:classic:mai_5lp>mai_5lp>mai_236lk', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱P連打から弱必殺忍蜂で運ぶノーゲージ基本例です。'),
  ('b1000004-0000-4000-8000-000000000002'::uuid, 'mai', 'classic', '【テスト】中足ラッシュ忍蜂締め例', '["mai_2mk","sys_dr","mai_2mp","mai_5hp","mai_236hk"]'::jsonb, 'mai:classic:mai_2mk>sys_dr>mai_2mp>mai_5hp>mai_236hk', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。中足キャンセルラッシュから強必殺忍蜂へ繋ぐ定番例です。'),
  ('b1000004-0000-4000-8000-000000000003'::uuid, 'mai', 'classic', '【テスト】DI始動の焔龍炎舞SA3例', '["sys_di","mai_5hp","mai_214hp_ex","mai_sa3"]'::jsonb, 'mai:classic:sys_di>mai_5hp>mai_214hp_ex>mai_sa3', array['di_hit', 'mai_flame_stock']::text[], 'optimal', null::int, 1.0, 3, 1, 0, false, '※動作確認用のテストデータです。焔ストックを消費した強化版強龍炎舞からSA3へ繋ぐ例です。'),
  ('b1000004-0000-4000-8000-000000000004'::uuid, 'mai', 'modern', '【テスト】弱始動の飛翔龍炎陣例', '["mai_m_2l","mai_m_2l","mai_m_6sp"]'::jsonb, 'mai:modern:mai_m_2l>mai_m_2l>mai_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱から前必（弱飛翔龍炎陣）で締めるモダン基本例です。'),
  ('b1000004-0000-4000-8000-000000000005'::uuid, 'mai', 'modern', '【テスト】屈中ラッシュ忍蜂締め例', '["mai_m_2m","sys_dr","mai_m_auto_m","mai_m_auto_h","mai_m_2sp"]'::jsonb, 'mai:modern:mai_m_2m>sys_dr>mai_m_auto_m>mai_m_auto_h>mai_m_2sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中ラッシュから下必（必殺忍蜂）へ繋ぐ定番例です。'),
  ('b1000004-0000-4000-8000-000000000006'::uuid, 'mai', 'modern', '【テスト】DI始動の焔忍蜂SA3例', '["sys_di","mai_m_auto_h","mai_m_2sp_ex","mai_m_sa3"]'::jsonb, 'mai:modern:sys_di>mai_m_auto_h>mai_m_2sp_ex>mai_m_sa3', array['di_hit', 'mai_flame_stock']::text[], 'optimal', null::int, 1.0, 3, 1, 0, false, '※動作確認用のテストデータです。焔ストック消費の強化版下必（忍蜂）からSA3へ繋ぐ例です。'),
  -- elena
  ('b1000004-0000-4000-8000-000000000007'::uuid, 'elena', 'classic', '【テスト】弱始動スクラッチ基本例', '["elena_2lp","elena_2lp","elena_623lk"]'::jsonb, 'elena:classic:elena_2lp>elena_2lp>elena_623lk', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱Pから弱スクラッチホイールへ繋ぐ基本例です。'),
  ('b1000004-0000-4000-8000-000000000008'::uuid, 'elena', 'classic', '【テスト】立ち中Kラッシュライノ例', '["elena_5mk","sys_dr","elena_5mk","elena_2hp","elena_236mk"]'::jsonb, 'elena:classic:elena_5mk>sys_dr>elena_5mk>elena_2hp>elena_236mk', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち中Kラッシュから2強P・中ライノホーンで締める定番例です。'),
  ('b1000004-0000-4000-8000-000000000009'::uuid, 'elena', 'classic', '【テスト】DI始動ライノSA3締め例', '["sys_di","elena_2hp","elena_236hk","elena_sa3"]'::jsonb, 'elena:classic:sys_di>elena_2hp>elena_236hk>elena_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから2強P・強ライノホーン経由でSA3へ繋ぐ例です。'),
  ('b1000004-0000-4000-8000-000000000010'::uuid, 'elena', 'modern', '【テスト】弱始動スクラッチ基本例', '["elena_m_2l","elena_m_2l","elena_m_6sp"]'::jsonb, 'elena:modern:elena_m_2l>elena_m_2l>elena_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱から前必（中スクラッチホイール）で締める基本例です。'),
  ('b1000004-0000-4000-8000-000000000011'::uuid, 'elena', 'modern', '【テスト】A中ラッシュライノ締め例', '["elena_m_auto_m","sys_dr","elena_m_auto_h","elena_m_2h","elena_m_sp"]'::jsonb, 'elena:modern:elena_m_auto_m>sys_dr>elena_m_auto_h>elena_m_2h>elena_m_sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。アシスト中ラッシュから2強・N必（ライノホーン）へ繋ぐ定番例です。'),
  ('b1000004-0000-4000-8000-000000000012'::uuid, 'elena', 'modern', '【テスト】DI始動ライノSA3締め例', '["sys_di","elena_m_2h","elena_m_sp","elena_m_sa3"]'::jsonb, 'elena:modern:sys_di>elena_m_2h>elena_m_sp>elena_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから2強・N必（弱ライノホーン）経由でSA3へ繋ぐ例です。'),
  -- sagat
  ('b1000004-0000-4000-8000-000000000013'::uuid, 'sagat', 'classic', '【テスト】弱始動タイガーアッパー例', '["sagat_2lp","sagat_2lp","sagat_623lp"]'::jsonb, 'sagat:classic:sagat_2lp>sagat_2lp>sagat_623lp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱Pから弱タイガーアッパーカットへ繋ぐ基本例です。'),
  ('b1000004-0000-4000-8000-000000000014'::uuid, 'sagat', 'classic', '【テスト】屈中Pラッシュニー締め例', '["sagat_2mp","sys_dr","sagat_5mp","sagat_2mp","sagat_236lk"]'::jsonb, 'sagat:classic:sagat_2mp>sys_dr>sagat_5mp>sagat_2mp>sagat_236lk', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中Pラッシュから弱タイガーニークラッシュへ繋ぐ定番例です。'),
  ('b1000004-0000-4000-8000-000000000015'::uuid, 'sagat', 'classic', '【テスト】DI始動アッパーSA3締め例', '["sys_di","sagat_5hk","sagat_623hp","sagat_sa3"]'::jsonb, 'sagat:classic:sys_di>sagat_5hk>sagat_623hp>sagat_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから5強K・強タイガーアッパー経由でSA3へ繋ぐ例です。'),
  ('b1000004-0000-4000-8000-000000000016'::uuid, 'sagat', 'modern', '【テスト】弱始動タイガーアッパー例', '["sagat_m_2l","sagat_m_2l","sagat_m_6sp"]'::jsonb, 'sagat:modern:sagat_m_2l>sagat_m_2l>sagat_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱から前必（弱タイガーアッパー）で締める基本例です。'),
  ('b1000004-0000-4000-8000-000000000017'::uuid, 'sagat', 'modern', '【テスト】A中ラッシュニー締め例', '["sagat_m_auto_m","sys_dr","sagat_m_2m","sagat_m_auto_m","sagat_m_sp"]'::jsonb, 'sagat:modern:sagat_m_auto_m>sys_dr>sagat_m_2m>sagat_m_auto_m>sagat_m_sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。アシスト中ラッシュからN必（中ニークラッシュ）で締める定番例です。'),
  ('b1000004-0000-4000-8000-000000000018'::uuid, 'sagat', 'modern', '【テスト】DI始動アッパーSA3締め例', '["sys_di","sagat_m_auto_h","sagat_m_6sp","sagat_m_sa3"]'::jsonb, 'sagat:modern:sys_di>sagat_m_auto_h>sagat_m_6sp>sagat_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットからアシスト強・前必アッパー経由でSA3へ繋ぐ例です。'),
  -- c-viper
  ('b1000004-0000-4000-8000-000000000019'::uuid, 'c-viper', 'classic', '【テスト】弱始動サンダーの基本例', '["cviper_2lp","cviper_2lp","cviper_214hp"]'::jsonb, 'c-viper:classic:cviper_2lp>cviper_2lp>cviper_214hp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱Pから強サンダースラップへ繋ぐ基本サンプルです。'),
  ('b1000004-0000-4000-8000-000000000020'::uuid, 'c-viper', 'classic', '【テスト】屈中Pラッシュサンダー例', '["cviper_2mp","sys_dr","cviper_5mp","cviper_2hp","cviper_214mp"]'::jsonb, 'c-viper:classic:cviper_2mp>sys_dr>cviper_5mp>cviper_2hp>cviper_214mp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中Pラッシュから2強P・中サンダースラップへ繋ぐ定番例です。'),
  ('b1000004-0000-4000-8000-000000000021'::uuid, 'c-viper', 'classic', '【テスト】DI始動サンダーSA3例', '["sys_di","cviper_2hp","cviper_214mp","cviper_sa3"]'::jsonb, 'c-viper:classic:sys_di>cviper_2hp>cviper_214mp>cviper_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから2強P・中サンダースラップ経由でSA3へ繋ぐ例です。'),
  ('b1000004-0000-4000-8000-000000000022'::uuid, 'c-viper', 'modern', '【テスト】弱始動サンダーの基本例', '["cviper_m_5l","cviper_m_5l","cviper_m_6sp"]'::jsonb, 'c-viper:modern:cviper_m_5l>cviper_m_5l>cviper_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱から前必（強サンダースラップ）で締めるモダン基本例です。'),
  ('b1000004-0000-4000-8000-000000000023'::uuid, 'c-viper', 'modern', '【テスト】A中ラッシュサンダー例', '["cviper_m_auto_m","sys_dr","cviper_m_auto_m","cviper_m_2h","cviper_m_6sp"]'::jsonb, 'c-viper:modern:cviper_m_auto_m>sys_dr>cviper_m_auto_m>cviper_m_2h>cviper_m_6sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。アシスト中ラッシュから2強・前必（強サンダー）へ繋ぐ定番例です。'),
  ('b1000004-0000-4000-8000-000000000024'::uuid, 'c-viper', 'modern', '【テスト】DI始動サンダーSA3例', '["sys_di","cviper_m_2h","cviper_m_214m","cviper_m_sa3"]'::jsonb, 'c-viper:modern:sys_di>cviper_m_2h>cviper_m_214m>cviper_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから2強・中サンダースラップ経由でSA3へ繋ぐ例です。'),
  -- alex
  ('b1000004-0000-4000-8000-000000000025'::uuid, 'alex', 'classic', '【テスト】弱始動アックスの基本例', '["alex_5lp","alex_5lp","alex_236lp"]'::jsonb, 'alex:classic:alex_5lp>alex_5lp>alex_236lp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱P連打から弱フラッシュアックスへ繋ぐ基本サンプルです。'),
  ('b1000004-0000-4000-8000-000000000026'::uuid, 'alex', 'classic', '【テスト】立ち中Pラッシュアックス例', '["alex_5mp","sys_dr","alex_2mk","alex_2hp","alex_236mp"]'::jsonb, 'alex:classic:alex_5mp>sys_dr>alex_2mk>alex_2hp>alex_236mp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち中Pラッシュから2強P・中フラッシュアックスで締める定番例です。'),
  ('b1000004-0000-4000-8000-000000000027'::uuid, 'alex', 'classic', '【テスト】DI始動アックスSA3例', '["sys_di","alex_2hp","alex_236mp","alex_sa3"]'::jsonb, 'alex:classic:sys_di>alex_2hp>alex_236mp>alex_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから2強P・中フラッシュアックス経由でSA3へ繋ぐ例です。'),
  ('b1000004-0000-4000-8000-000000000028'::uuid, 'alex', 'modern', '【テスト】立ち中N必アックス基本例', '["alex_m_5m","alex_m_sp"]'::jsonb, 'alex:modern:alex_m_5m>alex_m_sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち中からN必（中フラッシュアックス）へ繋ぐモダン基本例です。'),
  ('b1000004-0000-4000-8000-000000000029'::uuid, 'alex', 'modern', '【テスト】立ち中ラッシュアックス例', '["alex_m_5m","sys_dr","alex_m_2m","alex_m_2h","alex_m_sp"]'::jsonb, 'alex:modern:alex_m_5m>sys_dr>alex_m_2m>alex_m_2h>alex_m_sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち中ラッシュから2強・N必（中アックス）へ繋ぐ定番例です。'),
  ('b1000004-0000-4000-8000-000000000030'::uuid, 'alex', 'modern', '【テスト】DI始動アックスSA3例', '["sys_di","alex_m_2h","alex_m_sp","alex_m_sa3"]'::jsonb, 'alex:modern:sys_di>alex_m_2h>alex_m_sp>alex_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから2強・N必（中アックス）経由でSA3へ繋ぐ例です。'),
  -- ingrid
  ('b1000004-0000-4000-8000-000000000031'::uuid, 'ingrid', 'classic', '【テスト】弱始動サンライズ基本例', '["ingrid_2lp","ingrid_2lp","ingrid_236lk"]'::jsonb, 'ingrid:classic:ingrid_2lp>ingrid_2lp>ingrid_236lk', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱Pから弱サンライズへ繋ぐノーゲージ基本例です。'),
  ('b1000004-0000-4000-8000-000000000032'::uuid, 'ingrid', 'classic', '【テスト】中足ラッシュサンライズ例', '["ingrid_2mk","sys_dr","ingrid_2mp","ingrid_5mk","ingrid_236mk"]'::jsonb, 'ingrid:classic:ingrid_2mk>sys_dr>ingrid_2mp>ingrid_5mk>ingrid_236mk', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。中足キャンセルラッシュから中サンライズで締める定番例です。'),
  ('b1000004-0000-4000-8000-000000000033'::uuid, 'ingrid', 'classic', '【テスト】DI始動サンフレアSA3例', '["sys_di","ingrid_2hp","ingrid_214hp_lv2","ingrid_sa3"]'::jsonb, 'ingrid:classic:sys_di>ingrid_2hp>ingrid_214hp_lv2>ingrid_sa3', array['di_hit', 'ingrid_sun_symbol']::text[], 'optimal', null::int, 1.0, 3, 1, 0, false, '※動作確認用のテストデータです。サンシンボルを1消費する強化版サンフレアからSA3へ繋ぐ例です。'),
  ('b1000004-0000-4000-8000-000000000034'::uuid, 'ingrid', 'modern', '【テスト】A弱始動サンライズ基本例', '["ingrid_m_auto_l","ingrid_m_auto_l","ingrid_m_6sp"]'::jsonb, 'ingrid:modern:ingrid_m_auto_l>ingrid_m_auto_l>ingrid_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。アシスト弱から前必（弱サンライズ）へ繋ぐモダン基本例です。'),
  ('b1000004-0000-4000-8000-000000000035'::uuid, 'ingrid', 'modern', '【テスト】屈中ラッシュサンフレア例', '["ingrid_m_2m","sys_dr","ingrid_m_auto_m","ingrid_m_5m","ingrid_m_2sp"]'::jsonb, 'ingrid:modern:ingrid_m_2m>sys_dr>ingrid_m_auto_m>ingrid_m_5m>ingrid_m_2sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中ラッシュから下必（サンフレア）で締める定番例です。'),
  ('b1000004-0000-4000-8000-000000000036'::uuid, 'ingrid', 'modern', '【テスト】DI始動サンフレアSA3例', '["sys_di","ingrid_m_2h","ingrid_m_3sp_lv2","ingrid_m_sa3"]'::jsonb, 'ingrid:modern:sys_di>ingrid_m_2h>ingrid_m_3sp_lv2>ingrid_m_sa3', array['di_hit', 'ingrid_sun_symbol']::text[], 'optimal', null::int, 1.0, 3, 1, 0, false, '※動作確認用のテストデータです。サンシンボル消費の強化版右下必からSA3へ繋ぐ高火力例です。'),
  -- yasmine
  ('b1000004-0000-4000-8000-000000000037'::uuid, 'yasmine', 'classic', '【テスト】弱始動リパの基本サンプル', '["yasmine_2lp","yasmine_2lp","yasmine_623lk"]'::jsonb, 'yasmine:classic:yasmine_2lp>yasmine_2lp>yasmine_623lk', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱Pから弱リパ・ン・アギラで締める基本サンプルです。'),
  ('b1000004-0000-4000-8000-000000000038'::uuid, 'yasmine', 'classic', '【テスト】中足ラッシュアロン締め例', '["yasmine_2mk","sys_dr","yasmine_2mp","yasmine_2hp","yasmine_236mp","yasmine_aron_m"]'::jsonb, 'yasmine:classic:yasmine_2mk>sys_dr>yasmine_2mp>yasmine_2hp>yasmine_236mp>yasmine_aron_m', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 1, true, '※動作確認用のテストデータです。中足ラッシュから中アロンでバヤニ・モードを獲得する定番例です。'),
  ('b1000004-0000-4000-8000-000000000039'::uuid, 'yasmine', 'classic', '【テスト】DI始動強化アロンSA3例', '["sys_di","yasmine_5hp","yasmine_236hp","yasmine_aron_h_ex","yasmine_sa3"]'::jsonb, 'yasmine:classic:sys_di>yasmine_5hp>yasmine_236hp>yasmine_aron_h_ex>yasmine_sa3', array['di_hit', 'yasmine_bayani']::text[], 'optimal', null::int, 1.0, 3, 1, 0, false, '※動作確認用のテストデータです。バヤニ消費の強化版強アロンからSA3へ繋ぐ高火力サンプルです。'),
  ('b1000004-0000-4000-8000-000000000040'::uuid, 'yasmine', 'modern', '【テスト】弱始動リパの基本サンプル', '["yasmine_m_2l","yasmine_m_2l","yasmine_m_6sp"]'::jsonb, 'yasmine:modern:yasmine_m_2l>yasmine_m_2l>yasmine_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱から前必（弱リパ・ン・アギラ）で締める基本例です。'),
  ('b1000004-0000-4000-8000-000000000041'::uuid, 'yasmine', 'modern', '【テスト】屈中ラッシュアロン締め例', '["yasmine_m_2m","sys_dr","yasmine_m_auto_m","yasmine_m_2h","yasmine_m_sp","yasmine_m_aron_m"]'::jsonb, 'yasmine:modern:yasmine_m_2m>sys_dr>yasmine_m_auto_m>yasmine_m_2h>yasmine_m_sp>yasmine_m_aron_m', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 1, true, '※動作確認用のテストデータです。しゃがみ中ラッシュからN必・中アロンでバヤニを獲得する定番例です。'),
  ('b1000004-0000-4000-8000-000000000042'::uuid, 'yasmine', 'modern', '【テスト】DI始動強化アロンSA3例', '["sys_di","yasmine_m_auto_h","yasmine_m_sp","yasmine_m_aron_m_ex","yasmine_m_sa3"]'::jsonb, 'yasmine:modern:sys_di>yasmine_m_auto_h>yasmine_m_sp>yasmine_m_aron_m_ex>yasmine_m_sa3', array['di_hit', 'yasmine_bayani']::text[], 'optimal', null::int, 1.0, 3, 1, 0, false, '※動作確認用のテストデータです。バヤニ消費の強化版中アロンからSA3へ繋ぐ高火力サンプルです。'),
  -- arjun
  ('b1000004-0000-4000-8000-000000000043'::uuid, 'arjun', 'classic', '【テスト】弱始動の巨腕基本サンプル', '["arjun_5lp","arjun_5lp","arjun_236lp"]'::jsonb, 'arjun:classic:arjun_5lp>arjun_5lp>arjun_236lp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱P連打から弱大義の巨腕へ繋ぐノーゲージ基本例です。'),
  ('b1000004-0000-4000-8000-000000000044'::uuid, 'arjun', 'classic', '【テスト】立ち中Kラッシュ巨腕追撃例', '["arjun_5mk","sys_dr","arjun_2mk","arjun_5mk","arjun_236mp","arjun_236p_followup"]'::jsonb, 'arjun:classic:arjun_5mk>sys_dr>arjun_2mk>arjun_5mk>arjun_236mp>arjun_236p_followup', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち中Kラッシュから中大義の巨腕・追撃まで繋ぐ定番例です。'),
  ('b1000004-0000-4000-8000-000000000045'::uuid, 'arjun', 'classic', '【テスト】DI始動の巨腕SA3締め例', '["sys_di","arjun_2hp","arjun_236mp","arjun_sa3"]'::jsonb, 'arjun:classic:sys_di>arjun_2hp>arjun_236mp>arjun_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから2強P・中大義の巨腕経由でSA3へ繋ぐ高火力例です。'),
  ('b1000004-0000-4000-8000-000000000046'::uuid, 'arjun', 'modern', '【テスト】弱始動N必巨腕の基本例', '["arjun_m_5l","arjun_m_5l","arjun_m_sp"]'::jsonb, 'arjun:modern:arjun_m_5l>arjun_m_5l>arjun_m_sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱からN必（弱大義の巨腕）へ繋ぐモダン基本サンプルです。'),
  ('b1000004-0000-4000-8000-000000000047'::uuid, 'arjun', 'modern', '【テスト】立ち中ラッシュ息吹締め例', '["arjun_m_5m","sys_dr","arjun_m_auto_m","arjun_m_5m","arjun_m_4sp","arjun_m_shinkan_m"]'::jsonb, 'arjun:modern:arjun_m_5m>sys_dr>arjun_m_auto_m>arjun_m_5m>arjun_m_4sp>arjun_m_shinkan_m', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち中ラッシュから後必（息吹の円筒）・中震撼へ繋ぐ定番例です。'),
  ('b1000004-0000-4000-8000-000000000048'::uuid, 'arjun', 'modern', '【テスト】DI始動の巨腕SA3締め例', '["sys_di","arjun_m_2h","arjun_m_sp","arjun_m_sa3"]'::jsonb, 'arjun:modern:sys_di>arjun_m_2h>arjun_m_sp>arjun_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから2強・N必（弱大義の巨腕）経由でSA3へ繋ぐ例です。')
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
