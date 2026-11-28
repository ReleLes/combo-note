import type {
  Character,
  ComboCategoryDefinition,
  ControlType,
  GameVersion,
  Move,
  SituationDefinition,
  SituationGroup,
} from "@/types/combo";

export const SEED_CHARACTERS: Character[] = [
  {
    id: "luke",
    slug: "luke",
    nameJa: "ルーク",
    nameEn: "Luke",
    sortOrder: 1,
    isActive: true,
  },
  {
    id: "jamie",
    slug: "jamie",
    nameJa: "ジェイミー",
    nameEn: "Jamie",
    sortOrder: 2,
    isActive: true,
    stockMeta: {
      label: "酔いレベル",
      shortLabel: "酔い",
      maxCount: 4,
      gainOptions: [0, 1, 2, 3, 4],
      gainHint: "飲み技（魔身・流酔脚3段目・幻酔舞3段目・円月脚3段目・SA1飲み・前投げ飲み）で +1 上昇",
    },
  },
  {
    id: "manon",
    slug: "manon",
    nameJa: "マノン",
    nameEn: "Manon",
    sortOrder: 3,
    isActive: true,
    stockMeta: {
      label: "メダル",
      shortLabel: "メダル",
      maxCount: 5,
      gainOptions: [0, 1, 2],
      gainHint: "マネージュ・ドレ／ランヴェルセで +1 獲得",
    },
  },
  {
    id: "kimberly",
    slug: "kimberly",
    nameJa: "キンバリー",
    nameEn: "Kimberly",
    sortOrder: 4,
    isActive: true,
    stockMeta: {
      label: "細工手裏剣",
      shortLabel: "手裏剣",
      maxCount: 3,
      gainOptions: [0, 1, 3],
      gainHint: "召雷細工で +1 / OD召雷細工で +3 獲得",
    },
  },
  {
    id: "marisa",
    slug: "marisa",
    nameJa: "マリーザ",
    nameEn: "Marisa",
    sortOrder: 5,
    isActive: true,
  },
  {
    id: "lily",
    slug: "lily",
    nameJa: "リリー",
    nameEn: "Lily",
    sortOrder: 6,
    isActive: true,
    stockMeta: {
      label: "風纏い",
      shortLabel: "風纏い",
      maxCount: 3,
      gainOptions: [0, 1, 2, 3],
      gainHint: "中/強コンドルウィンドで +1 / ODホールドで +2 / 溜めで最大 +3 獲得",
    },
  },
  {
    id: "jp",
    slug: "jp",
    nameJa: "JP",
    nameEn: "JP",
    sortOrder: 7,
    isActive: true,
  },
  {
    id: "juri",
    slug: "juri",
    nameJa: "ジュリ",
    nameEn: "Juri",
    sortOrder: 8,
    isActive: true,
    stockMeta: {
      label: "風破ストック",
      shortLabel: "風破",
      maxCount: 3,
    },
  },
  {
    id: "deejay",
    slug: "deejay",
    nameJa: "ディージェイ",
    nameEn: "Dee Jay",
    sortOrder: 9,
    isActive: true,
  },
  {
    id: "cammy",
    slug: "cammy",
    nameJa: "キャミィ",
    nameEn: "Cammy",
    sortOrder: 10,
    isActive: true,
  },
  {
    id: "ryu",
    slug: "ryu",
    nameJa: "リュウ",
    nameEn: "Ryu",
    sortOrder: 11,
    isActive: true,
    stockMeta: {
      label: "電刃練気",
      shortLabel: "電刃",
      maxCount: 1,
    },
  },
  {
    id: "ehonda",
    slug: "ehonda",
    nameJa: "エドモンド本田",
    nameEn: "E. Honda",
    sortOrder: 12,
    isActive: true,
    stockMeta: {
      label: "相撲魂",
      shortLabel: "相撲魂",
      maxCount: 1,
    },
  },
  {
    id: "blanka",
    slug: "blanka",
    nameJa: "ブランカ",
    nameEn: "Blanka",
    sortOrder: 13,
    isActive: true,
  },
  {
    id: "guile",
    slug: "guile",
    nameJa: "ガイル",
    nameEn: "Guile",
    sortOrder: 14,
    isActive: true,
  },
  {
    id: "ken",
    slug: "ken",
    nameJa: "ケン",
    nameEn: "Ken",
    sortOrder: 15,
    isActive: true,
  },
  {
    id: "chun-li",
    slug: "chun-li",
    nameJa: "春麗",
    nameEn: "Chun-Li",
    sortOrder: 16,
    isActive: true,
  },
  {
    id: "zangief",
    slug: "zangief",
    nameJa: "ザンギエフ",
    nameEn: "Zangief",
    sortOrder: 17,
    isActive: true,
  },
  {
    id: "dhalsim",
    slug: "dhalsim",
    nameJa: "ダルシム",
    nameEn: "Dhalsim",
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
    id: "ed",
    slug: "ed",
    nameJa: "エド",
    nameEn: "Ed",
    sortOrder: 21,
    isActive: true,
  },
  {
    id: "akuma",
    slug: "akuma",
    nameJa: "豪鬼",
    nameEn: "Akuma",
    sortOrder: 22,
    isActive: true,
  },
  {
    id: "vega",
    slug: "vega",
    nameJa: "ベガ",
    nameEn: "M. Bison",
    sortOrder: 23,
    isActive: true,
  },
  {
    id: "terry",
    slug: "terry",
    nameJa: "テリー",
    nameEn: "Terry",
    sortOrder: 24,
    isActive: true,
  },
  {
    id: "mai",
    slug: "mai",
    nameJa: "舞",
    nameEn: "Mai",
    sortOrder: 25,
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
    id: "elena",
    slug: "elena",
    nameJa: "エレナ",
    nameEn: "Elena",
    sortOrder: 26,
    isActive: true,
  },
  {
    id: "sagat",
    slug: "sagat",
    nameJa: "サガット",
    nameEn: "Sagat",
    sortOrder: 27,
    isActive: true,
  },
  {
    id: "c-viper",
    slug: "c-viper",
    nameJa: "C.ヴァイパー",
    nameEn: "C. Viper",
    sortOrder: 28,
    isActive: true,
  },
  {
    id: "alex",
    slug: "alex",
    nameJa: "アレックス",
    nameEn: "Alex",
    sortOrder: 29,
    isActive: true,
  },
  {
    id: "ingrid",
    slug: "ingrid",
    nameJa: "イングリッド",
    nameEn: "Ingrid",
    sortOrder: 30,
    isActive: true,
    stockMeta: {
      label: "サンシンボル",
      shortLabel: "サンシンボル",
      maxCount: 4,
    },
  },
  {
    id: "yasmine",
    slug: "yasmine",
    nameJa: "ヤスミン",
    nameEn: "Yasmine",
    sortOrder: 31,
    isActive: true,
    stockMeta: {
      label: "バヤニ・モード",
      shortLabel: "バヤニ",
      maxCount: 1,
    },
  },
  {
    id: "arjun",
    slug: "arjun",
    nameJa: "アルジュン",
    nameEn: "Arjun",
    sortOrder: 32,
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

export const SITUATION_GROUPS: ReadonlyArray<{
  key: SituationGroup;
  label: string;
}> = [
  { key: "basic", label: "基本状況" },
  { key: "purpose", label: "実戦目的・状態" },
  { key: "character", label: "キャラ固有" },
];

export const SEED_SITUATIONS: SituationDefinition[] = [
  // 基本状況（共通）
  {
    key: "midscreen",
    label: "中央・基本",
    badgeClassName:
      "bg-blue-100 text-blue-700 dark:bg-blue-500/20 dark:text-blue-200 dark:border dark:border-blue-400/30",
    characterId: null,
    group: "basic",
    sortOrder: 1,
  },
  {
    key: "corner",
    label: "画面端",
    badgeClassName:
      "bg-amber-100 text-amber-700 dark:bg-amber-500/20 dark:text-amber-200 dark:border dark:border-amber-400/30",
    characterId: null,
    group: "basic",
    sortOrder: 2,
  },
  {
    key: "di_hit",
    label: "DIヒット",
    badgeClassName:
      "bg-purple-100 text-purple-700 dark:bg-purple-500/25 dark:text-purple-200 dark:border dark:border-purple-400/35",
    characterId: null,
    group: "basic",
    sortOrder: 3,
  },
  {
    key: "di_wall_splat",
    label: "壁ドン",
    badgeClassName:
      "bg-fuchsia-100 text-fuchsia-700 dark:bg-fuchsia-500/20 dark:text-fuchsia-200 dark:border dark:border-fuchsia-400/30",
    characterId: null,
    group: "basic",
    sortOrder: 4,
  },
  {
    key: "counter",
    label: "カウンター",
    badgeClassName:
      "bg-red-100 text-red-700 dark:bg-red-500/20 dark:text-red-200 dark:border dark:border-red-400/30",
    characterId: null,
    group: "basic",
    sortOrder: 5,
  },
  {
    key: "punish_counter",
    label: "パニカン",
    badgeClassName:
      "bg-rose-100 text-rose-700 dark:bg-rose-500/20 dark:text-rose-200 dark:border dark:border-rose-400/30",
    characterId: null,
    group: "basic",
    sortOrder: 6,
  },
  {
    key: "anti_air",
    label: "対空",
    badgeClassName:
      "bg-emerald-100 text-emerald-700 dark:bg-emerald-500/20 dark:text-emerald-200 dark:border dark:border-emerald-400/30",
    characterId: null,
    group: "basic",
    sortOrder: 7,
  },
  {
    key: "stun",
    label: "スタン",
    badgeClassName:
      "bg-yellow-100 text-yellow-800 dark:bg-yellow-500/20 dark:text-yellow-200 dark:border dark:border-yellow-400/30",
    characterId: null,
    group: "basic",
    sortOrder: 8,
  },

  // 実戦目的・状態（共通）
  {
    key: "lethal",
    label: "リーサル",
    badgeClassName:
      "border border-red-300 bg-red-600 text-white dark:border-red-400/60 dark:bg-red-600/85 dark:text-red-50",
    characterId: null,
    group: "purpose",
    description: "倒し切り・最大火力",
    sortOrder: 21,
  },
  {
    key: "corner_carry",
    label: "運び",
    badgeClassName:
      "bg-indigo-100 text-indigo-700 dark:bg-indigo-500/25 dark:text-indigo-200 dark:border dark:border-indigo-400/35",
    characterId: null,
    group: "purpose",
    description: "画面端への運び重視",
    sortOrder: 22,
  },
  {
    key: "drive_recovery",
    label: "Dゲージ回復",
    badgeClassName:
      "bg-sky-100 text-sky-700 dark:bg-sky-500/20 dark:text-sky-200 dark:border dark:border-sky-400/35",
    characterId: null,
    group: "purpose",
    description: "Dゲージ回復待ち・時間稼ぎ",
    sortOrder: 23,
  },
  {
    key: "burnout",
    label: "自分BO中",
    badgeClassName:
      "bg-slate-200 text-slate-800 dark:bg-slate-500/25 dark:text-slate-200 dark:border dark:border-slate-400/35",
    characterId: null,
    group: "purpose",
    description: "バーンアウト中でも使用可能",
    sortOrder: 24,
  },
  {
    key: "setplay",
    label: "セットプレイ",
    badgeClassName:
      "bg-teal-100 text-teal-800 dark:bg-teal-500/20 dark:text-teal-200 dark:border dark:border-teal-400/35",
    characterId: null,
    group: "purpose",
    description: "詐欺飛び・起き攻め連携・セットプレイ向け",
    sortOrder: 25,
  },

  // キャラ固有状況
  {
    key: "juri_feng_shui",
    label: "風水エンジン",
    badgeClassName:
      "bg-pink-100 text-pink-700 dark:bg-pink-500/20 dark:text-pink-200 dark:border dark:border-pink-400/30",
    characterId: "juri",
    group: "character",
    sortOrder: 101,
  },
  {
    key: "juri_fuha_stock",
    label: "風破ストック",
    badgeClassName:
      "bg-fuchsia-100 text-fuchsia-800 dark:bg-fuchsia-500/25 dark:text-fuchsia-200 dark:border dark:border-fuchsia-400/35",
    characterId: "juri",
    group: "character",
    description: "風破ストックを消費する強化技を使用",
    sortOrder: 102,
  },
  {
    key: "juri_fuha_gain",
    label: "風破溜め",
    badgeClassName:
      "bg-purple-100 text-purple-700 dark:bg-purple-500/20 dark:text-purple-200 dark:border dark:border-purple-400/35",
    characterId: "juri",
    group: "character",
    description: "風破刃で風破ストックを獲得",
    sortOrder: 103,
  },
  {
    key: "c_viper_feint",
    label: "フェイントキャンセル",
    badgeClassName:
      "bg-pink-100 text-pink-700 dark:bg-pink-500/20 dark:text-pink-200 dark:border dark:border-pink-400/30",
    characterId: "c-viper",
    group: "character",
    sortOrder: 104,
  },
  {
    key: "ingrid_sun_install",
    label: "空中派生",
    badgeClassName:
      "bg-pink-100 text-pink-700 dark:bg-pink-500/20 dark:text-pink-200 dark:border dark:border-pink-400/30",
    characterId: "ingrid",
    group: "character",
    sortOrder: 105,
  },
  {
    key: "ingrid_sun_symbol",
    label: "サンシンボル",
    badgeClassName:
      "bg-cyan-100 text-cyan-800 dark:bg-cyan-500/20 dark:text-cyan-200 dark:border dark:border-cyan-400/30",
    characterId: "ingrid",
    group: "character",
    description: "サンシンボルを消費する強化技を使用",
    sortOrder: 106,
  },
  {
    key: "ingrid_sun_symbol_gain",
    label: "サンシンボル獲得",
    badgeClassName:
      "bg-sky-100 text-sky-800 dark:bg-sky-500/20 dark:text-sky-200 dark:border dark:border-sky-400/35",
    characterId: "ingrid",
    group: "character",
    description: "弱サンフレア等でサンシンボルを獲得",
    sortOrder: 107,
  },
  {
    key: "mai_flame_stock",
    label: "焔ストック",
    badgeClassName:
      "bg-orange-100 text-orange-700 dark:bg-orange-500/20 dark:text-orange-200 dark:border dark:border-orange-400/30",
    characterId: "mai",
    group: "character",
    description: "焔ストックを消費する強化技を使用",
    sortOrder: 108,
  },
  {
    key: "mai_flame_gain",
    label: "焔獲得",
    badgeClassName:
      "bg-amber-100 text-amber-800 dark:bg-amber-500/20 dark:text-amber-200 dark:border dark:border-amber-400/35",
    characterId: "mai",
    group: "character",
    description: "SA1 陽炎の舞で焔ストックを獲得",
    sortOrder: 109,
  },
  {
    key: "ryu_denjin",
    label: "電刃練気",
    badgeClassName:
      "bg-sky-100 text-sky-700 dark:bg-sky-500/20 dark:text-sky-200 dark:border dark:border-sky-400/30",
    characterId: "ryu",
    group: "character",
    description: "電刃練気ストックを消費する強化技を使用",
    sortOrder: 110,
  },
  {
    key: "ryu_denjin_gain",
    label: "電刃溜め",
    badgeClassName:
      "bg-cyan-100 text-cyan-800 dark:bg-cyan-500/20 dark:text-cyan-200 dark:border dark:border-cyan-400/35",
    characterId: "ryu",
    group: "character",
    description: "電刃錬気で電刃ストックを獲得",
    sortOrder: 111,
  },
  {
    key: "guile_solid_puncher",
    label: "ソリッドパンチャー",
    badgeClassName:
      "bg-lime-100 text-lime-800 dark:bg-lime-500/20 dark:text-lime-200 dark:border dark:border-lime-400/30",
    characterId: "guile",
    group: "character",
    sortOrder: 112,
  },
  {
    key: "vega_mine_plant",
    label: "マイン設置",
    badgeClassName:
      "bg-indigo-100 text-indigo-800 dark:bg-indigo-500/20 dark:text-indigo-200 dark:border dark:border-indigo-400/35",
    characterId: "vega",
    group: "character",
    description: "バックフィストコンボでサイコマインを設置",
    sortOrder: 113,
  },
  {
    key: "vega_mine_detonate",
    label: "マイン起爆",
    badgeClassName:
      "bg-purple-100 text-purple-800 dark:bg-purple-500/25 dark:text-purple-200 dark:border dark:border-fuchsia-400/35",
    characterId: "vega",
    group: "character",
    description: "サイコマイン起爆を伴うコンボ",
    sortOrder: 114,
  },
  {
    key: "rashid_air_set",
    label: "気流設置",
    badgeClassName:
      "bg-cyan-100 text-cyan-800 dark:bg-cyan-500/20 dark:text-cyan-200 dark:border dark:border-cyan-400/35",
    characterId: "rashid",
    group: "character",
    description: "溜めワールウインド・ショットやイウサールで気流を設置",
    sortOrder: 115,
  },
  {
    key: "rashid_air_boost",
    label: "気流強化",
    badgeClassName:
      "bg-teal-100 text-teal-800 dark:bg-teal-500/20 dark:text-teal-200 dark:border dark:border-teal-400/35",
    characterId: "rashid",
    group: "character",
    description: "気流強化版の必殺技・派生を使用",
    sortOrder: 116,
  },
  {
    key: "aki_poison_inflict",
    label: "毒付与",
    badgeClassName:
      "bg-emerald-100 text-emerald-800 dark:bg-emerald-500/20 dark:text-emerald-200 dark:border dark:border-emerald-400/35",
    characterId: "aki",
    group: "character",
    description: "相手を毒状態にする技を含むコンボ",
    sortOrder: 117,
  },
  {
    key: "aki_poison_state",
    label: "毒状態限定",
    badgeClassName:
      "bg-violet-100 text-violet-800 dark:bg-violet-500/25 dark:text-lime-200 dark:border dark:border-lime-400/35",
    characterId: "aki",
    group: "character",
    description: "相手の毒状態・毒破裂を前提とするコンボ",
    sortOrder: 118,
  },
  {
    key: "alex_back_turned",
    label: "背面やられ",
    badgeClassName:
      "bg-red-100 text-red-800 dark:bg-red-500/25 dark:text-lime-200 dark:border dark:border-red-400/35",
    characterId: "alex",
    group: "character",
    sortOrder: 119,
  },
  {
    key: "yasmine_bayani",
    label: "バヤニ・モード",
    badgeClassName:
      "bg-sky-100 text-sky-800 dark:bg-sky-500/20 dark:text-amber-200 dark:border dark:border-sky-400/35",
    characterId: "yasmine",
    group: "character",
    sortOrder: 120,
  },
  {
    key: "yasmine_nakatagong_lakas",
    label: "ナカタゴン・ラカス",
    badgeClassName:
      "bg-amber-100 text-amber-800 dark:bg-amber-500/20 dark:text-yellow-200 dark:border dark:border-amber-400/35",
    characterId: "yasmine",
    group: "character",
    sortOrder: 121,
  },
  {
    key: "arjun_giant_rock",
    label: "岩設置中",
    badgeClassName:
      "bg-orange-100 text-orange-800 dark:bg-orange-500/20 dark:text-orange-200 dark:border dark:border-orange-400/35",
    characterId: "arjun",
    group: "character",
    sortOrder: 122,
  },
  {
    key: "jamie_drink_lv1",
    label: "酔いLv1+",
    badgeClassName:
      "bg-amber-100 text-amber-800 dark:bg-amber-500/20 dark:text-amber-200 dark:border dark:border-amber-400/35",
    characterId: "jamie",
    group: "character",
    description: "酔いレベル1以上で解禁される技を使用",
    sortOrder: 123,
  },
  {
    key: "jamie_drink_lv2",
    label: "酔いLv2+",
    badgeClassName:
      "bg-amber-100 text-amber-900 dark:bg-amber-500/25 dark:text-amber-100 dark:border dark:border-amber-400/45",
    characterId: "jamie",
    group: "character",
    description: "酔いレベル2以上で解禁される技を使用",
    sortOrder: 124,
  },
  {
    key: "jamie_drink_lv3",
    label: "酔いLv3+",
    badgeClassName:
      "bg-orange-100 text-orange-800 dark:bg-orange-500/25 dark:text-orange-200 dark:border dark:border-orange-400/45",
    characterId: "jamie",
    group: "character",
    description: "酔いレベル3以上で解禁される技を使用",
    sortOrder: 125,
  },
  {
    key: "jamie_drink_lv4",
    label: "酔いLv4",
    badgeClassName:
      "bg-red-100 text-red-800 dark:bg-red-500/25 dark:text-red-200 dark:border dark:border-red-400/45",
    characterId: "jamie",
    group: "character",
    description: "酔いレベル4で解禁・強化される技を使用",
    sortOrder: 126,
  },
  {
    key: "jamie_drink_gain",
    label: "酔いLv上昇",
    badgeClassName:
      "bg-yellow-100 text-yellow-800 dark:bg-yellow-500/20 dark:text-yellow-200 dark:border dark:border-yellow-400/35",
    characterId: "jamie",
    group: "character",
    description: "飲み技で酔いレベルを上昇させるコンボ",
    sortOrder: 127,
  },
  {
    key: "kimberly_shuriken",
    label: "細工手裏剣（消費）",
    badgeClassName:
      "bg-pink-100 text-pink-800 dark:bg-fuchsia-500/20 dark:text-pink-200 dark:border dark:border-pink-400/35",
    characterId: "kimberly",
    group: "character",
    description: "細工手裏剣の消費・起爆を伴うコンボ",
    sortOrder: 128,
  },
  {
    key: "kimberly_shuriken_gain",
    label: "細工手裏剣（溜め）",
    badgeClassName:
      "bg-fuchsia-100 text-fuchsia-800 dark:bg-fuchsia-500/20 dark:text-fuchsia-200 dark:border dark:border-fuchsia-400/35",
    characterId: "kimberly",
    group: "character",
    description: "召雷細工で細工手裏剣を補充",
    sortOrder: 129,
  },
  {
    key: "manon_medal_gain",
    label: "メダル獲得",
    badgeClassName:
      "bg-rose-100 text-rose-800 dark:bg-rose-500/20 dark:text-rose-200 dark:border dark:border-rose-400/35",
    characterId: "manon",
    group: "character",
    description: "マネージュ・ドレ／ランヴェルセでメダルを獲得",
    sortOrder: 130,
  },
  {
    key: "blanka_lightning_beast",
    label: "ライトニングビースト",
    badgeClassName:
      "bg-emerald-100 text-emerald-800 dark:bg-emerald-500/20 dark:text-yellow-200 dark:border dark:border-emerald-400/35",
    characterId: "blanka",
    group: "character",
    sortOrder: 131,
  },
  {
    key: "ehonda_sumo_spirit",
    label: "相撲魂",
    badgeClassName:
      "bg-rose-100 text-rose-800 dark:bg-rose-500/20 dark:text-rose-200 dark:border dark:border-rose-400/35",
    characterId: "ehonda",
    group: "character",
    description: "相撲魂を消費する強化張り手を使用",
    sortOrder: 132,
  },
  {
    key: "ehonda_sumo_spirit_gain",
    label: "相撲魂獲得",
    badgeClassName:
      "bg-orange-100 text-orange-800 dark:bg-orange-500/20 dark:text-orange-200 dark:border dark:border-orange-400/35",
    characterId: "ehonda",
    group: "character",
    description: "肩屋入りで相撲魂を獲得",
    sortOrder: 133,
  },
  {
    key: "lily_windclad",
    label: "風纏い",
    badgeClassName:
      "bg-emerald-100 text-emerald-800 dark:bg-sky-500/20 dark:text-emerald-200 dark:border dark:border-emerald-400/35",
    characterId: "lily",
    group: "character",
    description: "風纏いストックを消費する強化技を使用",
    sortOrder: 134,
  },
  {
    key: "lily_windclad_gain",
    label: "風纏い獲得",
    badgeClassName:
      "bg-teal-100 text-teal-800 dark:bg-teal-500/20 dark:text-teal-200 dark:border dark:border-teal-400/35",
    characterId: "lily",
    group: "character",
    description: "コンドルウィンドで風纏いストックを獲得",
    sortOrder: 135,
  },
];

/**
 * 廃止された旧キャラ固有状況キーの表示フォールバック定義。
 * DB や LocalStorage に旧キーが残っている既存コンボの描画時に使用する。
 */
export const LEGACY_SITUATION_FALLBACKS: Readonly<
  Record<string, SituationDefinition>
> = {
  jamie_drink_level: {
    key: "jamie_drink_level",
    label: "酔いレベル",
    badgeClassName:
      "bg-amber-100 text-amber-800 dark:bg-amber-500/20 dark:text-amber-200 dark:border dark:border-amber-400/35",
    characterId: "jamie",
    group: "character",
    description: "旧タグ（酔いレベル関連）",
    sortOrder: 901,
  },
  manon_medal: {
    key: "manon_medal",
    label: "メダル",
    badgeClassName:
      "bg-rose-100 text-rose-800 dark:bg-rose-500/20 dark:text-rose-200 dark:border dark:border-rose-400/35",
    characterId: "manon",
    group: "character",
    description: "旧タグ（メダル関連）",
    sortOrder: 902,
  },
  aki_poison: {
    key: "aki_poison",
    label: "毒状態",
    badgeClassName:
      "bg-violet-100 text-violet-800 dark:bg-violet-500/25 dark:text-lime-200 dark:border dark:border-lime-400/35",
    characterId: "aki",
    group: "character",
    description: "旧タグ（毒状態関連）",
    sortOrder: 903,
  },
  vega_psycho_mine: {
    key: "vega_psycho_mine",
    label: "サイコマイン",
    badgeClassName:
      "bg-purple-100 text-purple-800 dark:bg-purple-500/25 dark:text-purple-200 dark:border dark:border-fuchsia-400/35",
    characterId: "vega",
    group: "character",
    description: "旧タグ（サイコマイン関連）",
    sortOrder: 904,
  },
  rashid_air_current: {
    key: "rashid_air_current",
    label: "気流",
    badgeClassName:
      "bg-teal-100 text-teal-800 dark:bg-teal-500/20 dark:text-teal-200 dark:border dark:border-teal-400/35",
    characterId: "rashid",
    group: "character",
    description: "旧タグ（気流関連）",
    sortOrder: 905,
  },
};

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
