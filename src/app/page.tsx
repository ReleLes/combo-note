import fs from "node:fs";
import path from "node:path";
import { getSituationsForCharacter } from "@/data/seed";
import { getCharacterTheme } from "@/lib/characterThemes";
import {
  type CharacterComboCounts,
  fetchActiveCharacters,
  fetchComboCountsByCharacter,
} from "@/lib/supabase/queries";
import type { Character } from "@/types/combo";
import { DataErrorBanner } from "@/components/DataErrorBanner";
import {
  CharacterSelectGridClient,
  type CharacterSelectCardItem,
} from "@/components/CharacterSelectGridClient";

export const dynamic = "force-dynamic";

const CHARACTER_IMAGE_EXTENSIONS = [".webp", ".png", ".jpg", ".jpeg"] as const;
const CHARACTER_IMAGE_DIR = path.join(
  process.cwd(),
  "public",
  "images",
  "characters"
);

function resolveCharacterImageUrl(slug: string): string | null {
  if (!/^[a-z0-9-]+$/i.test(slug)) return null;

  for (const ext of CHARACTER_IMAGE_EXTENSIONS) {
    const filePath = path.join(CHARACTER_IMAGE_DIR, `${slug}${ext}`);
    if (fs.existsSync(filePath)) {
      return `/images/characters/${slug}${ext}`;
    }
  }
  return null;
}

export default async function HomePage() {
  let characters: Character[] = [];
  let comboCounts: Record<string, CharacterComboCounts> = {};
  let errorMessage: string | null = null;

  try {
    [characters, comboCounts] = await Promise.all([
      fetchActiveCharacters(),
      fetchComboCountsByCharacter(),
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
        title="キャラクター一覧を読み込めませんでした"
        message={errorMessage}
      />
    );
  }

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
    const imageUrl = resolveCharacterImageUrl(character.slug);
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

  return <CharacterSelectGridClient items={cardItems} />;
}
