"use client";

import { useEffect, useState } from "react";
import { X } from "lucide-react";
import type {
  Character,
  ControlType,
  PrivateNote,
  SituationDefinition,
} from "@/types/combo";
import type { CreatePrivateNoteInput } from "@/hooks/useComboNoteStorage";

interface PrivateNoteFormModalProps {
  isOpen: boolean;
  characters: Character[];
  situationsByCharacter: Record<string, SituationDefinition[]>;
  defaultCharacterId: string;
  editingNote: PrivateNote | null;
  onSave: (data: CreatePrivateNoteInput, editingId?: string) => void;
  onClose: () => void;
}

export function PrivateNoteFormModal({
  isOpen,
  characters,
  situationsByCharacter,
  defaultCharacterId,
  editingNote,
  onSave,
  onClose,
}: PrivateNoteFormModalProps) {
  const [characterId, setCharacterId] = useState(
    editingNote?.characterId ?? defaultCharacterId
  );
  const [controlType, setControlType] = useState<ControlType | "">(
    editingNote?.controlType ?? ""
  );
  const [situation, setSituation] = useState(editingNote?.situation ?? "");
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

  if (!isOpen) return null;

  const quickSituations = situationsByCharacter[characterId] ?? [];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const trimmedSituation = situation.trim();
    const trimmedRecipe = recipeText.trim();
    const trimmedNote = note.trim();

    if (!trimmedSituation) {
      setError("状況を入力または選択してください。");
      return;
    }
    if (!trimmedRecipe) {
      setError("コンボレシピを入力してください。");
      return;
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
        recipeText: trimmedRecipe,
        note: trimmedNote,
      },
      editingNote?.id
    );
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-end justify-center bg-slate-900/50 p-0 backdrop-blur-[1px] sm:items-center sm:p-4"
      onClick={onClose}
      role="dialog"
      aria-modal="true"
      aria-label={editingNote ? "非公開メモを編集" : "非公開メモを作成"}
    >
      <div
        className="max-h-[92vh] w-full overflow-y-auto rounded-t-2xl bg-white shadow-xl sm:max-w-lg sm:rounded-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="sticky top-0 z-10 flex items-center justify-between border-b border-slate-200 bg-white px-4 py-3.5 sm:px-6">
          <h2 className="text-base font-bold text-slate-900">
            {editingNote ? "非公開メモを編集" : "非公開メモを作成"}
          </h2>
          <button
            type="button"
            onClick={onClose}
            aria-label="モーダルを閉じる"
            className="rounded-lg p-1.5 text-slate-400 transition-colors hover:bg-slate-100 hover:text-slate-700"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4 p-4 sm:p-6">
          {error && (
            <div
              role="alert"
              className="rounded-lg border border-rose-200 bg-rose-50 px-3 py-2 text-xs font-medium text-rose-700"
            >
              {error}
            </div>
          )}

          {/* キャラクター & 操作タイプ */}
          <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
            <label className="flex flex-col gap-1 text-xs font-semibold text-slate-700">
              <span>キャラクター</span>
              <select
                value={characterId}
                onChange={(e) => setCharacterId(e.target.value)}
                className="rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm font-medium text-slate-900 focus:border-blue-500 focus:outline-none"
              >
                {characters.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.nameJa}
                  </option>
                ))}
              </select>
            </label>

            <div className="flex flex-col gap-1 text-xs font-semibold text-slate-700">
              <span>操作タイプ（任意）</span>
              <div className="grid grid-cols-3 rounded-lg bg-slate-100 p-0.5">
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
                        ? "bg-white text-blue-700 shadow-xs"
                        : "text-slate-600 hover:text-slate-900"
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
              className="block text-xs font-semibold text-slate-700"
            >
              状況 <span className="text-rose-500">*</span>
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
              className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none"
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

          {/* コンボレシピ（自由テキスト入力） */}
          <div className="space-y-1">
            <label
              htmlFor="private-note-recipe"
              className="block text-xs font-semibold text-slate-700"
            >
              コンボレシピ（自由入力） <span className="text-rose-500">*</span>
            </label>
            <textarea
              id="private-note-recipe"
              rows={2}
              value={recipeText}
              onChange={(e) => {
                setRecipeText(e.target.value);
                setError(null);
              }}
              placeholder="例: 2中K > DR > 5大P > 236中K"
              className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 font-mono text-sm text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none"
            />
          </div>

          {/* 補足メモ（必須） */}
          <div className="space-y-1">
            <label
              htmlFor="private-note-body"
              className="block text-xs font-semibold text-slate-700"
            >
              補足メモ・コツ <span className="text-rose-500">*</span>
            </label>
            <textarea
              id="private-note-body"
              rows={4}
              value={note}
              onChange={(e) => {
                setNote(e.target.value);
                setError(null);
              }}
              placeholder="タイミングのコツ、距離限定、起き攻めのフレーム状況など"
              className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none"
            />
          </div>

          {/* アクション */}
          <div className="flex items-center justify-end gap-2 border-t border-slate-100 pt-3">
            <button
              type="button"
              onClick={onClose}
              className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-xs font-semibold text-slate-600 transition-colors hover:bg-slate-50 sm:text-sm"
            >
              キャンセル
            </button>
            <button
              type="submit"
              className="rounded-lg bg-blue-600 px-4 py-2 text-xs font-semibold text-white transition-colors hover:bg-blue-700 sm:text-sm"
            >
              {editingNote ? "更新する" : "保存する"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
