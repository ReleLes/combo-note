import type { Metadata } from "next";
import {
  fetchActiveCharacters,
  fetchAllMoves,
  fetchComboById,
  fetchGameVersions,
} from "@/lib/supabase/queries";
import type { Character, Combo, GameVersion, Move } from "@/types/combo";
import { DataErrorBanner } from "@/components/DataErrorBanner";
import { ComboEditClient } from "@/components/ComboEditClient";

export const metadata: Metadata = {
  title: "公開コンボを編集",
};

export const dynamic = "force-dynamic";

interface EditComboPageProps {
  params: Promise<{ id: string }>;
}

export default async function EditComboPage({ params }: EditComboPageProps) {
  const { id } = await params;

  let combo: Combo | null = null;
  let characters: Character[] = [];
  let allMoves: Move[] = [];
  let versions: GameVersion[] = [];
  let errorMessage: string | null = null;

  try {
    [combo, characters, allMoves, versions] = await Promise.all([
      fetchComboById(id),
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
        title="編集画面のデータを読み込めませんでした"
        message={errorMessage}
      />
    );
  }

  return (
    <ComboEditClient
      comboId={id}
      combo={combo}
      characters={characters}
      allMoves={allMoves}
      versions={versions}
    />
  );
}
