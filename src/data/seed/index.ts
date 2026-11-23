import type {
  Character,
  CharacterSeedData,
  Combo,
  ControlType,
  GameVersion,
  Move,
  NotationMode,
  SituationDefinition,
} from "@/types/combo";
import {
  COMBO_CATEGORIES,
  SEED_CHARACTERS,
  SEED_GAME_VERSIONS,
  SEED_SITUATIONS,
  SYSTEM_MOVES,
  buildRecipeSignature,
} from "./common";
import { akumaSeedData } from "./characters/akuma";
import { juriSeedData } from "./characters/juri";
import { ingridSeedData } from "./characters/ingrid";
import { cViperSeedData } from "./characters/c-viper";
import { maiSeedData } from "./characters/mai";
import { ryuSeedData } from "./characters/ryu";
import { kenSeedData } from "./characters/ken";
import { lukeSeedData } from "./characters/luke";
import { cammySeedData } from "./characters/cammy";
import { chunLiSeedData } from "./characters/chun-li";
import { guileSeedData } from "./characters/guile";
import { zangiefSeedData } from "./characters/zangief";
import { vegaSeedData } from "./characters/vega";
import { jpSeedData } from "./characters/jp";
import { edSeedData } from "./characters/ed";
import { terrySeedData } from "./characters/terry";
import { sagatSeedData } from "./characters/sagat";
import { deejaySeedData } from "./characters/deejay";
import { rashidSeedData } from "./characters/rashid";
import { akiSeedData } from "./characters/aki";
import { elenaSeedData } from "./characters/elena";
import { alexSeedData } from "./characters/alex";
import { yasmineSeedData } from "./characters/yasmine";
import { arjunSeedData } from "./characters/arjun";
import { jamieSeedData } from "./characters/jamie";
import { kimberlySeedData } from "./characters/kimberly";
import { marisaSeedData } from "./characters/marisa";
import { manonSeedData } from "./characters/manon";
import { blankaSeedData } from "./characters/blanka";
import { ehondaSeedData } from "./characters/ehonda";
import { dhalsimSeedData } from "./characters/dhalsim";
import { lilySeedData } from "./characters/lily";

const CHARACTER_SEED_MAP: Record<string, CharacterSeedData> = {
  akuma: akumaSeedData,
  juri: juriSeedData,
  ingrid: ingridSeedData,
  "c-viper": cViperSeedData,
  mai: maiSeedData,
  ryu: ryuSeedData,
  ken: kenSeedData,
  luke: lukeSeedData,
  cammy: cammySeedData,
  "chun-li": chunLiSeedData,
  guile: guileSeedData,
  zangief: zangiefSeedData,
  vega: vegaSeedData,
  jp: jpSeedData,
  ed: edSeedData,
  terry: terrySeedData,
  sagat: sagatSeedData,
  deejay: deejaySeedData,
  rashid: rashidSeedData,
  aki: akiSeedData,
  elena: elenaSeedData,
  alex: alexSeedData,
  yasmine: yasmineSeedData,
  arjun: arjunSeedData,
  jamie: jamieSeedData,
  kimberly: kimberlySeedData,
  marisa: marisaSeedData,
  manon: manonSeedData,
  blanka: blankaSeedData,
  ehonda: ehondaSeedData,
  dhalsim: dhalsimSeedData,
  lily: lilySeedData,
};

export {
  COMBO_CATEGORIES,
  SEED_CHARACTERS,
  SEED_GAME_VERSIONS,
  SEED_SITUATIONS,
  SYSTEM_MOVES,
  buildRecipeSignature,
};

export function getAllCharacters(): Character[] {
  return [...SEED_CHARACTERS]
    .filter((c) => c.isActive)
    .sort((a, b) => a.sortOrder - b.sortOrder);
}

export function getCharacterBySlug(slug: string): Character | undefined {
  return SEED_CHARACTERS.find((c) => c.slug === slug && c.isActive);
}

export function getCharacterById(id: string): Character | undefined {
  return SEED_CHARACTERS.find((c) => c.id === id);
}

export function getAllMoves(): Move[] {
  const characterMoves = Object.values(CHARACTER_SEED_MAP).flatMap(
    (seed) => seed.moves
  );
  return [...SYSTEM_MOVES, ...characterMoves];
}

export function getMovesForCharacter(
  characterId: string,
  controlType?: ControlType
): Move[] {
  const charSeed = CHARACTER_SEED_MAP[characterId];
  const combined = [...SYSTEM_MOVES, ...(charSeed?.moves ?? [])];

  return combined
    .filter((move) => {
      if (!controlType) return true;
      return move.controlType === "both" || move.controlType === controlType;
    })
    .sort((a, b) => a.sortOrder - b.sortOrder);
}

export function getMoveMap(characterId?: string): Record<string, Move> {
  const moves = characterId ? getMovesForCharacter(characterId) : getAllMoves();
  const map: Record<string, Move> = {};
  for (const move of moves) {
    map[move.id] = move;
  }
  return map;
}

export function getAllCombos(): Combo[] {
  return Object.values(CHARACTER_SEED_MAP).flatMap((seed) => seed.combos);
}

export function getCombosByCharacter(
  characterId: string,
  controlType?: ControlType
): Combo[] {
  const combos = CHARACTER_SEED_MAP[characterId]?.combos ?? [];
  if (!controlType) return [...combos];
  return combos.filter((combo) => combo.controlType === controlType);
}

export function getComboById(comboId: string): Combo | undefined {
  return getAllCombos().find((combo) => combo.id === comboId);
}

export function resolveComboMoves(combo: Combo): Move[] {
  const moveMap = getMoveMap(combo.characterId);
  return combo.moveIds
    .map((moveId) => moveMap[moveId])
    .filter((move): move is Move => Boolean(move));
}

export function getMoveNotation(move: Move, notationMode: NotationMode): string {
  switch (notationMode) {
    case "numpad":
      return move.notationNumpad;
    case "command":
      return move.notationCommand;
    case "name":
      return move.notationName;
  }
}

export function formatComboRecipeParts(
  combo: Combo,
  notationMode: NotationMode
): string[] {
  return resolveComboMoves(combo).map((move) =>
    getMoveNotation(move, notationMode)
  );
}

export function getSituationsForCharacter(
  characterId: string
): SituationDefinition[] {
  return SEED_SITUATIONS.filter(
    (s) => s.characterId === null || s.characterId === characterId
  ).sort((a, b) => a.sortOrder - b.sortOrder);
}

export function getSituationByKey(
  key: string
): SituationDefinition | undefined {
  return SEED_SITUATIONS.find((s) => s.key === key);
}

export function getVersionById(versionId: string): GameVersion | undefined {
  return SEED_GAME_VERSIONS.find((v) => v.id === versionId);
}
