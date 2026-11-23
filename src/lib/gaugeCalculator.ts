import type { Move } from "@/types/combo";

export interface RecipeGaugeCostResult {
  /** 上限キャップ適用前の消費Dゲージ合計 */
  rawDriveCost: number;
  /** DB制約（0〜6）に合わせて上限キャップした消費Dゲージ */
  driveCost: number;
  /** 計算上の消費Dゲージが上限（6）を超過しているか */
  isDriveOverCap: boolean;
  /** 上限キャップ適用前の消費SAゲージ合計 */
  rawSaCost: number;
  /** DB制約（0〜3）に合わせて上限キャップした消費SAゲージ */
  saCost: 0 | 1 | 2 | 3;
}

/**
 * 親技のOD必殺技から派生し、追加のDゲージを消費しない技の除外リスト。
 * 二重カウントを防ぐため、これらの技は必ず Dゲージ消費 0 として扱う。
 */
export const DRIVE_COST_EXCLUDED_MOVE_IDS: ReadonlySet<string> = new Set([
  // 豪鬼: OD 金剛灼火（2段目）および OD 百鬼襲からの専用派生（親技で既に +2 消費済み）
  "akuma_214odp_2",
  "akuma_m_od_2sp_2",
  "akuma_hyakki_zanku",
  "akuma_hyakki_rasen",
  "akuma_m_hyakki_zanku",
  "akuma_m_hyakki_rasen",
  // ジュリ: OD 疾空閃からの派生（親技で既に +2 消費済み）
  "juri_shiku_odkk",
  "juri_m_shiku_od",
  // 舞: OD 花蝶扇（ホールド）からの派生（コマンド表記に "ODホールド後" を含むが追加消費なし）
  "mai_midare",
  "mai_midare_ex",
  "mai_m_midare",
  "mai_m_midare_ex",
]);

/**
 * 技ID単位の個別Dゲージ消費コストマップ。
 * システム共通パーツや、表記ルールだけでは判別しづらい技のコストを明示管理する。
 */
export const MOVE_DRIVE_COST_OVERRIDES: Readonly<Record<string, number>> = {
  // システム共通パーツ
  sys_dr: 3, // キャンセルドライブラッシュ (CDR)
  sys_raw_dr: 1, // 生ドライブラッシュ (DR)
  sys_di: 1, // ドライブインパクト (DI)
  // C.ヴァイパー: 発動時に Dゲージを 10000（1本）消費する固有アクション・派生技
  cviper_hj_f: 1, // ハイジャンプ（前方）
  cviper_hj_v: 1, // ハイジャンプ（垂直）
  cviper_hjc: 1, // ハイジャンプキャンセル
  cviper_trace_l: 1, // 弱 トレースコンビネーション
  cviper_trace_m: 1, // 中 トレースコンビネーション
  cviper_trace_h: 1, // 強 トレースコンビネーション
  cviper_m_trace_l: 1, // 弱 トレースコンビネーション（モダン）
  cviper_m_trace_m: 1, // 中 トレースコンビネーション（モダン）
  cviper_m_trace_h: 1, // 強 トレースコンビネーション（モダン）
  cviper_chase: 1, // チェイスナックル
  cviper_m_chase: 1, // チェイスナックル（モダン）
  cviper_double_burn: 1, // ダブルバーン
  cviper_m_double_burn: 1, // ダブルバーン（モダン）
};

/**
 * 技ID単位の個別SAゲージ消費コストマップ（将来拡張・例外技用）。
 */
export const MOVE_SA_COST_OVERRIDES: Readonly<Record<string, number>> = {};

/**
 * 技1つが OD 必殺技（消費Dゲージ +2）かどうかを判定する。
 * 除外リストに含まれる派生技は呼び出し元で先に除外されている前提。
 */
function isOdSpecialMove(move: Move): boolean {
  if (move.category !== "special") return false;

  // 表記に "OD" を含む技（クラシックOD・モダンコマンドOD・モダンワンボタンOD技名）
  if (
    move.notationNumpad.includes("OD") ||
    move.notationName.includes("OD")
  ) {
    return true;
  }

  // モダンワンボタンOD技（A+N必, A+前必, A+後必, A+下必, A+空必 等）
  if (
    /A\+.*必/.test(move.notationNumpad) ||
    /(?:^|[^A-Za-z])A\+.*SP/.test(move.notationCommand)
  ) {
    return true;
  }

  // ID命名規則によるフォールバック（例: akuma_214odp, ingrid_214odk, cviper_623odp, *_m_od_*）
  if (/(?:^|_)od(?:$|_|\d|[a-z]{1,2}$)/i.test(move.id) || /\d+od[pk]/i.test(move.id)) {
    return true;
  }

  return false;
}

/**
 * 単一の技の消費Dゲージを算出する。
 */
export function getMoveDriveCost(move: Move): number {
  if (DRIVE_COST_EXCLUDED_MOVE_IDS.has(move.id)) {
    return 0;
  }

  const override = MOVE_DRIVE_COST_OVERRIDES[move.id];
  if (override !== undefined) {
    return override;
  }

  // システムパーツのフォールバック判定（キャンセルDR を 生DR より先に判定）
  if (move.category === "system") {
    const numpad = move.notationNumpad.trim().toUpperCase();
    const name = move.notationName;
    if (numpad === "CDR" || name.includes("キャンセルドライブラッシュ")) {
      return 3;
    }
    if (
      numpad === "DR" ||
      numpad === "生DR" ||
      numpad === "生ラッシュ" ||
      name === "ドライブラッシュ" ||
      name.includes("生ドライブラッシュ") ||
      name.includes("生ラッシュ")
    ) {
      return 1;
    }
    if (numpad === "DI" || name.includes("ドライブインパクト")) {
      return 1;
    }
    return 0;
  }

  // OD 必殺技
  if (isOdSpecialMove(move)) {
    return 2;
  }

  return 0;
}

/**
 * 単一の技の消費SAゲージを算出する。
 */
export function getMoveSaCost(move: Move): number {
  const override = MOVE_SA_COST_OVERRIDES[move.id];
  if (override !== undefined) {
    return override;
  }

  if (move.category !== "super") {
    return 0;
  }

  const combined = `${move.notationNumpad} ${move.notationName} ${move.id}`.toUpperCase();
  if (/SA3/.test(combined)) return 3;
  if (/SA2/.test(combined)) return 2;
  if (/SA1/.test(combined)) return 1;

  return 0;
}

/**
 * レシピの技配列から消費Dゲージ・消費SAゲージを自動計算する純粋関数。
 */
export function calculateRecipeGaugeCost(moves: Move[]): RecipeGaugeCostResult {
  let rawDriveCost = 0;
  let rawSaCost = 0;

  for (const move of moves) {
    rawDriveCost += getMoveDriveCost(move);
    rawSaCost += getMoveSaCost(move);
  }

  const driveCost = Math.min(6, rawDriveCost);
  const isDriveOverCap = rawDriveCost > 6;
  const clampedSa = Math.min(3, Math.max(0, Math.round(rawSaCost)));
  const saCost: 0 | 1 | 2 | 3 =
    clampedSa === 1 || clampedSa === 2 || clampedSa === 3 ? clampedSa : 0;

  return {
    rawDriveCost,
    driveCost,
    isDriveOverCap,
    rawSaCost,
    saCost,
  };
}
