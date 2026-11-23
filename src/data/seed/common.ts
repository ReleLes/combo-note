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
  {
    id: "mai",
    slug: "mai",
    nameJa: "舞",
    nameEn: "Mai",
    sortOrder: 5,
    isActive: true,
    stockMeta: {
      label: "焔ストック",
      shortLabel: "焔",
      maxCount: 5,
      gainOptions: [0, 5],
      gainHint: "SA1（陽炎の舞）で +5 獲得",
    },
  },
  {
    id: "ryu",
    slug: "ryu",
    nameJa: "リュウ",
    nameEn: "Ryu",
    sortOrder: 6,
    isActive: true,
    stockMeta: {
      label: "電刃練気",
      shortLabel: "電刃",
      maxCount: 1,
    },
  },
  {
    id: "ken",
    slug: "ken",
    nameJa: "ケン",
    nameEn: "Ken",
    sortOrder: 7,
    isActive: true,
  },
  {
    id: "luke",
    slug: "luke",
    nameJa: "ルーク",
    nameEn: "Luke",
    sortOrder: 8,
    isActive: true,
  },
  {
    id: "cammy",
    slug: "cammy",
    nameJa: "キャミィ",
    nameEn: "Cammy",
    sortOrder: 9,
    isActive: true,
  },
  {
    id: "chun-li",
    slug: "chun-li",
    nameJa: "春麗",
    nameEn: "Chun-Li",
    sortOrder: 10,
    isActive: true,
  },
  {
    id: "guile",
    slug: "guile",
    nameJa: "ガイル",
    nameEn: "Guile",
    sortOrder: 11,
    isActive: true,
  },
  {
    id: "zangief",
    slug: "zangief",
    nameJa: "ザンギエフ",
    nameEn: "Zangief",
    sortOrder: 12,
    isActive: true,
  },
  {
    id: "vega",
    slug: "vega",
    nameJa: "ベガ",
    nameEn: "M. Bison",
    sortOrder: 13,
    isActive: true,
  },
  {
    id: "jp",
    slug: "jp",
    nameJa: "JP",
    nameEn: "JP",
    sortOrder: 14,
    isActive: true,
  },
  {
    id: "ed",
    slug: "ed",
    nameJa: "エド",
    nameEn: "Ed",
    sortOrder: 15,
    isActive: true,
  },
  {
    id: "terry",
    slug: "terry",
    nameJa: "テリー",
    nameEn: "Terry",
    sortOrder: 16,
    isActive: true,
  },
  {
    id: "sagat",
    slug: "sagat",
    nameJa: "サガット",
    nameEn: "Sagat",
    sortOrder: 17,
    isActive: true,
  },
  {
    id: "deejay",
    slug: "deejay",
    nameJa: "ディージェイ",
    nameEn: "Dee Jay",
    sortOrder: 18,
    isActive: true,
  },
  {
    id: "rashid",
    slug: "rashid",
    nameJa: "ラシード",
    nameEn: "Rashid",
    sortOrder: 19,
    isActive: true,
  },
  {
    id: "aki",
    slug: "aki",
    nameJa: "A.K.I.",
    nameEn: "A.K.I.",
    sortOrder: 20,
    isActive: true,
  },
  {
    id: "elena",
    slug: "elena",
    nameJa: "エレナ",
    nameEn: "Elena",
    sortOrder: 21,
    isActive: true,
  },
  {
    id: "alex",
    slug: "alex",
    nameJa: "アレックス",
    nameEn: "Alex",
    sortOrder: 22,
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
    badgeClassName:
      "bg-blue-100 text-blue-700 dark:bg-blue-500/20 dark:text-blue-200 dark:border dark:border-blue-400/30",
    characterId: null,
    sortOrder: 1,
  },
  {
    key: "corner",
    label: "画面端",
    badgeClassName:
      "bg-amber-100 text-amber-700 dark:bg-amber-500/20 dark:text-amber-200 dark:border dark:border-amber-400/30",
    characterId: null,
    sortOrder: 2,
  },
  {
    key: "di_hit",
    label: "DIヒット",
    badgeClassName:
      "bg-purple-100 text-purple-700 dark:bg-purple-500/25 dark:text-purple-200 dark:border dark:border-purple-400/35",
    characterId: null,
    sortOrder: 3,
  },
  {
    key: "di_wall_splat",
    label: "壁ドン",
    badgeClassName:
      "bg-fuchsia-100 text-fuchsia-700 dark:bg-fuchsia-500/20 dark:text-fuchsia-200 dark:border dark:border-fuchsia-400/30",
    characterId: null,
    sortOrder: 4,
  },
  {
    key: "counter",
    label: "カウンター",
    badgeClassName:
      "bg-red-100 text-red-700 dark:bg-red-500/20 dark:text-red-200 dark:border dark:border-red-400/30",
    characterId: null,
    sortOrder: 5,
  },
  {
    key: "punish_counter",
    label: "パニカン",
    badgeClassName:
      "bg-rose-100 text-rose-700 dark:bg-rose-500/20 dark:text-rose-200 dark:border dark:border-rose-400/30",
    characterId: null,
    sortOrder: 6,
  },
  {
    key: "anti_air",
    label: "対空",
    badgeClassName:
      "bg-emerald-100 text-emerald-700 dark:bg-emerald-500/20 dark:text-emerald-200 dark:border dark:border-emerald-400/30",
    characterId: null,
    sortOrder: 7,
  },
  {
    key: "stun",
    label: "スタン",
    badgeClassName:
      "bg-yellow-100 text-yellow-800 dark:bg-yellow-500/20 dark:text-yellow-200 dark:border dark:border-yellow-400/30",
    characterId: null,
    sortOrder: 8,
  },

  // キャラ固有状況
  {
    key: "juri_feng_shui",
    label: "風水エンジン",
    badgeClassName:
      "bg-pink-100 text-pink-700 dark:bg-pink-500/20 dark:text-pink-200 dark:border dark:border-pink-400/30",
    characterId: "juri",
    sortOrder: 101,
  },
  {
    key: "c_viper_feint",
    label: "フェイントキャンセル",
    badgeClassName:
      "bg-pink-100 text-pink-700 dark:bg-pink-500/20 dark:text-pink-200 dark:border dark:border-pink-400/30",
    characterId: "c-viper",
    sortOrder: 103,
  },
  {
    key: "ingrid_sun_install",
    label: "空中派生",
    badgeClassName:
      "bg-pink-100 text-pink-700 dark:bg-pink-500/20 dark:text-pink-200 dark:border dark:border-pink-400/30",
    characterId: "ingrid",
    sortOrder: 104,
  },
  {
    key: "ingrid_sun_symbol",
    label: "サンシンボル",
    badgeClassName:
      "bg-cyan-100 text-cyan-800 dark:bg-cyan-500/20 dark:text-cyan-200 dark:border dark:border-cyan-400/30",
    characterId: "ingrid",
    sortOrder: 106,
  },
  {
    key: "mai_flame_stock",
    label: "焔ストック",
    badgeClassName:
      "bg-orange-100 text-orange-700 dark:bg-orange-500/20 dark:text-orange-200 dark:border dark:border-orange-400/30",
    characterId: "mai",
    sortOrder: 105,
  },
  {
    key: "ryu_denjin",
    label: "電刃練気",
    badgeClassName:
      "bg-sky-100 text-sky-700 dark:bg-sky-500/20 dark:text-sky-200 dark:border dark:border-sky-400/30",
    characterId: "ryu",
    sortOrder: 107,
  },
  {
    key: "guile_solid_puncher",
    label: "ソリッドパンチャー",
    badgeClassName:
      "bg-lime-100 text-lime-800 dark:bg-lime-500/20 dark:text-lime-200 dark:border dark:border-lime-400/30",
    characterId: "guile",
    sortOrder: 108,
  },
  {
    key: "vega_psycho_mine",
    label: "サイコマイン",
    badgeClassName:
      "bg-purple-100 text-purple-800 dark:bg-purple-500/25 dark:text-purple-200 dark:border dark:border-fuchsia-400/35",
    characterId: "vega",
    sortOrder: 109,
  },
  {
    key: "rashid_air_current",
    label: "気流",
    badgeClassName:
      "bg-teal-100 text-teal-800 dark:bg-teal-500/20 dark:text-teal-200 dark:border dark:border-teal-400/35",
    characterId: "rashid",
    sortOrder: 110,
  },
  {
    key: "aki_poison",
    label: "毒状態",
    badgeClassName:
      "bg-violet-100 text-violet-800 dark:bg-violet-500/25 dark:text-lime-200 dark:border dark:border-lime-400/35",
    characterId: "aki",
    sortOrder: 111,
  },
  {
    key: "alex_back_turned",
    label: "背面やられ",
    badgeClassName:
      "bg-red-100 text-red-800 dark:bg-red-500/25 dark:text-lime-200 dark:border dark:border-red-400/35",
    characterId: "alex",
    sortOrder: 112,
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
  {
    id: "sys_ch",
    characterId: null,
    controlType: "both",
    category: "system",
    notationNumpad: "(CH)",
    notationCommand: "(CH)",
    notationName: "カウンターヒット",
    sortOrder: 10,
  },
  {
    id: "sys_pc",
    characterId: null,
    controlType: "both",
    category: "system",
    notationNumpad: "(PC)",
    notationCommand: "(PC)",
    notationName: "パニッシュカウンター",
    sortOrder: 11,
  },
];

export function buildRecipeSignature(
  characterId: string,
  controlType: ControlType,
  moveIds: string[]
): string {
  return `${characterId}:${controlType}:${moveIds.join(">")}`;
}
