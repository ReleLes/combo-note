import type {
  ControlType,
  Move,
  MoveCategory,
  NotationMode,
} from "@/types/combo";

/**
 * コンボビルダーUI専用の技カテゴリタブキー。
 * DBスキーマ上の MoveCategory は変更せず、モダン選択時のみ「アシスト」タブを切り出す。
 */
export type MoveBuilderTabKey = MoveCategory | "assist";

const MODERN_ASSIST_TAB_MOVE_ID_PATTERN =
  /_m_assist_(?:l|m|h)_(?:1|2|full)$/i;
const DEPRECATED_ASSIST_COMBO_ID_PATTERN = /_m_auto_.*_combo$/i;
const DEPRECATED_GROUND_AUTO_MOVE_ID_PATTERN = /_m_auto_(?:l|m|h)$/i;

/**
 * 新モダン・アシストコンボ（{prefix}_m_assist_{l|m|h}_{1|2|full}）かどうかを判定する。
 */
export function isModernAssistTabMove(move: Move): boolean {
  return (
    move.controlType === "modern" &&
    move.category === "unique" &&
    MODERN_ASSIST_TAB_MOVE_ID_PATTERN.test(move.id)
  );
}

/**
 * ビルダーの技選択パレットから非表示にする旧アシスト技IDかどうかを判定する。
 * - 旧アシストコンボ（*_m_auto_*_combo）
 * - 新1段目と役割が重複する地上単発アシスト（*_m_auto_{l|m|h}）
 * ※空中アシスト（*_m_j_auto_* 等）は除外しない。
 * ※既存コンボ・既存マイノート描画用の moveMap からは絶対に除外しないこと。
 */
export function isDeprecatedAssistMove(move: Move): boolean {
  return (
    DEPRECATED_ASSIST_COMBO_ID_PATTERN.test(move.id) ||
    DEPRECATED_GROUND_AUTO_MOVE_ID_PATTERN.test(move.id)
  );
}

const BASE_MOVE_BUILDER_TABS: { key: MoveBuilderTabKey; label: string }[] = [
  { key: "normal", label: "通常技" },
  { key: "unique", label: "特殊技" },
  { key: "special", label: "必殺技" },
  { key: "super", label: "SA" },
  { key: "throw", label: "投げ" },
  { key: "system", label: "システム" },
];

const MODERN_MOVE_BUILDER_TABS: { key: MoveBuilderTabKey; label: string }[] = [
  { key: "normal", label: "通常技" },
  { key: "assist", label: "アシスト" },
  { key: "unique", label: "特殊技" },
  { key: "special", label: "必殺技" },
  { key: "super", label: "SA" },
  { key: "throw", label: "投げ" },
  { key: "system", label: "システム" },
];

/**
 * 操作タイプに応じたコンボビルダー用カテゴリタブ定義を返す。
 * モダン選択時のみ「アシスト」タブを含む7タブ、それ以外は従来の6タブを返す。
 */
export function getMoveBuilderCategoryTabs(
  controlType: ControlType | ""
): { key: MoveBuilderTabKey; label: string }[] {
  return controlType === "modern"
    ? MODERN_MOVE_BUILDER_TABS
    : BASE_MOVE_BUILDER_TABS;
}

/**
 * 攻撃始動となり得るシステム技ID。
 * DI（ドライブインパクト）は始動技になり得るため、システム補助スキップの対象外とする。
 */
const STARTER_ALLOWED_SYSTEM_MOVE_IDS: ReadonlySet<string> = new Set([
  "sys_di",
]);

/**
 * コンボの moveIds を先頭から走査し、非攻撃のシステム補助・修飾パーツ
 * （(CH), (PC), CDR, DR, 微歩き, 前ステップ, ディレイ, ジャンプ等）をスキップして
 * 最初の実技IDを「始動技」として抽出する。
 * ※ DI（sys_di）は始動技になり得るためスキップしない。
 */
export function getStarterMoveId(
  moveIds: string[],
  moveMap: Record<string, Move>
): string | null {
  for (const id of moveIds) {
    const move = moveMap[id];
    if (!move) continue;
    if (
      move.category === "system" &&
      !STARTER_ALLOWED_SYSTEM_MOVE_IDS.has(move.id)
    ) {
      continue;
    }
    return move.id;
  }

  return moveIds[0] ?? null;
}

/**
 * 技1つを選択中の表記モードのプレーンテキストへ変換する。
 */
export function formatMoveText(move: Move, notationMode: NotationMode): string {
  switch (notationMode) {
    case "numpad":
      return move.notationNumpad;
    case "command":
      return move.notationCommand;
    case "name":
      return move.notationName;
  }
}

/**
 * 技配列を選択中の表記モードで連結したコピー用レシピ文字列を生成する。
 */
export function formatComboRecipeText(
  moves: Move[],
  notationMode: NotationMode
): string {
  return moves.map((move) => formatMoveText(move, notationMode)).join(" > ");
}

/**
 * クリップボードへテキストをコピーする（Clipboard API 未対応時のフォールバック付き）。
 */
export async function copyTextToClipboard(text: string): Promise<boolean> {
  if (typeof window === "undefined") return false;

  try {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      await navigator.clipboard.writeText(text);
      return true;
    }
  } catch {
    // フォールバックへ継続
  }

  try {
    const textarea = document.createElement("textarea");
    textarea.value = text;
    textarea.setAttribute("readonly", "");
    textarea.style.position = "fixed";
    textarea.style.top = "-9999px";
    textarea.style.left = "-9999px";
    document.body.appendChild(textarea);
    textarea.select();
    const ok = document.execCommand("copy");
    document.body.removeChild(textarea);
    return ok;
  } catch {
    return false;
  }
}

/**
 * ISO日時文字列を「3分前」「2時間前」「2026/11/24」のような読みやすい表記へ変換する。
 */
export function formatRelativePostedAt(
  isoString: string,
  nowMs: number = Date.now()
): string {
  const date = new Date(isoString);
  const timeMs = date.getTime();
  if (Number.isNaN(timeMs)) return "";

  const diffSec = Math.floor((nowMs - timeMs) / 1000);
  if (diffSec < 0) {
    return formatYmdDate(date);
  }
  if (diffSec < 60) {
    return "たった今";
  }
  const diffMin = Math.floor(diffSec / 60);
  if (diffMin < 60) {
    return `${diffMin}分前`;
  }
  const diffHour = Math.floor(diffMin / 60);
  if (diffHour < 24) {
    return `${diffHour}時間前`;
  }
  const diffDay = Math.floor(diffHour / 24);
  if (diffDay < 7) {
    return `${diffDay}日前`;
  }

  return formatYmdDate(date);
}

/**
 * ツールチップ等に表示する完全な日付時刻文字列（YYYY/MM/DD HH:mm）。
 */
export function formatFullDateTime(isoString: string): string {
  const date = new Date(isoString);
  if (Number.isNaN(date.getTime())) return "";
  const ymd = formatYmdDate(date);
  const hh = String(date.getHours()).padStart(2, "0");
  const mm = String(date.getMinutes()).padStart(2, "0");
  return `${ymd} ${hh}:${mm}`;
}

function formatYmdDate(date: Date): string {
  const yyyy = date.getFullYear();
  const mm = String(date.getMonth() + 1).padStart(2, "0");
  const dd = String(date.getDate()).padStart(2, "0");
  return `${yyyy}/${mm}/${dd}`;
}
