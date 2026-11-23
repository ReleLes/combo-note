import type { Move } from "@/types/combo";

export interface MoveStockDelta {
  /** この技で消費するストック数（獲得より先に判定される） */
  consume: number;
  /** この技で獲得するストック数 */
  gain: number;
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
  /** ストック消費時に自動ONにする状況タグキー（該当タグがないキャラは null） */
  situationKey: string | null;
  /** 1技あたりのストック消費・獲得を判定する純粋関数 */
  evaluateMove: (move: Move) => MoveStockDelta;
}

export interface RecipeStockResult {
  characterId: string;
  shortLabel: string;
  label: string;
  maxCount: number;
  badgeClassName: string;
  situationKey: string | null;
  /** 開始時に最低限必要なストック数（途中で手持ちがマイナスになる最大不足分） */
  requiredStart: number;
  /** レシピ内の総消費数 */
  consumedTotal: number;
  /** レシピ内の総獲得数 */
  gainedTotal: number;
  /** 開始時 requiredStart から走査した終了時の手持ちストック数（上限考慮） */
  endStock: number;
  /** 終了時の純増減（endStock - requiredStart、上限考慮） */
  netChange: number;
  /** 消費または獲得が1つ以上発生するか */
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

/**
 * キャラ別のストック計算ルール設定マップ。
 * 将来イングリッドや他キャラを追加する際は、このマップにエントリを追加するだけで対応可能。
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
    // ジュリの固有状況タグは風水エンジン（juri_feng_shui）のみのため null
    situationKey: null,
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
};

export function hasStockCalculator(characterId: string): boolean {
  return Boolean(CHARACTER_STOCK_RULES[characterId]);
}

function buildSummaryLabel(
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

  // Pass 1: 開始時に最低限必要なストック数（最大不足分）および総消費・総獲得を算出
  let virtualStock = 0;
  let minStock = 0;
  let consumedTotal = 0;
  let gainedTotal = 0;

  for (const { consume, gain } of deltas) {
    if (consume > 0) {
      virtualStock -= consume;
      consumedTotal += consume;
      if (virtualStock < minStock) {
        minStock = virtualStock;
      }
    }
    if (gain > 0) {
      virtualStock += gain;
      gainedTotal += gain;
    }
  }

  const requiredStart = Math.max(0, -minStock);

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
    config.shortLabel,
    config.maxCount,
    requiredStart,
    consumedTotal,
    gainedTotal
  );

  return {
    characterId: config.characterId,
    shortLabel: config.shortLabel,
    label: config.label,
    maxCount: config.maxCount,
    badgeClassName: config.badgeClassName,
    situationKey: config.situationKey,
    requiredStart,
    consumedTotal,
    gainedTotal,
    endStock,
    netChange,
    hasActivity,
    summaryLabel,
  };
}
