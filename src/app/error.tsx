"use client";

import { useEffect } from "react";
import Link from "next/link";
import { AlertCircle, Home, RefreshCw } from "lucide-react";

interface GlobalErrorProps {
  error: Error & { digest?: string };
  reset: () => void;
}

export default function GlobalError({ error, reset }: GlobalErrorProps) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <div className="mx-auto flex w-full max-w-lg flex-1 items-center justify-center px-4 py-16">
      <div
        role="alert"
        className="w-full rounded-2xl border border-rose-200 bg-white p-6 text-center shadow-xs sm:p-8 dark:border-rose-400/35 dark:bg-[#1B152B]"
      >
        <div className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-rose-50 text-rose-600 dark:bg-rose-500/20 dark:text-rose-300">
          <AlertCircle className="h-6 w-6" aria-hidden="true" />
        </div>
        <h1 className="text-lg font-bold text-slate-900 dark:text-[#F4F1FF]">
          画面の表示中にエラーが発生しました
        </h1>
        <p className="mt-2 text-xs leading-relaxed text-slate-600 sm:text-sm dark:text-[#A99EC4]">
          一時的な通信エラーの可能性があります。再試行するか、トップページへ戻ってお試しください。
        </p>

        <div className="mt-6 flex flex-wrap items-center justify-center gap-2.5">
          <button
            type="button"
            onClick={() => reset()}
            className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-4 py-2 text-xs font-semibold text-white shadow-xs transition-colors hover:bg-blue-700 sm:text-sm dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
          >
            <RefreshCw className="h-4 w-4" aria-hidden="true" />
            <span>再試行する</span>
          </button>
          <Link
            href="/"
            className="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-700 transition-colors hover:bg-slate-50 sm:text-sm dark:border-[#2E2447] dark:bg-[#251D3A] dark:text-[#E2DCF5] dark:hover:bg-[#30264A]"
          >
            <Home className="h-4 w-4" aria-hidden="true" />
            <span>トップへ戻る</span>
          </Link>
        </div>
      </div>
    </div>
  );
}
