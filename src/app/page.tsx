import { getSituationsForCharacter } from "@/data/seed";
import { SEED_SITUATIONS } from "@/data/seed/common";
import { buildCharacterImageMap } from "@/lib/characterImages";
import { getCharacterTheme } from "@/lib/characterThemes";
import { getAutoManagedCharacterSituations } from "@/lib/stockCalculator";
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

    // キャラカードの固有特徴バッジ（スマホ2列でも崩れないよう最大2個に集約）
    // ストックを持つキャラは stockMeta.label を代表バッジとし、ストック連動の個別タグは省略する
    const traitBadges: string[] = [];
    if (character.stockMeta) {
      traitBadges.push(character.stockMeta.label);
      const stockManagedKeys = new Set<string>(
        getAutoManagedCharacterSituations(character.id)
      );
      for (const sit of uniqueSituations) {
        if (traitBadges.length >= 2) break;
        if (stockManagedKeys.has(sit.key)) continue;
        if (!traitBadges.includes(sit.label)) {
          traitBadges.push(sit.label);
        }
      }
    } else {
      for (const sit of uniqueSituations) {
        if (traitBadges.length >= 2) break;
        if (!traitBadges.includes(sit.label)) {
          traitBadges.push(sit.label);
        }
      }
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
