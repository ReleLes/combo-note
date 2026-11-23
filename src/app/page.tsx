import fs from "node:fs";
import path from "node:path";
import type { CSSProperties } from "react";
import Image from "next/image";
import Link from "next/link";
import { ChevronRight } from "lucide-react";
import { getSituationsForCharacter } from "@/data/seed";
import { getCharacterTheme } from "@/lib/characterThemes";
import {
  type CharacterComboCounts,
  fetchActiveCharacters,
  fetchComboCountsByCharacter,
} from "@/lib/supabase/queries";
import type { Character } from "@/types/combo";
import { DataErrorBanner } from "@/components/DataErrorBanner";

export const dynamic = "force-dynamic";

const CHARACTER_IMAGE_EXTENSIONS = [".webp", ".png", ".jpg"] as const;
const CHARACTER_IMAGE_DIR = path.join(
  process.cwd(),
  "public",
  "images",
  "characters"
);

function resolveCharacterImageUrl(slug: string): string | null {
  if (!/^[a-z0-9-]+$/i.test(slug)) return null;

  for (const ext of CHARACTER_IMAGE_EXTENSIONS) {
    const filePath = path.join(CHARACTER_IMAGE_DIR, `${slug}${ext}`);
    if (fs.existsSync(filePath)) {
      return `/images/characters/${slug}${ext}`;
    }
  }
  return null;
}

export default async function HomePage() {
  let characters: Character[] = [];
  let comboCounts: Record<string, CharacterComboCounts> = {};
  let errorMessage: string | null = null;

  try {
    [characters, comboCounts] = await Promise.all([
      fetchActiveCharacters(),
      fetchComboCountsByCharacter(),
    ]);
  } catch (error) {
    errorMessage =
      error instanceof Error
        ? error.message
        : "データベースからの読み込み中にエラーが発生しました。";
  }

  if (errorMessage) {
    return (
      <DataErrorBanner
        title="キャラクター一覧を読み込めませんでした"
        message={errorMessage}
      />
    );
  }

  return (
    <div className="mx-auto w-full max-w-5xl px-3 py-6 sm:px-6 sm:py-10 xl:max-w-6xl">
      <section className="mb-6 sm:mb-8">
        <h1 className="text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl dark:text-[#F4F1FF]">
          キャラクターを選択
        </h1>
        <p className="mt-1.5 text-sm text-slate-600 dark:text-[#A99EC4]">
          練習中や対戦の合間に、状況別の定番コンボをすぐ確認できます。
        </p>
      </section>

      <section
        aria-label="キャラクター一覧"
        className="grid grid-cols-2 gap-3 sm:grid-cols-3 sm:gap-4 lg:grid-cols-4 xl:grid-cols-5"
      >
        {characters.map((character) => {
          const counts = comboCounts[character.id] ?? {
            total: 0,
            classic: 0,
            modern: 0,
          };
          const uniqueSituations = getSituationsForCharacter(
            character.id
          ).filter((s) => s.characterId === character.id);
          const theme = getCharacterTheme(character.slug);
          const imageUrl = resolveCharacterImageUrl(character.slug);
          const watermarkText =
            theme.watermark ?? character.nameEn.toUpperCase();

          // 固有状況バッジ＋固有ストックバッジ（重複ラベルはまとめる）
          const traitBadges: string[] = uniqueSituations.map((s) => s.label);
          if (
            character.stockMeta &&
            !traitBadges.includes(character.stockMeta.label)
          ) {
            traitBadges.push(character.stockMeta.label);
          }

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
              className="group relative flex aspect-[3/4] min-h-[240px] flex-col justify-end overflow-hidden rounded-2xl border border-slate-900/15 bg-[#120D20] shadow-md shadow-slate-900/10 transition-all duration-300 hover:-translate-y-1 hover:border-[var(--char-accent)] hover:shadow-[0_14px_34px_-10px_var(--char-glow)] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[var(--char-accent)] active:scale-[0.985] sm:min-h-[300px] dark:border-white/12 dark:shadow-lg dark:shadow-black/45"
            >
              {/* 背景レイヤー：ポートレート画像 or テーマカラーフォールバック */}
              <div className="pointer-events-none absolute inset-0 overflow-hidden">
                {imageUrl ? (
                  <Image
                    src={imageUrl}
                    alt={`${character.nameJa}（${character.nameEn}）`}
                    fill
                    sizes="(max-width: 639px) 50vw, (max-width: 1023px) 33vw, (max-width: 1279px) 25vw, 20vw"
                    className="object-cover object-top transition-transform duration-500 ease-out group-hover:scale-105"
                  />
                ) : (
                  <div
                    className="relative h-full w-full"
                    style={{
                      background:
                        "linear-gradient(150deg, var(--char-from) 0%, var(--char-to) 68%, #090612 100%)",
                    }}
                  >
                    {/* 上部ラジアルグロー */}
                    <div
                      className="absolute -top-12 -right-10 h-44 w-44 rounded-full opacity-35 blur-3xl transition-opacity duration-500 group-hover:opacity-55"
                      style={{
                        background:
                          "radial-gradient(circle, var(--char-accent) 0%, transparent 70%)",
                      }}
                    />
                    <div
                      className="absolute top-1/3 -left-10 h-36 w-36 rounded-full opacity-20 blur-2xl"
                      style={{
                        background:
                          "radial-gradient(circle, var(--char-secondary) 0%, transparent 70%)",
                      }}
                    />

                    {/* 繊細な斜めストライプテクスチャ */}
                    <div
                      className="absolute inset-0 opacity-75"
                      style={{
                        backgroundImage:
                          "repeating-linear-gradient(-35deg, rgba(255,255,255,0.035) 0px, rgba(255,255,255,0.035) 2px, transparent 2px, transparent 14px)",
                      }}
                    />

                    {/* スト6風・斜めの光スラッシュライン */}
                    <div
                      className="absolute top-[24%] -left-8 h-[2px] w-[140%] -rotate-12 opacity-45 transition-opacity duration-300 group-hover:opacity-80"
                      style={{
                        background:
                          "linear-gradient(90deg, transparent 0%, var(--char-accent) 45%, var(--char-secondary) 75%, transparent 100%)",
                      }}
                    />
                    <div
                      className="absolute top-[29%] -left-8 h-px w-[130%] -rotate-12 opacity-25"
                      style={{
                        background:
                          "linear-gradient(90deg, transparent 0%, rgba(255,255,255,0.7) 55%, transparent 100%)",
                      }}
                    />

                    {/* 大文字・極太・低不透明度の斜め英字透かし */}
                    <div
                      aria-hidden="true"
                      className="absolute inset-x-0 top-[14%] flex select-none items-center justify-center overflow-hidden px-1"
                    >
                      <span className="-rotate-12 whitespace-nowrap text-center text-[2.4rem] font-black italic leading-none tracking-[-0.04em] text-white/[0.11] transition-all duration-500 group-hover:scale-105 group-hover:text-white/[0.16] sm:text-[3.1rem]">
                        {watermarkText}
                      </span>
                    </div>
                  </div>
                )}
              </div>

              {/* 視認性確保用：テーマ色混じりの下部ダークオーバーレイ */}
              <div
                aria-hidden="true"
                className="pointer-events-none absolute inset-0"
                style={{
                  background:
                    "linear-gradient(to top, rgba(8, 5, 16, 0.96) 0%, rgba(12, 8, 24, 0.80) 38%, rgba(12, 8, 24, 0.24) 68%, rgba(12, 8, 24, 0.06) 100%)",
                }}
              />
              <div
                aria-hidden="true"
                className="pointer-events-none absolute inset-x-0 bottom-0 h-2/3 opacity-20 transition-opacity duration-300 group-hover:opacity-35"
                style={{
                  background:
                    "linear-gradient(to top, var(--char-from) 0%, transparent 100%)",
                }}
              />

              {/* 上部コーナーのアクセント＆遷移アイコン */}
              <div className="pointer-events-none absolute top-0 right-0 left-0 z-10 flex items-start justify-between p-2.5 sm:p-3">
                <span
                  aria-hidden="true"
                  className="mt-1 h-1 w-8 -skew-x-12 rounded-full opacity-90 transition-all duration-300 group-hover:w-12"
                  style={{
                    background:
                      "linear-gradient(90deg, var(--char-accent), var(--char-secondary))",
                  }}
                />
                <span className="flex h-7 w-7 items-center justify-center rounded-full border border-white/15 bg-black/35 text-white/75 backdrop-blur-xs transition-all duration-300 group-hover:border-[var(--char-accent)] group-hover:bg-black/55 group-hover:text-white">
                  <ChevronRight
                    className="h-3.5 w-3.5 transition-transform duration-300 group-hover:translate-x-0.5"
                    aria-hidden="true"
                  />
                </span>
              </div>

              {/* 下部情報エリア */}
              <div className="relative z-10 flex flex-col gap-2 p-3 sm:p-3.5">
                {/* 1. キャラ日本語名＋英語名 */}
                <div className="min-w-0">
                  <h2 className="truncate text-base font-extrabold leading-tight tracking-tight text-white drop-shadow-xs sm:text-lg">
                    {character.nameJa}
                  </h2>
                  <p className="mt-0.5 truncate text-[10px] font-bold uppercase tracking-[0.14em] text-white/70 sm:text-[11px]">
                    {character.nameEn}
                  </p>
                </div>

                {/* 2. キャラ固有タグバッジ */}
                {traitBadges.length > 0 && (
                  <div className="flex flex-wrap gap-1">
                    {traitBadges.map((label) => (
                      <span
                        key={label}
                        style={{
                          backgroundColor: "var(--char-badge-bg)",
                          borderColor: "var(--char-badge-border)",
                        }}
                        className="inline-flex max-w-full items-center truncate rounded-md border px-1.5 py-0.5 text-[10px] font-semibold leading-tight text-white/95 backdrop-blur-xs"
                      >
                        {label}
                      </span>
                    ))}
                  </div>
                )}

                {/* 3. 登録コンボ件数 */}
                <div className="flex flex-wrap items-center justify-between gap-x-2 gap-y-0.5 border-t border-white/15 pt-2 text-[11px] text-white/80">
                  <span>
                    登録{" "}
                    <strong className="font-bold text-white">
                      {counts.total}
                    </strong>
                    件
                  </span>
                  <span className="font-mono text-[10px] text-white/70">
                    C:{counts.classic} / M:{counts.modern}
                  </span>
                </div>
              </div>

              {/* 最下部のスト6風アクセントバー */}
              <span
                aria-hidden="true"
                className="pointer-events-none absolute inset-x-0 bottom-0 h-1 opacity-75 transition-opacity duration-300 group-hover:opacity-100"
                style={{
                  background:
                    "linear-gradient(90deg, var(--char-accent) 0%, var(--char-secondary) 100%)",
                }}
              />
            </Link>
          );
        })}
      </section>
    </div>
  );
}
