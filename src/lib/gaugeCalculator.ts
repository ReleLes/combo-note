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
  // エド: OD サイコスパークからの追撃派生（OD サイコシュート弱/中/強は親技ODサイコスパークで既に +2 消費済み・追加消費なし）
  "ed_shoot_od_l",
  "ed_shoot_od_m",
  "ed_shoot_od_h",
  "ed_m_shoot_od_l",
  "ed_m_shoot_od_m",
  "ed_m_shoot_od_h",
  // サガット: OD タイガーネクサスからの各種OD派生（親技ODタイガーネクサスで既に +2 消費済み・追加消費なし）
  "sagat_nexus_od_might",
  "sagat_nexus_od_greed",
  "sagat_nexus_od_nova",
  "sagat_m_nexus_od_might",
  "sagat_m_nexus_od_greed",
  "sagat_m_nexus_od_nova",
  // ディージェイ: OD ジョスクールからの各種OD派生（親技ODジョスクールで既に +2 消費済み・追加消費なし）
  "deejay_jos_od_lk",
  "deejay_jos_od_mk",
  "deejay_jos_od_hk",
  "deejay_jos_od_step",
  "deejay_jos_od_sway",
  "deejay_m_jos_od_l",
  "deejay_m_jos_od_m",
  "deejay_m_jos_od_h",
  "deejay_m_jos_od_step",
  "deejay_m_jos_od_sway",
  // ラシード: アラビアン・サイクロン（OD含む）からの各種派生（親技ODアラビアン・サイクロンで既に +2 消費済み・追加消費なし）
  "rashid_wing_stroke",
  "rashid_assault_roll",
  "rashid_assault_nail",
  "rashid_m_wing_stroke",
  "rashid_m_assault_roll",
  "rashid_m_assault_nail",
  // A.K.I.: OD 紫煙砲からの追撃派生（OD 紫煙追は親技OD紫煙砲で既に +2 消費済み・追加消費なし）
  "aki_shientsui_od",
  "aki_m_shientsui_od",
  // エレナ: OD リンクシング派生（ODリンクスワール・強化版各種）および OD ムーングライド（2段目）は親技で既に +2 消費済み・追加消費なし
  "elena_swirl_od",
  "elena_m_swirl_od",
  "elena_leopard_ex",
  "elena_harvest_ex",
  "elena_mallet_ex",
  "elena_m_leopard_ex",
  "elena_m_harvest_ex",
  "elena_m_mallet_ex",
  "elena_moonglide_od_2",
  "elena_m_moonglide_od_2",
  // アレックス: OD パワードロップからのハイパーボム派生（親技ODパワードロップで既に +2 消費済み・追加消費なし）
  "alex_hyperbomb",
  "alex_m_hyperbomb",
  // ヤスミン: OD ダロイ・ン・トゥビグからの OD アロン派生、および OD ムカ・ン・ランギットからの OD ウラン／OD クロッグ派生（親技で既に +2 消費済み・追加消費なし）
  "yasmine_aron_od",
  "yasmine_aron_od_ex",
  "yasmine_aron_od_sa2",
  "yasmine_m_aron_od",
  "yasmine_m_aron_od_ex",
  "yasmine_m_aron_od_sa2",
  "yasmine_ulan_od_from_od",
  "yasmine_kulog_od_from_od",
  "yasmine_m_ulan_od_from_od",
  "yasmine_m_kulog_od_from_od",
  // アルジュン: OD 大義の巨腕からの OD 追撃、OD 厳酷な岩肩からの OD 過剰な正義、OD 息吹の円筒からの OD 息吹の震撼（親技で既に +2 消費済み・追加消費なし）
  "arjun_236odp_followup",
  "arjun_m_236od_followup",
  "arjun_kajo_od",
  "arjun_m_kajo_od",
  "arjun_shinkan_od_l",
  "arjun_shinkan_od_m",
  "arjun_shinkan_od_h",
  "arjun_m_shinkan_od_l",
  "arjun_m_shinkan_od_m",
  "arjun_m_shinkan_od_h",
  // ジェイミー: OD 流酔拳（2段目・3段目）、OD 流酔脚（2段目・3段目）、OD 疾歩仙掌（親技OD流酔拳1段目／OD酔疾歩で既に +2 消費済み・追加消費なし）
  "jamie_ryusuiken_od_2",
  "jamie_ryusuiken_od_lv4_2",
  "jamie_ryusuiken_od_3",
  "jamie_ryusuiken_od_lv4_3",
  "jamie_ryusuikyaku_od_2",
  "jamie_ryusuikyaku_od_3",
  "jamie_sipposensho_od",
  "jamie_m_ryusuiken_od_2",
  "jamie_m_ryusuiken_od_lv4_2",
  "jamie_m_ryusuiken_od_3",
  "jamie_m_ryusuiken_od_lv4_3",
  "jamie_m_ryusuikyaku_od_2",
  "jamie_m_ryusuikyaku_od_3",
  "jamie_m_sipposensho_od",
  // キンバリー: OD 疾駆けおよび OD 弧空からの全派生（親技OD疾駆けで既に +2 消費済み・追加消費なし）
  "kimberly_hayagake_od_stop",
  "kimberly_hayagake_od_dohane",
  "kimberly_hayagake_od_kage",
  "kimberly_hayagake_od_kubi",
  "kimberly_koku_od",
  "kimberly_izuna_od",
  "kimberly_hoko_od",
  "kimberly_m_hayagake_od_stop",
  "kimberly_m_hayagake_od_dohane",
  "kimberly_m_hayagake_od_kage",
  "kimberly_m_hayagake_od_kubi",
  "kimberly_m_koku_od",
  "kimberly_m_izuna_od",
  "kimberly_m_hoko_od",
  // マリーザ: OD ディマカイルス（2段目）および OD スクトゥムからの各種派生（親技で既に +2 消費済み・追加消費なし）
  "marisa_dimachaerus_od_2",
  "marisa_scutum_od_counter",
  "marisa_tonitrus_1",
  "marisa_tonitrus_2",
  "marisa_procella",
  "marisa_enfold",
  "marisa_m_dimachaerus_od_2",
  "marisa_m_scutum_od_counter",
  "marisa_m_tonitrus_1",
  "marisa_m_tonitrus_2",
  "marisa_m_procella",
  "marisa_m_enfold",
  // マノン: OD ランヴェルセからの OD グラン・フェッテおよびフェイント派生（親技ODランヴェルセで既に +2 消費済み・追加消費なし）
  "manon_grand_fouette_od",
  "manon_renverse_feint",
  "manon_m_grand_fouette_od",
  "manon_m_renverse_feint",
  // ブランカ: OD ブランカちゃん爆弾（起動・射出）およびローリングキャノン派生（親技OD電撃／ODローリング等で既に +2 消費済み・追加消費なし）
  "blanka_bomb_shot_od",
  "blanka_m_bomb_shot_od",
  "blanka_rolling_cannon",
  "blanka_m_rolling_cannon",
  // エドモンド本田: OD 相撲ステップからの OD 鉄砲（1・2段目）および OD 大砲派生（親技OD相撲ステップで既に +2 消費済み・追加消費なし）
  "ehonda_teppo_od_1",
  "ehonda_teppo_od_2",
  "ehonda_taiho_od",
  "ehonda_m_teppo_od_1",
  "ehonda_m_teppo_od_2",
  "ehonda_m_taiho_od",
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
  // テリー: SA2 ツインゲイザーは公式仕様どおり Dゲージを 3本消費（SAゲージ追加消費なし）
  terry_sa2_twin: 3,
  terry_m_sa2_twin: 3,
  // リリー: 風纏いコンドルダイブ後の OD コンドルダイブ（派生）は公式仕様どおり Dゲージ 10000（1本）消費
  lily_dive_followup_od: 1,
  lily_m_dive_followup_od: 1,
  // モダン・アシストコンボ出し切り（*_m_assist_{l|m|h}_full）のキャラ別例外上書き枠
  // ※共通デフォルト（l_full: D0 / m_full: D2 / h_full: D0）より本マップが優先される。
  //   OD必殺技の有無が共通デフォルトと異なるキャラが確定した場合、以下のように1行ずつ追記する：
  //   例: 強アシスト出し切りでOD必殺技を挟むキャラ → <prefix>_m_assist_h_full: 2,
  //   例: 中アシスト出し切りでOD必殺技を挟まないキャラ → <prefix>_m_assist_m_full: 0,
};

/**
 * 技ID単位の個別SAゲージ消費コストマップ（将来拡張・例外技用）。
 */
export const MOVE_SA_COST_OVERRIDES: Readonly<Record<string, number>> = {
  // テリー: SA2 パワーゲイザーからの追撃派生
  // - ツインゲイザー: 追加SA消費なし（0、Dゲージ3本消費のみ）
  // - トリプルゲイザー: 追加SA消費 +1（パワーゲイザーSA2と合算して計SA3）
  terry_sa2_twin: 0,
  terry_m_sa2_twin: 0,
  terry_sa2_triple: 1,
  terry_m_sa2_triple: 1,
  // サガット: SA2 サベージタイガーからの4方向派生フィニッシュ（親技SA2で既に消費済み・追加SA 0）
  sagat_sa2_raid: 0,
  sagat_sa2_zenith: 0,
  sagat_sa2_pendulum: 0,
  sagat_sa2_stamp: 0,
  sagat_m_sa2_raid: 0,
  sagat_m_sa2_zenith: 0,
  sagat_m_sa2_pendulum: 0,
  sagat_m_sa2_stamp: 0,
  // ディージェイ: SA2 サンライズフェスティバルからのフィニッシュ派生（親技SA2で既に消費済み・追加SA 0）
  deejay_sa2_climax: 0,
  deejay_sa2_encore: 0,
  deejay_m_sa2_climax: 0,
  deejay_m_sa2_encore: 0,
  // モダン・アシストコンボ出し切り（*_m_assist_{l|m|h}_full）のキャラ別SA消費例外上書き枠
  // ※共通デフォルト（l_full: SA1 / m_full: SA2 / h_full: SA3）より本マップが優先される。
  //   例: <prefix>_m_assist_m_full: 0,
};

const MODERN_ASSIST_FULL_ID_PATTERN = /_m_assist_(l|m|h)_full$/i;

/**
 * モダン・アシストコンボ出し切り（*_m_assist_{l|m|h}_full）のフルゲージ時デフォルト消費を返す。
 * 1段目（_1）・2段止め（_2）は消費なしのため null を返す。
 */
function getModernAssistFullDefaultGauge(
  move: Move
): { drive: number; sa: number } | null {
  const match = MODERN_ASSIST_FULL_ID_PATTERN.exec(move.id);
  if (!match) return null;

  switch (match[1].toLowerCase()) {
    case "l":
      return { drive: 0, sa: 1 };
    case "m":
      return { drive: 2, sa: 2 };
    case "h":
      return { drive: 0, sa: 3 };
    default:
      return null;
  }
}

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

  // モダン・アシストコンボ出し切り（*_m_assist_{l|m|h}_full）の共通デフォルト消費
  const assistDefault = getModernAssistFullDefaultGauge(move);
  if (assistDefault !== null) {
    return assistDefault.drive;
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

  // モダン・アシストコンボ出し切り（*_m_assist_{l|m|h}_full）の共通デフォルト消費
  const assistDefault = getModernAssistFullDefaultGauge(move);
  if (assistDefault !== null) {
    return assistDefault.sa;
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
