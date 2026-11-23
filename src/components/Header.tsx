"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  BookMarked,
  LogIn,
  LogOut,
  Moon,
  PlusCircle,
  Shield,
  Sun,
  User,
  Users,
  X,
} from "lucide-react";
import { useAuth } from "@/components/AuthProvider";
import { useTheme } from "@/components/ThemeProvider";

export function Header() {
  const pathname = usePathname();
  const router = useRouter();
  const { user, isAdmin, isLoading, signOut } = useAuth();
  const { theme, toggleTheme } = useTheme();
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

  // キャラ別コンボ一覧画面 (/characters/[slug]) にいる場合は選択中キャラを投稿画面へ引き継ぐ
  const characterPageMatch = pathname.match(/^\/characters\/([^/]+)$/);
  const newComboHref = characterPageMatch
    ? `/combos/new?character=${encodeURIComponent(characterPageMatch[1])}`
    : "/combos/new";

  return (
    <>
      <header className="sticky top-0 z-30 border-b border-slate-200 bg-white/95 backdrop-blur dark:border-[#2D2346] dark:bg-[#151024]/90">
        <div className="mx-auto flex h-14 max-w-5xl items-center justify-between gap-1.5 px-3 sm:gap-2 sm:px-6">
          <Link
            href="/"
            className="flex shrink-0 items-center gap-1.5 text-slate-900 transition-opacity hover:opacity-80 sm:gap-2 dark:text-[#F4F1FF]"
          >
            <span className="flex h-8 w-8 shrink-0 overflow-hidden rounded-lg shadow-sm ring-1 ring-black/5 dark:ring-white/15">
              <Image
                src="/icons/icon-192.png"
                alt=""
                width={32}
                height={32}
                priority
                className="h-full w-full object-cover"
              />
            </span>
            <span className="text-sm font-bold tracking-tight sm:text-lg">
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
                  ? "bg-blue-50 text-blue-700 dark:bg-[#7C3AED]/25 dark:text-[#DDD6FE]"
                  : "text-slate-600 hover:bg-slate-100 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:bg-[#251D3A] dark:hover:text-[#F4F1FF]"
              }`}
            >
              <Users className="h-4 w-4 shrink-0" aria-hidden="true" />
              <span className="hidden sm:inline">キャラ一覧</span>
            </Link>

            <Link
              href="/my-note"
              className={`inline-flex items-center gap-1.5 rounded-lg px-2 py-1.5 text-xs font-medium transition-colors sm:px-3 sm:text-sm ${
                pathname.startsWith("/my-note")
                  ? "bg-blue-50 text-blue-700 dark:bg-[#7C3AED]/25 dark:text-[#DDD6FE]"
                  : "text-slate-600 hover:bg-slate-100 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:bg-[#251D3A] dark:hover:text-[#F4F1FF]"
              }`}
            >
              <BookMarked className="h-4 w-4 shrink-0" aria-hidden="true" />
              <span className="hidden xs:inline sm:inline">マイノート</span>
              <span className="sm:hidden">ノート</span>
            </Link>

            <Link
              href={newComboHref}
              className={`inline-flex items-center gap-1.5 rounded-lg px-2 py-1.5 text-xs font-medium transition-colors sm:px-3 sm:text-sm ${
                pathname.startsWith("/combos/new")
                  ? "bg-blue-50 text-blue-700 dark:bg-[#7C3AED]/25 dark:text-[#DDD6FE]"
                  : "text-slate-600 hover:bg-slate-100 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:bg-[#251D3A] dark:hover:text-[#F4F1FF]"
              }`}
            >
              <PlusCircle className="h-4 w-4 shrink-0" aria-hidden="true" />
              <span className="hidden sm:inline">公開コンボ投稿</span>
              <span className="sm:hidden">投稿</span>
            </Link>

            {/* ライト／ダークモード切替ボタン */}
            <button
              type="button"
              onClick={toggleTheme}
              aria-label={
                theme === "dark"
                  ? "ライトモードに切り替え"
                  : "ダークモードに切り替え"
              }
              title={
                theme === "dark"
                  ? "ライトモードに切り替え"
                  : "ダークモードに切り替え"
              }
              className="inline-flex h-8 w-8 shrink-0 items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-600 transition-colors hover:bg-slate-100 hover:text-slate-900 dark:border-[#2E2447] dark:bg-[#251D3A] dark:text-[#DDD6FE] dark:hover:bg-[#30264A] dark:hover:text-white"
            >
              <Moon
                className="h-4 w-4 dark:hidden"
                aria-hidden="true"
              />
              <Sun
                className="hidden h-4 w-4 dark:block"
                aria-hidden="true"
              />
            </button>

            {!isLoading && user ? (
              <div className="flex items-center gap-1 sm:gap-1.5">
                {isAdmin && (
                  <span
                    title="管理者権限でログイン中"
                    aria-label="管理者権限（ADMIN）"
                    className="inline-flex shrink-0 items-center gap-1 rounded-md border border-amber-300/80 bg-amber-50 px-1.5 py-1 text-[10px] font-bold tracking-wider text-amber-800 sm:px-2 dark:border-amber-400/40 dark:bg-amber-500/20 dark:text-amber-200"
                  >
                    <Shield className="h-3 w-3 shrink-0" aria-hidden="true" />
                    <span className="hidden sm:inline">ADMIN</span>
                  </span>
                )}
                <span
                  title={user.email ?? "ログイン中"}
                  className="hidden max-w-[140px] items-center gap-1 truncate rounded-lg bg-slate-100 px-2.5 py-1.5 text-xs font-medium text-slate-700 md:inline-flex dark:bg-[#251D3A] dark:text-[#E2DCF5]"
                >
                  <User
                    className="h-3.5 w-3.5 shrink-0 text-slate-500 dark:text-[#A99EC4]"
                    aria-hidden="true"
                  />
                  <span className="truncate">{user.email}</span>
                </span>
                <button
                  type="button"
                  onClick={handleLogout}
                  aria-label="ログアウト"
                  title={`ログアウト (${user.email ?? ""})`}
                  className="inline-flex items-center gap-1 rounded-lg border border-slate-200 bg-white px-2 py-1.5 text-xs font-medium text-slate-700 transition-colors hover:bg-slate-50 sm:px-2.5 sm:text-sm dark:border-[#2E2447] dark:bg-[#1B152B] dark:text-[#E2DCF5] dark:hover:bg-[#251D3A]"
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
                aria-label="ログイン"
                className={`inline-flex items-center gap-1.5 rounded-lg border px-2 py-1.5 text-xs font-medium transition-colors sm:px-3 sm:text-sm ${
                  pathname === "/login"
                    ? "border-blue-200 bg-blue-50 text-blue-700 dark:border-[#8B5CF6]/50 dark:bg-[#7C3AED]/25 dark:text-[#DDD6FE]"
                    : "border-slate-200 bg-white text-slate-700 hover:bg-slate-50 dark:border-[#2E2447] dark:bg-[#1B152B] dark:text-[#E2DCF5] dark:hover:bg-[#251D3A]"
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
          className="fixed right-3 bottom-4 left-3 z-50 mx-auto flex max-w-md items-center justify-between gap-3 rounded-xl border border-slate-200 bg-slate-900 px-4 py-3 text-sm text-white shadow-lg sm:right-6 sm:left-auto dark:border-[#3D2F63] dark:bg-[#1F1835] dark:text-[#F4F1FF]"
        >
          <span>{notice}</span>
          <button
            type="button"
            onClick={() => setNotice(null)}
            aria-label="通知を閉じる"
            className="shrink-0 rounded p-1 text-slate-300 hover:bg-slate-800 hover:text-white dark:text-[#A99EC4] dark:hover:bg-[#30264A] dark:hover:text-white"
          >
            <X className="h-4 w-4" />
          </button>
        </div>
      )}
    </>
  );
}
