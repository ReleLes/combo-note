-- =============================================================================
-- コンボノート (Combo Note) 初期シードデータ投入 SQL
-- 対象: 初期4キャラクター（豪鬼・ジュリ・イングリッド・C.ヴァイパー）
-- ※ ON CONFLICT DO NOTHING により何度実行しても冪等に動作します
-- =============================================================================

-- 1. キャラクターマスタ
insert into public.characters (id, slug, name_ja, name_en, sort_order, is_active, stock_label, stock_short_label, stock_max_count)
values
  ('akuma', 'akuma', '豪鬼', 'Akuma', 1, true, null, null, null),
  ('juri', 'juri', 'ジュリ', 'Juri', 2, true, '風破ストック', '風破', 3),
  ('ingrid', 'ingrid', 'イングリッド', 'Ingrid', 3, true, 'サンシンボル', 'サンシンボル', 4),
  ('c-viper', 'c-viper', 'C.ヴァイパー', 'C. Viper', 4, true, null, null, null)
on conflict (id) do nothing;

-- 2. バージョンマスタ
insert into public.game_versions (id, label, released_at)
values
  ('year2', 'Year 2', '2024-05-22T00:00:00Z'),
  ('year3', 'Year 3', '2025-06-05T00:00:00Z'),
  ('year4', 'Year 4 / Ver.2026', '2026-06-01T00:00:00Z')
on conflict (id) do nothing;

-- 3. 技マスタ（システム共通パーツ: character_id = null）
insert into public.moves (id, character_id, control_type, category, notation_numpad, notation_command, notation_name, sort_order, startup_frames, hit_advantage, cancel_types)
values
  ('sys_dr', null, 'both', 'system', 'DR', 'キャンセルラッシュ', 'キャンセルドライブラッシュ', 1, null, null, null),
  ('sys_raw_dr', null, 'both', 'system', '生DR', '生ラッシュ', '生ドライブラッシュ', 2, null, null, null),
  ('sys_di', null, 'both', 'system', 'DI', 'DI', 'ドライブインパクト', 3, null, null, null),
  ('sys_micro_walk', null, 'both', 'system', '微歩き', '微歩き', '微歩き', 4, null, null, null),
  ('sys_dash', null, 'both', 'system', '66', '→→', '前ステップ', 5, null, null, null),
  ('sys_delay', null, 'both', 'system', 'ディレイ', 'ディレイ', 'ディレイ', 6, null, null, null),
  ('sys_jump', null, 'both', 'system', 'J', '↑', 'ジャンプ', 7, null, null, null),
  ('sys_f_jump', null, 'both', 'system', '前J', '↗', '前ジャンプ', 8, null, null, null),
  ('sys_jc', null, 'both', 'system', 'jc', 'jc', 'ジャンプキャンセル', 9, null, null, null)
on conflict (id) do nothing;

-- 3-1. 技マスタ（豪鬼 / akuma）
insert into public.moves (id, character_id, control_type, category, notation_numpad, notation_command, notation_name, sort_order, startup_frames, hit_advantage, cancel_types)
values
  ('akuma_2lp', 'akuma', 'classic', 'normal', '2弱P', '屈弱P', 'しゃがみ弱P', 10, 4, 4, array['special', 'super']),
  ('akuma_5lk', 'akuma', 'classic', 'normal', '5弱K', '立弱K', '立ち弱K', 11, 5, 2, array['special', 'super']),
  ('akuma_5mp', 'akuma', 'classic', 'normal', '5中P', '立中P', '立ち中P', 12, 6, 7, array['special', 'super']),
  ('akuma_2mp', 'akuma', 'classic', 'normal', '2中P', '屈中P', 'しゃがみ中P', 13, 6, 5, array['special', 'super']),
  ('akuma_2mk', 'akuma', 'classic', 'normal', '2中K', '屈中K', 'しゃがみ中K', 14, 8, 2, array['special', 'super']),
  ('akuma_5hp', 'akuma', 'classic', 'normal', '5大P', '立強P', '立ち強P', 15, 9, 3, array['special', 'super']),
  ('akuma_5hk', 'akuma', 'classic', 'normal', '5大K', '立強K', '立ち強K', 16, 13, 4, null),
  ('akuma_4hk', 'akuma', 'classic', 'unique', '4大K', '←+強K', '羅漢（後ろ強K）', 30, null, null, null),
  ('akuma_m_auto_m', 'akuma', 'modern', 'normal', 'A中', 'アシスト中', 'アシスト中（立中P）', 40, null, null, null),
  ('akuma_m_2m', 'akuma', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（屈中K）', 41, null, null, null),
  ('akuma_m_auto_h', 'akuma', 'modern', 'normal', 'A強', 'アシスト強', 'アシスト強（立強P）', 42, null, null, null),
  ('akuma_214lk', 'akuma', 'classic', 'special', '214弱K', '↓↙←+弱K', '弱竜巻斬空脚', 50, null, null, null),
  ('akuma_214hk', 'akuma', 'classic', 'special', '214大K', '↓↙←+強K', '強竜巻斬空脚', 51, null, null, null),
  ('akuma_214hp', 'akuma', 'classic', 'special', '214大P', '↓↙←+強P', '強金剛灼火', 52, null, null, null),
  ('akuma_214odp', 'akuma', 'classic', 'special', '214PP', '↓↙←+PP', 'OD金剛灼火', 53, null, null, null),
  ('akuma_623hp', 'akuma', 'classic', 'special', '623大P', '→↓↘+強P', '強豪昇龍拳', 54, null, null, null),
  ('akuma_236hk_dive', 'akuma', 'classic', 'special', '236大K>P', '↓↘→+強K>P', '百鬼襲〜百鬼豪刃', 55, null, null, null),
  ('akuma_m_4sp', 'akuma', 'modern', 'special', '4SP', '←+SP', '竜巻斬空脚（後SP）', 60, null, null, null),
  ('akuma_m_6sp', 'akuma', 'modern', 'special', '6SP', '→+SP', '豪昇龍拳（前SP）', 61, null, null, null),
  ('akuma_sa1', 'akuma', 'both', 'super', 'SA1', '↓↘→↓↘→+P', '滅殺豪波動（SA1）', 70, null, null, null),
  ('akuma_sa3', 'akuma', 'both', 'super', 'SA3', '↓↙←↓↙←+K', '禍坏（SA3）', 71, null, null, null)
on conflict (id) do nothing;

-- 3-2. 技マスタ（ジュリ / juri）
insert into public.moves (id, character_id, control_type, category, notation_numpad, notation_command, notation_name, sort_order, startup_frames, hit_advantage, cancel_types)
values
  ('juri_5lp', 'juri', 'classic', 'normal', '5弱P', '立弱P', '立ち弱P', 10, 4, 4, array['special', 'super']),
  ('juri_2lp', 'juri', 'classic', 'normal', '2弱P', '屈弱P', 'しゃがみ弱P', 11, 4, 4, array['special', 'super']),
  ('juri_5lk', 'juri', 'classic', 'normal', '5弱K', '立弱K', '立ち弱K', 12, 5, 3, array['special', 'super']),
  ('juri_5mp', 'juri', 'classic', 'normal', '5中P', '立中P', '立ち中P', 13, 6, 7, array['special', 'super']),
  ('juri_2mp', 'juri', 'classic', 'normal', '2中P', '屈中P', 'しゃがみ中P', 14, 6, 5, array['special', 'super']),
  ('juri_2mk', 'juri', 'classic', 'normal', '2中K', '屈中K', 'しゃがみ中K', 15, 7, 1, array['special', 'super']),
  ('juri_5hp', 'juri', 'classic', 'normal', '5大P', '立強P', '立ち強P', 16, 10, 2, array['special', 'super']),
  ('juri_2hp', 'juri', 'classic', 'normal', '2大P', '屈強P', 'しゃがみ強P', 17, 8, 1, array['special', 'super']),
  ('juri_5hk', 'juri', 'classic', 'normal', '5大K', '立強K', '立ち強K', 18, 17, 3, null),
  ('juri_jmp', 'juri', 'both', 'normal', 'J中P', 'J中P', 'ジャンプ中P', 19, null, null, null),
  ('juri_jmk', 'juri', 'classic', 'normal', 'J中K', 'J中K', 'ジャンプ中K', 20, null, null, null),
  ('juri_jhp', 'juri', 'classic', 'normal', 'J大P', 'J強P', 'ジャンプ強P', 21, null, null, null),
  ('juri_jhk', 'juri', 'both', 'normal', 'J大K', 'J強K', 'ジャンプ強K', 22, null, null, null),
  ('juri_6hp', 'juri', 'classic', 'unique', '6大P', '→+強P', '狂背掌', 30, null, null, null),
  ('juri_4hk', 'juri', 'classic', 'unique', '4大K', '←+強K', '鉤鎌脚', 31, null, null, null),
  ('juri_m_auto_m', 'juri', 'modern', 'normal', 'A中', 'アシスト中', 'アシスト中（立中P）', 40, null, null, null),
  ('juri_m_2m', 'juri', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（屈中K）', 41, null, null, null),
  ('juri_m_auto_h', 'juri', 'modern', 'normal', 'A強', 'アシスト強', 'アシスト強（立強P）', 42, null, null, null),
  ('juri_214lk', 'juri', 'classic', 'special', '214弱K', '↓↙←+弱K', '風破刃', 50, null, null, null),
  ('juri_236mk', 'juri', 'classic', 'special', '236中K', '↓↘→+中K', '暗剣殺', 51, null, null, null),
  ('juri_236hk', 'juri', 'classic', 'special', '236大K', '↓↘→+強K', '五黄殺', 52, null, null, null),
  ('juri_236odk', 'juri', 'classic', 'special', '236KK', '↓↘→+KK', 'OD暗剣殺', 53, null, null, null),
  ('juri_623hp', 'juri', 'classic', 'special', '623大P', '→↓↘+強P', '強天穿輪', 54, null, null, null),
  ('juri_214mk', 'juri', 'classic', 'special', '214中K', '↓↙←+中K', '中疾空閃', 55, null, null, null),
  ('juri_m_sp', 'juri', 'modern', 'special', 'SP', 'SP', '暗剣殺（SP）', 60, null, null, null),
  ('juri_m_6sp', 'juri', 'modern', 'special', '6SP', '→+SP', '天穿輪（前SP）', 61, null, null, null),
  ('juri_m_4sp', 'juri', 'modern', 'special', '4SP', '←+SP', '風破刃（後SP）', 62, null, null, null),
  ('juri_sa1', 'juri', 'both', 'super', 'SA1', '↓↙←↓↙←+K', '殺界風破斬（SA1）', 70, null, null, null),
  ('juri_sa2', 'juri', 'both', 'super', 'SA2', '↓↙←↓↙←+P', '風水エンジン（SA2）', 71, null, null, null),
  ('juri_sa3', 'juri', 'both', 'super', 'SA3', '↓↘→↓↘→+K', '回旋断界落（SA3）', 72, null, null, null)
on conflict (id) do nothing;

-- 3-3. 技マスタ（イングリッド / ingrid）
insert into public.moves (id, character_id, control_type, category, notation_numpad, notation_command, notation_name, sort_order, startup_frames, hit_advantage, cancel_types)
values
  ('ingrid_2lp', 'ingrid', 'classic', 'normal', '2弱P', '屈弱P', 'しゃがみ弱P', 10, 4, 4, array['special', 'super']),
  ('ingrid_5mp', 'ingrid', 'classic', 'normal', '5中P', '立中P', '立ち中P', 11, 6, 6, array['special', 'super']),
  ('ingrid_2mp', 'ingrid', 'classic', 'normal', '2中P', '屈中P', 'しゃがみ中P', 12, 6, 5, array['special', 'super']),
  ('ingrid_2mk', 'ingrid', 'classic', 'normal', '2中K', '屈中K', 'しゃがみ中K', 13, 7, 2, array['special', 'super']),
  ('ingrid_5hp', 'ingrid', 'classic', 'normal', '5大P', '立強P', '立ち強P', 14, 9, 3, array['special', 'super']),
  ('ingrid_2hp', 'ingrid', 'classic', 'normal', '2大P', '屈強P', 'しゃがみ強P', 15, 8, 1, array['special', 'super']),
  ('ingrid_jhk', 'ingrid', 'both', 'normal', 'J大K', 'J強K', 'ジャンプ強K', 16, null, null, null),
  ('ingrid_6mk', 'ingrid', 'classic', 'unique', '6中K', '→+中K', 'サンステップキック', 30, null, null, null),
  ('ingrid_m_auto_m', 'ingrid', 'modern', 'normal', 'A中', 'アシスト中', 'アシスト中（立中P）', 40, null, null, null),
  ('ingrid_m_2m', 'ingrid', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（屈中K）', 41, null, null, null),
  ('ingrid_m_auto_h', 'ingrid', 'modern', 'normal', 'A強', 'アシスト強', 'アシスト強（立強P）', 42, null, null, null),
  ('ingrid_236mp', 'ingrid', 'classic', 'special', '236中P', '↓↘→+中P', '中サンシュート', 50, null, null, null),
  ('ingrid_623hk', 'ingrid', 'classic', 'special', '623大K', '→↓↘+強K', '強サンライズ', 51, null, null, null),
  ('ingrid_214mk', 'ingrid', 'classic', 'special', '214中K', '↓↙←+中K', '中サンアーチ', 52, null, null, null),
  ('ingrid_214odk', 'ingrid', 'classic', 'special', '214KK', '↓↙←+KK', 'ODサンアーチ', 53, null, null, null),
  ('ingrid_air_214k', 'ingrid', 'classic', 'special', '空中214K', '空中↓↙←+K', 'サンダイブ', 54, null, null, null),
  ('ingrid_m_6sp', 'ingrid', 'modern', 'special', '6SP', '→+SP', 'サンライズ（前SP）', 60, null, null, null),
  ('ingrid_m_4sp', 'ingrid', 'modern', 'special', '4SP', '←+SP', 'サンアーチ（後SP）', 61, null, null, null),
  ('ingrid_sa1', 'ingrid', 'both', 'super', 'SA1', '↓↘→↓↘→+P', 'サンバースト（SA1）', 70, null, null, null),
  ('ingrid_sa3', 'ingrid', 'both', 'super', 'SA3', '↓↙←↓↙←+K', 'サンデルタ（SA3）', 71, null, null, null)
on conflict (id) do nothing;

-- 3-4. 技マスタ（C.ヴァイパー / c-viper）
insert into public.moves (id, character_id, control_type, category, notation_numpad, notation_command, notation_name, sort_order, startup_frames, hit_advantage, cancel_types)
values
  ('cviper_2lp', 'c-viper', 'classic', 'normal', '2弱P', '屈弱P', 'しゃがみ弱P', 10, 4, 4, array['special', 'super']),
  ('cviper_5mp', 'c-viper', 'classic', 'normal', '5中P', '立中P', '立ち中P', 11, 6, 6, array['special', 'super']),
  ('cviper_2mp', 'c-viper', 'classic', 'normal', '2中P', '屈中P', 'しゃがみ中P', 12, 6, 5, array['special', 'super']),
  ('cviper_2mk', 'c-viper', 'classic', 'normal', '2中K', '屈中K', 'しゃがみ中K', 13, 7, 1, array['special', 'super']),
  ('cviper_5hp', 'c-viper', 'classic', 'normal', '5大P', '立強P', '立ち強P', 14, 9, 3, array['special', 'super']),
  ('cviper_2hp', 'c-viper', 'classic', 'normal', '2大P', '屈強P', 'しゃがみ強P', 15, 8, 2, array['special', 'super']),
  ('cviper_fc', 'c-viper', 'classic', 'system', 'FC', 'フェイント', 'サンダーフェイントキャンセル', 25, null, null, null),
  ('cviper_hjc', 'c-viper', 'both', 'system', 'hjc', 'ハイジャンプ', 'ハイジャンプキャンセル', 26, null, null, null),
  ('cviper_m_auto_m', 'c-viper', 'modern', 'normal', 'A中', 'アシスト中', 'アシスト中（立中P）', 40, null, null, null),
  ('cviper_m_2m', 'c-viper', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（屈中K）', 41, null, null, null),
  ('cviper_m_auto_h', 'c-viper', 'modern', 'normal', 'A強', 'アシスト強', 'アシスト強（立強P）', 42, null, null, null),
  ('cviper_214mp', 'c-viper', 'classic', 'special', '214中P', '↓↙←+中P', '中サンダーナックル', 50, null, null, null),
  ('cviper_214hp', 'c-viper', 'classic', 'special', '214大P', '↓↙←+強P', '強サンダーナックル', 51, null, null, null),
  ('cviper_623hp', 'c-viper', 'classic', 'special', '623大P', '→↓↘+強P', '強セイスモハンマー', 52, null, null, null),
  ('cviper_623odp', 'c-viper', 'classic', 'special', '623PP', '→↓↘+PP', 'ODセイスモハンマー', 53, null, null, null),
  ('cviper_214hk', 'c-viper', 'classic', 'special', '214大K', '↓↙←+強K', '強バーニングキック', 54, null, null, null),
  ('cviper_air_214mk', 'c-viper', 'classic', 'special', '空中214中K', '空中↓↙←+中K', '空中バーニングキック', 55, null, null, null),
  ('cviper_m_sp', 'c-viper', 'modern', 'special', 'SP', 'SP', 'サンダーナックル（SP）', 60, null, null, null),
  ('cviper_m_4sp', 'c-viper', 'modern', 'special', '4SP', '←+SP', 'バーニングキック（後SP）', 61, null, null, null),
  ('cviper_sa1', 'c-viper', 'both', 'super', 'SA1', '↓↘→↓↘→+P', 'エマージェンシーコンビネーション（SA1）', 70, null, null, null),
  ('cviper_sa3', 'c-viper', 'both', 'super', 'SA3', '↓↙←↓↙←+P', 'バーストタイム（SA3）', 71, null, null, null)
on conflict (id) do nothing;

-- 4. 公開コンボ（初期サンプル 19件、author_id = null）
insert into public.combos (
  id, author_id, author_name, character_id, control_type,
  move_ids, recipe_signature, situations, category,
  damage, drive_cost, sa_cost, stock_cost, stock_gain,
  has_oki, note, version_id, likes_count, created_at, updated_at
)
values
  -- 豪鬼 (akuma)
  (
    '10000000-0000-4000-8000-000000000001',
    null, '運営シード', 'akuma', 'classic',
    '["akuma_2mk","sys_dr","akuma_2mp","akuma_5hp","akuma_214lk","akuma_623hp"]'::jsonb,
    'akuma:classic:akuma_2mk>sys_dr>akuma_2mp>akuma_5hp>akuma_214lk>akuma_623hp',
    array['midscreen'], 'standard',
    2740, 3.0, 0, 0, 0,
    true, '豪鬼の中央定番ラッシュコンボ。弱竜巻で浮かせてから強豪昇龍拳で締める。画面端が近ければ214大K（強竜巻）締めも強力。',
    'year4', 51, '2026-11-10T11:00:00Z', '2026-11-10T11:00:00Z'
  ),
  (
    '10000000-0000-4000-8000-000000000002',
    null, '運営シード', 'akuma', 'classic',
    '["akuma_5mp","akuma_5hp","akuma_214odp","akuma_4hk","akuma_214hk"]'::jsonb,
    'akuma:classic:akuma_5mp>akuma_5hp>akuma_214odp>akuma_4hk>akuma_214hk',
    array['corner'], 'optimal',
    3680, 2.0, 0, 0, 0,
    true, '画面端OD金剛灼火の壁バウンドから4大K（羅漢）で拾って強竜巻で締める高火力ルート。起き攻め状況が非常に良い。',
    'year4', 38, '2026-11-11T14:20:00Z', '2026-11-11T14:20:00Z'
  ),
  (
    '10000000-0000-4000-8000-000000000003',
    null, '運営シード', 'akuma', 'classic',
    '["akuma_5hk","sys_micro_walk","akuma_5hp","akuma_214hp","akuma_sa3"]'::jsonb,
    'akuma:classic:akuma_5hk>sys_micro_walk>akuma_5hp>akuma_214hp>akuma_sa3',
    array['punish_counter', 'midscreen'], 'optimal',
    5320, 0.0, 3, 0, 0,
    false, '無敵技ガード後の立ち強Kパニカン始動。微歩き立ち強Pから強金剛灼火2段目キャンセルSA3でDゲージ消費ゼロのリーサル火力。',
    'year4', 44, '2026-11-13T16:40:00Z', '2026-11-13T16:40:00Z'
  ),
  (
    '10000000-0000-4000-8000-000000000004',
    null, '運営シード', 'akuma', 'modern',
    '["akuma_m_2m","sys_dr","akuma_m_auto_m","akuma_m_auto_h","akuma_m_6sp"]'::jsonb,
    'akuma:modern:akuma_m_2m>sys_dr>akuma_m_auto_m>akuma_m_auto_h>akuma_m_6sp',
    array['midscreen'], 'beginner',
    2410, 3.0, 0, 0, 0,
    true, 'モダン豪鬼の安定ラッシュコンボ。複雑なコマンド不要で屈中からしっかりダメージを取れる。',
    'year4', 22, '2026-11-15T10:10:00Z', '2026-11-15T10:10:00Z'
  ),

  -- ジュリ (juri)
  (
    '20000000-0000-4000-8000-000000000001',
    null, '運営シード', 'juri', 'classic',
    '["juri_2mk","sys_dr","juri_2mp","juri_5mp","juri_2mp","juri_214lk"]'::jsonb,
    'juri:classic:juri_2mk>sys_dr>juri_2mp>juri_5mp>juri_2mp>juri_214lk',
    array['midscreen'], 'standard',
    2280, 3.0, 0, 0, 1,
    true, 'ジュリの基本となる屈中Kラッシュ始動。風破刃締めでストックを1つ溜めつつ、前ステから起き攻めに行ける。',
    'year4', 42, '2026-11-10T10:00:00Z', '2026-11-10T10:00:00Z'
  ),
  (
    '20000000-0000-4000-8000-000000000002',
    null, '運営シード', 'juri', 'classic',
    '["juri_5mp","juri_2mp","juri_236mk","juri_236hk","juri_623hp"]'::jsonb,
    'juri:classic:juri_5mp>juri_2mp>juri_236mk>juri_236hk>juri_623hp',
    array['corner'], 'optimal',
    3340, 0.0, 0, 2, 0,
    true, '風破ストック2本消費の画面端ノーゲージ高火力ルート。暗剣殺→五黄殺→強天穿輪でダウンを奪い柔道へ移行可能。',
    'year4', 31, '2026-11-11T12:00:00Z', '2026-11-11T12:00:00Z'
  ),
  (
    '20000000-0000-4000-8000-000000000003',
    null, '運営シード', 'juri', 'classic',
    '["juri_5hp","juri_236mk","juri_236hk","juri_214mk","juri_sa3"]'::jsonb,
    'juri:classic:juri_5hp>juri_236mk>juri_236hk>juri_214mk>juri_sa3',
    array['corner', 'punish_counter'], 'optimal',
    5410, 0.0, 3, 3, 0,
    false, '風破ストック最大（3本）時の画面端パニカン・リーサルコンボ。Dゲージを使わずに暗剣殺→五黄殺→中疾空閃→SA3で大ダメージを奪える。',
    'year4', 36, '2026-11-15T15:00:00Z', '2026-11-15T15:00:00Z'
  ),
  (
    '20000000-0000-4000-8000-000000000004',
    null, '運営シード', 'juri', 'classic',
    '["sys_di","juri_5hp","juri_236hk","juri_623hp"]'::jsonb,
    'juri:classic:sys_di>juri_5hp>juri_236hk>juri_623hp',
    array['di_hit', 'di_wall_splat', 'corner'], 'beginner',
    2920, 1.0, 0, 1, 0,
    true, '画面端のDIヒット・壁ドン共通で安定する簡単レシピ。風破ストックが無い場合は236大Kを214弱K（風破刃）に代用可能。',
    'year4', 27, '2026-11-12T09:30:00Z', '2026-11-12T09:30:00Z'
  ),
  (
    '20000000-0000-4000-8000-000000000005',
    null, '運営シード', 'juri', 'classic',
    '["juri_5mp","juri_2mp","juri_sa2","sys_raw_dr","juri_5lp","juri_5mp","juri_2mk","juri_5hp","sys_jc","sys_f_jump","juri_jmp","juri_jmk","juri_jhk","juri_214lk"]'::jsonb,
    'juri:classic:juri_5mp>juri_2mp>juri_sa2>sys_raw_dr>juri_5lp>juri_5mp>juri_2mk>juri_5hp>sys_jc>sys_f_jump>juri_jmp>juri_jmk>juri_jhk>juri_214lk',
    array['midscreen', 'juri_feng_shui'], 'standard',
    3480, 1.0, 2, 0, 1,
    true, '風水エンジン発動からの中央運び＆起き攻め重視の長尺チェーンコンボ。立ち強P後のジャンプキャンセルは最速で前ジャンプし、J中P→J中K→J強Kをテンポよく繋ぐ。',
    'year4', 58, '2026-11-14T18:00:00Z', '2026-11-14T18:00:00Z'
  ),
  (
    '20000000-0000-4000-8000-000000000006',
    null, '運営シード', 'juri', 'classic',
    '["juri_5hp","juri_sa2","juri_5lk","juri_5mp","juri_5hp","juri_6hp","sys_jc","juri_jmp","juri_jmk","juri_jhp","juri_214mk","sys_delay","juri_623hp"]'::jsonb,
    'juri:classic:juri_5hp>juri_sa2>juri_5lk>juri_5mp>juri_5hp>juri_6hp>sys_jc>juri_jmp>juri_jmk>juri_jhp>juri_214mk>sys_delay>juri_623hp',
    array['corner', 'punish_counter', 'juri_feng_shui'], 'optimal',
    4210, 0.0, 2, 0, 0,
    true, '画面端パニカン立ち強Pからの風水エンジン高火力チェーン。6大P（狂背掌）を挟んで浮かせ、空中チェーン後に着地ディレイ強天穿輪で締める。ゲージ温存しつつ大ダメージを狙える。',
    'year4', 49, '2026-11-15T20:15:00Z', '2026-11-15T20:15:00Z'
  ),
  (
    '20000000-0000-4000-8000-000000000007',
    null, '運営シード', 'juri', 'modern',
    '["juri_m_2m","sys_dr","juri_m_auto_m","juri_m_auto_h","juri_m_4sp"]'::jsonb,
    'juri:modern:juri_m_2m>sys_dr>juri_m_auto_m>juri_m_auto_h>juri_m_4sp',
    array['midscreen'], 'beginner',
    2050, 3.0, 0, 0, 1,
    true, 'モダンジュリの基本ラッシュコンボ。屈中ヒット確認からラッシュし、アシスト中→アシスト強→後SP（風破刃）でストックを溜めつつ安全に起き攻めへ。',
    'year4', 19, '2026-11-16T08:00:00Z', '2026-11-16T08:00:00Z'
  ),

  -- イングリッド (ingrid)
  (
    '30000000-0000-4000-8000-000000000001',
    null, '運営シード', 'ingrid', 'classic',
    '["ingrid_2mk","sys_dr","ingrid_5mp","ingrid_5hp","ingrid_214mk"]'::jsonb,
    'ingrid:classic:ingrid_2mk>sys_dr>ingrid_5mp>ingrid_5hp>ingrid_214mk',
    array['midscreen'], 'standard',
    2390, 3.0, 0, 0, 1,
    true, 'イングリッドの中央基本ラッシュコンボ。サンアーチ締めで運びつつ前ステから起き攻めが可能。',
    'year4', 28, '2026-11-12T11:00:00Z', '2026-11-12T11:00:00Z'
  ),
  (
    '30000000-0000-4000-8000-000000000002',
    null, '運営シード', 'ingrid', 'classic',
    '["ingrid_5hp","ingrid_214odk","sys_f_jump","ingrid_jhk","ingrid_air_214k","ingrid_623hk"]'::jsonb,
    'ingrid:classic:ingrid_5hp>ingrid_214odk>sys_f_jump>ingrid_jhk>ingrid_air_214k>ingrid_623hk',
    array['corner', 'ingrid_sun_install'], 'optimal',
    3560, 2.0, 0, 1, 0,
    true, '画面端ODサンアーチで浮かせてから空中追撃→サンダイブ着地後に強サンライズで拾う高火力ルート。',
    'year4', 34, '2026-11-13T15:00:00Z', '2026-11-13T15:00:00Z'
  ),
  (
    '30000000-0000-4000-8000-000000000003',
    null, '運営シード', 'ingrid', 'classic',
    '["sys_di","ingrid_5hp","ingrid_623hk","ingrid_sa3"]'::jsonb,
    'ingrid:classic:sys_di>ingrid_5hp>ingrid_623hk>ingrid_sa3',
    array['di_hit', 'punish_counter'], 'optimal',
    4680, 1.0, 3, 0, 0,
    false, 'DIパニカン確定時のシンプルかつ高火力なリーサルルート。強サンライズの初段をSA3キャンセルする。',
    'year4', 25, '2026-11-14T13:10:00Z', '2026-11-14T13:10:00Z'
  ),
  (
    '30000000-0000-4000-8000-000000000004',
    null, '運営シード', 'ingrid', 'modern',
    '["ingrid_m_2m","sys_dr","ingrid_m_auto_m","ingrid_m_auto_h","ingrid_m_6sp"]'::jsonb,
    'ingrid:modern:ingrid_m_2m>sys_dr>ingrid_m_auto_m>ingrid_m_auto_h>ingrid_m_6sp',
    array['midscreen'], 'beginner',
    2180, 3.0, 0, 0, 0,
    true, 'モダンイングリッドの基本コンボ。アシスト強から前SP（サンライズ）で確実にダウンを奪える。',
    'year4', 16, '2026-11-16T09:00:00Z', '2026-11-16T09:00:00Z'
  ),

  -- C.ヴァイパー (c-viper)
  (
    '40000000-0000-4000-8000-000000000001',
    null, '運営シード', 'c-viper', 'classic',
    '["cviper_2mk","sys_dr","cviper_5mp","cviper_5hp","cviper_214mp"]'::jsonb,
    'c-viper:classic:cviper_2mk>sys_dr>cviper_5mp>cviper_5hp>cviper_214mp',
    array['midscreen'], 'standard',
    2450, 3.0, 0, 0, 0,
    true, 'C.ヴァイパーの中央安定ラッシュコンボ。フェイント不要で安定するため、まず最初に覚えたい基本ルート。',
    'year4', 33, '2026-11-12T17:00:00Z', '2026-11-12T17:00:00Z'
  ),
  (
    '40000000-0000-4000-8000-000000000002',
    null, '運営シード', 'c-viper', 'classic',
    '["cviper_5hp","cviper_fc","cviper_2hp","cviper_623hp","cviper_hjc","cviper_air_214mk","cviper_214hp"]'::jsonb,
    'c-viper:classic:cviper_5hp>cviper_fc>cviper_2hp>cviper_623hp>cviper_hjc>cviper_air_214mk>cviper_214hp',
    array['corner', 'c_viper_feint'], 'optimal',
    3890, 0.0, 0, 0, 0,
    true, '立ち強P→サンダーフェイントキャンセル→屈強P→強セイスモ→ハイジャンプキャンセル空中バーニング→強サンダーナックルのヴァイパーらしいノーゲージ高火力ルート。',
    'year4', 47, '2026-11-14T19:30:00Z', '2026-11-14T19:30:00Z'
  ),
  (
    '40000000-0000-4000-8000-000000000003',
    null, '運営シード', 'c-viper', 'classic',
    '["cviper_5hp","cviper_623odp","cviper_hjc","cviper_air_214mk","cviper_sa3"]'::jsonb,
    'c-viper:classic:cviper_5hp>cviper_623odp>cviper_hjc>cviper_air_214mk>cviper_sa3',
    array['punish_counter', 'midscreen'], 'optimal',
    5180, 2.0, 3, 0, 0,
    false, 'パニカン立ち強PからのODセイスモ→ハイジャンプ空中バーニング→SA3のリーサルルート。',
    'year4', 29, '2026-11-15T21:00:00Z', '2026-11-15T21:00:00Z'
  ),
  (
    '40000000-0000-4000-8000-000000000004',
    null, '運営シード', 'c-viper', 'modern',
    '["cviper_m_2m","sys_dr","cviper_m_auto_m","cviper_m_auto_h","cviper_m_sp"]'::jsonb,
    'c-viper:modern:cviper_m_2m>sys_dr>cviper_m_auto_m>cviper_m_auto_h>cviper_m_sp',
    array['midscreen'], 'beginner',
    2190, 3.0, 0, 0, 0,
    true, 'モダンC.ヴァイパー向けの簡単ラッシュコンボ。屈中ヒットからアシスト強→SP（サンダーナックル）まで繋いでダウンを奪う。',
    'year4', 18, '2026-11-16T11:20:00Z', '2026-11-16T11:20:00Z'
  )
on conflict (id) do nothing;
