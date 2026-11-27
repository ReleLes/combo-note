-- =============================================================================
-- キャラ固有状況タグ見直し Step 3: 既存公開コンボ（public.combos.situations）移行SQL
-- =============================================================================
-- 【安全設計方針】
-- 1. 非破壊的: DELETE / TRUNCATE / DROP は一切行わず、public.combos.situations の
--    対象キャラ固有タグのみを UPDATE する。共通状況タグ・実戦目的タグ・他キャラ固有タグは
--    すべて元の順序のまま保持する。
-- 2. 冪等性: 重複排除（unnest + GROUP BY + ORDER BY min(ord)）と IS DISTINCT FROM 判定により、
--    何度実行しても結果が同一かつ重複キーが発生しない。
-- 3. 対象範囲:
--    - 旧キー廃止・分離（5キャラ）: jamie, manon, aki, vega, rashid
--    - 既存消費系キー維持＋獲得系（ジュリは消費系含む）キー補完（7キャラ）:
--      kimberly, juri, lily, ryu, ehonda, mai, ingrid
--    - 既存タグ維持のみ（更新対象外）: guile, blanka, alex, yasmine, arjun, c-viper
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- 1. ジェイミー（jamie）
--    旧キー: jamie_drink_level → 廃止
--    新キー: jamie_drink_lv1 / lv2 / lv3 / lv4（開始必要Lv）, jamie_drink_gain（飲み技あり）
--    ※ 先頭から走査し、事前の飲み技(+1)および SA2 絶唱魔身(一時Lv4)を考慮して必要Lvを算出。
--       旧キーが付いていたがレシピから判定できない場合は安全側で jamie_drink_lv1 へフォールバック。
-- -----------------------------------------------------------------------------
WITH jamie_steps AS (
  SELECT
    c.id AS combo_id,
    m.ord,
    CASE
      WHEN m.move_id IN (
        'jamie_22p',
        'jamie_m_22',
        'jamie_tc_gensui3',
        'jamie_m_tc_gensui3',
        'jamie_tc_engetsu3',
        'jamie_m_tc_engetsu3',
        'jamie_sa1_drink',
        'jamie_m_sa1_drink',
        'jamie_throw_f_drink',
        'jamie_m_throw_f_drink'
      )
      OR m.move_id ~ '^jamie_(m_)?ryusuikyaku_[a-z]+_3$'
      THEN 1
      ELSE 0
    END AS is_drink,
    CASE
      WHEN m.move_id IN ('jamie_sa2', 'jamie_m_sa2') THEN 1
      ELSE 0
    END AS is_sa2,
    CASE
      WHEN m.move_id LIKE '%\_lv4%' ESCAPE '\'
        OR m.move_id LIKE '%ransui%'
        OR m.move_id LIKE '%sipposensho%'
      THEN 4
      WHEN m.move_id LIKE '%meitei%'
        OR m.move_id LIKE '%tenshin%'
      THEN 3
      WHEN m.move_id LIKE '%engetsu%'
        OR m.move_id IN (
          'jamie_236lk', 'jamie_236mk', 'jamie_236hk', 'jamie_236odk',
          'jamie_m_1sp', 'jamie_m_2sp', 'jamie_m_3sp', 'jamie_m_od_2sp'
        )
      THEN 2
      WHEN m.move_id LIKE '%eishoda%'
        OR m.move_id ~ '^jamie_(m_)?j214'
        OR m.move_id IN ('jamie_m_j_sp', 'jamie_m_j_od_sp')
      THEN 1
      ELSE 0
    END AS req_lv
  FROM public.combos AS c
  LEFT JOIN LATERAL jsonb_array_elements_text(
    CASE
      WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
      ELSE '[]'::jsonb
    END
  ) WITH ORDINALITY AS m(move_id, ord) ON true
  WHERE c.character_id = 'jamie'
),
jamie_running AS (
  SELECT
    combo_id,
    is_drink,
    req_lv,
    COALESCE(
      SUM(is_drink) OVER (
        PARTITION BY combo_id
        ORDER BY ord
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
      ),
      0
    ) AS drinks_before,
    COALESCE(
      MAX(is_sa2) OVER (
        PARTITION BY combo_id
        ORDER BY ord
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
      ),
      0
    ) AS has_sa2_before
  FROM jamie_steps
),
jamie_calc AS (
  SELECT
    combo_id,
    COALESCE(MAX(is_drink), 0) > 0 AS has_drink,
    GREATEST(
      0,
      COALESCE(
        MAX(
          CASE
            WHEN req_lv > 0 AND has_sa2_before = 0 THEN req_lv - drinks_before
            ELSE 0
          END
        ),
        0
      )
    ) AS required_start
  FROM jamie_running
  GROUP BY combo_id
),
jamie_target AS (
  SELECT
    c.id,
    (
      SELECT COALESCE(array_agg(t.tag ORDER BY t.first_ord), '{}'::text[])
      FROM (
        SELECT elem AS tag, min(ord) AS first_ord
        FROM unnest(
          array_remove(c.situations, 'jamie_drink_level')
          || CASE
               WHEN jc.required_start >= 4 THEN ARRAY['jamie_drink_lv4']
               WHEN jc.required_start = 3 THEN ARRAY['jamie_drink_lv3']
               WHEN jc.required_start = 2 THEN ARRAY['jamie_drink_lv2']
               WHEN jc.required_start = 1 THEN ARRAY['jamie_drink_lv1']
               ELSE '{}'::text[]
             END
          || CASE
               WHEN jc.has_drink THEN ARRAY['jamie_drink_gain']
               ELSE '{}'::text[]
             END
          || CASE
               WHEN 'jamie_drink_level' = ANY(c.situations)
                AND jc.required_start = 0
                AND NOT jc.has_drink
               THEN ARRAY['jamie_drink_lv1']
               ELSE '{}'::text[]
             END
        ) WITH ORDINALITY AS u(elem, ord)
        WHERE elem IS NOT NULL AND elem <> ''
        GROUP BY elem
      ) AS t
    ) AS next_situations
  FROM public.combos AS c
  JOIN jamie_calc AS jc ON jc.combo_id = c.id
  WHERE c.character_id = 'jamie'
)
UPDATE public.combos AS c
SET situations = t.next_situations
FROM jamie_target AS t
WHERE c.id = t.id
  AND t.next_situations IS DISTINCT FROM c.situations;

-- -----------------------------------------------------------------------------
-- 2. マノン（manon）
--    旧キー: manon_medal → manon_medal_gain へ置換
--    補完: stock_gain > 0 またはマネージュ・ドレ／ランヴェルセを含む場合も manon_medal_gain を付与
--          （フェイント・グラン・フェッテ・ロン・ポワンは除外）
-- -----------------------------------------------------------------------------
WITH manon_calc AS (
  SELECT
    c.id AS combo_id,
    COALESCE(c.stock_gain, 0) > 0
    OR 'manon_medal' = ANY(c.situations)
    OR EXISTS (
      SELECT 1
      FROM jsonb_array_elements_text(
        CASE
          WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
          ELSE '[]'::jsonb
        END
      ) AS m(move_id)
      WHERE m.move_id IN (
        'manon_63214lp', 'manon_63214mp', 'manon_63214hp', 'manon_63214odp',
        'manon_m_sp', 'manon_m_od_sp',
        'manon_m_63214l', 'manon_m_63214m', 'manon_m_63214h', 'manon_m_63214od',
        'manon_236lp', 'manon_236mp', 'manon_236hp', 'manon_236odp',
        'manon_m_2sp', 'manon_m_od_2sp'
      )
    ) AS has_medal_gain
  FROM public.combos AS c
  WHERE c.character_id = 'manon'
),
manon_target AS (
  SELECT
    c.id,
    (
      SELECT COALESCE(array_agg(t.tag ORDER BY t.first_ord), '{}'::text[])
      FROM (
        SELECT elem AS tag, min(ord) AS first_ord
        FROM unnest(
          array_remove(c.situations, 'manon_medal')
          || CASE
               WHEN mc.has_medal_gain THEN ARRAY['manon_medal_gain']
               ELSE '{}'::text[]
             END
        ) WITH ORDINALITY AS u(elem, ord)
        WHERE elem IS NOT NULL AND elem <> ''
        GROUP BY elem
      ) AS t
    ) AS next_situations
  FROM public.combos AS c
  JOIN manon_calc AS mc ON mc.combo_id = c.id
  WHERE c.character_id = 'manon'
)
UPDATE public.combos AS c
SET situations = t.next_situations
FROM manon_target AS t
WHERE c.id = t.id
  AND t.next_situations IS DISTINCT FROM c.situations;

-- -----------------------------------------------------------------------------
-- 3. A.K.I.（aki）
--    旧キー: aki_poison → 廃止
--    新キー: aki_poison_inflict（毒付与技あり）, aki_poison_state（毒破裂パーツあり）
--    フォールバック: 旧キーが付いていたがどちらも未検出の場合は aki_poison_state へ置換
-- -----------------------------------------------------------------------------
WITH aki_calc AS (
  SELECT
    c.id AS combo_id,
    EXISTS (
      SELECT 1
      FROM jsonb_array_elements_text(
        CASE
          WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
          ELSE '[]'::jsonb
        END
      ) AS m(move_id)
      WHERE m.move_id IN (
        'aki_214lp', 'aki_214odp',
        'aki_m_4sp', 'aki_m_od_4sp', 'aki_m_214l', 'aki_m_214od',
        'aki_214mp', 'aki_m_214m',
        'aki_214hp', 'aki_m_214h',
        'aki_214lk', 'aki_214mk', 'aki_214hk', 'aki_214odk',
        'aki_m_1sp', 'aki_m_2sp', 'aki_m_3sp', 'aki_m_od_2sp',
        'aki_dakou_throw', 'aki_m_dakou_throw',
        'aki_sa2', 'aki_m_sa2'
      )
    ) AS has_poison_inflict,
    EXISTS (
      SELECT 1
      FROM jsonb_array_elements_text(
        CASE
          WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
          ELSE '[]'::jsonb
        END
      ) AS m(move_id)
      WHERE m.move_id = 'aki_poison_burst'
    ) AS has_poison_burst
  FROM public.combos AS c
  WHERE c.character_id = 'aki'
),
aki_target AS (
  SELECT
    c.id,
    (
      SELECT COALESCE(array_agg(t.tag ORDER BY t.first_ord), '{}'::text[])
      FROM (
        SELECT elem AS tag, min(ord) AS first_ord
        FROM unnest(
          array_remove(c.situations, 'aki_poison')
          || CASE
               WHEN ac.has_poison_inflict THEN ARRAY['aki_poison_inflict']
               ELSE '{}'::text[]
             END
          || CASE
               WHEN ac.has_poison_burst
                 OR ('aki_poison' = ANY(c.situations) AND NOT ac.has_poison_inflict)
               THEN ARRAY['aki_poison_state']
               ELSE '{}'::text[]
             END
        ) WITH ORDINALITY AS u(elem, ord)
        WHERE elem IS NOT NULL AND elem <> ''
        GROUP BY elem
      ) AS t
    ) AS next_situations
  FROM public.combos AS c
  JOIN aki_calc AS ac ON ac.combo_id = c.id
  WHERE c.character_id = 'aki'
)
UPDATE public.combos AS c
SET situations = t.next_situations
FROM aki_target AS t
WHERE c.id = t.id
  AND t.next_situations IS DISTINCT FROM c.situations;

-- -----------------------------------------------------------------------------
-- 4. ベガ（vega）
--    旧キー: vega_psycho_mine → 廃止
--    新キー: vega_mine_plant（通常バックフィスト）, vega_mine_detonate（_mine 技・起爆パーツ）
--    フォールバック: 旧キーが付いていたがどちらも未検出の場合は vega_mine_detonate へ置換
-- -----------------------------------------------------------------------------
WITH vega_calc AS (
  SELECT
    c.id AS combo_id,
    EXISTS (
      SELECT 1
      FROM jsonb_array_elements_text(
        CASE
          WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
          ELSE '[]'::jsonb
        END
      ) AS m(move_id)
      WHERE m.move_id IN (
        'vega_214lp', 'vega_214mp', 'vega_214hp', 'vega_214odp',
        'vega_m_sp', 'vega_m_od_sp',
        'vega_m_214l', 'vega_m_214m', 'vega_m_214h', 'vega_m_214od'
      )
    ) AS has_mine_plant,
    EXISTS (
      SELECT 1
      FROM jsonb_array_elements_text(
        CASE
          WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
          ELSE '[]'::jsonb
        END
      ) AS m(move_id)
      WHERE m.move_id = 'vega_mine_explode'
         OR m.move_id LIKE '%\_mine' ESCAPE '\'
         OR m.move_id LIKE '%\_mine\_%' ESCAPE '\'
    ) AS has_mine_detonate
  FROM public.combos AS c
  WHERE c.character_id = 'vega'
),
vega_target AS (
  SELECT
    c.id,
    (
      SELECT COALESCE(array_agg(t.tag ORDER BY t.first_ord), '{}'::text[])
      FROM (
        SELECT elem AS tag, min(ord) AS first_ord
        FROM unnest(
          array_remove(c.situations, 'vega_psycho_mine')
          || CASE
               WHEN vc.has_mine_plant THEN ARRAY['vega_mine_plant']
               ELSE '{}'::text[]
             END
          || CASE
               WHEN vc.has_mine_detonate
                 OR ('vega_psycho_mine' = ANY(c.situations) AND NOT vc.has_mine_plant)
               THEN ARRAY['vega_mine_detonate']
               ELSE '{}'::text[]
             END
        ) WITH ORDINALITY AS u(elem, ord)
        WHERE elem IS NOT NULL AND elem <> ''
        GROUP BY elem
      ) AS t
    ) AS next_situations
  FROM public.combos AS c
  JOIN vega_calc AS vc ON vc.combo_id = c.id
  WHERE c.character_id = 'vega'
)
UPDATE public.combos AS c
SET situations = t.next_situations
FROM vega_target AS t
WHERE c.id = t.id
  AND t.next_situations IS DISTINCT FROM c.situations;

-- -----------------------------------------------------------------------------
-- 5. ラシード（rashid）
--    旧キー: rashid_air_current → 廃止
--    新キー: rashid_air_set（溜めワールウインド・イウサール）, rashid_air_boost（_wind 技）
--    フォールバック: 旧キーが付いていたがどちらも未検出の場合は rashid_air_boost へ置換
-- -----------------------------------------------------------------------------
WITH rashid_calc AS (
  SELECT
    c.id AS combo_id,
    EXISTS (
      SELECT 1
      FROM jsonb_array_elements_text(
        CASE
          WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
          ELSE '[]'::jsonb
        END
      ) AS m(move_id)
      WHERE m.move_id IN (
        'rashid_236lk_hold', 'rashid_236lk_max',
        'rashid_236mk_hold', 'rashid_236mk_max',
        'rashid_236hk_hold', 'rashid_236hk_max',
        'rashid_236odk_hold',
        'rashid_m_sp_hold', 'rashid_m_sp_max',
        'rashid_m_od_sp_hold',
        'rashid_sa2', 'rashid_m_sa2'
      )
    ) AS has_air_set,
    EXISTS (
      SELECT 1
      FROM jsonb_array_elements_text(
        CASE
          WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
          ELSE '[]'::jsonb
        END
      ) AS m(move_id)
      WHERE m.move_id LIKE '%\_wind' ESCAPE '\'
    ) AS has_air_boost
  FROM public.combos AS c
  WHERE c.character_id = 'rashid'
),
rashid_target AS (
  SELECT
    c.id,
    (
      SELECT COALESCE(array_agg(t.tag ORDER BY t.first_ord), '{}'::text[])
      FROM (
        SELECT elem AS tag, min(ord) AS first_ord
        FROM unnest(
          array_remove(c.situations, 'rashid_air_current')
          || CASE
               WHEN rc.has_air_set THEN ARRAY['rashid_air_set']
               ELSE '{}'::text[]
             END
          || CASE
               WHEN rc.has_air_boost
                 OR ('rashid_air_current' = ANY(c.situations) AND NOT rc.has_air_set)
               THEN ARRAY['rashid_air_boost']
               ELSE '{}'::text[]
             END
        ) WITH ORDINALITY AS u(elem, ord)
        WHERE elem IS NOT NULL AND elem <> ''
        GROUP BY elem
      ) AS t
    ) AS next_situations
  FROM public.combos AS c
  JOIN rashid_calc AS rc ON rc.combo_id = c.id
  WHERE c.character_id = 'rashid'
)
UPDATE public.combos AS c
SET situations = t.next_situations
FROM rashid_target AS t
WHERE c.id = t.id
  AND t.next_situations IS DISTINCT FROM c.situations;

-- -----------------------------------------------------------------------------
-- 6. キンバリー（kimberly）
--    維持: kimberly_shuriken
--    補完: 召雷細工を含む または stock_gain > 0 の場合に kimberly_shuriken_gain を補完
-- -----------------------------------------------------------------------------
WITH kimberly_target AS (
  SELECT
    c.id,
    (
      SELECT COALESCE(array_agg(t.tag ORDER BY t.first_ord), '{}'::text[])
      FROM (
        SELECT elem AS tag, min(ord) AS first_ord
        FROM unnest(
          c.situations || ARRAY['kimberly_shuriken_gain']
        ) WITH ORDINALITY AS u(elem, ord)
        WHERE elem IS NOT NULL AND elem <> ''
        GROUP BY elem
      ) AS t
    ) AS next_situations
  FROM public.combos AS c
  WHERE c.character_id = 'kimberly'
    AND (
      COALESCE(c.stock_gain, 0) > 0
      OR EXISTS (
        SELECT 1
        FROM jsonb_array_elements_text(
          CASE
            WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
            ELSE '[]'::jsonb
          END
        ) AS m(move_id)
        WHERE m.move_id IN (
          'kimberly_22k', 'kimberly_22odk',
          'kimberly_m_22h', 'kimberly_m_22od'
        )
      )
    )
)
UPDATE public.combos AS c
SET situations = t.next_situations
FROM kimberly_target AS t
WHERE c.id = t.id
  AND t.next_situations IS DISTINCT FROM c.situations;

-- -----------------------------------------------------------------------------
-- 7. ジュリ（juri）
--    維持: juri_feng_shui
--    補完: 強化必殺技／stock_cost > 0 → juri_fuha_stock、風破刃／stock_gain > 0 → juri_fuha_gain
-- -----------------------------------------------------------------------------
WITH juri_calc AS (
  SELECT
    c.id AS combo_id,
    COALESCE(c.stock_cost, 0) > 0
    OR EXISTS (
      SELECT 1
      FROM jsonb_array_elements_text(
        CASE
          WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
          ELSE '[]'::jsonb
        END
      ) AS m(move_id)
      WHERE m.move_id IN (
        'juri_236lk_ex', 'juri_236mk_ex', 'juri_236hk_ex',
        'juri_236l_ex', 'juri_236m_ex', 'juri_236h_ex'
      )
    ) AS has_fuha_stock,
    COALESCE(c.stock_gain, 0) > 0
    OR EXISTS (
      SELECT 1
      FROM jsonb_array_elements_text(
        CASE
          WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
          ELSE '[]'::jsonb
        END
      ) AS m(move_id)
      WHERE m.move_id IN (
        'juri_214lk', 'juri_214mk', 'juri_214hk', 'juri_214odk',
        'juri_m_2sp', 'juri_m_od_2sp',
        'juri_m_214l', 'juri_m_214m', 'juri_m_214h', 'juri_m_214od'
      )
    ) AS has_fuha_gain
  FROM public.combos AS c
  WHERE c.character_id = 'juri'
),
juri_target AS (
  SELECT
    c.id,
    (
      SELECT COALESCE(array_agg(t.tag ORDER BY t.first_ord), '{}'::text[])
      FROM (
        SELECT elem AS tag, min(ord) AS first_ord
        FROM unnest(
          c.situations
          || CASE
               WHEN jc.has_fuha_stock THEN ARRAY['juri_fuha_stock']
               ELSE '{}'::text[]
             END
          || CASE
               WHEN jc.has_fuha_gain THEN ARRAY['juri_fuha_gain']
               ELSE '{}'::text[]
             END
        ) WITH ORDINALITY AS u(elem, ord)
        WHERE elem IS NOT NULL AND elem <> ''
        GROUP BY elem
      ) AS t
    ) AS next_situations
  FROM public.combos AS c
  JOIN juri_calc AS jc ON jc.combo_id = c.id
  WHERE c.character_id = 'juri'
    AND (jc.has_fuha_stock OR jc.has_fuha_gain)
)
UPDATE public.combos AS c
SET situations = t.next_situations
FROM juri_target AS t
WHERE c.id = t.id
  AND t.next_situations IS DISTINCT FROM c.situations;

-- -----------------------------------------------------------------------------
-- 8. リリー（lily）
--    維持: lily_windclad
--    補完: 風纏い獲得コンドルウィンド（弱単発除外）または stock_gain > 0 → lily_windclad_gain
-- -----------------------------------------------------------------------------
WITH lily_target AS (
  SELECT
    c.id,
    (
      SELECT COALESCE(array_agg(t.tag ORDER BY t.first_ord), '{}'::text[])
      FROM (
        SELECT elem AS tag, min(ord) AS first_ord
        FROM unnest(
          c.situations || ARRAY['lily_windclad_gain']
        ) WITH ORDINALITY AS u(elem, ord)
        WHERE elem IS NOT NULL AND elem <> ''
        GROUP BY elem
      ) AS t
    ) AS next_situations
  FROM public.combos AS c
  WHERE c.character_id = 'lily'
    AND (
      COALESCE(c.stock_gain, 0) > 0
      OR EXISTS (
        SELECT 1
        FROM jsonb_array_elements_text(
          CASE
            WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
            ELSE '[]'::jsonb
          END
        ) AS m(move_id)
        WHERE m.move_id IN (
          'lily_214mp', 'lily_214hp', 'lily_214odp', 'lily_214odp_hold',
          'lily_wind_hold1', 'lily_wind_hold2', 'lily_wind_hold3',
          'lily_m_4sp', 'lily_m_od_4sp', 'lily_m_od_4sp_hold',
          'lily_m_214m', 'lily_m_214h', 'lily_m_214od', 'lily_m_214od_hold',
          'lily_m_wind_hold1', 'lily_m_wind_hold2', 'lily_m_wind_hold3'
        )
      )
    )
)
UPDATE public.combos AS c
SET situations = t.next_situations
FROM lily_target AS t
WHERE c.id = t.id
  AND t.next_situations IS DISTINCT FROM c.situations;

-- -----------------------------------------------------------------------------
-- 9. リュウ（ryu）
--    維持: ryu_denjin
--    補完: 電刃錬気（ryu_22p / ryu_m_22）または stock_gain > 0 → ryu_denjin_gain
-- -----------------------------------------------------------------------------
WITH ryu_target AS (
  SELECT
    c.id,
    (
      SELECT COALESCE(array_agg(t.tag ORDER BY t.first_ord), '{}'::text[])
      FROM (
        SELECT elem AS tag, min(ord) AS first_ord
        FROM unnest(
          c.situations || ARRAY['ryu_denjin_gain']
        ) WITH ORDINALITY AS u(elem, ord)
        WHERE elem IS NOT NULL AND elem <> ''
        GROUP BY elem
      ) AS t
    ) AS next_situations
  FROM public.combos AS c
  WHERE c.character_id = 'ryu'
    AND (
      COALESCE(c.stock_gain, 0) > 0
      OR EXISTS (
        SELECT 1
        FROM jsonb_array_elements_text(
          CASE
            WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
            ELSE '[]'::jsonb
          END
        ) AS m(move_id)
        WHERE m.move_id IN ('ryu_22p', 'ryu_m_22')
      )
    )
)
UPDATE public.combos AS c
SET situations = t.next_situations
FROM ryu_target AS t
WHERE c.id = t.id
  AND t.next_situations IS DISTINCT FROM c.situations;

-- -----------------------------------------------------------------------------
-- 10. エドモンド本田（ehonda）
--     維持: ehonda_sumo_spirit
--     補完: 肩屋入り（ehonda_22k / ehonda_m_22mh）または stock_gain > 0 → ehonda_sumo_spirit_gain
-- -----------------------------------------------------------------------------
WITH ehonda_target AS (
  SELECT
    c.id,
    (
      SELECT COALESCE(array_agg(t.tag ORDER BY t.first_ord), '{}'::text[])
      FROM (
        SELECT elem AS tag, min(ord) AS first_ord
        FROM unnest(
          c.situations || ARRAY['ehonda_sumo_spirit_gain']
        ) WITH ORDINALITY AS u(elem, ord)
        WHERE elem IS NOT NULL AND elem <> ''
        GROUP BY elem
      ) AS t
    ) AS next_situations
  FROM public.combos AS c
  WHERE c.character_id = 'ehonda'
    AND (
      COALESCE(c.stock_gain, 0) > 0
      OR EXISTS (
        SELECT 1
        FROM jsonb_array_elements_text(
          CASE
            WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
            ELSE '[]'::jsonb
          END
        ) AS m(move_id)
        WHERE m.move_id IN ('ehonda_22k', 'ehonda_m_22mh')
      )
    )
)
UPDATE public.combos AS c
SET situations = t.next_situations
FROM ehonda_target AS t
WHERE c.id = t.id
  AND t.next_situations IS DISTINCT FROM c.situations;

-- -----------------------------------------------------------------------------
-- 11. 舞（mai）
--     維持: mai_flame_stock
--     補完: SA1 陽炎の舞 または stock_gain > 0 → mai_flame_gain
-- -----------------------------------------------------------------------------
WITH mai_target AS (
  SELECT
    c.id,
    (
      SELECT COALESCE(array_agg(t.tag ORDER BY t.first_ord), '{}'::text[])
      FROM (
        SELECT elem AS tag, min(ord) AS first_ord
        FROM unnest(
          c.situations || ARRAY['mai_flame_gain']
        ) WITH ORDINALITY AS u(elem, ord)
        WHERE elem IS NOT NULL AND elem <> ''
        GROUP BY elem
      ) AS t
    ) AS next_situations
  FROM public.combos AS c
  WHERE c.character_id = 'mai'
    AND (
      COALESCE(c.stock_gain, 0) > 0
      OR EXISTS (
        SELECT 1
        FROM jsonb_array_elements_text(
          CASE
            WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
            ELSE '[]'::jsonb
          END
        ) AS m(move_id)
        WHERE m.move_id IN (
          'mai_sa1', 'mai_sa1_ex', 'mai_m_sa1', 'mai_m_sa1_ex'
        )
      )
    )
)
UPDATE public.combos AS c
SET situations = t.next_situations
FROM mai_target AS t
WHERE c.id = t.id
  AND t.next_situations IS DISTINCT FROM c.situations;

-- -----------------------------------------------------------------------------
-- 12. イングリッド（ingrid）
--     維持: ingrid_sun_install, ingrid_sun_symbol
--     補完: 弱サンフレア／弱ソーラーフレア または stock_gain > 0 → ingrid_sun_symbol_gain
-- -----------------------------------------------------------------------------
WITH ingrid_target AS (
  SELECT
    c.id,
    (
      SELECT COALESCE(array_agg(t.tag ORDER BY t.first_ord), '{}'::text[])
      FROM (
        SELECT elem AS tag, min(ord) AS first_ord
        FROM unnest(
          c.situations || ARRAY['ingrid_sun_symbol_gain']
        ) WITH ORDINALITY AS u(elem, ord)
        WHERE elem IS NOT NULL AND elem <> ''
        GROUP BY elem
      ) AS t
    ) AS next_situations
  FROM public.combos AS c
  WHERE c.character_id = 'ingrid'
    AND (
      COALESCE(c.stock_gain, 0) > 0
      OR EXISTS (
        SELECT 1
        FROM jsonb_array_elements_text(
          CASE
            WHEN jsonb_typeof(c.move_ids) = 'array' THEN c.move_ids
            ELSE '[]'::jsonb
          END
        ) AS m(move_id)
        WHERE m.move_id IN (
          'ingrid_214lp', 'ingrid_214lp_h', 'ingrid_air_214lp',
          'ingrid_m_1sp', 'ingrid_m_1sp_h', 'ingrid_m_air_1sp',
          'ingrid_m_214l', 'ingrid_m_214l_h', 'ingrid_m_air_214l'
        )
      )
    )
)
UPDATE public.combos AS c
SET situations = t.next_situations
FROM ingrid_target AS t
WHERE c.id = t.id
  AND t.next_situations IS DISTINCT FROM c.situations;

COMMIT;
