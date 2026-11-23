import type { Metadata } from "next";
import {
  fetchActiveCharacters,
  fetchGameVersions,
  fetchMovesForCharacter,
} from "@/lib/supabase/queries";
import type { Character, GameVersion, Move } from "@/types/combo";
import { DataErrorBanner } from "@/components/DataErrorBanner";
import { ComboBuilderClient } from "@/components/ComboBuilderClient";

export const metadata: Metadata = {
  title: "公開コンボを投稿",
};

export const dynamic = "force-dynamic";

interface NewComboPageProps {
  searchParams: Promise<{ character?: string | string[] }>;
}

export default async function NewComboPage({
  searchParams,
}: NewComboPageProps) {
  const resolvedSearchParams = await searchParams;
  const rawCharParam =
    typeof resolvedSearchParams.character === "string"
      ? resolvedSearchParams.character.trim()
      : undefined;

  let characters: Character[] = [];
  let initialMoves: Move[] = [];
  let versions: GameVersion[] = [];
  let initialCharacterId: string | undefined;
  let matchedCharacterSlug: string | undefined;
  let errorMessage: string | null = null;

  try {
    [characters, versions] = await Promise.all([
      fetchActiveCharacters(),
      fetchGameVersions(),
    ]);

    // URLクエリ ?character=（slug または id）に一致するアクティブキャラを照合
    const matchedCharacter = rawCharParam
      ? characters.find(
          (c) =>
            c.slug.toLowerCase() === rawCharParam.toLowerCase() ||
            c.id.toLowerCase() === rawCharParam.toLowerCase()
        )
      : undefined;

    const targetCharacter = matchedCharacter ?? characters[0];
    initialCharacterId = targetCharacter?.id;
    matchedCharacterSlug = matchedCharacter?.slug;

    // 初期表示時は初期選択キャラの技＋システム共通パーツのみを取得（全キャラ一括取得を回避）
    if (initialCharacterId) {
      initialMoves = await fetchMovesForCharacter(initialCharacterId);
    }
  } catch (error) {
    errorMessage =
      error instanceof Error
        ? error.message
        : "データベースからの読み込み中にエラーが発生しました。";
  }

  if (errorMessage) {
    return (
      <DataErrorBanner
        title="投稿画面のデータを読み込めませんでした"
        message={errorMessage}
      />
    );
  }

  return (
    <ComboBuilderClient
      characters={characters}
      initialMoves={initialMoves}
      initialCharacterId={initialCharacterId}
      initialCharacterSlug={matchedCharacterSlug}
      versions={versions}
    />
  );
}
