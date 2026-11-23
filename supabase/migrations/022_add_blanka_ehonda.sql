-- =============================================================================
-- Migration: 022_add_blanka_ehonda.sql
-- 目的: 29人目「ブランカ（blanka）」・30人目「エドモンド本田（ehonda）」のキャラクターマスタおよび
--       全技マスタ（ブランカ全129技＋エドモンド本田全125技＝計254技・
--       公式フレームデータ＆コマンドリスト準拠・CA除外）を
--       既存の Supabase 本番 DB へ安全・冪等に UPSERT する
-- 前提: 001_add_throw_category.sql を先に適用済みであること
-- =============================================================================

-- 1. キャラクターマスタへブランカ・エドモンド本田を追加・更新
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
  ('blanka', 'blanka', 'ブランカ', 'Blanka', 29, true, null, null, null),
  ('ehonda', 'ehonda', 'エドモンド本田', 'E. Honda', 30, true, '相撲魂', '相撲魂', 1)
on conflict (id) do update set
  slug = excluded.slug,
  name_ja = excluded.name_ja,
  name_en = excluded.name_en,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  stock_label = excluded.stock_label,
  stock_short_label = excluded.stock_short_label,
  stock_max_count = excluded.stock_max_count;

-- 2. ブランカ・エドモンド本田全技マスタ（計254技）を UPSERT
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
  -- ブランカ（blanka）全129技（クラシック62種＋モダン67種）
  -- =========================================================================

  -- 1. 通常技（クラシック 19種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜36、垂直J強P含む）
  ('blanka_5lp', 'blanka', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（ベアアタック）', 10, 5, 3, array['C']),
  ('blanka_5lk', 'blanka', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（ビーストキック）', 11, 4, 5, array['C']),
  ('blanka_5mp', 'blanka', 'classic', 'normal', '5中P', '中P', '立ち中P（ビーストチョップ）', 12, 9, 3, array['SA']),
  ('blanka_5mk', 'blanka', 'classic', 'normal', '5中K', '中K', '立ち中K（ブラッディーテイル）', 13, 8, 5, array['C']),
  ('blanka_5hp', 'blanka', 'classic', 'normal', '5強P', '強P', '立ち強P（ジャングルアーチ）', 14, 10, 3, array['C']),
  ('blanka_5hk', 'blanka', 'classic', 'normal', '5強K', '強K', '立ち強K（ワイルドダンス）', 15, 7, 6, array[]::text[]),
  ('blanka_2lp', 'blanka', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（キャットクロー）', 20, 6, 5, array['C']),
  ('blanka_2lk', 'blanka', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（ジャングルトラップ）', 21, 5, 3, array[]::text[]),
  ('blanka_2mp', 'blanka', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（ベアクロー）', 22, 9, -1, array['C']),
  ('blanka_2mk', 'blanka', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（ビーストステップ）', 23, 8, 5, array['C']),
  ('blanka_2hp', 'blanka', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（スネークアッパー）', 24, 15, 0, array[]::text[]),
  ('blanka_2hk', 'blanka', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（ビーストテイル）', 25, 11, null, array[]::text[]),
  ('blanka_jlp', 'blanka', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（パンサークロー）', 30, 4, null, array[]::text[]),
  ('blanka_jlk', 'blanka', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（フライングヴァイパー）', 31, 5, null, array[]::text[]),
  ('blanka_jmp', 'blanka', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（フィストドロップ）', 32, 7, null, array['C']),
  ('blanka_jmk', 'blanka', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（ワイルドヒール）', 33, 7, null, array[]::text[]),
  ('blanka_jhp', 'blanka', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（サバイバルクロー）', 34, 9, null, array[]::text[]),
  ('blanka_jhk', 'blanka', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（サバイバルキック）', 35, 11, null, array[]::text[]),
  ('blanka_vjhp', 'blanka', 'classic', 'normal', '垂直J強P', '垂直J中強P', '垂直ジャンプ強P（サバイバルクロー・垂直）', 36, 7, null, array[]::text[]),

  -- 2. 特殊技＆フィアーダウン派生（クラシック 10種: 40〜49）
  ('blanka_6mp', 'blanka', 'classic', 'unique', '6中P', '→+中P', 'ロッククラッシュ', 40, 20, 3, array[]::text[]),
  ('blanka_6mk', 'blanka', 'classic', 'unique', '6中K', '→+中K', 'ダブルニーボンバー', 41, 9, 6, array[]::text[]),
  ('blanka_4mk', 'blanka', 'classic', 'unique', '4中K', '←+中K', 'ワイルドエッジ', 42, 9, 8, array['C']),
  ('blanka_6hp', 'blanka', 'classic', 'unique', '6強P', '→+強P', 'ワイルドネイル', 43, 18, null, array[]::text[]),
  ('blanka_3hp', 'blanka', 'classic', 'unique', '3強P', '↘+強P', 'アマゾンリバーラン', 44, 14, null, array[]::text[]),
  ('blanka_2ppp', 'blanka', 'classic', 'unique', '2PPP', '↓+PPP', 'フィアーダウン', 45, null, null, array[]::text[]),
  ('blanka_wild_lift', 'blanka', 'classic', 'unique', 'ワイルドリフト', 'フィアーダウン中P', 'ワイルドリフト', 46, 8, null, array[]::text[]),
  ('blanka_raid_jump', 'blanka', 'classic', 'unique', 'レイドジャンプ', 'フィアーダウン中K', 'レイドジャンプ', 47, null, null, array[]::text[]),
  ('blanka_6kkk', 'blanka', 'classic', 'unique', '6KKK', '→+KKK', 'サプライズフォワード', 48, null, null, array[]::text[]),
  ('blanka_4kkk', 'blanka', 'classic', 'unique', '4KKK', '←+KKK', 'サプライズバック', 49, null, null, array[]::text[]),

  -- 3. 必殺技（クラシック 27種: 55〜81、溜め表記統一・ブランカちゃん爆弾＆ローリングキャノン含む）
  ('blanka_214p', 'blanka', 'classic', 'special', '214P', '↓↙←+P', 'エレクトリックサンダー', 55, 10, null, array['SA3']),
  ('blanka_214odp', 'blanka', 'classic', 'special', 'OD214PP', '↓↙←+PP', 'OD エレクトリックサンダー', 56, 10, null, array['SA2']),
  ('blanka_46lp', 'blanka', 'classic', 'special', '[4]6弱P', '←タメ→+弱P', '弱 ローリングアタック', 57, 10, null, array['SA3']),
  ('blanka_46mp', 'blanka', 'classic', 'special', '[4]6中P', '←タメ→+中P', '中 ローリングアタック', 58, 12, null, array['SA3']),
  ('blanka_46hp', 'blanka', 'classic', 'special', '[4]6強P', '←タメ→+強P', '強 ローリングアタック', 59, 22, null, array['SA3']),
  ('blanka_46odp', 'blanka', 'classic', 'special', 'OD[4]6PP', '←タメ→+PP', 'OD ローリングアタック', 60, 18, null, array['SA2']),
  ('blanka_28lk', 'blanka', 'classic', 'special', '[2]8弱K', '↓タメ↑+弱K', '弱 バーチカルローリング', 61, 8, null, array[]::text[]),
  ('blanka_28mk', 'blanka', 'classic', 'special', '[2]8中K', '↓タメ↑+中K', '中 バーチカルローリング', 62, 8, null, array[]::text[]),
  ('blanka_28hk', 'blanka', 'classic', 'special', '[2]8強K', '↓タメ↑+強K', '強 バーチカルローリング', 63, 8, null, array[]::text[]),
  ('blanka_28odk', 'blanka', 'classic', 'special', 'OD[2]8KK', '↓タメ↑+KK', 'OD バーチカルローリング', 64, 7, null, array[]::text[]),
  ('blanka_63214lk', 'blanka', 'classic', 'special', '63214弱K', '→↘↓↙←+弱K', '弱 バックステップローリング', 65, 41, 9, array[]::text[]),
  ('blanka_63214mk', 'blanka', 'classic', 'special', '63214中K', '→↘↓↙←+中K', '中 バックステップローリング', 66, 41, 8, array[]::text[]),
  ('blanka_63214hk', 'blanka', 'classic', 'special', '63214強K', '→↘↓↙←+強K', '強 バックステップローリング', 67, 41, 8, array[]::text[]),
  ('blanka_63214odk', 'blanka', 'classic', 'special', 'OD63214KK', '→↘↓↙←+KK', 'OD バックステップローリング', 68, 8, 10, array['SA2']),
  ('blanka_j46lp', 'blanka', 'classic', 'special', 'J[4]6弱P', '空中で←タメ→+弱P', '弱 エリアルローリング', 69, 13, null, array[]::text[]),
  ('blanka_j46mp', 'blanka', 'classic', 'special', 'J[4]6中P', '空中で←タメ→+中P', '中 エリアルローリング', 70, 13, null, array[]::text[]),
  ('blanka_j46hp', 'blanka', 'classic', 'special', 'J[4]6強P', '空中で←タメ→+強P', '強 エリアルローリング', 71, 13, null, array[]::text[]),
  ('blanka_j46odp', 'blanka', 'classic', 'special', 'JOD[4]6PP', '空中で←タメ→+PP', 'OD エリアルローリング', 72, 13, null, array[]::text[]),
  ('blanka_236lk', 'blanka', 'classic', 'special', '236弱K', '↓↘→+弱K', '弱 ワイルドハント', 73, 34, null, array[]::text[]),
  ('blanka_236mk', 'blanka', 'classic', 'special', '236中K', '↓↘→+中K', '中 ワイルドハント', 74, 39, null, array[]::text[]),
  ('blanka_236hk', 'blanka', 'classic', 'special', '236強K', '↓↘→+強K', '強 ワイルドハント', 75, 43, null, array[]::text[]),
  ('blanka_236odk', 'blanka', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD ワイルドハント', 76, 32, null, array[]::text[]),
  ('blanka_22p', 'blanka', 'classic', 'special', '22P(人形)', '↓↓+P', 'ブランカちゃん爆弾（設置）', 77, null, null, array[]::text[]),
  ('blanka_bomb_shot', 'blanka', 'classic', 'special', '人形起動(射出)', '電撃で人形起動', 'ブランカちゃん爆弾（起動・射出）', 78, 36, null, array[]::text[]),
  ('blanka_bomb_shot_od', 'blanka', 'classic', 'special', 'OD人形起動(射出)', 'OD電撃で人形起動', 'OD ブランカちゃん爆弾（起動・射出）', 79, 36, null, array[]::text[]),
  ('blanka_bomb_shot_sa1', 'blanka', 'classic', 'special', 'SA1人形起動(射出)', 'SA1で人形起動', 'SA1 ブランカちゃん爆弾（起動・射出）', 80, 26, null, array[]::text[]),
  ('blanka_rolling_cannon', 'blanka', 'classic', 'special', 'ローリングキャノン', '[SA2中]ローリング中方向+P', 'ローリングキャノン', 81, 3, null, array[]::text[]),

  -- 4. スーパーアーツ（クラシック 3種: 85〜87、CA除外）
  ('blanka_sa1', 'blanka', 'classic', 'super', 'SA1', '↓↘→↓↘→+P', 'SA1 シャウトオブアース', 85, 8, null, array[]::text[]),
  ('blanka_sa2', 'blanka', 'classic', 'super', 'SA2', '↓↙←↓↙←+P', 'SA2 ライトニングビースト', 86, null, null, array[]::text[]),
  ('blanka_sa3', 'blanka', 'classic', 'super', 'SA3', '↓↘→↓↘→+K', 'SA3 グランドシェイブキャノンボール', 87, 10, null, array[]::text[]),

  -- 5. 通常投げ（クラシック 3種: 90〜92、空中投げ含む）
  ('blanka_throw_f', 'blanka', 'classic', 'throw', '前投げ', '弱P+弱K', 'ワイルドファング（前投げ）', 90, 5, null, array[]::text[]),
  ('blanka_throw_b', 'blanka', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', 'ジャングルフリップ（後ろ投げ）', 91, 5, null, array[]::text[]),
  ('blanka_throw_air', 'blanka', 'classic', 'throw', '空投げ', '空中で弱P+弱K', 'ワイルドバイツ（空中投げ）', 92, 5, null, array[]::text[]),

  -- 6. モダン通常技（9種: 100〜108）
  ('blanka_m_5l', 'blanka', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 100, 5, 3, array['C']),
  ('blanka_m_5m', 'blanka', 'modern', 'normal', '5中', '中', '立ち中（立ち中K）', 101, 8, 5, array['C']),
  ('blanka_m_5h', 'blanka', 'modern', 'normal', '5強', '強', '立ち強（立ち強K）', 102, 7, 6, array[]::text[]),
  ('blanka_m_2l', 'blanka', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱K）', 103, 5, 3, array[]::text[]),
  ('blanka_m_2m', 'blanka', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 104, 8, 5, array['C']),
  ('blanka_m_2h', 'blanka', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 105, 15, 0, array[]::text[]),
  ('blanka_m_jl', 'blanka', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 106, 4, null, array[]::text[]),
  ('blanka_m_jm', 'blanka', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 107, 7, null, array['C']),
  ('blanka_m_jh', 'blanka', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強K）', 108, 11, null, array[]::text[]),

  -- 7. モダン特殊技・アシスト・フィアーダウン派生（20種: 115〜134）
  ('blanka_m_auto_l', 'blanka', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・立ち弱K）', 115, 4, 5, array['C']),
  ('blanka_m_auto_l2', 'blanka', 'modern', 'unique', 'A弱>弱', 'アシスト弱>弱', 'アシスト弱2段目（しゃがみ弱P）', 116, 6, 5, array['C']),
  ('blanka_m_auto_h', 'blanka', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち強P）', 117, 10, 3, array['C']),
  ('blanka_m_j_auto_l', 'blanka', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 118, 5, null, array[]::text[]),
  ('blanka_m_j_auto_m', 'blanka', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 119, 7, null, array[]::text[]),
  ('blanka_m_j_auto_h', 'blanka', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強P）', 120, 9, null, array[]::text[]),
  ('blanka_m_vj_auto_h', 'blanka', 'modern', 'unique', '垂直JA強', '垂直J中アシスト強', '垂直ジャンプアシスト強（サバイバルクロー・垂直）', 121, 7, null, array[]::text[]),
  ('blanka_m_auto_l_combo', 'blanka', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 122, 4, null, array[]::text[]),
  ('blanka_m_auto_2l_combo', 'blanka', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 123, 5, null, array[]::text[]),
  ('blanka_m_auto_m_combo', 'blanka', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 124, null, null, array[]::text[]),
  ('blanka_m_auto_h_combo', 'blanka', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 125, 10, null, array[]::text[]),
  ('blanka_m_6m', 'blanka', 'modern', 'unique', '6中', '→+中', 'ダブルニーボンバー', 126, 9, 6, array[]::text[]),
  ('blanka_m_4m', 'blanka', 'modern', 'unique', '4中', '←+中', 'ワイルドエッジ', 127, 9, 8, array['C']),
  ('blanka_m_6h', 'blanka', 'modern', 'unique', '6強', '→+強', 'ワイルドネイル', 128, 18, null, array[]::text[]),
  ('blanka_m_3h', 'blanka', 'modern', 'unique', '3強', '↘+強', 'アマゾンリバーラン', 129, 14, null, array[]::text[]),
  ('blanka_m_2mh', 'blanka', 'modern', 'unique', '2中強', '↓+中+強', 'フィアーダウン', 130, null, null, array[]::text[]),
  ('blanka_m_wild_lift', 'blanka', 'modern', 'unique', 'ワイルドリフト', 'フィアーダウン中弱', 'ワイルドリフト', 131, 8, null, array[]::text[]),
  ('blanka_m_raid_jump', 'blanka', 'modern', 'unique', 'レイドジャンプ', 'フィアーダウン中中/強', 'レイドジャンプ', 132, null, null, array[]::text[]),
  ('blanka_m_6all', 'blanka', 'modern', 'unique', '6攻撃×3', '→+攻撃×3', 'サプライズフォワード', 133, null, null, array[]::text[]),
  ('blanka_m_4all', 'blanka', 'modern', 'unique', '4攻撃×3', '←+攻撃×3', 'サプライズバック', 134, null, null, array[]::text[]),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（10種: 140〜149）
  ('blanka_m_sp', 'blanka', 'modern', 'special', 'N必', 'SP', 'エレクトリックサンダー（N必）', 140, 10, null, array['SA3']),
  ('blanka_m_od_sp', 'blanka', 'modern', 'special', 'A+N必', 'A+SP', 'OD エレクトリックサンダー（A+N必）', 141, 10, null, array['SA2']),
  ('blanka_m_4sp', 'blanka', 'modern', 'special', '[4]後必', '←タメ+SP', '中 ローリングアタック（後必）', 142, 12, null, array['SA3']),
  ('blanka_m_od_4sp', 'blanka', 'modern', 'special', 'A+[4]後必', 'A+←タメ+SP', 'OD ローリングアタック（A+後必）', 143, 18, null, array['SA2']),
  ('blanka_m_2sp', 'blanka', 'modern', 'special', '[2]下必', '↓タメ+SP', '弱 バーチカルローリング（下必）', 144, 8, null, array[]::text[]),
  ('blanka_m_od_2sp', 'blanka', 'modern', 'special', 'A+[2]下必', 'A+↓タメ+SP', 'OD バーチカルローリング（A+下必）', 145, 7, null, array[]::text[]),
  ('blanka_m_6sp', 'blanka', 'modern', 'special', '前必', '→+SP', '中 バックステップローリング（前必）', 146, 41, 8, array[]::text[]),
  ('blanka_m_od_6sp', 'blanka', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD バックステップローリング（A+前必）', 147, 8, 10, array['SA2']),
  ('blanka_m_j_4sp', 'blanka', 'modern', 'special', '空[4]後必', '空中で←タメ+SP', '中 エリアルローリング（空後必）', 148, 13, null, array[]::text[]),
  ('blanka_m_j_od_4sp', 'blanka', 'modern', 'special', '空A+[4]後必', '空中でA+←タメ+SP', 'OD エリアルローリング（空A+後必）', 149, 13, null, array[]::text[]),

  -- 9. モダン必殺技：コマンド入力版＆派生技（22種: 155〜176）
  ('blanka_m_214', 'blanka', 'modern', 'special', '214攻撃', '↓↙←+攻撃', 'エレクトリックサンダー', 155, 10, null, array['SA3']),
  ('blanka_m_214od', 'blanka', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD エレクトリックサンダー', 156, 10, null, array['SA2']),
  ('blanka_m_46l', 'blanka', 'modern', 'special', '[4]6弱', '←タメ→+弱', '弱 ローリングアタック', 157, 10, null, array['SA3']),
  ('blanka_m_46m', 'blanka', 'modern', 'special', '[4]6中', '←タメ→+中', '中 ローリングアタック', 158, 12, null, array['SA3']),
  ('blanka_m_46h', 'blanka', 'modern', 'special', '[4]6強', '←タメ→+強', '強 ローリングアタック', 159, 22, null, array['SA3']),
  ('blanka_m_46od', 'blanka', 'modern', 'special', 'OD[4]6', '←タメ→+攻撃×2', 'OD ローリングアタック', 160, 18, null, array['SA2']),
  ('blanka_m_28l', 'blanka', 'modern', 'special', '[2]8弱', '↓タメ↑+弱', '弱 バーチカルローリング', 161, 8, null, array[]::text[]),
  ('blanka_m_28m', 'blanka', 'modern', 'special', '[2]8中', '↓タメ↑+中', '中 バーチカルローリング', 162, 8, null, array[]::text[]),
  ('blanka_m_28h', 'blanka', 'modern', 'special', '[2]8強', '↓タメ↑+強', '強 バーチカルローリング', 163, 8, null, array[]::text[]),
  ('blanka_m_28od', 'blanka', 'modern', 'special', 'OD[2]8', '↓タメ↑+攻撃×2', 'OD バーチカルローリング', 164, 7, null, array[]::text[]),
  ('blanka_m_j46l', 'blanka', 'modern', 'special', 'J[4]6弱', '空中で←タメ→+弱', '弱 エリアルローリング', 165, 13, null, array[]::text[]),
  ('blanka_m_j46m', 'blanka', 'modern', 'special', 'J[4]6中', '空中で←タメ→+中', '中 エリアルローリング', 166, 13, null, array[]::text[]),
  ('blanka_m_j46h', 'blanka', 'modern', 'special', 'J[4]6強', '空中で←タメ→+強', '強 エリアルローリング', 167, 13, null, array[]::text[]),
  ('blanka_m_236l', 'blanka', 'modern', 'special', '236弱', '↓↘→+弱', '弱 ワイルドハント', 168, 34, null, array[]::text[]),
  ('blanka_m_236m', 'blanka', 'modern', 'special', '236中', '↓↘→+中', '中 ワイルドハント', 169, 39, null, array[]::text[]),
  ('blanka_m_236h', 'blanka', 'modern', 'special', '236強', '↓↘→+強', '強 ワイルドハント', 170, 43, null, array[]::text[]),
  ('blanka_m_236od', 'blanka', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD ワイルドハント', 171, 32, null, array[]::text[]),
  ('blanka_m_22', 'blanka', 'modern', 'special', '22攻撃(人形)', '↓↓+攻撃', 'ブランカちゃん爆弾（設置）', 172, null, null, array[]::text[]),
  ('blanka_m_bomb_shot', 'blanka', 'modern', 'special', '人形起動(射出)', '電撃で人形起動', 'ブランカちゃん爆弾（起動・射出）', 173, 36, null, array[]::text[]),
  ('blanka_m_bomb_shot_od', 'blanka', 'modern', 'special', 'OD人形起動(射出)', 'OD電撃で人形起動', 'OD ブランカちゃん爆弾（起動・射出）', 174, 36, null, array[]::text[]),
  ('blanka_m_bomb_shot_sa1', 'blanka', 'modern', 'special', 'SA1人形起動(射出)', 'SA1で人形起動', 'SA1 ブランカちゃん爆弾（起動・射出）', 175, 26, null, array[]::text[]),
  ('blanka_m_rolling_cannon', 'blanka', 'modern', 'special', 'ローリングキャノン', '[SA2中]ローリング中方向+攻撃', 'ローリングキャノン', 176, 3, null, array[]::text[]),

  -- 10. モダンスーパーアーツ（3種: 180〜182、CA除外）
  ('blanka_m_sa1', 'blanka', 'modern', 'super', 'SA1', 'SP+強', 'SA1 シャウトオブアース', 180, 8, null, array[]::text[]),
  ('blanka_m_sa2', 'blanka', 'modern', 'super', 'SA2', '←+SP+強', 'SA2 ライトニングビースト', 181, null, null, array[]::text[]),
  ('blanka_m_sa3', 'blanka', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 グランドシェイブキャノンボール', 182, 10, null, array[]::text[]),

  -- 11. モダン通常投げ（3種: 185〜187、空中投げ含む）
  ('blanka_m_throw_f', 'blanka', 'modern', 'throw', '前投げ', '弱+中', 'ワイルドファング（前投げ）', 185, 5, null, array[]::text[]),
  ('blanka_m_throw_b', 'blanka', 'modern', 'throw', '後ろ投げ', '←+弱+中', 'ジャングルフリップ（後ろ投げ）', 186, 5, null, array[]::text[]),
  ('blanka_m_throw_air', 'blanka', 'modern', 'throw', '空投げ', '空中で弱+中', 'ワイルドバイツ（空中投げ）', 187, 5, null, array[]::text[]),

  -- =========================================================================
  -- エドモンド本田（ehonda）全125技（クラシック59種＋モダン66種）
  -- =========================================================================

  -- 1. 通常技（クラシック 19種: 立ち 10〜15 / しゃがみ 20〜25 / ジャンプ 30〜36、垂直J強P大熊手含む）
  ('ehonda_5lp', 'ehonda', 'classic', 'normal', '5弱P', '弱P', '立ち弱P（張り手）', 10, 5, 4, array['C']),
  ('ehonda_5lk', 'ehonda', 'classic', 'normal', '5弱K', '弱K', '立ち弱K（けたぐり）', 11, 4, 5, array['C']),
  ('ehonda_5mp', 'ehonda', 'classic', 'normal', '5中P', '中P', '立ち中P（突っ張り）', 12, 10, 6, array['C']),
  ('ehonda_5mk', 'ehonda', 'classic', 'normal', '5中K', '中K', '立ち中K（四股蹴り）', 13, 10, 4, array[]::text[]),
  ('ehonda_5hp', 'ehonda', 'classic', 'normal', '5強P', '強P', '立ち強P（ごっつぁんチョップ）', 14, 8, 1, array['C']),
  ('ehonda_5hk', 'ehonda', 'classic', 'normal', '5強K', '強K', '立ち強K（丸太蹴り）', 15, 8, -1, array['C']),
  ('ehonda_2lp', 'ehonda', 'classic', 'normal', '2弱P', '↓+弱P', 'しゃがみ弱P（しゃがみ張り手）', 20, 4, 4, array['C']),
  ('ehonda_2lk', 'ehonda', 'classic', 'normal', '2弱K', '↓+弱K', 'しゃがみ弱K（向こうずねキック）', 21, 5, 3, array[]::text[]),
  ('ehonda_2mp', 'ehonda', 'classic', 'normal', '2中P', '↓+中P', 'しゃがみ中P（しゃがみ突っ張り）', 22, 8, 3, array['C']),
  ('ehonda_2mk', 'ehonda', 'classic', 'normal', '2中K', '↓+中K', 'しゃがみ中K（掛け足）', 23, 9, 6, array[]::text[]),
  ('ehonda_2hp', 'ehonda', 'classic', 'normal', '2強P', '↓+強P', 'しゃがみ強P（スーパー出足払い）', 24, 11, 3, array['SA']),
  ('ehonda_2hk', 'ehonda', 'classic', 'normal', '2強K', '↓+強K', 'しゃがみ強K（土俵払い）', 25, 11, null, array[]::text[]),
  ('ehonda_jlp', 'ehonda', 'classic', 'normal', 'J弱P', '空中で弱P', 'ジャンプ弱P（ジャンプ突き手）', 30, 5, null, array[]::text[]),
  ('ehonda_jlk', 'ehonda', 'classic', 'normal', 'J弱K', '空中で弱K', 'ジャンプ弱K（百貫落とし）', 31, 6, null, array[]::text[]),
  ('ehonda_jmp', 'ehonda', 'classic', 'normal', 'J中P', '空中で中P', 'ジャンプ中P（ジャンプチョップ）', 32, 6, null, array[]::text[]),
  ('ehonda_jmk', 'ehonda', 'classic', 'normal', 'J中K', '空中で中K', 'ジャンプ中K（わらじ蹴り）', 33, 9, null, array[]::text[]),
  ('ehonda_jhp', 'ehonda', 'classic', 'normal', 'J強P', '空中で強P', 'ジャンプ強P（ジャンプ張り手）', 34, 9, null, array[]::text[]),
  ('ehonda_jhk', 'ehonda', 'classic', 'normal', 'J強K', '空中で強K', 'ジャンプ強K（跳び丸太蹴り）', 35, 10, null, array[]::text[]),
  ('ehonda_vjhp', 'ehonda', 'classic', 'normal', '垂直J強P', '垂直J中強P', '垂直ジャンプ強P（大熊手）', 36, 10, null, array[]::text[]),

  -- 2. 特殊技＆ターゲットコンボ（クラシック 5種: 40〜44）
  ('ehonda_6hk', 'ehonda', 'classic', 'unique', '6強K', '→+強K', '払い蹴り', 40, 14, 1, array[]::text[]),
  ('ehonda_3hk', 'ehonda', 'classic', 'unique', '3強K', '↘+強K', '力足', 41, 22, 3, array[]::text[]),
  ('ehonda_j2mk', 'ehonda', 'classic', 'unique', '前J2中K', '前J中↓+中K', 'フライングスモウプレス', 42, 11, null, array[]::text[]),
  ('ehonda_tc_lp', 'ehonda', 'classic', 'unique', '5弱P>中P', '弱P>中P', '連ね張り手', 43, 4, null, array['C']),
  ('ehonda_tc_jichin', 'ehonda', 'classic', 'unique', '5中P>3強K', '中P>↘+強K', '地鎮', 44, 22, 3, array[]::text[]),

  -- 3. 必殺技（クラシック 30種: 50〜79、溜め表記統一・肩屋入り強化版＆相撲ステップ派生含む）
  ('ehonda_214lp', 'ehonda', 'classic', 'special', '214弱P', '↓↙←+弱P', '弱 百裂張り手', 50, 12, 2, array['SA3']),
  ('ehonda_214lp_ex', 'ehonda', 'classic', 'special', '[強化]214弱P', '[強化]↓↙←+弱P', '[強化版]弱 百裂張り手（肩屋入り）', 51, 12, 4, array['SA3']),
  ('ehonda_214mp', 'ehonda', 'classic', 'special', '214中P', '↓↙←+中P', '中 百裂張り手', 52, 16, 2, array['SA3']),
  ('ehonda_214mp_ex', 'ehonda', 'classic', 'special', '[強化]214中P', '[強化]↓↙←+中P', '[強化版]中 百裂張り手（肩屋入り）', 53, 16, 4, array['SA3']),
  ('ehonda_214hp', 'ehonda', 'classic', 'special', '214強P', '↓↙←+強P', '強 百裂張り手', 54, 19, 2, array['SA3']),
  ('ehonda_214hp_ex', 'ehonda', 'classic', 'special', '[強化]214強P', '[強化]↓↙←+強P', '[強化版]強 百裂張り手（肩屋入り）', 55, 19, 4, array['SA3']),
  ('ehonda_214odp', 'ehonda', 'classic', 'special', 'OD214PP', '↓↙←+PP', 'OD 百裂張り手', 56, 19, 4, array['SA2']),
  ('ehonda_214odp_ex', 'ehonda', 'classic', 'special', '[強化]OD214PP', '[強化]↓↙←+PP', '[強化版]OD 百裂張り手（肩屋入り）', 57, 19, 6, array['SA2']),
  ('ehonda_46lp', 'ehonda', 'classic', 'special', '[4]6弱P', '←タメ→+弱P', '弱 スーパー頭突き', 58, 10, null, array['SA3']),
  ('ehonda_46mp', 'ehonda', 'classic', 'special', '[4]6中P', '←タメ→+中P', '中 スーパー頭突き', 59, 10, null, array['SA3']),
  ('ehonda_46hp', 'ehonda', 'classic', 'special', '[4]6強P', '←タメ→+強P', '強 スーパー頭突き', 60, 14, null, array['SA3']),
  ('ehonda_46odp', 'ehonda', 'classic', 'special', 'OD[4]6PP', '←タメ→+PP', 'OD スーパー頭突き', 61, 9, null, array[]::text[]),
  ('ehonda_28lk', 'ehonda', 'classic', 'special', '[2]8弱K', '↓タメ↑+弱K', '弱 スーパー百貫落とし', 62, 11, null, array[]::text[]),
  ('ehonda_28mk', 'ehonda', 'classic', 'special', '[2]8中K', '↓タメ↑+中K', '中 スーパー百貫落とし', 63, 11, null, array[]::text[]),
  ('ehonda_28hk', 'ehonda', 'classic', 'special', '[2]8強K', '↓タメ↑+強K', '強 スーパー百貫落とし', 64, 11, null, array[]::text[]),
  ('ehonda_28odk', 'ehonda', 'classic', 'special', 'OD[2]8KK', '↓タメ↑+KK', 'OD スーパー百貫落とし', 65, 6, null, array[]::text[]),
  ('ehonda_63214lk', 'ehonda', 'classic', 'special', '63214弱K', '→↘↓↙←+弱K', '弱 大銀杏投げ', 66, 6, null, array[]::text[]),
  ('ehonda_63214mk', 'ehonda', 'classic', 'special', '63214中K', '→↘↓↙←+中K', '中 大銀杏投げ', 67, 6, null, array[]::text[]),
  ('ehonda_63214hk', 'ehonda', 'classic', 'special', '63214強K', '→↘↓↙←+強K', '強 大銀杏投げ', 68, 6, null, array[]::text[]),
  ('ehonda_63214odk', 'ehonda', 'classic', 'special', 'OD63214KK', '→↘↓↙←+KK', 'OD 大銀杏投げ', 69, 6, null, array[]::text[]),
  ('ehonda_236k', 'ehonda', 'classic', 'special', '236K', '↓↘→+K', '相撲ステップ', 70, null, null, array[]::text[]),
  ('ehonda_236odk', 'ehonda', 'classic', 'special', 'OD236KK', '↓↘→+KK', 'OD 相撲ステップ', 71, null, null, array[]::text[]),
  ('ehonda_teppo_1', 'ehonda', 'classic', 'special', '鉄砲1段目', '相撲ステップ中P', '鉄砲（1段目）', 72, 9, null, array['SA3']),
  ('ehonda_teppo_2', 'ehonda', 'classic', 'special', '鉄砲2段目', '相撲ステップ中P>P', '鉄砲（2段目）', 73, 14, null, array[]::text[]),
  ('ehonda_teppo_od_1', 'ehonda', 'classic', 'special', 'OD鉄砲1段目', 'OD相撲ステップ中P', 'OD 鉄砲（1段目）', 74, 9, 3, array['SA2']),
  ('ehonda_teppo_od_2', 'ehonda', 'classic', 'special', 'OD鉄砲2段目', 'OD相撲ステップ中P>P', 'OD 鉄砲（2段目）', 75, 14, null, array[]::text[]),
  ('ehonda_taiho', 'ehonda', 'classic', 'special', '大砲', '相撲ステップ中↓+P', '大砲', 76, 12, null, array['SA3']),
  ('ehonda_taiho_od', 'ehonda', 'classic', 'special', 'OD大砲', 'OD相撲ステップ中↓+P', 'OD 大砲', 77, 12, null, array['SA2']),
  ('ehonda_22p', 'ehonda', 'classic', 'special', '22P', '↓↓+P', '猫だまし', 78, 11, 3, array['SA3']),
  ('ehonda_22k', 'ehonda', 'classic', 'special', '22K(肩屋入り)', '↓↓+K', '肩屋入り（相撲魂）', 79, null, null, array[]::text[]),

  -- 4. スーパーアーツ（クラシック 3種: 85〜87、CA除外）
  ('ehonda_sa1', 'ehonda', 'classic', 'super', 'SA1', '↓↘→↓↘→+P', 'SA1 発揮爆砕', 85, 7, null, array[]::text[]),
  ('ehonda_sa2', 'ehonda', 'classic', 'super', 'SA2', '←タメ→←→+K', 'SA2 スーパー鬼無双', 86, 12, null, array[]::text[]),
  ('ehonda_sa3', 'ehonda', 'classic', 'super', 'SA3', '↓↙←↓↙←+P', 'SA3 千秋楽', 87, 9, null, array[]::text[]),

  -- 5. 通常投げ（クラシック 2種: 90〜91）
  ('ehonda_throw_f', 'ehonda', 'classic', 'throw', '前投げ', '弱P+弱K', 'さば折り（前投げ）', 90, 5, null, array[]::text[]),
  ('ehonda_throw_b', 'ehonda', 'classic', 'throw', '後ろ投げ', '←+弱P+弱K', '俵投げ（後ろ投げ）', 91, 5, null, array[]::text[]),

  -- 6. モダン通常技（11種: 100〜110、垂直J強大熊手含む）
  ('ehonda_m_5l', 'ehonda', 'modern', 'normal', '5弱', '弱', '立ち弱（立ち弱P）', 100, 5, 4, array['C']),
  ('ehonda_m_5m', 'ehonda', 'modern', 'normal', '5中', '中', '立ち中（立ち中P）', 101, 10, 6, array['C']),
  ('ehonda_m_5h', 'ehonda', 'modern', 'normal', '5強', '強', '立ち強（立ち強P）', 102, 8, 1, array['C']),
  ('ehonda_m_2l', 'ehonda', 'modern', 'normal', '2弱', '↓+弱', 'しゃがみ弱（しゃがみ弱P）', 103, 4, 4, array['C']),
  ('ehonda_m_2m', 'ehonda', 'modern', 'normal', '2中', '↓+中', 'しゃがみ中（しゃがみ中K）', 104, 9, 6, array[]::text[]),
  ('ehonda_m_2h', 'ehonda', 'modern', 'normal', '2強', '↓+強', 'しゃがみ強（しゃがみ強P）', 105, 11, 3, array['SA']),
  ('ehonda_m_3h', 'ehonda', 'modern', 'normal', '3強', '↘+強', '右下強（土俵払い）', 106, 11, null, array[]::text[]),
  ('ehonda_m_jl', 'ehonda', 'modern', 'normal', 'J弱', '空中で弱', 'ジャンプ弱（ジャンプ弱P）', 107, 5, null, array[]::text[]),
  ('ehonda_m_jm', 'ehonda', 'modern', 'normal', 'J中', '空中で中', 'ジャンプ中（ジャンプ中P）', 108, 6, null, array[]::text[]),
  ('ehonda_m_jh', 'ehonda', 'modern', 'normal', 'J強', '空中で強', 'ジャンプ強（ジャンプ強P）', 109, 9, null, array[]::text[]),
  ('ehonda_m_vjh', 'ehonda', 'modern', 'normal', '垂直J強', '垂直J中強', '垂直ジャンプ強（大熊手）', 110, 10, null, array[]::text[]),

  -- 7. モダン特殊技・アシスト・TC（14種: 115〜128）
  ('ehonda_m_auto_l', 'ehonda', 'modern', 'unique', 'A弱(単発)', 'アシスト弱', 'アシスト弱（単発・しゃがみ弱K）', 115, 5, 3, array[]::text[]),
  ('ehonda_m_auto_m', 'ehonda', 'modern', 'unique', 'A中(単発)', 'アシスト中', 'アシスト中（単発・しゃがみ中P）', 116, 8, 3, array['C']),
  ('ehonda_m_auto_h', 'ehonda', 'modern', 'unique', 'A強(単発)', 'アシスト強', 'アシスト強（単発・立ち強K）', 117, 8, -1, array['C']),
  ('ehonda_m_j_auto_l', 'ehonda', 'modern', 'unique', 'JA弱', '空中でアシスト弱', 'ジャンプアシスト弱（ジャンプ弱K）', 118, 6, null, array[]::text[]),
  ('ehonda_m_j_auto_m', 'ehonda', 'modern', 'unique', 'JA中', '空中でアシスト中', 'ジャンプアシスト中（ジャンプ中K）', 119, 9, null, array[]::text[]),
  ('ehonda_m_j_auto_h', 'ehonda', 'modern', 'unique', 'JA強', '空中でアシスト強', 'ジャンプアシスト強（ジャンプ強K）', 120, 10, null, array[]::text[]),
  ('ehonda_m_auto_l_combo', 'ehonda', 'modern', 'unique', 'A弱コンボ', 'アシスト弱連打', 'アシストコンボ1（弱）', 121, 5, null, array[]::text[]),
  ('ehonda_m_auto_2l_combo', 'ehonda', 'modern', 'unique', '連打A弱コンボ', '↓+アシスト弱連打', '連打キャンセルアシストコンボ', 122, 4, null, array[]::text[]),
  ('ehonda_m_auto_m_combo', 'ehonda', 'modern', 'unique', 'A中コンボ', 'アシスト中連打', 'アシストコンボ2（中）', 123, 8, null, array[]::text[]),
  ('ehonda_m_auto_h_combo', 'ehonda', 'modern', 'unique', 'A強コンボ', 'アシスト強連打', 'アシストコンボ3（強）', 124, 8, null, array[]::text[]),
  ('ehonda_m_6h', 'ehonda', 'modern', 'unique', '6強', '→+強', '払い蹴り', 125, 14, 1, array[]::text[]),
  ('ehonda_m_j2m', 'ehonda', 'modern', 'unique', '前J2中', '前J中↓+中', 'フライングスモウプレス', 126, 11, null, array[]::text[]),
  ('ehonda_m_tc_l', 'ehonda', 'modern', 'unique', '5弱>弱', '弱>弱', '連ね張り手', 127, 4, null, array['C']),
  ('ehonda_m_tc_jichin', 'ehonda', 'modern', 'unique', '5中>3中', '中>↘+中', '地鎮', 128, 22, 3, array[]::text[]),

  -- 8. モダン必殺技：ワンボタンSP＆OD版（10種: 135〜144）
  ('ehonda_m_sp', 'ehonda', 'modern', 'special', 'N必', 'SP', '弱 百裂張り手（N必）', 135, 12, 2, array['SA3']),
  ('ehonda_m_sp_ex', 'ehonda', 'modern', 'special', '[強化]N必', '[強化]SP', '[強化版]弱 百裂張り手（肩屋入り・N必）', 136, 12, 4, array['SA3']),
  ('ehonda_m_od_sp', 'ehonda', 'modern', 'special', 'A+N必', 'A+SP', 'OD 百裂張り手（A+N必）', 137, 19, 4, array['SA2']),
  ('ehonda_m_od_sp_ex', 'ehonda', 'modern', 'special', '[強化]A+N必', '[強化]A+SP', '[強化版]OD 百裂張り手（肩屋入り・A+N必）', 138, 19, 6, array['SA2']),
  ('ehonda_m_4sp', 'ehonda', 'modern', 'special', '[4]後必', '←タメ+SP', '中 スーパー頭突き（後必）', 139, 10, null, array['SA3']),
  ('ehonda_m_od_4sp', 'ehonda', 'modern', 'special', 'A+[4]後必', 'A+←タメ+SP', 'OD スーパー頭突き（A+後必）', 140, 9, null, array[]::text[]),
  ('ehonda_m_2sp', 'ehonda', 'modern', 'special', '下必', '↓+SP', '強 大銀杏投げ（下必）', 141, 6, null, array[]::text[]),
  ('ehonda_m_od_2sp', 'ehonda', 'modern', 'special', 'A+下必', 'A+↓+SP', 'OD 大銀杏投げ（A+下必）', 142, 6, null, array[]::text[]),
  ('ehonda_m_6sp', 'ehonda', 'modern', 'special', '前必', '→+SP', '相撲ステップ（前必）', 143, null, null, array[]::text[]),
  ('ehonda_m_od_6sp', 'ehonda', 'modern', 'special', 'A+前必', 'A+→+SP', 'OD 相撲ステップ（A+前必）', 144, null, null, array[]::text[]),

  -- 9. モダン必殺技：コマンド入力版＆派生技（26種: 150〜175）
  ('ehonda_m_214l', 'ehonda', 'modern', 'special', '214弱', '↓↙←+弱', '弱 百裂張り手', 150, 12, 2, array['SA3']),
  ('ehonda_m_214l_ex', 'ehonda', 'modern', 'special', '[強化]214弱', '[強化]↓↙←+弱', '[強化版]弱 百裂張り手（肩屋入り）', 151, 12, 4, array['SA3']),
  ('ehonda_m_214m', 'ehonda', 'modern', 'special', '214中', '↓↙←+中', '中 百裂張り手', 152, 16, 2, array['SA3']),
  ('ehonda_m_214m_ex', 'ehonda', 'modern', 'special', '[強化]214中', '[強化]↓↙←+中', '[強化版]中 百裂張り手（肩屋入り）', 153, 16, 4, array['SA3']),
  ('ehonda_m_214h', 'ehonda', 'modern', 'special', '214強', '↓↙←+強', '強 百裂張り手', 154, 19, 2, array['SA3']),
  ('ehonda_m_214h_ex', 'ehonda', 'modern', 'special', '[強化]214強', '[強化]↓↙←+強', '[強化版]強 百裂張り手（肩屋入り）', 155, 19, 4, array['SA3']),
  ('ehonda_m_214od', 'ehonda', 'modern', 'special', 'OD214', '↓↙←+攻撃×2', 'OD 百裂張り手', 156, 19, 4, array['SA2']),
  ('ehonda_m_214od_ex', 'ehonda', 'modern', 'special', '[強化]OD214', '[強化]↓↙←+攻撃×2', '[強化版]OD 百裂張り手（肩屋入り）', 157, 19, 6, array['SA2']),
  ('ehonda_m_46l', 'ehonda', 'modern', 'special', '[4]6弱', '←タメ→+弱', '弱 スーパー頭突き', 158, 10, null, array['SA3']),
  ('ehonda_m_46m', 'ehonda', 'modern', 'special', '[4]6中', '←タメ→+中', '中 スーパー頭突き', 159, 10, null, array['SA3']),
  ('ehonda_m_46h', 'ehonda', 'modern', 'special', '[4]6強', '←タメ→+強', '強 スーパー頭突き', 160, 14, null, array['SA3']),
  ('ehonda_m_46od', 'ehonda', 'modern', 'special', 'OD[4]6', '←タメ→+攻撃×2', 'OD スーパー頭突き', 161, 9, null, array[]::text[]),
  ('ehonda_m_28l', 'ehonda', 'modern', 'special', '[2]8弱', '↓タメ↑+弱', '弱 スーパー百貫落とし', 162, 11, null, array[]::text[]),
  ('ehonda_m_28m', 'ehonda', 'modern', 'special', '[2]8中', '↓タメ↑+中', '中 スーパー百貫落とし', 163, 11, null, array[]::text[]),
  ('ehonda_m_28h', 'ehonda', 'modern', 'special', '[2]8強', '↓タメ↑+強', '強 スーパー百貫落とし', 164, 11, null, array[]::text[]),
  ('ehonda_m_28od', 'ehonda', 'modern', 'special', 'OD[2]8', '↓タメ↑+攻撃×2', 'OD スーパー百貫落とし', 165, 6, null, array[]::text[]),
  ('ehonda_m_236', 'ehonda', 'modern', 'special', '236攻撃', '↓↘→+攻撃', '相撲ステップ', 166, null, null, array[]::text[]),
  ('ehonda_m_236od', 'ehonda', 'modern', 'special', 'OD236', '↓↘→+攻撃×2', 'OD 相撲ステップ', 167, null, null, array[]::text[]),
  ('ehonda_m_teppo_1', 'ehonda', 'modern', 'special', '鉄砲1段目', '相撲ステップ中攻撃', '鉄砲（1段目）', 168, 9, null, array['SA3']),
  ('ehonda_m_teppo_2', 'ehonda', 'modern', 'special', '鉄砲2段目', '相撲ステップ中攻撃×2', '鉄砲（2段目）', 169, 14, null, array[]::text[]),
  ('ehonda_m_teppo_od_1', 'ehonda', 'modern', 'special', 'OD鉄砲1段目', 'OD相撲ステップ中攻撃', 'OD 鉄砲（1段目）', 170, 9, 3, array['SA2']),
  ('ehonda_m_teppo_od_2', 'ehonda', 'modern', 'special', 'OD鉄砲2段目', 'OD相撲ステップ中攻撃×2', 'OD 鉄砲（2段目）', 171, 14, null, array[]::text[]),
  ('ehonda_m_taiho', 'ehonda', 'modern', 'special', '大砲', '相撲ステップ中↓+攻撃', '大砲', 172, 12, null, array['SA3']),
  ('ehonda_m_taiho_od', 'ehonda', 'modern', 'special', 'OD大砲', 'OD相撲ステップ中↓+攻撃', 'OD 大砲', 173, 12, null, array['SA2']),
  ('ehonda_m_22l', 'ehonda', 'modern', 'special', '22弱', '↓↓+弱', '猫だまし', 174, 11, 3, array['SA3']),
  ('ehonda_m_22mh', 'ehonda', 'modern', 'special', '22中/強(肩屋入り)', '↓↓+中/強', '肩屋入り（相撲魂）', 175, null, null, array[]::text[]),

  -- 10. モダンスーパーアーツ（3種: 180〜182、CA除外）
  ('ehonda_m_sa1', 'ehonda', 'modern', 'super', 'SA1', 'SP+強', 'SA1 発揮爆砕', 180, 7, null, array[]::text[]),
  ('ehonda_m_sa2', 'ehonda', 'modern', 'super', 'SA2', '←タメ+SP+強', 'SA2 スーパー鬼無双', 181, 12, null, array[]::text[]),
  ('ehonda_m_sa3', 'ehonda', 'modern', 'super', 'SA3', '↓+SP+強', 'SA3 千秋楽', 182, 9, null, array[]::text[]),

  -- 11. モダン通常投げ（2種: 185〜186）
  ('ehonda_m_throw_f', 'ehonda', 'modern', 'throw', '前投げ', '弱+中', 'さば折り（前投げ）', 185, 5, null, array[]::text[]),
  ('ehonda_m_throw_b', 'ehonda', 'modern', 'throw', '後ろ投げ', '←+弱+中', '俵投げ（後ろ投げ）', 186, 5, null, array[]::text[])
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
