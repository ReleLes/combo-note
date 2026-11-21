"use client";

import { useState } from "react";
import { Lock, Pencil, Trash2 } from "lucide-react";
import type { PrivateNote, SituationDefinition } from "@/types/combo";

interface PrivateNoteCardProps {
  note: PrivateNote;
  situations: SituationDefinition[];
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
  onEdit,
  onDelete,
}: PrivateNoteCardProps) {
  const [confirmingDelete, setConfirmingDelete] = useState(false);

  const badgeStyle = resolveSituationStyle(note.situation, situations);

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

      {/* レシピ表示エリア */}
      <div className="mb-3 rounded-lg border border-slate-100 bg-slate-50/80 p-2.5 sm:p-3">
        <p className="break-words whitespace-pre-wrap font-mono text-xs font-semibold leading-relaxed text-slate-900 sm:text-sm">
          {note.recipeText}
        </p>
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
