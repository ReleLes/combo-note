/**
 * =============================================================================
 * Supabase サーバー側データ取得クエリ（再発防止・スケーリング規約）
 * =============================================================================
 * 今後の開発者・AIエージェントは以下のルールを必ず遵守すること：
 *
 * 1. 【1,000件上限対策】
 *    Supabase (PostgREST) はデフォルトで 1 リクエスト最大 1,000 件しか返さない。
 *    1,000 件を超え得るテーブル（moves, combos 等）を取得するクエリは、必ず
 *    `fetchAllPages()` を経由し、ページ境界での重複・欠落を防ぐため一意な列
 *    （`id` 等）を最終ソートキーに含めること。
 *
 * 2. 【全件取得の回避・キャラ単位絞り込み＆RPC優先】
 *    30キャラ規模（技マスタ数千件・コンボ数千件）への拡張および Next.js の
 *    データ転送量・2MB キャッシュ上限対策として、原則として全件取得
 *    （`fetchAllMoves()`・`fetchAllCombos()` 等）は新規利用を避け、
 *    `fetchMovesForCharacter()` / `fetchMovesForCharacters()` のように
 *    `character_id` で絞り込んだ関数や、集計 RPC
 *    （`get_combo_counts_by_character` 等）を優先すること。
 * =============================================================================
 */

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
  source_url?: string | null;
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
      : seedStockMeta
        ? { ...seedStockMeta }
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
    sourceUrl: row.source_url ?? null,
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

/**
 * Supabase (PostgREST) のデフォルト取得上限（1回あたり最大1,000件）を超えても
 * 全件を漏れなく取得するためのページネーションヘルパー。
 * ページ境界での重複・欠落を防ぐため、呼び出し元のクエリでは必ず一意な列（id 等）を
 * 最終ソートキーに含めること。
 */
const SUPABASE_PAGE_SIZE = 1000;

async function fetchAllPages<T>(
  fetchPage: (
    from: number,
    to: number
  ) => PromiseLike<{ data: unknown[] | null; error: { message: string } | null }>,
  errorPrefix: string
): Promise<T[]> {
  const allRows: T[] = [];
  let from = 0;

  while (true) {
    const to = from + SUPABASE_PAGE_SIZE - 1;
    const { data, error } = await fetchPage(from, to);

    if (error) {
      throw new Error(`${errorPrefix}: ${error.message}`);
    }

    const batch = (data ?? []) as T[];
    allRows.push(...batch);

    if (batch.length < SUPABASE_PAGE_SIZE) {
      break;
    }
    from += SUPABASE_PAGE_SIZE;
  }

  return allRows;
}

export async function fetchMovesForCharacter(
  characterId: string
): Promise<Move[]> {
  const supabase = await createClient();
  const rows = await fetchAllPages<MoveRow>(
    (from, to) =>
      supabase
        .from("moves")
        .select("*")
        .or(`character_id.eq.${characterId},character_id.is.null`)
        .order("sort_order", { ascending: true })
        .order("id", { ascending: true })
        .range(from, to),
    "技マスタの取得に失敗しました"
  );

  return rows.map(mapMove);
}

/**
 * 複数キャラクター分の技マスタ＋システム共通パーツ（character_id IS NULL）のみを
 * ページネーション付きで取得する。characterIds が空の場合はクエリ自体をスキップする。
 */
export async function fetchMovesForCharacters(
  characterIds: string[]
): Promise<Move[]> {
  const uniqueIds = Array.from(
    new Set(characterIds.filter((id) => typeof id === "string" && id.length > 0))
  );
  if (uniqueIds.length === 0) {
    return [];
  }

  const supabase = await createClient();
  const inList = uniqueIds.join(",");
  const rows = await fetchAllPages<MoveRow>(
    (from, to) =>
      supabase
        .from("moves")
        .select("*")
        .or(`character_id.in.(${inList}),character_id.is.null`)
        .order("sort_order", { ascending: true })
        .order("id", { ascending: true })
        .range(from, to),
    "技マスタの取得に失敗しました"
  );

  return rows.map(mapMove);
}

/**
 * @deprecated 全キャラ分の技を一括取得するため、原則として `fetchMovesForCharacter()` または
 * `fetchMovesForCharacters()` を使用すること。
 */
export async function fetchAllMoves(): Promise<Move[]> {
  const supabase = await createClient();
  const rows = await fetchAllPages<MoveRow>(
    (from, to) =>
      supabase
        .from("moves")
        .select("*")
        .order("sort_order", { ascending: true })
        .order("id", { ascending: true })
        .range(from, to),
    "技マスタの取得に失敗しました"
  );

  return rows.map(mapMove);
}

export async function fetchCombosByCharacter(
  characterId: string
): Promise<Combo[]> {
  const supabase = await createClient();
  const rows = await fetchAllPages<ComboRow>(
    (from, to) =>
      supabase
        .from("combos")
        .select("*")
        .eq("character_id", characterId)
        .order("likes_count", { ascending: false })
        .order("created_at", { ascending: false })
        .order("id", { ascending: true })
        .range(from, to),
    "コンボ一覧の取得に失敗しました"
  );

  return rows.map(mapCombo);
}

export async function fetchAllCombos(): Promise<Combo[]> {
  const supabase = await createClient();
  const rows = await fetchAllPages<ComboRow>(
    (from, to) =>
      supabase
        .from("combos")
        .select("*")
        .order("likes_count", { ascending: false })
        .order("created_at", { ascending: false })
        .order("id", { ascending: true })
        .range(from, to),
    "コンボ一覧の取得に失敗しました"
  );

  return rows.map(mapCombo);
}

export interface RecentCombosQueryOptions {
  /** 1ページあたりの取得件数（デフォルト: 20） */
  limit?: number;
  /** オフセット開始位置（デフォルト: 0） */
  offset?: number;
  /** 特定キャラクターで絞り込む場合の character_id */
  characterId?: string | null;
  /** 操作タイプ絞り込み（"all" または未指定で両方取得） */
  controlType?: ControlType | "all";
  /** 単一の共通状況タグキー（後方互換用） */
  situation?: string | null;
  /** 複数の共通状況タグキー（AND条件で絞り込み） */
  situations?: string[] | null;
}

export interface RecentCombosPageResult {
  combos: Combo[];
  hasMore: boolean;
}

/**
 * 全キャラクターの公開コンボを新着順（created_at DESC, id DESC）で
 * ページネーション取得する（1ページあたりデフォルト20件）。
 * limit + 1 件取得することで COUNT クエリ無しで次ページの有無を判定する。
 */
export async function fetchRecentCombosPage(
  options: RecentCombosQueryOptions = {}
): Promise<RecentCombosPageResult> {
  const limit = Math.max(1, Math.min(100, options.limit ?? 20));
  const offset = Math.max(0, options.offset ?? 0);

  const supabase = await createClient();
  let query = supabase
    .from("combos")
    .select("*")
    .order("created_at", { ascending: false })
    .order("id", { ascending: false });

  if (options.characterId && options.characterId !== "all") {
    query = query.eq("character_id", options.characterId);
  }
  if (options.controlType && options.controlType !== "all") {
    query = query.eq("control_type", options.controlType);
  }

  const activeSituations = Array.from(
    new Set([
      ...(options.situations ?? []).filter(
        (s): s is string => typeof s === "string" && s.length > 0 && s !== "all"
      ),
      ...(options.situation && options.situation !== "all"
        ? [options.situation]
        : []),
    ])
  );
  if (activeSituations.length > 0) {
    // PostgreSQL text[] の contains (@>) により、指定した全状況タグを含むコンボのみ抽出（AND条件）
    query = query.contains("situations", activeSituations);
  }

  const { data, error } = await query.range(offset, offset + limit);

  if (error) {
    throw new Error(`新着コンボ一覧の取得に失敗しました: ${error.message}`);
  }

  const rows = (data ?? []) as ComboRow[];
  const hasMore = rows.length > limit;
  const pageRows = hasMore ? rows.slice(0, limit) : rows;

  return {
    combos: pageRows.map(mapCombo),
    hasMore,
  };
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

interface ComboCountRpcRow {
  character_id: string;
  total_count: number | string | null;
  classic_count: number | string | null;
  modern_count: number | string | null;
}

export async function fetchComboCountsByCharacter(): Promise<
  Record<string, CharacterComboCounts>
> {
  const supabase = await createClient();

  // 優先: Supabase RPC (get_combo_counts_by_character) で DB 側 GROUP BY 集計
  const { data: rpcData, error: rpcError } = await supabase.rpc(
    "get_combo_counts_by_character"
  );

  if (!rpcError && Array.isArray(rpcData)) {
    const counts: Record<string, CharacterComboCounts> = {};
    for (const row of rpcData as ComboCountRpcRow[]) {
      if (!row.character_id) continue;
      counts[row.character_id] = {
        total: Number(row.total_count ?? 0),
        classic: Number(row.classic_count ?? 0),
        modern: Number(row.modern_count ?? 0),
      };
    }
    return counts;
  }

  // RPC 未適用環境向けフォールバック（クラッシュを防ぎつつ警告を出力）
  if (rpcError) {
    console.warn(
      `[fetchComboCountsByCharacter] RPC呼び出しに失敗したためフォールバック集計を実行します（013_combo_counts_rpc.sql 適用済みか確認してください）: ${rpcError.message}`
    );
  }

  const rows = await fetchAllPages<{
    character_id: string;
    control_type: ControlType;
  }>(
    (from, to) =>
      supabase
        .from("combos")
        .select("character_id, control_type")
        .order("id", { ascending: true })
        .range(from, to),
    "コンボ件数の取得に失敗しました"
  );

  const counts: Record<string, CharacterComboCounts> = {};
  for (const row of rows) {
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
