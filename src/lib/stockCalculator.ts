import type { Move, SituationKey } from "@/types/combo";

export interface MoveStockDelta {
  /** この技で消費するストック数（獲得より先に判定される） */
  consume: number;
  /** この技で獲得するストック数 */
  gain: number;
  /** この技の使用時点で最低限必要なストック／レベル（消費なし。例: ジェイミーの酔いLv1〜4解禁技） */
  minRequired?: number;
  /** この技の発動以降、一時的に到達扱いとするレベル（例: ジェイミー SA2 絶唱魔身 = Lv4） */
  temporaryLevel?: number;
}

export interface CharacterStockRuleConfig {
  characterId: string;
  /** 表示用ストック名（短い表記: 例 "風破", "焔"） */
  shortLabel: string;
  /** 正式名（例: "風破ストック", "焔ストック"） */
  label: string;
  /** ストック上限値 */
  maxCount: number;
  /** バッジ用のTailwindクラス */
  badgeClassName: string;
  /** ストック消費時に自動ONにする状況タグキー（該当タグがないキャラ・レベル別解決を使うキャラは null） */
  situationKey: SituationKey | null;
  /** ストック獲得時に自動ONにする状況タグキー（該当タグがないキャラは省略または null） */
  gainSituationKey?: SituationKey | null;
  /** 開始時必要数（requiredStart）に応じて動的に自動ONタグを決定する任意関数（例: ジェイミー Lv1〜4） */
  resolveRequiredSituationKey?: (requiredStart: number) => SituationKey | null;
  /** 1技あたりのストック消費・獲得・必要レベルを判定する純粋関数 */
  evaluateMove: (move: Move) => MoveStockDelta;
}

export interface RecipeStockResult {
  characterId: string;
  shortLabel: string;
  label: string;
  maxCount: number;
  badgeClassName: string;
  situationKey: SituationKey | null;
  gainSituationKey: SituationKey | null;
  /** 開始時に最低限必要なストック数（途中で手持ちがマイナスになる最大不足分、またはレベル要件不足分） */
  requiredStart: number;
  /** レシピ内の総消費数 */
  consumedTotal: number;
  /** レシピ内の総獲得数 */
  gainedTotal: number;
  /** 開始時 requiredStart から走査した終了時の手持ちストック数（上限考慮） */
  endStock: number;
  /** 終了時の純増減（endStock - requiredStart、上限考慮） */
  netChange: number;
  /** 消費・獲得・開始時必要レベルのいずれかが1つ以上発生するか */
  hasActivity: boolean;
  /** カード・詳細・プレビュー用の短い表示ラベル（例: "風破 +1", "焔 必要1 / +5回収"） */
  summaryLabel: string;
}

function isEnhancedMove(move: Move): boolean {
  return (
    move.notationName.includes("[強化版]") ||
    move.notationNumpad.includes("[強化]") ||
    move.notationCommand.includes("[強化]")
  );
}

// =============================================================================
// ジェイミー（酔いレベル）判定用定数・ヘルパー
// =============================================================================

const JAMIE_DRINK_GAIN_MOVE_IDS: ReadonlySet<string> = new Set([
  "jamie_22p",
  "jamie_m_22",
  "jamie_tc_gensui3",
  "jamie_m_tc_gensui3",
  "jamie_tc_engetsu3",
  "jamie_m_tc_engetsu3",
  "jamie_sa1_drink",
  "jamie_m_sa1_drink",
  "jamie_throw_f_drink",
  "jamie_m_throw_f_drink",
]);

const JAMIE_SA2_MOVE_IDS: ReadonlySet<string> = new Set([
  "jamie_sa2",
  "jamie_m_sa2",
]);

const JAMIE_LV1_FALLBACK_IDS: ReadonlySet<string> = new Set([
  "jamie_m_j_sp",
  "jamie_m_j_od_sp",
]);

const JAMIE_LV2_FALLBACK_IDS: ReadonlySet<string> = new Set([
  "jamie_236lk",
  "jamie_236mk",
  "jamie_236hk",
  "jamie_236odk",
  "jamie_m_1sp",
  "jamie_m_2sp",
  "jamie_m_3sp",
  "jamie_m_od_2sp",
]);

function isJamieDrinkGainMove(move: Move): boolean {
  if (JAMIE_DRINK_GAIN_MOVE_IDS.has(move.id)) {
    return true;
  }
  return /^jamie_(?:m_)?ryusuikyaku_[a-z]+_3$/.test(move.id);
}

function getJamieRequiredDrinkLevel(move: Move): number {
  const combined = `${move.notationNumpad} ${move.notationCommand} ${move.notationName}`;
  const match = combined.match(/\[(?:酔い)?Lv([1-4])\]/);
  if (match) {
    return Number(match[1]);
  }
  if (
    move.id.includes("_lv4") ||
    move.id.includes("ransui") ||
    move.id.includes("sipposensho")
  ) {
    return 4;
  }
  if (move.id.includes("meitei") || move.id.includes("tenshin")) {
    return 3;
  }
  if (move.id.includes("engetsu") || JAMIE_LV2_FALLBACK_IDS.has(move.id)) {
    return 2;
  }
  if (
    move.id.includes("eishoda") ||
    /^jamie_(?:m_)?j214/.test(move.id) ||
    JAMIE_LV1_FALLBACK_IDS.has(move.id)
  ) {
    return 1;
  }
  return 0;
}

// =============================================================================
// マノン（メダル）判定用定数・ヘルパー
// =============================================================================

const MANON_MEDAL_GAIN_MOVE_IDS: ReadonlySet<string> = new Set([
  // マネージュ・ドレ（クラシック・モダン）
  "manon_63214lp",
  "manon_63214mp",
  "manon_63214hp",
  "manon_63214odp",
  "manon_m_sp",
  "manon_m_od_sp",
  "manon_m_63214l",
  "manon_m_63214m",
  "manon_m_63214h",
  "manon_m_63214od",
  // ランヴェルセ（クラシック・モダン ※フェイント／グラン・フェッテ／ロン・ポワン除外）
  "manon_236lp",
  "manon_236mp",
  "manon_236hp",
  "manon_236odp",
  "manon_m_2sp",
  "manon_m_od_2sp",
]);

function isManonMedalGainMove(move: Move): boolean {
  if (move.id.includes("_feint") || move.id.includes("grand_fouette")) {
    return false;
  }
  if (MANON_MEDAL_GAIN_MOVE_IDS.has(move.id)) {
    return true;
  }
  if (move.category !== "special") {
    return false;
  }
  return (
    move.notationName.includes("マネージュ・ドレ") ||
    (move.notationName.includes("ランヴェルセ") &&
      !move.notationName.includes("フェイント"))
  );
}

// =============================================================================
// A.K.I. / ベガ / ラシード 技IDベースの固有タグ自動ON判定用定数
// =============================================================================

const AKI_POISON_INFLICT_MOVE_IDS: ReadonlySet<string> = new Set([
  // 紫煙砲（通常・OD）
  "aki_214lp",
  "aki_214odp",
  "aki_m_4sp",
  "aki_m_od_4sp",
  "aki_m_214l",
  "aki_m_214od",
  // 紫泡泉
  "aki_214mp",
  "aki_m_214m",
  // 紫泡撒
  "aki_214hp",
  "aki_m_214h",
  // 凶襲突（弱・中・強・OD）
  "aki_214lk",
  "aki_214mk",
  "aki_214hk",
  "aki_214odk",
  "aki_m_1sp",
  "aki_m_2sp",
  "aki_m_3sp",
  "aki_m_od_2sp",
  // 雁字搦
  "aki_dakou_throw",
  "aki_m_dakou_throw",
  // SA2 紫煙裂爪
  "aki_sa2",
  "aki_m_sa2",
]);

const VEGA_MINE_PLANT_MOVE_IDS: ReadonlySet<string> = new Set([
  // 通常版バックフィストコンボ（クラシック・モダン）
  "vega_214lp",
  "vega_214mp",
  "vega_214hp",
  "vega_214odp",
  "vega_m_sp",
  "vega_m_od_sp",
  "vega_m_214l",
  "vega_m_214m",
  "vega_m_214h",
  "vega_m_214od",
]);

const RASHID_AIR_SET_MOVE_IDS: ReadonlySet<string> = new Set([
  // ワールウインド・ショット（ホールド・ホールドMAX・ODホールド）
  "rashid_236lk_hold",
  "rashid_236lk_max",
  "rashid_236mk_hold",
  "rashid_236mk_max",
  "rashid_236hk_hold",
  "rashid_236hk_max",
  "rashid_236odk_hold",
  "rashid_m_sp_hold",
  "rashid_m_sp_max",
  "rashid_m_od_sp_hold",
  // SA2 イウサール
  "rashid_sa2",
  "rashid_m_sa2",
]);

function isVegaMineDetonateMoveId(moveId: string): boolean {
  return (
    moveId === "vega_mine_explode" ||
    moveId.endsWith("_mine") ||
    moveId.includes("_mine_")
  );
}

/**
 * キャラ別のストック計算ルール設定マップ。
 * 将来他キャラを追加する際は、このマップにエントリを追加するだけで対応可能。
 */
export const CHARACTER_STOCK_RULES: Readonly<
  Record<string, CharacterStockRuleConfig>
> = {
  juri: {
    characterId: "juri",
    shortLabel: "風破",
    label: "風破ストック",
    maxCount: 3,
    badgeClassName:
      "border-pink-200 bg-pink-50 text-pink-700 dark:border-pink-400/30 dark:bg-pink-500/20 dark:text-pink-200",
    situationKey: "juri_fuha_stock",
    gainSituationKey: "juri_fuha_gain",
    evaluateMove: (move) => {
      let consume = 0;
      let gain = 0;

      // 消費（-1）: [強化版] 歳破衝・暗剣殺・五黄殺（クラシック・モダン共通）
      if (move.category === "special" && isEnhancedMove(move)) {
        consume += 1;
      }

      // 獲得（+1）: 弱/中/強/OD 風破刃（クラシック・モダンコマンド・モダンワンボタン 下必/A+下必）
      if (move.category === "special" && move.notationName.includes("風破刃")) {
        gain += 1;
      }

      return { consume, gain };
    },
  },
  mai: {
    characterId: "mai",
    shortLabel: "焔",
    label: "焔ストック",
    maxCount: 5,
    badgeClassName:
      "border-orange-200 bg-orange-50 text-orange-700 dark:border-orange-400/30 dark:bg-orange-500/20 dark:text-orange-200",
    situationKey: "mai_flame_stock",
    gainSituationKey: "mai_flame_gain",
    evaluateMove: (move) => {
      let consume = 0;
      let gain = 0;

      // 消費（-1）: [強化版] が付く各種必殺技・SA（クラシック・モダン共通）
      if (
        (move.category === "special" || move.category === "super") &&
        isEnhancedMove(move)
      ) {
        consume += 1;
      }

      // 獲得（+5・上限5）: SA1 陽炎の舞（通常・強化版とも。強化版は消費1の後に+5で上限5になる）
      if (move.category === "super" && move.notationName.includes("陽炎の舞")) {
        gain += 5;
      }

      return { consume, gain };
    },
  },
  ingrid: {
    characterId: "ingrid",
    shortLabel: "サンシンボル",
    label: "サンシンボル",
    maxCount: 4,
    badgeClassName:
      "border-cyan-200 bg-cyan-50 text-cyan-800 dark:border-cyan-400/30 dark:bg-cyan-500/20 dark:text-cyan-200",
    situationKey: "ingrid_sun_symbol",
    gainSituationKey: "ingrid_sun_symbol_gain",
    evaluateMove: (move) => {
      let consume = 0;
      let gain = 0;

      // 消費（Lv2: -1 / Lv3: -2）: [強化版] サンフレア・ソーラーフレア・SA1 サンシャイン・SA2 サンオーダー
      if (
        (move.category === "special" || move.category === "super") &&
        isEnhancedMove(move)
      ) {
        if (
          move.notationName.includes("(Lv3)") ||
          move.notationNumpad.includes("[強化2]")
        ) {
          consume += 2;
        } else {
          consume += 1;
        }
      }

      // 獲得（+1 / 弱サンフレアホールド +2）: 弱 サンフレア・弱 ソーラーフレア
      if (
        move.category === "special" &&
        (move.notationName.includes("弱 サンフレア") ||
          move.notationName.includes("弱 ソーラーフレア"))
      ) {
        if (
          move.notationName.includes("ホールド") ||
          move.notationNumpad.includes("(H)")
        ) {
          gain += 2;
        } else {
          gain += 1;
        }
      }

      return { consume, gain };
    },
  },
  ryu: {
    characterId: "ryu",
    shortLabel: "電刃",
    label: "電刃練気",
    maxCount: 1,
    badgeClassName:
      "border-sky-200 bg-sky-50 text-sky-700 dark:border-sky-400/30 dark:bg-sky-500/20 dark:text-sky-200",
    situationKey: "ryu_denjin",
    gainSituationKey: "ryu_denjin_gain",
    evaluateMove: (move) => {
      let consume = 0;
      let gain = 0;

      // 消費（-1）: [強化版] 波動拳・OD波動拳・波掌撃・OD波掌撃・SA1真空波動拳・SA2真・波掌撃（クラシック・モダン共通）
      if (
        (move.category === "special" || move.category === "super") &&
        isEnhancedMove(move)
      ) {
        consume += 1;
      }

      // 獲得（+1・上限1）: 電刃錬気（クラシック 22P / モダン 22攻撃）
      if (
        move.category === "special" &&
        (move.notationName.includes("電刃錬気") ||
          move.notationName.includes("電刃練気"))
      ) {
        gain += 1;
      }

      return { consume, gain };
    },
  },
  yasmine: {
    characterId: "yasmine",
    shortLabel: "バヤニ",
    label: "バヤニ・モード",
    maxCount: 1,
    badgeClassName:
      "border-sky-200 bg-sky-50 text-sky-800 dark:border-sky-400/35 dark:bg-sky-500/20 dark:text-amber-200",
    situationKey: "yasmine_bayani",
    evaluateMove: (move) => {
      let consume = 0;
      let gain = 0;

      // 消費（-1）: [強化版] 弱/中/強/OD アロン（ナカタゴン・ラカス中専用版は解除されないため除外）
      if (
        move.category === "special" &&
        isEnhancedMove(move) &&
        !move.notationName.includes("ナカタゴン")
      ) {
        consume += 1;
      }

      // 獲得（+1・上限1）: 通常版アロン（弱/中/強/OD）、SA1 ヒワン・ン・カラヒタン、SA2 ナカタゴン・ラカス
      if (
        move.category === "special" &&
        move.notationName.includes("アロン") &&
        !isEnhancedMove(move)
      ) {
        gain += 1;
      } else if (
        move.category === "super" &&
        (move.notationName.includes("ヒワン・ン・カラヒタン") ||
          move.notationName.includes("ナカタゴン・ラカス"))
      ) {
        gain += 1;
      }

      return { consume, gain };
    },
  },
  kimberly: {
    characterId: "kimberly",
    shortLabel: "手裏剣",
    label: "細工手裏剣",
    maxCount: 3,
    badgeClassName:
      "border-pink-200 bg-pink-50 text-pink-800 dark:border-pink-400/35 dark:bg-fuchsia-500/20 dark:text-pink-200",
    situationKey: "kimberly_shuriken",
    gainSituationKey: "kimberly_shuriken_gain",
    evaluateMove: (move) => {
      let consume = 0;
      let gain = 0;

      // 獲得: 召雷細工 (+1) / OD 召雷細工 (+3・上限3)
      if (move.category === "special" && move.notationName.includes("召雷細工")) {
        if (move.notationName.includes("OD") || move.id.includes("_od")) {
          gain += 3;
        } else {
          gain += 1;
        }
      }

      // 消費: 乱れ細工手裏剣 (-2) / 細工手裏剣 (-1) / SA1 武神乱拍子・雷譜 (-1)
      if (move.category === "special" && move.notationName.includes("乱れ細工手裏剣")) {
        consume += 2;
      } else if (
        move.category === "special" &&
        move.notationName.includes("細工手裏剣")
      ) {
        consume += 1;
      } else if (
        move.category === "super" &&
        move.notationName.includes("武神乱拍子・雷譜")
      ) {
        consume += 1;
      }

      return { consume, gain };
    },
  },
  ehonda: {
    characterId: "ehonda",
    shortLabel: "相撲魂",
    label: "相撲魂",
    maxCount: 1,
    badgeClassName:
      "border-rose-200 bg-rose-50 text-rose-800 dark:border-rose-400/35 dark:bg-rose-500/20 dark:text-rose-200",
    situationKey: "ehonda_sumo_spirit",
    gainSituationKey: "ehonda_sumo_spirit_gain",
    evaluateMove: (move) => {
      let consume = 0;
      let gain = 0;

      // 消費（-1）: [強化版] 弱/中/強/OD 百裂張り手（肩屋入り）（クラシック・モダン共通）
      if (move.category === "special" && isEnhancedMove(move)) {
        consume += 1;
      }

      // 獲得（+1・上限1）: 肩屋入り（相撲魂）（クラシック 22K / モダン 22中・強）
      if (
        move.category === "special" &&
        !isEnhancedMove(move) &&
        (move.notationName.includes("肩屋入り") ||
          move.notationName.includes("相撲魂"))
      ) {
        gain += 1;
      }

      return { consume, gain };
    },
  },
  lily: {
    characterId: "lily",
    shortLabel: "風纏い",
    label: "風纏い",
    maxCount: 3,
    badgeClassName:
      "border-emerald-200 bg-emerald-50 text-emerald-800 dark:border-emerald-400/35 dark:bg-sky-500/20 dark:text-emerald-200",
    situationKey: "lily_windclad",
    gainSituationKey: "lily_windclad_gain",
    evaluateMove: (move) => {
      let consume = 0;
      let gain = 0;

      // 消費（-1）: [強化版] コンドルスパイア・トマホークバスター・コンドルダイブ（派生含む）・SA2（クラシック・モダン共通）
      if (
        (move.category === "special" || move.category === "super") &&
        isEnhancedMove(move)
      ) {
        consume += 1;
      }

      // 獲得: コンドルウィンド系（弱単発は攻撃のみで0、中/強/OD単発/ホールド+1は +1、ホールド+2/ODホールドは +2、ホールド+3は +3）
      if (move.category === "special" && move.notationName.includes("コンドルウィンド")) {
        if (move.notationName.includes("+3")) {
          gain += 3;
        } else if (
          move.notationName.includes("+2") ||
          (move.notationName.includes("OD") && move.notationName.includes("ホールド"))
        ) {
          gain += 2;
        } else if (
          move.notationName.includes("弱 コンドルウィンド") &&
          !move.notationName.includes("ホールド")
        ) {
          gain += 0;
        } else {
          gain += 1;
        }
      }

      return { consume, gain };
    },
  },
  jamie: {
    characterId: "jamie",
    shortLabel: "酔い",
    label: "酔いレベル",
    maxCount: 4,
    badgeClassName:
      "border-amber-200 bg-amber-50 text-amber-800 dark:border-amber-400/35 dark:bg-amber-500/20 dark:text-amber-200",
    situationKey: null,
    gainSituationKey: "jamie_drink_gain",
    resolveRequiredSituationKey: (requiredStart) => {
      if (requiredStart >= 4) return "jamie_drink_lv4";
      if (requiredStart === 3) return "jamie_drink_lv3";
      if (requiredStart === 2) return "jamie_drink_lv2";
      if (requiredStart === 1) return "jamie_drink_lv1";
      return null;
    },
    evaluateMove: (move) => {
      // SA2 絶唱魔身：発動以降は一時的に酔いLv4扱いとする
      if (JAMIE_SA2_MOVE_IDS.has(move.id)) {
        return { consume: 0, gain: 0, temporaryLevel: 4 };
      }

      const minRequired = getJamieRequiredDrinkLevel(move);
      const gain = isJamieDrinkGainMove(move) ? 1 : 0;

      return {
        consume: 0,
        gain,
        ...(minRequired > 0 ? { minRequired } : {}),
      };
    },
  },
  manon: {
    characterId: "manon",
    shortLabel: "メダル",
    label: "メダル",
    maxCount: 5,
    badgeClassName:
      "border-rose-200 bg-rose-50 text-rose-800 dark:border-rose-400/35 dark:bg-rose-500/20 dark:text-rose-200",
    situationKey: null,
    gainSituationKey: "manon_medal_gain",
    evaluateMove: (move) => {
      const gain = isManonMedalGainMove(move) ? 1 : 0;
      return { consume: 0, gain };
    },
  },
};

export function hasStockCalculator(characterId: string): boolean {
  return Boolean(CHARACTER_STOCK_RULES[characterId]);
}

/**
 * 指定キャラクターに「消費ストック／始動必要数」の概念があるか判定する。
 * マノン（メダル獲得のみ・消費なし）のように消費概念がないキャラでは false を返す。
 */
export function hasStockCostConcept(characterId: string): boolean {
  const config = CHARACTER_STOCK_RULES[characterId];
  if (!config) return true;
  return (
    config.situationKey !== null ||
    Boolean(config.resolveRequiredSituationKey)
  );
}

function buildSummaryLabel(
  characterId: string,
  shortLabel: string,
  maxCount: number,
  requiredStart: number,
  consumedTotal: number,
  gainedTotal: number
): string {
  if (requiredStart === 0 && consumedTotal === 0 && gainedTotal === 0) {
    return "";
  }

  const displayGain = Math.min(maxCount, gainedTotal);

  // ジェイミー専用表記（酔いLv◯+ / 酔い+◯）
  if (characterId === "jamie") {
    const reqLvLabel =
      requiredStart >= 4 ? "酔いLv4" : `酔いLv${requiredStart}+`;
    if (requiredStart === 0 && displayGain > 0) {
      return `酔い+${displayGain}`;
    }
    if (requiredStart > 0 && displayGain === 0) {
      return reqLvLabel;
    }
    if (requiredStart > 0 && displayGain > 0) {
      return `${reqLvLabel} / 酔い+${displayGain}`;
    }
  }

  // マノン専用表記（メダル+◯）
  if (characterId === "manon" && displayGain > 0) {
    return `メダル+${displayGain}`;
  }

  if (requiredStart === 0 && consumedTotal === 0 && displayGain > 0) {
    return `${shortLabel} +${displayGain}`;
  }
  if (requiredStart > 0 && displayGain === 0) {
    return `${shortLabel} 必要${requiredStart}`;
  }
  if (requiredStart > 0 && displayGain > 0) {
    return `${shortLabel} 必要${requiredStart} / +${displayGain}回収`;
  }
  // 獲得してから同じコンボ内で消費した場合（開始時必要数 0）
  return `${shortLabel} +${displayGain} / 消費${consumedTotal}`;
}

/**
 * キャラクターIDと選択技配列から、ストックの必要数・消費・獲得・純増減を
 * 先頭から順にシミュレーションする純粋関数。
 * ストック未対応キャラの場合は null を返す。
 */
export function calculateRecipeStock(
  characterId: string,
  moves: Move[]
): RecipeStockResult | null {
  const config = CHARACTER_STOCK_RULES[characterId];
  if (!config) {
    return null;
  }

  const deltas = moves.map((move) => config.evaluateMove(move));

  // Pass 1: 開始時に最低限必要なストック数／レベル（最大不足分）および総消費・総獲得を算出
  let virtualStock = 0;
  let requiredStart = 0;
  let activeTempLevel = 0;
  let consumedTotal = 0;
  let gainedTotal = 0;

  for (const { consume, gain, minRequired = 0, temporaryLevel = 0 } of deltas) {
    // 1. 必要レベルチェック（消費・獲得より先に判定。一時Lv効果で満たしていれば不足計上しない）
    if (minRequired > 0 && activeTempLevel < minRequired) {
      const needed = minRequired - virtualStock;
      if (needed > requiredStart) {
        requiredStart = needed;
      }
    }

    // 2. ストック消費
    if (consume > 0) {
      virtualStock -= consume;
      consumedTotal += consume;
      if (-virtualStock > requiredStart) {
        requiredStart = -virtualStock;
      }
    }

    // 3. ストック獲得
    if (gain > 0) {
      virtualStock += gain;
      gainedTotal += gain;
    }

    // 4. 一時レベル効果の適用（例: ジェイミー SA2 絶唱魔身）
    if (temporaryLevel > activeTempLevel) {
      activeTempLevel = temporaryLevel;
    }
  }

  requiredStart = Math.max(0, requiredStart);

  // Pass 2: requiredStart 個を持った状態から上限キャップ付きで終了時ストック数を算出
  let simStock = Math.min(config.maxCount, requiredStart);
  for (const { consume, gain } of deltas) {
    if (consume > 0) {
      simStock = Math.max(0, simStock - consume);
    }
    if (gain > 0) {
      simStock = Math.min(config.maxCount, simStock + gain);
    }
  }

  const endStock = simStock;
  const netChange = endStock - Math.min(config.maxCount, requiredStart);
  const hasActivity =
    requiredStart > 0 || consumedTotal > 0 || gainedTotal > 0;
  const summaryLabel = buildSummaryLabel(
    config.characterId,
    config.shortLabel,
    config.maxCount,
    requiredStart,
    consumedTotal,
    gainedTotal
  );
  const resolvedSituationKey = config.resolveRequiredSituationKey
    ? config.resolveRequiredSituationKey(requiredStart)
    : config.situationKey;

  return {
    characterId: config.characterId,
    shortLabel: config.shortLabel,
    label: config.label,
    maxCount: config.maxCount,
    badgeClassName: config.badgeClassName,
    situationKey: resolvedSituationKey,
    gainSituationKey: config.gainSituationKey ?? null,
    requiredStart,
    consumedTotal,
    gainedTotal,
    endStock,
    netChange,
    hasActivity,
    summaryLabel,
  };
}

/**
 * キャラクターID・レシピ技ID配列・ストック計算結果から、
 * 自動ONすべきキャラ固有状況タグキー一覧を重複なしで返す純粋関数。
 *
 * - ストック対応キャラ（消費・開始必要数・獲得）
 * - キンバリー: 細工手裏剣（起爆）パーツ
 * - A.K.I.: 毒付与技 / 毒破裂パーツ
 * - ベガ: サイコマイン設置技 / `_mine` 起爆技・起爆パーツ
 * - ラシード: 気流設置技（溜めワールウインド・イウサール） / `_wind` 気流強化技
 */
export function getAutoCharacterSituations(
  characterId: string,
  moveIds: string[],
  stockResult?: RecipeStockResult | null
): SituationKey[] {
  const keys: SituationKey[] = [];
  const addKey = (key: SituationKey | null | undefined) => {
    if (key && !keys.includes(key)) {
      keys.push(key);
    }
  };

  // 1. ストック計算結果からの自動ON（消費・必要レベル／獲得）
  if (stockResult && stockResult.characterId === characterId) {
    if (stockResult.situationKey && stockResult.requiredStart > 0) {
      addKey(stockResult.situationKey);
    }
    if (stockResult.gainSituationKey && stockResult.gainedTotal > 0) {
      addKey(stockResult.gainSituationKey);
    }
  }

  // 2. 技IDベースのキャラ固有自動ON
  switch (characterId) {
    case "kimberly": {
      if (moveIds.includes("kimberly_shuriken_explode")) {
        addKey("kimberly_shuriken");
      }
      break;
    }
    case "aki": {
      if (moveIds.some((id) => AKI_POISON_INFLICT_MOVE_IDS.has(id))) {
        addKey("aki_poison_inflict");
      }
      if (moveIds.includes("aki_poison_burst")) {
        addKey("aki_poison_state");
      }
      break;
    }
    case "vega": {
      if (moveIds.some((id) => VEGA_MINE_PLANT_MOVE_IDS.has(id))) {
        addKey("vega_mine_plant");
      }
      if (moveIds.some((id) => isVegaMineDetonateMoveId(id))) {
        addKey("vega_mine_detonate");
      }
      break;
    }
    case "rashid": {
      if (moveIds.some((id) => RASHID_AIR_SET_MOVE_IDS.has(id))) {
        addKey("rashid_air_set");
      }
      if (moveIds.some((id) => id.endsWith("_wind"))) {
        addKey("rashid_air_boost");
      }
      break;
    }
    default:
      break;
  }

  return keys;
}

/**
 * 指定キャラクターで自動ON対象となり得るキャラ固有状況タグキー一覧を返す。
 * フォーム側でユーザーが手動OFFにしたタグ（dismissedAutoSituations）を記憶する際の判定に使用する。
 */
export function getAutoManagedCharacterSituations(
  characterId: string
): SituationKey[] {
  const keys: SituationKey[] = [];
  const addKey = (key: SituationKey | null | undefined) => {
    if (key && !keys.includes(key)) {
      keys.push(key);
    }
  };

  const stockConfig = CHARACTER_STOCK_RULES[characterId];
  if (stockConfig) {
    addKey(stockConfig.situationKey);
    addKey(stockConfig.gainSituationKey);
    if (stockConfig.resolveRequiredSituationKey) {
      for (let lv = 1; lv <= stockConfig.maxCount; lv += 1) {
        addKey(stockConfig.resolveRequiredSituationKey(lv));
      }
    }
  }

  switch (characterId) {
    case "aki":
      addKey("aki_poison_inflict");
      addKey("aki_poison_state");
      break;
    case "vega":
      addKey("vega_mine_plant");
      addKey("vega_mine_detonate");
      break;
    case "rashid":
      addKey("rashid_air_set");
      addKey("rashid_air_boost");
      break;
    default:
      break;
  }

  return keys;
}
