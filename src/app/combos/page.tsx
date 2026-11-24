import type { Metadata } from "next";
import { SEED_SITUATIONS } from "@/data/seed/common";
import { buildCharacterImageMap } from "@/lib/characterImages";
import {
  buildMoveMap,
  fetchActiveCharacters,
  fetchGameVersions,
  fetchMovesForCharacters,
  fetchRecentCombosPage,
} from "@/lib/supabase/queries";
import type { Character, Combo, GameVersion, Move } from "@/types/combo";
import { DataErrorBanner } from "@/components/DataErrorBanner";
import { RecentComboListClient } from "@/components/RecentComboListClient";

export const dynamic = "force-dynamic";

const INITIAL_PAGE_SIZE = 20;

export const metadata: Metadata = {
  title: "新着コンボ一覧",
  description:
    "ストリートファイター6（SF6）全キャラクターの公開コンボを新着順で一覧表示。操作タイプ・キャラクター・状況タグでの絞り込みと3表記ワンタップ切替に対応。",
};

export default async function RecentCombosPage() {
  let characters: Character[] = [];
  let initialCombos: Combo[] = [];
  let initialHasMore = false;
  let versions: GameVersion[] = [];
  let moves: Move[] = [];
  let initialLoadedCharacterIds: string[] = [];
  let errorMessage: string | null = null;

  try {
    const [fetchedCharacters, recentPage, fetchedVersions] = await Promise.all([
      fetchActiveCharacters(),
      fetchRecentCombosPage({ limit: INITIAL_PAGE_SIZE, offset: 0 }),
      fetchGameVersions(),
    ]);

    characters = fetchedCharacters;
    initialCombos = recentPage.combos;
    initialHasMore = recentPage.hasMore;
    versions = fetchedVersions;

    // 取得したコンボ配列に含まれる character_id のユニーク集合のみ技マスタを取得（軽量化）
    initialLoadedCharacterIds = Array.from(
      new Set(initialCombos.map((c) => c.characterId).filter(Boolean))
    );
    moves = await fetchMovesForCharacters(initialLoadedCharacterIds);
  } catch (error) {
    errorMessage =
      error instanceof Error
        ? error.message
        : "データベースからの読み込み中にエラーが発生しました。";
  }

  if (errorMessage) {
    return (
      <DataErrorBanner
        title="新着コンボ一覧を読み込めませんでした"
        message={errorMessage}
      />
    );
  }

  const moveMap = buildMoveMap(moves);
  const characterImageMap = buildCharacterImageMap(characters);
  const commonSituations = SEED_SITUATIONS.filter(
    (s) => s.characterId === null
  ).sort((a, b) => a.sortOrder - b.sortOrder);

  return (
    <RecentComboListClient
      characters={characters}
      characterImageMap={characterImageMap}
      initialCombos={initialCombos}
      initialHasMore={initialHasMore}
      initialMoveMap={moveMap}
      initialLoadedCharacterIds={initialLoadedCharacterIds}
      commonSituations={commonSituations}
      allSituations={SEED_SITUATIONS}
      versions={versions}
    />
  );
}
