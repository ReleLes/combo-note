"use client";

import { useEffect, useMemo, useState } from "react";
import { ChevronRight, Loader2, Trash2, Undo2, X } from "lucide-react";
import type {
  Character,
  ControlType,
  Move,
  MoveCategory,
  NotationMode,
  PrivateNote,
  SituationDefinition,
} from "@/types/combo";
import type { CreatePrivateNoteInput } from "@/hooks/useComboNoteStorage";
import { MoveNotation } from "@/components/CommandNotation";

type RecipeInputMode = "builder" | "text";

interface PrivateNoteFormModalProps {
  isOpen: boolean;
  characters: Character[];
  allMoves: Move[];
  isLoadingMoves?: boolean;
  onRequestCharacterMoves?: (characterId: string) => void;
  situationsByCharacter: Record<string, SituationDefinition[]>;
  defaultCharacterId: string;
  notationMode: NotationMode;
  onChangeNotationMode: (mode: NotationMode) => void;
  editingNote: PrivateNote | null;
  onSave: (data: CreatePrivateNoteInput, editingId?: string) => void;
  onClose: () => void;
}

const MOVE_CATEGORY_TABS: { key: MoveCategory; label: string }[] = [
  { key: "normal", label: "通常技" },
  { key: "unique", label: "特殊技" },
  { key: "special", label: "必殺技" },
  { key: "super", label: "SA" },
  { key: "throw", label: "投げ" },
  { key: "system", label: "システム" },
];

const NOTATION_TABS: { mode: NotationMode; label: string }[] = [
  { mode: "numpad", label: "テンキー" },
  { mode: "command", label: "コマンド" },
  { mode: "name", label: "技名" },
];

function getMoveChipStyle(move: Move): string {
  switch (move.category) {
    case "system":
      return "border-slate-200 bg-slate-100 text-slate-700 dark:border-[#3B3057] dark:bg-[#251D3A] dark:text-[#CFC6E8]";
    case "super":
      return "border-indigo-200 bg-indigo-50 text-indigo-800 font-semibold dark:border-violet-400/40 dark:bg-violet-500/20 dark:text-violet-200";
    case "special":
      return "border-blue-200 bg-blue-50/70 text-slate-900 font-medium dark:border-sky-400/35 dark:bg-sky-500/15 dark:text-[#F4F1FF]";
    case "throw":
      return "border-amber-200 bg-amber-50/70 text-amber-900 font-medium dark:border-amber-400/35 dark:bg-amber-500/15 dark:text-amber-200";
    default:
      return "border-slate-200 bg-white text-slate-900 font-medium dark:border-[#3D315C] dark:bg-[#261E3B] dark:text-[#F4F1FF]";
  }
}

export function PrivateNoteFormModal({
  isOpen,
  characters,
  allMoves,
  isLoadingMoves = false,
  onRequestCharacterMoves,
  situationsByCharacter,
  defaultCharacterId,
  notationMode,
  onChangeNotationMode,
  editingNote,
  onSave,
  onClose,
}: PrivateNoteFormModalProps) {
  const initialHasMoveIds = Boolean(
    editingNote?.moveIds && editingNote.moveIds.length > 0
  );

  const [characterId, setCharacterId] = useState(
    editingNote?.characterId ?? defaultCharacterId
  );
  const [controlType, setControlType] = useState<ControlType | "">(
    editingNote?.controlType ?? ""
  );
  const [situation, setSituation] = useState(editingNote?.situation ?? "");
  const [recipeInputMode, setRecipeInputMode] = useState<RecipeInputMode>(
    editingNote ? (initialHasMoveIds ? "builder" : "text") : "builder"
  );
  const [activeMoveCategory, setActiveMoveCategory] =
    useState<MoveCategory>("normal");
  const [recipeMoveIds, setRecipeMoveIds] = useState<string[]>(
    editingNote?.moveIds ?? []
  );
  const [recipeText, setRecipeText] = useState(editingNote?.recipeText ?? "");
  const [note, setNote] = useState(editingNote?.note ?? "");
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!isOpen) return;
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen, onClose]);

  useEffect(() => {
    if (!isOpen || !characterId) return;
    onRequestCharacterMoves?.(characterId);
  }, [isOpen, characterId, onRequestCharacterMoves]);

  const moveMap = useMemo(() => {
    const map: Record<string, Move> = {};
    for (const m of allMoves) {
      map[m.id] = m;
    }
    return map;
  }, [allMoves]);

  const availableMoves = useMemo(() => {
    return allMoves
      .filter((move) => {
        const matchChar =
          move.characterId === characterId || move.characterId === null;
        if (!matchChar) return false;
        if (!controlType) return true;
        return move.controlType === "both" || move.controlType === controlType;
      })
      .sort((a, b) => a.sortOrder - b.sortOrder);
  }, [allMoves, characterId, controlType]);

  const movesByCategory = useMemo(() => {
    const grouped: Record<MoveCategory, Move[]> = {
      normal: [],
      unique: [],
      special: [],
      super: [],
      throw: [],
      system: [],
    };
    for (const m of availableMoves) {
      grouped[m.category].push(m);
    }
    return grouped;
  }, [availableMoves]);

  const recipeMoves = useMemo(
    () =>
      recipeMoveIds
        .map((id) => moveMap[id])
        .filter((m): m is Move => Boolean(m)),
    [recipeMoveIds, moveMap]
  );

  if (!isOpen) return null;

  const quickSituations = situationsByCharacter[characterId] ?? [];
  const currentCategoryMoves = movesByCategory[activeMoveCategory];

  const handleChangeCharacter = (nextCharId: string) => {
    if (nextCharId === characterId) return;
    if (recipeMoveIds.length > 0) {
      setRecipeMoveIds([]);
    }
    setCharacterId(nextCharId);
    setActiveMoveCategory("normal");
  };

  const handleSwitchRecipeMode = (nextMode: RecipeInputMode) => {
    if (nextMode === recipeInputMode) return;
    // 技ボタンで組み立てていた内容を自由入力へ引き継ぐ
    if (nextMode === "text" && recipeMoves.length > 0 && !recipeText.trim()) {
      setRecipeText(recipeMoves.map((m) => m.notationNumpad).join(" > "));
    }
    setRecipeInputMode(nextMode);
    setError(null);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const trimmedSituation = situation.trim();
    const trimmedNote = note.trim();

    if (!trimmedSituation) {
      setError("状況を入力または選択してください。");
      return;
    }

    let finalRecipeText = "";
    let finalMoveIds: string[] | undefined = undefined;

    if (recipeInputMode === "builder") {
      if (recipeMoves.length === 0) {
        setError("コンボレシピの技を選択してください。");
        return;
      }
      finalMoveIds = recipeMoveIds;
      finalRecipeText = recipeMoves.map((m) => m.notationNumpad).join(" > ");
    } else {
      const trimmedRecipe = recipeText.trim();
      if (!trimmedRecipe) {
        setError("コンボレシピを入力してください。");
        return;
      }
      finalRecipeText = trimmedRecipe;
      finalMoveIds = undefined;
    }

    if (!trimmedNote) {
      setError("補足メモを入力してください。");
      return;
    }

    onSave(
      {
        characterId,
        controlType: controlType || undefined,
        situation: trimmedSituation,
        recipeText: finalRecipeText,
        moveIds: finalMoveIds,
        note: trimmedNote,
      },
      editingNote?.id
    );
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-end justify-center bg-slate-900/50 p-0 backdrop-blur-[1px] sm:items-center sm:p-4 dark:bg-black/70"
      onClick={onClose}
      role="dialog"
      aria-modal="true"
      aria-label={editingNote ? "非公開メモを編集" : "非公開メモを作成"}
    >
      <div
        className="max-h-[92vh] w-full overflow-y-auto rounded-t-2xl bg-white shadow-xl sm:max-w-2xl sm:rounded-2xl dark:border dark:border-[#2E2447] dark:bg-[#1B152B]"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="sticky top-0 z-10 flex items-center justify-between border-b border-slate-200 bg-white px-4 py-3.5 sm:px-6 dark:border-[#2D2346] dark:bg-[#1B152B]">
          <h2 className="text-base font-bold text-slate-900 dark:text-[#F4F1FF]">
            {editingNote ? "非公開メモを編集" : "非公開メモを作成"}
          </h2>
          <button
            type="button"
            onClick={onClose}
            aria-label="モーダルを閉じる"
            className="rounded-lg p-1.5 text-slate-400 transition-colors hover:bg-slate-100 hover:text-slate-700 dark:text-[#A99EC4] dark:hover:bg-[#251D3A] dark:hover:text-[#F4F1FF]"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4 p-4 sm:p-6">
          {error && (
            <div
              role="alert"
              className="rounded-lg border border-rose-200 bg-rose-50 px-3 py-2 text-xs font-medium text-rose-700 dark:border-rose-500/35 dark:bg-rose-500/15 dark:text-rose-200"
            >
              {error}
            </div>
          )}

          {/* キャラクター & 操作タイプ */}
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
            <label className="flex flex-col gap-1 text-xs font-semibold text-slate-700 dark:text-[#CFC6E8]">
              <span>キャラクター</span>
              <select
                value={characterId}
                onChange={(e) => handleChangeCharacter(e.target.value)}
                className="rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm font-medium text-slate-900 focus:border-blue-500 focus:outline-none dark:border-[#3A2E58] dark:bg-[#140F23] dark:text-[#F4F1FF] dark:focus:border-[#8B5CF6]"
              >
                {characters.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.nameJa}
                  </option>
                ))}
              </select>
            </label>

            <div className="flex flex-col gap-1 text-xs font-semibold text-slate-700 dark:text-[#CFC6E8]">
              <span>操作タイプ（任意）</span>
              <div className="grid grid-cols-3 rounded-lg bg-slate-100 p-0.5 dark:bg-[#251D3A]">
                {(
                  [
                    { value: "", label: "指定なし" },
                    { value: "classic", label: "クラシック" },
                    { value: "modern", label: "モダン" },
                  ] as const
                ).map((item) => (
                  <button
                    key={item.label}
                    type="button"
                    onClick={() => setControlType(item.value)}
                    className={`rounded-md px-2 py-1.5 text-xs font-semibold transition-colors ${
                      controlType === item.value
                        ? "bg-white text-blue-700 shadow-xs dark:bg-[#7C3AED] dark:text-white"
                        : "text-slate-600 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:text-[#F4F1FF]"
                    }`}
                  >
                    {item.label}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* 状況（選択または自由入力） */}
          <div className="space-y-1.5">
            <label
              htmlFor="private-note-situation"
              className="block text-xs font-semibold text-slate-700 dark:text-[#CFC6E8]"
            >
              状況 <span className="text-rose-500 dark:text-rose-400">*</span>
            </label>
            <input
              id="private-note-situation"
              type="text"
              value={situation}
              onChange={(e) => {
                setSituation(e.target.value);
                setError(null);
              }}
              placeholder="例: 画面端パニカン、風水エンジン"
              className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none dark:border-[#3A2E58] dark:bg-[#140F23] dark:text-[#F4F1FF] dark:placeholder:text-[#8E82B3] dark:focus:border-[#8B5CF6]"
            />
            <div className="flex flex-wrap gap-1.5 pt-1">
              {quickSituations.map((sit) => (
                <button
                  key={sit.key}
                  type="button"
                  onClick={() => {
                    setSituation(sit.label);
                    setError(null);
                  }}
                  className={`rounded-full px-2 py-0.5 text-[11px] font-semibold transition-opacity hover:opacity-80 ${sit.badgeClassName}`}
                >
                  {sit.label}
                </button>
              ))}
            </div>
          </div>

          {/* コンボレシピ（技ボタン選択 / 自由入力 切替） */}
          <div className="space-y-2.5 rounded-xl border border-slate-200 bg-slate-50/50 p-3 dark:border-[#2E2447] dark:bg-[#140F23]">
            <div className="flex flex-wrap items-center justify-between gap-2">
              <span className="text-xs font-bold text-slate-700 dark:text-[#E2DCF5]">
                コンボレシピ <span className="text-rose-500 dark:text-rose-400">*</span>
              </span>
              <div
                role="tablist"
                aria-label="レシピ入力方式切替"
                className="inline-grid grid-cols-2 rounded-lg bg-slate-200/75 p-0.5 dark:bg-[#251D3A]"
              >
                <button
                  type="button"
                  role="tab"
                  aria-selected={recipeInputMode === "builder"}
                  onClick={() => handleSwitchRecipeMode("builder")}
                  className={`rounded-md px-2.5 py-1 text-xs font-semibold transition-all ${
                    recipeInputMode === "builder"
                      ? "bg-white text-blue-700 shadow-xs dark:bg-[#7C3AED] dark:text-white"
                      : "text-slate-600 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:text-[#F4F1FF]"
                  }`}
                >
                  技ボタンで選択
                </button>
                <button
                  type="button"
                  role="tab"
                  aria-selected={recipeInputMode === "text"}
                  onClick={() => handleSwitchRecipeMode("text")}
                  className={`rounded-md px-2.5 py-1 text-xs font-semibold transition-all ${
                    recipeInputMode === "text"
                      ? "bg-white text-blue-700 shadow-xs dark:bg-[#7C3AED] dark:text-white"
                      : "text-slate-600 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:text-[#F4F1FF]"
                  }`}
                >
                  自由入力
                </button>
              </div>
            </div>

            {recipeInputMode === "builder" ? (
              <div className="space-y-2.5">
                {/* 表記切替 + カテゴリタブ */}
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <div className="flex flex-wrap gap-1">
                    {MOVE_CATEGORY_TABS.map((tab) => {
                      const count = movesByCategory[tab.key].length;
                      const isActive = activeMoveCategory === tab.key;
                      return (
                        <button
                          key={tab.key}
                          type="button"
                          onClick={() => setActiveMoveCategory(tab.key)}
                          className={`inline-flex items-center gap-1 rounded-md px-2 py-1 text-[11px] font-semibold transition-colors ${
                            isActive
                              ? "bg-blue-600 text-white dark:bg-[#7C3AED]"
                              : "border border-slate-200 bg-white text-slate-600 hover:bg-slate-100 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:bg-[#30264A]"
                          }`}
                        >
                          <span>{tab.label}</span>
                          <span className="text-[10px] opacity-80">{count}</span>
                        </button>
                      );
                    })}
                  </div>

                  <div className="inline-grid grid-cols-3 rounded-md bg-slate-200/75 p-0.5 dark:bg-[#251D3A]">
                    {NOTATION_TABS.map((item) => (
                      <button
                        key={item.mode}
                        type="button"
                        onClick={() => onChangeNotationMode(item.mode)}
                        className={`rounded px-2 py-0.5 text-[11px] font-semibold transition-colors ${
                          notationMode === item.mode
                            ? "bg-blue-600 text-white dark:bg-[#7C3AED]"
                            : "text-slate-600 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:text-[#F4F1FF]"
                        }`}
                      >
                        {item.label}
                      </button>
                    ))}
                  </div>
                </div>

                {/* 技ボタングリッド */}
                {isLoadingMoves && currentCategoryMoves.length === 0 ? (
                  <div className="flex items-center justify-center gap-2 py-6 text-xs text-slate-500 dark:text-[#A99EC4]">
                    <Loader2
                      className="h-4 w-4 animate-spin text-blue-600 dark:text-[#A78BFA]"
                      aria-hidden="true"
                    />
                    <span>技データを読み込み中...</span>
                  </div>
                ) : currentCategoryMoves.length > 0 ? (
                  <div
                    className={`grid max-h-48 gap-1.5 overflow-y-auto overscroll-contain pr-0.5 ${
                      notationMode === "name"
                        ? "grid-cols-2 sm:grid-cols-3"
                        : "grid-cols-3 sm:grid-cols-4"
                    }`}
                  >
                    {currentCategoryMoves.map((move) => (
                      <button
                        key={move.id}
                        type="button"
                        onClick={() => {
                          setRecipeMoveIds((prev) => [...prev, move.id]);
                          setError(null);
                        }}
                        title={`${move.notationName} (${move.notationNumpad})`}
                        className="flex min-h-[38px] items-center justify-center rounded-lg border border-slate-200 bg-white px-1.5 py-1.5 text-center transition-all hover:border-blue-400 hover:bg-blue-50/50 active:scale-[0.98] dark:border-[#3A2E58] dark:bg-[#1B152B] dark:hover:border-[#8B5CF6] dark:hover:bg-[#251D3A]"
                      >
                        <span
                          className={`inline-flex max-w-full items-center justify-center text-xs font-bold text-slate-900 dark:text-[#F4F1FF] ${
                            notationMode === "command"
                              ? "leading-tight"
                              : "truncate"
                          }`}
                        >
                          <MoveNotation
                            move={move}
                            notationMode={notationMode}
                          />
                        </span>
                      </button>
                    ))}
                  </div>
                ) : (
                  <p className="py-4 text-center text-xs text-slate-500 dark:text-[#A99EC4]">
                    このカテゴリの技はありません。
                  </p>
                )}

                {/* 組み立て中レシピ */}
                <div className="rounded-lg border border-slate-200 bg-white p-2.5 dark:border-[#2E2447] dark:bg-[#1B152B]">
                  <div className="mb-2 flex items-center justify-between gap-2">
                    <span className="text-[11px] font-semibold text-slate-500 dark:text-[#A99EC4]">
                      組み立て中 ({recipeMoves.length} パーツ)
                    </span>
                    <div className="flex items-center gap-1">
                      <button
                        type="button"
                        onClick={() =>
                          setRecipeMoveIds((prev) => prev.slice(0, -1))
                        }
                        disabled={recipeMoves.length === 0}
                        className="inline-flex items-center gap-1 rounded border border-slate-200 px-2 py-0.5 text-[11px] font-medium text-slate-600 hover:bg-slate-50 disabled:opacity-40 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:bg-[#30264A]"
                      >
                        <Undo2 className="h-3 w-3" aria-hidden="true" />
                        戻す
                      </button>
                      <button
                        type="button"
                        onClick={() => setRecipeMoveIds([])}
                        disabled={recipeMoves.length === 0}
                        className="inline-flex items-center gap-1 rounded border border-rose-200 bg-rose-50/60 px-2 py-0.5 text-[11px] font-medium text-rose-700 hover:bg-rose-100 disabled:opacity-40 dark:border-rose-500/35 dark:bg-rose-500/15 dark:text-rose-200 dark:hover:bg-rose-500/25"
                      >
                        <Trash2 className="h-3 w-3" aria-hidden="true" />
                        消去
                      </button>
                    </div>
                  </div>

                  {recipeMoves.length > 0 ? (
                    <div className="flex flex-wrap items-center gap-x-1 gap-y-1.5">
                      {recipeMoves.map((move, index) => (
                        <div
                          key={`${move.id}-${index}`}
                          className="inline-flex max-w-full items-center gap-1"
                        >
                          <span
                            className={`inline-flex max-w-full items-center gap-1 rounded-md border py-0.5 pr-1 pl-2 text-xs ${getMoveChipStyle(
                              move
                            )}`}
                          >
                            <span className="inline-flex items-center break-words">
                              <MoveNotation
                                move={move}
                                notationMode={notationMode}
                              />
                            </span>
                            <button
                              type="button"
                              onClick={() =>
                                setRecipeMoveIds((prev) =>
                                  prev.filter((_, i) => i !== index)
                                )
                              }
                              aria-label={`${move.notationName} を削除`}
                              className="rounded p-0.5 text-slate-400 hover:bg-slate-200/80 hover:text-slate-700 dark:text-[#8E82B3] dark:hover:bg-[#3A2E58] dark:hover:text-[#F4F1FF]"
                            >
                              <X className="h-3 w-3" aria-hidden="true" />
                            </button>
                          </span>
                          {index < recipeMoves.length - 1 && (
                            <ChevronRight
                              className="h-3.5 w-3.5 shrink-0 text-slate-400 dark:text-[#7D71A1]"
                              aria-hidden="true"
                            />
                          )}
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="py-2 text-center text-xs text-slate-400 dark:text-[#8E82B3]">
                      上の技ボタンをタップして組み立ててください
                    </p>
                  )}
                </div>
              </div>
            ) : (
              <textarea
                id="private-note-recipe"
                rows={2}
                value={recipeText}
                onChange={(e) => {
                  setRecipeText(e.target.value);
                  setError(null);
                }}
                placeholder="例: 2中K > CDR > 5大P > 236中K"
                className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 font-mono text-sm text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none dark:border-[#3A2E58] dark:bg-[#1B152B] dark:text-[#F4F1FF] dark:placeholder:text-[#8E82B3] dark:focus:border-[#8B5CF6]"
              />
            )}
          </div>

          {/* 補足メモ（必須） */}
          <div className="space-y-1">
            <label
              htmlFor="private-note-body"
              className="block text-xs font-semibold text-slate-700 dark:text-[#CFC6E8]"
            >
              補足メモ・コツ <span className="text-rose-500 dark:text-rose-400">*</span>
            </label>
            <textarea
              id="private-note-body"
              rows={3}
              value={note}
              onChange={(e) => {
                setNote(e.target.value);
                setError(null);
              }}
              placeholder="タイミングのコツ、距離限定、起き攻めのフレーム状況など"
              className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none dark:border-[#3A2E58] dark:bg-[#140F23] dark:text-[#F4F1FF] dark:placeholder:text-[#8E82B3] dark:focus:border-[#8B5CF6]"
            />
          </div>

          {/* アクション */}
          <div className="flex items-center justify-end gap-2 border-t border-slate-100 pt-3 dark:border-[#2D2346]">
            <button
              type="button"
              onClick={onClose}
              className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-600 transition-colors hover:bg-slate-50 sm:text-sm dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:bg-[#30264A]"
            >
              キャンセル
            </button>
            <button
              type="submit"
              className="rounded-lg bg-blue-600 px-4 py-2 text-xs font-semibold text-white transition-colors hover:bg-blue-700 sm:text-sm dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
            >
              {editingNote ? "更新する" : "保存する"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
