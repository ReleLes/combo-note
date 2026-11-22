import type {
  Character,
  Combo,
  ComboCategory,
  ControlType,
  GameVersion,
  Move,
  MoveCategory,
  MoveControlType,
} from "@/types/combo";
import { SEED_CHARACTERS } from "@/data/seed/common";
import { createClient } from "./server";

interface CharacterRow {
  id: string;
  slug: string;
  name_ja: string;
  name_en: string;
  sort_order: number | null;
  is_active: boolean | null;
  stock_label: string | null;
  stock_short_label: string | null;
  stock_max_count: number | null;
}

interface MoveRow {
  id: string;
  character_id: string | null;
  control_type: MoveControlType;
  category: MoveCategory;
  notation_numpad: string;
  notation_command: string;
  notation_name: string;
  sort_order: number | null;
  startup_frames: number | null;
  hit_advantage: number | null;
  cancel_types: string[] | null;
}

interface GameVersionRow {
  id: string;
  label: string;
  released_at: string;
}

interface ComboRow {
  id: string;
  author_id: string | null;
  author_name: string | null;
  character_id: string;
  control_type: ControlType;
  title?: string | null;
  move_ids: unknown;
  recipe_signature: string;
  situations: string[] | null;
  category: ComboCategory;
  damage: number | null;
  drive_cost: number | string | null;
  sa_cost: number | null;
  stock_cost: number | null;
  stock_gain: number | null;
  has_oki: boolean | null;
  note: string;
  version_id: string;
  likes_count: number | null;
  created_at: string;
  updated_at: string;
}

function mapCharacter(row: CharacterRow): Character {
  const seedStockMeta = SEED_CHARACTERS.find((c) => c.id === row.id)?.stockMeta;
  const stockMeta =
    row.stock_label && row.stock_short_label && row.stock_max_count
      ? {
          label: row.stock_label,
          shortLabel: row.stock_short_label,
          maxCount: row.stock_max_count,
          gainOptions: seedStockMeta?.gainOptions,
          gainHint: seedStockMeta?.gainHint,
        }
      : undefined;

  return {
    id: row.id,
    slug: row.slug,
    nameJa: row.name_ja,
    nameEn: row.name_en,
    sortOrder: row.sort_order ?? 0,
    isActive: row.is_active ?? true,
    stockMeta,
  };
}

function mapMove(row: MoveRow): Move {
  return {
    id: row.id,
    characterId: row.character_id,
    controlType: row.control_type,
    category: row.category,
    notationNumpad: row.notation_numpad,
    notationCommand: row.notation_command,
    notationName: row.notation_name,
    sortOrder: row.sort_order ?? 0,
    startupFrames: row.startup_frames,
    hitAdvantage: row.hit_advantage,
    cancelTypes: row.cancel_types,
  };
}

function mapGameVersion(row: GameVersionRow): GameVersion {
  return {
    id: row.id,
    label: row.label,
    releasedAt: row.released_at,
  };
}

function mapCombo(row: ComboRow): Combo {
  const moveIds = Array.isArray(row.move_ids)
    ? row.move_ids.filter((id): id is string => typeof id === "string")
    : [];

  const saRaw = row.sa_cost ?? 0;
  const saCost: 0 | 1 | 2 | 3 =
    saRaw === 1 || saRaw === 2 || saRaw === 3 ? saRaw : 0;

  return {
    id: row.id,
    authorId: row.author_id ?? "seed",
    authorName: row.author_name ?? undefined,
    characterId: row.character_id,
    controlType: row.control_type,
    title: row.title ?? null,
    moveIds,
    recipeSignature: row.recipe_signature,
    situations: row.situations ?? [],
    category: row.category,
    damage: row.damage,
    driveCost: Number(row.drive_cost ?? 0),
    saCost,
    stockCost: row.stock_cost ?? 0,
    stockGain: row.stock_gain ?? 0,
    hasOki: row.has_oki ?? false,
    note: row.note,
    versionId: row.version_id,
    likesCount: row.likes_count ?? 0,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export async function fetchActiveCharacters(): Promise<Character[]> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("characters")
    .select("*")
    .eq("is_active", true)
    .order("sort_order", { ascending: true });

  if (error) {
    throw new Error(`キャラクター一覧の取得に失敗しました: ${error.message}`);
  }

  return ((data ?? []) as CharacterRow[]).map(mapCharacter);
}

export async function fetchCharacterBySlug(
  slug: string
): Promise<Character | null> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("characters")
    .select("*")
    .eq("slug", slug)
    .eq("is_active", true)
    .maybeSingle();

  if (error) {
    throw new Error(`キャラクター情報の取得に失敗しました: ${error.message}`);
  }

  return data ? mapCharacter(data as CharacterRow) : null;
}

export async function fetchGameVersions(): Promise<GameVersion[]> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("game_versions")
    .select("*")
    .order("released_at", { ascending: false });

  if (error) {
    throw new Error(`バージョン情報の取得に失敗しました: ${error.message}`);
  }

  return ((data ?? []) as GameVersionRow[]).map(mapGameVersion);
}

export async function fetchMovesForCharacter(
  characterId: string
): Promise<Move[]> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("moves")
    .select("*")
    .or(`character_id.eq.${characterId},character_id.is.null`)
    .order("sort_order", { ascending: true });

  if (error) {
    throw new Error(`技マスタの取得に失敗しました: ${error.message}`);
  }

  return ((data ?? []) as MoveRow[]).map(mapMove);
}

export async function fetchAllMoves(): Promise<Move[]> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("moves")
    .select("*")
    .order("sort_order", { ascending: true });

  if (error) {
    throw new Error(`技マスタの取得に失敗しました: ${error.message}`);
  }

  return ((data ?? []) as MoveRow[]).map(mapMove);
}

export async function fetchCombosByCharacter(
  characterId: string
): Promise<Combo[]> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("combos")
    .select("*")
    .eq("character_id", characterId)
    .order("likes_count", { ascending: false })
    .order("created_at", { ascending: false });

  if (error) {
    throw new Error(`コンボ一覧の取得に失敗しました: ${error.message}`);
  }

  return ((data ?? []) as ComboRow[]).map(mapCombo);
}

export async function fetchAllCombos(): Promise<Combo[]> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("combos")
    .select("*")
    .order("likes_count", { ascending: false })
    .order("created_at", { ascending: false });

  if (error) {
    throw new Error(`コンボ一覧の取得に失敗しました: ${error.message}`);
  }

  return ((data ?? []) as ComboRow[]).map(mapCombo);
}

const UUID_REGEX =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export async function fetchComboById(id: string): Promise<Combo | null> {
  if (!UUID_REGEX.test(id)) {
    return null;
  }

  const supabase = await createClient();
  const { data, error } = await supabase
    .from("combos")
    .select("*")
    .eq("id", id)
    .maybeSingle();

  if (error) {
    throw new Error(`コンボ情報の取得に失敗しました: ${error.message}`);
  }

  return data ? mapCombo(data as ComboRow) : null;
}

export interface CharacterComboCounts {
  total: number;
  classic: number;
  modern: number;
}

export async function fetchComboCountsByCharacter(): Promise<
  Record<string, CharacterComboCounts>
> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("combos")
    .select("character_id, control_type");

  if (error) {
    throw new Error(`コンボ件数の取得に失敗しました: ${error.message}`);
  }

  const counts: Record<string, CharacterComboCounts> = {};
  for (const row of (data ?? []) as {
    character_id: string;
    control_type: ControlType;
  }[]) {
    if (!counts[row.character_id]) {
      counts[row.character_id] = { total: 0, classic: 0, modern: 0 };
    }
    counts[row.character_id].total += 1;
    if (row.control_type === "classic") {
      counts[row.character_id].classic += 1;
    } else if (row.control_type === "modern") {
      counts[row.character_id].modern += 1;
    }
  }

  return counts;
}

export function buildMoveMap(moves: Move[]): Record<string, Move> {
  const map: Record<string, Move> = {};
  for (const move of moves) {
    map[move.id] = move;
  }
  return map;
}
