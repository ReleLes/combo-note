"use client";

import { useEffect, useRef, useState } from "react";
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
  Sparkles,
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
  const [isAccountMenuOpen, setIsAccountMenuOpen] = useState(false);
  const accountMenuRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (!notice) return;
    const timer = window.setTimeout(() => setNotice(null), 2800);
    return () => window.clearTimeout(timer);
  }, [notice]);

  useEffect(() => {
    if (!isAccountMenuOpen) return;

    const handlePointerDown = (event: MouseEvent) => {
      if (
        accountMenuRef.current &&
        !accountMenuRef.current.contains(event.target as Node)
      ) {
        setIsAccountMenuOpen(false);
      }
    };

    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        setIsAccountMenuOpen(false);
      }
    };

    document.addEventListener("mousedown", handlePointerDown);
    document.addEventListener("keydown", handleKeyDown);
    return () => {
      document.removeEventListener("mousedown", handlePointerDown);
      document.removeEventListener("keydown", handleKeyDown);
    };
  }, [isAccountMenuOpen]);

  const handleLogout = async () => {
    setIsAccountMenuOpen(false);
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
        <div className="mx-auto flex h-14 max-w-6xl items-center justify-between gap-1 px-2.5 sm:gap-2 sm:px-6">
          <Link
            href="/"
            className="flex shrink-0 items-center gap-1.5 text-slate-900 transition-opacity hover:opacity-80 sm:gap-2 dark:text-[#F4F1FF]"
          >
            <span className="flex h-7 w-7 shrink-0 overflow-hidden rounded-lg shadow-sm ring-1 ring-black/5 sm:h-8 sm:w-8 dark:ring-white/15">
              <Image
                src="/icons/icon-192.png"
                alt=""
                width={32}
                height={32}
                priority
                className="h-full w-full object-cover"
              />
            </span>
            <span className="text-[13px] font-bold tracking-tight sm:text-lg">
              コンボノート
            </span>
          </Link>

          <nav
            aria-label="メインナビゲーション"
            className="flex items-center gap-0.5 sm:gap-1.5 lg:gap-2"
          >
            <Link
              href="/"
              className={`hidden items-center gap-1.5 rounded-lg px-2 py-1.5 text-xs font-medium transition-colors sm:inline-flex sm:px-2.5 sm:text-sm lg:px-3 ${
                pathname === "/" || pathname.startsWith("/characters")
                  ? "bg-blue-50 text-blue-700 dark:bg-[#7C3AED]/25 dark:text-[#DDD6FE]"
                  : "text-slate-600 hover:bg-slate-100 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:bg-[#251D3A] dark:hover:text-[#F4F1FF]"
              }`}
            >
              <Users className="h-4 w-4 shrink-0" aria-hidden="true" />
              <span>キャラ一覧</span>
            </Link>

            <Link
              href="/combos"
              className={`inline-flex items-center gap-1 rounded-lg px-1.5 py-1.5 text-[11px] font-medium transition-colors sm:gap-1.5 sm:px-2.5 sm:text-sm lg:px-3 ${
                pathname === "/combos"
                  ? "bg-blue-50 text-blue-700 dark:bg-[#7C3AED]/25 dark:text-[#DDD6FE]"
                  : "text-slate-600 hover:bg-slate-100 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:bg-[#251D3A] dark:hover:text-[#F4F1FF]"
              }`}
            >
              <Sparkles className="h-3.5 w-3.5 shrink-0 sm:h-4 sm:w-4" aria-hidden="true" />
              <span className="hidden sm:inline">新着コンボ</span>
              <span className="sm:hidden">新着</span>
            </Link>

            <Link
              href="/my-note"
              className={`inline-flex items-center gap-1 rounded-lg px-1.5 py-1.5 text-[11px] font-medium transition-colors sm:gap-1.5 sm:px-2.5 sm:text-sm lg:px-3 ${
                pathname.startsWith("/my-note")
                  ? "bg-blue-50 text-blue-700 dark:bg-[#7C3AED]/25 dark:text-[#DDD6FE]"
                  : "text-slate-600 hover:bg-slate-100 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:bg-[#251D3A] dark:hover:text-[#F4F1FF]"
              }`}
            >
              <BookMarked className="h-3.5 w-3.5 shrink-0 sm:h-4 sm:w-4" aria-hidden="true" />
              <span className="hidden sm:inline">マイノート</span>
              <span className="sm:hidden">ノート</span>
            </Link>

            <Link
              href={newComboHref}
              className={`inline-flex items-center gap-1 rounded-lg px-1.5 py-1.5 text-[11px] font-medium transition-colors sm:gap-1.5 sm:px-2.5 sm:text-sm lg:px-3 ${
                pathname.startsWith("/combos/new")
                  ? "bg-blue-50 text-blue-700 dark:bg-[#7C3AED]/25 dark:text-[#DDD6FE]"
                  : "text-slate-600 hover:bg-slate-100 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:bg-[#251D3A] dark:hover:text-[#F4F1FF]"
              }`}
            >
              <PlusCircle className="h-3.5 w-3.5 shrink-0 sm:h-4 sm:w-4" aria-hidden="true" />
              <span className="hidden lg:inline">公開コンボ投稿</span>
              <span className="lg:hidden">投稿</span>
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
              className="inline-flex h-7 w-7 shrink-0 items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-600 transition-colors hover:bg-slate-100 hover:text-slate-900 sm:h-8 sm:w-8 dark:border-[#2E2447] dark:bg-[#251D3A] dark:text-[#DDD6FE] dark:hover:bg-[#30264A] dark:hover:text-white"
            >
              <Moon
                className="h-3.5 w-3.5 sm:h-4 sm:w-4 dark:hidden"
                aria-hidden="true"
              />
              <Sun
                className="hidden h-3.5 w-3.5 sm:h-4 sm:w-4 dark:block"
                aria-hidden="true"
              />
            </button>

            {!isLoading && user ? (
              <div className="flex items-center gap-1 sm:gap-1.5">
                {isAdmin && (
                  <span
                    title="管理者権限でログイン中"
                    aria-label="管理者権限（ADMIN）"
                    className="inline-flex shrink-0 items-center gap-1 rounded-md border border-amber-300/80 bg-amber-50 px-1 py-1 text-[10px] font-bold tracking-wider text-amber-800 sm:px-2 dark:border-amber-400/40 dark:bg-amber-500/20 dark:text-amber-200"
                  >
                    <Shield className="h-3 w-3 shrink-0" aria-hidden="true" />
                    <span className="hidden sm:inline">ADMIN</span>
                  </span>
                )}
                <div ref={accountMenuRef} className="relative">
                  <button
                    type="button"
                    onClick={() => setIsAccountMenuOpen((prev) => !prev)}
                    aria-label="アカウントメニュー"
                    aria-haspopup="menu"
                    aria-expanded={isAccountMenuOpen}
                    title="アカウントメニュー"
                    className={`inline-flex h-7 w-7 shrink-0 items-center justify-center rounded-lg border transition-colors sm:h-8 sm:w-8 ${
                      isAccountMenuOpen
                        ? "border-blue-300 bg-blue-50 text-blue-700 dark:border-[#8B5CF6] dark:bg-[#7C3AED]/25 dark:text-[#DDD6FE]"
                        : "border-slate-200 bg-white text-slate-600 hover:bg-slate-100 hover:text-slate-900 dark:border-[#2E2447] dark:bg-[#251D3A] dark:text-[#DDD6FE] dark:hover:bg-[#30264A] dark:hover:text-white"
                    }`}
                  >
                    <User
                      className="h-3.5 w-3.5 sm:h-4 sm:w-4"
                      aria-hidden="true"
                    />
                  </button>

                  {isAccountMenuOpen && (
                    <div
                      role="menu"
                      aria-label="アカウントメニュー"
                      className="absolute right-0 z-40 mt-2 w-44 overflow-hidden rounded-xl border border-slate-200 bg-white p-1.5 shadow-lg dark:border-[#3A2E58] dark:bg-[#1B152B] dark:shadow-black/40"
                    >
                      <div className="flex items-center gap-2 border-b border-slate-100 px-2.5 py-2 text-xs font-semibold text-slate-700 dark:border-[#2E2447] dark:text-[#E2DCF5]">
                        <span
                          className="h-2 w-2 shrink-0 rounded-full bg-emerald-500 dark:bg-emerald-400"
                          aria-hidden="true"
                        />
                        <span>ログイン中</span>
                      </div>
                      <button
                        type="button"
                        role="menuitem"
                        onClick={handleLogout}
                        className="mt-1 flex w-full items-center gap-2 rounded-lg px-2.5 py-2 text-left text-xs font-medium text-slate-700 transition-colors hover:bg-rose-50 hover:text-rose-700 dark:text-[#E2DCF5] dark:hover:bg-rose-500/15 dark:hover:text-rose-200"
                      >
                        <LogOut
                          className="h-3.5 w-3.5 shrink-0"
                          aria-hidden="true"
                        />
                        <span>ログアウト</span>
                      </button>
                    </div>
                  )}
                </div>
              </div>
            ) : (
              <Link
                href={
                  pathname && pathname !== "/login"
                    ? `/login?next=${encodeURIComponent(pathname)}`
                    : "/login"
                }
                aria-label="ログイン"
                className={`inline-flex items-center gap-1.5 rounded-lg border px-1.5 py-1.5 text-xs font-medium transition-colors sm:px-2.5 sm:text-sm lg:px-3 ${
                  pathname === "/login"
                    ? "border-blue-200 bg-blue-50 text-blue-700 dark:border-[#8B5CF6]/50 dark:bg-[#7C3AED]/25 dark:text-[#DDD6FE]"
                    : "border-slate-200 bg-white text-slate-700 hover:bg-slate-50 dark:border-[#2E2447] dark:bg-[#1B152B] dark:text-[#E2DCF5] dark:hover:bg-[#251D3A]"
                }`}
              >
                <LogIn className="h-3.5 w-3.5 shrink-0 sm:h-4 sm:w-4" aria-hidden="true" />
                <span className="hidden md:inline">ログイン</span>
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
