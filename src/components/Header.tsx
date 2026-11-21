"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { BookMarked, LogIn, PlusCircle, Swords, Users, X } from "lucide-react";

export function Header() {
  const pathname = usePathname();
  const [notice, setNotice] = useState<string | null>(null);

  const showComingSoon = (featureName: string) => {
    setNotice(`「${featureName}」機能は準備中です。今後のフェーズで実装予定です。`);
  };

  return (
    <>
      <header className="sticky top-0 z-30 border-b border-slate-200 bg-white/95 backdrop-blur">
        <div className="mx-auto flex h-14 max-w-5xl items-center justify-between gap-2 px-3 sm:px-6">
          <Link
            href="/"
            className="flex shrink-0 items-center gap-2 text-slate-900 transition-opacity hover:opacity-80"
          >
            <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-600 text-white shadow-xs">
              <Swords className="h-4 w-4" aria-hidden="true" />
            </span>
            <span className="text-base font-bold tracking-tight sm:text-lg">
              コンボノート
            </span>
          </Link>

          <nav aria-label="メインナビゲーション" className="flex items-center gap-1 sm:gap-2">
            <Link
              href="/"
              className={`inline-flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-xs font-medium transition-colors sm:px-3 sm:text-sm ${
                pathname === "/" || pathname.startsWith("/characters")
                  ? "bg-blue-50 text-blue-700"
                  : "text-slate-600 hover:bg-slate-100 hover:text-slate-900"
              }`}
            >
              <Users className="h-4 w-4 shrink-0" aria-hidden="true" />
              <span className="hidden xs:inline sm:inline">キャラ一覧</span>
            </Link>

            <Link
              href="/my-note"
              className={`inline-flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-xs font-medium transition-colors sm:px-3 sm:text-sm ${
                pathname.startsWith("/my-note")
                  ? "bg-blue-50 text-blue-700"
                  : "text-slate-600 hover:bg-slate-100 hover:text-slate-900"
              }`}
            >
              <BookMarked className="h-4 w-4 shrink-0" aria-hidden="true" />
              <span>マイノート</span>
            </Link>

            <button
              type="button"
              onClick={() => showComingSoon("公開コンボ投稿")}
              className="inline-flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-xs font-medium text-slate-600 transition-colors hover:bg-slate-100 hover:text-slate-900 sm:px-3 sm:text-sm"
            >
              <PlusCircle className="h-4 w-4 shrink-0" aria-hidden="true" />
              <span className="hidden sm:inline">公開コンボ投稿</span>
              <span className="sm:hidden">投稿</span>
            </button>

            <button
              type="button"
              onClick={() => showComingSoon("ログイン")}
              className="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-xs font-medium text-slate-700 transition-colors hover:bg-slate-50 sm:px-3 sm:text-sm"
            >
              <LogIn className="h-4 w-4 shrink-0" aria-hidden="true" />
              <span className="hidden sm:inline">ログイン</span>
            </button>
          </nav>
        </div>
      </header>

      {notice && (
        <div
          role="status"
          className="fixed right-3 bottom-4 left-3 z-50 mx-auto flex max-w-md items-center justify-between gap-3 rounded-xl border border-slate-200 bg-slate-900 px-4 py-3 text-sm text-white shadow-lg sm:right-6 sm:left-auto"
        >
          <span>{notice}</span>
          <button
            type="button"
            onClick={() => setNotice(null)}
            aria-label="通知を閉じる"
            className="shrink-0 rounded p-1 text-slate-300 hover:bg-slate-800 hover:text-white"
          >
            <X className="h-4 w-4" />
          </button>
        </div>
      )}
    </>
  );
}
