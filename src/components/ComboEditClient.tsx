"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  ArrowLeft,
  Lock,
  LogIn,
  Pencil,
  Shield,
  ShieldAlert,
} from "lucide-react";
import type { Character, Combo, GameVersion, Move } from "@/types/combo";
import { validateSourceUrl } from "@/lib/sourceUrl";
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
  initialMoves: Move[];
  versions: GameVersion[];
}

export function ComboEditClient({
  comboId,
  combo,
  characters,
  initialMoves,
  versions,
}: ComboEditClientProps) {
  const router = useRouter();
  const { user, isAdmin, isLoading } = useAuth();
  const { setControlType: savePreferredControlType } = usePreferences();

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);
  const [submitSuccess, setSubmitSuccess] = useState<string | null>(null);

  const isOwner = Boolean(user && combo && combo.authorId === user.id);
  const canEdit = Boolean(user && combo && (isOwner || isAdmin));
  const isAdminEdit = Boolean(user && combo && !isOwner && isAdmin);

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
    if (!user || !combo || !canEdit || isSubmitting) return;

    setSubmitError(null);
    setIsSubmitting(true);
    const supabase = createClient();

    try {
      const normalizedAuthorName = payload.authorName?.trim() || null;

      let sourceUrlUpdate: { source_url: string | null } | Record<string, never> =
        {};
      if (payload.sourceUrl !== undefined) {
        const sourceUrlResult = validateSourceUrl(payload.sourceUrl);
        if (!sourceUrlResult.isValid) {
          throw new Error(
            sourceUrlResult.error ??
              "YouTube または X（旧Twitter）のURLのみ登録できます。"
          );
        }
        sourceUrlUpdate = { source_url: sourceUrlResult.normalizedUrl };
      }

      // 管理者が他ユーザーのコンボを編集した際も author_id（投稿者アカウント紐付け）は上書きしない。
      // 認可は DB の RLS ポリシー（auth.uid() = author_id OR public.is_admin()）で強制する。
      const { data: updatedRow, error: updateError } = await supabase
        .from("combos")
        .update({
          author_name: normalizedAuthorName,
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
          ...sourceUrlUpdate,
          updated_at: new Date().toISOString(),
        })
        .eq("id", combo.id)
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
        <div className="h-44 rounded-2xl border border-slate-200 bg-white dark:border-[#2E2447] dark:bg-[#1B152B]" />
      </div>
    );
  }

  // 未ログイン時のガード表示
  if (!user) {
    const loginNext = encodeURIComponent(`/combos/${comboId}/edit`);
    return (
      <div className="mx-auto w-full max-w-lg px-3 py-10 sm:px-6">
        <div className="rounded-2xl border border-slate-200 bg-white p-6 text-center shadow-xs dark:border-[#2E2447] dark:bg-[#1B152B]">
          <div className="mx-auto mb-3 flex h-11 w-11 items-center justify-center rounded-full bg-blue-50 text-blue-600 dark:bg-violet-500/20 dark:text-[#C4B5FD]">
            <Lock className="h-5 w-5" aria-hidden="true" />
          </div>
          <h1 className="text-lg font-bold text-slate-900 dark:text-[#F4F1FF]">
            公開コンボの編集にはログインが必要です
          </h1>
          <p className="mt-1.5 text-xs leading-relaxed text-slate-600 sm:text-sm dark:text-[#A99EC4]">
            投稿した本人のアカウントでログインすると、コンボ内容を編集できます。
          </p>
          <div className="mt-5 flex flex-wrap items-center justify-center gap-2.5">
            <Link
              href={`/login?next=${loginNext}`}
              className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white shadow-xs transition-colors hover:bg-blue-700 dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
            >
              <LogIn className="h-4 w-4" aria-hidden="true" />
              <span>ログイン画面へ進む</span>
            </Link>
            <Link
              href={backHref}
              className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 transition-colors hover:bg-slate-50 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#E2DCF5] dark:hover:bg-[#30264A]"
            >
              {backLabel}
            </Link>
          </div>
        </div>
      </div>
    );
  }

  // コンボが存在しない、または投稿者本人・管理者ではない場合
  if (!combo || !canEdit) {
    return (
      <div className="mx-auto w-full max-w-lg px-3 py-10 sm:px-6">
        <div className="rounded-2xl border border-slate-200 bg-white p-6 text-center shadow-xs dark:border-[#2E2447] dark:bg-[#1B152B]">
          <div className="mx-auto mb-3 flex h-11 w-11 items-center justify-center rounded-full bg-rose-50 text-rose-600 dark:bg-rose-500/20 dark:text-rose-300">
            <ShieldAlert className="h-5 w-5" aria-hidden="true" />
          </div>
          <h1 className="text-lg font-bold text-slate-900 dark:text-[#F4F1FF]">
            このコンボを編集する権限がありません
          </h1>
          <p className="mt-1.5 text-xs leading-relaxed text-slate-600 sm:text-sm dark:text-[#A99EC4]">
            指定されたコンボが見つからないか、他のユーザーが投稿したコンボです。自分が投稿したコンボのみ編集できます。
          </p>
          <div className="mt-5 flex flex-wrap items-center justify-center gap-2.5">
            {targetCharacter && (
              <Link
                href={`/characters/${targetCharacter.slug}`}
                className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white shadow-xs transition-colors hover:bg-blue-700 dark:bg-[#7C3AED] dark:hover:bg-[#6D28D9]"
              >
                <ArrowLeft className="h-4 w-4" aria-hidden="true" />
                <span>{targetCharacter.nameJa}のコンボ一覧へ戻る</span>
              </Link>
            )}
            <Link
              href="/"
              className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 transition-colors hover:bg-slate-50 dark:border-[#3A2E58] dark:bg-[#251D3A] dark:text-[#E2DCF5] dark:hover:bg-[#30264A]"
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
          className="inline-flex items-center gap-1 text-xs font-semibold text-slate-600 transition-colors hover:text-blue-600 dark:text-[#A99EC4] dark:hover:text-[#C4B5FD]"
        >
          <ArrowLeft className="h-3.5 w-3.5" aria-hidden="true" />
          <span>{backLabel}</span>
        </Link>
      </div>

      {/* ページ見出し */}
      <div className="mb-4">
        <h1 className="flex items-center gap-2 text-xl font-bold tracking-tight text-slate-900 sm:text-2xl dark:text-[#F4F1FF]">
          <Pencil className="h-5 w-5 text-blue-600 dark:text-[#A78BFA]" aria-hidden="true" />
          <span>公開コンボを編集</span>
        </h1>
        <p className="mt-0.5 text-xs text-slate-500 dark:text-[#A99EC4]">
          レシピ・状況タグ・ゲージ・補足メモを修正して保存できます。
        </p>
        {isAdminEdit && (
          <div className="mt-3 flex items-start gap-2 rounded-xl border border-amber-200 bg-amber-50 px-3.5 py-2.5 text-xs text-amber-900 dark:border-amber-400/35 dark:bg-amber-500/15 dark:text-amber-200">
            <Shield
              className="mt-0.5 h-4 w-4 shrink-0 text-amber-600 dark:text-amber-300"
              aria-hidden="true"
            />
            <span>
              <strong>管理者権限で編集しています。</strong>
              元の投稿者アカウント（表示名: {combo.authorName?.trim() || "未設定（匿名）"}）の紐付けは変更されません。
            </span>
          </div>
        )}
      </div>

      <ComboForm
        mode="edit"
        characters={characters}
        initialMoves={initialMoves}
        initialAuthorName={combo.authorName ?? ""}
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
