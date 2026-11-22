"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  BookMarked,
  Download,
  ExternalLink,
  Lock,
  Plus,
  RotateCcw,
  Star,
  Upload,
  X,
} from "lucide-react";
import type {
  Character,
  Combo,
  GameVersion,
  Move,
  PrivateNote,
  SituationDefinition,
  UserPreferences,
} from "@/types/combo";
import {
  type CreatePrivateNoteInput,
  usePreferences,
  usePrivateNotes,
  useSavedCombos,
} from "@/hooks/useComboNoteStorage";
import { createClient } from "@/lib/supabase/client";
import { useAuth } from "@/components/AuthProvider";
import { useComboLikes } from "@/hooks/useComboLikes";
import { ComboCard } from "./ComboCard";
import { ComboDetailModal } from "./ComboDetailModal";
import { PrivateNoteCard } from "./PrivateNoteCard";
import { PrivateNoteFormModal } from "./PrivateNoteFormModal";

type MyNoteSection = "saved" | "private";

interface BackupPayload {
  version: 1;
  exportedAt: string;
  preferences?: UserPreferences;
  savedCombos: string[];
  privateNotes: PrivateNote[];
}

interface MyNoteClientProps {
  characters: Character[];
  allCombos: Combo[];
  allMoves: Move[];
  moveMap: Record<string, Move>;
  allSituations: SituationDefinition[];
  versions: GameVersion[];
}

export function MyNoteClient({
  characters,
  allCombos,
  allMoves,
  moveMap,
  allSituations,
  versions,
}: MyNoteClientProps) {
  const router = useRouter();
  const { user } = useAuth();
  const {
    preferences,
    notationMode,
    setControlType,
    setNotationMode,
  } = usePreferences();
  const {
    savedComboIds,
    isSaved,
    toggleSavedCombo,
    removeSavedCombo,
    replaceSavedCombos,
  } = useSavedCombos();
  const {
    privateNotes,
    addPrivateNote,
    updatePrivateNote,
    deletePrivateNote,
    replacePrivateNotes,
  } = usePrivateNotes();
  const { isLiked, getLikesCount, toggleLike } = useComboLikes(allCombos);
  const [deletedIds, setDeletedIds] = useState<Set<string>>(() => new Set());
  const [isDeleting, setIsDeleting] = useState(false);

  const [selectedCharacterId, setSelectedCharacterId] = useState<string>(
    characters[0]?.id ?? "akuma"
  );
  const [activeSection, setActiveSection] = useState<MyNoteSection>("saved");

  // 保存済みコンボ用の状況フィルタ
  const [selectedSituations, setSelectedSituations] = useState<string[]>([]);
  const [onlyStockGain, setOnlyStockGain] = useState(false);
  const [selectedStockCosts, setSelectedStockCosts] = useState<number[]>([]);

  // モーダル・通知
  const [activeCombo, setActiveCombo] = useState<Combo | null>(null);
  const [isNoteModalOpen, setIsNoteModalOpen] = useState(false);
  const [editingNote, setEditingNote] = useState<PrivateNote | null>(null);
  const [notice, setNotice] = useState<{
    message: string;
    showLoginLink?: boolean;
  } | null>(null);
  const fileInputRef = useRef<HTMLInputElement | null>(null);

  useEffect(() => {
    if (!notice) return;
    const timer = window.setTimeout(
      () => setNotice(null),
      notice.showLoginLink ? 5000 : 3000
    );
    return () => window.clearTimeout(timer);
  }, [notice]);

  const activeCharacter = useMemo(
    () =>
      characters.find((c) => c.id === selectedCharacterId) ?? characters[0],
    [characters, selectedCharacterId]
  );

  const versionMap = useMemo(() => {
    const map: Record<string, GameVersion> = {};
    for (const v of versions) {
      map[v.id] = v;
    }
    return map;
  }, [versions]);

  const situationsByCharacter = useMemo(() => {
    const map: Record<string, SituationDefinition[]> = {};
    for (const c of characters) {
      map[c.id] = allSituations
        .filter((s) => s.characterId === null || s.characterId === c.id)
        .sort((a, b) => a.sortOrder - b.sortOrder);
    }
    return map;
  }, [characters, allSituations]);

  const currentSituations = useMemo(
    () => situationsByCharacter[selectedCharacterId] ?? [],
    [situationsByCharacter, selectedCharacterId]
  );

  const currentSituationMap = useMemo(() => {
    const map: Record<string, SituationDefinition> = {};
    for (const s of currentSituations) {
      map[s.key] = s;
    }
    return map;
  }, [currentSituations]);

  // キャラごとの件数集計
  const savedCombosByChar = useMemo(() => {
    const idSet = new Set(savedComboIds);
    const map: Record<string, Combo[]> = {};
    for (const c of characters) {
      map[c.id] = [];
    }
    for (const combo of allCombos) {
      if (
        !deletedIds.has(combo.id) &&
        idSet.has(combo.id) &&
        map[combo.characterId]
      ) {
        map[combo.characterId].push(combo);
      }
    }
    return map;
  }, [allCombos, characters, savedComboIds, deletedIds]);

  const privateNotesByChar = useMemo(() => {
    const map: Record<string, PrivateNote[]> = {};
    for (const c of characters) {
      map[c.id] = [];
    }
    for (const note of privateNotes) {
      if (map[note.characterId]) {
        map[note.characterId].push(note);
      }
    }
    return map;
  }, [characters, privateNotes]);

  const currentSavedCombos = useMemo(
    () => savedCombosByChar[selectedCharacterId] ?? [],
    [savedCombosByChar, selectedCharacterId]
  );

  const currentPrivateNotes = useMemo(
    () => privateNotesByChar[selectedCharacterId] ?? [],
    [privateNotesByChar, selectedCharacterId]
  );

  const filteredSavedCombos = useMemo(() => {
    return currentSavedCombos.filter((combo) => {
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
      return true;
    });
  }, [
    currentSavedCombos,
    selectedSituations,
    onlyStockGain,
    selectedStockCosts,
  ]);

  const handleSelectCharacter = (charId: string) => {
    setSelectedCharacterId(charId);
    setSelectedSituations([]);
    setOnlyStockGain(false);
    setSelectedStockCosts([]);
  };

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

  const resetSavedFilters = () => {
    setSelectedSituations([]);
    setOnlyStockGain(false);
    setSelectedStockCosts([]);
  };

  const hasSavedFilters =
    selectedSituations.length > 0 ||
    onlyStockGain ||
    selectedStockCosts.length > 0;

  const handleToggleSave = (comboId: string) => {
    const added = toggleSavedCombo(comboId);
    setNotice({
      message: added
        ? "マイノートに保存しました。"
        : "マイノートから解除しました。",
    });
    if (!added && activeCombo?.id === comboId) {
      setActiveCombo(null);
    }
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

  const handleDeleteCombo = async (combo: Combo) => {
    if (!user || user.id !== combo.authorId || isDeleting) return;
    setIsDeleting(true);
    try {
      const supabase = createClient();
      const { error } = await supabase
        .from("combos")
        .delete()
        .eq("id", combo.id)
        .eq("author_id", user.id);

      if (error) {
        throw error;
      }

      setDeletedIds((prev) => new Set(prev).add(combo.id));
      removeSavedCombo(combo.id);
      setActiveCombo(null);
      setNotice({ message: "コンボを削除しました。" });
      router.refresh();
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "コンボの削除に失敗しました。";
      setNotice({ message });
    } finally {
      setIsDeleting(false);
    }
  };

  const handleOpenCreateNote = () => {
    setEditingNote(null);
    setIsNoteModalOpen(true);
  };

  const handleOpenEditNote = (note: PrivateNote) => {
    setEditingNote(note);
    setIsNoteModalOpen(true);
  };

  const handleSavePrivateNote = (
    data: CreatePrivateNoteInput,
    editingId?: string
  ) => {
    if (editingId) {
      updatePrivateNote(editingId, data);
      setNotice({ message: "非公開メモを更新しました。" });
    } else {
      addPrivateNote(data);
      setNotice({ message: "非公開メモを保存しました。" });
    }
    setSelectedCharacterId(data.characterId);
    setActiveSection("private");
    setIsNoteModalOpen(false);
    setEditingNote(null);
  };

  const handleDeletePrivateNote = (id: string) => {
    deletePrivateNote(id);
    setNotice({ message: "非公開メモを削除しました。" });
  };

  const handleExportJson = () => {
    const payload: BackupPayload = {
      version: 1,
      exportedAt: new Date().toISOString(),
      preferences,
      savedCombos: savedComboIds,
      privateNotes,
    };
    const blob = new Blob([JSON.stringify(payload, null, 2)], {
      type: "application/json",
    });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    const today = new Date().toISOString().slice(0, 10).replace(/-/g, "");
    a.href = url;
    a.download = `combonote-backup-${today}.json`;
    a.click();
    URL.revokeObjectURL(url);
    setNotice({ message: "バックアップJSONをエクスポートしました。" });
  };

  const handleImportFile = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    e.target.value = "";
    if (!file) return;

    try {
      const text = await file.text();
      const parsed: unknown = JSON.parse(text);
      if (typeof parsed !== "object" || parsed === null) {
        throw new Error("invalid");
      }

      const data = parsed as Record<string, unknown>;
      const importedSaved = Array.isArray(data.savedCombos)
        ? data.savedCombos.filter(
            (id): id is string => typeof id === "string"
          )
        : [];

      const importedNotes = Array.isArray(data.privateNotes)
        ? data.privateNotes.filter((item): item is PrivateNote => {
            if (typeof item !== "object" || item === null) return false;
            const n = item as Record<string, unknown>;
            return (
              typeof n.id === "string" &&
              typeof n.characterId === "string" &&
              typeof n.situation === "string" &&
              typeof n.recipeText === "string" &&
              typeof n.note === "string" &&
              typeof n.createdAt === "string" &&
              typeof n.updatedAt === "string"
            );
          })
        : [];

      if (
        !Array.isArray(data.savedCombos) &&
        !Array.isArray(data.privateNotes)
      ) {
        throw new Error("missing-fields");
      }

      // 既存データと安全にマージ（ID重複はインポート側で更新）
      const mergedSaved = Array.from(
        new Set([...savedComboIds, ...importedSaved])
      );
      replaceSavedCombos(mergedSaved);

      const noteMap = new Map<string, PrivateNote>();
      for (const n of privateNotes) {
        noteMap.set(n.id, n);
      }
      for (const n of importedNotes) {
        noteMap.set(n.id, n);
      }
      const mergedNotes = Array.from(noteMap.values()).sort(
        (a, b) =>
          new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime()
      );
      replacePrivateNotes(mergedNotes);

      if (typeof data.preferences === "object" && data.preferences !== null) {
        const pref = data.preferences as Record<string, unknown>;
        if (pref.controlType === "classic" || pref.controlType === "modern") {
          setControlType(pref.controlType);
        }
        if (
          pref.notationMode === "numpad" ||
          pref.notationMode === "command" ||
          pref.notationMode === "name"
        ) {
          setNotationMode(pref.notationMode);
        }
      }

      setNotice({
        message: `インポート完了（保存コンボ ${importedSaved.length}件・非公開メモ ${importedNotes.length}件を取り込みました）`,
      });
    } catch {
      setNotice({
        message:
          "JSONファイルの読み込みに失敗しました。コンボノートのバックアップファイルを選択してください。",
      });
    }
  };

  return (
    <div className="mx-auto w-full max-w-5xl px-3 py-4 sm:px-6 sm:py-6">
      {/* タイトル */}
      <div className="mb-4 flex flex-wrap items-center justify-between gap-2">
        <div>
          <h1 className="flex items-center gap-2 text-xl font-bold tracking-tight text-slate-900 sm:text-2xl">
            <BookMarked className="h-5 w-5 text-blue-600" aria-hidden="true" />
            <span>マイノート</span>
          </h1>
          <p className="mt-0.5 text-xs text-slate-500">
            このブラウザに自動保存されます（ログイン不要）
          </p>
        </div>

        <button
          type="button"
          onClick={handleOpenCreateNote}
          className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-3 py-2 text-xs font-semibold text-white shadow-xs transition-colors hover:bg-blue-700 sm:px-3.5 sm:text-sm"
        >
          <Plus className="h-4 w-4" aria-hidden="true" />
          <span>非公開メモを作成</span>
        </button>
      </div>

      {/* キャラクター別タブ */}
      <section aria-label="キャラクター選択タブ" className="mb-4">
        <div
          role="tablist"
          className="grid grid-cols-2 gap-1.5 rounded-xl border border-slate-200 bg-white p-1.5 shadow-xs sm:grid-cols-4"
        >
          {characters.map((char) => {
            const isSelected = char.id === selectedCharacterId;
            const totalCount =
              (savedCombosByChar[char.id]?.length ?? 0) +
              (privateNotesByChar[char.id]?.length ?? 0);
            return (
              <button
                key={char.id}
                type="button"
                role="tab"
                aria-selected={isSelected}
                onClick={() => handleSelectCharacter(char.id)}
                className={`flex items-center justify-between gap-1.5 rounded-lg px-3 py-2 text-xs font-semibold transition-all sm:text-sm ${
                  isSelected
                    ? "bg-blue-600 text-white shadow-xs"
                    : "text-slate-700 hover:bg-slate-100"
                }`}
              >
                <span className="truncate">{char.nameJa}</span>
                <span
                  className={`shrink-0 rounded-full px-1.5 py-0.5 text-[11px] font-bold ${
                    isSelected
                      ? "bg-white/20 text-white"
                      : "bg-slate-100 text-slate-600"
                  }`}
                >
                  {totalCount}
                </span>
              </button>
            );
          })}
        </div>
      </section>

      {/* セクション切替：保存した公開コンボ / 自分用非公開メモ */}
      <div className="mb-4 flex flex-wrap items-center justify-between gap-2.5">
        <div
          role="tablist"
          aria-label="マイノートセクション切替"
          className="grid w-full grid-cols-2 rounded-xl bg-slate-200/75 p-1 sm:w-auto"
        >
          <button
            type="button"
            role="tab"
            aria-selected={activeSection === "saved"}
            onClick={() => setActiveSection("saved")}
            className={`inline-flex items-center justify-center gap-1.5 rounded-lg px-3 py-1.5 text-xs font-semibold transition-all sm:px-4 sm:text-sm ${
              activeSection === "saved"
                ? "bg-white text-slate-900 shadow-xs"
                : "text-slate-600 hover:text-slate-900"
            }`}
          >
            <Star
              className={`h-3.5 w-3.5 ${
                activeSection === "saved"
                  ? "fill-amber-400 text-amber-500"
                  : ""
              }`}
              aria-hidden="true"
            />
            <span>保存コンボ</span>
            <span className="rounded-full bg-slate-100 px-1.5 py-0.2 text-[11px] text-slate-600">
              {currentSavedCombos.length}
            </span>
          </button>

          <button
            type="button"
            role="tab"
            aria-selected={activeSection === "private"}
            onClick={() => setActiveSection("private")}
            className={`inline-flex items-center justify-center gap-1.5 rounded-lg px-3 py-1.5 text-xs font-semibold transition-all sm:px-4 sm:text-sm ${
              activeSection === "private"
                ? "bg-white text-slate-900 shadow-xs"
                : "text-slate-600 hover:text-slate-900"
            }`}
          >
            <Lock className="h-3.5 w-3.5" aria-hidden="true" />
            <span>非公開メモ</span>
            <span className="rounded-full bg-slate-100 px-1.5 py-0.2 text-[11px] text-slate-600">
              {currentPrivateNotes.length}
            </span>
          </button>
        </div>

        {/* 3表記切替（保存コンボ・技ボタン作成の非公開メモ共通） */}
        <div className="flex w-full items-center justify-end gap-2 sm:w-auto">
          <span className="text-xs font-semibold text-slate-500">表記</span>
          <div
            role="tablist"
            aria-label="マイノートの表記切替"
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
                className={`rounded-md px-2.5 py-1 text-xs font-semibold transition-all sm:px-3 ${
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

      {/* セクション1: 保存した公開コンボ */}
      {activeSection === "saved" && (
        <section aria-label="保存した公開コンボ" className="space-y-4">
          {currentSavedCombos.length > 0 && (
            <div className="rounded-xl border border-slate-200 bg-white p-3.5 shadow-xs">
              <div className="mb-2 flex items-center justify-between">
                <span className="text-xs font-bold text-slate-700">
                  状況で絞る
                </span>
                {hasSavedFilters && (
                  <button
                    type="button"
                    onClick={resetSavedFilters}
                    className="inline-flex items-center gap-1 text-xs font-medium text-blue-600 hover:underline"
                  >
                    <RotateCcw className="h-3 w-3" aria-hidden="true" />
                    クリア
                  </button>
                )}
              </div>
              <div className="flex flex-wrap gap-1.5">
                {currentSituations.map((sit) => {
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

                {activeCharacter?.stockMeta && (
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
                      {activeCharacter.stockMeta.shortLabel}獲得
                    </button>

                    {Array.from(
                      { length: activeCharacter.stockMeta.maxCount },
                      (_, i) => i + 1
                    ).map((count) => {
                      const isSelected = selectedStockCosts.includes(count);
                      const isMax = count === activeCharacter.stockMeta?.maxCount;
                      const label = isMax
                        ? `${activeCharacter.stockMeta?.shortLabel}最大(${count}個)`
                        : `${activeCharacter.stockMeta?.shortLabel}${count}個`;
                      return (
                        <button
                          key={`mynote-stock-${count}`}
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
          )}

          {filteredSavedCombos.length > 0 ? (
            <div className="space-y-3">
              {filteredSavedCombos.map((combo) => (
                <ComboCard
                  key={combo.id}
                  combo={combo}
                  moveMap={moveMap}
                  situationMap={currentSituationMap}
                  version={versionMap[combo.versionId]}
                  stockMeta={activeCharacter?.stockMeta}
                  notationMode={notationMode}
                  isSaved={isSaved(combo.id)}
                  isLiked={isLiked(combo.id)}
                  likesCount={getLikesCount(combo)}
                  characterSlug={activeCharacter?.slug}
                  onToggleSave={handleToggleSave}
                  onToggleLike={handleToggleLike}
                  onSelect={setActiveCombo}
                />
              ))}
            </div>
          ) : currentSavedCombos.length > 0 ? (
            <div className="rounded-xl border border-dashed border-slate-300 bg-white px-4 py-10 text-center">
              <p className="text-sm font-medium text-slate-700">
                選択した状況に一致する保存コンボがありません。
              </p>
              <button
                type="button"
                onClick={resetSavedFilters}
                className="mt-3 inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-3.5 py-2 text-xs font-semibold text-white hover:bg-blue-700"
              >
                <RotateCcw className="h-3.5 w-3.5" aria-hidden="true" />
                絞り込みをクリア
              </button>
            </div>
          ) : (
            <div className="rounded-xl border border-dashed border-slate-300 bg-white px-4 py-10 text-center">
              <p className="text-sm font-medium text-slate-700">
                {activeCharacter?.nameJa}の保存済みコンボはまだありません。
              </p>
              <p className="mt-1 text-xs text-slate-500">
                コンボ一覧で「☆」をタップすると、ここにカンペとしてまとまります。
              </p>
              {activeCharacter && (
                <Link
                  href={`/characters/${activeCharacter.slug}`}
                  className="mt-4 inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-4 py-2 text-xs font-semibold text-white transition-colors hover:bg-blue-700"
                >
                  <span>{activeCharacter.nameJa}のコンボ一覧を見る</span>
                  <ExternalLink className="h-3.5 w-3.5" aria-hidden="true" />
                </Link>
              )}
            </div>
          )}
        </section>
      )}

      {/* セクション2: 自分用非公開メモ */}
      {activeSection === "private" && (
        <section aria-label="自分用非公開メモ" className="space-y-3">
          {currentPrivateNotes.length > 0 ? (
            currentPrivateNotes.map((note) => (
              <PrivateNoteCard
                key={note.id}
                note={note}
                situations={currentSituations}
                moveMap={moveMap}
                notationMode={notationMode}
                onEdit={handleOpenEditNote}
                onDelete={handleDeletePrivateNote}
              />
            ))
          ) : (
            <div className="rounded-xl border border-dashed border-slate-300 bg-white px-4 py-10 text-center">
              <p className="text-sm font-medium text-slate-700">
                {activeCharacter?.nameJa}の非公開メモはまだありません。
              </p>
              <p className="mt-1 text-xs text-slate-500">
                自分だけの練習メモや手癖ルートを自由テキストで手軽に記録できます。
              </p>
              <button
                type="button"
                onClick={handleOpenCreateNote}
                className="mt-4 inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-4 py-2 text-xs font-semibold text-white transition-colors hover:bg-blue-700"
              >
                <Plus className="h-4 w-4" aria-hidden="true" />
                <span>最初のメモを作成する</span>
              </button>
            </div>
          )}
        </section>
      )}

      {/* 画面下部：JSONエクスポート / インポート */}
      <section
        aria-label="データバックアップ"
        className="mt-8 rounded-xl border border-slate-200 bg-white p-4 shadow-xs"
      >
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="text-xs font-bold text-slate-800 sm:text-sm">
              マイノートデータのバックアップ
            </h2>
            <p className="mt-0.5 text-xs text-slate-500">
              ブラウザのデータ消去や端末移行に備えて、JSON形式で保存・復元できます。
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <button
              type="button"
              onClick={handleExportJson}
              className="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-xs font-semibold text-slate-700 transition-colors hover:bg-slate-50"
            >
              <Download className="h-3.5 w-3.5" aria-hidden="true" />
              <span>JSONエクスポート</span>
            </button>

            <button
              type="button"
              onClick={() => fileInputRef.current?.click()}
              className="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-xs font-semibold text-slate-700 transition-colors hover:bg-slate-50"
            >
              <Upload className="h-3.5 w-3.5" aria-hidden="true" />
              <span>JSONインポート</span>
            </button>
            <input
              ref={fileInputRef}
              type="file"
              accept="application/json,.json"
              onChange={handleImportFile}
              className="hidden"
            />
          </div>
        </div>
      </section>

      {/* 保存済み公開コンボ詳細モーダル */}
      <ComboDetailModal
        combo={activeCombo}
        moveMap={moveMap}
        situationMap={currentSituationMap}
        version={activeCombo ? versionMap[activeCombo.versionId] : undefined}
        stockMeta={activeCharacter?.stockMeta}
        notationMode={notationMode}
        isSaved={activeCombo ? isSaved(activeCombo.id) : false}
        isLiked={activeCombo ? isLiked(activeCombo.id) : false}
        likesCount={activeCombo ? getLikesCount(activeCombo) : 0}
        canDelete={Boolean(user && activeCombo && user.id === activeCombo.authorId)}
        isDeleting={isDeleting}
        characterSlug={activeCharacter?.slug}
        onToggleSave={handleToggleSave}
        onToggleLike={handleToggleLike}
        onDelete={handleDeleteCombo}
        onChangeNotationMode={setNotationMode}
        onClose={() => setActiveCombo(null)}
      />

      {/* 非公開メモ作成・編集モーダル */}
      <PrivateNoteFormModal
        key={
          isNoteModalOpen
            ? editingNote?.id ?? `new-${selectedCharacterId}`
            : "closed"
        }
        isOpen={isNoteModalOpen}
        characters={characters}
        allMoves={allMoves}
        situationsByCharacter={situationsByCharacter}
        defaultCharacterId={selectedCharacterId}
        notationMode={notationMode}
        onChangeNotationMode={setNotationMode}
        editingNote={editingNote}
        onSave={handleSavePrivateNote}
        onClose={() => {
          setIsNoteModalOpen(false);
          setEditingNote(null);
        }}
      />

      {/* トースト通知 */}
      {notice && (
        <div
          role="status"
          className="fixed right-3 bottom-4 left-3 z-50 mx-auto flex max-w-md items-center justify-between gap-3 rounded-xl border border-slate-200 bg-slate-900 px-4 py-3 text-sm text-white shadow-lg sm:right-6 sm:left-auto"
        >
          <span>{notice.message}</span>
          <div className="flex shrink-0 items-center gap-2">
            {notice.showLoginLink && (
              <Link
                href="/login?next=%2Fmy-note"
                className="rounded-md bg-blue-600 px-2.5 py-1 text-xs font-semibold text-white transition-colors hover:bg-blue-500"
              >
                ログイン
              </Link>
            )}
            <button
              type="button"
              onClick={() => setNotice(null)}
              aria-label="通知を閉じる"
              className="rounded p-1 text-slate-300 hover:bg-slate-800 hover:text-white"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
