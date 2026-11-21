"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  BookMarked,
  LogIn,
  LogOut,
  PlusCircle,
  Swords,
  User,
  Users,
  X,
} from "lucide-react";
import { useAuth } from "@/components/AuthProvider";

export function Header() {
  const pathname = usePathname();
  const router = useRouter();
  const { user, isLoading, signOut } = useAuth();
  const [notice, setNotice] = useState<string | null>(null);

  useEffect(() => {
    if (!notice) return;
    const timer = window.setTimeout(() => setNotice(null), 2800);
    return () => window.clearTimeout(timer);
  }, [notice]);

  const handleLogout = async () => {
    await signOut();
    setNotice("ログアウトしました。");
    router.refresh();
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

          <nav
            aria-label="メインナビゲーション"
            className="flex items-center gap-1 sm:gap-2"
          >
            <Link
              href="/"
              className={`inline-flex items-center gap-1.5 rounded-lg px-2 py-1.5 text-xs font-medium transition-colors sm:px-3 sm:text-sm ${
                pathname === "/" || pathname.startsWith("/characters")
                  ? "bg-blue-50 text-blue-700"
                  : "text-slate-600 hover:bg-slate-100 hover:text-slate-900"
              }`}
            >
              <Users className="h-4 w-4 shrink-0" aria-hidden="true" />
              <span className="hidden sm:inline">キャラ一覧</span>
            </Link>

            <Link
              href="/my-note"
              className={`inline-flex items-center gap-1.5 rounded-lg px-2 py-1.5 text-xs font-medium transition-colors sm:px-3 sm:text-sm ${
                pathname.startsWith("/my-note")
                  ? "bg-blue-50 text-blue-700"
                  : "text-slate-600 hover:bg-slate-100 hover:text-slate-900"
              }`}
            >
              <BookMarked className="h-4 w-4 shrink-0" aria-hidden="true" />
              <span>マイノート</span>
            </Link>

            <Link
              href="/combos/new"
              className={`inline-flex items-center gap-1.5 rounded-lg px-2 py-1.5 text-xs font-medium transition-colors sm:px-3 sm:text-sm ${
                pathname.startsWith("/combos/new")
                  ? "bg-blue-50 text-blue-700"
                  : "text-slate-600 hover:bg-slate-100 hover:text-slate-900"
              }`}
            >
              <PlusCircle className="h-4 w-4 shrink-0" aria-hidden="true" />
              <span className="hidden sm:inline">公開コンボ投稿</span>
              <span className="sm:hidden">投稿</span>
            </Link>

            {!isLoading && user ? (
              <div className="flex items-center gap-1.5 pl-1">
                <span
                  title={user.email ?? "ログイン中"}
                  className="hidden max-w-[140px] items-center gap-1 truncate rounded-lg bg-slate-100 px-2.5 py-1.5 text-xs font-medium text-slate-700 md:inline-flex"
                >
                  <User className="h-3.5 w-3.5 shrink-0 text-slate-500" aria-hidden="true" />
                  <span className="truncate">{user.email}</span>
                </span>
                <button
                  type="button"
                  onClick={handleLogout}
                  aria-label="ログアウト"
                  title={`ログアウト (${user.email ?? ""})`}
                  className="inline-flex items-center gap-1 rounded-lg border border-slate-200 bg-white px-2 py-1.5 text-xs font-medium text-slate-700 transition-colors hover:bg-slate-50 sm:px-2.5 sm:text-sm"
                >
                  <LogOut className="h-4 w-4 shrink-0" aria-hidden="true" />
                  <span className="hidden sm:inline">ログアウト</span>
                </button>
              </div>
            ) : (
              <Link
                href={
                  pathname && pathname !== "/login"
                    ? `/login?next=${encodeURIComponent(pathname)}`
                    : "/login"
                }
                className={`inline-flex items-center gap-1.5 rounded-lg border px-2.5 py-1.5 text-xs font-medium transition-colors sm:px-3 sm:text-sm ${
                  pathname === "/login"
                    ? "border-blue-200 bg-blue-50 text-blue-700"
                    : "border-slate-200 bg-white text-slate-700 hover:bg-slate-50"
                }`}
              >
                <LogIn className="h-4 w-4 shrink-0" aria-hidden="true" />
                <span className="hidden sm:inline">ログイン</span>
              </Link>
            )}
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
