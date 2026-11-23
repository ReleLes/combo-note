export interface CharacterVisualTheme {
  /** メインアクセントカラー（ホバー枠・斜めライン等） */
  accent: string;
  /** サブアクセントカラー（グラデーション・ハイライト等） */
  secondary: string;
  /** フォールバック背景の開始色（上側） */
  gradientFrom: string;
  /** フォールバック背景の終了色（下側） */
  gradientTo: string;
  /** ホバー時のグロー影色 */
  glow: string;
  /** 固有タグバッジの半透明背景色 */
  badgeBg: string;
  /** 固有タグバッジの枠線色 */
  badgeBorder: string;
  /** 画像未設定時の透かし英字表記（未指定時は英語名を大文字化） */
  watermark?: string;
}

export const DEFAULT_CHARACTER_THEME: CharacterVisualTheme = {
  accent: "#8B5CF6",
  secondary: "#6366F1",
  gradientFrom: "#2E1065",
  gradientTo: "#130D24",
  glow: "rgba(139, 92, 246, 0.45)",
  badgeBg: "rgba(139, 92, 246, 0.24)",
  badgeBorder: "rgba(167, 139, 250, 0.42)",
};

/**
 * キャラクター slug ごとのビジュアルテーマ定義。
 * 将来キャラクターを追加する際は、ここに slug をキーとして追記するだけで反映されます。
 */
export const CHARACTER_THEMES: Record<string, CharacterVisualTheme> = {
  // 豪鬼：深紅／ダークレッド系
  akuma: {
    accent: "#EF4444",
    secondary: "#DC2626",
    gradientFrom: "#450A0A",
    gradientTo: "#180814",
    glow: "rgba(239, 68, 68, 0.48)",
    badgeBg: "rgba(239, 68, 68, 0.24)",
    badgeBorder: "rgba(248, 113, 113, 0.42)",
    watermark: "AKUMA",
  },
  // ジュリ：マゼンタパープル系
  juri: {
    accent: "#D946EF",
    secondary: "#A855F7",
    gradientFrom: "#4A044E",
    gradientTo: "#1A0B24",
    glow: "rgba(217, 70, 239, 0.48)",
    badgeBg: "rgba(217, 70, 239, 0.24)",
    badgeBorder: "rgba(232, 121, 249, 0.42)",
    watermark: "JURI",
  },
  // イングリッド：シアン／ゴールド系
  ingrid: {
    accent: "#06B6D4",
    secondary: "#F59E0B",
    gradientFrom: "#083344",
    gradientTo: "#17132B",
    glow: "rgba(6, 182, 212, 0.46)",
    badgeBg: "rgba(6, 182, 212, 0.24)",
    badgeBorder: "rgba(34, 211, 238, 0.42)",
    watermark: "INGRID",
  },
  // C.ヴァイパー：クリムゾン／アンバー系
  "c-viper": {
    accent: "#F97316",
    secondary: "#DC2626",
    gradientFrom: "#431407",
    gradientTo: "#1D0F1E",
    glow: "rgba(249, 115, 22, 0.46)",
    badgeBg: "rgba(249, 115, 22, 0.24)",
    badgeBorder: "rgba(251, 146, 60, 0.42)",
    watermark: "C.VIPER",
  },
  // 舞：炎の赤／オレンジ系
  mai: {
    accent: "#FB7185",
    secondary: "#EA580C",
    gradientFrom: "#4C0519",
    gradientTo: "#1F0E18",
    glow: "rgba(251, 113, 133, 0.48)",
    badgeBg: "rgba(251, 113, 133, 0.24)",
    badgeBorder: "rgba(253, 164, 175, 0.42)",
    watermark: "MAI",
  },
  // リュウ：精悍なロイヤルブルー／電刃シアン系
  ryu: {
    accent: "#38BDF8",
    secondary: "#2563EB",
    gradientFrom: "#0C2D57",
    gradientTo: "#121024",
    glow: "rgba(56, 189, 248, 0.48)",
    badgeBg: "rgba(56, 189, 248, 0.24)",
    badgeBorder: "rgba(125, 211, 252, 0.45)",
    watermark: "RYU",
  },
  // ケン：炎のクリムゾン／ゴールドオレンジ系
  ken: {
    accent: "#EF4444",
    secondary: "#F59E0B",
    gradientFrom: "#4C0519",
    gradientTo: "#1F1014",
    glow: "rgba(239, 68, 68, 0.48)",
    badgeBg: "rgba(239, 68, 68, 0.24)",
    badgeBorder: "rgba(245, 158, 11, 0.45)",
    watermark: "KEN",
  },
  // ルーク：コバルトブルー／イエロー系
  luke: {
    accent: "#3B82F6",
    secondary: "#FACC15",
    gradientFrom: "#0C2A5A",
    gradientTo: "#11162B",
    glow: "rgba(59, 130, 246, 0.48)",
    badgeBg: "rgba(59, 130, 246, 0.24)",
    badgeBorder: "rgba(250, 204, 21, 0.45)",
    watermark: "LUKE",
  },
  // キャミィ：エメラルドグリーン／レッド系
  cammy: {
    accent: "#10B981",
    secondary: "#EF4444",
    gradientFrom: "#064E3B",
    gradientTo: "#121826",
    glow: "rgba(16, 185, 129, 0.48)",
    badgeBg: "rgba(16, 185, 129, 0.24)",
    badgeBorder: "rgba(239, 68, 68, 0.45)",
    watermark: "CAMMY",
  },
  // 春麗：シアンブルー／ロイヤルゴールド系
  "chun-li": {
    accent: "#0EA5E9",
    secondary: "#EAB308",
    gradientFrom: "#0C4A6E",
    gradientTo: "#14122B",
    glow: "rgba(14, 165, 233, 0.48)",
    badgeBg: "rgba(14, 165, 233, 0.24)",
    badgeBorder: "rgba(234, 179, 8, 0.45)",
    watermark: "CHUN-LI",
  },
  // ガイル：ミリタリーオリーブグリーン／アンバーゴールド系
  guile: {
    accent: "#84CC16",
    secondary: "#F59E0B",
    gradientFrom: "#1A2E05",
    gradientTo: "#141914",
    glow: "rgba(132, 204, 22, 0.48)",
    badgeBg: "rgba(132, 204, 22, 0.24)",
    badgeBorder: "rgba(245, 158, 11, 0.45)",
    watermark: "GUILE",
  },
  // ザンギエフ：バーミリオンレッド／ブロンズゴールド系
  zangief: {
    accent: "#DC2626",
    secondary: "#D97706",
    gradientFrom: "#450A0A",
    gradientTo: "#1C120E",
    glow: "rgba(220, 38, 38, 0.48)",
    badgeBg: "rgba(220, 38, 38, 0.24)",
    badgeBorder: "rgba(217, 119, 6, 0.45)",
    watermark: "ZANGIEF",
  },
};

export function getCharacterTheme(slug: string): CharacterVisualTheme {
  return CHARACTER_THEMES[slug] ?? DEFAULT_CHARACTER_THEME;
}

/**
 * 漢字表記や表記揺れのあるキャラクター向け検索補助（読み仮名・通称）。
 * 新規キャラクターを追加する際は必要に応じて追記する。
 */
export const CHARACTER_SEARCH_READINGS: Readonly<Record<string, string[]>> = {
  akuma: ["ごうき", "ゴウキ", "gouki", "あくま"],
  juri: ["じゅり"],
  ingrid: ["いんぐりっど"],
  "c-viper": [
    "ばいぱー",
    "ゔぁいぱー",
    "しーばいぱー",
    "cviper",
    "くりむぞんばいぱー",
  ],
  mai: ["まい", "マイ", "しらぬいまい", "不知火舞"],
  ryu: ["りゅう", "りゅー"],
  ken: ["けん"],
  luke: ["るーく"],
  cammy: ["きゃみぃ", "きゃみー", "キャミー"],
  "chun-li": ["ちゅんりー", "チュンリー", "ちゅんり", "chunli"],
  guile: ["がいる"],
  zangief: ["ざんぎえふ", "ざんぎ"],
};

/**
 * キャラクター検索用に文字列を正規化する：
 * - NFKC 正規化＆小文字化
 * - ひらがな → カタカナ変換
 * - ヴァ/ヴィ/ヴ/ヴェ/ヴォ → バ/ビ/ブ/ベ/ボ 統一（例: 「ばいぱー」で「C.ヴァイパー」にヒット）
 */
export function normalizeCharacterSearchText(input: string): string {
  return input
    .normalize("NFKC")
    .toLowerCase()
    .trim()
    .replace(/[\u3041-\u3096]/g, (ch) =>
      String.fromCharCode(ch.charCodeAt(0) + 0x60)
    )
    .replace(/ヴァ/g, "バ")
    .replace(/ヴィ/g, "ビ")
    .replace(/ヴェ/g, "ベ")
    .replace(/ヴォ/g, "ボ")
    .replace(/ヴ/g, "ブ");
}

function stripSearchSeparators(normalized: string): string {
  return normalized.replace(/[\s.\-・_]/g, "");
}

/**
 * キャラクターが検索クエリに部分一致するか判定する。
 * `nameJa` / `nameEn` / `slug` / 読み仮名補助マップを大文字小文字・かな揺れ無視で照合する。
 */
export function matchesCharacterSearch(
  character: { id: string; slug: string; nameJa: string; nameEn: string },
  rawQuery: string
): boolean {
  const normalizedQuery = normalizeCharacterSearchText(rawQuery);
  if (!normalizedQuery) return true;

  const compactQuery = stripSearchSeparators(normalizedQuery);
  const readings =
    CHARACTER_SEARCH_READINGS[character.slug] ??
    CHARACTER_SEARCH_READINGS[character.id] ??
    [];

  const candidates = [
    character.nameJa,
    character.nameEn,
    character.slug,
    character.id,
    ...readings,
  ];

  return candidates.some((candidate) => {
    const normalized = normalizeCharacterSearchText(candidate);
    if (normalized.includes(normalizedQuery)) return true;
    if (compactQuery && stripSearchSeparators(normalized).includes(compactQuery)) {
      return true;
    }
    return false;
  });
}
