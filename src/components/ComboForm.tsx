"use client";

import { useEffect, useMemo, useState } from "react";
import {
  AlertCircle,
  AlertTriangle,
  CheckCircle2,
  ChevronLeft,
  ChevronRight,
  CornerDownRight,
  ExternalLink,
  Info,
  Loader2,
  Plus,
  RotateCcw,
  Send,
  ShieldCheck,
  Sparkles,
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
import { fetchClientMovesForCharacter } from "@/lib/supabase/clientQueries";
import { calculateRecipeGaugeCost } from "@/lib/gaugeCalculator";
import {
  calculateRecipeStock,
  hasStockCalculator,
} from "@/lib/stockCalculator";
import {
  type ComboValidationWarning,
  validateComboRecipe,
} from "@/lib/comboValidator";
import { usePreferences, useSavedCombos } from "@/hooks/useComboNoteStorage";
import { ComboDetailModal } from "@/components/ComboDetailModal";
import { MoveNotation } from "@/components/CommandNotation";

export interface ComboFormSubmitPayload {
  characterId: string;
  controlType: ControlType;
  title: string | null;
  moveIds: string[];
  recipeSignature: string;
  situations: string[];
  category: ComboCategory;
  damage: number | null;
  driveCost: number;
  saCost: 0 | 1 | 2 | 3;
  stockCost: number;
  stockGain: number;
  hasOki: boolean;
  note: string;
}

export interface ComboFormProps {
  mode: "create" | "edit";
  characters: Character[];
  /** 初期選択キャラクターの技＋システム共通パーツ（別キャラ切替時はクライアント側で遅延取得＆キャッシュ） */
  initialMoves: Move[];
  /** 新規投稿時の初期選択キャラクターID（URLクエリ引き継ぎ等） */
  initialCharacterId?: string;
  versions: GameVersion[];
  /** 編集モード時の初期値 */
  initialCombo?: Combo;
  /** 重複チェック時に除外するコンボID（編集モード用） */
  excludeComboId?: string;
  /** ログインユーザーID（重複チェックの有効化判定） */
  currentUserId: string | null;
  isSubmitting: boolean;
  submitError: string | null;
  submitSuccess: string | null;
  onClearSubmitError?: () => void;
  onSubmit: (payload: ComboFormSubmitPayload) => Promise<void> | void;
}

interface DuplicateComboRow {
  id: string;
  author_id: string | null;
  author_name: string | null;
  character_id: string;
  control_type: ControlType;
  title?: string | null;
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
    title: row.title ?? null,
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

export function ComboForm({
  mode,
  characters,
  initialMoves,
  initialCharacterId,
  versions,
  initialCombo,
  excludeComboId,
  currentUserId,
  isSubmitting,
  submitError,
  submitSuccess,
  onClearSubmitError,
  onSubmit,
}: ComboFormProps) {
  const {
    controlType: preferredControlType,
    notationMode,
    setNotationMode,
  } = usePreferences();
  const { isSaved, toggleSavedCombo } = useSavedCombos();

  const defaultCharacterId =
    initialCombo?.characterId ??
    initialCharacterId ??
    characters[0]?.id ??
    "akuma";

  // キャラ別技キャッシュ（初回選択キャラ分はSSR取得済みをそのまま格納し、再切替時は即表示）
  const [movesByCharacter, setMovesByCharacter] = useState<
    Record<string, Move[]>
  >(() => ({
    [defaultCharacterId]: initialMoves,
  }));
  const [isLoadingMoves, setIsLoadingMoves] = useState(false);
  const [movesLoadError, setMovesLoadError] = useState<string | null>(null);
  const [movesRetryNonce, setMovesRetryNonce] = useState(0);

  // Step 1: ビルダー状態
  const [selectedCharacterId, setSelectedCharacterId] =
    useState<string>(defaultCharacterId);

  // 選択キャラの技が未キャッシュのときのみ非同期取得
  useEffect(() => {
    if (movesByCharacter[selectedCharacterId]) {
      setIsLoadingMoves(false);
      setMovesLoadError(null);
      return;
    }

    let cancelled = false;
    setIsLoadingMoves(true);
    setMovesLoadError(null);

    fetchClientMovesForCharacter(selectedCharacterId)
      .then((fetchedMoves) => {
        if (cancelled) return;
        setMovesByCharacter((prev) => ({
          ...prev,
          [selectedCharacterId]: fetchedMoves,
        }));
        setIsLoadingMoves(false);
      })
      .catch((err) => {
        if (cancelled) return;
        setMovesLoadError(
          err instanceof Error
            ? err.message
            : "技データの読み込みに失敗しました。"
        );
        setIsLoadingMoves(false);
      });

    return () => {
      cancelled = true;
    };
  }, [selectedCharacterId, movesByCharacter, movesRetryNonce]);

  const activeMoves = useMemo(
    () => movesByCharacter[selectedCharacterId] ?? [],
    [movesByCharacter, selectedCharacterId]
  );

  const initialMoveMap = useMemo(() => {
    const map: Record<string, Move> = {};
    for (const m of initialMoves) {
      map[m.id] = m;
    }
    return map;
  }, [initialMoves]);

  const moveMap = useMemo(() => {
    const map: Record<string, Move> = {};
    for (const m of activeMoves) {
      map[m.id] = m;
    }
    return map;
  }, [activeMoves]);

  // 初期ゲージ・ストック計算（編集モード時に手動調整済みか判定するため）
  const initialAutoGauge = useMemo(() => {
    if (!initialCombo) return null;
    const moves = initialCombo.moveIds
      .map((id) => initialMoveMap[id])
      .filter((m): m is Move => Boolean(m));
    return calculateRecipeGaugeCost(moves);
  }, [initialCombo, initialMoveMap]);

  const initialAutoStock = useMemo(() => {
    if (!initialCombo) return null;
    const moves = initialCombo.moveIds
      .map((id) => initialMoveMap[id])
      .filter((m): m is Move => Boolean(m));
    return calculateRecipeStock(initialCombo.characterId, moves);
  }, [initialCombo, initialMoveMap]);

  const [controlType, setControlType] = useState<ControlType>(
    initialCombo?.controlType ?? preferredControlType
  );
  const [activeMoveCategory, setActiveMoveCategory] =
    useState<MoveCategory>("normal");
  const [recipeMoveIds, setRecipeMoveIds] = useState<string[]>(
    initialCombo?.moveIds ?? []
  );
  /** 挿入位置（null = 末尾に追加、0..length-1 = 該当インデックスの直前に挿入） */
  const [insertIndex, setInsertIndex] = useState<number | null>(null);

  // Step 2: メタ情報フォーム状態
  const [title, setTitle] = useState<string>(initialCombo?.title ?? "");
  const [selectedSituations, setSelectedSituations] = useState<string[]>(
    initialCombo?.situations ?? []
  );
  /** ユーザーが手動でOFFにした自動連携状況タグ（勝手に再ONしないため） */
  const [dismissedAutoSituations, setDismissedAutoSituations] = useState<
    string[]
  >([]);
  const [category, setCategory] = useState<ComboCategory>(
    initialCombo?.category ?? "standard"
  );
  const [damageInput, setDamageInput] = useState<string>(
    initialCombo?.damage !== null && initialCombo?.damage !== undefined
      ? String(initialCombo.damage)
      : ""
  );

  // Dゲージ・SAゲージ（それぞれ独立して自動／手動モードを持つ）
  const [driveCostMode, setDriveCostMode] = useState<"auto" | "manual">(() => {
    if (!initialCombo || !initialAutoGauge) return "auto";
    return initialCombo.driveCost === initialAutoGauge.driveCost
      ? "auto"
      : "manual";
  });
  const [manualDriveCost, setManualDriveCost] = useState<number>(
    initialCombo?.driveCost ?? 0
  );
  const [saCostMode, setSaCostMode] = useState<"auto" | "manual">(() => {
    if (!initialCombo || !initialAutoGauge) return "auto";
    return initialCombo.saCost === initialAutoGauge.saCost ? "auto" : "manual";
  });
  const [manualSaCost, setManualSaCost] = useState<0 | 1 | 2 | 3>(
    initialCombo?.saCost ?? 0
  );

  // ストック消費・獲得（自動計算対応キャラでは自動／手動モードを持つ）
  const [stockCostMode, setStockCostMode] = useState<"auto" | "manual">(() => {
    if (!initialCombo || !initialAutoStock) return "auto";
    const expectedCost = Math.min(
      initialAutoStock.maxCount,
      initialAutoStock.requiredStart
    );
    return (initialCombo.stockCost ?? 0) === expectedCost ? "auto" : "manual";
  });
  const [manualStockCost, setManualStockCost] = useState<number>(
    initialCombo?.stockCost ?? 0
  );
  const [stockGainMode, setStockGainMode] = useState<"auto" | "manual">(() => {
    if (!initialCombo || !initialAutoStock) return "auto";
    const expectedGain = Math.min(
      initialAutoStock.maxCount,
      initialAutoStock.gainedTotal
    );
    return (initialCombo.stockGain ?? 0) === expectedGain ? "auto" : "manual";
  });
  const [manualStockGain, setManualStockGain] = useState<number>(
    initialCombo?.stockGain ?? 0
  );
  const [hasOki, setHasOki] = useState<boolean>(initialCombo?.hasOki ?? false);
  const [note, setNote] = useState<string>(initialCombo?.note ?? "");

  // 重複チェック・ローカルバリデーションエラー
  const [duplicateCheck, setDuplicateCheck] = useState<{
    signature: string;
    combo: Combo | null;
  }>({ signature: "", combo: null });
  const [previewDuplicateModal, setPreviewDuplicateModal] = useState(false);
  const [validationError, setValidationError] = useState<string | null>(null);

  const selectedCharacter = useMemo(
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
    return activeMoves
      .filter((move) => {
        const matchCharacter =
          move.characterId === selectedCharacterId || move.characterId === null;
        const matchControl =
          move.controlType === "both" || move.controlType === controlType;
        return matchCharacter && matchControl;
      })
      .sort((a, b) => a.sortOrder - b.sortOrder);
  }, [activeMoves, selectedCharacterId, controlType]);

  const movesByCategory = useMemo(() => {
    const grouped: Record<MoveCategory, Move[]> = {
      normal: [],
      unique: [],
      special: [],
      super: [],
      throw: [],
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

  // レシピからリアルタイム自動計算（D/SAゲージ・固有ストック）
  const autoGauge = useMemo(
    () => calculateRecipeGaugeCost(recipeMoves),
    [recipeMoves]
  );
  const autoStock = useMemo(
    () => calculateRecipeStock(selectedCharacterId, recipeMoves),
    [selectedCharacterId, recipeMoves]
  );
  const supportsAutoStock = hasStockCalculator(selectedCharacterId);

  const driveCost =
    driveCostMode === "auto" ? autoGauge.driveCost : manualDriveCost;
  const saCost: 0 | 1 | 2 | 3 =
    saCostMode === "auto" ? autoGauge.saCost : manualSaCost;

  const autoStockCostValue = autoStock
    ? Math.min(autoStock.maxCount, autoStock.requiredStart)
    : 0;
  const autoStockGainValue = useMemo(() => {
    if (!autoStock) return 0;
    const gainOptions = selectedCharacter?.stockMeta?.gainOptions;
    if (gainOptions && gainOptions.length > 0) {
      if (autoStock.gainedTotal <= 0) return 0;
      const nonZeroMax = Math.max(...gainOptions);
      return gainOptions.includes(autoStock.gainedTotal)
        ? autoStock.gainedTotal
        : nonZeroMax;
    }
    return Math.min(autoStock.maxCount, autoStock.gainedTotal);
  }, [autoStock, selectedCharacter]);

  const stockCost =
    supportsAutoStock && stockCostMode === "auto"
      ? autoStockCostValue
      : manualStockCost;
  const stockGain =
    supportsAutoStock && stockGainMode === "auto"
      ? autoStockGainValue
      : manualStockGain;

  const isInsertingMidway =
    insertIndex !== null && insertIndex < recipeMoveIds.length;
  const effectiveInsertIndex = isInsertingMidway
    ? insertIndex
    : recipeMoveIds.length;

  // ストック消費技・(CH)・(PC)がレシピに含まれたとき、対応する状況タグを自動でONにする
  // （ユーザーが手動で外した場合は dismissedAutoSituations で記憶し勝手に付け直さない）
  const autoSituationKeys = useMemo(() => {
    const keys: string[] = [];
    if (autoStock?.situationKey && autoStock.requiredStart > 0) {
      keys.push(autoStock.situationKey);
    }
    if (
      selectedCharacterId === "kimberly" &&
      recipeMoveIds.includes("kimberly_shuriken_explode") &&
      !keys.includes("kimberly_shuriken")
    ) {
      keys.push("kimberly_shuriken");
    }
    if (recipeMoveIds.includes("sys_ch")) {
      keys.push("counter");
    }
    if (recipeMoveIds.includes("sys_pc")) {
      keys.push("punish_counter");
    }
    return keys;
  }, [autoStock, recipeMoveIds]);

  useEffect(() => {
    if (autoSituationKeys.length === 0) return;
    const keysToAdd = autoSituationKeys.filter(
      (key) => !dismissedAutoSituations.includes(key)
    );
    if (keysToAdd.length === 0) return;
    setSelectedSituations((prev) => {
      const missing = keysToAdd.filter((key) => !prev.includes(key));
      return missing.length > 0 ? [...prev, ...missing] : prev;
    });
  }, [autoSituationKeys, dismissedAutoSituations]);

  const recipeSignature = useMemo(() => {
    if (recipeMoveIds.length < 2) return "";
    return buildRecipeSignature(selectedCharacterId, controlType, recipeMoveIds);
  }, [selectedCharacterId, controlType, recipeMoveIds]);

  // リアルタイムフレーム検証（ソフト警告：投稿・保存はブロックしない）
  const frameWarnings = useMemo<ComboValidationWarning[]>(
    () =>
      validateComboRecipe({
        characterId: selectedCharacterId,
        moves: activeMoves,
        moveIds: recipeMoveIds,
        situations: selectedSituations,
      }),
    [selectedCharacterId, activeMoves, recipeMoveIds, selectedSituations]
  );

  const frameWarningByStepIndex = useMemo(() => {
    const map = new Map<number, ComboValidationWarning>();
    for (const warning of frameWarnings) {
      map.set(warning.stepIndex, warning);
    }
    return map;
  }, [frameWarnings]);

  const duplicateCombo =
    recipeSignature && duplicateCheck.signature === recipeSignature
      ? duplicateCheck.combo
      : null;

  const isCheckingDuplicate = Boolean(
    currentUserId &&
      recipeSignature &&
      duplicateCheck.signature !== recipeSignature
  );

  // 重複コンボ自動チェック（recipe_signature 照合）
  useEffect(() => {
    if (!currentUserId || !recipeSignature) {
      return;
    }

    let cancelled = false;

    const timer = window.setTimeout(async () => {
      try {
        const supabase = createClient();
        let query = supabase
          .from("combos")
          .select("*")
          .eq("character_id", selectedCharacterId)
          .eq("control_type", controlType)
          .eq("recipe_signature", recipeSignature);

        if (excludeComboId) {
          query = query.neq("id", excludeComboId);
        }

        const { data, error } = await query.limit(1).maybeSingle();

        if (cancelled) return;
        setDuplicateCheck({
          signature: recipeSignature,
          combo:
            !error && data ? mapRowToCombo(data as DuplicateComboRow) : null,
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
  }, [
    currentUserId,
    selectedCharacterId,
    controlType,
    recipeSignature,
    excludeComboId,
  ]);

  const clearErrors = () => {
    setValidationError(null);
    onClearSubmitError?.();
  };

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
    setInsertIndex(null);
    setManualStockCost(0);
    setManualStockGain(0);
    setStockCostMode("auto");
    setStockGainMode("auto");
    setDriveCostMode("auto");
    setSaCostMode("auto");
    setDismissedAutoSituations([]);
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
      setInsertIndex(null);
    }
    setControlType(nextControl);
    setActiveMoveCategory("normal");
  };

  const handleAppendMove = (moveId: string) => {
    if (insertIndex === null || insertIndex >= recipeMoveIds.length) {
      setRecipeMoveIds((prev) => [...prev, moveId]);
    } else {
      const targetPos = insertIndex;
      setRecipeMoveIds((prev) => [
        ...prev.slice(0, targetPos),
        moveId,
        ...prev.slice(targetPos),
      ]);
      // 続けて途中挿入できるよう挿入位置を +1 右へ進める
      setInsertIndex(targetPos + 1);
    }
    clearErrors();
  };

  const handleUndo = () => {
    if (isInsertingMidway && insertIndex > 0) {
      const removePos = insertIndex - 1;
      setRecipeMoveIds((prev) => prev.filter((_, i) => i !== removePos));
      setInsertIndex(removePos);
      return;
    }
    setRecipeMoveIds((prev) => prev.slice(0, -1));
  };

  const handleRemoveAt = (index: number) => {
    const nextLength = recipeMoveIds.length - 1;
    setRecipeMoveIds((prev) => prev.filter((_, i) => i !== index));
    if (insertIndex !== null) {
      if (index < insertIndex) {
        const shifted = insertIndex - 1;
        setInsertIndex(shifted >= nextLength ? null : shifted);
      } else if (insertIndex >= nextLength) {
        setInsertIndex(null);
      }
    }
  };

  const handleMoveLeft = (index: number) => {
    if (index <= 0) return;
    setRecipeMoveIds((prev) => {
      const next = [...prev];
      [next[index - 1], next[index]] = [next[index], next[index - 1]];
      return next;
    });
    clearErrors();
  };

  const handleMoveRight = (index: number) => {
    if (index >= recipeMoveIds.length - 1) return;
    setRecipeMoveIds((prev) => {
      const next = [...prev];
      [next[index], next[index + 1]] = [next[index + 1], next[index]];
      return next;
    });
    clearErrors();
  };

  const handleClear = () => {
    setRecipeMoveIds([]);
    setInsertIndex(null);
  };

  const handleManualDriveCostChange = (nextVal: number) => {
    setDriveCostMode("manual");
    setManualDriveCost(nextVal);
    clearErrors();
  };

  const handleResetDriveCostToAuto = () => {
    setDriveCostMode("auto");
    clearErrors();
  };

  const handleManualSaCostChange = (nextVal: 0 | 1 | 2 | 3) => {
    setSaCostMode("manual");
    setManualSaCost(nextVal);
    clearErrors();
  };

  const handleResetSaCostToAuto = () => {
    setSaCostMode("auto");
    clearErrors();
  };

  const handleManualStockCostChange = (nextVal: number) => {
    if (supportsAutoStock) {
      setStockCostMode("manual");
    }
    setManualStockCost(nextVal);
    clearErrors();
  };

  const handleResetStockCostToAuto = () => {
    setStockCostMode("auto");
    clearErrors();
  };

  const handleManualStockGainChange = (nextVal: number) => {
    if (supportsAutoStock) {
      setStockGainMode("manual");
    }
    setManualStockGain(nextVal);
    clearErrors();
  };

  const handleResetStockGainToAuto = () => {
    setStockGainMode("auto");
    clearErrors();
  };

  const toggleSituation = (key: string) => {
    const isCurrentlySelected = selectedSituations.includes(key);
    if (isCurrentlySelected) {
      setSelectedSituations((prev) => prev.filter((item) => item !== key));
      // 自動連携対象タグ（ストック・カウンター・パニカン）をユーザーが手動で外したことを記憶
      if (
        key === "counter" ||
        key === "punish_counter" ||
        autoStock?.situationKey === key
      ) {
        setDismissedAutoSituations((prev) =>
          prev.includes(key) ? prev : [...prev, key]
        );
      }
    } else {
      setSelectedSituations((prev) => [...prev, key]);
      setDismissedAutoSituations((prev) => prev.filter((item) => item !== key));
    }
    clearErrors();
  };

  const handleFormSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (isSubmitting) return;

    clearErrors();

    if (recipeMoveIds.length < 2) {
      setValidationError("コンボレシピは2つ以上の技を選択してください。");
      return;
    }
    if (selectedSituations.length === 0) {
      setValidationError("状況タグを1つ以上選択してください。");
      return;
    }

    const trimmedNote = note.trim();
    if (!trimmedNote) {
      setValidationError(
        "補足メモを入力してください（タイミングのコツや距離限定など）。"
      );
      return;
    }

    let parsedDamage: number | null = null;
    if (damageInput.trim() !== "") {
      const num = Number(damageInput);
      if (!Number.isFinite(num) || num < 0 || num > 30000) {
        setValidationError("ダメージは 0〜30000 の数値で入力してください。");
        return;
      }
      parsedDamage = Math.round(num);
    }

    if (!Number.isFinite(driveCost) || driveCost < 0 || driveCost > 6) {
      setValidationError("消費Dゲージは 0〜6 の範囲で入力してください。");
      return;
    }

    const trimmedTitle = title.trim();
    if (trimmedTitle.length > 60) {
      setValidationError("コンボタイトルは60文字以内で入力してください。");
      return;
    }

    await onSubmit({
      characterId: selectedCharacterId,
      controlType,
      title: trimmedTitle || null,
      moveIds: recipeMoveIds,
      recipeSignature,
      situations: selectedSituations,
      category,
      damage: parsedDamage,
      driveCost,
      saCost,
      stockCost: selectedCharacter?.stockMeta ? stockCost : 0,
      stockGain: selectedCharacter?.stockMeta ? stockGain : 0,
      hasOki,
      note: trimmedNote,
    });
  };

  const currentCategoryMoves = movesByCategory[activeMoveCategory];
  const stockMeta = selectedCharacter?.stockMeta;
  const activeError = validationError ?? submitError;

  return (
    <form onSubmit={handleFormSubmit}>
      {/* 1. キャラクター & 操作タイプ & 表記モード選択 */}
      <section
        aria-label="キャラクター・操作タイプ・表記選択"
        className="mb-4 rounded-xl border border-slate-200 bg-white p-3.5 shadow-xs sm:p-4 dark:border-[#2E2447] dark:bg-[#1B152B]"
      >
        <div className="grid grid-cols-1 gap-3 sm:grid-cols-3">
          {mode === "edit" ? (
            <div className="flex flex-col gap-1.5 text-xs font-bold text-slate-700 dark:text-[#CFC6E8]">
              <div className="flex items-center gap-1.5">
                <span>対象キャラクター</span>
                <span className="rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-medium text-slate-500 dark:bg-[#251D3A] dark:text-[#A99EC4]">
                  変更不可
                </span>
              </div>
              <div className="rounded-lg border border-slate-200 bg-slate-50 px-3 py-2 text-sm font-semibold text-slate-700 dark:border-[#3A2E58] dark:bg-[#140F23] dark:text-[#CFC6E8]">
                {selectedCharacter
                  ? `${selectedCharacter.nameJa}（${selectedCharacter.nameEn}）`
                  : selectedCharacterId}
              </div>
            </div>
          ) : (
            <label className="flex flex-col gap-1.5 text-xs font-bold text-slate-700 dark:text-[#CFC6E8]">
              <span>対象キャラクター</span>
              <select
                value={selectedCharacterId}
                onChange={(e) => handleChangeCharacter(e.target.value)}
                className="rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm font-semibold text-slate-900 focus:border-blue-500 focus:outline-none dark:border-[#3A2E58] dark:bg-[#140F23] dark:text-[#F4F1FF] dark:focus:border-[#8B5CF6]"
              >
                {characters.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.nameJa}（{c.nameEn}）
                  </option>
                ))}
              </select>
            </label>
          )}

          <div className="flex flex-col gap-1.5 text-xs font-bold text-slate-700 dark:text-[#CFC6E8]">
            <span>操作タイプ</span>
            <div
              role="tablist"
              aria-label="操作タイプ選択"
              className="grid grid-cols-2 rounded-lg bg-slate-100 p-1 dark:bg-[#251D3A]"
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
                      ? "bg-white text-blue-700 shadow-xs dark:bg-[#7C3AED] dark:text-white"
                      : "text-slate-600 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:text-[#F4F1FF]"
                  }`}
                >
                  {item.label}
                </button>
              ))}
            </div>
          </div>

          <div className="flex flex-col gap-1.5 text-xs font-bold text-slate-700 dark:text-[#CFC6E8]">
            <span>表記モード</span>
            <div
              role="tablist"
              aria-label="表記モード選択"
              className="grid grid-cols-3 rounded-lg bg-slate-100 p-1 dark:bg-[#251D3A]"
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

      {/* 2. 技ボタン選択式ビルダー */}
      <section
        aria-label="技ボタンビルダー"
        className="mb-4 rounded-xl border border-slate-200 bg-white p-3.5 shadow-xs sm:p-4 dark:border-[#2E2447] dark:bg-[#1B152B]"
      >
        <div className="mb-3 flex items-center justify-between gap-2">
          <h2 className="text-sm font-bold text-slate-900 dark:text-[#F4F1FF]">
            技を選択して追加 <span className="text-rose-500 dark:text-rose-400">*</span>
          </h2>
          <span className="text-[11px] font-medium text-slate-500 dark:text-[#A99EC4]">
            {isInsertingMidway ? (
              <span className="font-semibold text-blue-600 dark:text-[#C4B5FD]">
                {effectiveInsertIndex === 0
                  ? "タップで先頭に挿入"
                  : `タップで ${effectiveInsertIndex}→${effectiveInsertIndex + 1} 番目の間に挿入`}
              </span>
            ) : (
              "タップでレシピ末尾に追加"
            )}
          </span>
        </div>

        {/* カテゴリ別タブ */}
        <div
          role="tablist"
          aria-label="技カテゴリ切替"
          className="mb-2.5 grid grid-cols-3 gap-1.5 border-b border-slate-100 pb-2.5 sm:flex sm:flex-wrap dark:border-[#2D2346]"
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
                className={`inline-flex items-center justify-center gap-1 rounded-lg px-2 py-1.5 text-xs font-semibold transition-colors sm:px-3 ${
                  isActive
                    ? "bg-blue-600 text-white shadow-xs dark:bg-[#7C3AED]"
                    : "bg-slate-100 text-slate-700 hover:bg-slate-200 dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:bg-[#30264A]"
                }`}
              >
                <span className="truncate">{tab.label}</span>
                <span
                  className={`shrink-0 rounded-full px-1.5 py-0.2 text-[10px] ${
                    isActive
                      ? "bg-white/20 text-white"
                      : "bg-white text-slate-500 dark:bg-[#1B152B] dark:text-[#A99EC4]"
                  }`}
                >
                  {count}
                </span>
              </button>
            );
          })}
        </div>

        {/* 技ボタングリッド（選択中の表記モードのみ表示・CDR/DR/DIは常にアイコン統一） */}
        {isLoadingMoves ? (
          <div className="flex flex-col items-center justify-center gap-2 rounded-lg border border-slate-100 bg-slate-50/40 py-8 text-xs text-slate-500 dark:border-[#2A2142] dark:bg-[#140F23] dark:text-[#A99EC4]">
            <Loader2
              className="h-5 w-5 animate-spin text-blue-600 dark:text-[#A78BFA]"
              aria-hidden="true"
            />
            <span>技データを読み込み中...</span>
          </div>
        ) : movesLoadError ? (
          <div className="flex flex-col items-center justify-center gap-2 rounded-lg border border-rose-200 bg-rose-50/70 px-3 py-6 text-center text-xs text-rose-700 dark:border-rose-500/35 dark:bg-rose-500/15 dark:text-rose-200">
            <p>{movesLoadError}</p>
            <button
              type="button"
              onClick={() => setMovesRetryNonce((n) => n + 1)}
              className="inline-flex items-center gap-1 rounded-lg bg-rose-600 px-3 py-1.5 text-xs font-semibold text-white transition-colors hover:bg-rose-700"
            >
              <RotateCcw className="h-3.5 w-3.5" aria-hidden="true" />
              <span>再読み込み</span>
            </button>
          </div>
        ) : currentCategoryMoves.length > 0 ? (
          <div className="max-h-60 overflow-y-auto overscroll-contain rounded-lg border border-slate-100 bg-slate-50/40 p-1.5 sm:max-h-72 sm:p-2 dark:border-[#2A2142] dark:bg-[#140F23]">
            <div
              className={`grid gap-1.5 ${
                notationMode === "name"
                  ? "grid-cols-2 sm:grid-cols-3 md:grid-cols-4"
                  : "grid-cols-3 sm:grid-cols-4 md:grid-cols-5"
              }`}
            >
              {currentCategoryMoves.map((move) => (
                <button
                  key={move.id}
                  type="button"
                  onClick={() => handleAppendMove(move.id)}
                  title={`${move.notationName} (${move.notationNumpad})`}
                  className="flex min-h-[40px] items-center justify-center rounded-lg border border-slate-200 bg-white px-1.5 py-1.5 text-center shadow-2xs transition-all hover:border-blue-400 hover:bg-blue-50/60 active:scale-[0.97] sm:px-2 dark:border-[#3A2E58] dark:bg-[#1E1730] dark:hover:border-[#8B5CF6] dark:hover:bg-[#2A2145]"
                >
                  <span
                    className={`inline-flex max-w-full items-center justify-center text-xs font-bold text-slate-900 sm:text-[13px] dark:text-[#F4F1FF] ${
                      notationMode === "command" ? "leading-tight" : "truncate"
                    }`}
                  >
                    <MoveNotation move={move} notationMode={notationMode} />
                  </span>
                </button>
              ))}
            </div>
          </div>
        ) : (
          <p className="py-6 text-center text-xs text-slate-500 dark:text-[#A99EC4]">
            このカテゴリに登録されている技はありません。
          </p>
        )}
      </section>

      {/* 3. 組み立て中のレシピ（任意位置挿入・並び替え・リアルタイムプレビュー） */}
      <section
        aria-label="組み立て中のレシピ"
        className="mb-4 rounded-xl border border-slate-200 bg-white p-3.5 shadow-xs sm:p-4 dark:border-[#2E2447] dark:bg-[#1B152B]"
      >
        <div className="mb-3 flex flex-wrap items-center justify-between gap-2">
          <div className="flex flex-wrap items-center gap-1.5 sm:gap-2">
            <h2 className="text-sm font-bold text-slate-900 dark:text-[#F4F1FF]">
              組み立て中のレシピ
            </h2>
            <span className="rounded-full bg-slate-100 px-2 py-0.5 text-xs font-semibold text-slate-600 dark:bg-[#251D3A] dark:text-[#CFC6E8]">
              {recipeMoves.length} パーツ
            </span>
            {autoStock?.hasActivity && (
              <span
                className={`inline-flex items-center gap-1 rounded-full border px-2 py-0.5 text-[11px] font-semibold ${autoStock.badgeClassName}`}
                title={`${autoStock.label} 自動計算結果`}
              >
                <Sparkles className="h-3 w-3" aria-hidden="true" />
                <span>{autoStock.summaryLabel}</span>
              </span>
            )}
            {recipeMoves.length === 1 && (
              <span className="text-[11px] font-medium text-amber-700 dark:text-amber-300">
                ※ 2つ以上選択してください
              </span>
            )}
          </div>

          <div className="flex flex-wrap items-center gap-1.5">
            {isInsertingMidway && (
              <button
                type="button"
                onClick={() => setInsertIndex(null)}
                className="inline-flex items-center gap-1 rounded-lg border border-blue-200 bg-blue-50 px-2.5 py-1.5 text-xs font-semibold text-blue-700 transition-colors hover:bg-blue-100 dark:border-violet-400/40 dark:bg-violet-500/20 dark:text-[#DDD6FE] dark:hover:bg-violet-500/30"
              >
                <CornerDownRight className="h-3.5 w-3.5" aria-hidden="true" />
                <span>末尾に追加へ戻す</span>
              </button>
            )}
            <button
              type="button"
              onClick={handleUndo}
              disabled={recipeMoves.length === 0}
              className="inline-flex items-center gap-1 rounded-lg border border-slate-200 bg-white px-2.5 py-1.5 text-xs font-semibold text-slate-700 transition-colors hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#E2DCF5] dark:hover:bg-[#30264A]"
            >
              <Undo2 className="h-3.5 w-3.5" aria-hidden="true" />
              <span>1つ戻す</span>
            </button>
            <button
              type="button"
              onClick={handleClear}
              disabled={recipeMoves.length === 0}
              className="inline-flex items-center gap-1 rounded-lg border border-rose-200 bg-rose-50/60 px-2.5 py-1.5 text-xs font-semibold text-rose-700 transition-colors hover:bg-rose-100 disabled:cursor-not-allowed disabled:opacity-40 dark:border-rose-500/35 dark:bg-rose-500/15 dark:text-rose-200 dark:hover:bg-rose-500/25"
            >
              <Trash2 className="h-3.5 w-3.5" aria-hidden="true" />
              <span>全消去</span>
            </button>
          </div>
        </div>

        {recipeMoves.length > 0 ? (
          <>
            <div className="rounded-lg border border-slate-100 bg-slate-50/70 p-2.5 sm:p-3 dark:border-[#2A2142] dark:bg-[#140F23]">
              <div className="flex flex-wrap items-center gap-x-1 gap-y-2">
                {/* 先頭挿入スロット（index = 0） */}
                {effectiveInsertIndex === 0 ? (
                  <span
                    aria-live="polite"
                    className="inline-flex items-center gap-1 rounded-full bg-blue-600 px-2 py-1 text-[10px] font-bold text-white shadow-xs dark:bg-[#7C3AED]"
                  >
                    <span
                      className="h-2.5 w-0.5 animate-pulse rounded-full bg-white"
                      aria-hidden="true"
                    />
                    ここに挿入
                  </span>
                ) : (
                  <button
                    type="button"
                    onClick={() => setInsertIndex(0)}
                    aria-label="先頭に技を挿入する位置に設定"
                    title="先頭に挿入"
                    className="inline-flex h-7 items-center gap-0.5 rounded-md border border-dashed border-slate-300 bg-white px-1.5 text-[10px] font-semibold text-slate-500 transition-colors hover:border-blue-400 hover:bg-blue-50 hover:text-blue-600 dark:border-[#4A3B70] dark:bg-[#1B152B] dark:text-[#A99EC4] dark:hover:border-[#8B5CF6] dark:hover:bg-[#251D3A] dark:hover:text-[#DDD6FE]"
                  >
                    <Plus className="h-3 w-3" aria-hidden="true" />
                    <span>先頭</span>
                  </button>
                )}

                {recipeMoves.map((move, index) => {
                  const isFirst = index === 0;
                  const isLast = index === recipeMoves.length - 1;
                  const nextSlot = index + 1;
                  const isNextSlotActive =
                    !isLast && effectiveInsertIndex === nextSlot;
                  const chipWarning = frameWarningByStepIndex.get(index);
                  const nextConnectorWarning = !isLast
                    ? frameWarningByStepIndex.get(nextSlot)
                    : undefined;

                  return (
                    <div
                      key={`${move.id}-${index}`}
                      className="inline-flex max-w-full items-center gap-1"
                    >
                      {/* 技チップ（並び替え←/→・削除×付き） */}
                      <span
                        title={chipWarning?.message}
                        className={`inline-flex max-w-full items-center gap-1 rounded-lg border py-1 pr-1 pl-2 text-xs leading-snug shadow-2xs sm:text-sm ${getMoveChipStyle(
                          move
                        )} ${
                          chipWarning
                            ? "border-amber-400 ring-1 ring-amber-400/70 dark:border-amber-400/75 dark:ring-amber-400/50"
                            : ""
                        }`}
                      >
                        <span className="inline-flex items-center break-words">
                          <MoveNotation
                            move={move}
                            notationMode={notationMode}
                          />
                        </span>
                        <span className="ml-0.5 inline-flex shrink-0 items-center gap-0.5 border-l border-slate-200/90 pl-1 dark:border-[#4A3B70]/70">
                          <button
                            type="button"
                            onClick={() => handleMoveLeft(index)}
                            disabled={isFirst}
                            aria-label={`${move.notationName} を1つ左へ移動`}
                            title="1つ左へ"
                            className="inline-flex h-6 w-6 items-center justify-center rounded text-slate-500 transition-colors hover:bg-slate-200/80 hover:text-slate-900 disabled:cursor-not-allowed disabled:opacity-25 dark:text-[#A99EC4] dark:hover:bg-[#3A2E58] dark:hover:text-[#F4F1FF]"
                          >
                            <ChevronLeft className="h-3.5 w-3.5" aria-hidden="true" />
                          </button>
                          <button
                            type="button"
                            onClick={() => handleMoveRight(index)}
                            disabled={isLast}
                            aria-label={`${move.notationName} を1つ右へ移動`}
                            title="1つ右へ"
                            className="inline-flex h-6 w-6 items-center justify-center rounded text-slate-500 transition-colors hover:bg-slate-200/80 hover:text-slate-900 disabled:cursor-not-allowed disabled:opacity-25 dark:text-[#A99EC4] dark:hover:bg-[#3A2E58] dark:hover:text-[#F4F1FF]"
                          >
                            <ChevronRight className="h-3.5 w-3.5" aria-hidden="true" />
                          </button>
                          <button
                            type="button"
                            onClick={() => handleRemoveAt(index)}
                            aria-label={`${move.notationName} を削除`}
                            title="削除"
                            className="inline-flex h-6 w-6 items-center justify-center rounded text-slate-400 transition-colors hover:bg-rose-100 hover:text-rose-600 dark:text-[#8E82B3] dark:hover:bg-rose-500/20 dark:hover:text-rose-300"
                          >
                            <X className="h-3.5 w-3.5" aria-hidden="true" />
                          </button>
                        </span>
                      </span>

                      {/* 技と技の間の挿入スロット */}
                      {!isLast &&
                        (isNextSlotActive ? (
                          <span
                            aria-live="polite"
                            className="inline-flex items-center gap-1 rounded-full bg-blue-600 px-2 py-1 text-[10px] font-bold text-white shadow-xs dark:bg-[#7C3AED]"
                          >
                            <span
                              className="h-2.5 w-0.5 animate-pulse rounded-full bg-white"
                              aria-hidden="true"
                            />
                            ここに挿入
                          </span>
                        ) : (
                          <button
                            type="button"
                            onClick={() => setInsertIndex(nextSlot)}
                            aria-label={`${index + 1}番目と${index + 2}番目の間に技を挿入`}
                            title={
                              nextConnectorWarning
                                ? `${nextConnectorWarning.message}（タップでここに挿入）`
                                : "ここに挿入"
                            }
                            className={`inline-flex h-7 w-6 shrink-0 items-center justify-center rounded-md transition-colors ${
                              nextConnectorWarning
                                ? "bg-amber-100/90 text-amber-700 ring-1 ring-amber-300 hover:bg-amber-200 dark:bg-amber-500/20 dark:text-amber-300 dark:ring-amber-400/45 dark:hover:bg-amber-500/30"
                                : "text-slate-400 hover:bg-blue-100 hover:text-blue-600 dark:text-[#7D71A1] dark:hover:bg-violet-500/25 dark:hover:text-[#DDD6FE]"
                            }`}
                          >
                            <ChevronRight
                              className="h-4 w-4"
                              aria-hidden="true"
                            />
                          </button>
                        ))}
                    </div>
                  );
                })}

                {/* 末尾挿入スロット */}
                {!isInsertingMidway ? (
                  <span className="inline-flex items-center gap-1 rounded-full border border-blue-200 bg-blue-50 px-2 py-1 text-[10px] font-bold text-blue-700 dark:border-violet-400/40 dark:bg-violet-500/20 dark:text-[#DDD6FE]">
                    <span
                      className="h-2.5 w-0.5 animate-pulse rounded-full bg-blue-600 dark:bg-[#A78BFA]"
                      aria-hidden="true"
                    />
                    末尾に追加
                  </span>
                ) : (
                  <button
                    type="button"
                    onClick={() => setInsertIndex(null)}
                    aria-label="末尾に技を追加する位置に戻す"
                    title="末尾に追加"
                    className="inline-flex h-7 items-center gap-0.5 rounded-md border border-dashed border-slate-300 bg-white px-1.5 text-[10px] font-semibold text-slate-500 transition-colors hover:border-blue-400 hover:bg-blue-50 hover:text-blue-600 dark:border-[#4A3B70] dark:bg-[#1B152B] dark:text-[#A99EC4] dark:hover:border-[#8B5CF6] dark:hover:bg-[#251D3A] dark:hover:text-[#DDD6FE]"
                  >
                    <Plus className="h-3 w-3" aria-hidden="true" />
                    <span>末尾</span>
                  </button>
                )}
              </div>
            </div>
            <p className="mt-2 text-[11px] text-slate-500 dark:text-[#A99EC4]">
              ※「+ 先頭」や技の間の「›」をタップすると途中の位置に技を挿入できます。チップ内の「‹」「›」で左右に並び替えられます。
            </p>

            {/* フレーム検証ソフト警告カード（警告が1件以上あるときのみ表示・投稿はブロックしない） */}
            {frameWarnings.length > 0 && (
              <div
                role="status"
                aria-live="polite"
                className="mt-3 rounded-xl border border-amber-300 bg-amber-50/95 p-3 text-amber-950 sm:p-3.5 dark:border-amber-400/35 dark:bg-amber-500/15 dark:text-amber-100"
              >
                <div className="flex items-start gap-2.5">
                  <AlertTriangle
                    className="mt-0.5 h-4 w-4 shrink-0 text-amber-600 sm:h-5 sm:w-5 dark:text-amber-300"
                    aria-hidden="true"
                  />
                  <div className="min-w-0 flex-1">
                    <div className="flex flex-wrap items-center gap-1.5">
                      <p className="text-xs font-bold sm:text-sm">
                        繋がらない可能性があります（フレーム検証）
                      </p>
                      <span className="rounded-full bg-amber-200/80 px-1.5 py-0.5 text-[10px] font-bold text-amber-900 dark:bg-amber-400/25 dark:text-amber-200">
                        {frameWarnings.length}件
                      </span>
                    </div>
                    <ul className="mt-1.5 space-y-1 text-xs leading-relaxed text-amber-900/95 dark:text-amber-100/95">
                      {frameWarnings.map((warning) => {
                        const fromMove = moveMap[warning.fromMoveId];
                        const toMove = moveMap[warning.toMoveId];
                        const pairSummary =
                          fromMove && toMove
                            ? `${fromMove.notationNumpad}（${fromMove.notationName}） → ${toMove.notationNumpad}（${toMove.notationName}）`
                            : null;

                        return (
                          <li
                            key={`${warning.stepIndex}-${warning.kind}-${warning.fromMoveId}-${warning.toMoveId}`}
                            className="flex items-start gap-1.5 break-words"
                          >
                            <span
                              aria-hidden="true"
                              className="mt-1.5 h-1.5 w-1.5 shrink-0 rounded-full bg-amber-500 dark:bg-amber-300"
                            />
                            <div className="min-w-0 flex-1">
                              <span className="font-medium">
                                {warning.message}
                              </span>
                              {pairSummary &&
                                warning.kind === "frame_shortage" && (
                                  <span className="mt-0.5 block text-[11px] text-amber-800/85 dark:text-amber-200/80">
                                    対象箇所（{warning.stepIndex}→
                                    {warning.stepIndex + 1}番目）: {pairSummary}
                                  </span>
                                )}
                            </div>
                          </li>
                        );
                      })}
                    </ul>
                    <p className="mt-2 border-t border-amber-200/80 pt-2 text-[11px] leading-relaxed text-amber-800/90 dark:border-amber-400/20 dark:text-amber-200/80">
                      ※しゃがみ喰らい（+1F）・持続当て・画面端限定・設置技の時間差ヒットなどで成立する場合は、そのまま投稿できます。
                    </p>
                  </div>
                </div>
              </div>
            )}
          </>
        ) : (
          <div className="rounded-lg border border-dashed border-slate-200 bg-slate-50/50 px-3 py-6 text-center text-xs text-slate-500 dark:border-[#3A2E58] dark:bg-[#140F23] dark:text-[#A99EC4]">
            上の技ボタンをタップして、コンボの始動技から順番に組み立ててください。
          </div>
        )}
      </section>

      {/* 4. 状況・カテゴリ・数値・補足メモ入力 */}
      <section
        aria-label="コンボの属性と補足メモ"
        className="mb-5 space-y-5 rounded-xl border border-slate-200 bg-white p-3.5 shadow-xs sm:p-5 dark:border-[#2E2447] dark:bg-[#1B152B]"
      >
        {/* コンボタイトル（任意） */}
        <div className="space-y-1.5">
          <div className="flex items-center justify-between gap-2">
            <label
              htmlFor="combo-title-input"
              className="text-sm font-bold text-slate-900 dark:text-[#F4F1FF]"
            >
              コンボタイトル（任意）
            </label>
            <span className="text-[11px] text-slate-400 dark:text-[#8E82B3]">
              {title.trim().length}/60
            </span>
          </div>
          <input
            id="combo-title-input"
            type="text"
            maxLength={60}
            value={title}
            onChange={(e) => {
              setTitle(e.target.value);
              clearErrors();
            }}
            placeholder="例: 屈中Kラッシュ運び定番 / 画面端パニカン最大"
            className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-base text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none sm:text-sm dark:border-[#3A2E58] dark:bg-[#140F23] dark:text-[#F4F1FF] dark:placeholder:text-[#8E82B3] dark:focus:border-[#8B5CF6]"
          />
        </div>

        {/* 状況タグ選択（必須・複数選択可） */}
        <div>
          <div className="mb-2 flex items-center justify-between gap-2">
            <span className="text-sm font-bold text-slate-900 dark:text-[#F4F1FF]">
              状況タグ（複数選択可） <span className="text-rose-500 dark:text-rose-400">*</span>
            </span>
            <span className="text-[11px] text-slate-500 dark:text-[#A99EC4]">
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
                      ? `${sit.badgeClassName} ring-2 ring-blue-600 ring-offset-1 dark:ring-[#8B5CF6] dark:ring-offset-[#1B152B]`
                      : "border border-slate-200 bg-slate-50 text-slate-600 hover:bg-slate-100 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:bg-[#30264A]"
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
          <span className="mb-2 block text-sm font-bold text-slate-900 dark:text-[#F4F1FF]">
            カテゴリ <span className="text-rose-500 dark:text-rose-400">*</span>
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
                      ? "border-blue-600 bg-blue-50 text-blue-700 dark:border-[#8B5CF6] dark:bg-violet-500/20 dark:text-[#DDD6FE]"
                      : "border-slate-200 bg-white text-slate-700 hover:bg-slate-50 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:bg-[#30264A]"
                  }`}
                >
                  {cat.label}
                </button>
              );
            })}
          </div>
        </div>

        {/* 数値・ゲージ・起き攻め */}
        <div className="grid grid-cols-1 gap-4 border-t border-slate-100 pt-4 sm:grid-cols-2 dark:border-[#2D2346]">
          {/* ダメージ */}
          <label className="flex flex-col gap-1.5 text-xs font-bold text-slate-700 dark:text-[#CFC6E8]">
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
              className="rounded-lg border border-slate-300 bg-white px-3 py-2 text-base text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none sm:text-sm dark:border-[#3A2E58] dark:bg-[#140F23] dark:text-[#F4F1FF] dark:placeholder:text-[#8E82B3] dark:focus:border-[#8B5CF6]"
            />
          </label>

          {/* 起き攻め */}
          <div className="flex flex-col gap-1.5 text-xs font-bold text-slate-700 dark:text-[#CFC6E8]">
            <span>起き攻めの有無</span>
            <div className="grid grid-cols-2 rounded-lg bg-slate-100 p-1 dark:bg-[#251D3A]">
              <button
                type="button"
                onClick={() => setHasOki(true)}
                className={`inline-flex items-center justify-center gap-1 rounded-md py-1.5 text-xs font-semibold transition-all sm:text-sm ${
                  hasOki
                    ? "bg-emerald-600 text-white shadow-xs dark:bg-emerald-500"
                    : "text-slate-600 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:text-[#F4F1FF]"
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
                    ? "bg-white text-slate-900 shadow-xs dark:bg-[#3A2E58] dark:text-[#F4F1FF]"
                    : "text-slate-600 hover:text-slate-900 dark:text-[#A99EC4] dark:hover:text-[#F4F1FF]"
                }`}
              >
                なし
              </button>
            </div>
          </div>

          {/* 消費Dゲージ（自動計算＋手動微調整＋自動復帰） */}
          <div className="flex flex-col gap-1.5 text-xs font-bold text-slate-700 dark:text-[#CFC6E8]">
            <div className="flex flex-wrap items-center justify-between gap-1.5">
              <div className="flex flex-wrap items-center gap-1.5">
                <span>消費Dゲージ（0〜6）</span>
                {driveCostMode === "auto" ? (
                  <span className="inline-flex items-center rounded-full border border-emerald-200 bg-emerald-50 px-2 py-0.5 text-[10px] font-semibold text-emerald-700 dark:border-emerald-400/35 dark:bg-emerald-500/20 dark:text-emerald-200">
                    自動計算
                  </span>
                ) : (
                  <>
                    <span className="inline-flex items-center rounded-full border border-amber-200 bg-amber-50 px-2 py-0.5 text-[10px] font-semibold text-amber-700 dark:border-amber-400/35 dark:bg-amber-500/20 dark:text-amber-200">
                      手動調整中
                    </span>
                    <button
                      type="button"
                      onClick={handleResetDriveCostToAuto}
                      className="inline-flex items-center gap-0.5 rounded-md border border-slate-200 bg-white px-1.5 py-0.5 text-[10px] font-semibold text-blue-600 transition-colors hover:border-blue-300 hover:bg-blue-50 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#C4B5FD] dark:hover:border-[#8B5CF6] dark:hover:bg-[#30264A]"
                    >
                      <RotateCcw className="h-2.5 w-2.5" aria-hidden="true" />
                      <span>自動に戻す</span>
                    </button>
                  </>
                )}
              </div>
              <span className="font-mono text-xs text-slate-600 dark:text-[#E2DCF5]">
                {driveCost} 本
              </span>
            </div>
            <div className="flex flex-wrap items-center gap-1.5">
              {[0, 1, 2, 3, 4, 5, 6].map((val) => (
                <button
                  key={val}
                  type="button"
                  onClick={() => handleManualDriveCostChange(val)}
                  className={`h-8 w-8 rounded-lg border text-xs font-bold transition-colors ${
                    driveCost === val
                      ? "border-emerald-600 bg-emerald-600 text-white dark:border-emerald-500 dark:bg-emerald-500"
                      : "border-slate-200 bg-white text-slate-700 hover:bg-slate-50 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:bg-[#30264A]"
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
                    handleManualDriveCostChange(Math.min(6, Math.max(0, v)));
                  }
                }}
                aria-label="消費Dゲージ数値入力（0.5刻み可）"
                className="w-16 rounded-lg border border-slate-300 bg-white px-2 py-1.5 text-center font-mono text-xs text-slate-900 focus:border-blue-500 focus:outline-none dark:border-[#3A2E58] dark:bg-[#140F23] dark:text-[#F4F1FF] dark:focus:border-[#8B5CF6]"
              />
            </div>
            {autoGauge.isDriveOverCap && (
              <p className="text-[11px] font-medium leading-relaxed text-amber-700 dark:text-amber-300">
                ※計算上 {autoGauge.rawDriveCost}{" "}
                本消費（バーンアウト想定のため上限 6 で登録されます）
              </p>
            )}
          </div>

          {/* 消費SAゲージ（自動計算＋手動微調整＋自動復帰） */}
          <div className="flex flex-col gap-1.5 text-xs font-bold text-slate-700 dark:text-[#CFC6E8]">
            <div className="flex flex-wrap items-center gap-1.5">
              <span>消費SAゲージ</span>
              {saCostMode === "auto" ? (
                <span className="inline-flex items-center rounded-full border border-indigo-200 bg-indigo-50 px-2 py-0.5 text-[10px] font-semibold text-indigo-700 dark:border-violet-400/35 dark:bg-violet-500/20 dark:text-violet-200">
                  自動計算
                </span>
              ) : (
                <>
                  <span className="inline-flex items-center rounded-full border border-amber-200 bg-amber-50 px-2 py-0.5 text-[10px] font-semibold text-amber-700 dark:border-amber-400/35 dark:bg-amber-500/20 dark:text-amber-200">
                    手動調整中
                  </span>
                  <button
                    type="button"
                    onClick={handleResetSaCostToAuto}
                    className="inline-flex items-center gap-0.5 rounded-md border border-slate-200 bg-white px-1.5 py-0.5 text-[10px] font-semibold text-blue-600 transition-colors hover:border-blue-300 hover:bg-blue-50 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#C4B5FD] dark:hover:border-[#8B5CF6] dark:hover:bg-[#30264A]"
                  >
                    <RotateCcw className="h-2.5 w-2.5" aria-hidden="true" />
                    <span>自動に戻す</span>
                  </button>
                </>
              )}
            </div>
            <div className="grid grid-cols-4 gap-1.5">
              {([0, 1, 2, 3] as const).map((val) => (
                <button
                  key={val}
                  type="button"
                  onClick={() => handleManualSaCostChange(val)}
                  className={`rounded-lg border py-1.5 font-mono text-xs font-bold transition-colors ${
                    saCost === val
                      ? "border-indigo-600 bg-indigo-600 text-white dark:border-[#7C3AED] dark:bg-[#7C3AED]"
                      : "border-slate-200 bg-white text-slate-700 hover:bg-slate-50 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:bg-[#30264A]"
                  }`}
                >
                  SA {val}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* キャラ固有ストック（ジュリ・イングリッド・舞など対応キャラのみ表示） */}
        {stockMeta && (
          <div className="grid grid-cols-1 gap-4 rounded-xl border border-slate-200 bg-slate-50/70 p-3 sm:grid-cols-2 dark:border-[#2E2447] dark:bg-[#140F23]">
            <div className="flex flex-col gap-1.5 text-xs font-bold text-slate-700 dark:text-[#CFC6E8]">
              <div className="flex flex-wrap items-center gap-1.5">
                <span>{stockMeta.label} 消費数（始動必要数）</span>
                {supportsAutoStock &&
                  (stockCostMode === "auto" ? (
                    <span className="inline-flex items-center rounded-full border border-pink-200 bg-pink-50 px-2 py-0.5 text-[10px] font-semibold text-pink-700 dark:border-pink-400/35 dark:bg-pink-500/20 dark:text-pink-200">
                      自動計算
                    </span>
                  ) : (
                    <>
                      <span className="inline-flex items-center rounded-full border border-amber-200 bg-amber-50 px-2 py-0.5 text-[10px] font-semibold text-amber-700 dark:border-amber-400/35 dark:bg-amber-500/20 dark:text-amber-200">
                        手動調整中
                      </span>
                      <button
                        type="button"
                        onClick={handleResetStockCostToAuto}
                        className="inline-flex items-center gap-0.5 rounded-md border border-slate-200 bg-white px-1.5 py-0.5 text-[10px] font-semibold text-blue-600 transition-colors hover:border-blue-300 hover:bg-blue-50 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#C4B5FD] dark:hover:border-[#8B5CF6] dark:hover:bg-[#30264A]"
                      >
                        <RotateCcw className="h-2.5 w-2.5" aria-hidden="true" />
                        <span>自動に戻す</span>
                      </button>
                    </>
                  ))}
              </div>
              <div className="flex flex-wrap gap-1.5">
                {Array.from(
                  { length: stockMeta.maxCount + 1 },
                  (_, i) => i
                ).map((val) => (
                  <button
                    key={`cost-${val}`}
                    type="button"
                    onClick={() => handleManualStockCostChange(val)}
                    className={`rounded-lg border px-2.5 py-1 text-xs font-semibold transition-colors ${
                      stockCost === val
                        ? "border-pink-600 bg-pink-600 text-white dark:border-pink-500 dark:bg-pink-500"
                        : "border-slate-200 bg-white text-slate-700 hover:bg-pink-50 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:bg-pink-500/20"
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

            <div className="flex flex-col gap-1.5 text-xs font-bold text-slate-700 dark:text-[#CFC6E8]">
              <div className="flex flex-wrap items-center gap-1.5">
                <span>
                  {stockMeta.label} 獲得数
                  {stockMeta.gainHint && (
                    <span className="ml-1.5 font-normal text-slate-500 dark:text-[#A99EC4]">
                      （{stockMeta.gainHint}）
                    </span>
                  )}
                </span>
                {supportsAutoStock &&
                  (stockGainMode === "auto" ? (
                    <span className="inline-flex items-center rounded-full border border-cyan-200 bg-cyan-50 px-2 py-0.5 text-[10px] font-semibold text-cyan-700 dark:border-cyan-400/35 dark:bg-cyan-500/20 dark:text-cyan-200">
                      自動計算
                    </span>
                  ) : (
                    <>
                      <span className="inline-flex items-center rounded-full border border-amber-200 bg-amber-50 px-2 py-0.5 text-[10px] font-semibold text-amber-700 dark:border-amber-400/35 dark:bg-amber-500/20 dark:text-amber-200">
                        手動調整中
                      </span>
                      <button
                        type="button"
                        onClick={handleResetStockGainToAuto}
                        className="inline-flex items-center gap-0.5 rounded-md border border-slate-200 bg-white px-1.5 py-0.5 text-[10px] font-semibold text-blue-600 transition-colors hover:border-blue-300 hover:bg-blue-50 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#C4B5FD] dark:hover:border-[#8B5CF6] dark:hover:bg-[#30264A]"
                      >
                        <RotateCcw className="h-2.5 w-2.5" aria-hidden="true" />
                        <span>自動に戻す</span>
                      </button>
                    </>
                  ))}
              </div>
              <div className="flex flex-wrap gap-1.5">
                {(
                  stockMeta.gainOptions ??
                  Array.from({ length: stockMeta.maxCount + 1 }, (_, i) => i)
                ).map((val) => (
                  <button
                    key={`gain-${val}`}
                    type="button"
                    onClick={() => handleManualStockGainChange(val)}
                    className={`rounded-lg border px-2.5 py-1 text-xs font-semibold transition-colors ${
                      stockGain === val
                        ? "border-cyan-600 bg-cyan-600 text-white dark:border-cyan-500 dark:bg-cyan-500"
                        : "border-slate-200 bg-white text-slate-700 hover:bg-cyan-50 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#CFC6E8] dark:hover:bg-cyan-500/20"
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
        <div className="space-y-2 border-t border-slate-100 pt-4 dark:border-[#2D2346]">
          <label
            htmlFor="combo-note-textarea"
            className="block text-sm font-bold text-slate-900 dark:text-[#F4F1FF]"
          >
            補足メモ・コツ <span className="text-rose-500 dark:text-rose-400">*</span>
          </label>
          {recipeMoveIds.includes("sys_delay") && (
            <div className="flex items-start gap-2 rounded-lg border border-blue-200 bg-blue-50 px-3 py-2 text-xs leading-relaxed text-blue-800 dark:border-sky-400/35 dark:bg-sky-500/15 dark:text-sky-200">
              <Info
                className="mt-0.5 h-4 w-4 shrink-0 text-blue-600 dark:text-sky-300"
                aria-hidden="true"
              />
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
              clearErrors();
            }}
            placeholder="タイミングのコツ、距離限定、キャラ限定、起き攻めのフレーム状況などを記入してください。"
            className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2.5 text-base leading-relaxed text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none sm:text-sm dark:border-[#3A2E58] dark:bg-[#140F23] dark:text-[#F4F1FF] dark:placeholder:text-[#8E82B3] dark:focus:border-[#8B5CF6]"
          />
        </div>
      </section>

      {/* 重複コンボ自動チェック警告 */}
      {duplicateCombo && (
        <div
          role="alert"
          className="mb-4 flex flex-col gap-2.5 rounded-xl border border-amber-300 bg-amber-50 p-3.5 text-amber-900 sm:flex-row sm:items-center sm:justify-between dark:border-amber-400/35 dark:bg-amber-500/15 dark:text-amber-100"
        >
          <div className="flex items-start gap-2.5">
            <AlertTriangle
              className="mt-0.5 h-5 w-5 shrink-0 text-amber-600 dark:text-amber-300"
              aria-hidden="true"
            />
            <div className="text-xs leading-relaxed sm:text-sm">
              <p className="font-bold">同じレシピが既に登録されています</p>
              <p className="text-amber-800 dark:text-amber-200/90">
                重複投稿を避けるため、先に既存のコンボ内容をご確認ください。
              </p>
            </div>
          </div>
          <button
            type="button"
            onClick={() => setPreviewDuplicateModal(true)}
            className="inline-flex shrink-0 items-center justify-center gap-1.5 rounded-lg border border-amber-400 bg-white px-3 py-1.5 text-xs font-semibold text-amber-900 transition-colors hover:bg-amber-100 dark:border-amber-400/40 dark:bg-amber-500/20 dark:text-amber-100 dark:hover:bg-amber-500/30"
          >
            <span>既存コンボを確認</span>
            <ExternalLink className="h-3.5 w-3.5" aria-hidden="true" />
          </button>
        </div>
      )}

      {isCheckingDuplicate && recipeMoveIds.length > 0 && !duplicateCombo && (
        <p className="mb-3 text-right text-[11px] text-slate-400 dark:text-[#8E82B3]">
          重複レシピを確認中...
        </p>
      )}

      {/* バリデーション・送信エラー */}
      {activeError && (
        <div
          role="alert"
          className="mb-4 flex items-start gap-2 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-xs font-medium text-rose-700 sm:text-sm dark:border-rose-500/35 dark:bg-rose-500/15 dark:text-rose-200"
        >
          <AlertCircle
            className="mt-0.5 h-4 w-4 shrink-0"
            aria-hidden="true"
          />
          <span>{activeError}</span>
        </div>
      )}

      {/* 投稿・更新成功通知 */}
      {submitSuccess && (
        <div
          role="status"
          className="mb-4 flex items-center gap-2 rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-xs font-semibold text-emerald-800 sm:text-sm dark:border-emerald-500/35 dark:bg-emerald-500/15 dark:text-emerald-200"
        >
          <CheckCircle2 className="h-4 w-4 shrink-0" aria-hidden="true" />
          <span>{submitSuccess}</span>
        </div>
      )}

      {/* 送信ボタン */}
      <div className="flex flex-col-reverse gap-2 sm:flex-row sm:items-center sm:justify-between">
        <p className="text-[11px] text-slate-500 dark:text-[#A99EC4]">
          {mode === "create"
            ? "※ 投稿時の最新ゲームバージョンが自動で紐付けられます。"
            : "※ 変更内容は公開コンボ一覧へ即座に反映されます。"}
        </p>
        <button
          type="submit"
          disabled={isSubmitting || Boolean(submitSuccess)}
          className="inline-flex items-center justify-center gap-2 rounded-xl bg-blue-600 px-6 py-3 text-sm font-bold text-white shadow-sm transition-colors hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-60 dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
        >
          <Send className="h-4 w-4" aria-hidden="true" />
          <span>
            {mode === "create"
              ? isSubmitting
                ? "投稿中..."
                : "公開コンボを投稿する"
              : isSubmitting
                ? "更新中..."
                : "変更を保存する"}
          </span>
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
