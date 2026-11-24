export default function RecentCombosLoading() {
  return (
    <div className="mx-auto w-full max-w-5xl animate-pulse px-3 py-4 sm:px-6 sm:py-6">
      <div className="mb-4 flex items-center gap-3">
        <div className="h-8 w-16 rounded-lg bg-slate-200 dark:bg-[#251D3A]" />
        <div className="h-8 w-44 rounded-lg bg-slate-200 dark:bg-[#251D3A]" />
      </div>
      <div className="mb-4 h-16 rounded-xl border border-slate-200 bg-white dark:border-[#2E2447] dark:bg-[#1B152B]" />
      <div className="mb-5 h-28 rounded-xl border border-slate-200 bg-white dark:border-[#2E2447] dark:bg-[#1B152B]" />
      <div className="space-y-3">
        {Array.from({ length: 4 }).map((_, i) => (
          <div
            key={i}
            className="h-44 rounded-xl border border-slate-200 bg-white p-4 dark:border-[#2E2447] dark:bg-[#1B152B]"
          >
            <div className="mb-3 flex items-center justify-between border-b border-slate-100 pb-2 dark:border-[#2E2447]">
              <div className="flex items-center gap-2">
                <div className="h-6 w-6 rounded-full bg-slate-200 dark:bg-[#30264A]" />
                <div className="h-4 w-20 rounded bg-slate-200 dark:bg-[#30264A]" />
              </div>
              <div className="h-3.5 w-14 rounded bg-slate-100 dark:bg-[#251D3A]" />
            </div>
            <div className="flex gap-2">
              <div className="h-5 w-16 rounded bg-slate-200 dark:bg-[#30264A]" />
              <div className="h-5 w-20 rounded bg-slate-100 dark:bg-[#251D3A]" />
            </div>
            <div className="mt-3 h-12 rounded-lg bg-slate-100 dark:bg-[#140F23]" />
          </div>
        ))}
      </div>
    </div>
  );
}
