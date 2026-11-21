import Link from "next/link";
import { ChevronRight } from "lucide-react";
import {
  getAllCharacters,
  getCombosByCharacter,
  getSituationsForCharacter,
} from "@/data/seed";

export default function HomePage() {
  const characters = getAllCharacters();

  return (
    <div className="mx-auto w-full max-w-5xl px-3 py-6 sm:px-6 sm:py-10">
      <section className="mb-6 sm:mb-8">
        <h1 className="text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl">
          キャラクターを選択
        </h1>
        <p className="mt-1.5 text-sm text-slate-600">
          練習中や対戦の合間に、状況別の定番コンボをすぐ確認できます。
        </p>
      </section>

      <section
        aria-label="キャラクター一覧"
        className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4"
      >
        {characters.map((character) => {
          const allCombos = getCombosByCharacter(character.id);
          const classicCount = allCombos.filter(
            (c) => c.controlType === "classic"
          ).length;
          const modernCount = allCombos.filter(
            (c) => c.controlType === "modern"
          ).length;
          const uniqueSituations = getSituationsForCharacter(
            character.id
          ).filter((s) => s.characterId === character.id);

          return (
            <Link
              key={character.id}
              href={`/characters/${character.slug}`}
              className="group flex flex-col justify-between rounded-xl border border-slate-200 bg-white p-4 shadow-xs transition-all hover:border-blue-400 hover:shadow-md focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
            >
              <div>
                <div className="flex items-start justify-between gap-2">
                  <div>
                    <h2 className="text-lg font-bold text-slate-900 group-hover:text-blue-600">
                      {character.nameJa}
                    </h2>
                    <p className="text-xs font-medium text-slate-500">
                      {character.nameEn}
                    </p>
                  </div>
                  <span className="rounded-lg bg-slate-100 p-1.5 text-slate-400 transition-colors group-hover:bg-blue-50 group-hover:text-blue-600">
                    <ChevronRight className="h-4 w-4" aria-hidden="true" />
                  </span>
                </div>

                {(uniqueSituations.length > 0 || character.stockMeta) && (
                  <div className="mt-3 flex flex-wrap gap-1.5">
                    {uniqueSituations.map((sit) => (
                      <span
                        key={sit.key}
                        className={`inline-flex items-center rounded-md px-2 py-0.5 text-[11px] font-semibold ${sit.badgeClassName}`}
                      >
                        {sit.label}
                      </span>
                    ))}
                    {character.stockMeta && (
                      <span className="inline-flex items-center rounded-md bg-cyan-50 px-2 py-0.5 text-[11px] font-semibold text-cyan-700">
                        {character.stockMeta.label}
                      </span>
                    )}
                  </div>
                )}
              </div>

              <div className="mt-4 flex items-center justify-between border-t border-slate-100 pt-3 text-xs text-slate-500">
                <span>
                  登録{" "}
                  <strong className="font-semibold text-slate-800">
                    {allCombos.length}
                  </strong>{" "}
                  件
                </span>
                <span className="text-[11px]">
                  C: {classicCount} / M: {modernCount}
                </span>
              </div>
            </Link>
          );
        })}
      </section>
    </div>
  );
}
