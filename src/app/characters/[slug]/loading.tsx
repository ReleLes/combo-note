export default function CharacterCombosLoading() {
  return (
    <div className="mx-auto w-full max-w-5xl animate-pulse px-3 py-4 sm:px-6 sm:py-6">
      <div className="mb-4 flex items-center justify-between">
        <div className="h-8 w-40 rounded-lg bg-slate-200 dark:bg-[#251D3A]" />
        <div className="h-9 w-32 rounded-lg bg-slate-200 dark:bg-[#251D3A]" />
      </div>
      <div className="mb-4 h-16 rounded-xl border border-slate-200 bg-white dark:border-[#2E2447] dark:bg-[#1B152B]" />
      <div className="mb-5 h-28 rounded-xl border border-slate-200 bg-white dark:border-[#2E2447] dark:bg-[#1B152B]" />
      <div className="space-y-3">
        {Array.from({ length: 3 }).map((_, i) => (
          <div
            key={i}
            className="h-40 rounded-xl border border-slate-200 bg-white p-4 dark:border-[#2E2447] dark:bg-[#1B152B]"
          >
            <div className="flex gap-2">
              <div className="h-5 w-16 rounded bg-slate-200 dark:bg-[#30264A]" />
              <div className="h-5 w-20 rounded bg-slate-100 dark:bg-[#251D3A]" />
            </div>
            <div className="mt-3 h-12 rounded-lg bg-slate-100 dark:bg-[#140F23]" />
            <div className="mt-3 h-4 w-2/3 rounded bg-slate-100 dark:bg-[#251D3A]" />
          </div>
        ))}
      </div>
    </div>
  );
}
