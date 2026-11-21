import type {
  Character,
  ComboCategoryDefinition,
  ControlType,
  GameVersion,
  Move,
  SituationDefinition,
} from "@/types/combo";

export const SEED_CHARACTERS: Character[] = [
  {
    id: "akuma",
    slug: "akuma",
    nameJa: "豪鬼",
    nameEn: "Akuma",
    sortOrder: 1,
    isActive: true,
  },
  {
    id: "juri",
    slug: "juri",
    nameJa: "ジュリ",
    nameEn: "Juri",
    sortOrder: 2,
    isActive: true,
    stockMeta: {
      label: "風破ストック",
      shortLabel: "風破",
      maxCount: 3,
    },
  },
  {
    id: "ingrid",
    slug: "ingrid",
    nameJa: "イングリッド",
    nameEn: "Ingrid",
    sortOrder: 3,
    isActive: true,
    stockMeta: {
      label: "サンシンボル",
      shortLabel: "サンシンボル",
      maxCount: 4,
    },
  },
  {
    id: "c-viper",
    slug: "c-viper",
    nameJa: "C.ヴァイパー",
    nameEn: "C. Viper",
    sortOrder: 4,
    isActive: true,
  },
];

export const SEED_GAME_VERSIONS: GameVersion[] = [
  {
    id: "year2",
    label: "Year 2",
    releasedAt: "2024-05-22T00:00:00Z",
  },
  {
    id: "year3",
    label: "Year 3",
    releasedAt: "2025-06-05T00:00:00Z",
  },
  {
    id: "year4",
    label: "Year 4 / Ver.2026",
    releasedAt: "2026-06-01T00:00:00Z",
  },
];

export const COMBO_CATEGORIES: ComboCategoryDefinition[] = [
  { key: "beginner", label: "初心者向け", sortOrder: 1 },
  { key: "standard", label: "基本・定番", sortOrder: 2 },
  { key: "optimal", label: "高火力", sortOrder: 3 },
  { key: "fun", label: "ネタコン", sortOrder: 4 },
];

export const SEED_SITUATIONS: SituationDefinition[] = [
  // 共通状況
  {
    key: "midscreen",
    label: "中央・基本",
    badgeClassName: "bg-blue-100 text-blue-700",
    characterId: null,
    sortOrder: 1,
  },
  {
    key: "corner",
    label: "画面端",
    badgeClassName: "bg-amber-100 text-amber-700",
    characterId: null,
    sortOrder: 2,
  },
  {
    key: "di_hit",
    label: "DIヒット",
    badgeClassName: "bg-purple-100 text-purple-700",
    characterId: null,
    sortOrder: 3,
  },
  {
    key: "di_wall_splat",
    label: "壁ドン",
    badgeClassName: "bg-fuchsia-100 text-fuchsia-700",
    characterId: null,
    sortOrder: 4,
  },
  {
    key: "punish_counter",
    label: "パニカン",
    badgeClassName: "bg-rose-100 text-rose-700",
    characterId: null,
    sortOrder: 5,
  },
  {
    key: "anti_air",
    label: "対空",
    badgeClassName: "bg-emerald-100 text-emerald-700",
    characterId: null,
    sortOrder: 6,
  },
  {
    key: "stun",
    label: "スタン",
    badgeClassName: "bg-yellow-100 text-yellow-800",
    characterId: null,
    sortOrder: 7,
  },

  // キャラ固有状況
  {
    key: "juri_feng_shui",
    label: "風水エンジン",
    badgeClassName: "bg-pink-100 text-pink-700",
    characterId: "juri",
    sortOrder: 101,
  },
  {
    key: "c_viper_feint",
    label: "フェイントキャンセル",
    badgeClassName: "bg-pink-100 text-pink-700",
    characterId: "c-viper",
    sortOrder: 103,
  },
  {
    key: "ingrid_sun_install",
    label: "空中派生",
    badgeClassName: "bg-pink-100 text-pink-700",
    characterId: "ingrid",
    sortOrder: 104,
  },
];

/** 全キャラ共通のシステムパーツ（characterId: null） */
export const SYSTEM_MOVES: Move[] = [
  {
    id: "sys_dr",
    characterId: null,
    controlType: "both",
    category: "system",
    notationNumpad: "CDR",
    notationCommand: "CDR",
    notationName: "キャンセルドライブラッシュ",
    sortOrder: 1,
  },
  {
    id: "sys_raw_dr",
    characterId: null,
    controlType: "both",
    category: "system",
    notationNumpad: "DR",
    notationCommand: "DR",
    notationName: "ドライブラッシュ",
    sortOrder: 2,
  },
  {
    id: "sys_di",
    characterId: null,
    controlType: "both",
    category: "system",
    notationNumpad: "DI",
    notationCommand: "DI",
    notationName: "ドライブインパクト",
    sortOrder: 3,
  },
  {
    id: "sys_micro_walk",
    characterId: null,
    controlType: "both",
    category: "system",
    notationNumpad: "微歩き",
    notationCommand: "微歩き",
    notationName: "微歩き",
    sortOrder: 4,
  },
  {
    id: "sys_dash",
    characterId: null,
    controlType: "both",
    category: "system",
    notationNumpad: "前ステップ",
    notationCommand: "前ステップ",
    notationName: "前ステップ",
    sortOrder: 5,
  },
  {
    id: "sys_delay",
    characterId: null,
    controlType: "both",
    category: "system",
    notationNumpad: "ディレイ",
    notationCommand: "ディレイ",
    notationName: "ディレイ",
    sortOrder: 6,
  },
  {
    id: "sys_jump",
    characterId: null,
    controlType: "both",
    category: "system",
    notationNumpad: "J",
    notationCommand: "↑",
    notationName: "ジャンプ",
    sortOrder: 7,
  },
  {
    id: "sys_f_jump",
    characterId: null,
    controlType: "both",
    category: "system",
    notationNumpad: "前J",
    notationCommand: "↗",
    notationName: "前ジャンプ",
    sortOrder: 8,
  },
  {
    id: "sys_jc",
    characterId: null,
    controlType: "both",
    category: "system",
    notationNumpad: "Jキャン",
    notationCommand: "Jキャン",
    notationName: "ジャンプキャンセル",
    sortOrder: 9,
  },
];

export function buildRecipeSignature(
  characterId: string,
  controlType: ControlType,
  moveIds: string[]
): string {
  return `${characterId}:${controlType}:${moveIds.join(">")}`;
}
