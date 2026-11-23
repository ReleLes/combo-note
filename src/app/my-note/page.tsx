import type { Metadata } from "next";
import { SEED_SITUATIONS } from "@/data/seed";
import {
  fetchActiveCharacters,
  fetchGameVersions,
} from "@/lib/supabase/queries";
import type { Character, GameVersion } from "@/types/combo";
import { MyNoteClient } from "@/components/MyNoteClient";
import { DataErrorBanner } from "@/components/DataErrorBanner";

export const metadata: Metadata = {
  title: "マイノート",
};

export const dynamic = "force-dynamic";

export default async function MyNotePage() {
  let characters: Character[] = [];
  let versions: GameVersion[] = [];
  let errorMessage: string | null = null;

  try {
    // サーバー側では全コンボ・全技の一括取得を行わず、軽量なキャラ一覧・バージョンのみ取得
    // 保存済みコンボおよび必要キャラ分の技はクライアント側で必要最小限だけ取得する
    [characters, versions] = await Promise.all([
      fetchActiveCharacters(),
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

  return (
    <MyNoteClient
      characters={characters}
      allSituations={SEED_SITUATIONS}
      versions={versions}
    />
  );
}
