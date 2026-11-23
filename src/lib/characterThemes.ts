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
};

export function getCharacterTheme(slug: string): CharacterVisualTheme {
  return CHARACTER_THEMES[slug] ?? DEFAULT_CHARACTER_THEME;
}
