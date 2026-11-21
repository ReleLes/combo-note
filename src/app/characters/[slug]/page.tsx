import { notFound } from "next/navigation";
import {
  SEED_GAME_VERSIONS,
  getAllCharacters,
  getCharacterBySlug,
  getCombosByCharacter,
  getMoveMap,
  getSituationsForCharacter,
} from "@/data/seed";
import { CharacterComboListClient } from "@/components/CharacterComboListClient";

interface CharacterPageProps {
  params: Promise<{ slug: string }>;
}

export function generateStaticParams() {
  return getAllCharacters().map((c) => ({ slug: c.slug }));
}

export default async function CharacterPage({ params }: CharacterPageProps) {
  const { slug } = await params;
  const character = getCharacterBySlug(slug);

  if (!character) {
    notFound();
  }

  const allCharacters = getAllCharacters();
  const combos = getCombosByCharacter(character.id);
  const moveMap = getMoveMap(character.id);
  const situations = getSituationsForCharacter(character.id);

  return (
    <CharacterComboListClient
      character={character}
      allCharacters={allCharacters}
      combos={combos}
      moveMap={moveMap}
      situations={situations}
      versions={SEED_GAME_VERSIONS}
    />
  );
}
