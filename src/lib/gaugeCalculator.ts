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
  // ケン: OD 迅雷脚からの追加派生（OD風鎌蹴り・OD轟雷落とし・OD閃火脚・火砕蹴は親技で既に +2 消費済み・追加消費なし）
  "ken_jinrai_od_l",
  "ken_jinrai_od_m",
  "ken_jinrai_od_h",
  "ken_jinrai_kasai",
  "ken_m_jinrai_od_l",
  "ken_m_jinrai_od_m",
  "ken_m_jinrai_od_h",
  "ken_m_jinrai_kasai",
  "ken_m_sp_jinrai_od_l",
  "ken_m_sp_jinrai_od_m",
  "ken_m_sp_jinrai_od_h",
  "ken_m_sp_jinrai_kasai",
  // ルーク: OD アベンジャーからの追加派生（ODノーチェイサー・ODインパラーは親技で既に +2 消費済み・追加消費なし）
  "luke_avenger_od_nc",
  "luke_avenger_od_imp",
  "luke_m_avenger_od_nc",
  "luke_m_avenger_od_imp",
  // キャミィ: OD フーリガンコンビネーションからの各種派生（親技で既に +2 消費済み・追加消費なし）
  "cammy_hooligan_od_razor",
  "cammy_hooligan_od_strike",
  "cammy_hooligan_od_reverse",
  "cammy_hooligan_od_fatal",
  "cammy_hooligan_od_silent",
  "cammy_m_hooligan_od_razor",
  "cammy_m_hooligan_od_strike",
  "cammy_m_hooligan_od_reverse",
  "cammy_m_hooligan_od_fatal",
  "cammy_m_hooligan_od_silent",
  // 春麗: OD 百裂脚からの追加派生（百裂連脚は親技で既に +2 消費済み・公式仕様どおり追加消費なし）
  "chunli_hyaku_renkyaku",
  "chunli_m_hyaku_renkyaku",
  "chunli_m_sp_hyaku_renkyaku",
  // ガイル: OD ソニックブレイドからの通常派生（ODソニッククロス1）および SA2 中の OD ソニックブレイク（親技で既に +2 消費済み・追加消費なし）
  "guile_cross_od_from_od",
  "guile_m_cross_od_from_od",
  "guile_break_od",
  "guile_m_break_od",
  // ベガ: OD シャドウライズからの各種OD派生（親技ODシャドウライズで既に +2 消費済み・追加消費なし）
  "vega_headpress_od_from_od",
  "vega_devil_od_from_od",
  "vega_devil_od_mine_from_od",
  "vega_m_headpress_od_from_od",
  "vega_m_devil_od_from_od",
  "vega_m_devil_od_mine_from_od",
  // JP: ヴィーハト（OD含む）設置中からの各種派生（ヴィーハト・アクノ／ヴィーハト・チェーニは追加消費なし）
  "jp_vihat_akno",
  "jp_vihat_cheni",
  "jp_m_vihat_akno",
  "jp_m_vihat_cheni",
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
  // ルーク: OD必殺技からの追加派生で、発動時にDゲージを10000（1本）追加消費する技（親技ODで+2、派生で+1＝計3本）
  luke_fatal_shot: 1, // フェイタルショット（ODサンドブラスト後）
  luke_ddt: 1, // DDT（ODフラッシュナックル後）
  luke_slam_dunk: 1, // スラムダンク（ODライジングアッパー後）
  luke_m_fatal_shot: 1, // フェイタルショット（モダン）
  luke_m_ddt: 1, // DDT（モダン）
  luke_m_slam_dunk: 1, // スラムダンク（モダン）
  luke_m_sp_fatal_shot: 1, // フェイタルショット（モダンSP）
  luke_m_sp_ddt: 1, // DDT（モダンSP）
  luke_m_sp_slam_dunk: 1, // スラムダンク（モダンSP）
  // ガイル: OD ソニックブレイドからの追撃強化派生（OD ソニッククロス2・壁やられ）は追加で Dゲージ 1本消費（計3本）
  guile_cross_od2: 1,
  guile_m_cross_od2: 1,
  guile_m_sp_cross_od2: 1,
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
