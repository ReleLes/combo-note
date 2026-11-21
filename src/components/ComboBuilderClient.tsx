"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  AlertCircle,
  AlertTriangle,
  CheckCircle2,
  ChevronRight,
  ExternalLink,
  Info,
  Lock,
  LogIn,
  PlusCircle,
  Send,
  ShieldCheck,
  Trash2,
  Undo2,
  X,
} from "lucide-react";
import type {
  Character,
  Combo,
  ComboCategory,
  ControlType,
  GameVersion,
  Move,
  MoveCategory,
  NotationMode,
  SituationDefinition,
} from "@/types/combo";
import {
  COMBO_CATEGORIES,
  buildRecipeSignature,
} from "@/data/seed/common";
import { getSituationsForCharacter } from "@/data/seed";
import { createClient } from "@/lib/supabase/client";
import { useAuth } from "@/components/AuthProvider";
import { usePreferences, useSavedCombos } from "@/hooks/useComboNoteStorage";
import { ComboDetailModal } from "@/components/ComboDetailModal";
import { MoveNotation } from "@/components/CommandNotation";

interface ComboBuilderClientProps {
  characters: Character[];
  allMoves: Move[];
  versions: GameVersion[];
}

interface DuplicateComboRow {
  id: string;
  author_id: string | null;
  author_name: string | null;
  character_id: string;
  control_type: ControlType;
  move_ids: unknown;
  recipe_signature: string;
  situations: string[] | null;
  category: ComboCategory;
  damage: number | null;
  drive_cost: number | string | null;
  sa_cost: number | null;
  stock_cost: number | null;
  stock_gain: number | null;
  has_oki: boolean | null;
  note: string;
  version_id: string;
  likes_count: number | null;
  created_at: string;
  updated_at: string;
}

const MOVE_CATEGORY_TABS: { key: MoveCategory; label: string }[] = [
  { key: "normal", label: "通常技" },
  { key: "unique", label: "特殊技" },
  { key: "special", label: "必殺技" },
  { key: "super", label: "SA" },
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
      return "border-slate-200 bg-slate-100 text-slate-700";
    case "super":
      return "border-indigo-200 bg-indigo-50 text-indigo-800 font-semibold";
    case "special":
      return "border-blue-200 bg-blue-50/70 text-slate-900 font-medium";
    default:
      return "border-slate-200 bg-white text-slate-900 font-medium";
  }
}

function mapRowToCombo(row: DuplicateComboRow): Combo {
  const moveIds = Array.isArray(row.move_ids)
    ? row.move_ids.filter((id): id is string => typeof id === "string")
    : [];
  const saRaw = row.sa_cost ?? 0;
  const saCost: 0 | 1 | 2 | 3 =
    saRaw === 1 || saRaw === 2 || saRaw === 3 ? saRaw : 0;

  return {
    id: row.id,
    authorId: row.author_id ?? "seed",
    authorName: row.author_name ?? undefined,
    characterId: row.character_id,
    controlType: row.control_type,
    moveIds,
    recipeSignature: row.recipe_signature,
    situations: row.situations ?? [],
    category: row.category,
    damage: row.damage,
    driveCost: Number(row.drive_cost ?? 0),
    saCost,
    stockCost: row.stock_cost ?? 0,
    stockGain: row.stock_gain ?? 0,
    hasOki: row.has_oki ?? false,
    note: row.note,
    versionId: row.version_id,
    likesCount: row.likes_count ?? 0,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export function ComboBuilderClient({
  characters,
  allMoves,
  versions,
}: ComboBuilderClientProps) {
  const router = useRouter();
  const { user, isLoading } = useAuth();
  const {
    controlType: preferredControlType,
    notationMode,
    setControlType: savePreferredControlType,
    setNotationMode,
  } = usePreferences();
  const { isSaved, toggleSavedCombo } = useSavedCombos();

  // Step 1: ビルダー状態
  const [selectedCharacterId, setSelectedCharacterId] = useState<string>(
    characters[0]?.id ?? "akuma"
  );
  const [controlType, setControlType] = useState<ControlType>(
    preferredControlType
  );
  const [activeMoveCategory, setActiveMoveCategory] =
    useState<MoveCategory>("normal");
  const [recipeMoveIds, setRecipeMoveIds] = useState<string[]>([]);

  // Step 2: メタ情報フォーム状態
  const [selectedSituations, setSelectedSituations] = useState<string[]>([]);
  const [category, setCategory] = useState<ComboCategory>("standard");
  const [damageInput, setDamageInput] = useState<string>("");
  const [driveCost, setDriveCost] = useState<number>(0);
  const [saCost, setSaCost] = useState<0 | 1 | 2 | 3>(0);
  const [stockCost, setStockCost] = useState<number>(0);
  const [stockGain, setStockGain] = useState<number>(0);
  const [hasOki, setHasOki] = useState<boolean>(false);
  const [note, setNote] = useState<string>("");

  // 重複チェック・送信状態
  const [duplicateCheck, setDuplicateCheck] = useState<{
    signature: string;
    combo: Combo | null;
  }>({ signature: "", combo: null });
  const [previewDuplicateModal, setPreviewDuplicateModal] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [submitSuccess, setSubmitSuccess] = useState<string | null>(null);

  const selectedCharacter = useMemo(
    () =>
      characters.find((c) => c.id === selectedCharacterId) ?? characters[0],
    [characters, selectedCharacterId]
  );

  const moveMap = useMemo(() => {
    const map: Record<string, Move> = {};
    for (const m of allMoves) {
      map[m.id] = m;
    }
    return map;
  }, [allMoves]);

  const versionMap = useMemo(() => {
    const map: Record<string, GameVersion> = {};
    for (const v of versions) {
      map[v.id] = v;
    }
    return map;
  }, [versions]);

  const characterSituations = useMemo(
    () => getSituationsForCharacter(selectedCharacterId),
    [selectedCharacterId]
  );

  const situationMap = useMemo(() => {
    const map: Record<string, SituationDefinition> = {};
    for (const s of characterSituations) {
      map[s.key] = s;
    }
    return map;
  }, [characterSituations]);

  // 選択中キャラ＋操作タイプに該当する技一覧（システム共通パーツ含む）
  const availableMoves = useMemo(() => {
    return allMoves
      .filter((move) => {
        const matchCharacter =
          move.characterId === selectedCharacterId || move.characterId === null;
        const matchControl =
          move.controlType === "both" || move.controlType === controlType;
        return matchCharacter && matchControl;
      })
      .sort((a, b) => a.sortOrder - b.sortOrder);
  }, [allMoves, selectedCharacterId, controlType]);

  const movesByCategory = useMemo(() => {
    const grouped: Record<MoveCategory, Move[]> = {
      normal: [],
      unique: [],
      special: [],
      super: [],
      system: [],
    };
    for (const move of availableMoves) {
      grouped[move.category].push(move);
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

  const recipeSignature = useMemo(() => {
    if (recipeMoveIds.length < 2) return "";
    return buildRecipeSignature(selectedCharacterId, controlType, recipeMoveIds);
  }, [selectedCharacterId, controlType, recipeMoveIds]);

  const duplicateCombo =
    recipeSignature && duplicateCheck.signature === recipeSignature
      ? duplicateCheck.combo
      : null;

  const isCheckingDuplicate = Boolean(
    user && recipeSignature && duplicateCheck.signature !== recipeSignature
  );

  // 重複コンボ自動チェック（recipe_signature 照合）
  useEffect(() => {
    if (!user || !recipeSignature) {
      return;
    }

    let cancelled = false;

    const timer = window.setTimeout(async () => {
      try {
        const supabase = createClient();
        const { data, error } = await supabase
          .from("combos")
          .select("*")
          .eq("character_id", selectedCharacterId)
          .eq("control_type", controlType)
          .eq("recipe_signature", recipeSignature)
          .limit(1)
          .maybeSingle();

        if (cancelled) return;
        setDuplicateCheck({
          signature: recipeSignature,
          combo: !error && data ? mapRowToCombo(data as DuplicateComboRow) : null,
        });
      } catch {
        if (!cancelled) {
          setDuplicateCheck({ signature: recipeSignature, combo: null });
        }
      }
    }, 250);

    return () => {
      cancelled = true;
      window.clearTimeout(timer);
    };
  }, [user, selectedCharacterId, controlType, recipeSignature]);

  const handleChangeCharacter = (nextCharId: string) => {
    if (nextCharId === selectedCharacterId) return;
    if (recipeMoveIds.length > 0) {
      const ok = window.confirm(
        "キャラクターを変更すると、組み立て中のレシピがリセットされます。よろしいですか？"
      );
      if (!ok) return;
      setRecipeMoveIds([]);
    }
    setSelectedCharacterId(nextCharId);
    setActiveMoveCategory("normal");
    setStockCost(0);
    setStockGain(0);
    // 別キャラ固有の状況キーを除外
    const nextAllowed = new Set(
      getSituationsForCharacter(nextCharId).map((s) => s.key)
    );
    setSelectedSituations((prev) => prev.filter((key) => nextAllowed.has(key)));
  };

  const handleChangeControlType = (nextControl: ControlType) => {
    if (nextControl === controlType) return;
    if (recipeMoveIds.length > 0) {
      const ok = window.confirm(
        "操作タイプを変更すると、組み立て中のレシピがリセットされます。よろしいですか？"
      );
      if (!ok) return;
      setRecipeMoveIds([]);
    }
    setControlType(nextControl);
    setActiveMoveCategory("normal");
  };

  const handleAppendMove = (moveId: string) => {
    setRecipeMoveIds((prev) => [...prev, moveId]);
    setFormError(null);
  };

  const handleUndo = () => {
    setRecipeMoveIds((prev) => prev.slice(0, -1));
  };

  const handleRemoveAt = (index: number) => {
    setRecipeMoveIds((prev) => prev.filter((_, i) => i !== index));
  };

  const handleClear = () => {
    setRecipeMoveIds([]);
  };

  const toggleSituation = (key: string) => {
    setSelectedSituations((prev) =>
      prev.includes(key) ? prev.filter((item) => item !== key) : [...prev, key]
    );
    setFormError(null);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user || isSubmitting) return;

    setFormError(null);

    if (recipeMoveIds.length < 2) {
      setFormError("コンボレシピは2つ以上の技を選択してください。");
      return;
    }
    if (selectedSituations.length === 0) {
      setFormError("状況タグを1つ以上選択してください。");
      return;
    }

    const trimmedNote = note.trim();
    if (!trimmedNote) {
      setFormError("補足メモを入力してください（タイミングのコツや距離限定など）。");
      return;
    }

    let parsedDamage: number | null = null;
    if (damageInput.trim() !== "") {
      const num = Number(damageInput);
      if (!Number.isFinite(num) || num < 0 || num > 30000) {
        setFormError("ダメージは 0〜30000 の数値で入力してください。");
        return;
      }
      parsedDamage = Math.round(num);
    }

    if (!Number.isFinite(driveCost) || driveCost < 0 || driveCost > 6) {
      setFormError("消費Dゲージは 0〜6 の範囲で入力してください。");
      return;
    }

    setIsSubmitting(true);
    const supabase = createClient();

    try {
      // 1. 現在日時から該当ゲームバージョンを自動判定
      const nowIso = new Date().toISOString();
      const { data: latestVersion, error: versionError } = await supabase
        .from("game_versions")
        .select("id")
        .lte("released_at", nowIso)
        .order("released_at", { ascending: false })
        .limit(1)
        .maybeSingle();

      if (versionError) {
        throw new Error(
          `ゲームバージョンの判定に失敗しました: ${versionError.message}`
        );
      }

      const resolvedVersionId =
        (latestVersion?.id as string | undefined) ?? versions[0]?.id;
      if (!resolvedVersionId) {
        throw new Error("ゲームバージョンマスタが見つかりませんでした。");
      }

      const authorName = user.email ? user.email.split("@")[0] : "ユーザー";

      // 2. combos テーブルへ INSERT
      const { error: insertError } = await supabase.from("combos").insert({
        author_id: user.id,
        author_name: authorName,
        character_id: selectedCharacterId,
        control_type: controlType,
        move_ids: recipeMoveIds,
        recipe_signature: recipeSignature,
        situations: selectedSituations,
        category,
        damage: parsedDamage,
        drive_cost: driveCost,
        sa_cost: saCost,
        stock_cost: selectedCharacter?.stockMeta ? stockCost : 0,
        stock_gain: selectedCharacter?.stockMeta ? stockGain : 0,
        has_oki: hasOki,
        note: trimmedNote,
        version_id: resolvedVersionId,
      });

      if (insertError) {
        throw new Error(`コンボの投稿に失敗しました: ${insertError.message}`);
      }

      // 投稿した操作タイプを一覧側にも引き継ぐ
      savePreferredControlType(controlType);
      setSubmitSuccess(
        "公開コンボを投稿しました！キャラクターのコンボ一覧へ移動します..."
      );

      const targetSlug = selectedCharacter?.slug ?? selectedCharacterId;
      window.setTimeout(() => {
        router.push(`/characters/${targetSlug}`);
        router.refresh();
      }, 700);
    } catch (err) {
      const message =
        err instanceof Error
          ? err.message
          : "コンボの投稿中にエラーが発生しました。";
      setFormError(message);
      setIsSubmitting(false);
    }
  };

  // 認証確認中
  if (isLoading) {
    return (
      <div className="mx-auto w-full max-w-5xl animate-pulse px-3 py-6 sm:px-6">
        <div className="h-44 rounded-2xl border border-slate-200 bg-white" />
      </div>
    );
  }

  // 未ログイン時のガード表示
  if (!user) {
    return (
      <div className="mx-auto w-full max-w-lg px-3 py-10 sm:px-6">
        <div className="rounded-2xl border border-slate-200 bg-white p-6 text-center shadow-xs">
          <div className="mx-auto mb-3 flex h-11 w-11 items-center justify-center rounded-full bg-blue-50 text-blue-600">
            <Lock className="h-5 w-5" aria-hidden="true" />
          </div>
          <h1 className="text-lg font-bold text-slate-900">
            公開コンボの投稿にはログインが必要です
          </h1>
          <p className="mt-1.5 text-xs leading-relaxed text-slate-600 sm:text-sm">
            ログインすると、技ボタン選択式ビルダーで公開コンボを作成・共有できます。
          </p>
          <div className="mt-5 flex flex-wrap items-center justify-center gap-2.5">
            <Link
              href="/login?next=%2Fcombos%2Fnew"
              className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white shadow-xs transition-colors hover:bg-blue-700"
            >
              <LogIn className="h-4 w-4" aria-hidden="true" />
              <span>ログイン画面へ進む</span>
            </Link>
            <Link
              href="/"
              className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 transition-colors hover:bg-slate-50"
            >
              キャラ一覧へ戻る
            </Link>
          </div>
        </div>
      </div>
    );
  }

  const currentCategoryMoves = movesByCategory[activeMoveCategory];
  const stockMeta = selectedCharacter?.stockMeta;

  return (
    <form
      onSubmit={handleSubmit}
      className="mx-auto w-full max-w-5xl px-3 py-4 pb-10 sm:px-6 sm:py-6"
    >
      {/* ページ見出し */}
      <div className="mb-4">
        <h1 className="flex items-center gap-2 text-xl font-bold tracking-tight text-slate-900 sm:text-2xl">
          <PlusCircle className="h-5 w-5 text-blue-600" aria-hidden="true" />
          <span>公開コンボを投稿</span>
        </h1>
        <p className="mt-0.5 text-xs text-slate-500">
          技ボタンをタップしてレシピを組み立て、状況と補足メモを添えて共有できます。
        </p>
      </div>

      {/* 1. キャラクター & 操作タイプ & 表記モード選択 */}
      <section
        aria-label="キャラクター・操作タイプ・表記選択"
        className="mb-4 rounded-xl border border-slate-200 bg-white p-3.5 shadow-xs sm:p-4"
      >
        <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
          <label className="flex flex-col gap-1.5 text-xs font-bold text-slate-700">
            <span>対象キャラクター</span>
            <select
              value={selectedCharacterId}
              onChange={(e) => handleChangeCharacter(e.target.value)}
              className="rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm font-semibold text-slate-900 focus:border-blue-500 focus:outline-none"
            >
              {characters.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.nameJa}（{c.nameEn}）
                </option>
              ))}
            </select>
          </label>

          <div className="flex flex-col gap-1.5 text-xs font-bold text-slate-700">
            <span>操作タイプ</span>
            <div
              role="tablist"
              aria-label="操作タイプ選択"
              className="grid grid-cols-2 rounded-lg bg-slate-100 p-1"
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
                  onClick={() => handleChangeControlType(item.value)}
                  className={`rounded-md py-1.5 text-xs font-semibold transition-all sm:text-sm ${
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

          <div className="flex flex-col gap-1.5 text-xs font-bold text-slate-700">
            <span>表記モード</span>
            <div
              role="tablist"
              aria-label="表記モード選択"
              className="grid grid-cols-3 rounded-lg bg-slate-100 p-1"
            >
              {NOTATION_TABS.map((item) => (
                <button
                  key={item.mode}
                  type="button"
                  role="tab"
                  aria-selected={notationMode === item.mode}
                  onClick={() => setNotationMode(item.mode)}
                  className={`rounded-md py-1.5 text-xs font-semibold transition-all sm:text-sm ${
                    notationMode === item.mode
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

      {/* 2. 技ボタン選択式ビルダー */}
      <section
        aria-label="技ボタンビルダー"
        className="mb-4 rounded-xl border border-slate-200 bg-white p-3.5 shadow-xs sm:p-4"
      >
        <div className="mb-3 flex items-center justify-between gap-2">
          <h2 className="text-sm font-bold text-slate-900">
            技を選択して追加 <span className="text-rose-500">*</span>
          </h2>
          <span className="text-[11px] text-slate-500">
            タップでレシピ末尾に追加
          </span>
        </div>

        {/* カテゴリ別タブ */}
        <div
          role="tablist"
          aria-label="技カテゴリ切替"
          className="mb-3 flex flex-wrap gap-1.5 border-b border-slate-100 pb-3"
        >
          {MOVE_CATEGORY_TABS.map((tab) => {
            const count = movesByCategory[tab.key].length;
            const isActive = activeMoveCategory === tab.key;
            return (
              <button
                key={tab.key}
                type="button"
                role="tab"
                aria-selected={isActive}
                onClick={() => setActiveMoveCategory(tab.key)}
                className={`inline-flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-xs font-semibold transition-colors sm:px-3 ${
                  isActive
                    ? "bg-blue-600 text-white shadow-xs"
                    : "bg-slate-100 text-slate-700 hover:bg-slate-200"
                }`}
              >
                <span>{tab.label}</span>
                <span
                  className={`rounded-full px-1.5 py-0.2 text-[10px] ${
                    isActive
                      ? "bg-white/20 text-white"
                      : "bg-white text-slate-500"
                  }`}
                >
                  {count}
                </span>
              </button>
            );
          })}
        </div>

        {/* 技ボタングリッド（選択中の表記モードのみ表示・CDR/DR/DIは常にアイコン統一） */}
        {currentCategoryMoves.length > 0 ? (
          <div className="grid grid-cols-2 gap-2 sm:grid-cols-3 md:grid-cols-4">
            {currentCategoryMoves.map((move) => (
              <button
                key={move.id}
                type="button"
                onClick={() => handleAppendMove(move.id)}
                title={`${move.notationName} (${move.notationNumpad})`}
                className="flex min-h-[44px] items-center justify-center rounded-lg border border-slate-200 bg-slate-50/60 px-2.5 py-2 text-center transition-all hover:border-blue-400 hover:bg-blue-50/50 active:scale-[0.98]"
              >
                <span className="inline-flex max-w-full items-center truncate text-xs font-bold text-slate-900 sm:text-sm">
                  <MoveNotation move={move} notationMode={notationMode} />
                </span>
              </button>
            ))}
          </div>
        ) : (
          <p className="py-6 text-center text-xs text-slate-500">
            このカテゴリに登録されている技はありません。
          </p>
        )}
      </section>

      {/* 3. 組み立て中のレシピ（選択中の表記モードでリアルタイム表示） */}
      <section
        aria-label="組み立て中のレシピ"
        className="mb-4 rounded-xl border border-slate-200 bg-white p-3.5 shadow-xs sm:p-4"
      >
        <div className="mb-3 flex flex-wrap items-center justify-between gap-2">
          <div className="flex items-center gap-2">
            <h2 className="text-sm font-bold text-slate-900">
              組み立て中のレシピ
            </h2>
            <span className="rounded-full bg-slate-100 px-2 py-0.5 text-xs font-semibold text-slate-600">
              {recipeMoves.length} パーツ
            </span>
            {recipeMoves.length === 1 && (
              <span className="text-[11px] font-medium text-amber-700">
                ※ 2つ以上選択してください
              </span>
            )}
          </div>

          <div className="flex items-center gap-1.5">
            <button
              type="button"
              onClick={handleUndo}
              disabled={recipeMoves.length === 0}
              className="inline-flex items-center gap-1 rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-xs font-semibold text-slate-700 transition-colors hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
            >
              <Undo2 className="h-3.5 w-3.5" aria-hidden="true" />
              <span>1つ戻す</span>
            </button>
            <button
              type="button"
              onClick={handleClear}
              disabled={recipeMoves.length === 0}
              className="inline-flex items-center gap-1 rounded-lg border border-rose-200 bg-rose-50/60 px-2.5 py-1.5 text-xs font-semibold text-rose-700 transition-colors hover:bg-rose-100 disabled:cursor-not-allowed disabled:opacity-40"
            >
              <Trash2 className="h-3.5 w-3.5" aria-hidden="true" />
              <span>全消去</span>
            </button>
          </div>
        </div>

        {recipeMoves.length > 0 ? (
          <div className="rounded-lg border border-slate-100 bg-slate-50/70 p-2.5 sm:p-3">
            <div className="flex flex-wrap items-center gap-x-1 gap-y-1.5">
              {recipeMoves.map((move, index) => (
                <div
                  key={`${move.id}-${index}`}
                  className="inline-flex max-w-full items-center gap-1"
                >
                  <span
                    className={`inline-flex max-w-full items-center gap-1 rounded-md border py-0.5 pr-1 pl-2 text-xs leading-snug sm:text-sm ${getMoveChipStyle(
                      move
                    )}`}
                  >
                    <span className="inline-flex items-center break-words">
                      <MoveNotation move={move} notationMode={notationMode} />
                    </span>
                    <button
                      type="button"
                      onClick={() => handleRemoveAt(index)}
                      aria-label={`${move.notationName} を削除`}
                      className="rounded p-0.5 text-slate-400 transition-colors hover:bg-slate-200/80 hover:text-slate-700"
                    >
                      <X className="h-3 w-3" aria-hidden="true" />
                    </button>
                  </span>
                  {index < recipeMoves.length - 1 && (
                    <ChevronRight
                      className="h-3.5 w-3.5 shrink-0 text-slate-400"
                      aria-hidden="true"
                    />
                  )}
                </div>
              ))}
            </div>
          </div>
        ) : (
          <div className="rounded-lg border border-dashed border-slate-200 bg-slate-50/50 px-3 py-6 text-center text-xs text-slate-500">
            上の技ボタンをタップして、コンボの始動技から順番に組み立ててください。
          </div>
        )}
      </section>

      {/* 5. 状況・カテゴリ・数値・補足メモ入力 */}
      <section
        aria-label="コンボの属性と補足メモ"
        className="mb-5 space-y-5 rounded-xl border border-slate-200 bg-white p-3.5 shadow-xs sm:p-5"
      >
        {/* 状況タグ選択（必須・複数選択可） */}
        <div>
          <div className="mb-2 flex items-center justify-between gap-2">
            <span className="text-sm font-bold text-slate-900">
              状況タグ（複数選択可） <span className="text-rose-500">*</span>
            </span>
            <span className="text-[11px] text-slate-500">
              カードの最上部に表示されます
            </span>
          </div>
          <div className="flex flex-wrap gap-1.5">
            {characterSituations.map((sit) => {
              const isSelected = selectedSituations.includes(sit.key);
              return (
                <button
                  key={sit.key}
                  type="button"
                  onClick={() => toggleSituation(sit.key)}
                  aria-pressed={isSelected}
                  className={`inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold transition-all ${
                    isSelected
                      ? `${sit.badgeClassName} ring-2 ring-blue-600 ring-offset-1`
                      : "border border-slate-200 bg-slate-50 text-slate-600 hover:bg-slate-100"
                  }`}
                >
                  {sit.label}
                </button>
              );
            })}
          </div>
        </div>

        {/* カテゴリ選択（必須） */}
        <div>
          <span className="mb-2 block text-sm font-bold text-slate-900">
            カテゴリ <span className="text-rose-500">*</span>
          </span>
          <div className="grid grid-cols-2 gap-2 sm:grid-cols-4">
            {COMBO_CATEGORIES.map((cat) => {
              const isSelected = category === cat.key;
              return (
                <button
                  key={cat.key}
                  type="button"
                  onClick={() => setCategory(cat.key)}
                  aria-pressed={isSelected}
                  className={`rounded-lg border px-3 py-2 text-xs font-semibold transition-all sm:text-sm ${
                    isSelected
                      ? "border-blue-600 bg-blue-50 text-blue-700"
                      : "border-slate-200 bg-white text-slate-700 hover:bg-slate-50"
                  }`}
                >
                  {cat.label}
                </button>
              );
            })}
          </div>
        </div>

        {/* 数値・ゲージ・起き攻め */}
        <div className="grid grid-cols-1 gap-4 border-t border-slate-100 pt-4 sm:grid-cols-2">
          {/* ダメージ */}
          <label className="flex flex-col gap-1.5 text-xs font-bold text-slate-700">
            <span>ダメージ（任意）</span>
            <input
              type="number"
              inputMode="numeric"
              min={0}
              max={30000}
              step={1}
              value={damageInput}
              onChange={(e) => setDamageInput(e.target.value)}
              placeholder="例: 2740"
              className="rounded-lg border border-slate-300 bg-white px-3 py-2 text-base text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none sm:text-sm"
            />
          </label>

          {/* 起き攻め */}
          <div className="flex flex-col gap-1.5 text-xs font-bold text-slate-700">
            <span>起き攻めの有無</span>
            <div className="grid grid-cols-2 rounded-lg bg-slate-100 p-1">
              <button
                type="button"
                onClick={() => setHasOki(true)}
                className={`inline-flex items-center justify-center gap-1 rounded-md py-1.5 text-xs font-semibold transition-all sm:text-sm ${
                  hasOki
                    ? "bg-emerald-600 text-white shadow-xs"
                    : "text-slate-600 hover:text-slate-900"
                }`}
              >
                <ShieldCheck className="h-3.5 w-3.5" aria-hidden="true" />
                <span>起き攻めあり</span>
              </button>
              <button
                type="button"
                onClick={() => setHasOki(false)}
                className={`rounded-md py-1.5 text-xs font-semibold transition-all sm:text-sm ${
                  !hasOki
                    ? "bg-white text-slate-900 shadow-xs"
                    : "text-slate-600 hover:text-slate-900"
                }`}
              >
                なし
              </button>
            </div>
          </div>

          {/* 消費Dゲージ */}
          <div className="flex flex-col gap-1.5 text-xs font-bold text-slate-700">
            <div className="flex items-center justify-between">
              <span>消費Dゲージ（0〜6）</span>
              <span className="font-mono text-xs text-slate-600">
                {driveCost} 本
              </span>
            </div>
            <div className="flex flex-wrap items-center gap-1.5">
              {[0, 1, 2, 3, 4, 5, 6].map((val) => (
                <button
                  key={val}
                  type="button"
                  onClick={() => setDriveCost(val)}
                  className={`h-8 w-8 rounded-lg border text-xs font-bold transition-colors ${
                    driveCost === val
                      ? "border-emerald-600 bg-emerald-600 text-white"
                      : "border-slate-200 bg-white text-slate-700 hover:bg-slate-50"
                  }`}
                >
                  {val}
                </button>
              ))}
              <input
                type="number"
                min={0}
                max={6}
                step={0.5}
                value={driveCost}
                onChange={(e) => {
                  const v = Number(e.target.value);
                  if (Number.isFinite(v)) {
                    setDriveCost(Math.min(6, Math.max(0, v)));
                  }
                }}
                aria-label="消費Dゲージ数値入力（0.5刻み可）"
                className="w-16 rounded-lg border border-slate-300 bg-white px-2 py-1.5 text-center font-mono text-xs text-slate-900 focus:border-blue-500 focus:outline-none"
              />
            </div>
          </div>

          {/* 消費SAゲージ */}
          <div className="flex flex-col gap-1.5 text-xs font-bold text-slate-700">
            <span>消費SAゲージ</span>
            <div className="grid grid-cols-4 gap-1.5">
              {([0, 1, 2, 3] as const).map((val) => (
                <button
                  key={val}
                  type="button"
                  onClick={() => setSaCost(val)}
                  className={`rounded-lg border py-1.5 font-mono text-xs font-bold transition-colors ${
                    saCost === val
                      ? "border-indigo-600 bg-indigo-600 text-white"
                      : "border-slate-200 bg-white text-slate-700 hover:bg-slate-50"
                  }`}
                >
                  SA {val}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* キャラ固有ストック（ジュリ・イングリッドなど対応キャラのみ表示） */}
        {stockMeta && (
          <div className="grid grid-cols-1 gap-4 rounded-xl border border-slate-200 bg-slate-50/70 p-3 sm:grid-cols-2">
            <div className="flex flex-col gap-1.5 text-xs font-bold text-slate-700">
              <span>{stockMeta.label} 消費数（始動必要数）</span>
              <div className="flex flex-wrap gap-1.5">
                {Array.from(
                  { length: stockMeta.maxCount + 1 },
                  (_, i) => i
                ).map((val) => (
                  <button
                    key={`cost-${val}`}
                    type="button"
                    onClick={() => setStockCost(val)}
                    className={`rounded-lg border px-2.5 py-1 text-xs font-semibold transition-colors ${
                      stockCost === val
                        ? "border-pink-600 bg-pink-600 text-white"
                        : "border-slate-200 bg-white text-slate-700 hover:bg-pink-50"
                    }`}
                  >
                    {val === 0
                      ? "0（なし）"
                      : val === stockMeta.maxCount
                        ? `最大(${val})`
                        : `${val}`}
                  </button>
                ))}
              </div>
            </div>

            <div className="flex flex-col gap-1.5 text-xs font-bold text-slate-700">
              <span>{stockMeta.label} 獲得数</span>
              <div className="flex flex-wrap gap-1.5">
                {Array.from(
                  { length: stockMeta.maxCount + 1 },
                  (_, i) => i
                ).map((val) => (
                  <button
                    key={`gain-${val}`}
                    type="button"
                    onClick={() => setStockGain(val)}
                    className={`rounded-lg border px-2.5 py-1 text-xs font-semibold transition-colors ${
                      stockGain === val
                        ? "border-cyan-600 bg-cyan-600 text-white"
                        : "border-slate-200 bg-white text-slate-700 hover:bg-cyan-50"
                    }`}
                  >
                    {val === 0 ? "0（なし）" : `+${val}`}
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* 補足メモ欄（必須） */}
        <div className="space-y-2 border-t border-slate-100 pt-4">
          <label
            htmlFor="combo-note-textarea"
            className="block text-sm font-bold text-slate-900"
          >
            補足メモ・コツ <span className="text-rose-500">*</span>
          </label>
          {recipeMoveIds.includes("sys_delay") && (
            <div className="flex items-start gap-2 rounded-lg border border-blue-200 bg-blue-50 px-3 py-2 text-xs leading-relaxed text-blue-800">
              <Info className="mt-0.5 h-4 w-4 shrink-0 text-blue-600" aria-hidden="true" />
              <span>
                レシピに「ディレイ」が含まれています。タイミングの目安（少し遅め／着地ギリギリ／○F
                など）を補足メモに書いておくと再現しやすくなります。
              </span>
            </div>
          )}
          <textarea
            id="combo-note-textarea"
            rows={4}
            required
            value={note}
            onChange={(e) => {
              setNote(e.target.value);
              setFormError(null);
            }}
            placeholder="タイミングのコツ、距離限定、キャラ限定、起き攻めのフレーム状況などを記入してください。"
            className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2.5 text-base leading-relaxed text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none sm:text-sm"
          />
        </div>
      </section>

      {/* 重複コンボ自動チェック警告 */}
      {duplicateCombo && (
        <div
          role="alert"
          className="mb-4 flex flex-col gap-2.5 rounded-xl border border-amber-300 bg-amber-50 p-3.5 text-amber-900 sm:flex-row sm:items-center sm:justify-between"
        >
          <div className="flex items-start gap-2.5">
            <AlertTriangle
              className="mt-0.5 h-5 w-5 shrink-0 text-amber-600"
              aria-hidden="true"
            />
            <div className="text-xs leading-relaxed sm:text-sm">
              <p className="font-bold">同じレシピが既に登録されています</p>
              <p className="text-amber-800">
                重複投稿を避けるため、先に既存のコンボ内容をご確認ください。
              </p>
            </div>
          </div>
          <button
            type="button"
            onClick={() => setPreviewDuplicateModal(true)}
            className="inline-flex shrink-0 items-center justify-center gap-1.5 rounded-lg border border-amber-400 bg-white px-3 py-1.5 text-xs font-semibold text-amber-900 transition-colors hover:bg-amber-100"
          >
            <span>既存コンボを確認</span>
            <ExternalLink className="h-3.5 w-3.5" aria-hidden="true" />
          </button>
        </div>
      )}

      {isCheckingDuplicate && recipeMoveIds.length > 0 && !duplicateCombo && (
        <p className="mb-3 text-right text-[11px] text-slate-400">
          重複レシピを確認中...
        </p>
      )}

      {/* バリデーション・送信エラー */}
      {formError && (
        <div
          role="alert"
          className="mb-4 flex items-start gap-2 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-xs font-medium text-rose-700 sm:text-sm"
        >
          <AlertCircle className="mt-0.5 h-4 w-4 shrink-0" aria-hidden="true" />
          <span>{formError}</span>
        </div>
      )}

      {/* 投稿成功通知 */}
      {submitSuccess && (
        <div
          role="status"
          className="mb-4 flex items-center gap-2 rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-xs font-semibold text-emerald-800 sm:text-sm"
        >
          <CheckCircle2 className="h-4 w-4 shrink-0" aria-hidden="true" />
          <span>{submitSuccess}</span>
        </div>
      )}

      {/* 送信ボタン */}
      <div className="flex flex-col-reverse gap-2 sm:flex-row sm:items-center sm:justify-between">
        <p className="text-[11px] text-slate-500">
          ※ 投稿時の最新ゲームバージョンが自動で紐付けられます。
        </p>
        <button
          type="submit"
          disabled={isSubmitting || Boolean(submitSuccess)}
          className="inline-flex items-center justify-center gap-2 rounded-xl bg-blue-600 px-6 py-3 text-sm font-bold text-white shadow-sm transition-colors hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-60"
        >
          <Send className="h-4 w-4" aria-hidden="true" />
          <span>{isSubmitting ? "投稿中..." : "公開コンボを投稿する"}</span>
        </button>
      </div>

      {/* 重複コンボ確認モーダル */}
      <ComboDetailModal
        combo={previewDuplicateModal ? duplicateCombo : null}
        moveMap={moveMap}
        situationMap={situationMap}
        version={
          duplicateCombo ? versionMap[duplicateCombo.versionId] : undefined
        }
        stockMeta={stockMeta}
        notationMode={notationMode}
        isSaved={duplicateCombo ? isSaved(duplicateCombo.id) : false}
        isLiked={false}
        likesCount={duplicateCombo?.likesCount ?? 0}
        onToggleSave={(id) => toggleSavedCombo(id)}
        onToggleLike={() => {}}
        onChangeNotationMode={setNotationMode}
        onClose={() => setPreviewDuplicateModal(false)}
      />
    </form>
  );
}
