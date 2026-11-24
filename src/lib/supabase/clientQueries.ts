import type {
  Combo,
  ComboCategory,
  ControlType,
  Move,
  MoveCategory,
  MoveControlType,
} from "@/types/combo";
import { createClient } from "./client";

const SUPABASE_PAGE_SIZE = 1000;
const COMBO_ID_CHUNK_SIZE = 100;

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

async function fetchAllClientPages<T>(
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

/**
 * クライアント側から指定キャラクター1体分の技＋システム共通パーツを取得する。
 */
export async function fetchClientMovesForCharacter(
  characterId: string
): Promise<Move[]> {
  const supabase = createClient();
  const rows = await fetchAllClientPages<MoveRow>(
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
 * クライアント側から複数キャラクター分の技＋システム共通パーツのみを取得する。
 * characterIds が空の場合はクエリをスキップする。
 */
export async function fetchClientMovesForCharacters(
  characterIds: string[]
): Promise<Move[]> {
  const uniqueIds = Array.from(
    new Set(characterIds.filter((id) => typeof id === "string" && id.length > 0))
  );
  if (uniqueIds.length === 0) {
    return [];
  }

  const supabase = createClient();
  const inList = uniqueIds.join(",");
  const rows = await fetchAllClientPages<MoveRow>(
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

const UUID_REGEX =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * クライアント側から指定ID群の公開コンボのみをチャンク分割で取得する。
 * マイノート画面で全公開コンボを取得せず、保存済みコンボ分だけ取得するために使用。
 */
export async function fetchClientCombosByIds(ids: string[]): Promise<Combo[]> {
  const validIds = Array.from(
    new Set(ids.filter((id) => typeof id === "string" && UUID_REGEX.test(id)))
  );
  if (validIds.length === 0) {
    return [];
  }

  const supabase = createClient();
  const results: Combo[] = [];

  for (let i = 0; i < validIds.length; i += COMBO_ID_CHUNK_SIZE) {
    const chunk = validIds.slice(i, i + COMBO_ID_CHUNK_SIZE);
    const { data, error } = await supabase
      .from("combos")
      .select("*")
      .in("id", chunk)
      .order("likes_count", { ascending: false })
      .order("created_at", { ascending: false })
      .order("id", { ascending: true });

    if (error) {
      throw new Error(`保存済みコンボの取得に失敗しました: ${error.message}`);
    }

    for (const row of (data ?? []) as ComboRow[]) {
      results.push(mapCombo(row));
    }
  }

  return results;
}

export interface ClientRecentCombosQueryOptions {
  /** 1ページあたりの取得件数（デフォルト: 20） */
  limit?: number;
  /** オフセット開始位置（デフォルト: 0） */
  offset?: number;
  /** 特定キャラクターで絞り込む場合の character_id */
  characterId?: string | null;
  /** 操作タイプ絞り込み（"all" または未指定で両方取得） */
  controlType?: ControlType | "all";
  /** 共通状況タグキー（例: "midscreen", "corner"） */
  situation?: string | null;
}

export interface ClientRecentCombosPageResult {
  combos: Combo[];
  hasMore: boolean;
}

/**
 * クライアント側から全キャラ公開コンボを新着順（created_at DESC, id DESC）で
 * ページネーション取得する（1ページあたりデフォルト20件）。
 */
export async function fetchClientRecentCombosPage(
  options: ClientRecentCombosQueryOptions = {}
): Promise<ClientRecentCombosPageResult> {
  const limit = Math.max(1, Math.min(100, options.limit ?? 20));
  const offset = Math.max(0, options.offset ?? 0);

  const supabase = createClient();
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
  if (options.situation && options.situation !== "all") {
    query = query.contains("situations", [options.situation]);
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

/**
 * ログイン中ユーザーが管理者（public.admin_users）かどうかを判定する。
 * 優先して RPC (`public.is_admin`) を呼び出し、未適用環境や一時エラー時は
 * `admin_users` の自ユーザー行参照へフォールバックする。
 */
export async function fetchClientIsAdmin(userId?: string): Promise<boolean> {
  const supabase = createClient();

  const { data: rpcData, error: rpcError } = await supabase.rpc("is_admin");
  if (!rpcError && typeof rpcData === "boolean") {
    return rpcData;
  }

  let targetUserId = userId;
  if (!targetUserId) {
    const { data: userData } = await supabase.auth.getUser();
    targetUserId = userData.user?.id;
  }
  if (!targetUserId) {
    return false;
  }

  const { data: row, error: selectError } = await supabase
    .from("admin_users")
    .select("user_id")
    .eq("user_id", targetUserId)
    .maybeSingle();

  if (selectError) {
    return false;
  }

  return Boolean(row);
}

/**
 * 指定IDの公開コンボを削除する。
 * 認可は DB の RLS ポリシー（投稿者本人 OR 管理者）で強制される。
 * 関連する `combo_likes` は FK の ON DELETE CASCADE により自動削除される。
 */
export async function deleteCombo(comboId: string): Promise<void> {
  if (!UUID_REGEX.test(comboId)) {
    throw new Error("不正なコンボIDです。");
  }

  const supabase = createClient();
  const { data, error } = await supabase
    .from("combos")
    .delete()
    .eq("id", comboId)
    .select("id");

  if (error) {
    throw new Error(`コンボの削除に失敗しました: ${error.message}`);
  }

  if (!data || data.length === 0) {
    throw new Error(
      "コンボの削除に失敗しました。削除権限がないか、すでに削除されている可能性があります。"
    );
  }
}
