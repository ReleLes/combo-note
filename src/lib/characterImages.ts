import fs from "node:fs";
import path from "node:path";

const CHARACTER_IMAGE_EXTENSIONS = [".webp", ".png", ".jpg", ".jpeg"] as const;
const CHARACTER_IMAGE_DIR = path.join(
  process.cwd(),
  "public",
  "images",
  "characters"
);

/**
 * サーバー側で `public/images/characters/[slug]` の存在を確認し、
 * 存在する場合は公開パスを返す。未配置の場合は null。
 */
export function resolveCharacterImageUrl(slug: string): string | null {
  if (!/^[a-z0-9-]+$/i.test(slug)) return null;

  for (const ext of CHARACTER_IMAGE_EXTENSIONS) {
    const filePath = path.join(CHARACTER_IMAGE_DIR, `${slug}${ext}`);
    if (fs.existsSync(filePath)) {
      return `/images/characters/${slug}${ext}`;
    }
  }
  return null;
}

/**
 * 複数キャラクター分のモチーフ画像URLマップ（characterId -> imageUrl | null）を生成する。
 */
export function buildCharacterImageMap(
  characters: Array<{ id: string; slug: string }>
): Record<string, string | null> {
  const map: Record<string, string | null> = {};
  for (const character of characters) {
    map[character.id] = resolveCharacterImageUrl(character.slug);
  }
  return map;
}
