"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  ArrowLeft,
  Lock,
  LogIn,
  Pencil,
  ShieldAlert,
} from "lucide-react";
import type { Character, Combo, GameVersion, Move } from "@/types/combo";
import { createClient } from "@/lib/supabase/client";
import { useAuth } from "@/components/AuthProvider";
import { usePreferences } from "@/hooks/useComboNoteStorage";
import {
  ComboForm,
  type ComboFormSubmitPayload,
} from "@/components/ComboForm";

interface ComboEditClientProps {
  comboId: string;
  combo: Combo | null;
  characters: Character[];
  allMoves: Move[];
  versions: GameVersion[];
}

export function ComboEditClient({
  comboId,
  combo,
  characters,
  allMoves,
  versions,
}: ComboEditClientProps) {
  const router = useRouter();
  const { user, isLoading } = useAuth();
  const { setControlType: savePreferredControlType } = usePreferences();

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [submitSuccess, setSubmitSuccess] = useState<string | null>(null);

  const targetCharacter = combo
    ? characters.find((c) => c.id === combo.characterId)
    : undefined;
  const backHref = targetCharacter
    ? `/characters/${targetCharacter.slug}`
    : "/";
  const backLabel = targetCharacter
    ? `${targetCharacter.nameJa}のコンボ一覧へ戻る`
    : "キャラ一覧へ戻る";

  const handleSubmit = async (payload: ComboFormSubmitPayload) => {
    if (!user || !combo || isSubmitting) return;

    setSubmitError(null);
    setIsSubmitting(true);
    const supabase = createClient();

    try {
      const { data: updatedRow, error: updateError } = await supabase
        .from("combos")
        .update({
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
          updated_at: new Date().toISOString(),
        })
        .eq("id", combo.id)
        .eq("author_id", user.id)
        .select("id")
        .maybeSingle();

      if (updateError) {
        throw new Error(`コンボの更新に失敗しました: ${updateError.message}`);
      }
      if (!updatedRow) {
        throw new Error(
          "更新対象のコンボが見つからないか、編集権限がありません。"
        );
      }

      // 更新した操作タイプを一覧側にも引き継ぐ
      savePreferredControlType(payload.controlType);
      setSubmitSuccess(
        "コンボの変更を保存しました！キャラクターのコンボ一覧へ移動します..."
      );

      const targetSlug = targetCharacter?.slug ?? combo.characterId;
      window.setTimeout(() => {
        router.push(`/characters/${targetSlug}`);
        router.refresh();
      }, 700);
    } catch (err) {
      const message =
        err instanceof Error
          ? err.message
          : "コンボの更新中にエラーが発生しました。";
      setSubmitError(message);
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
    const loginNext = encodeURIComponent(`/combos/${comboId}/edit`);
    return (
      <div className="mx-auto w-full max-w-lg px-3 py-10 sm:px-6">
        <div className="rounded-2xl border border-slate-200 bg-white p-6 text-center shadow-xs">
          <div className="mx-auto mb-3 flex h-11 w-11 items-center justify-center rounded-full bg-blue-50 text-blue-600">
            <Lock className="h-5 w-5" aria-hidden="true" />
          </div>
          <h1 className="text-lg font-bold text-slate-900">
            公開コンボの編集にはログインが必要です
          </h1>
          <p className="mt-1.5 text-xs leading-relaxed text-slate-600 sm:text-sm">
            投稿した本人のアカウントでログインすると、コンボ内容を編集できます。
          </p>
          <div className="mt-5 flex flex-wrap items-center justify-center gap-2.5">
            <Link
              href={`/login?next=${loginNext}`}
              className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white shadow-xs transition-colors hover:bg-blue-700"
            >
              <LogIn className="h-4 w-4" aria-hidden="true" />
              <span>ログイン画面へ進む</span>
            </Link>
            <Link
              href={backHref}
              className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 transition-colors hover:bg-slate-50"
            >
              {backLabel}
            </Link>
          </div>
        </div>
      </div>
    );
  }

  // コンボが存在しない、または投稿者本人ではない場合
  if (!combo || combo.authorId !== user.id) {
    return (
      <div className="mx-auto w-full max-w-lg px-3 py-10 sm:px-6">
        <div className="rounded-2xl border border-slate-200 bg-white p-6 text-center shadow-xs">
          <div className="mx-auto mb-3 flex h-11 w-11 items-center justify-center rounded-full bg-rose-50 text-rose-600">
            <ShieldAlert className="h-5 w-5" aria-hidden="true" />
          </div>
          <h1 className="text-lg font-bold text-slate-900">
            このコンボを編集する権限がありません
          </h1>
          <p className="mt-1.5 text-xs leading-relaxed text-slate-600 sm:text-sm">
            指定されたコンボが見つからないか、他のユーザーが投稿したコンボです。自分が投稿したコンボのみ編集できます。
          </p>
          <div className="mt-5 flex flex-wrap items-center justify-center gap-2.5">
            {targetCharacter && (
              <Link
                href={`/characters/${targetCharacter.slug}`}
                className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white shadow-xs transition-colors hover:bg-blue-700"
              >
                <ArrowLeft className="h-4 w-4" aria-hidden="true" />
                <span>{targetCharacter.nameJa}のコンボ一覧へ戻る</span>
              </Link>
            )}
            <Link
              href="/"
              className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 transition-colors hover:bg-slate-50"
            >
              トップへ戻る
            </Link>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto w-full max-w-5xl px-3 py-4 pb-10 sm:px-6 sm:py-6">
      {/* 戻るリンク */}
      <div className="mb-3">
        <Link
          href={backHref}
          className="inline-flex items-center gap-1 text-xs font-semibold text-slate-600 transition-colors hover:text-blue-600"
        >
          <ArrowLeft className="h-3.5 w-3.5" aria-hidden="true" />
          <span>{backLabel}</span>
        </Link>
      </div>

      {/* ページ見出し */}
      <div className="mb-4">
        <h1 className="flex items-center gap-2 text-xl font-bold tracking-tight text-slate-900 sm:text-2xl">
          <Pencil className="h-5 w-5 text-blue-600" aria-hidden="true" />
          <span>公開コンボを編集</span>
        </h1>
        <p className="mt-0.5 text-xs text-slate-500">
          レシピ・状況タグ・ゲージ・補足メモを修正して保存できます。
        </p>
      </div>

      <ComboForm
        mode="edit"
        characters={characters}
        allMoves={allMoves}
        versions={versions}
        initialCombo={combo}
        excludeComboId={combo.id}
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
