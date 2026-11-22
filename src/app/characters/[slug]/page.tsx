import { notFound } from "next/navigation";
import { getSituationsForCharacter } from "@/data/seed";
import {
  buildMoveMap,
  fetchActiveCharacters,
  fetchCharacterBySlug,
  fetchCombosByCharacter,
  fetchGameVersions,
  fetchMovesForCharacter,
} from "@/lib/supabase/queries";
import type { Character, Combo, GameVersion, Move } from "@/types/combo";
import { CharacterComboListClient } from "@/components/CharacterComboListClient";
import { DataErrorBanner } from "@/components/DataErrorBanner";

export const dynamic = "force-dynamic";

interface CharacterPageProps {
  params: Promise<{ slug: string }>;
  searchParams: Promise<{ combo?: string | string[] }>;
}

export default async function CharacterPage({
  params,
  searchParams,
}: CharacterPageProps) {
  const [{ slug }, resolvedSearchParams] = await Promise.all([
    params,
    searchParams,
  ]);
  const initialComboId =
    typeof resolvedSearchParams.combo === "string"
      ? resolvedSearchParams.combo
      : undefined;

  let character: Character | null = null;
  let errorMessage: string | null = null;

  try {
    character = await fetchCharacterBySlug(slug);
  } catch (error) {
    errorMessage =
      error instanceof Error
        ? error.message
        : "データベースからの読み込み中にエラーが発生しました。";
  }

  if (errorMessage) {
    return (
      <DataErrorBanner
        title="キャラクター情報を読み込めませんでした"
        message={errorMessage}
      />
    );
  }

  if (!character) {
    notFound();
  }

  let allCharacters: Character[] = [];
  let combos: Combo[] = [];
  let moves: Move[] = [];
  let versions: GameVersion[] = [];

  try {
    [allCharacters, combos, moves, versions] = await Promise.all([
      fetchActiveCharacters(),
      fetchCombosByCharacter(character.id),
      fetchMovesForCharacter(character.id),
      fetchGameVersions(),
    ]);
  } catch (error) {
    errorMessage =
      error instanceof Error
        ? error.message
        : "データベースからの読み込み中にエラーが発生しました。";
  }

  if (errorMessage) {
    return (
      <DataErrorBanner
        title="コンボ一覧を読み込めませんでした"
        message={errorMessage}
      />
    );
  }

  const moveMap = buildMoveMap(moves);
  const situations = getSituationsForCharacter(character.id);

  return (
    <CharacterComboListClient
      character={character}
      allCharacters={allCharacters}
      combos={combos}
      moveMap={moveMap}
      situations={situations}
      versions={versions}
      initialComboId={initialComboId}
    />
  );
}
