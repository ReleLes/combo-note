"use client";

import { ChevronRight, Flame, Heart, ShieldCheck, Star } from "lucide-react";
import type {
  CharacterStockMeta,
  Combo,
  GameVersion,
  Move,
  NotationMode,
  SituationDefinition,
} from "@/types/combo";
import { COMBO_CATEGORIES } from "@/data/seed/common";

interface ComboCardProps {
  combo: Combo;
  moveMap: Record<string, Move>;
  situationMap: Record<string, SituationDefinition>;
  version?: GameVersion;
  stockMeta?: CharacterStockMeta;
  notationMode: NotationMode;
  isSaved: boolean;
  onToggleSave: (comboId: string) => void;
  onSelect: (combo: Combo) => void;
  onPlaceholderAction: (featureName: string) => void;
}

function getMoveLabel(move: Move, notationMode: NotationMode): string {
  switch (notationMode) {
    case "numpad":
      return move.notationNumpad;
    case "command":
      return move.notationCommand;
    case "name":
      return move.notationName;
  }
}

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

function getCategoryLabel(categoryKey: Combo["category"]): string {
  return (
    COMBO_CATEGORIES.find((c) => c.key === categoryKey)?.label ?? categoryKey
  );
}

export function ComboCard({
  combo,
  moveMap,
  situationMap,
  version,
  stockMeta,
  notationMode,
  isSaved,
  onToggleSave,
  onSelect,
  onPlaceholderAction,
}: ComboCardProps) {
  const moves = combo.moveIds
    .map((id) => moveMap[id])
    .filter((m): m is Move => Boolean(m));

  const driveBlocks = Math.min(6, Math.max(0, Math.round(combo.driveCost)));
  const stockShortLabel = stockMeta?.shortLabel ?? "ストック";
  const stockCost = combo.stockCost ?? 0;
  const stockGain = combo.stockGain ?? 0;

  return (
    <article
      onClick={() => onSelect(combo)}
      onKeyDown={(e) => {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          onSelect(combo);
        }
      }}
      role="button"
      tabIndex={0}
      className="group cursor-pointer rounded-xl border border-slate-200 bg-white p-3.5 shadow-xs transition-all hover:border-blue-300 hover:shadow-md focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600 sm:p-4"
    >
      {/* ヘッダー行：最重要の状況バッジ + カテゴリ + マイノート保存ボタン */}
      <div className="mb-3 flex items-start justify-between gap-2">
        <div className="flex flex-wrap items-center gap-1.5">
          {combo.situations.map((sitKey) => {
            const def = situationMap[sitKey];
            const label = def?.label ?? sitKey;
            const badgeStyle =
              def?.badgeClassName ?? "bg-slate-100 text-slate-700";
            return (
              <span
                key={sitKey}
                className={`inline-flex items-center rounded-md px-2 py-0.5 text-xs font-bold tracking-tight ${badgeStyle}`}
              >
                {label}
              </span>
            );
          })}
          <span className="inline-flex items-center rounded-md border border-slate-200 bg-slate-50 px-2 py-0.5 text-[11px] font-medium text-slate-600">
            {getCategoryLabel(combo.category)}
          </span>
        </div>

        <button
          type="button"
          onClick={(e) => {
            e.stopPropagation();
            onToggleSave(combo.id);
          }}
          aria-pressed={isSaved}
          aria-label={isSaved ? "マイノートから解除" : "マイノートに保存"}
          title={isSaved ? "マイノートから解除" : "マイノートに保存"}
          className={`shrink-0 rounded-lg p-1.5 transition-colors ${
            isSaved
              ? "bg-amber-50 text-amber-500 hover:bg-amber-100"
              : "text-slate-400 hover:bg-amber-50 hover:text-amber-500"
          }`}
        >
          <Star className={`h-4 w-4 ${isSaved ? "fill-amber-400" : ""}`} />
        </button>
      </div>

      {/* レシピ表示エリア：長尺コンボでも390px幅で崩れず折り返される */}
      <div className="mb-3 rounded-lg border border-slate-100 bg-slate-50/70 p-2.5 sm:p-3">
        <div className="flex flex-wrap items-center gap-x-1 gap-y-1.5">
          {moves.map((move, index) => (
            <div
              key={`${move.id}-${index}`}
              className="inline-flex max-w-full items-center gap-1"
            >
              <span
                className={`inline-block max-w-full break-words rounded-md border px-2 py-0.5 text-xs leading-snug sm:text-sm ${getMoveChipStyle(
                  move
                )}`}
              >
                {getMoveLabel(move, notationMode)}
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

      {/* メタ情報バー */}
      <div className="mb-2.5 flex flex-wrap items-center justify-between gap-x-3 gap-y-2 border-b border-slate-100 pb-2.5 text-xs text-slate-600">
        <div className="flex flex-wrap items-center gap-x-3 gap-y-1.5">
          {/* ダメージ */}
          <span className="inline-flex items-center gap-1 font-semibold text-slate-900">
            <Flame className="h-3.5 w-3.5 text-orange-500" aria-hidden="true" />
            {combo.damage !== null ? combo.damage.toLocaleString() : "---"}
          </span>

          {/* 消費Dゲージ */}
          <span
            className="inline-flex items-center gap-1.5"
            title={`消費Dゲージ: ${combo.driveCost}`}
          >
            <span className="text-[11px] font-medium text-slate-500">D</span>
            <span className="inline-flex items-center gap-0.5" aria-hidden="true">
              {Array.from({ length: 6 }).map((_, i) => (
                <span
                  key={i}
                  className={`h-2.5 w-1.5 rounded-[2px] ${
                    i < driveBlocks ? "bg-emerald-500" : "bg-slate-200"
                  }`}
                />
              ))}
            </span>
            <span className="font-mono text-[11px] font-semibold text-slate-700">
              {combo.driveCost}
            </span>
          </span>

          {/* 消費SAゲージ */}
          <span className="inline-flex items-center gap-1 rounded bg-slate-100 px-1.5 py-0.5 font-mono text-[11px] font-semibold text-slate-700">
            SA {combo.saCost}
          </span>

          {/* キャラ固有ストック消費 */}
          {stockCost > 0 && (
            <span
              className="inline-flex items-center gap-0.5 rounded border border-pink-200 bg-pink-50 px-1.5 py-0.5 text-[11px] font-semibold text-pink-700"
              title={`${stockMeta?.label ?? "ストック"}を${stockCost}消費`}
            >
              <span>{stockShortLabel}</span>
              <span className="font-mono">-{stockCost}</span>
            </span>
          )}

          {/* キャラ固有ストック獲得 */}
          {stockGain > 0 && (
            <span
              className="inline-flex items-center gap-0.5 rounded border border-cyan-200 bg-cyan-50 px-1.5 py-0.5 text-[11px] font-semibold text-cyan-700"
              title={`${stockMeta?.label ?? "ストック"}を${stockGain}獲得`}
            >
              <span>{stockShortLabel}</span>
              <span className="font-mono">+{stockGain}</span>
            </span>
          )}

          {/* 起き攻め */}
          {combo.hasOki && (
            <span className="inline-flex items-center gap-1 rounded bg-emerald-50 px-1.5 py-0.5 text-[11px] font-semibold text-emerald-700">
              <ShieldCheck className="h-3 w-3" aria-hidden="true" />
              起き攻めあり
            </span>
          )}
        </div>

        <div className="flex items-center gap-2.5 text-[11px] text-slate-500">
          {version && (
            <span className="rounded bg-slate-100 px-1.5 py-0.5 font-medium text-slate-600">
              {version.label}
            </span>
          )}
          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              onPlaceholderAction("いいね");
            }}
            className="inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 text-slate-500 transition-colors hover:bg-rose-50 hover:text-rose-600"
            aria-label={`いいね ${combo.likesCount}件（準備中）`}
          >
            <Heart className="h-3.5 w-3.5" aria-hidden="true" />
            <span className="font-medium">{combo.likesCount}</span>
          </button>
        </div>
      </div>

      {/* 補足メモプレビュー（1〜2行） */}
      <p className="line-clamp-2 text-xs leading-relaxed text-slate-600 sm:text-sm">
        {combo.note}
      </p>
    </article>
  );
}
