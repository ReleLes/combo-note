export default function HomeLoading() {
  return (
    <div className="mx-auto w-full max-w-5xl animate-pulse px-3 py-6 sm:px-6 sm:py-10">
      <div className="mb-6 space-y-2 sm:mb-8">
        <div className="h-8 w-52 rounded-lg bg-slate-200 dark:bg-[#251D3A]" />
        <div className="h-4 w-72 rounded bg-slate-200 dark:bg-[#251D3A]" />
      </div>
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <div
            key={i}
            className="h-36 rounded-xl border border-slate-200 bg-white p-4 dark:border-[#2E2447] dark:bg-[#1B152B]"
          >
            <div className="h-5 w-24 rounded bg-slate-200 dark:bg-[#30264A]" />
            <div className="mt-2 h-3 w-16 rounded bg-slate-100 dark:bg-[#251D3A]" />
            <div className="mt-8 h-3 w-full rounded bg-slate-100 dark:bg-[#251D3A]" />
          </div>
        ))}
      </div>
    </div>
  );
}
