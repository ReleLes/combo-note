import { SEED_SITUATIONS } from "@/data/seed";
import {
  buildMoveMap,
  fetchActiveCharacters,
  fetchAllCombos,
  fetchAllMoves,
  fetchGameVersions,
} from "@/lib/supabase/queries";
import type { Character, Combo, GameVersion, Move } from "@/types/combo";
import { MyNoteClient } from "@/components/MyNoteClient";
import { DataErrorBanner } from "@/components/DataErrorBanner";

export const dynamic = "force-dynamic";

export default async function MyNotePage() {
  let characters: Character[] = [];
  let allCombos: Combo[] = [];
  let allMoves: Move[] = [];
  let versions: GameVersion[] = [];
  let errorMessage: string | null = null;

  try {
    [characters, allCombos, allMoves, versions] = await Promise.all([
      fetchActiveCharacters(),
      fetchAllCombos(),
      fetchAllMoves(),
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
        title="マイノートを読み込めませんでした"
        message={errorMessage}
      />
    );
  }

  const moveMap = buildMoveMap(allMoves);

  return (
    <MyNoteClient
      characters={characters}
      allCombos={allCombos}
      allMoves={allMoves}
      moveMap={moveMap}
      allSituations={SEED_SITUATIONS}
      versions={versions}
    />
  );
}
