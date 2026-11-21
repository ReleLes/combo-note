"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  ArrowLeft,
  ChevronDown,
  ChevronUp,
  RotateCcw,
  SlidersHorizontal,
  X,
} from "lucide-react";
import type {
  Character,
  Combo,
  ComboCategory,
  GameVersion,
  Move,
  SituationDefinition,
} from "@/types/combo";
import { COMBO_CATEGORIES } from "@/data/seed/common";
import { usePreferences, useSavedCombos } from "@/hooks/useComboNoteStorage";
import { ComboCard } from "./ComboCard";
import { ComboDetailModal } from "./ComboDetailModal";

type SortKey = "popular" | "newest" | "damage";

interface CharacterComboListClientProps {
  character: Character;
  allCharacters: Character[];
  combos: Combo[];
  moveMap: Record<string, Move>;
  situations: SituationDefinition[];
  versions: GameVersion[];
}

export function CharacterComboListClient({
  character,
  allCharacters,
  combos,
  moveMap,
  situations,
  versions,
}: CharacterComboListClientProps) {
  const router = useRouter();

  // 上部コントロール状態（LocalStorage永続化）
  const { controlType, notationMode, setControlType, setNotationMode } =
    usePreferences();
  const { isSaved, toggleSavedCombo } = useSavedCombos();

  // 絞り込み・並び替え状態
  const [selectedSituations, setSelectedSituations] = useState<string[]>([]);
  const [onlyStockGain, setOnlyStockGain] = useState(false);
  const [selectedStockCosts, setSelectedStockCosts] = useState<number[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<
    ComboCategory | "all"
  >("all");
  const [isAdvancedOpen, setIsAdvancedOpen] = useState(false);
  const [maxDriveCost, setMaxDriveCost] = useState<number | "all">("all");
  const [saCostFilter, setSaCostFilter] = useState<number | "all">("all");
  const [onlyOki, setOnlyOki] = useState(false);
  const [sortBy, setSortBy] = useState<SortKey>("popular");

  // 詳細モーダル・通知トースト
  const [activeCombo, setActiveCombo] = useState<Combo | null>(null);
  const [notice, setNotice] = useState<string | null>(null);

  useEffect(() => {
    if (!notice) return;
    const timer = window.setTimeout(() => setNotice(null), 2600);
    return () => window.clearTimeout(timer);
  }, [notice]);

  const situationMap = useMemo(() => {
    const map: Record<string, SituationDefinition> = {};
    for (const s of situations) {
      map[s.key] = s;
    }
    return map;
  }, [situations]);

  const versionMap = useMemo(() => {
    const map: Record<string, GameVersion> = {};
    for (const v of versions) {
      map[v.id] = v;
    }
    return map;
  }, [versions]);

  const toggleSituation = (key: string) => {
    setSelectedSituations((prev) =>
      prev.includes(key) ? prev.filter((item) => item !== key) : [...prev, key]
    );
  };

  const toggleStockCost = (count: number) => {
    setSelectedStockCosts((prev) =>
      prev.includes(count)
        ? prev.filter((item) => item !== count)
        : [...prev, count]
    );
  };

  const resetFilters = () => {
    setSelectedSituations([]);
    setOnlyStockGain(false);
    setSelectedStockCosts([]);
    setSelectedCategory("all");
    setMaxDriveCost("all");
    setSaCostFilter("all");
    setOnlyOki(false);
  };

  const hasActiveFilters =
    selectedSituations.length > 0 ||
    onlyStockGain ||
    selectedStockCosts.length > 0 ||
    selectedCategory !== "all" ||
    maxDriveCost !== "all" ||
    saCostFilter !== "all" ||
    onlyOki;

  const filteredCombos = useMemo(() => {
    const filtered = combos.filter((combo) => {
      if (combo.controlType !== controlType) return false;

      if (
        selectedSituations.length > 0 &&
        !selectedSituations.some((sit) => combo.situations.includes(sit))
      ) {
        return false;
      }

      if (onlyStockGain && (combo.stockGain ?? 0) <= 0) {
        return false;
      }

      if (
        selectedStockCosts.length > 0 &&
        !selectedStockCosts.includes(combo.stockCost ?? 0)
      ) {
        return false;
      }

      if (selectedCategory !== "all" && combo.category !== selectedCategory) {
        return false;
      }

      if (maxDriveCost !== "all" && combo.driveCost > maxDriveCost) {
        return false;
      }

      if (saCostFilter !== "all" && combo.saCost !== saCostFilter) {
        return false;
      }

      if (onlyOki && !combo.hasOki) {
        return false;
      }

      return true;
    });

    return [...filtered].sort((a, b) => {
      switch (sortBy) {
        case "popular":
          return b.likesCount - a.likesCount;
        case "newest":
          return (
            new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
          );
        case "damage":
          return (b.damage ?? 0) - (a.damage ?? 0);
      }
    });
  }, [
    combos,
    controlType,
    selectedSituations,
    onlyStockGain,
    selectedStockCosts,
    selectedCategory,
    maxDriveCost,
    saCostFilter,
    onlyOki,
    sortBy,
  ]);

  const handleToggleSave = (comboId: string) => {
    const added = toggleSavedCombo(comboId);
    setNotice(
      added ? "マイノートに保存しました。" : "マイノートから解除しました。"
    );
  };

  const handlePlaceholderAction = (featureName: string) => {
    setNotice(`「${featureName}」機能は準備中です。今後のフェーズで実装予定です。`);
  };

  return (
    <div className="mx-auto w-full max-w-5xl px-3 py-4 sm:px-6 sm:py-6">
      {/* キャラヘッダー & キャラ切替 */}
      <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-2.5">
          <Link
            href="/"
            className="inline-flex items-center gap-1 rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-xs font-medium text-slate-600 transition-colors hover:bg-slate-100 hover:text-slate-900"
          >
            <ArrowLeft className="h-3.5 w-3.5" aria-hidden="true" />
            <span>一覧</span>
          </Link>
          <div>
            <h1 className="text-xl font-bold tracking-tight text-slate-900 sm:text-2xl">
              {character.nameJa}
            </h1>
            <p className="text-xs text-slate-500">{character.nameEn}</p>
          </div>
        </div>

        <label className="flex items-center gap-2 text-xs font-medium text-slate-600">
          <span className="hidden sm:inline">キャラ切替</span>
          <select
            aria-label="キャラクターを切り替え"
            value={character.slug}
            onChange={(e) => router.push(`/characters/${e.target.value}`)}
            className="rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-sm font-medium text-slate-900 shadow-2xs focus:border-blue-500 focus:outline-none"
          >
            {allCharacters.map((c) => (
              <option key={c.id} value={c.slug}>
                {c.nameJa}
              </option>
            ))}
          </select>
        </label>
      </div>

      {/* 上部コントロールバー：操作タイプ切替 + 3表記切替 */}
      <section
        aria-label="表示設定"
        className="sticky top-14 z-20 -mx-3 mb-4 border-y border-slate-200 bg-slate-50/95 px-3 py-2.5 backdrop-blur sm:mx-0 sm:rounded-xl sm:border sm:bg-white sm:px-4 sm:py-3 sm:shadow-xs"
      >
        <div className="flex flex-col gap-2.5 sm:flex-row sm:items-center sm:justify-between">
          {/* 操作タイプ切替タブ */}
          <div className="flex items-center gap-2">
            <span className="shrink-0 text-[11px] font-semibold text-slate-500 sm:text-xs">
              操作
            </span>
            <div
              role="tablist"
              aria-label="操作タイプ切替"
              className="grid flex-1 grid-cols-2 rounded-lg bg-slate-200/75 p-0.5 sm:flex-initial"
            >
              {(
                [
                  { value: "classic", label: "クラシック" },
                  { value: "modern", label: "モダン" },
                ] as const
              ).map((item) => (
                <button
                  key={item.value}
                  type="button"
                  role="tab"
                  aria-selected={controlType === item.value}
                  onClick={() => setControlType(item.value)}
                  className={`rounded-md px-3 py-1.5 text-xs font-semibold transition-all sm:px-4 ${
                    controlType === item.value
                      ? "bg-white text-blue-700 shadow-xs"
                      : "text-slate-600 hover:text-slate-900"
                  }`}
                >
                  {item.label}
                </button>
              ))}
            </div>
          </div>

          {/* 3表記切替セグメント */}
          <div className="flex items-center gap-2">
            <span className="shrink-0 text-[11px] font-semibold text-slate-500 sm:text-xs">
              表記
            </span>
            <div
              role="tablist"
              aria-label="レシピ表記モード切替"
              className="grid flex-1 grid-cols-3 rounded-lg bg-slate-200/75 p-0.5 sm:flex-initial"
            >
              {(
                [
                  { value: "numpad", label: "テンキー" },
                  { value: "command", label: "コマンド" },
                  { value: "name", label: "技名" },
                ] as const
              ).map((item) => (
                <button
                  key={item.value}
                  type="button"
                  role="tab"
                  aria-selected={notationMode === item.value}
                  onClick={() => setNotationMode(item.value)}
                  className={`rounded-md px-2.5 py-1.5 text-xs font-semibold transition-all sm:px-3.5 ${
                    notationMode === item.value
                      ? "bg-blue-600 text-white shadow-xs"
                      : "text-slate-600 hover:text-slate-900"
                  }`}
                >
                  {item.label}
                </button>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* 絞り込み・並び替えエリア */}
      <section
        aria-label="検索・絞り込み"
        className="mb-5 space-y-3 rounded-xl border border-slate-200 bg-white p-3.5 shadow-xs sm:p-4"
      >
        {/* 状況フィルタチップ */}
        <div>
          <div className="mb-2 flex items-center justify-between">
            <span className="text-xs font-bold text-slate-700">状況で絞る</span>
            {(selectedSituations.length > 0 ||
              onlyStockGain ||
              selectedStockCosts.length > 0) && (
              <button
                type="button"
                onClick={() => {
                  setSelectedSituations([]);
                  setOnlyStockGain(false);
                  setSelectedStockCosts([]);
                }}
                className="text-xs font-medium text-blue-600 hover:underline"
              >
                状況をクリア
              </button>
            )}
          </div>
          <div className="flex flex-wrap gap-1.5">
            {situations.map((sit) => {
              const isSelected = selectedSituations.includes(sit.key);
              return (
                <button
                  key={sit.key}
                  type="button"
                  onClick={() => toggleSituation(sit.key)}
                  aria-pressed={isSelected}
                  className={`inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold transition-all ${
                    isSelected
                      ? `${sit.badgeClassName} ring-2 ring-blue-600 ring-offset-1`
                      : "border border-slate-200 bg-slate-50 text-slate-600 hover:bg-slate-100"
                  }`}
                >
                  {sit.label}
                </button>
              );
            })}

            {/* キャラ固有ストック絞り込み（獲得・始動ストック数） */}
            {character.stockMeta && (
              <>
                <button
                  type="button"
                  onClick={() => setOnlyStockGain((prev) => !prev)}
                  aria-pressed={onlyStockGain}
                  className={`inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold transition-all ${
                    onlyStockGain
                      ? "bg-cyan-100 text-cyan-800 ring-2 ring-blue-600 ring-offset-1"
                      : "border border-cyan-200 bg-cyan-50/70 text-cyan-700 hover:bg-cyan-100/70"
                  }`}
                >
                  {character.stockMeta.shortLabel}獲得
                </button>

                {Array.from(
                  { length: character.stockMeta.maxCount },
                  (_, i) => i + 1
                ).map((count) => {
                  const isSelected = selectedStockCosts.includes(count);
                  const isMax = count === character.stockMeta?.maxCount;
                  const label = isMax
                    ? `${character.stockMeta?.shortLabel}最大(${count}個)`
                    : `${character.stockMeta?.shortLabel}${count}個`;
                  return (
                    <button
                      key={`stock-cost-${count}`}
                      type="button"
                      onClick={() => toggleStockCost(count)}
                      aria-pressed={isSelected}
                      className={`inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold transition-all ${
                        isSelected
                          ? "bg-pink-100 text-pink-800 ring-2 ring-blue-600 ring-offset-1"
                          : "border border-pink-200 bg-pink-50/70 text-pink-700 hover:bg-pink-100/70"
                      }`}
                    >
                      {label}
                    </button>
                  );
                })}
              </>
            )}
          </div>
        </div>

        {/* カテゴリフィルタ + 詳細条件トグル */}
        <div className="flex flex-wrap items-center justify-between gap-2 border-t border-slate-100 pt-3">
          <div className="flex flex-wrap items-center gap-1.5">
            <button
              type="button"
              onClick={() => setSelectedCategory("all")}
              className={`rounded-lg px-2.5 py-1 text-xs font-medium transition-colors ${
                selectedCategory === "all"
                  ? "bg-slate-900 text-white"
                  : "bg-slate-100 text-slate-600 hover:bg-slate-200"
              }`}
            >
              すべて
            </button>
            {COMBO_CATEGORIES.map((cat) => (
              <button
                key={cat.key}
                type="button"
                onClick={() => setSelectedCategory(cat.key)}
                className={`rounded-lg px-2.5 py-1 text-xs font-medium transition-colors ${
                  selectedCategory === cat.key
                    ? "bg-slate-900 text-white"
                    : "bg-slate-100 text-slate-600 hover:bg-slate-200"
                }`}
              >
                {cat.label}
              </button>
            ))}
          </div>

          <button
            type="button"
            onClick={() => setIsAdvancedOpen((prev) => !prev)}
            aria-expanded={isAdvancedOpen}
            className="inline-flex items-center gap-1 rounded-lg border border-slate-200 bg-white px-2.5 py-1 text-xs font-medium text-slate-700 transition-colors hover:bg-slate-50"
          >
            <SlidersHorizontal className="h-3.5 w-3.5" aria-hidden="true" />
            <span>詳細条件</span>
            {isAdvancedOpen ? (
              <ChevronUp className="h-3.5 w-3.5" aria-hidden="true" />
            ) : (
              <ChevronDown className="h-3.5 w-3.5" aria-hidden="true" />
            )}
          </button>
        </div>

        {/* 折りたたみ式：詳細条件フィルタ */}
        {isAdvancedOpen && (
          <div className="grid grid-cols-1 gap-3 rounded-lg border border-slate-200 bg-slate-50 p-3 sm:grid-cols-3">
            <label className="flex flex-col gap-1 text-xs font-medium text-slate-700">
              <span>消費Dゲージ上限</span>
              <select
                value={maxDriveCost === "all" ? "all" : String(maxDriveCost)}
                onChange={(e) =>
                  setMaxDriveCost(
                    e.target.value === "all" ? "all" : Number(e.target.value)
                  )
                }
                className="rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-xs text-slate-900"
              >
                <option value="all">指定なし</option>
                {[0, 1, 2, 3, 4, 5, 6].map((n) => (
                  <option key={n} value={n}>
                    {n === 0 ? "0本（ノーゲージ）" : `${n}本以下`}
                  </option>
                ))}
              </select>
            </label>

            <label className="flex flex-col gap-1 text-xs font-medium text-slate-700">
              <span>消費SAゲージ</span>
              <select
                value={saCostFilter === "all" ? "all" : String(saCostFilter)}
                onChange={(e) =>
                  setSaCostFilter(
                    e.target.value === "all" ? "all" : Number(e.target.value)
                  )
                }
                className="rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-xs text-slate-900"
              >
                <option value="all">指定なし</option>
                {[0, 1, 2, 3].map((n) => (
                  <option key={n} value={n}>
                    SA {n}
                  </option>
                ))}
              </select>
            </label>

            <label className="flex cursor-pointer items-center gap-2 self-end rounded-lg border border-slate-200 bg-white px-3 py-2 text-xs font-medium text-slate-700">
              <input
                type="checkbox"
                checked={onlyOki}
                onChange={(e) => setOnlyOki(e.target.checked)}
                className="h-4 w-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500"
              />
              <span>起き攻めありのみ</span>
            </label>
          </div>
        )}
      </section>

      {/* 件数・並び替えバー */}
      <div className="mb-3 flex flex-wrap items-center justify-between gap-2">
        <div className="flex items-center gap-2 text-xs text-slate-600 sm:text-sm">
          <span>
            <strong className="font-bold text-slate-900">
              {filteredCombos.length}
            </strong>{" "}
            件のコンボ
          </span>
          {hasActiveFilters && (
            <button
              type="button"
              onClick={resetFilters}
              className="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-medium text-blue-600 hover:bg-blue-50"
            >
              <RotateCcw className="h-3 w-3" aria-hidden="true" />
              条件リセット
            </button>
          )}
        </div>

        <label className="flex items-center gap-1.5 text-xs text-slate-600">
          <span>並び替え:</span>
          <select
            aria-label="コンボの並び替え"
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as SortKey)}
            className="rounded-lg border border-slate-200 bg-white px-2.5 py-1 text-xs font-medium text-slate-800 focus:border-blue-500 focus:outline-none"
          >
            <option value="popular">人気順</option>
            <option value="newest">新着順</option>
            <option value="damage">ダメージ高い順</option>
          </select>
        </label>
      </div>

      {/* コンボ一覧 */}
      {filteredCombos.length > 0 ? (
        <div className="space-y-3">
          {filteredCombos.map((combo) => (
            <ComboCard
              key={combo.id}
              combo={combo}
              moveMap={moveMap}
              situationMap={situationMap}
              version={versionMap[combo.versionId]}
              stockMeta={character.stockMeta}
              notationMode={notationMode}
              isSaved={isSaved(combo.id)}
              onToggleSave={handleToggleSave}
              onSelect={setActiveCombo}
              onPlaceholderAction={handlePlaceholderAction}
            />
          ))}
        </div>
      ) : (
        <div className="rounded-xl border border-dashed border-slate-300 bg-white px-4 py-12 text-center">
          <p className="text-sm font-medium text-slate-700">
            条件に一致するコンボが見つかりませんでした。
          </p>
          <p className="mt-1 text-xs text-slate-500">
            操作タイプや絞り込み条件を変更してお試しください。
          </p>
          {hasActiveFilters && (
            <button
              type="button"
              onClick={resetFilters}
              className="mt-4 inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-3.5 py-2 text-xs font-semibold text-white transition-colors hover:bg-blue-700"
            >
              <RotateCcw className="h-3.5 w-3.5" aria-hidden="true" />
              絞り込みをリセット
            </button>
          )}
        </div>
      )}

      {/* 詳細モーダル */}
      <ComboDetailModal
        combo={activeCombo}
        moveMap={moveMap}
        situationMap={situationMap}
        version={activeCombo ? versionMap[activeCombo.versionId] : undefined}
        stockMeta={character.stockMeta}
        notationMode={notationMode}
        isSaved={activeCombo ? isSaved(activeCombo.id) : false}
        onToggleSave={handleToggleSave}
        onChangeNotationMode={setNotationMode}
        onClose={() => setActiveCombo(null)}
      />

      {/* 準備中トースト */}
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
    </div>
  );
}
