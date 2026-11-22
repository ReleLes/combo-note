export default function MyNoteLoading() {
  return (
    <div className="mx-auto w-full max-w-5xl animate-pulse px-3 py-4 sm:px-6 sm:py-6">
      <div className="mb-4 flex items-center justify-between">
        <div className="h-8 w-36 rounded-lg bg-slate-200 dark:bg-[#251D3A]" />
        <div className="h-9 w-36 rounded-lg bg-slate-200 dark:bg-[#251D3A]" />
      </div>
      <div className="mb-4 grid grid-cols-2 gap-1.5 rounded-xl border border-slate-200 bg-white p-1.5 sm:grid-cols-4 dark:border-[#2E2447] dark:bg-[#1B152B]">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="h-9 rounded-lg bg-slate-100 dark:bg-[#251D3A]" />
        ))}
      </div>
      <div className="space-y-3">
        {Array.from({ length: 2 }).map((_, i) => (
          <div
            key={i}
            className="h-36 rounded-xl border border-slate-200 bg-white p-4 dark:border-[#2E2447] dark:bg-[#1B152B]"
          >
            <div className="h-5 w-24 rounded bg-slate-200 dark:bg-[#30264A]" />
            <div className="mt-3 h-12 rounded-lg bg-slate-100 dark:bg-[#140F23]" />
          </div>
        ))}
      </div>
    </div>
  );
}
