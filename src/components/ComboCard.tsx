"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import {
  Check,
  ChevronRight,
  Clock,
  Copy,
  Flame,
  Heart,
  Link2,
  Pencil,
  ShieldCheck,
  Star,
  Trash2,
} from "lucide-react";
import type {
  Character,
  CharacterStockMeta,
  Combo,
  GameVersion,
  Move,
  NotationMode,
  SituationDefinition,
} from "@/types/combo";
import { COMBO_CATEGORIES } from "@/data/seed/common";
import { getCharacterTheme } from "@/lib/characterThemes";
import {
  copyTextToClipboard,
  formatComboRecipeText,
  formatFullDateTime,
  formatRelativePostedAt,
} from "@/lib/comboUtils";
import { calculateRecipeStock } from "@/lib/stockCalculator";
import { MoveNotation } from "@/components/CommandNotation";

interface ComboCardProps {
  combo: Combo;
  moveMap: Record<string, Move>;
  situationMap: Record<string, SituationDefinition>;
  version?: GameVersion;
  stockMeta?: CharacterStockMeta;
  notationMode: NotationMode;
  isSaved: boolean;
  isLiked: boolean;
  likesCount: number;
  /** 投稿者本人または管理者に渡される編集リンク */
  editHref?: string;
  /** 投稿者本人または管理者に渡される削除トリガー */
  onDeleteRequest?: (combo: Combo) => void;
  /** 管理者が他ユーザー（またはシード）のコンボを操作しているか */
  isAdminAction?: boolean;
  /** 共有リンク生成用のキャラクターslug */
  characterSlug?: string;
  /** 全キャラ横断一覧（/combos 等）でカード最上部に表示するキャラクター情報 */
  character?: Pick<Character, "id" | "slug" | "nameJa" | "nameEn">;
  /** キャラクターの丸型モチーフアイコンURL（未配置時はテーマカラーイニシャル表示） */
  characterImageUrl?: string | null;
  /** 操作タイプバッジ（C/M）をキャラクターバッジ横に併記するか */
  showControlTypeBadge?: boolean;
  /** 投稿日時（相対日時または日付）をカード最上部に表示するか */
  showPostedAt?: boolean;
  onToggleSave: (comboId: string) => void;
  onToggleLike: (combo: Combo) => void;
  onSelect: (combo: Combo) => void;
}

function getMoveChipStyle(move: Move): string {
  switch (move.category) {
    case "system":
      return "border-slate-200 bg-slate-100 text-slate-700 dark:border-[#3A2F58] dark:bg-[#2E2546] dark:text-[#CFC6E8]";
    case "super":
      return "border-indigo-200 bg-indigo-50 text-indigo-800 font-semibold dark:border-violet-400/40 dark:bg-violet-500/20 dark:text-violet-200";
    case "special":
      return "border-blue-200 bg-blue-50/70 text-slate-900 font-medium dark:border-indigo-400/35 dark:bg-indigo-500/20 dark:text-[#F4F1FF]";
    case "throw":
      return "border-amber-200 bg-amber-50/70 text-amber-900 font-medium dark:border-amber-400/35 dark:bg-amber-500/20 dark:text-amber-200";
    default:
      return "border-slate-200 bg-white text-slate-900 font-medium dark:border-[#34294F] dark:bg-[#251D3A] dark:text-[#F4F1FF]";
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
  isLiked,
  likesCount,
  editHref,
  onDeleteRequest,
  isAdminAction = false,
  characterSlug,
  character,
  characterImageUrl,
  showControlTypeBadge = false,
  showPostedAt = false,
  onToggleSave,
  onToggleLike,
  onSelect,
}: ComboCardProps) {
  const [copiedTarget, setCopiedTarget] = useState<"recipe" | "link" | null>(
    null
  );

  useEffect(() => {
    if (!copiedTarget) return;
    const timer = window.setTimeout(() => setCopiedTarget(null), 1800);
    return () => window.clearTimeout(timer);
  }, [copiedTarget]);

  const moves = combo.moveIds
    .map((id) => moveMap[id])
    .filter((m): m is Move => Boolean(m));

  const handleCopyRecipe = async (e: React.MouseEvent) => {
    e.stopPropagation();
    const text = formatComboRecipeText(moves, notationMode);
    if (!text) return;
    const ok = await copyTextToClipboard(text);
    if (ok) {
      setCopiedTarget("recipe");
    }
  };

  const handleCopyShareLink = async (e: React.MouseEvent) => {
    e.stopPropagation();
    const slug = characterSlug ?? combo.characterId;
    const url = `${window.location.origin}/characters/${slug}?combo=${encodeURIComponent(
      combo.id
    )}`;
    const ok = await copyTextToClipboard(url);
    if (ok) {
      setCopiedTarget("link");
    }
  };

  const autoStock = calculateRecipeStock(combo.characterId, moves);
  const driveBlocks = Math.min(6, Math.max(0, Math.round(combo.driveCost)));
  const stockShortLabel = stockMeta?.shortLabel ?? "ストック";
  const stockCost = combo.stockCost ?? 0;
  const stockGain = combo.stockGain ?? 0;
  const charTheme = character ? getCharacterTheme(character.slug) : null;

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
      className="group cursor-pointer rounded-xl border border-slate-200 bg-white p-3.5 shadow-xs transition-all hover:border-blue-300 hover:shadow-md focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600 sm:p-4 dark:border-[#2E2447] dark:bg-[#1B152B] dark:hover:border-[#8B5CF6] dark:focus-visible:outline-[#8B5CF6]"
    >
      {/* キャラクターバッジ & 投稿日時（全キャラ横断一覧向け） */}
      {(character || showPostedAt) && (
        <div className="mb-2.5 flex items-center justify-between gap-2 border-b border-slate-100 pb-2 dark:border-[#2E2447]">
          {character ? (
            <Link
              href={`/characters/${character.slug}`}
              onClick={(e) => e.stopPropagation()}
              title={`${character.nameJa}のコンボ一覧を見る`}
              className="group/char inline-flex min-w-0 items-center gap-2 rounded-full py-0.5 pr-2 pl-0.5 transition-colors hover:bg-slate-100 dark:hover:bg-[#251D3A]"
            >
              {characterImageUrl ? (
                <span className="relative h-6 w-6 shrink-0 overflow-hidden rounded-full bg-[#1C222D] ring-1 ring-slate-900/10 shadow-2xs dark:ring-white/15">
                  <Image
                    src={characterImageUrl}
                    alt={`${character.nameJa}モチーフアイコン`}
                    fill
                    sizes="24px"
                    className="scale-[1.08] object-cover object-center"
                  />
                </span>
              ) : (
                <span
                  aria-hidden="true"
                  className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full text-[10px] font-extrabold text-white ring-1 ring-black/10 dark:ring-white/15"
                  style={
                    charTheme
                      ? {
                          background: `linear-gradient(135deg, ${charTheme.gradientFrom}, ${charTheme.accent})`,
                        }
                      : undefined
                  }
                >
                  {character.nameJa.slice(0, 1)}
                </span>
              )}
              <span className="truncate text-xs font-bold text-slate-800 group-hover/char:text-blue-700 sm:text-[13px] dark:text-[#F4F1FF] dark:group-hover/char:text-[#C4B5FD]">
                {character.nameJa}
              </span>
              {showControlTypeBadge && (
                <span
                  className={`shrink-0 rounded px-1.5 py-0.5 text-[10px] font-bold leading-none ${
                    combo.controlType === "classic"
                      ? "bg-slate-900 text-white dark:bg-[#7C3AED] dark:text-white"
                      : "bg-sky-100 text-sky-800 dark:bg-sky-500/20 dark:text-sky-200"
                  }`}
                >
                  {combo.controlType === "classic" ? "C" : "M"}
                </span>
              )}
            </Link>
          ) : (
            <span />
          )}

          {showPostedAt && (
            <time
              dateTime={combo.createdAt}
              title={formatFullDateTime(combo.createdAt)}
              suppressHydrationWarning
              className="inline-flex shrink-0 items-center gap-1 text-[11px] font-medium text-slate-500 dark:text-[#A99EC4]"
            >
              <Clock className="h-3 w-3" aria-hidden="true" />
              <span>{formatRelativePostedAt(combo.createdAt)}</span>
            </time>
          )}
        </div>
      )}
      {/* ヘッダー行：最重要の状況バッジ + カテゴリ + 編集・マイノート保存ボタン */}
      <div className="mb-3 flex items-start justify-between gap-2">
        <div className="flex flex-wrap items-center gap-1.5">
          {combo.situations.map((sitKey) => {
            const def = situationMap[sitKey];
            const label = def?.label ?? sitKey;
            const badgeStyle =
              def?.badgeClassName ??
              "bg-slate-100 text-slate-700 dark:bg-[#251D3A] dark:text-[#CFC6E8]";
            return (
              <span
                key={sitKey}
                className={`inline-flex items-center rounded-md px-2 py-0.5 text-xs font-bold tracking-tight ${badgeStyle}`}
              >
                {label}
              </span>
            );
          })}
          <span className="inline-flex items-center rounded-md border border-slate-200 bg-slate-50 px-2 py-0.5 text-[11px] font-medium text-slate-600 dark:border-[#34294F] dark:bg-[#251D3A] dark:text-[#A99EC4]">
            {getCategoryLabel(combo.category)}
          </span>
        </div>

        <div className="flex shrink-0 items-center gap-1">
          {editHref && (
            <Link
              href={editHref}
              onClick={(e) => e.stopPropagation()}
              aria-label={
                isAdminAction
                  ? "管理者権限でこのコンボを編集"
                  : "このコンボを編集"
              }
              title={
                isAdminAction
                  ? "管理者権限でこのコンボを編集"
                  : "このコンボを編集"
              }
              className={`inline-flex items-center gap-1 rounded-lg border px-1.5 py-1 text-[11px] font-semibold transition-colors sm:px-2 ${
                isAdminAction
                  ? "border-amber-200 bg-amber-50/70 text-amber-800 hover:border-amber-300 hover:bg-amber-100/80 dark:border-amber-400/35 dark:bg-amber-500/15 dark:text-amber-200 dark:hover:border-amber-400/60 dark:hover:bg-amber-500/25"
                  : "border-slate-200 bg-white text-slate-600 hover:border-blue-300 hover:bg-blue-50 hover:text-blue-700 dark:border-[#2E2447] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:border-[#8B5CF6] dark:hover:bg-[#30264A] dark:hover:text-[#F4F1FF]"
              }`}
            >
              <Pencil className="h-3 w-3" aria-hidden="true" />
              <span>編集</span>
            </Link>
          )}
          {onDeleteRequest && (
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                onDeleteRequest(combo);
              }}
              aria-label={
                isAdminAction
                  ? "管理者権限でこのコンボを削除"
                  : "このコンボを削除"
              }
              title={
                isAdminAction
                  ? "管理者権限でこのコンボを削除"
                  : "このコンボを削除"
              }
              className={`inline-flex items-center gap-1 rounded-lg border px-1.5 py-1 text-[11px] font-semibold transition-colors sm:px-2 ${
                isAdminAction
                  ? "border-rose-300 bg-rose-50/70 text-rose-700 hover:bg-rose-100/80 dark:border-rose-400/45 dark:bg-rose-500/20 dark:text-rose-200 dark:hover:bg-rose-500/30"
                  : "border-rose-200 bg-white text-rose-600 hover:bg-rose-50 dark:border-rose-400/35 dark:bg-rose-500/15 dark:text-rose-300 dark:hover:bg-rose-500/25"
              }`}
            >
              <Trash2 className="h-3 w-3" aria-hidden="true" />
              <span>削除</span>
            </button>
          )}
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
                ? "bg-amber-50 text-amber-500 hover:bg-amber-100 dark:bg-amber-500/20 dark:text-amber-300 dark:hover:bg-amber-500/30"
                : "text-slate-400 hover:bg-amber-50 hover:text-amber-500 dark:text-[#A99EC4] dark:hover:bg-amber-500/15 dark:hover:text-amber-300"
            }`}
          >
            <Star className={`h-4 w-4 ${isSaved ? "fill-amber-400" : ""}`} />
          </button>
        </div>
      </div>

      {/* コンボタイトル（設定時のみ表示） */}
      {combo.title?.trim() && (
        <h3 className="mb-2 text-sm font-bold leading-snug text-slate-900 sm:text-[15px] dark:text-[#F4F1FF]">
          {combo.title.trim()}
        </h3>
      )}

      {/* レシピ表示エリア：長尺コンボでも390px幅で崩れず折り返される */}
      <div className="mb-3 rounded-lg border border-slate-100 bg-slate-50/70 p-2.5 sm:p-3 dark:border-[#2E2447] dark:bg-[#140F23]">
        <div className="flex flex-wrap items-center gap-x-1 gap-y-1.5">
          {moves.map((move, index) => (
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
              {index < moves.length - 1 && (
                <ChevronRight
                  className="h-3.5 w-3.5 shrink-0 text-slate-400 dark:text-[#7E72A1]"
                  aria-hidden="true"
                />
              )}
            </div>
          ))}
        </div>
      </div>

      {/* メタ情報バー */}
      <div className="mb-2.5 flex flex-wrap items-center justify-between gap-x-3 gap-y-2 border-b border-slate-100 pb-2.5 text-xs text-slate-600 dark:border-[#2E2447] dark:text-[#A99EC4]">
        <div className="flex flex-wrap items-center gap-x-3 gap-y-1.5">
          {/* ダメージ */}
          <span className="inline-flex items-center gap-1 font-semibold text-slate-900 dark:text-[#F4F1FF]">
            <Flame className="h-3.5 w-3.5 text-orange-500 dark:text-orange-400" aria-hidden="true" />
            {combo.damage !== null ? combo.damage.toLocaleString() : "---"}
          </span>

          {/* 消費Dゲージ */}
          <span
            className="inline-flex items-center gap-1.5"
            title={`消費Dゲージ: ${combo.driveCost}`}
          >
            <span className="text-[11px] font-medium text-slate-500 dark:text-[#A99EC4]">D</span>
            <span className="inline-flex items-center gap-0.5" aria-hidden="true">
              {Array.from({ length: 6 }).map((_, i) => (
                <span
                  key={i}
                  className={`h-2.5 w-1.5 rounded-[2px] ${
                    i < driveBlocks
                      ? "bg-emerald-500 dark:bg-emerald-400"
                      : "bg-slate-200 dark:bg-[#2E2447]"
                  }`}
                />
              ))}
            </span>
            <span className="font-mono text-[11px] font-semibold text-slate-700 dark:text-[#E2DCF5]">
              {combo.driveCost}
            </span>
          </span>

          {/* 消費SAゲージ */}
          <span className="inline-flex items-center gap-1 rounded bg-slate-100 px-1.5 py-0.5 font-mono text-[11px] font-semibold text-slate-700 dark:bg-[#251D3A] dark:text-[#DDD6FE]">
            SA {combo.saCost}
          </span>

          {/* キャラ固有ストック増減（レシピ自動計算優先・未対応キャラ等はDB値をフォールバック表示） */}
          {autoStock?.hasActivity ? (
            <span
              className={`inline-flex items-center rounded border px-1.5 py-0.5 text-[11px] font-semibold ${autoStock.badgeClassName}`}
              title={`${autoStock.label}: 必要${autoStock.requiredStart} / 消費${autoStock.consumedTotal} / 獲得+${autoStock.gainedTotal}`}
            >
              {autoStock.summaryLabel}
            </span>
          ) : (
            <>
              {stockCost > 0 && (
                <span
                  className="inline-flex items-center gap-0.5 rounded border border-pink-200 bg-pink-50 px-1.5 py-0.5 text-[11px] font-semibold text-pink-700 dark:border-pink-400/30 dark:bg-pink-500/20 dark:text-pink-200"
                  title={`${stockMeta?.label ?? "ストック"}を${stockCost}消費`}
                >
                  <span>{stockShortLabel}</span>
                  <span className="font-mono">-{stockCost}</span>
                </span>
              )}
              {stockGain > 0 && (
                <span
                  className="inline-flex items-center gap-0.5 rounded border border-cyan-200 bg-cyan-50 px-1.5 py-0.5 text-[11px] font-semibold text-cyan-700 dark:border-cyan-400/30 dark:bg-cyan-500/20 dark:text-cyan-200"
                  title={`${stockMeta?.label ?? "ストック"}を${stockGain}獲得`}
                >
                  <span>{stockShortLabel}</span>
                  <span className="font-mono">+{stockGain}</span>
                </span>
              )}
            </>
          )}

          {/* 起き攻め */}
          {combo.hasOki && (
            <span className="inline-flex items-center gap-1 rounded bg-emerald-50 px-1.5 py-0.5 text-[11px] font-semibold text-emerald-700 dark:border dark:border-emerald-400/30 dark:bg-emerald-500/20 dark:text-emerald-200">
              <ShieldCheck className="h-3 w-3" aria-hidden="true" />
              起き攻めあり
            </span>
          )}
        </div>

        <div className="flex items-center gap-2.5 text-[11px] text-slate-500 dark:text-[#A99EC4]">
          {version && (
            <span className="rounded bg-slate-100 px-1.5 py-0.5 font-medium text-slate-600 dark:bg-[#251D3A] dark:text-[#A99EC4]">
              {version.label}
            </span>
          )}
          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              onToggleLike(combo);
            }}
            aria-pressed={isLiked}
            aria-label={
              isLiked
                ? `いいねを解除（現在 ${likesCount}件）`
                : `いいねする（現在 ${likesCount}件）`
            }
            className={`inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 transition-colors ${
              isLiked
                ? "bg-rose-50 text-rose-600 hover:bg-rose-100 dark:bg-rose-500/20 dark:text-rose-300 dark:hover:bg-rose-500/30"
                : "text-slate-500 hover:bg-rose-50 hover:text-rose-600 dark:text-[#A99EC4] dark:hover:bg-rose-500/15 dark:hover:text-rose-300"
            }`}
          >
            <Heart
              className={`h-3.5 w-3.5 ${isLiked ? "fill-rose-500 text-rose-500 dark:fill-rose-400 dark:text-rose-400" : ""}`}
              aria-hidden="true"
            />
            <span className="font-medium">{likesCount}</span>
          </button>
        </div>
      </div>

      {/* 補足メモプレビュー（1〜2行） */}
      <p className="line-clamp-2 text-xs leading-relaxed text-slate-600 sm:text-sm dark:text-[#CFC6E8]">
        {combo.note}
      </p>

      {/* クイックアクション（レシピコピー・共有リンク） */}
      <div className="mt-2.5 flex items-center justify-end gap-1.5 border-t border-slate-100 pt-2 dark:border-[#2E2447]">
        <button
          type="button"
          onClick={handleCopyRecipe}
          aria-label="レシピをコピー"
          title="表示中の表記モードでレシピをコピー"
          className={`inline-flex items-center gap-1 rounded-md border px-2 py-1 text-[11px] font-semibold transition-colors ${
            copiedTarget === "recipe"
              ? "border-emerald-200 bg-emerald-50 text-emerald-700 dark:border-emerald-400/40 dark:bg-emerald-500/20 dark:text-emerald-200"
              : "border-slate-200 bg-white text-slate-600 hover:border-blue-300 hover:bg-blue-50 hover:text-blue-700 dark:border-[#2E2447] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:border-[#8B5CF6] dark:hover:bg-[#30264A] dark:hover:text-[#F4F1FF]"
          }`}
        >
          {copiedTarget === "recipe" ? (
            <>
              <Check className="h-3 w-3" aria-hidden="true" />
              <span>コピー済</span>
            </>
          ) : (
            <>
              <Copy className="h-3 w-3" aria-hidden="true" />
              <span>レシピコピー</span>
            </>
          )}
        </button>

        <button
          type="button"
          onClick={handleCopyShareLink}
          aria-label="共有リンクをコピー"
          title="このコンボを直接開くURLをコピー"
          className={`inline-flex items-center gap-1 rounded-md border px-2 py-1 text-[11px] font-semibold transition-colors ${
            copiedTarget === "link"
              ? "border-emerald-200 bg-emerald-50 text-emerald-700 dark:border-emerald-400/40 dark:bg-emerald-500/20 dark:text-emerald-200"
              : "border-slate-200 bg-white text-slate-600 hover:border-blue-300 hover:bg-blue-50 hover:text-blue-700 dark:border-[#2E2447] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:border-[#8B5CF6] dark:hover:bg-[#30264A] dark:hover:text-[#F4F1FF]"
          }`}
        >
          {copiedTarget === "link" ? (
            <>
              <Check className="h-3 w-3" aria-hidden="true" />
              <span>コピー済</span>
            </>
          ) : (
            <>
              <Link2 className="h-3 w-3" aria-hidden="true" />
              <span>共有リンク</span>
            </>
          )}
        </button>
      </div>
    </article>
  );
}
