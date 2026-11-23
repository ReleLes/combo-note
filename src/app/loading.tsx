export default function HomeLoading() {
  return (
    <div className="mx-auto w-full max-w-5xl animate-pulse px-3 py-6 sm:px-6 sm:py-10 xl:max-w-6xl">
      <div className="mb-6 space-y-2 sm:mb-8">
        <div className="h-8 w-52 rounded-lg bg-slate-200 dark:bg-[#251D3A]" />
        <div className="h-4 w-72 rounded bg-slate-200 dark:bg-[#251D3A]" />
      </div>
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 sm:gap-4 lg:grid-cols-4 xl:grid-cols-5">
        {Array.from({ length: 5 }).map((_, i) => (
          <div
            key={i}
            className="flex aspect-[3/4] min-h-[240px] flex-col justify-end rounded-2xl border border-slate-200 bg-slate-200/80 p-3.5 sm:min-h-[300px] dark:border-[#2E2447] dark:bg-[#1B152B]"
          >
            <div className="h-5 w-24 rounded bg-slate-300/80 dark:bg-[#30264A]" />
            <div className="mt-1.5 h-3 w-16 rounded bg-slate-300/60 dark:bg-[#251D3A]" />
            <div className="mt-3 h-4 w-20 rounded bg-slate-300/60 dark:bg-[#251D3A]" />
            <div className="mt-3 h-3 w-full rounded bg-slate-300/60 dark:bg-[#251D3A]" />
          </div>
        ))}
      </div>
    </div>
  );
}
