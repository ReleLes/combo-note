"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Lock, LogIn, PlusCircle } from "lucide-react";
import type { Character, GameVersion, Move } from "@/types/combo";
import { createClient } from "@/lib/supabase/client";
import { useAuth } from "@/components/AuthProvider";
import { usePreferences } from "@/hooks/useComboNoteStorage";
import {
  ComboForm,
  type ComboFormSubmitPayload,
} from "@/components/ComboForm";

interface ComboBuilderClientProps {
  characters: Character[];
  initialMoves: Move[];
  initialCharacterId?: string;
  initialCharacterSlug?: string;
  versions: GameVersion[];
}

export function ComboBuilderClient({
  characters,
  initialMoves,
  initialCharacterId,
  initialCharacterSlug,
  versions,
}: ComboBuilderClientProps) {
  const router = useRouter();
  const { user, isLoading } = useAuth();
  const { setControlType: savePreferredControlType } = usePreferences();

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [submitSuccess, setSubmitSuccess] = useState<string | null>(null);

  const handleSubmit = async (payload: ComboFormSubmitPayload) => {
    if (!user || isSubmitting) return;

    setSubmitError(null);
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
        character_id: payload.characterId,
        control_type: payload.controlType,
        title: payload.title,
        move_ids: payload.moveIds,
        recipe_signature: payload.recipeSignature,
        situations: payload.situations,
        category: payload.category,
        damage: payload.damage,
        drive_cost: payload.driveCost,
        sa_cost: payload.saCost,
        stock_cost: payload.stockCost,
        stock_gain: payload.stockGain,
        has_oki: payload.hasOki,
        note: payload.note,
        version_id: resolvedVersionId,
      });

      if (insertError) {
        throw new Error(`コンボの投稿に失敗しました: ${insertError.message}`);
      }

      // 投稿した操作タイプを一覧側にも引き継ぐ
      savePreferredControlType(payload.controlType);
      setSubmitSuccess(
        "公開コンボを投稿しました！キャラクターのコンボ一覧へ移動します..."
      );

      const targetCharacter = characters.find(
        (c) => c.id === payload.characterId
      );
      const targetSlug = targetCharacter?.slug ?? payload.characterId;
      window.setTimeout(() => {
        router.push(`/characters/${targetSlug}`);
        router.refresh();
      }, 700);
    } catch (err) {
      const message =
        err instanceof Error
          ? err.message
          : "コンボの投稿中にエラーが発生しました。";
      setSubmitError(message);
      setIsSubmitting(false);
    }
  };

  // 認証確認中
  if (isLoading) {
    return (
      <div className="mx-auto w-full max-w-5xl animate-pulse px-3 py-6 sm:px-6">
        <div className="h-44 rounded-2xl border border-slate-200 bg-white dark:border-[#2E2447] dark:bg-[#1B152B]" />
      </div>
    );
  }

  // 未ログイン時のガード表示
  if (!user) {
    const nextPath = initialCharacterSlug
      ? `/combos/new?character=${encodeURIComponent(initialCharacterSlug)}`
      : "/combos/new";
    return (
      <div className="mx-auto w-full max-w-lg px-3 py-10 sm:px-6">
        <div className="rounded-2xl border border-slate-200 bg-white p-6 text-center shadow-xs dark:border-[#2E2447] dark:bg-[#1B152B]">
          <div className="mx-auto mb-3 flex h-11 w-11 items-center justify-center rounded-full bg-blue-50 text-blue-600 dark:bg-violet-500/20 dark:text-[#C4B5FD]">
            <Lock className="h-5 w-5" aria-hidden="true" />
          </div>
          <h1 className="text-lg font-bold text-slate-900 dark:text-[#F4F1FF]">
            公開コンボの投稿にはログインが必要です
          </h1>
          <p className="mt-1.5 text-xs leading-relaxed text-slate-600 sm:text-sm dark:text-[#A99EC4]">
            ログインすると、技ボタン選択式ビルダーで公開コンボを作成・共有できます。
          </p>
          <div className="mt-5 flex flex-wrap items-center justify-center gap-2.5">
            <Link
              href={`/login?next=${encodeURIComponent(nextPath)}`}
              className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white shadow-xs transition-colors hover:bg-blue-700 dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
            >
              <LogIn className="h-4 w-4" aria-hidden="true" />
              <span>ログイン画面へ進む</span>
            </Link>
            <Link
              href="/"
              className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 transition-colors hover:bg-slate-50 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#E2DCF5] dark:hover:bg-[#30264A]"
            >
              キャラ一覧へ戻る
            </Link>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto w-full max-w-5xl px-3 py-4 pb-10 sm:px-6 sm:py-6">
      {/* ページ見出し */}
      <div className="mb-4">
        <h1 className="flex items-center gap-2 text-xl font-bold tracking-tight text-slate-900 sm:text-2xl dark:text-[#F4F1FF]">
          <PlusCircle className="h-5 w-5 text-blue-600 dark:text-[#A78BFA]" aria-hidden="true" />
          <span>公開コンボを投稿</span>
        </h1>
        <p className="mt-0.5 text-xs text-slate-500 dark:text-[#A99EC4]">
          技ボタンをタップしてレシピを組み立て、状況と補足メモを添えて共有できます。
        </p>
      </div>

      <ComboForm
        key={initialCharacterId ?? "default"}
        mode="create"
        characters={characters}
        initialMoves={initialMoves}
        initialCharacterId={initialCharacterId}
        versions={versions}
        currentUserId={user.id}
        isSubmitting={isSubmitting}
        submitError={submitError}
        submitSuccess={submitSuccess}
        onClearSubmitError={() => setSubmitError(null)}
        onSubmit={handleSubmit}
      />
    </div>
  );
}
