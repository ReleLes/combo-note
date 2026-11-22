import type { Move, NotationMode } from "@/types/combo";

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
