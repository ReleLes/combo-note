import {
  SEED_GAME_VERSIONS,
  SEED_SITUATIONS,
  getAllCharacters,
  getAllCombos,
  getMoveMap,
} from "@/data/seed";
import { MyNoteClient } from "@/components/MyNoteClient";

export default function MyNotePage() {
  const characters = getAllCharacters();
  const allCombos = getAllCombos();
  const moveMap = getMoveMap();

  return (
    <MyNoteClient
      characters={characters}
      allCombos={allCombos}
      moveMap={moveMap}
      allSituations={SEED_SITUATIONS}
      versions={SEED_GAME_VERSIONS}
    />
  );
}
