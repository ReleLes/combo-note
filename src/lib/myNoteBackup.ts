import type { PrivateNote, UserPreferences } from "@/types/combo";

export const MY_NOTE_BACKUP_APP = "combo-note" as const;
export const MY_NOTE_BACKUP_SCHEMA_VERSION = 1 as const;

export type MyNoteImportMode = "merge" | "overwrite";

/** エクスポートされる標準JSONフォーマット */
export interface MyNoteBackupPayload {
  app: typeof MY_NOTE_BACKUP_APP;
  schemaVersion: typeof MY_NOTE_BACKUP_SCHEMA_VERSION;
  exportedAt: string;
  savedCombos: string[];
  privateNotes: PrivateNote[];
}

/** パース・バリデーション済みのインポートデータ（旧形式の後方互換情報を含む） */
export interface ParsedMyNoteBackup {
  app: string;
  schemaVersion: number;
  exportedAt: string | null;
  savedCombos: string[];
  privateNotes: PrivateNote[];
  /** 旧バックアップ形式に含まれる場合の任意設定 */
  preferences?: Partial<UserPreferences>;
  isLegacyFormat: boolean;
}

export type ParseMyNoteBackupResult =
  | { ok: true; data: ParsedMyNoteBackup }
  | { ok: false; error: string };

export interface ApplyMyNoteBackupResult {
  savedCombos: string[];
  privateNotes: PrivateNote[];
  addedSavedCount: number;
  addedNotesCount: number;
  updatedNotesCount: number;
}

function sanitizePrivateNote(item: unknown): PrivateNote | null {
  if (typeof item !== "object" || item === null) return null;
  const n = item as Record<string, unknown>;

  if (
    typeof n.id !== "string" ||
    n.id.trim() === "" ||
    typeof n.characterId !== "string" ||
    n.characterId.trim() === "" ||
    typeof n.situation !== "string" ||
    typeof n.recipeText !== "string" ||
    typeof n.note !== "string" ||
    typeof n.createdAt !== "string" ||
    typeof n.updatedAt !== "string"
  ) {
    return null;
  }

  const sanitized: PrivateNote = {
    id: n.id,
    characterId: n.characterId,
    situation: n.situation,
    recipeText: n.recipeText,
    note: n.note,
    createdAt: n.createdAt,
    updatedAt: n.updatedAt,
  };

  if (n.controlType === "classic" || n.controlType === "modern") {
    sanitized.controlType = n.controlType;
  }

  if (Array.isArray(n.moveIds)) {
    const validIds = n.moveIds.filter(
      (id): id is string => typeof id === "string" && id.trim() !== ""
    );
    if (validIds.length > 0) {
      sanitized.moveIds = validIds;
    }
  }

  return sanitized;
}

function sanitizeSavedCombos(raw: unknown): string[] {
  if (!Array.isArray(raw)) return [];
  return Array.from(
    new Set(
      raw.filter(
        (id): id is string => typeof id === "string" && id.trim() !== ""
      )
    )
  );
}

/** エクスポート用のJSONオブジェクトを構築 */
export function buildMyNoteBackupPayload(
  savedCombos: string[],
  privateNotes: PrivateNote[],
  now: Date = new Date()
): MyNoteBackupPayload {
  const validNotes = privateNotes
    .map((item) => sanitizePrivateNote(item))
    .filter((item): item is PrivateNote => item !== null);

  return {
    app: MY_NOTE_BACKUP_APP,
    schemaVersion: MY_NOTE_BACKUP_SCHEMA_VERSION,
    exportedAt: now.toISOString(),
    savedCombos: sanitizeSavedCombos(savedCombos),
    privateNotes: validNotes,
  };
}

/** ローカル日付ベースのファイル名を生成（例: combonote-backup-20261122.json） */
export function formatBackupFilename(date: Date = new Date()): string {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const d = String(date.getDate()).padStart(2, "0");
  return `combonote-backup-${y}${m}${d}.json`;
}

/** バックアップJSONファイルをブラウザからダウンロード */
export function downloadMyNoteBackup(
  savedCombos: string[],
  privateNotes: PrivateNote[]
): { filename: string; payload: MyNoteBackupPayload } {
  const now = new Date();
  const payload = buildMyNoteBackupPayload(savedCombos, privateNotes, now);
  const filename = formatBackupFilename(now);

  const blob = new Blob([JSON.stringify(payload, null, 2)], {
    type: "application/json;charset=utf-8",
  });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = filename;
  document.body.appendChild(anchor);
  anchor.click();
  document.body.removeChild(anchor);
  window.setTimeout(() => URL.revokeObjectURL(url), 1000);

  return { filename, payload };
}

/** JSON文字列をパース・検証（現行形式および旧version:1形式の両方に対応） */
export function parseAndValidateMyNoteBackup(
  rawText: string
): ParseMyNoteBackupResult {
  let parsed: unknown;
  try {
    parsed = JSON.parse(rawText);
  } catch {
    return {
      ok: false,
      error:
        "JSONファイルの形式が正しくありません。コンボノートのバックアップJSONを選択してください。",
    };
  }

  if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
    return {
      ok: false,
      error: "バックアップデータの構造が不正です。",
    };
  }

  const data = parsed as Record<string, unknown>;

  // app識別子の検証（指定がある場合は combo-note のみ許可）
  if (data.app !== undefined && data.app !== MY_NOTE_BACKUP_APP) {
    return {
      ok: false,
      error: "コンボノート以外のバックアップファイルです。",
    };
  }

  const isStandardFormat = data.app === MY_NOTE_BACKUP_APP;
  const isLegacyFormat = !isStandardFormat && data.version === 1;

  if (isStandardFormat) {
    if (data.schemaVersion !== MY_NOTE_BACKUP_SCHEMA_VERSION) {
      return {
        ok: false,
        error: `未対応のバックアップバージョン（schemaVersion: ${String(
          data.schemaVersion
        )}）です。`,
      };
    }
  } else if (!isLegacyFormat) {
    return {
      ok: false,
      error:
        "コンボノートのバックアップファイルとして認識できませんでした。",
    };
  }

  const hasSavedArray = Array.isArray(data.savedCombos);
  const hasNotesArray = Array.isArray(data.privateNotes);

  if (isStandardFormat && (!hasSavedArray || !hasNotesArray)) {
    return {
      ok: false,
      error:
        "バックアップファイルに savedCombos または privateNotes の配列が含まれていません。",
    };
  }

  if (!hasSavedArray && !hasNotesArray) {
    return {
      ok: false,
      error: "取り込み可能なマイノートデータが含まれていませんでした。",
    };
  }

  const savedCombos = sanitizeSavedCombos(data.savedCombos);
  const rawNotes = Array.isArray(data.privateNotes) ? data.privateNotes : [];
  const privateNotes = rawNotes
    .map((item) => sanitizePrivateNote(item))
    .filter((item): item is PrivateNote => item !== null);

  let preferences: Partial<UserPreferences> | undefined;
  if (typeof data.preferences === "object" && data.preferences !== null) {
    const pref = data.preferences as Record<string, unknown>;
    const extracted: Partial<UserPreferences> = {};
    if (pref.controlType === "classic" || pref.controlType === "modern") {
      extracted.controlType = pref.controlType;
    }
    if (
      pref.notationMode === "numpad" ||
      pref.notationMode === "command" ||
      pref.notationMode === "name"
    ) {
      extracted.notationMode = pref.notationMode;
    }
    if (Object.keys(extracted).length > 0) {
      preferences = extracted;
    }
  }

  return {
    ok: true,
    data: {
      app: MY_NOTE_BACKUP_APP,
      schemaVersion: MY_NOTE_BACKUP_SCHEMA_VERSION,
      exportedAt: typeof data.exportedAt === "string" ? data.exportedAt : null,
      savedCombos,
      privateNotes,
      preferences,
      isLegacyFormat,
    },
  };
}

function sortNotesByUpdatedAtDesc(notes: PrivateNote[]): PrivateNote[] {
  return [...notes].sort((a, b) => {
    const timeA = new Date(a.updatedAt).getTime();
    const timeB = new Date(b.updatedAt).getTime();
    return (Number.isNaN(timeB) ? 0 : timeB) - (Number.isNaN(timeA) ? 0 : timeA);
  });
}

/** マージまたは上書きモードでインポート結果を計算 */
export function applyMyNoteBackup(
  mode: MyNoteImportMode,
  current: { savedCombos: string[]; privateNotes: PrivateNote[] },
  incoming: { savedCombos: string[]; privateNotes: PrivateNote[] }
): ApplyMyNoteBackupResult {
  if (mode === "overwrite") {
    const nextSaved = sanitizeSavedCombos(incoming.savedCombos);
    const nextNotes = sortNotesByUpdatedAtDesc(incoming.privateNotes);
    return {
      savedCombos: nextSaved,
      privateNotes: nextNotes,
      addedSavedCount: nextSaved.length,
      addedNotesCount: nextNotes.length,
      updatedNotesCount: 0,
    };
  }

  // merge: 既存データを保持したまま重複排除・ID単位で最新を取り込み
  const existingSavedSet = new Set(current.savedCombos);
  let addedSavedCount = 0;
  for (const id of incoming.savedCombos) {
    if (!existingSavedSet.has(id)) {
      addedSavedCount += 1;
    }
  }
  const mergedSaved = Array.from(
    new Set([...current.savedCombos, ...incoming.savedCombos])
  );

  const noteMap = new Map<string, PrivateNote>();
  for (const note of current.privateNotes) {
    noteMap.set(note.id, note);
  }

  let addedNotesCount = 0;
  let updatedNotesCount = 0;
  for (const incomingNote of incoming.privateNotes) {
    const existing = noteMap.get(incomingNote.id);
    if (!existing) {
      noteMap.set(incomingNote.id, incomingNote);
      addedNotesCount += 1;
    } else {
      const existingTime = new Date(existing.updatedAt).getTime();
      const incomingTime = new Date(incomingNote.updatedAt).getTime();
      if (
        Number.isNaN(existingTime) ||
        Number.isNaN(incomingTime) ||
        incomingTime >= existingTime
      ) {
        noteMap.set(incomingNote.id, incomingNote);
        updatedNotesCount += 1;
      }
    }
  }

  return {
    savedCombos: mergedSaved,
    privateNotes: sortNotesByUpdatedAtDesc(Array.from(noteMap.values())),
    addedSavedCount,
    addedNotesCount,
    updatedNotesCount,
  };
}
