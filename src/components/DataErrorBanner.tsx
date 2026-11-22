"use client";

import { useRouter } from "next/navigation";
import { AlertCircle, RefreshCw } from "lucide-react";

interface DataErrorBannerProps {
  title?: string;
  message?: string;
}

export function DataErrorBanner({
  title = "データの読み込みに失敗しました",
  message = "時間をおいて再度お試しください。ネットワーク接続やSupabase設定をご確認ください。",
}: DataErrorBannerProps) {
  const router = useRouter();

  return (
    <div className="mx-auto w-full max-w-2xl px-3 py-10 sm:px-6">
      <div
        role="alert"
        className="rounded-xl border border-rose-200 bg-white p-6 text-center shadow-xs dark:border-rose-400/35 dark:bg-[#1B152B]"
      >
        <div className="mx-auto mb-3 flex h-10 w-10 items-center justify-center rounded-full bg-rose-50 text-rose-600 dark:bg-rose-500/20 dark:text-rose-300">
          <AlertCircle className="h-5 w-5" aria-hidden="true" />
        </div>
        <h2 className="text-base font-bold text-slate-900 dark:text-[#F4F1FF]">{title}</h2>
        <p className="mt-1.5 text-xs leading-relaxed text-slate-600 sm:text-sm dark:text-[#A99EC4]">
          {message}
        </p>
        <button
          type="button"
          onClick={() => router.refresh()}
          className="mt-4 inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-4 py-2 text-xs font-semibold text-white transition-colors hover:bg-blue-700 sm:text-sm dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
        >
          <RefreshCw className="h-4 w-4" aria-hidden="true" />
          <span>再読み込み</span>
        </button>
      </div>
    </div>
  );
}
