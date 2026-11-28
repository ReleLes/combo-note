import type { Move, SituationKey } from "@/types/combo";
import { DRIVE_COST_EXCLUDED_MOVE_IDS } from "@/lib/gaugeCalculator";

export type ComboValidationWarningKind =
  | "cancel_unavailable"
  | "frame_shortage"
  | "throw_in_combo";

export interface ComboValidationWarning {
  /** 繋ぎ目の位置（moveIds 配列上の該当ステップインデックス） */
  stepIndex: number;
  fromMoveId: string;
  toMoveId: string;
  kind: ComboValidationWarningKind;
  shortageFrames?: number;
  effectiveAdvantage?: number;
  nextStartup?: number;
  message: string;
}

export interface ValidateComboRecipeInput {
  characterId: string;
  moves: Move[];
  moveIds: string[];
  situations: SituationKey[];
}

/**
 * 通常のキャンセル則・地上ヒット硬直差が大きく変化するため、
 * レシピ全体のフレーム検証をスキップする状況タグ一覧。
 */
export const SKIP_VALIDATION_SITUATIONS: ReadonlySet<string> = new Set([
  // キャラ固有の特殊フレーム・キャンセル変化状態
  "juri_feng_shui", // ジュリ: 風水エンジン（通常技チェーンキャンセル解禁）
  "c_viper_feint", // C.ヴァイパー: フェイントキャンセル
  "guile_solid_puncher", // ガイル: ソリッドパンチャー
  "blanka_lightning_beast", // ブランカ: ライトニングビースト
  "yasmine_nakatagong_lakas", // ヤスミン: ナカタゴン・ラカス
  "rashid_air_boost", // ラシード: 気流強化
  "aki_poison_state", // A.K.I.: 毒状態限定（毒破裂による大幅追撃猶予変化）
  "vega_mine_detonate", // ベガ: サイコマイン起爆
  "alex_back_turned", // アレックス: 背面やられ
  // 地上ヒット硬直差がそのまま当てはまらない共通状況
  "anti_air", // 対空（空中ヒット）
  "di_wall_splat", // 壁ドン
  "stun", // スタン
]);

/**
 * 発動以降、通常フレーム・キャンセル則が変化するインストール系 SA2 の技ID。
 * 状況タグを付け忘れた場合でも、発動以降の繋ぎ目で誤検知を防ぐ。
 */
const INSTALL_SA_MOVE_IDS: ReadonlySet<string> = new Set([
  "juri_sa2",
  "juri_m_sa2",
  "guile_sa2",
  "guile_m_sa2",
  "blanka_sa2",
  "blanka_m_sa2",
  "yasmine_sa2",
  "yasmine_m_sa2",
]);

/** キャンセルラッシュ（CDR）のシステムパーツID */
const CANCEL_DR_ID = "sys_dr";
/** 生ドライブラッシュ（DR）のシステムパーツID */
const RAW_DR_ID = "sys_raw_dr";
const CH_ID = "sys_ch";
const PC_ID = "sys_pc";

/**
 * AとBの間に挟まった場合、距離・空中・時間差でフレームが変動するため
 * A→B の直接検証をスキップする共通システムパーツID。
 */
const GAP_SYSTEM_MOVE_IDS: ReadonlySet<string> = new Set([
  "sys_dr",
  "sys_raw_dr",
  "sys_di",
  "sys_micro_walk",
  "sys_dash",
  "sys_delay",
  "sys_jump",
  "sys_f_jump",
  "sys_jc",
]);

/** 派生技・ターゲットコンボ後段・構え派生を示唆する技名／コマンド表記パターン */
const FOLLOWUP_NAME_PATTERN =
  /(?:2段目|3段目|２段目|３段目|派生|追撃|追加|自動派生|射出|起爆|爆発)/;
const FOLLOWUP_COMMAND_PATTERN = /(?:>|＞|中に|中P|中K|中弱|中中|中強|中攻撃|中方向|中N|後PP|後PPP|後SP|後A\+SP|から)/;
const FOLLOWUP_ID_PATTERN = /(?:_tc_|_followup|_derive|_hasei|_auto_.*_combo)/i;

function normalizeCancelTokens(cancelTypes?: string[] | null): Set<string> | null {
  if (!Array.isArray(cancelTypes)) return null;
  const set = new Set<string>();
  for (const raw of cancelTypes) {
    if (typeof raw === "string" && raw.trim()) {
      set.add(raw.trim().toUpperCase());
    }
  }
  return set;
}

function canCancelIntoDriveRush(move: Move): boolean | null {
  const tokens = normalizeCancelTokens(move.cancelTypes);
  if (tokens === null) return null;
  return (
    tokens.has("C") ||
    tokens.has("DR") ||
    tokens.has("CDR") ||
    tokens.has("SPECIAL")
  );
}

function getSaLevel(move: Move): 1 | 2 | 3 | null {
  if (move.category !== "super") return null;
  const combined = `${move.notationNumpad} ${move.notationName} ${move.id}`.toUpperCase();
  if (/SA3/.test(combined)) return 3;
  if (/SA2/.test(combined)) return 2;
  if (/SA1/.test(combined)) return 1;
  return null;
}

function canCancelIntoMove(fromMove: Move, toMove: Move): boolean {
  const tokens = normalizeCancelTokens(fromMove.cancelTypes);
  if (tokens === null || tokens.size === 0) return false;

  if (toMove.category === "special") {
    return tokens.has("C") || tokens.has("SPECIAL");
  }

  if (toMove.category === "super") {
    const saLevel = getSaLevel(toMove);
    if (saLevel === null) return true;
    if (saLevel === 1) {
      return tokens.has("C") || tokens.has("SA") || tokens.has("SA1") || tokens.has("SUPER");
    }
    if (saLevel === 2) {
      return (
        tokens.has("C") ||
        tokens.has("SA") ||
        tokens.has("SA2") ||
        tokens.has("SUPER")
      );
    }
    // saLevel === 3（公式仕様: 【C】【SA】【SA2】【SA3】すべて SA3 キャンセル可能）
    return (
      tokens.has("C") ||
      tokens.has("SA") ||
      tokens.has("SA2") ||
      tokens.has("SA3") ||
      tokens.has("SUPER")
    );
  }

  if (toMove.category === "unique") {
    return tokens.has("TC");
  }

  return false;
}

function isModernAssistCombo(move: Move): boolean {
  return /_auto_.*_combo$/i.test(move.id) || move.notationName.includes("アシストコンボ");
}

function isFollowUpOrTargetComboContinuation(move: Move): boolean {
  if (DRIVE_COST_EXCLUDED_MOVE_IDS.has(move.id)) return true;
  if (isModernAssistCombo(move)) return true;
  if (FOLLOWUP_ID_PATTERN.test(move.id)) return true;
  if (move.notationNumpad.includes(">") || move.notationNumpad.includes("＞")) {
    return true;
  }
  if (FOLLOWUP_COMMAND_PATTERN.test(move.notationCommand)) {
    return true;
  }
  if (FOLLOWUP_NAME_PATTERN.test(move.notationName)) {
    return true;
  }
  return false;
}

function isLightChainableMove(move: Move): boolean {
  if (move.startupFrames == null || move.startupFrames > 5) return false;
  if (move.category !== "normal" && move.category !== "unique") return false;
  // 立ち/しゃがみ弱攻撃（クラシック 弱P/2弱P/弱K/2弱K、モダン 弱/2弱/A弱単発 ※旧5表記も許容）
  const np = move.notationNumpad;
  if (/^J|空|垂直/.test(np)) return false;
  return /^(?:[12456]?弱[PK]?|A弱\(単発\))$/.test(np);
}

function isNonHittingUtilityMove(move: Move): boolean {
  return move.startupFrames == null && move.hitAdvantage == null;
}

function formatSignedFrames(value: number): string {
  return value >= 0 ? `+${value}F` : `${value}F`;
}

/**
 * コンボレシピのフレーム整合性を検証し、繋がらない可能性が高い箇所を
 * ソフト警告として返す純粋関数。
 *
 * 誤検知（偽陽性）を防ぐため、不確定・特殊状況のケースは安全側（警告なし）に倒す。
 */
export function validateComboRecipe({
  moves,
  moveIds,
  situations,
}: ValidateComboRecipeInput): ComboValidationWarning[] {
  if (!moveIds || moveIds.length < 2) {
    return [];
  }

  // 1. 全体スキップ条件
  for (const sit of situations) {
    if (SKIP_VALIDATION_SITUATIONS.has(sit)) {
      return [];
    }
  }

  const moveMap = new Map<string, Move>();
  for (const move of moves) {
    moveMap.set(move.id, move);
  }

  const hasCounterSituation = situations.includes("counter");
  const hasPunishCounterSituation = situations.includes("punish_counter");

  const warnings: ComboValidationWarning[] = [];

  // 各実技（category !== 'system'）のインデックス一覧を抽出
  const realMoveIndices: number[] = [];
  for (let i = 0; i < moveIds.length; i++) {
    const move = moveMap.get(moveIds[i]);
    if (move && move.category !== "system") {
      realMoveIndices.push(i);
    }
  }

  if (realMoveIndices.length === 0) {
    return [];
  }

  // 実技ごとの直前・直後システムトークンを踏まえ、各繋ぎ目を走査
  let consumedTrailingModifierIndex = -1;

  for (let r = 0; r < realMoveIndices.length; r++) {
    const idxA = realMoveIndices[r];
    const moveA = moveMap.get(moveIds[idxA]);
    if (!moveA) continue;

    // インストール系SA2が発動された場合、それ以降の検証を打ち切る
    if (INSTALL_SA_MOVE_IDS.has(moveA.id)) {
      break;
    }

    const prevRealIdx = r > 0 ? realMoveIndices[r - 1] : -1;
    const nextRealIdx =
      r + 1 < realMoveIndices.length ? realMoveIndices[r + 1] : moveIds.length;

    // Aの直前に並ぶシステムパーツ（prevRealIdx < k < idxA）を解析
    let hasPrevDr = false;
    let hasPrevCh = false;
    let hasPrevPc = false;
    for (let k = prevRealIdx + 1; k < idxA; k++) {
      if (k === consumedTrailingModifierIndex) continue;
      const sysId = moveIds[k];
      if (sysId === CANCEL_DR_ID || sysId === RAW_DR_ID) {
        hasPrevDr = true;
      } else if (sysId === PC_ID) {
        hasPrevPc = true;
      } else if (sysId === CH_ID) {
        hasPrevCh = true;
      }
    }

    // 先頭実技の直後に (CH)/(PC) が置かれている表記（例: 5中P > (CH) > 2中P）も安全に拾う
    let hasTrailingCh = false;
    let hasTrailingPc = false;
    if (r === 0 && !hasPrevCh && !hasPrevPc && idxA + 1 < nextRealIdx) {
      const immediateNextId = moveIds[idxA + 1];
      if (immediateNextId === PC_ID) {
        hasTrailingPc = true;
        consumedTrailingModifierIndex = idxA + 1;
      } else if (immediateNextId === CH_ID) {
        hasTrailingCh = true;
        consumedTrailingModifierIndex = idxA + 1;
      }
    }

    // 実技Aのヒット有利補正を算出（パーツと状況タグの二重加算を防止）
    let chPcBonus = 0;
    if (hasPrevPc || hasTrailingPc) {
      chPcBonus = 4;
    } else if (hasPrevCh || hasTrailingCh) {
      chPcBonus = 2;
    } else if (r === 0) {
      if (hasPunishCounterSituation) {
        chPcBonus = 4;
      } else if (hasCounterSituation) {
        chPcBonus = 2;
      }
    }

    const drBonus =
      hasPrevDr && (moveA.category === "normal" || moveA.category === "unique")
        ? 4
        : 0;

    // Aと次の実技Bの間にあるシステムパーツ（idxA < k < nextRealIdx）を確認
    let hasGapBetweenAAndB = false;
    let cancelDrIndex = -1;

    for (let k = idxA + 1; k < nextRealIdx; k++) {
      const sysId = moveIds[k];
      const sysMove = moveMap.get(sysId);

      // チェック①用: A の直後に CDR（sys_dr）があるか検出（途中に他ギャップが無ければ直後扱い）
      if (sysId === CANCEL_DR_ID && !hasGapBetweenAAndB && cancelDrIndex === -1) {
        cancelDrIndex = k;
      }

      if (
        GAP_SYSTEM_MOVE_IDS.has(sysId) ||
        (sysMove && sysMove.category === "system" && sysMove.characterId !== null)
      ) {
        hasGapBetweenAAndB = true;
      }
    }

    // チェック①：キャンセルラッシュ（CDR: sys_dr）可否
    if (
      cancelDrIndex !== -1 &&
      !isModernAssistCombo(moveA) &&
      !isNonHittingUtilityMove(moveA)
    ) {
      const cdrAllowed = canCancelIntoDriveRush(moveA);
      if (cdrAllowed === false) {
        warnings.push({
          stepIndex: cancelDrIndex,
          fromMoveId: moveA.id,
          toMoveId: CANCEL_DR_ID,
          kind: "cancel_unavailable",
          message: `${moveA.notationNumpad}（${moveA.notationName}）はキャンセルラッシュ非対応の可能性があります`,
        });
      }
    }

    // 次の実技Bが無ければ終了
    if (nextRealIdx >= moveIds.length) {
      continue;
    }

    // AとBの間にギャップ／システムパーツが挟まっていれば直接検証はスキップ
    if (hasGapBetweenAAndB) {
      continue;
    }

    const moveB = moveMap.get(moveIds[nextRealIdx]);
    if (!moveB) continue;

    // 非打撃技（構え・移動・バフ等）からの遷移はヒット硬直を伴わないためスキップ
    if (isNonHittingUtilityMove(moveA)) {
      continue;
    }

    // チェック②：通常投げの連続技組み込み
    if (moveB.category === "throw") {
      if (moveA.category !== "throw") {
        warnings.push({
          stepIndex: nextRealIdx,
          fromMoveId: moveA.id,
          toMoveId: moveB.id,
          kind: "throw_in_combo",
          message: `ヒット硬直中の相手には通常投げ（${moveB.notationNumpad}）は繋がりません（リセット・補正切り用途なら問題ありません）`,
        });
      }
      continue;
    }

    // Bが派生技・TC後段・構え派生・アシストコンボなら安全側でスキップ
    if (isFollowUpOrTargetComboContinuation(moveB)) {
      continue;
    }

    // Aがモダンアシストコンボの場合は最終段のフレームが可変のためスキップ
    if (isModernAssistCombo(moveA)) {
      continue;
    }

    // チェック③-1：キャンセル成立判定
    if (canCancelIntoMove(moveA, moveB)) {
      continue;
    }

    // 必殺技→必殺技（風破チェーン・特殊派生・空中追撃等）や SA→追撃 は安全側でスキップ
    if (
      (moveA.category === "special" && moveB.category === "special") ||
      moveA.category === "super" ||
      moveA.category === "throw"
    ) {
      continue;
    }

    // Aのヒット有利またはBの発生が未定義／ダウン・空中技(null)なら目押し判定をスキップ
    if (moveA.hitAdvantage == null || moveB.startupFrames == null) {
      continue;
    }

    // 連打キャンセル（4〜5F帯の弱攻撃同士）は誤検知防止のためスキップ
    if (isLightChainableMove(moveA) && isLightChainableMove(moveB)) {
      continue;
    }

    // チェック③-2：目押し（リンク）フレームチェック
    const effectiveAdvantage = moveA.hitAdvantage + chPcBonus + drBonus;
    const nextStartup = moveB.startupFrames;

    if (effectiveAdvantage < nextStartup) {
      const shortageFrames = nextStartup - effectiveAdvantage;
      const isSpecialOrSuper =
        moveB.category === "special" || moveB.category === "super";
      const reasonSuffix = isSpecialOrSuper
        ? `キャンセル非対応かつ ${shortageFrames}F不足のため繋がらない可能性があります`
        : `${shortageFrames}F不足のため繋がらない可能性があります`;

      warnings.push({
        stepIndex: nextRealIdx,
        fromMoveId: moveA.id,
        toMoveId: moveB.id,
        kind: "frame_shortage",
        shortageFrames,
        effectiveAdvantage,
        nextStartup,
        message: `${moveA.notationNumpad} (${formatSignedFrames(effectiveAdvantage)}) → ${moveB.notationNumpad} (発生${nextStartup}F)：${reasonSuffix}`,
      });
    }
  }

  return warnings;
}
