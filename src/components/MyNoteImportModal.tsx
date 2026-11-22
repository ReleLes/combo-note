"use client";

import { useEffect, useState } from "react";
import {
  AlertTriangle,
  FileJson,
  GitMerge,
  RefreshCw,
  Upload,
  X,
} from "lucide-react";
import type {
  MyNoteImportMode,
  ParsedMyNoteBackup,
} from "@/lib/myNoteBackup";

interface MyNoteImportModalProps {
  pendingImport: {
    fileName: string;
    backup: ParsedMyNoteBackup;
  } | null;
  currentSavedCount: number;
  currentNotesCount: number;
  onConfirm: (mode: MyNoteImportMode) => void;
  onClose: () => void;
}

function formatExportedAt(iso: string | null): string {
  if (!iso) return "不明";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "不明";
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  const hh = String(d.getHours()).padStart(2, "0");
  const mm = String(d.getMinutes()).padStart(2, "0");
  return `${y}/${m}/${day} ${hh}:${mm}`;
}

export function MyNoteImportModal({
  pendingImport,
  currentSavedCount,
  currentNotesCount,
  onConfirm,
  onClose,
}: MyNoteImportModalProps) {
  const [mode, setMode] = useState<MyNoteImportMode>("merge");

  useEffect(() => {
    if (!pendingImport) return;
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [pendingImport, onClose]);

  if (!pendingImport) return null;

  const { fileName, backup } = pendingImport;

  return (
    <div
      className="fixed inset-0 z-50 flex items-end justify-center bg-slate-900/55 p-0 backdrop-blur-[1px] sm:items-center sm:p-4 dark:bg-black/75"
      onClick={onClose}
      role="dialog"
      aria-modal="true"
      aria-label="マイノートデータのインポート確認"
    >
      <div
        className="max-h-[92vh] w-full overflow-y-auto rounded-t-2xl bg-white shadow-xl sm:max-w-lg sm:rounded-2xl dark:border dark:border-[#2E2447] dark:bg-[#1B152B]"
        onClick={(e) => e.stopPropagation()}
      >
        {/* ヘッダー */}
        <div className="sticky top-0 z-10 flex items-center justify-between border-b border-slate-200 bg-white px-4 py-3.5 sm:px-5 dark:border-[#2D2346] dark:bg-[#1B152B]">
          <div className="flex items-center gap-2">
            <FileJson
              className="h-4 w-4 text-blue-600 dark:text-[#A78BFA]"
              aria-hidden="true"
            />
            <h2 className="text-sm font-bold text-slate-900 sm:text-base dark:text-[#F4F1FF]">
              バックアップのインポート確認
            </h2>
          </div>
          <button
            type="button"
            onClick={onClose}
            aria-label="モーダルを閉じる"
            className="rounded-lg p-1.5 text-slate-400 transition-colors hover:bg-slate-100 hover:text-slate-700 dark:text-[#A99EC4] dark:hover:bg-[#251D3A] dark:hover:text-[#F4F1FF]"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* 本文 */}
        <div className="space-y-4 p-4 sm:p-5">
          {/* ファイル情報 & 件数プレビュー */}
          <div className="rounded-xl border border-slate-200 bg-slate-50/80 p-3.5 dark:border-[#2A2142] dark:bg-[#140F23]">
            <p className="truncate text-xs font-bold text-slate-800 dark:text-[#F4F1FF]">
              {fileName}
            </p>
            <p className="mt-0.5 text-[11px] text-slate-500 dark:text-[#A99EC4]">
              エクスポート日時: {formatExportedAt(backup.exportedAt)}
            </p>

            <div className="mt-3 grid grid-cols-2 gap-2">
              <div className="rounded-lg border border-slate-200 bg-white px-3 py-2 dark:border-[#2E2447] dark:bg-[#1B152B]">
                <div className="text-[11px] text-slate-500 dark:text-[#A99EC4]">
                  保存コンボ
                </div>
                <div className="mt-0.5 flex items-baseline gap-1.5">
                  <span className="font-mono text-base font-bold text-slate-900 dark:text-[#F4F1FF]">
                    {backup.savedCombos.length}
                  </span>
                  <span className="text-[11px] text-slate-500 dark:text-[#A99EC4]">
                    件（現在 {currentSavedCount}件）
                  </span>
                </div>
              </div>

              <div className="rounded-lg border border-slate-200 bg-white px-3 py-2 dark:border-[#2E2447] dark:bg-[#1B152B]">
                <div className="text-[11px] text-slate-500 dark:text-[#A99EC4]">
                  非公開メモ
                </div>
                <div className="mt-0.5 flex items-baseline gap-1.5">
                  <span className="font-mono text-base font-bold text-slate-900 dark:text-[#F4F1FF]">
                    {backup.privateNotes.length}
                  </span>
                  <span className="text-[11px] text-slate-500 dark:text-[#A99EC4]">
                    件（現在 {currentNotesCount}件）
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* 取り込み方法選択 */}
          <div className="space-y-2">
            <span className="block text-xs font-bold text-slate-700 dark:text-[#E2DCF5]">
              取り込み方法を選択してください
            </span>

            <button
              type="button"
              onClick={() => setMode("merge")}
              aria-pressed={mode === "merge"}
              className={`flex w-full items-start gap-3 rounded-xl border p-3 text-left transition-all ${
                mode === "merge"
                  ? "border-blue-600 bg-blue-50/70 ring-1 ring-blue-600 dark:border-[#8B5CF6] dark:bg-violet-500/15 dark:ring-[#8B5CF6]"
                  : "border-slate-200 bg-white hover:bg-slate-50 dark:border-[#2E2447] dark:bg-[#251D3A]/60 dark:hover:bg-[#251D3A]"
              }`}
            >
              <span
                className={`mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-lg ${
                  mode === "merge"
                    ? "bg-blue-600 text-white dark:bg-[#7C3AED]"
                    : "bg-slate-100 text-slate-600 dark:bg-[#1B152B] dark:text-[#A99EC4]"
                }`}
              >
                <GitMerge className="h-4 w-4" aria-hidden="true" />
              </span>
              <div className="min-w-0 flex-1">
                <div className="flex flex-wrap items-center gap-1.5">
                  <span className="text-xs font-bold text-slate-900 sm:text-sm dark:text-[#F4F1FF]">
                    既存データにマージ
                  </span>
                  <span className="rounded-full bg-blue-100 px-2 py-0.5 text-[10px] font-bold text-blue-700 dark:bg-violet-500/25 dark:text-[#DDD6FE]">
                    おすすめ
                  </span>
                </div>
                <p className="mt-0.5 text-[11px] leading-relaxed text-slate-600 dark:text-[#A99EC4]">
                  現在のマイノートを残したまま、バックアップのコンボとメモを追加・統合します。
                </p>
              </div>
            </button>

            <button
              type="button"
              onClick={() => setMode("overwrite")}
              aria-pressed={mode === "overwrite"}
              className={`flex w-full items-start gap-3 rounded-xl border p-3 text-left transition-all ${
                mode === "overwrite"
                  ? "border-rose-500 bg-rose-50/70 ring-1 ring-rose-500 dark:border-rose-400 dark:bg-rose-500/15 dark:ring-rose-400"
                  : "border-slate-200 bg-white hover:bg-slate-50 dark:border-[#2E2447] dark:bg-[#251D3A]/60 dark:hover:bg-[#251D3A]"
              }`}
            >
              <span
                className={`mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-lg ${
                  mode === "overwrite"
                    ? "bg-rose-600 text-white dark:bg-rose-500"
                    : "bg-slate-100 text-slate-600 dark:bg-[#1B152B] dark:text-[#A99EC4]"
                }`}
              >
                <RefreshCw className="h-4 w-4" aria-hidden="true" />
              </span>
              <div className="min-w-0 flex-1">
                <span className="text-xs font-bold text-slate-900 sm:text-sm dark:text-[#F4F1FF]">
                  すべて上書き
                </span>
                <p className="mt-0.5 text-[11px] leading-relaxed text-slate-600 dark:text-[#A99EC4]">
                  このブラウザに保存中のデータをすべて削除し、バックアップファイルの内容で完全に置き換えます。
                </p>
              </div>
            </button>
          </div>

          {mode === "overwrite" && (
            <div
              role="alert"
              className="flex items-start gap-2 rounded-lg border border-rose-200 bg-rose-50 px-3 py-2 text-xs leading-relaxed text-rose-800 dark:border-rose-500/35 dark:bg-rose-500/15 dark:text-rose-200"
            >
              <AlertTriangle
                className="mt-0.5 h-4 w-4 shrink-0 text-rose-600 dark:text-rose-300"
                aria-hidden="true"
              />
              <span>
                現在保存されているお気に入りコンボ（{currentSavedCount}
                件）と非公開メモ（{currentNotesCount}
                件）は元に戻せません。必要に応じて先にエクスポートしてください。
              </span>
            </div>
          )}

          {/* アクションボタン */}
          <div className="flex flex-col-reverse gap-2 border-t border-slate-100 pt-3 sm:flex-row sm:justify-end dark:border-[#2D2346]">
            <button
              type="button"
              onClick={onClose}
              className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-600 transition-colors hover:bg-slate-50 sm:text-sm dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:bg-[#30264A]"
            >
              キャンセル
            </button>
            <button
              type="button"
              onClick={() => onConfirm(mode)}
              className={`inline-flex items-center justify-center gap-1.5 rounded-lg px-4 py-2 text-xs font-semibold text-white transition-colors sm:text-sm ${
                mode === "overwrite"
                  ? "bg-rose-600 hover:bg-rose-700 dark:bg-rose-600 dark:hover:bg-rose-500"
                  : "bg-blue-600 hover:bg-blue-700 dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
              }`}
            >
              <Upload className="h-3.5 w-3.5" aria-hidden="true" />
              <span>
                {mode === "overwrite"
                  ? "上書きしてインポート"
                  : "マージしてインポート"}
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
