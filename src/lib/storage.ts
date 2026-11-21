import type {
  ControlType,
  NotationMode,
  PrivateNote,
  UserPreferences,
} from "@/types/combo";

export const STORAGE_KEYS = {
  PREFERENCES: "combonote_v1_preferences",
  SAVED_COMBOS: "combonote_v1_saved_combos",
  PRIVATE_NOTES: "combonote_v1_private_notes",
} as const;

export type StorageKey = (typeof STORAGE_KEYS)[keyof typeof STORAGE_KEYS];

export const STORAGE_SYNC_EVENT = "combonote:storage-sync";

export const DEFAULT_PREFERENCES: UserPreferences = {
  notationMode: "numpad",
  controlType: "classic",
};

function isControlType(value: unknown): value is ControlType {
  return value === "classic" || value === "modern";
}

function isNotationMode(value: unknown): value is NotationMode {
  return value === "numpad" || value === "command" || value === "name";
}

export function isBrowser(): boolean {
  return typeof window !== "undefined" && typeof window.localStorage !== "undefined";
}

export function readRawStorage(key: StorageKey): string | null {
  if (!isBrowser()) return null;
  try {
    return window.localStorage.getItem(key);
  } catch {
    return null;
  }
}

export function writeStorage<T>(key: StorageKey, value: T): boolean {
  if (!isBrowser()) return false;
  try {
    window.localStorage.setItem(key, JSON.stringify(value));
    window.dispatchEvent(
      new CustomEvent(STORAGE_SYNC_EVENT, { detail: { key } })
    );
    return true;
  } catch {
    return false;
  }
}

export function parsePreferences(raw: string | null): UserPreferences {
  if (!raw) return DEFAULT_PREFERENCES;
  try {
    const parsed: unknown = JSON.parse(raw);
    if (typeof parsed !== "object" || parsed === null) {
      return DEFAULT_PREFERENCES;
    }
    const record = parsed as Record<string, unknown>;
    return {
      controlType: isControlType(record.controlType)
        ? record.controlType
        : DEFAULT_PREFERENCES.controlType,
      notationMode: isNotationMode(record.notationMode)
        ? record.notationMode
        : DEFAULT_PREFERENCES.notationMode,
    };
  } catch {
    return DEFAULT_PREFERENCES;
  }
}

export function parseSavedComboIds(raw: string | null): string[] {
  if (!raw) return [];
  try {
    const parsed: unknown = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];
    return Array.from(
      new Set(parsed.filter((item): item is string => typeof item === "string"))
    );
  } catch {
    return [];
  }
}

export function parsePrivateNotes(raw: string | null): PrivateNote[] {
  if (!raw) return [];
  try {
    const parsed: unknown = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];
    return parsed.filter((item): item is PrivateNote => {
      if (typeof item !== "object" || item === null) return false;
      const n = item as Record<string, unknown>;
      return (
        typeof n.id === "string" &&
        typeof n.characterId === "string" &&
        typeof n.situation === "string" &&
        typeof n.recipeText === "string" &&
        typeof n.note === "string" &&
        typeof n.createdAt === "string" &&
        typeof n.updatedAt === "string"
      );
    });
  } catch {
    return [];
  }
}
