"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  ArrowLeft,
  Loader2,
  RotateCcw,
  Sparkles,
  X,
} from "lucide-react";
import type {
  Character,
  Combo,
  ControlType,
  GameVersion,
  Move,
  SituationDefinition,
} from "@/types/combo";
import {
  deleteCombo,
  fetchClientMovesForCharacters,
  fetchClientRecentCombosPage,
} from "@/lib/supabase/clientQueries";
import { useAuth } from "@/components/AuthProvider";
import { usePreferences, useSavedCombos } from "@/hooks/useComboNoteStorage";
import { useComboLikes } from "@/hooks/useComboLikes";
import { ComboCard } from "./ComboCard";
import { ComboDetailModal } from "./ComboDetailModal";
import { DeleteComboConfirmModal } from "./DeleteComboConfirmModal";

const PAGE_SIZE = 20;

type ControlTypeFilter = "all" | ControlType;

interface RecentComboListClientProps {
  characters: Character[];
  characterImageMap: Record<string, string | null>;
  initialCombos: Combo[];
  initialHasMore: boolean;
  initialMoveMap: Record<string, Move>;
  initialLoadedCharacterIds: string[];
  commonSituations: SituationDefinition[];
  allSituations: SituationDefinition[];
  versions: GameVersion[];
}

export function RecentComboListClient({
  characters,
  characterImageMap,
  initialCombos,
  initialHasMore,
  initialMoveMap,
  initialLoadedCharacterIds,
  commonSituations,
  allSituations,
  versions,
}: RecentComboListClientProps) {
  const router = useRouter();
  const { user, isAdmin } = useAuth();
  const { notationMode, setControlType, setNotationMode } = usePreferences();
  const { isSaved, toggleSavedCombo, removeSavedCombo } = useSavedCombos();

  // 一覧データ＆技マスタキャッシュ（必要キャラ分のみ増分取得）
  const [combos, setCombos] = useState<Combo[]>(initialCombos);
  const [hasMore, setHasMore] = useState<boolean>(initialHasMore);
  const [moveMap, setMoveMap] = useState<Record<string, Move>>(initialMoveMap);
  const loadedMoveCharIdsRef = useRef<Set<string>>(
    new Set(initialLoadedCharacterIds)
  );
  const requestSeqRef = useRef(0);

  // 絞り込み条件
  const [selectedControlType, setSelectedControlType] =
    useState<ControlTypeFilter>("all");
  const [selectedCharacterId, setSelectedCharacterId] = useState<string>("all");
  const [selectedSituations, setSelectedSituations] = useState<string[]>([]);

  // ローディング・エラー状態
  const [isFilteringLoading, setIsFilteringLoading] = useState(false);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [fetchError, setFetchError] = useState<string | null>(null);

  // いいね・削除・モーダル・通知状態
  const { isLiked, getLikesCount, toggleLike } = useComboLikes(combos);
  const [deletedIds, setDeletedIds] = useState<Set<string>>(() => new Set());
  const [deleteTargetCombo, setDeleteTargetCombo] = useState<Combo | null>(
    null
  );
  const [deleteError, setDeleteError] = useState<string | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);
  const [activeCombo, setActiveCombo] = useState<Combo | null>(null);
  const [notice, setNotice] = useState<{
    message: string;
    showLoginLink?: boolean;
  } | null>(null);

  useEffect(() => {
    if (!notice) return;
    const timer = window.setTimeout(
      () => setNotice(null),
      notice.showLoginLink ? 5000 : 2600
    );
    return () => window.clearTimeout(timer);
  }, [notice]);

  const characterMap = useMemo(() => {
    const map: Record<string, Character> = {};
    for (const c of characters) {
      map[c.id] = c;
    }
    return map;
  }, [characters]);

  const groupedCommonSituations = useMemo(() => {
    return {
      basic: commonSituations.filter((s) => s.group === "basic"),
      purpose: commonSituations.filter((s) => s.group === "purpose"),
    };
  }, [commonSituations]);

  const situationMap = useMemo(() => {
    const map: Record<string, SituationDefinition> = {};
    for (const s of allSituations) {
      map[s.key] = s;
    }
    return map;
  }, [allSituations]);

  const versionMap = useMemo(() => {
    const map: Record<string, GameVersion> = {};
    for (const v of versions) {
      map[v.id] = v;
    }
    return map;
  }, [versions]);

  /**
   * 取得したコンボ群に含まれる未取得キャラの技マスタのみ追加取得してマージする。
   */
  const ensureMovesForCombos = useCallback(async (targetCombos: Combo[]) => {
    const missingCharIds = Array.from(
      new Set(
        targetCombos
          .map((c) => c.characterId)
          .filter((id) => id && !loadedMoveCharIdsRef.current.has(id))
      )
    );
    if (missingCharIds.length === 0) return;

    const fetchedMoves = await fetchClientMovesForCharacters(missingCharIds);
    for (const id of missingCharIds) {
      loadedMoveCharIdsRef.current.add(id);
    }

    setMoveMap((prev) => {
      const next = { ...prev };
      for (const move of fetchedMoves) {
        next[move.id] = move;
      }
      return next;
    });
  }, []);

  /**
   * 指定フィルタ条件で1ページ目（先頭20件）を再取得する。
   */
  const reloadFirstPage = useCallback(
    async (filters: {
      controlType: ControlTypeFilter;
      characterId: string;
      situations: string[];
    }) => {
      const seq = ++requestSeqRef.current;
      setIsFilteringLoading(true);
      setFetchError(null);

      try {
        const result = await fetchClientRecentCombosPage({
          limit: PAGE_SIZE,
          offset: 0,
          characterId: filters.characterId,
          controlType: filters.controlType,
          situations: filters.situations,
        });

        if (seq !== requestSeqRef.current) return;

        await ensureMovesForCombos(result.combos);
        if (seq !== requestSeqRef.current) return;

        setCombos(result.combos);
        setHasMore(result.hasMore);
      } catch (err) {
        if (seq !== requestSeqRef.current) return;
        const message =
          err instanceof Error
            ? err.message
            : "新着コンボの読み込みに失敗しました。";
        setFetchError(message);
      } finally {
        if (seq === requestSeqRef.current) {
          setIsFilteringLoading(false);
        }
      }
    },
    [ensureMovesForCombos]
  );

  /**
   * 次の20件を追加読み込みする。
   */
  const handleLoadMore = async () => {
    if (isLoadingMore || isFilteringLoading || !hasMore) return;

    const seq = ++requestSeqRef.current;
    setIsLoadingMore(true);
    setFetchError(null);

    try {
      const result = await fetchClientRecentCombosPage({
        limit: PAGE_SIZE,
        offset: combos.length,
        characterId: selectedCharacterId,
        controlType: selectedControlType,
        situations: selectedSituations,
      });

      if (seq !== requestSeqRef.current) return;

      await ensureMovesForCombos(result.combos);
      if (seq !== requestSeqRef.current) return;

      setCombos((prev) => {
        const existingIds = new Set(prev.map((c) => c.id));
        const uniqueNew = result.combos.filter((c) => !existingIds.has(c.id));
        return [...prev, ...uniqueNew];
      });
      setHasMore(result.hasMore);
    } catch (err) {
      if (seq !== requestSeqRef.current) return;
      const message =
        err instanceof Error
          ? err.message
          : "追加のコンボ読み込みに失敗しました。";
      setFetchError(message);
    } finally {
      if (seq === requestSeqRef.current) {
        setIsLoadingMore(false);
      }
    }
  };

  const handleControlTypeChange = (next: ControlTypeFilter) => {
    setSelectedControlType(next);
    if (next === "classic" || next === "modern") {
      setControlType(next);
    }
    void reloadFirstPage({
      controlType: next,
      characterId: selectedCharacterId,
      situations: selectedSituations,
    });
  };

  const handleCharacterChange = (nextCharacterId: string) => {
    setSelectedCharacterId(nextCharacterId);
    void reloadFirstPage({
      controlType: selectedControlType,
      characterId: nextCharacterId,
      situations: selectedSituations,
    });
  };

  const handleSituationToggle = (situationKey: string) => {
    const nextSituations = selectedSituations.includes(situationKey)
      ? selectedSituations.filter((item) => item !== situationKey)
      : [...selectedSituations, situationKey];
    setSelectedSituations(nextSituations);
    void reloadFirstPage({
      controlType: selectedControlType,
      characterId: selectedCharacterId,
      situations: nextSituations,
    });
  };

  const handleClearSituations = () => {
    setSelectedSituations([]);
    void reloadFirstPage({
      controlType: selectedControlType,
      characterId: selectedCharacterId,
      situations: [],
    });
  };

  const handleResetFilters = () => {
    setSelectedControlType("all");
    setSelectedCharacterId("all");
    setSelectedSituations([]);
    void reloadFirstPage({
      controlType: "all",
      characterId: "all",
      situations: [],
    });
  };

  const hasActiveFilters =
    selectedControlType !== "all" ||
    selectedCharacterId !== "all" ||
    selectedSituations.length > 0;

  const visibleCombos = useMemo(
    () => combos.filter((combo) => !deletedIds.has(combo.id)),
    [combos, deletedIds]
  );

  const handleToggleSave = (comboId: string) => {
    const added = toggleSavedCombo(comboId);
    setNotice({
      message: added
        ? "マイノートに保存しました。"
        : "マイノートから解除しました。",
    });
  };

  const handleToggleLike = async (combo: Combo) => {
    const result = await toggleLike(combo);
    if (result.requiresAuth) {
      setNotice({
        message: "いいねするにはログインが必要です。",
        showLoginLink: true,
      });
      return;
    }
    if (result.error) {
      setNotice({ message: result.error });
    }
  };

  const handleRequestDeleteCombo = (combo: Combo) => {
    setDeleteError(null);
    setDeleteTargetCombo(combo);
  };

  const handleConfirmDeleteCombo = async (combo: Combo) => {
    const canDeleteCombo = Boolean(
      user && (user.id === combo.authorId || isAdmin)
    );
    if (!canDeleteCombo || isDeleting) return;

    const isAdminDelete = Boolean(
      user && user.id !== combo.authorId && isAdmin
    );
    setIsDeleting(true);
    setDeleteError(null);
    try {
      await deleteCombo(combo.id);

      setDeletedIds((prev) => new Set(prev).add(combo.id));
      removeSavedCombo(combo.id);
      setDeleteTargetCombo(null);
      setActiveCombo((prev) => (prev?.id === combo.id ? null : prev));
      setNotice({
        message: isAdminDelete
          ? "管理者権限で公開コンボを削除しました。"
          : "公開コンボを削除しました。",
      });
      router.refresh();
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "コンボの削除に失敗しました。";
      setDeleteError(message);
    } finally {
      setIsDeleting(false);
    }
  };

  const activeCharacter = activeCombo
    ? characterMap[activeCombo.characterId]
    : undefined;

  return (
    <div className="mx-auto w-full max-w-5xl px-3 py-4 sm:px-6 sm:py-6">
      {/* ページヘッダー */}
      <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-2.5">
          <Link
            href="/"
            className="inline-flex shrink-0 items-center gap-1 rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-xs font-medium text-slate-600 transition-colors hover:bg-slate-100 hover:text-slate-900 dark:border-[#2E2447] dark:bg-[#1B152B] dark:text-[#A99EC4] dark:hover:bg-[#251D3A] dark:hover:text-[#F4F1FF]"
          >
            <ArrowLeft className="h-3.5 w-3.5" aria-hidden="true" />
            <span>トップ</span>
          </Link>
          <div className="min-w-0">
            <h1 className="flex items-center gap-1.5 text-xl font-bold tracking-tight text-slate-900 sm:text-2xl dark:text-[#F4F1FF]">
              <Sparkles
                className="h-5 w-5 shrink-0 text-blue-600 dark:text-[#A78BFA]"
                aria-hidden="true"
              />
              <span>新着コンボ一覧</span>
            </h1>
            <p className="text-xs text-slate-500 dark:text-[#A99EC4]">
              全キャラクターの公開コンボを新着順でチェックできます
            </p>
          </div>
        </div>
      </div>

      {/* 上部コントロールバー：操作タイプ切替（すべて／クラシック／モダン） + 3表記切替 */}
      <section
        aria-label="表示設定"
        className="sticky top-14 z-20 -mx-3 mb-4 border-y border-slate-200 bg-slate-50/95 px-3 py-2.5 backdrop-blur sm:mx-0 sm:rounded-xl sm:border sm:bg-white sm:px-4 sm:py-3 sm:shadow-xs dark:border-[#2D2346] dark:bg-[#151024]/90 dark:sm:bg-[#1B152B]"
      >
        <div className="flex flex-col gap-2.5 sm:flex-row sm:items-center sm:justify-between">
          {/* 操作タイプ切替タブ */}
          <div className="flex items-center gap-2">
            <span className="shrink-0 text-[11px] font-semibold text-slate-500 sm:text-xs dark:text-[#A99EC4]">
              操作
            </span>
            <div
              role="tablist"
              aria-label="操作タイプ切替"
              className="grid flex-1 grid-cols-3 rounded-lg bg-slate-200/75 p-0.5 sm:flex-initial dark:bg-[#251D3A]"
            >
              {(
                [
                  { value: "all", label: "すべて" },
                  { value: "classic", label: "クラシック" },
                  { value: "modern", label: "モダン" },
                ] as const
              ).map((item) => (
                <button
                  key={item.value}
                  type="button"
                  role="tab"
                  aria-selected={selectedControlType === item.value}
                  onClick={() => handleControlTypeChange(item.value)}
                  className={`rounded-md px-2.5 py-1.5 text-xs font-semibold transition-all sm:px-3.5 ${
                    selectedControlType === item.value
                      ? "bg-white text-blue-700 shadow-xs dark:bg-[#7C3AED] dark:text-white"
                      : "text-slate-600 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:text-[#F4F1FF]"
                  }`}
                >
                  {item.label}
                </button>
              ))}
            </div>
          </div>

          {/* 3表記切替セグメント */}
          <div className="flex items-center gap-2">
            <span className="shrink-0 text-[11px] font-semibold text-slate-500 sm:text-xs dark:text-[#A99EC4]">
              表記
            </span>
            <div
              role="tablist"
              aria-label="レシピ表記モード切替"
              className="grid flex-1 grid-cols-3 rounded-lg bg-slate-200/75 p-0.5 sm:flex-initial dark:bg-[#251D3A]"
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
                      ? "bg-blue-600 text-white shadow-xs dark:bg-[#7C3AED]"
                      : "text-slate-600 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:text-[#F4F1FF]"
                  }`}
                >
                  {item.label}
                </button>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* 絞り込みエリア：キャラクター選択 + 共通状況タグ */}
      <section
        aria-label="絞り込み"
        className="mb-5 space-y-3 rounded-xl border border-slate-200 bg-white p-3.5 shadow-xs sm:p-4 dark:border-[#2E2447] dark:bg-[#1B152B]"
      >
        {/* キャラクター絞り込みドロップダウン */}
        <div className="flex flex-col gap-1.5 sm:flex-row sm:items-center sm:justify-between">
          <label
            htmlFor="recent-character-filter"
            className="shrink-0 text-xs font-bold text-slate-700 dark:text-[#E2DCF5]"
          >
            キャラクターで絞る
          </label>
          <div className="flex items-center gap-2 sm:min-w-[260px]">
            <select
              id="recent-character-filter"
              value={selectedCharacterId}
              onChange={(e) => handleCharacterChange(e.target.value)}
              className="w-full rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-xs font-medium text-slate-900 focus:border-blue-500 focus:outline-none sm:text-sm dark:border-[#2E2447] dark:bg-[#251D3A] dark:text-[#F4F1FF] dark:focus:border-[#8B5CF6]"
            >
              <option value="all">すべてのキャラクター（{characters.length}キャラ）</option>
              {characters.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.nameJa}（{c.nameEn}）
                </option>
              ))}
            </select>
            {selectedCharacterId !== "all" && (
              <button
                type="button"
                onClick={() => handleCharacterChange("all")}
                aria-label="キャラクター絞り込みを解除"
                className="shrink-0 rounded-lg border border-slate-200 bg-slate-50 px-2 py-1.5 text-xs font-medium text-slate-600 transition-colors hover:bg-slate-100 dark:border-[#2E2447] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:bg-[#30264A]"
              >
                解除
              </button>
            )}
          </div>
        </div>

        {/* 共通状況タグフィルタ（基本状況／実戦・目的・複数選択AND） */}
        <div className="border-t border-slate-100 pt-3 dark:border-[#2E2447]">
          <div className="mb-2 flex items-center justify-between gap-2">
            <div className="flex items-baseline gap-1.5">
              <span className="text-xs font-bold text-slate-700 dark:text-[#E2DCF5]">
                共通状況で絞る
              </span>
              <span className="text-[10px] text-slate-400 dark:text-[#8E82B3]">
                複数選択はAND
              </span>
            </div>
            {selectedSituations.length > 0 && (
              <button
                type="button"
                onClick={handleClearSituations}
                className="text-xs font-medium text-blue-600 hover:underline dark:text-[#C4B5FD]"
              >
                状況をクリア
              </button>
            )}
          </div>
          <div className="space-y-2">
            <div className="flex flex-wrap items-center gap-1.5">
              <span className="shrink-0 text-[10px] font-bold text-slate-400 dark:text-[#8E82B3]">
                基本
              </span>
              {groupedCommonSituations.basic.map((sit) => {
                const isSelected = selectedSituations.includes(sit.key);
                return (
                  <button
                    key={sit.key}
                    type="button"
                    onClick={() => handleSituationToggle(sit.key)}
                    aria-pressed={isSelected}
                    className={`inline-flex items-center whitespace-nowrap rounded-full px-2.5 py-1 text-xs font-semibold transition-all ${
                      isSelected
                        ? `${sit.badgeClassName} ring-2 ring-blue-600 ring-offset-1 dark:ring-[#8B5CF6] dark:ring-offset-[#1B152B]`
                        : "border border-slate-200 bg-slate-50 text-slate-600 hover:bg-slate-100 dark:border-[#2E2447] dark:bg-[#251D3A] dark:text-[#A99EC4] dark:hover:bg-[#30264A] dark:hover:text-[#F4F1FF]"
                    }`}
                  >
                    {sit.label}
                  </button>
                );
              })}
            </div>
            {groupedCommonSituations.purpose.length > 0 && (
              <div className="flex flex-wrap items-center gap-1.5 border-t border-slate-100 pt-2 dark:border-[#2A2042]">
                <span className="shrink-0 text-[10px] font-bold text-slate-400 dark:text-[#8E82B3]">
                  実戦・目的
                </span>
                {groupedCommonSituations.purpose.map((sit) => {
                  const isSelected = selectedSituations.includes(sit.key);
                  return (
                    <button
                      key={sit.key}
                      type="button"
                      onClick={() => handleSituationToggle(sit.key)}
                      aria-pressed={isSelected}
                      title={sit.description}
                      className={`inline-flex items-center whitespace-nowrap rounded-full px-2.5 py-1 text-xs font-semibold transition-all ${
                        isSelected
                          ? `${sit.badgeClassName} ring-2 ring-blue-600 ring-offset-1 dark:ring-[#8B5CF6] dark:ring-offset-[#1B152B]`
                          : "border border-slate-200 bg-slate-50 text-slate-600 hover:bg-slate-100 dark:border-[#2E2447] dark:bg-[#251D3A] dark:text-[#A99EC4] dark:hover:bg-[#30264A] dark:hover:text-[#F4F1FF]"
                      }`}
                    >
                      {sit.label}
                    </button>
                  );
                })}
              </div>
            )}
          </div>
        </div>
      </section>

      {/* 件数・リセットバー */}
      <div className="mb-3 flex flex-wrap items-center justify-between gap-2">
        <div className="flex items-center gap-2 text-xs text-slate-600 sm:text-sm dark:text-[#A99EC4]">
          <span>
            <strong className="font-bold text-slate-900 dark:text-[#F4F1FF]">
              {visibleCombos.length}
            </strong>{" "}
            件を表示中{hasMore ? "（新着順）" : "（全件読み込み済み）"}
          </span>
          {isFilteringLoading && (
            <span className="inline-flex items-center gap-1 text-xs text-blue-600 dark:text-[#C4B5FD]">
              <Loader2 className="h-3.5 w-3.5 animate-spin" aria-hidden="true" />
              読み込み中…
            </span>
          )}
        </div>

        {hasActiveFilters && (
          <button
            type="button"
            onClick={handleResetFilters}
            className="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-medium text-blue-600 hover:bg-blue-50 dark:text-[#C4B5FD] dark:hover:bg-[#251D3A]"
          >
            <RotateCcw className="h-3 w-3" aria-hidden="true" />
            条件リセット
          </button>
        )}
      </div>

      {/* エラーバナー */}
      {fetchError && (
        <div
          role="alert"
          className="mb-4 flex flex-wrap items-center justify-between gap-2 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-xs text-rose-800 dark:border-rose-400/35 dark:bg-rose-500/15 dark:text-rose-200"
        >
          <span>{fetchError}</span>
          <button
            type="button"
            onClick={() =>
              reloadFirstPage({
                controlType: selectedControlType,
                characterId: selectedCharacterId,
                situations: selectedSituations,
              })
            }
            className="rounded-lg border border-rose-300 bg-white px-2.5 py-1 font-semibold text-rose-700 hover:bg-rose-50 dark:border-rose-400/40 dark:bg-[#1B152B] dark:text-rose-200 dark:hover:bg-rose-500/20"
          >
            再試行
          </button>
        </div>
      )}

      {/* コンボ一覧 */}
      {visibleCombos.length > 0 ? (
        <>
          <div
            className={`space-y-3 transition-opacity ${
              isFilteringLoading ? "opacity-60" : "opacity-100"
            }`}
          >
            {visibleCombos.map((combo) => {
              const char = characterMap[combo.characterId];
              const isOwner = Boolean(user && user.id === combo.authorId);
              const canManage = Boolean(user && (isOwner || isAdmin));
              const isAdminAction = Boolean(user && !isOwner && isAdmin);

              return (
                <ComboCard
                  key={combo.id}
                  combo={combo}
                  moveMap={moveMap}
                  situationMap={situationMap}
                  version={versionMap[combo.versionId]}
                  stockMeta={char?.stockMeta}
                  notationMode={notationMode}
                  isSaved={isSaved(combo.id)}
                  isLiked={isLiked(combo.id)}
                  likesCount={getLikesCount(combo)}
                  editHref={canManage ? `/combos/${combo.id}/edit` : undefined}
                  onDeleteRequest={
                    canManage ? handleRequestDeleteCombo : undefined
                  }
                  isAdminAction={isAdminAction}
                  characterSlug={char?.slug ?? combo.characterId}
                  character={char}
                  characterImageUrl={characterImageMap[combo.characterId] ?? null}
                  showControlTypeBadge
                  showPostedAt
                  onToggleSave={handleToggleSave}
                  onToggleLike={handleToggleLike}
                  onSelect={setActiveCombo}
                />
              );
            })}
          </div>

          {/* ページネーション：もっと見るボタン（全件読み込み済みの場合は非表示） */}
          {hasMore && (
            <div className="mt-6 flex justify-center">
              <button
                type="button"
                disabled={isLoadingMore || isFilteringLoading}
                onClick={handleLoadMore}
                className="inline-flex min-w-[200px] items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-5 py-2.5 text-sm font-semibold text-slate-800 shadow-xs transition-all hover:border-blue-300 hover:bg-blue-50 hover:text-blue-700 disabled:cursor-not-allowed disabled:opacity-60 dark:border-[#2E2447] dark:bg-[#1B152B] dark:text-[#F4F1FF] dark:hover:border-[#8B5CF6] dark:hover:bg-[#251D3A]"
              >
                {isLoadingMore ? (
                  <>
                    <Loader2
                      className="h-4 w-4 animate-spin"
                      aria-hidden="true"
                    />
                    <span>読み込み中…</span>
                  </>
                ) : (
                  <span>もっと見る（次の{PAGE_SIZE}件）</span>
                )}
              </button>
            </div>
          )}
        </>
      ) : (
        <div className="rounded-xl border border-dashed border-slate-300 bg-white px-4 py-12 text-center dark:border-[#3A2E58] dark:bg-[#1B152B]">
          <p className="text-sm font-medium text-slate-700 dark:text-[#F4F1FF]">
            {isFilteringLoading
              ? "コンボを読み込んでいます…"
              : "条件に一致する新着コンボが見つかりませんでした。"}
          </p>
          {!isFilteringLoading && (
            <>
              <p className="mt-1 text-xs text-slate-500 dark:text-[#A99EC4]">
                操作タイプやキャラクター・状況フィルタを変更してお試しください。
              </p>
              {hasActiveFilters && (
                <button
                  type="button"
                  onClick={handleResetFilters}
                  className="mt-4 inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-3.5 py-2 text-xs font-semibold text-white transition-colors hover:bg-blue-700 dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
                >
                  <RotateCcw className="h-3.5 w-3.5" aria-hidden="true" />
                  絞り込みをリセット
                </button>
              )}
            </>
          )}
        </div>
      )}

      {/* 詳細モーダル */}
      <ComboDetailModal
        combo={activeCombo}
        moveMap={moveMap}
        situationMap={situationMap}
        version={activeCombo ? versionMap[activeCombo.versionId] : undefined}
        stockMeta={activeCharacter?.stockMeta}
        notationMode={notationMode}
        isSaved={activeCombo ? isSaved(activeCombo.id) : false}
        isLiked={activeCombo ? isLiked(activeCombo.id) : false}
        likesCount={activeCombo ? getLikesCount(activeCombo) : 0}
        canDelete={Boolean(
          user && activeCombo && (user.id === activeCombo.authorId || isAdmin)
        )}
        isDeleting={isDeleting}
        isAdminAction={Boolean(
          user && activeCombo && user.id !== activeCombo.authorId && isAdmin
        )}
        disableEscapeClose={Boolean(deleteTargetCombo)}
        editHref={
          user && activeCombo && (user.id === activeCombo.authorId || isAdmin)
            ? `/combos/${activeCombo.id}/edit`
            : undefined
        }
        characterSlug={
          activeCharacter?.slug ?? activeCombo?.characterId ?? undefined
        }
        onToggleSave={handleToggleSave}
        onToggleLike={handleToggleLike}
        onDelete={handleRequestDeleteCombo}
        onChangeNotationMode={setNotationMode}
        onClose={() => setActiveCombo(null)}
      />

      {/* 削除確認モーダル */}
      <DeleteComboConfirmModal
        combo={deleteTargetCombo}
        isAdminAction={Boolean(
          user &&
            deleteTargetCombo &&
            user.id !== deleteTargetCombo.authorId &&
            isAdmin
        )}
        isDeleting={isDeleting}
        errorMessage={deleteError}
        onConfirm={handleConfirmDeleteCombo}
        onClose={() => {
          if (isDeleting) return;
          setDeleteTargetCombo(null);
          setDeleteError(null);
        }}
      />

      {/* 画面下部トースト通知 */}
      {notice && (
        <div
          role="status"
          className="pointer-events-none fixed inset-x-0 bottom-5 z-50 flex justify-center px-4"
        >
          <div className="pointer-events-auto flex items-center gap-3 rounded-xl border border-slate-200 bg-slate-900 px-4 py-2.5 text-xs font-medium text-white shadow-lg dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#F4F1FF]">
            <span>{notice.message}</span>
            {notice.showLoginLink && (
              <Link
                href={`/login?next=${encodeURIComponent("/combos")}`}
                className="rounded-md bg-blue-500 px-2.5 py-1 text-xs font-semibold text-white hover:bg-blue-400 dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
              >
                ログイン
              </Link>
            )}
            <button
              type="button"
              onClick={() => setNotice(null)}
              aria-label="通知を閉じる"
              className="rounded p-0.5 text-slate-400 hover:text-white dark:text-[#A99EC4] dark:hover:text-[#F4F1FF]"
            >
              <X className="h-3.5 w-3.5" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
