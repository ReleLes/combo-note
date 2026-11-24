"use client";

import { useMemo, useState, type CSSProperties } from "react";
import Image from "next/image";
import Link from "next/link";
import { ChevronRight, Search, X } from "lucide-react";
import type { Character } from "@/types/combo";
import type { CharacterVisualTheme } from "@/lib/characterThemes";
import { matchesCharacterSearch } from "@/lib/characterThemes";
import type { CharacterComboCounts } from "@/lib/supabase/queries";

export interface CharacterSelectCardItem {
  character: Character;
  counts: CharacterComboCounts;
  traitBadges: string[];
  theme: CharacterVisualTheme;
  imageUrl: string | null;
  watermarkText: string;
}

interface CharacterSelectGridClientProps {
  items: CharacterSelectCardItem[];
}

export function CharacterSelectGridClient({
  items,
}: CharacterSelectGridClientProps) {
  const [searchQuery, setSearchQuery] = useState("");

  const filteredItems = useMemo(() => {
    if (!searchQuery.trim()) return items;
    return items.filter((item) =>
      matchesCharacterSearch(item.character, searchQuery)
    );
  }, [items, searchQuery]);

  const isFiltering = searchQuery.trim().length > 0;

  return (
    <div className="mx-auto w-full max-w-6xl px-3 py-5 sm:px-6 sm:py-7">
      {/* 見出し＋キャラクター検索バー */}
      <section className="mb-4 sm:mb-6">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between sm:gap-4">
          <div className="min-w-0">
            <h1 className="text-xl font-bold tracking-tight text-slate-900 sm:text-2xl dark:text-[#F4F1FF]">
              キャラクターを選択
            </h1>
            <p className="mt-1 text-xs text-slate-600 sm:text-sm dark:text-[#A99EC4]">
              練習中や対戦の合間に、状況別の定番コンボをすぐ確認できます。
            </p>
          </div>

          {/* インライン検索バー */}
          <div className="w-full sm:w-72 md:w-80">
            <div className="relative flex items-center">
              <Search
                className="pointer-events-none absolute left-3 h-4 w-4 text-slate-400 dark:text-[#8E82B3]"
                aria-hidden="true"
              />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="キャラ名で検索（例: じゅり, 春麗, Ryu）"
                aria-label="キャラクター名で検索"
                className="w-full rounded-xl border border-slate-200 bg-white py-2 pr-9 pl-9 text-sm text-slate-900 shadow-2xs transition-colors placeholder:text-slate-400 focus:border-blue-500 focus:outline-none dark:border-[#2E2447] dark:bg-[#1B152B] dark:text-[#F4F1FF] dark:placeholder:text-[#8E82B3] dark:focus:border-[#8B5CF6]"
              />
              {searchQuery.length > 0 && (
                <button
                  type="button"
                  onClick={() => setSearchQuery("")}
                  aria-label="検索をクリア"
                  className="absolute right-2 inline-flex h-6 w-6 items-center justify-center rounded-md text-slate-400 transition-colors hover:bg-slate-100 hover:text-slate-700 dark:text-[#A99EC4] dark:hover:bg-[#2A2145] dark:hover:text-[#F4F1FF]"
                >
                  <X className="h-3.5 w-3.5" aria-hidden="true" />
                </button>
              )}
            </div>
            <div className="mt-1 flex items-center justify-between px-0.5 text-[11px] text-slate-500 dark:text-[#A99EC4]">
              <span>
                {isFiltering ? (
                  <>
                    <strong className="font-bold text-slate-800 dark:text-[#F4F1FF]">
                      {filteredItems.length}
                    </strong>{" "}
                    / {items.length} キャラが一致
                  </>
                ) : (
                  <>全 {items.length} キャラ対応</>
                )}
              </span>
              {isFiltering && (
                <button
                  type="button"
                  onClick={() => setSearchQuery("")}
                  className="font-medium text-blue-600 hover:underline dark:text-[#C4B5FD]"
                >
                  クリア
                </button>
              )}
            </div>
          </div>
        </div>
      </section>

      {/* 横長コンパクトバナーカードグリッド（スマホ2列 / タブレット3列 / PC4列） */}
      {filteredItems.length > 0 ? (
        <section
          aria-label="キャラクター一覧"
          className="grid grid-cols-2 gap-2.5 sm:grid-cols-3 sm:gap-3 lg:grid-cols-4"
        >
          {filteredItems.map(
            ({
              character,
              counts,
              traitBadges,
              theme,
              imageUrl,
              watermarkText,
            }) => {
              const cardStyle = {
                "--char-accent": theme.accent,
                "--char-secondary": theme.secondary,
                "--char-from": theme.gradientFrom,
                "--char-to": theme.gradientTo,
                "--char-glow": theme.glow,
                "--char-badge-bg": theme.badgeBg,
                "--char-badge-border": theme.badgeBorder,
              } as CSSProperties;

              return (
                <Link
                  key={character.id}
                  href={`/characters/${character.slug}`}
                  style={cardStyle}
                  className="group relative flex min-h-[80px] items-center justify-between gap-2 overflow-hidden rounded-xl border border-slate-900/15 bg-[#110C1D] shadow-sm shadow-slate-900/15 transition-all duration-200 hover:-translate-y-0.5 hover:border-[var(--char-accent)] hover:shadow-[0_10px_24px_-8px_var(--char-glow)] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[var(--char-accent)] active:scale-[0.985] sm:min-h-[88px] lg:min-h-[92px] dark:border-white/12 dark:shadow-md dark:shadow-black/45"
                >
                  {/* ベース背景：キャラ別テーマカラーの斜めグラデーション */}
                  <div
                    aria-hidden="true"
                    className="pointer-events-none absolute inset-0"
                    style={{
                      background:
                        "linear-gradient(122deg, #0D0919 0%, var(--char-from) 56%, var(--char-to) 100%)",
                    }}
                  />

                  {/* 斜めストライプ＆光スラッシュのスト6バナーテクスチャ */}
                  <div
                    aria-hidden="true"
                    className="pointer-events-none absolute inset-0 opacity-70"
                    style={{
                      backgroundImage:
                        "repeating-linear-gradient(-35deg, rgba(255,255,255,0.03) 0px, rgba(255,255,255,0.03) 2px, transparent 2px, transparent 12px)",
                    }}
                  />
                  <div
                    aria-hidden="true"
                    className="pointer-events-none absolute top-[18%] -left-6 h-[1.5px] w-[135%] -rotate-6 opacity-35 transition-opacity duration-300 group-hover:opacity-70"
                    style={{
                      background:
                        "linear-gradient(90deg, transparent 0%, var(--char-accent) 48%, var(--char-secondary) 80%, transparent 100%)",
                    }}
                  />

                  {/* 右側背景演出：モチーフアイコン用の控えめなグロー or 未配置時の英字透かしフォールバック */}
                  {imageUrl ? (
                    <div
                      aria-hidden="true"
                      className="pointer-events-none absolute top-1/2 -right-4 h-24 w-24 -translate-y-1/2 rounded-full opacity-25 blur-2xl transition-opacity duration-300 group-hover:opacity-45"
                      style={{
                        background:
                          "radial-gradient(circle, var(--char-accent) 0%, transparent 70%)",
                      }}
                    />
                  ) : (
                    <>
                      {/* 右側ラジアルグロー */}
                      <div
                        aria-hidden="true"
                        className="pointer-events-none absolute -top-8 -right-6 h-28 w-28 rounded-full opacity-35 blur-2xl transition-opacity duration-300 group-hover:opacity-60"
                        style={{
                          background:
                            "radial-gradient(circle, var(--char-accent) 0%, transparent 70%)",
                        }}
                      />
                      {/* 右寄せの半透明英字透かし */}
                      <div
                        aria-hidden="true"
                        className="pointer-events-none absolute inset-y-0 right-1 flex select-none items-center justify-end overflow-hidden pl-4"
                      >
                        <span className="-rotate-6 whitespace-nowrap text-right text-[1.85rem] font-black italic leading-none tracking-[-0.04em] text-white/[0.11] transition-all duration-300 group-hover:scale-105 group-hover:text-white/[0.18] sm:text-[2.2rem]">
                          {watermarkText}
                        </span>
                      </div>
                    </>
                  )}

                  {/* 左側テキスト可読性確保用の横方向ダークフェード */}
                  <div
                    aria-hidden="true"
                    className="pointer-events-none absolute inset-0"
                    style={{
                      background:
                        "linear-gradient(90deg, rgba(10, 7, 20, 0.90) 0%, rgba(12, 9, 24, 0.72) 50%, rgba(12, 9, 24, 0.24) 78%, rgba(12, 9, 24, 0.08) 100%)",
                    }}
                  />

                  {/* 左端のスト6風アクセントライン */}
                  <span
                    aria-hidden="true"
                    className="pointer-events-none absolute inset-y-0 left-0 w-[3px] opacity-85 transition-opacity duration-200 group-hover:opacity-100"
                    style={{
                      background:
                        "linear-gradient(180deg, var(--char-accent) 0%, var(--char-secondary) 100%)",
                    }}
                  />

                  {/* 左側：情報エリア */}
                  <div
                    className={`relative z-10 flex min-w-0 flex-1 flex-col justify-center gap-1 py-2 pl-3 sm:py-2.5 sm:pl-3.5 ${
                      imageUrl ? "pr-0" : "pr-7 sm:pr-8"
                    }`}
                  >
                    {/* 1. キャラ日本語名＋英語名 */}
                    <div className="min-w-0">
                      <h2 className="truncate text-[13px] font-extrabold leading-tight tracking-tight text-white drop-shadow-xs sm:text-[15px]">
                        {character.nameJa}
                      </h2>
                      <p className="mt-0.5 truncate text-[9px] font-bold uppercase leading-none tracking-[0.12em] text-white/70 sm:text-[10px]">
                        {character.nameEn}
                      </p>
                    </div>

                    {/* 2. 登録コンボ件数（1行コンパクト表示） */}
                    <div className="flex items-baseline gap-1.5 text-[10px] leading-none text-white/80 sm:text-[11px]">
                      <span className="shrink-0">
                        <strong className="font-bold text-white">
                          {counts.total}
                        </strong>
                        件
                      </span>
                      <span className="truncate font-mono text-[9px] text-white/65 sm:text-[10px]">
                        C:{counts.classic} / M:{counts.modern}
                      </span>
                    </div>

                    {/* 3. キャラ固有バッジ（該当キャラのみ極小ピル表示） */}
                    {traitBadges.length > 0 && (
                      <div className="mt-0.5 flex flex-wrap gap-1">
                        {traitBadges.map((label) => (
                          <span
                            key={label}
                            style={{
                              backgroundColor: "var(--char-badge-bg)",
                              borderColor: "var(--char-badge-border)",
                            }}
                            className="inline-flex max-w-full items-center truncate rounded border px-1.5 py-[1px] text-[9px] font-semibold leading-tight text-white/95 backdrop-blur-xs sm:text-[10px]"
                          >
                            {label}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>

                  {/* 右側：丸型モチーフアイコン（画像配置済みキャラ） or 右上コーナー遷移アイコン（未配置キャラ） */}
                  {imageUrl ? (
                    <div className="relative z-10 mr-2.5 h-12 w-12 shrink-0 overflow-hidden rounded-full bg-[#1C222D] ring-1 ring-white/20 shadow-[0_4px_12px_rgba(0,0,0,0.35)] transition-all duration-300 group-hover:ring-[var(--char-accent)]/75 group-hover:shadow-[0_0_16px_-2px_var(--char-glow)] sm:mr-3 sm:h-14 sm:w-14 lg:h-16 lg:w-16 dark:ring-white/15 dark:shadow-[0_4px_14px_rgba(0,0,0,0.55)]">
                      <Image
                        src={imageUrl}
                        alt={`${character.nameJa}（${character.nameEn}）モチーフアイコン`}
                        fill
                        sizes="(max-width: 639px) 48px, (max-width: 1023px) 56px, 64px"
                        className="scale-[1.08] object-cover object-center transition-transform duration-300 ease-out group-hover:scale-[1.14]"
                      />
                      <span
                        aria-hidden="true"
                        className="pointer-events-none absolute inset-0 rounded-full ring-1 ring-inset ring-black/15"
                      />
                    </div>
                  ) : (
                    <span
                      aria-hidden="true"
                      className="pointer-events-none absolute top-2 right-2 z-10 flex h-5 w-5 items-center justify-center rounded-full border border-white/15 bg-black/40 text-white/75 backdrop-blur-xs transition-all duration-200 group-hover:border-[var(--char-accent)] group-hover:bg-black/65 group-hover:text-white sm:h-6 sm:w-6"
                    >
                      <ChevronRight className="h-3 w-3 transition-transform duration-200 group-hover:translate-x-0.5 sm:h-3.5 sm:w-3.5" />
                    </span>
                  )}
                </Link>
              );
            }
          )}
        </section>
      ) : (
        <section
          aria-label="検索結果なし"
          className="rounded-2xl border border-dashed border-slate-300 bg-white px-4 py-12 text-center shadow-2xs dark:border-[#3A2E58] dark:bg-[#1B152B]"
        >
          <p className="text-sm font-semibold text-slate-800 dark:text-[#F4F1FF]">
            一致するキャラクターが見つかりません
          </p>
          <p className="mt-1 text-xs text-slate-500 dark:text-[#A99EC4]">
            「{searchQuery}」に該当するキャラクターはありません。別の表記やひらがな・英語でお試しください。
          </p>
          <button
            type="button"
            onClick={() => setSearchQuery("")}
            className="mt-4 inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-4 py-2 text-xs font-semibold text-white shadow-xs transition-colors hover:bg-blue-700 dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
          >
            <X className="h-3.5 w-3.5" aria-hidden="true" />
            <span>検索をクリア</span>
          </button>
        </section>
      )}
    </div>
  );
}
