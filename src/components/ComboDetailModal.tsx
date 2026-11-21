"use client";

import { useEffect, useState } from "react";
import {
  ChevronRight,
  Flame,
  Heart,
  ShieldCheck,
  Star,
  Trash2,
  User,
  X,
} from "lucide-react";
import type {
  CharacterStockMeta,
  Combo,
  GameVersion,
  Move,
  NotationMode,
  SituationDefinition,
} from "@/types/combo";
import { COMBO_CATEGORIES } from "@/data/seed/common";
import { MoveNotation } from "@/components/CommandNotation";

interface ComboDetailModalProps {
  combo: Combo | null;
  moveMap: Record<string, Move>;
  situationMap: Record<string, SituationDefinition>;
  version?: GameVersion;
  stockMeta?: CharacterStockMeta;
  notationMode: NotationMode;
  isSaved: boolean;
  isLiked: boolean;
  likesCount: number;
  canDelete?: boolean;
  isDeleting?: boolean;
  onToggleSave: (comboId: string) => void;
  onToggleLike: (combo: Combo) => void;
  onDelete?: (combo: Combo) => Promise<void> | void;
  onChangeNotationMode: (mode: NotationMode) => void;
  onClose: () => void;
}

const NOTATION_MODES: { mode: NotationMode; label: string }[] = [
  { mode: "numpad", label: "テンキー" },
  { mode: "command", label: "コマンド" },
  { mode: "name", label: "技名" },
];

function getMoveChipStyle(move: Move): string {
  switch (move.category) {
    case "system":
      return "border-slate-200 bg-slate-100 text-slate-700";
    case "super":
      return "border-indigo-200 bg-indigo-50 text-indigo-800 font-semibold";
    case "special":
      return "border-blue-200 bg-blue-50/70 text-slate-900 font-medium";
    default:
      return "border-slate-200 bg-white text-slate-900 font-medium";
  }
}

export function ComboDetailModal({
  combo,
  moveMap,
  situationMap,
  version,
  stockMeta,
  notationMode,
  isSaved,
  isLiked,
  likesCount,
  canDelete = false,
  isDeleting = false,
  onToggleSave,
  onToggleLike,
  onDelete,
  onChangeNotationMode,
  onClose,
}: ComboDetailModalProps) {
  const [confirmingComboId, setConfirmingComboId] = useState<string | null>(
    null
  );

  useEffect(() => {
    if (!combo) return;
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [combo, onClose]);

  if (!combo) return null;

  const isConfirmingDelete = confirmingComboId === combo.id;

  const moves = combo.moveIds
    .map((id) => moveMap[id])
    .filter((m): m is Move => Boolean(m));

  const categoryLabel =
    COMBO_CATEGORIES.find((c) => c.key === combo.category)?.label ??
    combo.category;

  return (
    <div
      className="fixed inset-0 z-50 flex items-end justify-center bg-slate-900/50 p-0 backdrop-blur-[1px] sm:items-center sm:p-4"
      onClick={onClose}
      role="dialog"
      aria-modal="true"
      aria-label="コンボ詳細"
    >
      <div
        className="max-h-[90vh] w-full overflow-y-auto rounded-t-2xl bg-white shadow-xl sm:max-w-2xl sm:rounded-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        {/* モーダルヘッダー */}
        <div className="sticky top-0 z-10 flex items-start justify-between gap-3 border-b border-slate-200 bg-white px-4 py-3.5 sm:px-6">
          <div className="flex flex-wrap items-center gap-1.5">
            {combo.situations.map((sitKey) => {
              const def = situationMap[sitKey];
              return (
                <span
                  key={sitKey}
                  className={`inline-flex items-center rounded-md px-2.5 py-0.5 text-xs font-bold ${
                    def?.badgeClassName ?? "bg-slate-100 text-slate-700"
                  }`}
                >
                  {def?.label ?? sitKey}
                </span>
              );
            })}
            <span className="inline-flex items-center rounded-md border border-slate-200 bg-slate-50 px-2 py-0.5 text-xs font-medium text-slate-600">
              {categoryLabel}
            </span>
            <span className="inline-flex items-center rounded-md bg-slate-900 px-2 py-0.5 text-xs font-medium text-white">
              {combo.controlType === "classic" ? "クラシック" : "モダン"}
            </span>
          </div>

          <div className="flex shrink-0 items-center gap-1.5">
            <button
              type="button"
              onClick={() => onToggleSave(combo.id)}
              aria-pressed={isSaved}
              className={`inline-flex items-center gap-1 rounded-lg border px-2.5 py-1.5 text-xs font-semibold transition-colors ${
                isSaved
                  ? "border-amber-200 bg-amber-50 text-amber-700 hover:bg-amber-100"
                  : "border-slate-200 bg-white text-slate-600 hover:bg-amber-50 hover:text-amber-600"
              }`}
            >
              <Star
                className={`h-3.5 w-3.5 ${
                  isSaved ? "fill-amber-400 text-amber-500" : ""
                }`}
                aria-hidden="true"
              />
              <span>{isSaved ? "保存済み" : "保存"}</span>
            </button>

            <button
              type="button"
              onClick={onClose}
              aria-label="モーダルを閉じる"
              className="rounded-lg p-1.5 text-slate-400 transition-colors hover:bg-slate-100 hover:text-slate-700"
            >
              <X className="h-5 w-5" />
            </button>
          </div>
        </div>

        {/* 本文 */}
        <div className="space-y-5 p-4 sm:p-6">
          {/* コンボレシピ（選択中の表記＋モーダル内切替） */}
          <section className="space-y-2.5">
            <div className="flex flex-wrap items-center justify-between gap-2">
              <h2 className="text-xs font-bold tracking-wider text-slate-500 uppercase">
                コンボレシピ
              </h2>
              <div
                role="tablist"
                aria-label="詳細画面の表記切替"
                className="inline-grid grid-cols-3 rounded-lg bg-slate-200/75 p-0.5"
              >
                {NOTATION_MODES.map(({ mode, label }) => (
                  <button
                    key={mode}
                    type="button"
                    role="tab"
                    aria-selected={notationMode === mode}
                    onClick={() => onChangeNotationMode(mode)}
                    className={`rounded-md px-2.5 py-1 text-xs font-semibold transition-all ${
                      notationMode === mode
                        ? "bg-blue-600 text-white shadow-xs"
                        : "text-slate-600 hover:text-slate-900"
                    }`}
                  >
                    {label}
                  </button>
                ))}
              </div>
            </div>

            <div className="rounded-xl border border-slate-200 bg-slate-50/70 p-3 sm:p-3.5">
              <div className="flex flex-wrap items-center gap-x-1 gap-y-1.5">
                {moves.map((move, index) => (
                  <div
                    key={`${notationMode}-${move.id}-${index}`}
                    className="inline-flex max-w-full items-center gap-1"
                  >
                    <span
                      className={`inline-flex max-w-full items-center break-words rounded-md border px-2 py-0.5 text-xs leading-snug sm:text-sm ${getMoveChipStyle(
                        move
                      )}`}
                    >
                      <MoveNotation move={move} notationMode={notationMode} />
                    </span>
                    {index < moves.length - 1 && (
                      <ChevronRight
                        className="h-3.5 w-3.5 shrink-0 text-slate-400"
                        aria-hidden="true"
                      />
                    )}
                  </div>
                ))}
              </div>
            </div>
          </section>

          {/* メタ情報グリッド */}
          <section className="grid grid-cols-2 gap-2.5 sm:grid-cols-4">
            <div className="rounded-lg border border-slate-200 bg-white p-2.5">
              <div className="text-[11px] text-slate-500">ダメージ</div>
              <div className="mt-0.5 flex items-center gap-1 text-base font-bold text-slate-900">
                <Flame
                  className="h-4 w-4 text-orange-500"
                  aria-hidden="true"
                />
                {combo.damage !== null ? combo.damage.toLocaleString() : "---"}
              </div>
            </div>

            <div className="rounded-lg border border-slate-200 bg-white p-2.5">
              <div className="text-[11px] text-slate-500">消費Dゲージ</div>
              <div className="mt-0.5 text-base font-bold text-slate-900">
                {combo.driveCost} 本
              </div>
            </div>

            <div className="rounded-lg border border-slate-200 bg-white p-2.5">
              <div className="text-[11px] text-slate-500">消費SAゲージ</div>
              <div className="mt-0.5 text-base font-bold text-slate-900">
                SA {combo.saCost}
              </div>
            </div>

            <div className="rounded-lg border border-slate-200 bg-white p-2.5">
              <div className="text-[11px] text-slate-500">起き攻め</div>
              <div className="mt-0.5 flex items-center gap-1 text-sm font-bold text-slate-900">
                {combo.hasOki ? (
                  <span className="inline-flex items-center gap-1 text-emerald-700">
                    <ShieldCheck className="h-4 w-4" aria-hidden="true" />
                    あり
                  </span>
                ) : (
                  <span className="text-slate-500">なし</span>
                )}
              </div>
            </div>
          </section>

          {/* キャラ固有ストック増減（該当する場合のみ表示） */}
          {((combo.stockCost ?? 0) > 0 || (combo.stockGain ?? 0) > 0) && (
            <section className="flex flex-wrap items-center gap-2 rounded-lg border border-slate-200 bg-slate-50/70 px-3 py-2.5 text-xs">
              <span className="font-semibold text-slate-600">
                {stockMeta?.label ?? "固有ストック"}:
              </span>
              {(combo.stockCost ?? 0) > 0 && (
                <span className="inline-flex items-center gap-1 rounded-md border border-pink-200 bg-pink-50 px-2 py-0.5 font-semibold text-pink-700">
                  消費 -{combo.stockCost}
                </span>
              )}
              {(combo.stockGain ?? 0) > 0 && (
                <span className="inline-flex items-center gap-1 rounded-md border border-cyan-200 bg-cyan-50 px-2 py-0.5 font-semibold text-cyan-700">
                  獲得 +{combo.stockGain}
                </span>
              )}
            </section>
          )}

          {/* 補足メモ全文 */}
          <section className="space-y-1.5">
            <h2 className="text-xs font-bold tracking-wider text-slate-500 uppercase">
              補足メモ・コツ
            </h2>
            <div className="rounded-xl border border-slate-200 bg-slate-50 p-3.5 text-sm leading-relaxed whitespace-pre-wrap text-slate-800">
              {combo.note}
            </div>
          </section>

          {/* フッターメタ情報 */}
          <div className="flex flex-wrap items-center justify-between gap-2 border-t border-slate-100 pt-3 text-xs text-slate-500">
            <div className="flex flex-wrap items-center gap-3">
              {version && (
                <span>
                  バージョン:{" "}
                  <strong className="font-semibold text-slate-700">
                    {version.label}
                  </strong>
                </span>
              )}
              <span className="inline-flex items-center gap-1">
                <User className="h-3.5 w-3.5" aria-hidden="true" />
                {combo.authorName ?? "投稿者"}
              </span>
            </div>

            <div className="flex flex-wrap items-center gap-2">
              {canDelete && onDelete && (
                <>
                  {isConfirmingDelete ? (
                    <div className="flex items-center gap-1.5 rounded-lg border border-rose-200 bg-rose-50 px-2 py-1">
                      <span className="text-[11px] font-semibold text-rose-700">
                        削除しますか？
                      </span>
                      <button
                        type="button"
                        disabled={isDeleting}
                        onClick={() => onDelete(combo)}
                        className="rounded bg-rose-600 px-2 py-0.5 text-[11px] font-semibold text-white hover:bg-rose-700 disabled:opacity-50"
                      >
                        {isDeleting ? "削除中..." : "削除する"}
                      </button>
                      <button
                        type="button"
                        disabled={isDeleting}
                        onClick={() => setConfirmingComboId(null)}
                        className="rounded border border-slate-200 bg-white px-2 py-0.5 text-[11px] font-medium text-slate-600 hover:bg-slate-50"
                      >
                        中止
                      </button>
                    </div>
                  ) : (
                    <button
                      type="button"
                      onClick={() => setConfirmingComboId(combo.id)}
                      className="inline-flex items-center gap-1 rounded-lg border border-rose-200 bg-white px-2.5 py-1 text-xs font-semibold text-rose-600 transition-colors hover:bg-rose-50"
                    >
                      <Trash2 className="h-3.5 w-3.5" aria-hidden="true" />
                      <span>削除</span>
                    </button>
                  )}
                </>
              )}

              <button
                type="button"
                onClick={() => onToggleLike(combo)}
                aria-pressed={isLiked}
                className={`inline-flex items-center gap-1.5 rounded-lg border px-2.5 py-1 text-xs font-semibold transition-colors ${
                  isLiked
                    ? "border-rose-200 bg-rose-50 text-rose-600 hover:bg-rose-100"
                    : "border-slate-200 bg-white text-slate-600 hover:bg-rose-50 hover:text-rose-600"
                }`}
              >
                <Heart
                  className={`h-3.5 w-3.5 ${
                    isLiked ? "fill-rose-500 text-rose-500" : ""
                  }`}
                  aria-hidden="true"
                />
                <span>{likesCount} いいね</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
