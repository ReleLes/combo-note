import type { Metadata } from "next";
import {
  fetchActiveCharacters,
  fetchAllMoves,
  fetchGameVersions,
} from "@/lib/supabase/queries";

export const metadata: Metadata = {
  title: "公開コンボを投稿",
};
import type { Character, GameVersion, Move } from "@/types/combo";
import { DataErrorBanner } from "@/components/DataErrorBanner";
import { ComboBuilderClient } from "@/components/ComboBuilderClient";

export const dynamic = "force-dynamic";

export default async function NewComboPage() {
  let characters: Character[] = [];
  let allMoves: Move[] = [];
  let versions: GameVersion[] = [];
  let errorMessage: string | null = null;

  try {
    [characters, allMoves, versions] = await Promise.all([
      fetchActiveCharacters(),
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
        title="投稿画面のデータを読み込めませんでした"
        message={errorMessage}
      />
    );
  }

  return (
    <ComboBuilderClient
      characters={characters}
      allMoves={allMoves}
      versions={versions}
    />
  );
}
