import { getSituationsForCharacter } from "@/data/seed";
import { SEED_SITUATIONS } from "@/data/seed/common";
import { buildCharacterImageMap } from "@/lib/characterImages";
import { getCharacterTheme } from "@/lib/characterThemes";
import {
  type CharacterComboCounts,
  buildMoveMap,
  fetchActiveCharacters,
  fetchComboCountsByCharacter,
  fetchMovesForCharacters,
  fetchRecentCombosPage,
} from "@/lib/supabase/queries";
import type { Character, Combo, Move } from "@/types/combo";
import { DataErrorBanner } from "@/components/DataErrorBanner";
import {
  CharacterSelectGridClient,
  type CharacterSelectCardItem,
} from "@/components/CharacterSelectGridClient";
import { RecentCombosPreview } from "@/components/RecentCombosPreview";

export const dynamic = "force-dynamic";

const RECENT_PREVIEW_LIMIT = 5;

export default async function HomePage() {
  let characters: Character[] = [];
  let comboCounts: Record<string, CharacterComboCounts> = {};
  let recentCombos: Combo[] = [];
  let recentMoves: Move[] = [];
  let errorMessage: string | null = null;

  try {
    const [fetchedCharacters, fetchedComboCounts, recentPage] =
      await Promise.all([
        fetchActiveCharacters(),
        fetchComboCountsByCharacter(),
        fetchRecentCombosPage({ limit: RECENT_PREVIEW_LIMIT, offset: 0 }),
      ]);

    characters = fetchedCharacters;
    comboCounts = fetchedComboCounts;
    recentCombos = recentPage.combos;

    // 軽量化：最新5件に登場するキャラクター分＋システム共通パーツのみ技マスタを取得
    const recentCharIds = Array.from(
      new Set(recentCombos.map((c) => c.characterId).filter(Boolean))
    );
    recentMoves = await fetchMovesForCharacters(recentCharIds);
  } catch (error) {
    errorMessage =
      error instanceof Error
        ? error.message
        : "データベースからの読み込み中にエラーが発生しました。";
  }

  if (errorMessage) {
    return (
      <DataErrorBanner
        title="キャラクター一覧を読み込めませんでした"
        message={errorMessage}
      />
    );
  }

  const characterImageMap = buildCharacterImageMap(characters);
  const recentMoveMap = buildMoveMap(recentMoves);

  const cardItems: CharacterSelectCardItem[] = characters.map((character) => {
    const counts = comboCounts[character.id] ?? {
      total: 0,
      classic: 0,
      modern: 0,
    };
    const uniqueSituations = getSituationsForCharacter(character.id).filter(
      (s) => s.characterId === character.id
    );
    const theme = getCharacterTheme(character.slug);
    const imageUrl = characterImageMap[character.id] ?? null;
    const watermarkText = theme.watermark ?? character.nameEn.toUpperCase();

    // 固有状況バッジ＋固有ストックバッジ（重複ラベルはまとめる）
    const traitBadges: string[] = uniqueSituations.map((s) => s.label);
    if (
      character.stockMeta &&
      !traitBadges.includes(character.stockMeta.label)
    ) {
      traitBadges.push(character.stockMeta.label);
    }

    return {
      character,
      counts,
      traitBadges,
      theme,
      imageUrl,
      watermarkText,
    };
  });

  return (
    <>
      <RecentCombosPreview
        combos={recentCombos}
        characters={characters}
        characterImageMap={characterImageMap}
        moveMap={recentMoveMap}
        allSituations={SEED_SITUATIONS}
      />
      <CharacterSelectGridClient items={cardItems} />
    </>
  );
}
