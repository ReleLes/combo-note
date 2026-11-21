"use client";

import { useCallback, useSyncExternalStore } from "react";
import type {
  ControlType,
  NotationMode,
  PrivateNote,
  UserPreferences,
} from "@/types/combo";
import {
  DEFAULT_PREFERENCES,
  STORAGE_KEYS,
  STORAGE_SYNC_EVENT,
  type StorageKey,
  parsePreferences,
  parsePrivateNotes,
  parseSavedComboIds,
  readRawStorage,
  writeStorage,
} from "@/lib/storage";

const EMPTY_SAVED_COMBOS: string[] = [];
const EMPTY_PRIVATE_NOTES: PrivateNote[] = [];

// useSyncExternalStore 用のスナップショット参照キャッシュ（同一文字列なら同一参照を返す）
let cachedPrefRaw: string | null | undefined = undefined;
let cachedPrefValue: UserPreferences = DEFAULT_PREFERENCES;

let cachedSavedRaw: string | null | undefined = undefined;
let cachedSavedValue: string[] = EMPTY_SAVED_COMBOS;

let cachedNotesRaw: string | null | undefined = undefined;
let cachedNotesValue: PrivateNote[] = EMPTY_PRIVATE_NOTES;

function subscribeToKey(key: StorageKey, callback: () => void): () => void {
  if (typeof window === "undefined") {
    return () => {};
  }

  const handleStorage = (e: StorageEvent) => {
    if (e.key === null || e.key === key) {
      callback();
    }
  };

  const handleCustomSync = (e: Event) => {
    const customEvent = e as CustomEvent<{ key?: StorageKey }>;
    if (!customEvent.detail?.key || customEvent.detail.key === key) {
      callback();
    }
  };

  window.addEventListener("storage", handleStorage);
  window.addEventListener(STORAGE_SYNC_EVENT, handleCustomSync);

  return () => {
    window.removeEventListener("storage", handleStorage);
    window.removeEventListener(STORAGE_SYNC_EVENT, handleCustomSync);
  };
}

function getPreferencesSnapshot(): UserPreferences {
  const raw = readRawStorage(STORAGE_KEYS.PREFERENCES);
  if (raw !== cachedPrefRaw) {
    cachedPrefRaw = raw;
    cachedPrefValue = parsePreferences(raw);
  }
  return cachedPrefValue;
}

function getPreferencesServerSnapshot(): UserPreferences {
  return DEFAULT_PREFERENCES;
}

function getSavedCombosSnapshot(): string[] {
  const raw = readRawStorage(STORAGE_KEYS.SAVED_COMBOS);
  if (raw !== cachedSavedRaw) {
    cachedSavedRaw = raw;
    cachedSavedValue = parseSavedComboIds(raw);
  }
  return cachedSavedValue;
}

function getSavedCombosServerSnapshot(): string[] {
  return EMPTY_SAVED_COMBOS;
}

function getPrivateNotesSnapshot(): PrivateNote[] {
  const raw = readRawStorage(STORAGE_KEYS.PRIVATE_NOTES);
  if (raw !== cachedNotesRaw) {
    cachedNotesRaw = raw;
    cachedNotesValue = parsePrivateNotes(raw);
  }
  return cachedNotesValue;
}

function getPrivateNotesServerSnapshot(): PrivateNote[] {
  return EMPTY_PRIVATE_NOTES;
}

/** 操作タイプ・表記モードの永続化フック (combonote_v1_preferences) */
export function usePreferences() {
  const subscribe = useCallback(
    (onStoreChange: () => void) =>
      subscribeToKey(STORAGE_KEYS.PREFERENCES, onStoreChange),
    []
  );

  const preferences = useSyncExternalStore(
    subscribe,
    getPreferencesSnapshot,
    getPreferencesServerSnapshot
  );

  const setControlType = useCallback((controlType: ControlType) => {
    const current = getPreferencesSnapshot();
    if (current.controlType === controlType) return;
    writeStorage<UserPreferences>(STORAGE_KEYS.PREFERENCES, {
      ...current,
      controlType,
    });
  }, []);

  const setNotationMode = useCallback((notationMode: NotationMode) => {
    const current = getPreferencesSnapshot();
    if (current.notationMode === notationMode) return;
    writeStorage<UserPreferences>(STORAGE_KEYS.PREFERENCES, {
      ...current,
      notationMode,
    });
  }, []);

  return {
    preferences,
    controlType: preferences.controlType,
    notationMode: preferences.notationMode,
    setControlType,
    setNotationMode,
  };
}

/** マイノート保存済み公開コンボIDの永続化フック (combonote_v1_saved_combos) */
export function useSavedCombos() {
  const subscribe = useCallback(
    (onStoreChange: () => void) =>
      subscribeToKey(STORAGE_KEYS.SAVED_COMBOS, onStoreChange),
    []
  );

  const savedComboIds = useSyncExternalStore(
    subscribe,
    getSavedCombosSnapshot,
    getSavedCombosServerSnapshot
  );

  const isSaved = useCallback(
    (comboId: string) => savedComboIds.includes(comboId),
    [savedComboIds]
  );

  /** 保存状態を切り替え、保存された場合は true、解除された場合は false を返す */
  const toggleSavedCombo = useCallback((comboId: string): boolean => {
    const current = getSavedCombosSnapshot();
    const exists = current.includes(comboId);
    const next = exists
      ? current.filter((id) => id !== comboId)
      : [...current, comboId];
    writeStorage<string[]>(STORAGE_KEYS.SAVED_COMBOS, next);
    return !exists;
  }, []);

  const removeSavedCombo = useCallback((comboId: string) => {
    const current = getSavedCombosSnapshot();
    if (!current.includes(comboId)) return;
    writeStorage<string[]>(
      STORAGE_KEYS.SAVED_COMBOS,
      current.filter((id) => id !== comboId)
    );
  }, []);

  const replaceSavedCombos = useCallback((comboIds: string[]) => {
    writeStorage<string[]>(
      STORAGE_KEYS.SAVED_COMBOS,
      Array.from(new Set(comboIds))
    );
  }, []);

  return {
    savedComboIds,
    isSaved,
    toggleSavedCombo,
    removeSavedCombo,
    replaceSavedCombos,
  };
}

export type CreatePrivateNoteInput = Omit<
  PrivateNote,
  "id" | "createdAt" | "updatedAt"
>;

export type UpdatePrivateNoteInput = Partial<CreatePrivateNoteInput>;

/** 非公開メモの永続化フック (combonote_v1_private_notes) */
export function usePrivateNotes() {
  const subscribe = useCallback(
    (onStoreChange: () => void) =>
      subscribeToKey(STORAGE_KEYS.PRIVATE_NOTES, onStoreChange),
    []
  );

  const privateNotes = useSyncExternalStore(
    subscribe,
    getPrivateNotesSnapshot,
    getPrivateNotesServerSnapshot
  );

  const addPrivateNote = useCallback((input: CreatePrivateNoteInput): PrivateNote => {
    const now = new Date().toISOString();
    const id =
      typeof crypto !== "undefined" && typeof crypto.randomUUID === "function"
        ? `memo-${crypto.randomUUID()}`
        : `memo-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;

    const newNote: PrivateNote = {
      ...input,
      id,
      createdAt: now,
      updatedAt: now,
    };

    const current = getPrivateNotesSnapshot();
    writeStorage<PrivateNote[]>(STORAGE_KEYS.PRIVATE_NOTES, [
      newNote,
      ...current,
    ]);
    return newNote;
  }, []);

  const updatePrivateNote = useCallback(
    (id: string, patch: UpdatePrivateNoteInput) => {
      const now = new Date().toISOString();
      const current = getPrivateNotesSnapshot();
      const next = current.map((note) =>
        note.id === id ? { ...note, ...patch, updatedAt: now } : note
      );
      writeStorage<PrivateNote[]>(STORAGE_KEYS.PRIVATE_NOTES, next);
    },
    []
  );

  const deletePrivateNote = useCallback((id: string) => {
    const current = getPrivateNotesSnapshot();
    writeStorage<PrivateNote[]>(
      STORAGE_KEYS.PRIVATE_NOTES,
      current.filter((note) => note.id !== id)
    );
  }, []);

  const replacePrivateNotes = useCallback((notes: PrivateNote[]) => {
    writeStorage<PrivateNote[]>(STORAGE_KEYS.PRIVATE_NOTES, notes);
  }, []);

  return {
    privateNotes,
    addPrivateNote,
    updatePrivateNote,
    deletePrivateNote,
    replacePrivateNotes,
  };
}
