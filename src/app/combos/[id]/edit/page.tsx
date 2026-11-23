import type { Metadata } from "next";
import {
  fetchActiveCharacters,
  fetchComboById,
  fetchGameVersions,
  fetchMovesForCharacter,
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
  let initialMoves: Move[] = [];
  let versions: GameVersion[] = [];
  let errorMessage: string | null = null;

  try {
    [combo, characters, versions] = await Promise.all([
      fetchComboById(id),
      fetchActiveCharacters(),
      fetchGameVersions(),
    ]);

    // 編集対象コンボのキャラクター分の技＋システム共通パーツのみを取得
    if (combo) {
      initialMoves = await fetchMovesForCharacter(combo.characterId);
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
      initialMoves={initialMoves}
      versions={versions}
    />
  );
}
