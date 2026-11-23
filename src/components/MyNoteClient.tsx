"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
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
} from "@/types/combo";
import {
  type CreatePrivateNoteInput,
  usePreferences,
  usePrivateNotes,
  useSavedCombos,
} from "@/hooks/useComboNoteStorage";
import { createClient } from "@/lib/supabase/client";
import {
  fetchClientCombosByIds,
  fetchClientMovesForCharacter,
  fetchClientMovesForCharacters,
} from "@/lib/supabase/clientQueries";
import { useAuth } from "@/components/AuthProvider";
import { useComboLikes } from "@/hooks/useComboLikes";
import {
  type MyNoteImportMode,
  type ParsedMyNoteBackup,
  applyMyNoteBackup,
  downloadMyNoteBackup,
  parseAndValidateMyNoteBackup,
} from "@/lib/myNoteBackup";
import { ComboCard } from "./ComboCard";
import { ComboDetailModal } from "./ComboDetailModal";
import { MyNoteImportModal } from "./MyNoteImportModal";
import { PrivateNoteCard } from "./PrivateNoteCard";
import { PrivateNoteFormModal } from "./PrivateNoteFormModal";

type MyNoteSection = "saved" | "private";

interface MyNoteClientProps {
  characters: Character[];
  allSituations: SituationDefinition[];
  versions: GameVersion[];
}

export function MyNoteClient({
  characters,
  allSituations,
  versions,
}: MyNoteClientProps) {
  const router = useRouter();
  const { user } = useAuth();
  const { notationMode, setControlType, setNotationMode } = usePreferences();
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

  // 保存済み公開コンボのみを必要最小限で取得（保存0件ならクエリ自体をスキップ）
  const [savedCombos, setSavedCombos] = useState<Combo[]>([]);
  // 必要キャラ分の技マスタのみをキャラ単位でキャッシュ
  const [movesByCharCache, setMovesByCharCache] = useState<
    Record<string, Move[]>
  >({});
  const [systemMovesCache, setSystemMovesCache] = useState<Move[]>([]);
  const loadedMoveCharIdsRef = useRef<Set<string>>(new Set());
  const [isLoadingModalMoves, setIsLoadingModalMoves] = useState(false);

  const savedComboIdsKey = useMemo(
    () => [...savedComboIds].sort().join(","),
    [savedComboIds]
  );

  useEffect(() => {
    if (savedComboIds.length === 0) {
      setSavedCombos([]);
      return;
    }

    let cancelled = false;
    fetchClientCombosByIds(savedComboIds)
      .then((fetched) => {
        if (!cancelled) {
          setSavedCombos(fetched);
        }
      })
      .catch((err) => {
        if (!cancelled) {
          console.error("保存済みコンボの読み込みに失敗しました:", err);
        }
      });

    return () => {
      cancelled = true;
    };
  }, [savedComboIdsKey, savedComboIds]);

  // 保存済み公開コンボ＆技ボタン作成済みの非公開メモに登場するキャラ分だけ技マスタを取得
  const neededMoveCharIds = useMemo(() => {
    const set = new Set<string>();
    for (const combo of savedCombos) {
      if (combo.characterId) set.add(combo.characterId);
    }
    for (const note of privateNotes) {
      if (note.moveIds && note.moveIds.length > 0 && note.characterId) {
        set.add(note.characterId);
      }
    }
    return Array.from(set).sort();
  }, [savedCombos, privateNotes]);

  const neededMoveCharIdsKey = neededMoveCharIds.join(",");

  useEffect(() => {
    const missingIds = neededMoveCharIds.filter(
      (id) => !loadedMoveCharIdsRef.current.has(id)
    );
    if (missingIds.length === 0) {
      return;
    }

    for (const id of missingIds) {
      loadedMoveCharIdsRef.current.add(id);
    }

    let cancelled = false;
    fetchClientMovesForCharacters(missingIds)
      .then((fetchedMoves) => {
        if (cancelled) return;
        const sys: Move[] = [];
        const grouped: Record<string, Move[]> = {};
        for (const id of missingIds) {
          grouped[id] = [];
        }
        for (const m of fetchedMoves) {
          if (m.characterId === null) {
            sys.push(m);
          } else if (grouped[m.characterId]) {
            grouped[m.characterId].push(m);
          }
        }
        if (sys.length > 0) {
          setSystemMovesCache(sys);
        }
        setMovesByCharCache((prev) => ({ ...prev, ...grouped }));
      })
      .catch((err) => {
        // 失敗したキャラIDは再取得できるようマークを戻す
        for (const id of missingIds) {
          loadedMoveCharIdsRef.current.delete(id);
        }
        if (!cancelled) {
          console.error("技マスタの読み込みに失敗しました:", err);
        }
      });

    return () => {
      cancelled = true;
    };
  }, [neededMoveCharIdsKey, neededMoveCharIds]);

  // 非公開メモ作成・編集モーダル用：指定キャラの技が未取得なら遅延取得してキャッシュ
  const handleRequestCharacterMoves = useCallback((charId: string) => {
    if (!charId || loadedMoveCharIdsRef.current.has(charId)) {
      return;
    }
    loadedMoveCharIdsRef.current.add(charId);
    setIsLoadingModalMoves(true);

    fetchClientMovesForCharacter(charId)
      .then((fetchedMoves) => {
        const sys: Move[] = [];
        const charMoves: Move[] = [];
        for (const m of fetchedMoves) {
          if (m.characterId === null) {
            sys.push(m);
          } else if (m.characterId === charId) {
            charMoves.push(m);
          }
        }
        if (sys.length > 0) {
          setSystemMovesCache(sys);
        }
        setMovesByCharCache((prev) => ({ ...prev, [charId]: charMoves }));
      })
      .catch((err) => {
        loadedMoveCharIdsRef.current.delete(charId);
        console.error("モーダル用技マスタの読み込みに失敗しました:", err);
      })
      .finally(() => {
        setIsLoadingModalMoves(false);
      });
  }, []);

  const allMoves = useMemo(() => {
    const map = new Map<string, Move>();
    for (const m of systemMovesCache) {
      map.set(m.id, m);
    }
    for (const list of Object.values(movesByCharCache)) {
      for (const m of list) {
        map.set(m.id, m);
      }
    }
    return Array.from(map.values());
  }, [systemMovesCache, movesByCharCache]);

  const moveMap = useMemo(() => {
    const map: Record<string, Move> = {};
    for (const m of allMoves) {
      map[m.id] = m;
    }
    return map;
  }, [allMoves]);

  const { isLiked, getLikesCount, toggleLike } = useComboLikes(savedCombos);
  const [deletedIds, setDeletedIds] = useState<Set<string>>(() => new Set());
  const [isDeleting, setIsDeleting] = useState(false);

  const [selectedCharacterId, setSelectedCharacterId] = useState<string>(
    characters[0]?.id ?? "akuma"
  );
  // キャラ増殖対策：デフォルトは「登録があるキャラのみ表示」
  const [showAllCharacters, setShowAllCharacters] = useState(false);
  const hasManuallySelectedCharRef = useRef(false);
  const [activeSection, setActiveSection] = useState<MyNoteSection>("saved");

  // 保存済みコンボ用の状況フィルタ
  const [selectedSituations, setSelectedSituations] = useState<string[]>([]);
  const [onlyStockGain, setOnlyStockGain] = useState(false);
  const [selectedStockCosts, setSelectedStockCosts] = useState<number[]>([]);

  // モーダル・通知
  const [activeCombo, setActiveCombo] = useState<Combo | null>(null);
  const [isNoteModalOpen, setIsNoteModalOpen] = useState(false);
  const [editingNote, setEditingNote] = useState<PrivateNote | null>(null);
  const [pendingImport, setPendingImport] = useState<{
    fileName: string;
    backup: ParsedMyNoteBackup;
  } | null>(null);
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
    for (const combo of savedCombos) {
      if (
        !deletedIds.has(combo.id) &&
        idSet.has(combo.id) &&
        map[combo.characterId]
      ) {
        map[combo.characterId].push(combo);
      }
    }
    return map;
  }, [savedCombos, characters, savedComboIds, deletedIds]);

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

  // 保存コンボまたは非公開メモが1件以上あるキャラ一覧
  const charactersWithEntries = useMemo(() => {
    return characters.filter(
      (c) =>
        (savedCombosByChar[c.id]?.length ?? 0) +
          (privateNotesByChar[c.id]?.length ?? 0) >
        0
    );
  }, [characters, savedCombosByChar, privateNotesByChar]);

  // 初回ロード時、登録のあるキャラが存在して現在の選択キャラが0件なら自動で登録ありキャラへ合わせる
  useEffect(() => {
    if (hasManuallySelectedCharRef.current) return;
    if (charactersWithEntries.length === 0) return;
    const currentHasEntries = charactersWithEntries.some(
      (c) => c.id === selectedCharacterId
    );
    if (!currentHasEntries) {
      setSelectedCharacterId(charactersWithEntries[0].id);
    }
  }, [charactersWithEntries, selectedCharacterId]);

  // タブバーに表示するキャラ一覧（「登録ありのみ」時は0件キャラを隠し、現在選択中のキャラだけは表示維持）
  const visibleTabCharacters = useMemo(() => {
    if (showAllCharacters || charactersWithEntries.length === 0) {
      return characters;
    }
    const visible = [...charactersWithEntries];
    if (!visible.some((c) => c.id === selectedCharacterId)) {
      const selected = characters.find((c) => c.id === selectedCharacterId);
      if (selected) {
        visible.push(selected);
      }
    }
    return visible;
  }, [
    showAllCharacters,
    charactersWithEntries,
    characters,
    selectedCharacterId,
  ]);

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
    hasManuallySelectedCharRef.current = true;
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
    const { filename, payload } = downloadMyNoteBackup(
      savedComboIds,
      privateNotes
    );
    setNotice({
      message: `${filename} をエクスポートしました（保存コンボ ${payload.savedCombos.length}件・非公開メモ ${payload.privateNotes.length}件）`,
    });
  };

  const handleImportFile = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    e.target.value = "";
    if (!file) return;

    try {
      const text = await file.text();
      const result = parseAndValidateMyNoteBackup(text);
      if (!result.ok) {
        setNotice({ message: result.error });
        return;
      }

      setPendingImport({
        fileName: file.name,
        backup: result.data,
      });
    } catch {
      setNotice({
        message:
          "JSONファイルの読み込みに失敗しました。ファイル内容を確認してください。",
      });
    }
  };

  const handleConfirmImport = (mode: MyNoteImportMode) => {
    if (!pendingImport) return;
    const { backup } = pendingImport;

    const applied = applyMyNoteBackup(
      mode,
      {
        savedCombos: savedComboIds,
        privateNotes,
      },
      {
        savedCombos: backup.savedCombos,
        privateNotes: backup.privateNotes,
      }
    );

    replaceSavedCombos(applied.savedCombos);
    replacePrivateNotes(applied.privateNotes);

    // 旧バックアップ形式に含まれる設定値がある場合は復元
    if (backup.preferences?.controlType) {
      setControlType(backup.preferences.controlType);
    }
    if (backup.preferences?.notationMode) {
      setNotationMode(backup.preferences.notationMode);
    }

    setPendingImport(null);

    if (mode === "overwrite") {
      setNotice({
        message: `上書きインポートが完了しました（保存コンボ ${applied.savedCombos.length}件・非公開メモ ${applied.privateNotes.length}件）`,
      });
    } else {
      const noteDetail =
        applied.updatedNotesCount > 0
          ? `メモ +${applied.addedNotesCount}件（更新 ${applied.updatedNotesCount}件）`
          : `メモ +${applied.addedNotesCount}件`;
      setNotice({
        message: `マージが完了しました（保存コンボ +${applied.addedSavedCount}件・${noteDetail}）`,
      });
    }
  };

  return (
    <div className="mx-auto w-full max-w-5xl px-3 py-4 sm:px-6 sm:py-6">
      {/* タイトル */}
      <div className="mb-4 flex flex-wrap items-center justify-between gap-2">
        <div>
          <h1 className="flex items-center gap-2 text-xl font-bold tracking-tight text-slate-900 sm:text-2xl dark:text-[#F4F1FF]">
            <BookMarked className="h-5 w-5 text-blue-600 dark:text-[#A78BFA]" aria-hidden="true" />
            <span>マイノート</span>
          </h1>
          <p className="mt-0.5 text-xs text-slate-500 dark:text-[#A99EC4]">
            このブラウザに自動保存されます（ログイン不要）
          </p>
        </div>

        <button
          type="button"
          onClick={handleOpenCreateNote}
          className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-3 py-2 text-xs font-semibold text-white shadow-xs transition-colors hover:bg-blue-700 sm:px-3.5 sm:text-sm dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
        >
          <Plus className="h-4 w-4" aria-hidden="true" />
          <span>非公開メモを作成</span>
        </button>
      </div>

      {/* キャラクター切替（登録あり優先・横スクロールタブバー＋全キャラ選択ドロップダウン併用） */}
      <section
        aria-label="キャラクター選択タブ"
        className="mb-4 space-y-2 rounded-xl border border-slate-200 bg-white p-2.5 shadow-xs sm:p-3 dark:border-[#2E2447] dark:bg-[#1B152B]"
      >
        {/* 上段：表示切替（登録ありのみ / 全キャラ）＋直接選択ドロップダウン */}
        <div className="flex flex-wrap items-center justify-between gap-2">
          <div className="flex items-center gap-1.5">
            {charactersWithEntries.length > 0 ? (
              <div
                role="group"
                aria-label="キャラクター表示範囲切替"
                className="inline-flex rounded-lg bg-slate-100 p-0.5 text-[11px] font-semibold dark:bg-[#251D3A]"
              >
                <button
                  type="button"
                  onClick={() => setShowAllCharacters(false)}
                  aria-pressed={!showAllCharacters}
                  className={`rounded-md px-2.5 py-1 transition-colors ${
                    !showAllCharacters
                      ? "bg-white text-blue-700 shadow-2xs dark:bg-[#7C3AED] dark:text-white"
                      : "text-slate-600 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:text-[#F4F1FF]"
                  }`}
                >
                  登録ありのみ ({charactersWithEntries.length})
                </button>
                <button
                  type="button"
                  onClick={() => setShowAllCharacters(true)}
                  aria-pressed={showAllCharacters}
                  className={`rounded-md px-2.5 py-1 transition-colors ${
                    showAllCharacters
                      ? "bg-white text-blue-700 shadow-2xs dark:bg-[#7C3AED] dark:text-white"
                      : "text-slate-600 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:text-[#F4F1FF]"
                  }`}
                >
                  全キャラ ({characters.length})
                </button>
              </div>
            ) : (
              <span className="text-[11px] font-medium text-slate-500 dark:text-[#A99EC4]">
                全 {characters.length} キャラ（登録済み 0）
              </span>
            )}
          </div>

          <label className="flex items-center gap-1.5 text-[11px] font-medium text-slate-500 dark:text-[#A99EC4]">
            <span className="hidden sm:inline">キャラ移動</span>
            <select
              aria-label="全キャラクターから選択"
              value={selectedCharacterId}
              onChange={(e) => handleSelectCharacter(e.target.value)}
              className="max-w-[165px] rounded-lg border border-slate-200 bg-slate-50 px-2.5 py-1 text-xs font-semibold text-slate-800 focus:border-blue-500 focus:bg-white focus:outline-none sm:max-w-[200px] dark:border-[#3A2E58] dark:bg-[#140F23] dark:text-[#F4F1FF] dark:focus:border-[#8B5CF6]"
            >
              {characters.map((char) => {
                const count =
                  (savedCombosByChar[char.id]?.length ?? 0) +
                  (privateNotesByChar[char.id]?.length ?? 0);
                return (
                  <option key={char.id} value={char.id}>
                    {char.nameJa}（{count}件）
                  </option>
                );
              })}
            </select>
          </label>
        </div>

        {/* 下段：スマホ幅でも1行で収まる横スクロールタブバー */}
        <div
          role="tablist"
          aria-label="キャラクター別タブ"
          className="flex items-center gap-1.5 overflow-x-auto overscroll-x-contain pb-0.5"
        >
          {visibleTabCharacters.map((char) => {
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
                className={`inline-flex shrink-0 items-center gap-1.5 whitespace-nowrap rounded-lg px-3 py-1.5 text-xs font-semibold transition-all sm:text-sm ${
                  isSelected
                    ? "bg-blue-600 text-white shadow-xs dark:bg-[#7C3AED]"
                    : "border border-slate-200/80 bg-slate-50 text-slate-700 hover:bg-slate-100 dark:border-[#2E2447] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:bg-[#30264A]"
                }`}
              >
                <span>{char.nameJa}</span>
                <span
                  className={`rounded-full px-1.5 py-0.2 text-[11px] font-bold ${
                    isSelected
                      ? "bg-white/20 text-white"
                      : "bg-white text-slate-600 dark:bg-[#1B152B] dark:text-[#A99EC4]"
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
          className="grid w-full grid-cols-2 rounded-xl bg-slate-200/75 p-1 sm:w-auto dark:bg-[#251D3A]"
        >
          <button
            type="button"
            role="tab"
            aria-selected={activeSection === "saved"}
            onClick={() => setActiveSection("saved")}
            className={`inline-flex items-center justify-center gap-1.5 rounded-lg px-3 py-1.5 text-xs font-semibold transition-all sm:px-4 sm:text-sm ${
              activeSection === "saved"
                ? "bg-white text-slate-900 shadow-xs dark:bg-[#7C3AED] dark:text-white"
                : "text-slate-600 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:text-[#F4F1FF]"
            }`}
          >
            <Star
              className={`h-3.5 w-3.5 ${
                activeSection === "saved"
                  ? "fill-amber-400 text-amber-500 dark:fill-amber-300 dark:text-amber-200"
                  : ""
              }`}
              aria-hidden="true"
            />
            <span>保存コンボ</span>
            <span
              className={`rounded-full px-1.5 py-0.2 text-[11px] ${
                activeSection === "saved"
                  ? "bg-slate-100 text-slate-600 dark:bg-white/20 dark:text-white"
                  : "bg-slate-100 text-slate-600 dark:bg-[#1B152B] dark:text-[#A99EC4]"
              }`}
            >
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
                ? "bg-white text-slate-900 shadow-xs dark:bg-[#7C3AED] dark:text-white"
                : "text-slate-600 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:text-[#F4F1FF]"
            }`}
          >
            <Lock className="h-3.5 w-3.5" aria-hidden="true" />
            <span>非公開メモ</span>
            <span
              className={`rounded-full px-1.5 py-0.2 text-[11px] ${
                activeSection === "private"
                  ? "bg-slate-100 text-slate-600 dark:bg-white/20 dark:text-white"
                  : "bg-slate-100 text-slate-600 dark:bg-[#1B152B] dark:text-[#A99EC4]"
              }`}
            >
              {currentPrivateNotes.length}
            </span>
          </button>
        </div>

        {/* 3表記切替（保存コンボ・技ボタン作成の非公開メモ共通） */}
        <div className="flex w-full items-center justify-end gap-2 sm:w-auto">
          <span className="text-xs font-semibold text-slate-500 dark:text-[#A99EC4]">表記</span>
          <div
            role="tablist"
            aria-label="マイノートの表記切替"
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
                className={`rounded-md px-2.5 py-1 text-xs font-semibold transition-all sm:px-3 ${
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

      {/* セクション1: 保存した公開コンボ */}
      {activeSection === "saved" && (
        <section aria-label="保存した公開コンボ" className="space-y-4">
          {currentSavedCombos.length > 0 && (
            <div className="rounded-xl border border-slate-200 bg-white p-3.5 shadow-xs dark:border-[#2E2447] dark:bg-[#1B152B]">
              <div className="mb-2 flex items-center justify-between">
                <span className="text-xs font-bold text-slate-700 dark:text-[#E2DCF5]">
                  状況で絞る
                </span>
                {hasSavedFilters && (
                  <button
                    type="button"
                    onClick={resetSavedFilters}
                    className="inline-flex items-center gap-1 text-xs font-medium text-blue-600 hover:underline dark:text-[#C4B5FD]"
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
                          ? `${sit.badgeClassName} ring-2 ring-blue-600 ring-offset-1 dark:ring-[#8B5CF6] dark:ring-offset-[#1B152B]`
                          : "border border-slate-200 bg-slate-50 text-slate-600 hover:bg-slate-100 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:bg-[#30264A]"
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
                          ? "bg-cyan-100 text-cyan-800 ring-2 ring-blue-600 ring-offset-1 dark:bg-cyan-500/25 dark:text-cyan-200 dark:ring-[#8B5CF6] dark:ring-offset-[#1B152B]"
                          : "border border-cyan-200 bg-cyan-50/70 text-cyan-700 hover:bg-cyan-100/70 dark:border-cyan-400/30 dark:bg-cyan-500/15 dark:text-cyan-200 dark:hover:bg-cyan-500/25"
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
                              ? "bg-pink-100 text-pink-800 ring-2 ring-blue-600 ring-offset-1 dark:bg-pink-500/25 dark:text-pink-200 dark:ring-[#8B5CF6] dark:ring-offset-[#1B152B]"
                              : "border border-pink-200 bg-pink-50/70 text-pink-700 hover:bg-pink-100/70 dark:border-pink-400/30 dark:bg-pink-500/15 dark:text-pink-200 dark:hover:bg-pink-500/25"
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
            <div className="rounded-xl border border-dashed border-slate-300 bg-white px-4 py-10 text-center dark:border-[#3A2E58] dark:bg-[#1B152B]">
              <p className="text-sm font-medium text-slate-700 dark:text-[#E2DCF5]">
                選択した状況に一致する保存コンボがありません。
              </p>
              <button
                type="button"
                onClick={resetSavedFilters}
                className="mt-3 inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-3.5 py-2 text-xs font-semibold text-white hover:bg-blue-700 dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
              >
                <RotateCcw className="h-3.5 w-3.5" aria-hidden="true" />
                絞り込みをクリア
              </button>
            </div>
          ) : (
            <div className="rounded-xl border border-dashed border-slate-300 bg-white px-4 py-10 text-center dark:border-[#3A2E58] dark:bg-[#1B152B]">
              <p className="text-sm font-medium text-slate-700 dark:text-[#E2DCF5]">
                {activeCharacter?.nameJa}の保存済みコンボはまだありません。
              </p>
              <p className="mt-1 text-xs text-slate-500 dark:text-[#A99EC4]">
                コンボ一覧で「☆」をタップすると、ここにカンペとしてまとまります。
              </p>
              {activeCharacter && (
                <Link
                  href={`/characters/${activeCharacter.slug}`}
                  className="mt-4 inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-4 py-2 text-xs font-semibold text-white transition-colors hover:bg-blue-700 dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
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
            <div className="rounded-xl border border-dashed border-slate-300 bg-white px-4 py-10 text-center dark:border-[#3A2E58] dark:bg-[#1B152B]">
              <p className="text-sm font-medium text-slate-700 dark:text-[#E2DCF5]">
                {activeCharacter?.nameJa}の非公開メモはまだありません。
              </p>
              <p className="mt-1 text-xs text-slate-500 dark:text-[#A99EC4]">
                自分だけの練習メモや手癖ルートを自由テキストで手軽に記録できます。
              </p>
              <button
                type="button"
                onClick={handleOpenCreateNote}
                className="mt-4 inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-4 py-2 text-xs font-semibold text-white transition-colors hover:bg-blue-700 dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
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
        className="mt-8 rounded-xl border border-slate-200 bg-white p-4 shadow-xs dark:border-[#2E2447] dark:bg-[#1B152B]"
      >
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <div className="flex flex-wrap items-center gap-2">
              <h2 className="text-xs font-bold text-slate-800 sm:text-sm dark:text-[#F4F1FF]">
                マイノートデータのバックアップ・移行
              </h2>
              <span className="rounded-full bg-slate-100 px-2 py-0.5 text-[11px] font-medium text-slate-600 dark:bg-[#251D3A] dark:text-[#A99EC4]">
                保存 {savedComboIds.length}件 / メモ {privateNotes.length}件
              </span>
            </div>
            <p className="mt-1 text-xs leading-relaxed text-slate-500 dark:text-[#A99EC4]">
              ブラウザのデータ消去や端末間の引き継ぎに備えて、お気に入りコンボと非公開メモをJSON形式で保存・復元（マージ／上書き）できます。
            </p>
          </div>
          <div className="grid grid-cols-2 gap-2 sm:flex sm:shrink-0 sm:items-center">
            <button
              type="button"
              onClick={handleExportJson}
              className="inline-flex items-center justify-center gap-1.5 rounded-lg border border-slate-200 bg-white px-3 py-2 text-xs font-semibold text-slate-700 transition-colors hover:bg-slate-50 sm:py-1.5 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#E2DCF5] dark:hover:bg-[#30264A]"
            >
              <Download className="h-3.5 w-3.5 shrink-0" aria-hidden="true" />
              <span>JSONエクスポート</span>
            </button>

            <button
              type="button"
              onClick={() => fileInputRef.current?.click()}
              className="inline-flex items-center justify-center gap-1.5 rounded-lg border border-blue-200 bg-blue-50/70 px-3 py-2 text-xs font-semibold text-blue-700 transition-colors hover:bg-blue-100 sm:py-1.5 dark:border-violet-400/40 dark:bg-violet-500/20 dark:text-[#DDD6FE] dark:hover:bg-violet-500/30"
            >
              <Upload className="h-3.5 w-3.5 shrink-0" aria-hidden="true" />
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

      {/* バックアップインポート確認モーダル */}
      <MyNoteImportModal
        key={pendingImport ? `${pendingImport.fileName}-${pendingImport.backup.exportedAt ?? ""}` : "closed"}
        pendingImport={pendingImport}
        currentSavedCount={savedComboIds.length}
        currentNotesCount={privateNotes.length}
        onConfirm={handleConfirmImport}
        onClose={() => setPendingImport(null)}
      />

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
        isLoadingMoves={isLoadingModalMoves}
        onRequestCharacterMoves={handleRequestCharacterMoves}
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
          className="fixed right-3 bottom-4 left-3 z-50 mx-auto flex max-w-md items-center justify-between gap-3 rounded-xl border border-slate-200 bg-slate-900 px-4 py-3 text-sm text-white shadow-lg sm:right-6 sm:left-auto dark:border-[#3A2E58] dark:bg-[#221A36] dark:text-[#F4F1FF]"
        >
          <span>{notice.message}</span>
          <div className="flex shrink-0 items-center gap-2">
            {notice.showLoginLink && (
              <Link
                href="/login?next=%2Fmy-note"
                className="rounded-md bg-blue-600 px-2.5 py-1 text-xs font-semibold text-white transition-colors hover:bg-blue-500 dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
              >
                ログイン
              </Link>
            )}
            <button
              type="button"
              onClick={() => setNotice(null)}
              aria-label="通知を閉じる"
              className="rounded p-1 text-slate-300 hover:bg-slate-800 hover:text-white dark:text-[#A99EC4] dark:hover:bg-[#30264A] dark:hover:text-[#F4F1FF]"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
