-- =============================================================================
-- Migration: 026_seed_test_combos_batch2.sql
-- 目的: 試験運用向け 動作確認用テストコンボデータ（バッチ2: 公式順9〜16キャラ）を投入する
-- 対象: deejay, cammy, ryu, ehonda, blanka, guile, ken, chun-li
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
  -- deejay
  ('b1000002-0000-4000-8000-000000000001'::uuid, 'deejay', 'classic', '【テスト】弱始動ソバット基本例', '["deejay_5lp","deejay_5lp","deejay_236mk"]'::jsonb, 'deejay:classic:deejay_5lp>deejay_5lp>deejay_236mk', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱P連打からクイックローリングソバットで締める基本例です。'),
  ('b1000002-0000-4000-8000-000000000002'::uuid, 'deejay', 'classic', '【テスト】屈中Pラッシュ定番例', '["deejay_2mp","sys_dr","deejay_5mp","deejay_5hp","deejay_236mk"]'::jsonb, 'deejay:classic:deejay_2mp>sys_dr>deejay_5mp>deejay_5hp>deejay_236mk', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中Pラッシュからソバットへ繋ぐ表記確認向けの定番例です。'),
  ('b1000002-0000-4000-8000-000000000003'::uuid, 'deejay', 'classic', '【テスト】DI始動マシンガンSA3例', '["sys_di","deejay_5hp","deejay_214mp","deejay_sa3"]'::jsonb, 'deejay:classic:sys_di>deejay_5hp>deejay_214mp>deejay_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから中マシンガンアッパー経由でSA3へ繋ぐ高火力例です。'),
  ('b1000002-0000-4000-8000-000000000004'::uuid, 'deejay', 'modern', '【テスト】弱始動ソバット基本例', '["deejay_m_5l","deejay_m_5l","deejay_m_6sp"]'::jsonb, 'deejay:modern:deejay_m_5l>deejay_m_5l>deejay_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱から前必（クイックローリングソバット）へ繋ぐ基本例です。'),
  ('b1000002-0000-4000-8000-000000000005'::uuid, 'deejay', 'modern', '【テスト】A中ラッシュ定番ルート例', '["deejay_m_auto_m","sys_dr","deejay_m_2h","deejay_m_4h","deejay_m_6sp"]'::jsonb, 'deejay:modern:deejay_m_auto_m>sys_dr>deejay_m_2h>deejay_m_4h>deejay_m_6sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。アシスト中ラッシュから4強・前必で締めるモダン定番例です。'),
  ('b1000002-0000-4000-8000-000000000006'::uuid, 'deejay', 'modern', '【テスト】DI始動ソバットSA3例', '["sys_di","deejay_m_4h","deejay_m_6sp","deejay_m_sa3"]'::jsonb, 'deejay:modern:sys_di>deejay_m_4h>deejay_m_6sp>deejay_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから4強・前必経由でSA3へ繋ぐ高火力サンプルです。'),
  -- cammy
  ('b1000002-0000-4000-8000-000000000007'::uuid, 'cammy', 'classic', '【テスト】弱始動アローの基本例', '["cammy_2lp","cammy_2lp","cammy_236lk"]'::jsonb, 'cammy:classic:cammy_2lp>cammy_2lp>cammy_236lk', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱Pから弱スパイラルアローへ繋ぐノーゲージ基本例です。'),
  ('b1000002-0000-4000-8000-000000000008'::uuid, 'cammy', 'classic', '【テスト】中足ラッシュ定番ルート例', '["cammy_2mk","sys_dr","cammy_5mp","cammy_5hp","cammy_236hk"]'::jsonb, 'cammy:classic:cammy_2mk>sys_dr>cammy_5mp>cammy_5hp>cammy_236hk', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。中足キャンセルラッシュから強アローで起き攻めへ繋ぐ定番例です。'),
  ('b1000002-0000-4000-8000-000000000009'::uuid, 'cammy', 'classic', '【テスト】DI始動アローSA3締め例', '["sys_di","cammy_5hp","cammy_236hk","cammy_sa3"]'::jsonb, 'cammy:classic:sys_di>cammy_5hp>cammy_236hk>cammy_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから5強P・強アロー経由でSA3へ繋ぐ高火力例です。'),
  ('b1000002-0000-4000-8000-000000000010'::uuid, 'cammy', 'modern', '【テスト】弱始動N必アロー基本例', '["cammy_m_5l","cammy_m_5l","cammy_m_sp"]'::jsonb, 'cammy:modern:cammy_m_5l>cammy_m_5l>cammy_m_sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱からN必（中スパイラルアロー）で締めるモダン基本例です。'),
  ('b1000002-0000-4000-8000-000000000011'::uuid, 'cammy', 'modern', '【テスト】屈中ラッシュアロー締め例', '["cammy_m_2m","sys_dr","cammy_m_5m","cammy_m_auto_h","cammy_m_sp"]'::jsonb, 'cammy:modern:cammy_m_2m>sys_dr>cammy_m_5m>cammy_m_auto_h>cammy_m_sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中ラッシュからアシスト強・N必へ繋ぐ定番サンプルです。'),
  ('b1000002-0000-4000-8000-000000000012'::uuid, 'cammy', 'modern', '【テスト】DI始動スパイクSA3例', '["sys_di","cammy_m_auto_h","cammy_m_6sp","cammy_m_sa3"]'::jsonb, 'cammy:modern:sys_di>cammy_m_auto_h>cammy_m_6sp>cammy_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットからアシスト強・前必（スパイク）経由でSA3へ繋ぐ例です。'),
  -- ryu
  ('b1000002-0000-4000-8000-000000000013'::uuid, 'ryu', 'classic', '【テスト】弱始動の弱竜巻基本例', '["ryu_2lp","ryu_2lp","ryu_214lk"]'::jsonb, 'ryu:classic:ryu_2lp>ryu_2lp>ryu_214lk', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱Pから弱竜巻旋風脚で起き攻めを作る基本例です。'),
  ('b1000002-0000-4000-8000-000000000014'::uuid, 'ryu', 'classic', '【テスト】中足ラッシュ昇龍締め例', '["ryu_2mk","sys_dr","ryu_5mp","ryu_2hp","ryu_623hp"]'::jsonb, 'ryu:classic:ryu_2mk>sys_dr>ryu_5mp>ryu_2hp>ryu_623hp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。中足キャンセルラッシュから強昇龍拳へ繋ぐ定番ルート例です。'),
  ('b1000002-0000-4000-8000-000000000015'::uuid, 'ryu', 'classic', '【テスト】DI始動の電刃波掌SA3例', '["sys_di","ryu_5hp","ryu_214p_ex","ryu_sa3"]'::jsonb, 'ryu:classic:sys_di>ryu_5hp>ryu_214p_ex>ryu_sa3', array['di_hit', 'ryu_denjin']::text[], 'optimal', null::int, 1.0, 3, 1, 0, false, '※動作確認用のテストデータです。電刃練気ストックを消費した強化版波掌撃からSA3へ繋ぐ例です。'),
  ('b1000002-0000-4000-8000-000000000016'::uuid, 'ryu', 'modern', '【テスト】弱始動のワンボタン昇龍例', '["ryu_m_5l","ryu_m_5l","ryu_m_6sp"]'::jsonb, 'ryu:modern:ryu_m_5l>ryu_m_5l>ryu_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱連打から前必（強昇龍拳）で締めるモダン基本例です。'),
  ('b1000002-0000-4000-8000-000000000017'::uuid, 'ryu', 'modern', '【テスト】屈中ラッシュ竜巻締め例', '["ryu_m_2m","sys_dr","ryu_m_5m","ryu_m_2h","ryu_m_4sp"]'::jsonb, 'ryu:modern:ryu_m_2m>sys_dr>ryu_m_5m>ryu_m_2h>ryu_m_4sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中ラッシュから後必（中竜巻旋風脚）で締める定番例です。'),
  ('b1000002-0000-4000-8000-000000000018'::uuid, 'ryu', 'modern', '【テスト】DI始動の電刃N必SA3例', '["sys_di","ryu_m_5h","ryu_m_sp_ex","ryu_m_sa3"]'::jsonb, 'ryu:modern:sys_di>ryu_m_5h>ryu_m_sp_ex>ryu_m_sa3', array['di_hit', 'ryu_denjin']::text[], 'optimal', null::int, 1.0, 3, 1, 0, false, '※動作確認用のテストデータです。電刃練気消費の強化版N必（波動拳）からSA3へ繋ぐ高火力例です。'),
  -- ehonda
  ('b1000002-0000-4000-8000-000000000019'::uuid, 'ehonda', 'classic', '【テスト】弱始動の百裂張り手基本例', '["ehonda_2lp","ehonda_2lp","ehonda_214lp"]'::jsonb, 'ehonda:classic:ehonda_2lp>ehonda_2lp>ehonda_214lp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱Pから弱百裂張り手へ繋ぐノーゲージ基本例です。'),
  ('b1000002-0000-4000-8000-000000000020'::uuid, 'ehonda', 'classic', '【テスト】立ち中Pラッシュ頭突き例', '["ehonda_5mp","sys_dr","ehonda_5mp","ehonda_5hp","ehonda_46hp"]'::jsonb, 'ehonda:classic:ehonda_5mp>sys_dr>ehonda_5mp>ehonda_5hp>ehonda_46hp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち中Pラッシュから強スーパー頭突きで締める定番サンプルです。'),
  ('b1000002-0000-4000-8000-000000000021'::uuid, 'ehonda', 'classic', '【テスト】DI始動の相撲魂SA3締め例', '["sys_di","ehonda_5hp","ehonda_214hp_ex","ehonda_sa3"]'::jsonb, 'ehonda:classic:sys_di>ehonda_5hp>ehonda_214hp_ex>ehonda_sa3', array['di_hit', 'ehonda_sumo_spirit']::text[], 'optimal', null::int, 1.0, 3, 1, 0, false, '※動作確認用のテストデータです。相撲魂を消費する強化版強百裂張り手からSA3へ繋ぐ例です。'),
  ('b1000002-0000-4000-8000-000000000022'::uuid, 'ehonda', 'modern', '【テスト】弱始動N必張り手基本例', '["ehonda_m_2l","ehonda_m_2l","ehonda_m_sp"]'::jsonb, 'ehonda:modern:ehonda_m_2l>ehonda_m_2l>ehonda_m_sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱からN必（弱百裂張り手）で締めるモダン基本例です。'),
  ('b1000002-0000-4000-8000-000000000023'::uuid, 'ehonda', 'modern', '【テスト】立ち中ラッシュ頭突き締め例', '["ehonda_m_5m","sys_dr","ehonda_m_5m","ehonda_m_5h","ehonda_m_4sp"]'::jsonb, 'ehonda:modern:ehonda_m_5m>sys_dr>ehonda_m_5m>ehonda_m_5h>ehonda_m_4sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち中ラッシュから後必（中スーパー頭突き）へ繋ぐ定番例です。'),
  ('b1000002-0000-4000-8000-000000000024'::uuid, 'ehonda', 'modern', '【テスト】DI始動の相撲魂N必SA3例', '["sys_di","ehonda_m_5h","ehonda_m_sp_ex","ehonda_m_sa3"]'::jsonb, 'ehonda:modern:sys_di>ehonda_m_5h>ehonda_m_sp_ex>ehonda_m_sa3', array['di_hit', 'ehonda_sumo_spirit']::text[], 'optimal', null::int, 1.0, 3, 1, 0, false, '※動作確認用のテストデータです。相撲魂消費の強化版N必（張り手）からSA3へ繋ぐ高火力例です。'),
  -- blanka
  ('b1000002-0000-4000-8000-000000000025'::uuid, 'blanka', 'classic', '【テスト】弱K始動の電撃基本例', '["blanka_5lk","blanka_5lk","blanka_214p"]'::jsonb, 'blanka:classic:blanka_5lk>blanka_5lk>blanka_214p', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱K連打からエレクトリックサンダーへ繋ぐ基本サンプルです。'),
  ('b1000002-0000-4000-8000-000000000026'::uuid, 'blanka', 'classic', '【テスト】中足ラッシュ電撃締め例', '["blanka_2mk","sys_dr","blanka_4mk","blanka_5hp","blanka_214p"]'::jsonb, 'blanka:classic:blanka_2mk>sys_dr>blanka_4mk>blanka_5hp>blanka_214p', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。中足ラッシュからワイルドエッジ・5強P・電撃へ繋ぐ定番例です。'),
  ('b1000002-0000-4000-8000-000000000027'::uuid, 'blanka', 'classic', '【テスト】DI始動の電撃SA3締め例', '["sys_di","blanka_5hp","blanka_214p","blanka_sa3"]'::jsonb, 'blanka:classic:sys_di>blanka_5hp>blanka_214p>blanka_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから5強P・電撃経由でSA3へ繋ぐ高火力サンプルです。'),
  ('b1000002-0000-4000-8000-000000000028'::uuid, 'blanka', 'modern', '【テスト】A弱始動N必電撃の基本例', '["blanka_m_auto_l","blanka_m_auto_l2","blanka_m_sp"]'::jsonb, 'blanka:modern:blanka_m_auto_l>blanka_m_auto_l2>blanka_m_sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。アシスト弱連打からN必（電撃）で締めるモダン基本サンプルです。'),
  ('b1000002-0000-4000-8000-000000000029'::uuid, 'blanka', 'modern', '【テスト】屈中ラッシュ電撃締め例', '["blanka_m_2m","sys_dr","blanka_m_4m","blanka_m_auto_h","blanka_m_sp"]'::jsonb, 'blanka:modern:blanka_m_2m>sys_dr>blanka_m_4m>blanka_m_auto_h>blanka_m_sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中ラッシュから4中・アシスト強・N必へ繋ぐ定番例です。'),
  ('b1000002-0000-4000-8000-000000000030'::uuid, 'blanka', 'modern', '【テスト】DI始動ローリングSA3例', '["sys_di","blanka_m_auto_h","blanka_m_4sp","blanka_m_sa3"]'::jsonb, 'blanka:modern:sys_di>blanka_m_auto_h>blanka_m_4sp>blanka_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットからアシスト強・後必（ローリング）経由でSA3へ繋ぐ例です。'),
  -- guile
  ('b1000002-0000-4000-8000-000000000031'::uuid, 'guile', 'classic', '【テスト】弱始動サマーの基本例', '["guile_2lp","guile_2lp","guile_28hk"]'::jsonb, 'guile:classic:guile_2lp>guile_2lp>guile_28hk', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱Pから強サマーソルトキックへ繋ぐ基本ルート例です。'),
  ('b1000002-0000-4000-8000-000000000032'::uuid, 'guile', 'classic', '【テスト】屈中Pラッシュサマー締め例', '["guile_2mp","sys_dr","guile_5mp","guile_2mp","guile_28hk"]'::jsonb, 'guile:classic:guile_2mp>sys_dr>guile_5mp>guile_2mp>guile_28hk', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中Pラッシュから溜めを作って強サマーで締める定番例です。'),
  ('b1000002-0000-4000-8000-000000000033'::uuid, 'guile', 'classic', '【テスト】DI始動サマーSA3締め例', '["sys_di","guile_5mp","guile_tc_5mp","guile_28hk","guile_sa3"]'::jsonb, 'guile:classic:sys_di>guile_5mp>guile_tc_5mp>guile_28hk>guile_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。リコイルキャノンから強サマー経由でSA3へ繋ぐ高火力例です。'),
  ('b1000002-0000-4000-8000-000000000034'::uuid, 'guile', 'modern', '【テスト】弱始動ワンボタンサマー例', '["guile_m_2l","guile_m_2l","guile_m_2sp"]'::jsonb, 'guile:modern:guile_m_2l>guile_m_2l>guile_m_2sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱から下必（中サマーソルトキック）へ繋ぐ基本例です。'),
  ('b1000002-0000-4000-8000-000000000035'::uuid, 'guile', 'modern', '【テスト】A中ラッシュサマー締め例', '["guile_m_auto_m","sys_dr","guile_m_auto_h","guile_m_auto_m","guile_m_2sp"]'::jsonb, 'guile:modern:guile_m_auto_m>sys_dr>guile_m_auto_h>guile_m_auto_m>guile_m_2sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。アシスト中ラッシュから下必（サマー）で締めるモダン定番例です。'),
  ('b1000002-0000-4000-8000-000000000036'::uuid, 'guile', 'modern', '【テスト】DI始動サマーSA3締め例', '["sys_di","guile_m_auto_h","guile_m_tc_ah","guile_m_2sp","guile_m_sa3"]'::jsonb, 'guile:modern:sys_di>guile_m_auto_h>guile_m_tc_ah>guile_m_2sp>guile_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。リコイルキャノンから下必サマー経由でSA3へ繋ぐ高火力例です。'),
  -- ken
  ('b1000002-0000-4000-8000-000000000037'::uuid, 'ken', 'classic', '【テスト】顎撥二連から強竜巻の基本例', '["ken_5mp","ken_tc_5mp_5hp","ken_214hk"]'::jsonb, 'ken:classic:ken_5mp>ken_tc_5mp_5hp>ken_214hk', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。顎撥二連から強竜巻旋風脚で運ぶノーゲージ基本ルート例です。'),
  ('b1000002-0000-4000-8000-000000000038'::uuid, 'ken', 'classic', '【テスト】中足ラッシュ奮迅竜巻例', '["ken_2mk","sys_dr","ken_5mp","ken_tc_5mp_5hp","ken_funjin","ken_funjin_tatsu"]'::jsonb, 'ken:classic:ken_2mk>sys_dr>ken_5mp>ken_tc_5mp_5hp>ken_funjin>ken_funjin_tatsu', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。中足ラッシュから顎撥二連・奮迅竜巻で端へ運ぶ定番例です。'),
  ('b1000002-0000-4000-8000-000000000039'::uuid, 'ken', 'classic', '【テスト】DI始動の昇龍SA3締め例', '["sys_di","ken_5hp","ken_623hp","ken_sa3"]'::jsonb, 'ken:classic:sys_di>ken_5hp>ken_623hp>ken_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから5強P・強昇龍拳経由でSA3へ繋ぐ高火力例です。'),
  ('b1000002-0000-4000-8000-000000000040'::uuid, 'ken', 'modern', '【テスト】顎撥二連から前必昇龍例', '["ken_m_auto_m","ken_m_tc_am","ken_m_6sp"]'::jsonb, 'ken:modern:ken_m_auto_m>ken_m_tc_am>ken_m_6sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。顎撥二連から前必（中昇龍拳）で締めるモダン基本サンプルです。'),
  ('b1000002-0000-4000-8000-000000000041'::uuid, 'ken', 'modern', '【テスト】屈中ラッシュ奮迅竜巻例', '["ken_m_2m","sys_dr","ken_m_auto_m","ken_m_tc_am","ken_m_funjin","ken_m_sp_funjin_tatsu"]'::jsonb, 'ken:modern:ken_m_2m>sys_dr>ken_m_auto_m>ken_m_tc_am>ken_m_funjin>ken_m_sp_funjin_tatsu', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中ラッシュから奮迅下必（奮迅竜巻）で運ぶ定番例です。'),
  ('b1000002-0000-4000-8000-000000000042'::uuid, 'ken', 'modern', '【テスト】DI始動の昇龍SA3締め例', '["sys_di","ken_m_auto_h","ken_m_6sp","ken_m_sa3"]'::jsonb, 'ken:modern:sys_di>ken_m_auto_h>ken_m_6sp>ken_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットからアシスト強・前必（昇龍拳）経由でSA3へ繋ぐ例です。'),
  -- chun-li
  ('b1000002-0000-4000-8000-000000000043'::uuid, 'chun-li', 'classic', '【テスト】弱始動の百裂脚基本例', '["chunli_2lp","chunli_2lp","chunli_236lk"]'::jsonb, 'chun-li:classic:chunli_2lp>chunli_2lp>chunli_236lk', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ弱Pから弱百裂脚へ繋ぐノーゲージ基本サンプルです。'),
  ('b1000002-0000-4000-8000-000000000044'::uuid, 'chun-li', 'classic', '【テスト】中足ラッシュSBK締め例', '["chunli_2mk","sys_dr","chunli_5mp","chunli_2mp","chunli_28mk"]'::jsonb, 'chun-li:classic:chunli_2mk>sys_dr>chunli_5mp>chunli_2mp>chunli_28mk', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。中足ラッシュから中スピニングバードキックで締める定番例です。'),
  ('b1000002-0000-4000-8000-000000000045'::uuid, 'chun-li', 'classic', '【テスト】DI始動の百裂SA3締め例', '["sys_di","chunli_4hp","chunli_236mk","chunli_sa3"]'::jsonb, 'chun-li:classic:sys_di>chunli_4hp>chunli_236mk>chunli_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから発勁・中百裂脚経由でSA3へ繋ぐ高火力例です。'),
  ('b1000002-0000-4000-8000-000000000046'::uuid, 'chun-li', 'modern', '【テスト】弱始動N必百裂の基本例', '["chunli_m_5l","chunli_m_5l","chunli_m_sp"]'::jsonb, 'chun-li:modern:chunli_m_5l>chunli_m_5l>chunli_m_sp', array['midscreen']::text[], 'beginner', null::int, 0.0, 0, 0, 0, true, '※動作確認用のテストデータです。立ち弱からN必（弱百裂脚）へ繋ぐモダン基本サンプルです。'),
  ('b1000002-0000-4000-8000-000000000047'::uuid, 'chun-li', 'modern', '【テスト】屈中ラッシュ天昇脚締め例', '["chunli_m_2m","sys_dr","chunli_m_5m","chunli_m_4h","chunli_m_6sp"]'::jsonb, 'chun-li:modern:chunli_m_2m>sys_dr>chunli_m_5m>chunli_m_4h>chunli_m_6sp', array['midscreen']::text[], 'standard', null::int, 3.0, 0, 0, 0, true, '※動作確認用のテストデータです。しゃがみ中ラッシュから発勁・前必（強天昇脚）で締める定番例です。'),
  ('b1000002-0000-4000-8000-000000000048'::uuid, 'chun-li', 'modern', '【テスト】DI始動の百裂SA3締め例', '["sys_di","chunli_m_4h","chunli_m_sp","chunli_m_sa3"]'::jsonb, 'chun-li:modern:sys_di>chunli_m_4h>chunli_m_sp>chunli_m_sa3', array['di_hit']::text[], 'optimal', null::int, 1.0, 3, 0, 0, false, '※動作確認用のテストデータです。DIヒットから発勁・N必（弱百裂脚）経由でSA3へ繋ぐ高火力例です。')
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
