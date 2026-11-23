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
  // ベガ：サイコパープル／クリムゾンレッド系
  vega: {
    accent: "#A855F7",
    secondary: "#E11D48",
    gradientFrom: "#3B0764",
    gradientTo: "#1F0A1D",
    glow: "rgba(168, 85, 247, 0.50)",
    badgeBg: "rgba(168, 85, 247, 0.24)",
    badgeBorder: "rgba(225, 29, 72, 0.45)",
    watermark: "M.BISON",
  },
  // JP：ディープバイオレット／ロイヤルゴールド系
  jp: {
    accent: "#7C3AED",
    secondary: "#EAB308",
    gradientFrom: "#2E1065",
    gradientTo: "#141026",
    glow: "rgba(124, 58, 237, 0.50)",
    badgeBg: "rgba(124, 58, 237, 0.24)",
    badgeBorder: "rgba(234, 179, 8, 0.45)",
    watermark: "JP",
  },
  // エド：ネオンバイオレット／エレクトリックシアン系
  ed: {
    accent: "#8B5CF6",
    secondary: "#22D3EE",
    gradientFrom: "#2E1065",
    gradientTo: "#0F172A",
    glow: "rgba(139, 92, 246, 0.50)",
    badgeBg: "rgba(139, 92, 246, 0.24)",
    badgeBorder: "rgba(34, 211, 238, 0.45)",
    watermark: "ED",
  },
  // テリー：ヒーローレッド／ロイヤルブルー系
  terry: {
    accent: "#EF4444",
    secondary: "#3B82F6",
    gradientFrom: "#450A0A",
    gradientTo: "#172554",
    glow: "rgba(239, 68, 68, 0.50)",
    badgeBg: "rgba(239, 68, 68, 0.24)",
    badgeBorder: "rgba(59, 130, 246, 0.45)",
    watermark: "TERRY",
  },
  // サガット：帝王ゴールド／バーミリオンレッド系
  sagat: {
    accent: "#F59E0B",
    secondary: "#DC2626",
    gradientFrom: "#451A03",
    gradientTo: "#270A0A",
    glow: "rgba(245, 158, 11, 0.50)",
    badgeBg: "rgba(245, 158, 11, 0.24)",
    badgeBorder: "rgba(220, 38, 38, 0.45)",
    watermark: "SAGAT",
  },
  // ディージェイ：トロピカルライム／サンセットオレンジ系
  deejay: {
    accent: "#84CC16",
    secondary: "#F97316",
    gradientFrom: "#1A2E05",
    gradientTo: "#2B1408",
    glow: "rgba(132, 204, 22, 0.50)",
    badgeBg: "rgba(132, 204, 22, 0.24)",
    badgeBorder: "rgba(249, 115, 22, 0.45)",
    watermark: "DEE JAY",
  },
  // ラシード：ターコイズ／サンゴールド系
  rashid: {
    accent: "#14B8A6",
    secondary: "#F59E0B",
    gradientFrom: "#042F2E",
    gradientTo: "#1E1B2E",
    glow: "rgba(20, 184, 166, 0.50)",
    badgeBg: "rgba(20, 184, 166, 0.24)",
    badgeBorder: "rgba(245, 158, 11, 0.45)",
    watermark: "RASHID",
  },
  // A.K.I.：毒パープル／アシッドグリーン系
  aki: {
    accent: "#A855F7",
    secondary: "#84CC16",
    gradientFrom: "#2E1065",
    gradientTo: "#132018",
    glow: "rgba(168, 85, 247, 0.50)",
    badgeBg: "rgba(168, 85, 247, 0.24)",
    badgeBorder: "rgba(132, 204, 22, 0.45)",
    watermark: "A.K.I.",
  },
  // エレナ：サバンナエメラルド／サンセットゴールド系
  elena: {
    accent: "#10B981",
    secondary: "#F59E0B",
    gradientFrom: "#064E3B",
    gradientTo: "#291A08",
    glow: "rgba(16, 185, 129, 0.50)",
    badgeBg: "rgba(16, 185, 129, 0.24)",
    badgeBorder: "rgba(245, 158, 11, 0.45)",
    watermark: "ELENA",
  },
  // アレックス：ファイターレッド／ミリタリーグリーン系
  alex: {
    accent: "#EF4444",
    secondary: "#65A30D",
    gradientFrom: "#450A0A",
    gradientTo: "#1A2E05",
    glow: "rgba(239, 68, 68, 0.50)",
    badgeBg: "rgba(239, 68, 68, 0.24)",
    badgeBorder: "rgba(101, 163, 13, 0.45)",
    watermark: "ALEX",
  },
  // ヤスミン：アクアブルー／サンパギータゴールド系
  yasmine: {
    accent: "#0EA5E9",
    secondary: "#FDE047",
    gradientFrom: "#0C4A6E",
    gradientTo: "#1E1B4B",
    glow: "rgba(14, 165, 233, 0.50)",
    badgeBg: "rgba(14, 165, 233, 0.24)",
    badgeBorder: "rgba(253, 224, 71, 0.45)",
    watermark: "YASMINE",
  },
  // アルジュン：アンバーブロンズ／インディゴスレート系
  arjun: {
    accent: "#F97316",
    secondary: "#6366F1",
    gradientFrom: "#431407",
    gradientTo: "#1E1B4B",
    glow: "rgba(249, 115, 22, 0.50)",
    badgeBg: "rgba(249, 115, 22, 0.24)",
    badgeBorder: "rgba(99, 102, 241, 0.45)",
    watermark: "ARJUN",
  },
  // ジェイミー：ゴールデンアンバー／深紅系
  jamie: {
    accent: "#F59E0B",
    secondary: "#DC2626",
    gradientFrom: "#451A03",
    gradientTo: "#290C12",
    glow: "rgba(245, 158, 11, 0.50)",
    badgeBg: "rgba(245, 158, 11, 0.24)",
    badgeBorder: "rgba(220, 38, 38, 0.45)",
    watermark: "JAMIE",
  },
  // キンバリー：ネオンピンク／シアン系
  kimberly: {
    accent: "#EC4899",
    secondary: "#06B6D4",
    gradientFrom: "#500724",
    gradientTo: "#083344",
    glow: "rgba(236, 72, 153, 0.50)",
    badgeBg: "rgba(236, 72, 153, 0.24)",
    badgeBorder: "rgba(6, 182, 212, 0.45)",
    watermark: "KIMBERLY",
  },
  // マリーザ：ローマンゴールド／深紅系
  marisa: {
    accent: "#EAB308",
    secondary: "#DC2626",
    gradientFrom: "#422006",
    gradientTo: "#3B0A0A",
    glow: "rgba(234, 179, 8, 0.50)",
    badgeBg: "rgba(234, 179, 8, 0.24)",
    badgeBorder: "rgba(220, 38, 38, 0.45)",
    watermark: "MARISA",
  },
  // マノン：パリジャンローズピンク／ロイヤルネイビー系
  manon: {
    accent: "#F43F5E",
    secondary: "#6366F1",
    gradientFrom: "#4C0519",
    gradientTo: "#172554",
    glow: "rgba(244, 63, 94, 0.50)",
    badgeBg: "rgba(244, 63, 94, 0.24)",
    badgeBorder: "rgba(99, 102, 241, 0.45)",
    watermark: "MANON",
  },
  // ブランカ：エレクトリックグリーン／サンダーイエロー系
  blanka: {
    accent: "#22C55E",
    secondary: "#FACC15",
    gradientFrom: "#052E16",
    gradientTo: "#29250A",
    glow: "rgba(34, 197, 94, 0.50)",
    badgeBg: "rgba(34, 197, 94, 0.24)",
    badgeBorder: "rgba(250, 204, 21, 0.45)",
    watermark: "BLANKA",
  },
  // エドモンド本田：歌舞伎クリムゾン／藍ブルー系
  ehonda: {
    accent: "#E11D48",
    secondary: "#3B82F6",
    gradientFrom: "#4C0519",
    gradientTo: "#0F172A",
    glow: "rgba(225, 29, 72, 0.50)",
    badgeBg: "rgba(225, 29, 72, 0.24)",
    badgeBorder: "rgba(59, 130, 246, 0.45)",
    watermark: "E.HONDA",
  },
  // ダルシム：サフランオレンジ／ターコイズ系
  dhalsim: {
    accent: "#F97316",
    secondary: "#14B8A6",
    gradientFrom: "#431407",
    gradientTo: "#042F2E",
    glow: "rgba(249, 115, 22, 0.50)",
    badgeBg: "rgba(249, 115, 22, 0.24)",
    badgeBorder: "rgba(20, 184, 166, 0.45)",
    watermark: "DHALSIM",
  },
  // リリー：ウィンドエメラルド／スカイブルー系
  lily: {
    accent: "#10B981",
    secondary: "#38BDF8",
    gradientFrom: "#064E3B",
    gradientTo: "#0C4A6E",
    glow: "rgba(16, 185, 129, 0.50)",
    badgeBg: "rgba(16, 185, 129, 0.24)",
    badgeBorder: "rgba(56, 189, 248, 0.45)",
    watermark: "LILY",
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
  vega: ["べが", "ばいそん", "m.bison", "mbison", "bison", "ベガ"],
  jp: ["じぇいぴー", "じぇーぴー", "じぇいぴ", "ジェイピー", "ジェーピー"],
  ed: ["えど", "エド"],
  terry: ["てりー", "てりーぼがーど", "テリーボガード", "terrybogard"],
  sagat: ["さがっと", "サガット"],
  deejay: ["でぃーじぇい", "でぃーじぇー", "dj", "ディージェー"],
  rashid: ["らしーど", "ラシード"],
  aki: ["あき", "アキ", "a.k.i.", "a.k.i", "aki"],
  elena: ["えれな", "エレナ"],
  alex: ["あれっくす", "アレックス", "あれくす"],
  yasmine: ["やすみん", "ヤスミン", "yasmin", "yasmine"],
  arjun: ["あるじゅん", "アルジュン", "arjun"],
  jamie: ["じぇいみー", "じぇーみー", "ジェイミー"],
  kimberly: ["きんばりー", "キンバリー"],
  marisa: ["まりーざ", "マリーザ"],
  manon: ["まのん", "マノン"],
  blanka: ["ぶらんか", "ブランカ"],
  ehonda: ["ほんだ", "ホンダ", "えどもんどほんだ", "エドモンドホンダ", "e.honda", "honda"],
  dhalsim: ["だるしむ", "ダルシム"],
  lily: ["りりー", "リリー"],
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
