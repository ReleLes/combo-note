import Link from "next/link";
import { BookMarked, Home, SearchX } from "lucide-react";

export default function NotFound() {
  return (
    <div className="mx-auto flex w-full max-w-lg flex-1 items-center justify-center px-4 py-16">
      <div className="w-full rounded-2xl border border-slate-200 bg-white p-6 text-center shadow-xs sm:p-8 dark:border-[#2E2447] dark:bg-[#1B152B]">
        <div className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-slate-100 text-slate-500 dark:bg-[#251D3A] dark:text-[#A99EC4]">
          <SearchX className="h-6 w-6" aria-hidden="true" />
        </div>
        <p className="font-mono text-xs font-bold tracking-wider text-slate-400 dark:text-[#8E82B3]">
          404 NOT FOUND
        </p>
        <h1 className="mt-1 text-lg font-bold text-slate-900 sm:text-xl dark:text-[#F4F1FF]">
          ページが見つかりませんでした
        </h1>
        <p className="mt-2 text-xs leading-relaxed text-slate-600 sm:text-sm dark:text-[#A99EC4]">
          お探しのURLは移動または削除された可能性があります。
        </p>

        <div className="mt-6 flex flex-wrap items-center justify-center gap-2.5">
          <Link
            href="/"
            className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-4 py-2 text-xs font-semibold text-white shadow-xs transition-colors hover:bg-blue-700 sm:text-sm dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
          >
            <Home className="h-4 w-4" aria-hidden="true" />
            <span>キャラ一覧へ戻る</span>
          </Link>
          <Link
            href="/my-note"
            className="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-700 transition-colors hover:bg-slate-50 sm:text-sm dark:border-[#2E2447] dark:bg-[#251D3A] dark:text-[#E2DCF5] dark:hover:bg-[#30264A]"
          >
            <BookMarked className="h-4 w-4" aria-hidden="true" />
            <span>マイノートを開く</span>
          </Link>
        </div>
      </div>
    </div>
  );
}
