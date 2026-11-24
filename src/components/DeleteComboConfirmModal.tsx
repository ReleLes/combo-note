"use client";

import { useEffect } from "react";
import { AlertTriangle, ShieldAlert, Trash2, X } from "lucide-react";
import type { Combo } from "@/types/combo";

interface DeleteComboConfirmModalProps {
  combo: Combo | null;
  /** 投稿者本人以外に対して管理者が削除操作を行っている場合 true */
  isAdminAction?: boolean;
  isDeleting?: boolean;
  errorMessage?: string | null;
  onConfirm: (combo: Combo) => Promise<void> | void;
  onClose: () => void;
}

export function DeleteComboConfirmModal({
  combo,
  isAdminAction = false,
  isDeleting = false,
  errorMessage = null,
  onConfirm,
  onClose,
}: DeleteComboConfirmModalProps) {
  useEffect(() => {
    if (!combo) return;
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape" && !isDeleting) {
        onClose();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [combo, isDeleting, onClose]);

  if (!combo) return null;

  const displayAuthorName = combo.authorName?.trim() || "未設定（匿名）";

  return (
    <div
      className="fixed inset-0 z-[60] flex items-center justify-center bg-slate-900/60 p-4 backdrop-blur-[1px] dark:bg-black/80"
      onClick={() => {
        if (!isDeleting) onClose();
      }}
      role="dialog"
      aria-modal="true"
      aria-labelledby="delete-combo-modal-title"
    >
      <div
        className="w-full max-w-md rounded-2xl border border-slate-200 bg-white p-5 shadow-xl dark:border-[#2E2447] dark:bg-[#1B152B]"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between gap-3">
          <div className="flex items-center gap-2.5">
            <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-rose-50 text-rose-600 dark:bg-rose-500/20 dark:text-rose-300">
              <AlertTriangle className="h-5 w-5" aria-hidden="true" />
            </span>
            <h2
              id="delete-combo-modal-title"
              className="text-base font-bold text-slate-900 dark:text-[#F4F1FF]"
            >
              公開コンボを削除
            </h2>
          </div>

          <button
            type="button"
            disabled={isDeleting}
            onClick={onClose}
            aria-label="確認モーダルを閉じる"
            className="rounded-lg p-1 text-slate-400 transition-colors hover:bg-slate-100 hover:text-slate-700 disabled:opacity-50 dark:text-[#A99EC4] dark:hover:bg-[#251D3A] dark:hover:text-[#F4F1FF]"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <p className="mt-3 text-sm leading-relaxed text-slate-700 dark:text-[#E2DCF5]">
          この公開コンボを削除しますか？（元に戻せません）
        </p>

        {isAdminAction && (
          <div className="mt-3 flex items-start gap-2 rounded-xl border border-amber-200 bg-amber-50 px-3 py-2.5 text-xs text-amber-900 dark:border-amber-400/35 dark:bg-amber-500/15 dark:text-amber-200">
            <ShieldAlert
              className="mt-0.5 h-4 w-4 shrink-0 text-amber-600 dark:text-amber-300"
              aria-hidden="true"
            />
            <div className="space-y-0.5">
              <p className="font-bold">管理者権限で削除します</p>
              <p className="text-[11px] leading-relaxed text-amber-800/90 dark:text-amber-200/85">
                投稿者（{displayAuthorName}
                ）の公開コンボを削除しようとしています。対象に誤りがないかご確認ください。
              </p>
            </div>
          </div>
        )}

        {/* 削除対象コンボの簡易プレビュー */}
        <div className="mt-3 rounded-xl border border-slate-200 bg-slate-50 p-3 text-xs dark:border-[#2E2447] dark:bg-[#140F23]">
          {combo.title?.trim() && (
            <p className="mb-1 font-bold text-slate-900 dark:text-[#F4F1FF]">
              {combo.title.trim()}
            </p>
          )}
          <p className="line-clamp-2 leading-relaxed text-slate-600 dark:text-[#CFC6E8]">
            {combo.note}
          </p>
          <div className="mt-1.5 flex flex-wrap items-center gap-2 text-[11px] text-slate-500 dark:text-[#A99EC4]">
            <span>
              {combo.controlType === "classic" ? "クラシック" : "モダン"}
            </span>
            <span>/</span>
            <span>
              ダメージ:{" "}
              {combo.damage !== null ? combo.damage.toLocaleString() : "---"}
            </span>
            <span>/</span>
            <span>投稿者: {displayAuthorName}</span>
          </div>
        </div>

        {errorMessage && (
          <p
            role="alert"
            className="mt-3 rounded-lg border border-rose-200 bg-rose-50 px-3 py-2 text-xs font-medium text-rose-700 dark:border-rose-400/35 dark:bg-rose-500/20 dark:text-rose-200"
          >
            {errorMessage}
          </p>
        )}

        <div className="mt-5 flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
          <button
            type="button"
            disabled={isDeleting}
            onClick={onClose}
            className="inline-flex items-center justify-center rounded-lg border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-700 transition-colors hover:bg-slate-50 disabled:opacity-50 sm:text-sm dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#E2DCF5] dark:hover:bg-[#30264A]"
          >
            キャンセル
          </button>
          <button
            type="button"
            disabled={isDeleting}
            onClick={() => onConfirm(combo)}
            className="inline-flex items-center justify-center gap-1.5 rounded-lg bg-rose-600 px-4 py-2 text-xs font-semibold text-white shadow-xs transition-colors hover:bg-rose-700 disabled:cursor-not-allowed disabled:opacity-60 sm:text-sm dark:bg-rose-600 dark:hover:bg-rose-500"
          >
            <Trash2 className="h-3.5 w-3.5" aria-hidden="true" />
            <span>
              {isDeleting
                ? "削除中..."
                : isAdminAction
                  ? "管理者権限で削除する"
                  : "削除する"}
            </span>
          </button>
        </div>
      </div>
    </div>
  );
}
