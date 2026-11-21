"use client";

import { useState } from "react";
import { ChevronRight, Lock, Pencil, Trash2 } from "lucide-react";
import type {
  Move,
  NotationMode,
  PrivateNote,
  SituationDefinition,
} from "@/types/combo";
import { MoveNotation } from "@/components/CommandNotation";

interface PrivateNoteCardProps {
  note: PrivateNote;
  situations: SituationDefinition[];
  moveMap: Record<string, Move>;
  notationMode: NotationMode;
  onEdit: (note: PrivateNote) => void;
  onDelete: (id: string) => void;
}

function resolveSituationStyle(
  situationLabel: string,
  situations: SituationDefinition[]
): string {
  const matched = situations.find(
    (s) => s.label === situationLabel || s.key === situationLabel
  );
  return matched?.badgeClassName ?? "bg-indigo-100 text-indigo-700";
}

function getMoveChipStyle(move: Move): string {
  switch (move.category) {
    case "system":
      return "border-slate-200 bg-slate-100 text-slate-700";
    case "super":
      return "border-indigo-200 bg-indigo-50 text-indigo-800 font-semibold";
    case "special":
      return "border-blue-200 bg-blue-50/70 text-slate-900 font-medium";
    case "throw":
      return "border-amber-200 bg-amber-50/70 text-amber-900 font-medium";
    default:
      return "border-slate-200 bg-white text-slate-900 font-medium";
  }
}

function formatUpdatedAt(isoString: string): string {
  const d = new Date(isoString);
  if (Number.isNaN(d.getTime())) return "";
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}/${m}/${day}`;
}

export function PrivateNoteCard({
  note,
  situations,
  moveMap,
  notationMode,
  onEdit,
  onDelete,
}: PrivateNoteCardProps) {
  const [confirmingDelete, setConfirmingDelete] = useState(false);

  const badgeStyle = resolveSituationStyle(note.situation, situations);
  const resolvedMoves = (note.moveIds ?? [])
    .map((id) => moveMap[id])
    .filter((m): m is Move => Boolean(m));
  const hasBuilderRecipe = resolvedMoves.length > 0;

  return (
    <article className="rounded-xl border border-slate-200 bg-white p-3.5 shadow-xs sm:p-4">
      {/* ヘッダー行：状況バッジ + 操作タイプ + 編集・削除 */}
      <div className="mb-3 flex items-start justify-between gap-2">
        <div className="flex flex-wrap items-center gap-1.5">
          <span
            className={`inline-flex items-center rounded-md px-2 py-0.5 text-xs font-bold tracking-tight ${badgeStyle}`}
          >
            {note.situation}
          </span>

          {note.controlType && (
            <span className="inline-flex items-center rounded-md bg-slate-900 px-2 py-0.5 text-[11px] font-medium text-white">
              {note.controlType === "classic" ? "クラシック" : "モダン"}
            </span>
          )}

          <span className="inline-flex items-center gap-1 rounded-md border border-slate-200 bg-slate-50 px-1.5 py-0.5 text-[11px] font-medium text-slate-500">
            <Lock className="h-3 w-3" aria-hidden="true" />
            非公開メモ
          </span>
        </div>

        <div className="flex shrink-0 items-center gap-1">
          {confirmingDelete ? (
            <div className="flex items-center gap-1">
              <button
                type="button"
                onClick={() => onDelete(note.id)}
                className="rounded-md bg-rose-600 px-2 py-1 text-[11px] font-semibold text-white hover:bg-rose-700"
              >
                削除
              </button>
              <button
                type="button"
                onClick={() => setConfirmingDelete(false)}
                className="rounded-md border border-slate-200 bg-white px-2 py-1 text-[11px] font-medium text-slate-600 hover:bg-slate-50"
              >
                中止
              </button>
            </div>
          ) : (
            <>
              <button
                type="button"
                onClick={() => onEdit(note)}
                aria-label="非公開メモを編集"
                title="編集"
                className="rounded-lg p-1.5 text-slate-400 transition-colors hover:bg-slate-100 hover:text-slate-700"
              >
                <Pencil className="h-4 w-4" />
              </button>
              <button
                type="button"
                onClick={() => setConfirmingDelete(true)}
                aria-label="非公開メモを削除"
                title="削除"
                className="rounded-lg p-1.5 text-slate-400 transition-colors hover:bg-rose-50 hover:text-rose-600"
              >
                <Trash2 className="h-4 w-4" />
              </button>
            </>
          )}
        </div>
      </div>

      {/* レシピ表示エリア：技ボタン組立てなら3表記切替対応チップ、自由入力ならテキスト */}
      <div className="mb-3 rounded-lg border border-slate-100 bg-slate-50/80 p-2.5 sm:p-3">
        {hasBuilderRecipe ? (
          <div className="flex flex-wrap items-center gap-x-1 gap-y-1.5">
            {resolvedMoves.map((move, index) => (
              <div
                key={`${move.id}-${index}`}
                className="inline-flex max-w-full items-center gap-1"
              >
                <span
                  className={`inline-flex max-w-full items-center break-words rounded-md border px-2 py-0.5 text-xs leading-snug sm:text-sm ${getMoveChipStyle(
                    move
                  )}`}
                >
                  <MoveNotation move={move} notationMode={notationMode} />
                </span>
                {index < resolvedMoves.length - 1 && (
                  <ChevronRight
                    className="h-3.5 w-3.5 shrink-0 text-slate-400"
                    aria-hidden="true"
                  />
                )}
              </div>
            ))}
          </div>
        ) : (
          <p className="break-words whitespace-pre-wrap font-mono text-xs font-semibold leading-relaxed text-slate-900 sm:text-sm">
            {note.recipeText}
          </p>
        )}
      </div>

      {/* 補足メモ全文 */}
      <p className="break-words whitespace-pre-wrap text-xs leading-relaxed text-slate-700 sm:text-sm">
        {note.note}
      </p>

      <div className="mt-2.5 border-t border-slate-100 pt-2 text-right text-[11px] text-slate-400">
        更新: {formatUpdatedAt(note.updatedAt)}
      </div>
    </article>
  );
}
