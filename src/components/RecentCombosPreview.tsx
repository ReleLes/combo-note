"use client";

import { useMemo } from "react";
import Image from "next/image";
import Link from "next/link";
import { ArrowRight, ChevronRight, Clock, Sparkles } from "lucide-react";
import type {
  Character,
  Combo,
  Move,
  SituationDefinition,
} from "@/types/combo";
import { getCharacterTheme } from "@/lib/characterThemes";
import {
  formatComboRecipeText,
  formatFullDateTime,
  formatRelativePostedAt,
} from "@/lib/comboUtils";
import { usePreferences } from "@/hooks/useComboNoteStorage";

interface RecentCombosPreviewProps {
  combos: Combo[];
  characters: Character[];
  characterImageMap: Record<string, string | null>;
  moveMap: Record<string, Move>;
  allSituations: SituationDefinition[];
}

export function RecentCombosPreview({
  combos,
  characters,
  characterImageMap,
  moveMap,
  allSituations,
}: RecentCombosPreviewProps) {
  const { notationMode, controlType } = usePreferences();

  const characterMap = useMemo(() => {
    const map: Record<string, Character> = {};
    for (const c of characters) {
      map[c.id] = c;
    }
    return map;
  }, [characters]);

  const situationMap = useMemo(() => {
    const map: Record<string, SituationDefinition> = {};
    for (const s of allSituations) {
      map[s.key] = s;
    }
    return map;
  }, [allSituations]);

  if (combos.length === 0) {
    return null;
  }

  return (
    <section
      aria-label="新着コンボ"
      className="mx-auto w-full max-w-6xl px-3 pt-4 sm:px-6 sm:pt-5"
    >
      <div className="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-2xs dark:border-[#2E2447] dark:bg-[#1B152B]">
        {/* セクションヘッダー */}
        <div className="flex items-center justify-between gap-2 border-b border-slate-100 bg-slate-50/70 px-3 py-2 sm:px-4 dark:border-[#2E2447] dark:bg-[#161124]">
          <div className="flex items-center gap-1.5">
            <Sparkles
              className="h-3.5 w-3.5 shrink-0 text-blue-600 dark:text-[#A78BFA]"
              aria-hidden="true"
            />
            <h2 className="text-xs font-bold tracking-tight text-slate-900 sm:text-sm dark:text-[#F4F1FF]">
              新着コンボ
            </h2>
            <span className="hidden text-[11px] text-slate-500 sm:inline dark:text-[#A99EC4]">
              最新{combos.length}件
            </span>
          </div>

          <Link
            href="/combos"
            className="inline-flex shrink-0 items-center gap-1 text-xs font-semibold text-blue-600 transition-colors hover:text-blue-700 hover:underline dark:text-[#C4B5FD] dark:hover:text-[#DDD6FE]"
          >
            <span>すべて見る</span>
            <ArrowRight className="h-3.5 w-3.5" aria-hidden="true" />
          </Link>
        </div>

        {/* スリムな最新5件リスト（スマホ2行 / PC1行構成で押し下げを抑制） */}
        <ul className="divide-y divide-slate-100 dark:divide-[#2A2042]">
          {combos.map((combo) => {
            const char = characterMap[combo.characterId];
            const slug = char?.slug ?? combo.characterId;
            const imageUrl = characterImageMap[combo.characterId] ?? null;
            const charTheme = getCharacterTheme(slug);
            const moves = combo.moveIds
              .map((id) => moveMap[id])
              .filter((m): m is Move => Boolean(m));
            const recipeText = formatComboRecipeText(moves, notationMode);
            const primarySituations = combo.situations.slice(0, 2);
            const matchesPreferredControl = combo.controlType === controlType;

            return (
              <li key={combo.id}>
                <Link
                  href={`/characters/${slug}?combo=${encodeURIComponent(combo.id)}`}
                  className="group flex flex-col gap-1 px-3 py-2 transition-colors hover:bg-slate-50 sm:flex-row sm:items-center sm:gap-2.5 sm:px-4 sm:py-2 dark:hover:bg-[#241C38]"
                >
                  {/* 1行目（PCでは左側グループ）：キャラバッジ＋操作タイプ＋主要状況バッジ＋(スマホ時の投稿日時) */}
                  <div className="flex min-w-0 shrink-0 items-center justify-between gap-2 sm:justify-start">
                    <div className="flex min-w-0 items-center gap-1.5 sm:gap-2">
                      {/* キャラクターバッジ */}
                      <span className="inline-flex shrink-0 items-center gap-1.5 sm:w-[116px]">
                        {imageUrl ? (
                          <span className="relative h-5 w-5 shrink-0 overflow-hidden rounded-full bg-[#1C222D] ring-1 ring-slate-900/10 dark:ring-white/15">
                            <Image
                              src={imageUrl}
                              alt=""
                              fill
                              sizes="20px"
                              className="scale-[1.08] object-cover object-center"
                            />
                          </span>
                        ) : (
                          <span
                            aria-hidden="true"
                            className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full text-[9px] font-extrabold text-white ring-1 ring-black/10 dark:ring-white/15"
                            style={{
                              background: `linear-gradient(135deg, ${charTheme.gradientFrom}, ${charTheme.accent})`,
                            }}
                          >
                            {(char?.nameJa ?? "?").slice(0, 1)}
                          </span>
                        )}
                        <span className="max-w-[78px] truncate text-xs font-bold text-slate-900 group-hover:text-blue-700 sm:max-w-[90px] dark:text-[#F4F1FF] dark:group-hover:text-[#C4B5FD]">
                          {char?.nameJa ?? combo.characterId}
                        </span>
                      </span>

                      {/* 操作タイプ極小バッジ（選択中の操作タイプと一致する場合は強調） */}
                      <span
                        title={
                          combo.controlType === "classic"
                            ? "クラシック"
                            : "モダン"
                        }
                        className={`shrink-0 rounded px-1 py-[1px] text-[10px] font-bold leading-tight ${
                          combo.controlType === "classic"
                            ? matchesPreferredControl
                              ? "bg-slate-900 text-white dark:bg-[#7C3AED] dark:text-white"
                              : "bg-slate-200 text-slate-700 dark:bg-[#2E2546] dark:text-[#CFC6E8]"
                            : matchesPreferredControl
                              ? "bg-sky-600 text-white dark:bg-sky-500/35 dark:text-sky-100"
                              : "bg-sky-100 text-sky-800 dark:bg-sky-500/20 dark:text-sky-200"
                        }`}
                      >
                        {combo.controlType === "classic" ? "C" : "M"}
                      </span>

                      {/* 主要状況バッジ（1〜2個） */}
                      <div className="flex min-w-0 items-center gap-1 overflow-hidden">
                        {primarySituations.map((sitKey, idx) => {
                          const def = situationMap[sitKey];
                          return (
                            <span
                              key={sitKey}
                              title={def?.description}
                              className={`inline-flex shrink-0 items-center whitespace-nowrap rounded px-1.5 py-[1px] text-[10px] font-bold leading-tight ${
                                idx > 0 ? "hidden sm:inline-flex" : ""
                              } ${
                                def?.badgeClassName ??
                                "bg-slate-100 text-slate-700 dark:bg-[#251D3A] dark:text-[#CFC6E8]"
                              }`}
                            >
                              {def?.label ?? sitKey}
                            </span>
                          );
                        })}
                      </div>
                    </div>

                    {/* スマホ用：右端に投稿日時 */}
                    <time
                      dateTime={combo.createdAt}
                      title={formatFullDateTime(combo.createdAt)}
                      suppressHydrationWarning
                      className="inline-flex shrink-0 items-center gap-0.5 text-[10px] text-slate-400 sm:hidden dark:text-[#8E82B3]"
                    >
                      <Clock className="h-2.5 w-2.5" aria-hidden="true" />
                      <span>{formatRelativePostedAt(combo.createdAt)}</span>
                    </time>
                  </div>

                  {/* 2行目（PCでは中央フレックス）：レシピの簡潔な1行表示 */}
                  <div className="min-w-0 flex-1">
                    <p className="truncate font-mono text-[11px] text-slate-700 sm:text-xs dark:text-[#D8D0EE]">
                      {recipeText || combo.title || "レシピを見る"}
                    </p>
                  </div>

                  {/* PC用：右端に投稿日時＋遷移シェブロン */}
                  <div className="hidden shrink-0 items-center gap-1.5 sm:flex">
                    <time
                      dateTime={combo.createdAt}
                      title={formatFullDateTime(combo.createdAt)}
                      suppressHydrationWarning
                      className="inline-flex items-center gap-1 text-[11px] text-slate-400 dark:text-[#8E82B3]"
                    >
                      <Clock className="h-3 w-3" aria-hidden="true" />
                      <span>{formatRelativePostedAt(combo.createdAt)}</span>
                    </time>
                    <ChevronRight
                      className="h-3.5 w-3.5 text-slate-300 transition-transform group-hover:translate-x-0.5 group-hover:text-blue-600 dark:text-[#5E5280] dark:group-hover:text-[#C4B5FD]"
                      aria-hidden="true"
                    />
                  </div>
                </Link>
              </li>
            );
          })}
        </ul>
      </div>
    </section>
  );
}
