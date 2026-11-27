export type SourceUrlPlatform = "youtube" | "x";

export interface SourceUrlValidationResult {
  isValid: boolean;
  /** 有効な場合は正規化済みURL、空欄時は null、不正時は null */
  normalizedUrl: string | null;
  /** 判定されたプラットフォーム（空欄・不正時は null） */
  platform: SourceUrlPlatform | null;
  /** 不正時のユーザー向け日本語エラーメッセージ（有効時は null） */
  error: string | null;
}

const MAX_SOURCE_URL_LENGTH = 2048;

const ALLOWED_PROTOCOLS: ReadonlySet<string> = new Set(["http:", "https:"]);

const YOUTUBE_HOSTNAMES: ReadonlySet<string> = new Set([
  "youtube.com",
  "www.youtube.com",
  "m.youtube.com",
  "youtu.be",
]);

const X_HOSTNAMES: ReadonlySet<string> = new Set([
  "x.com",
  "www.x.com",
  "twitter.com",
  "www.twitter.com",
  "mobile.twitter.com",
]);

export const SOURCE_URL_PLATFORM_ERROR =
  "YouTube または X（旧Twitter）のURLのみ登録できます。";

/**
 * 参考動画・投稿URL（source_url）のバリデーション・正規化を行う共通関数。
 *
 * - 空欄（null / undefined / 空白のみ）は有効とし、`normalizedUrl: null` を返す。
 * - プロトコルは `http:` / `https:` のみ許可（`javascript:` 等は拒否）。
 * - ホスト名は YouTube / X（旧Twitter）の許可リストに厳格限定する（大文字小文字無視）。
 * - `?t=` / `&t=` などのタイムスタンプ付きURLもそのまま許可する。
 */
export function validateSourceUrl(
  input: string | null | undefined
): SourceUrlValidationResult {
  if (input == null) {
    return {
      isValid: true,
      normalizedUrl: null,
      platform: null,
      error: null,
    };
  }

  const trimmed = input.trim();
  if (trimmed === "") {
    return {
      isValid: true,
      normalizedUrl: null,
      platform: null,
      error: null,
    };
  }

  if (trimmed.length > MAX_SOURCE_URL_LENGTH) {
    return {
      isValid: false,
      normalizedUrl: null,
      platform: null,
      error: `URLは${MAX_SOURCE_URL_LENGTH}文字以内で入力してください。`,
    };
  }

  let parsed: URL;
  try {
    parsed = new URL(trimmed);
  } catch {
    return {
      isValid: false,
      normalizedUrl: null,
      platform: null,
      error:
        "有効なURL形式で入力してください（例: https://youtu.be/... または https://x.com/...）。",
    };
  }

  const protocol = parsed.protocol.toLowerCase();
  if (!ALLOWED_PROTOCOLS.has(protocol)) {
    return {
      isValid: false,
      normalizedUrl: null,
      platform: null,
      error: "http:// または https:// で始まるURLのみ登録できます。",
    };
  }

  if (parsed.username || parsed.password || parsed.port !== "") {
    return {
      isValid: false,
      normalizedUrl: null,
      platform: null,
      error: SOURCE_URL_PLATFORM_ERROR,
    };
  }

  const hostname = parsed.hostname.toLowerCase();
  let platform: SourceUrlPlatform | null = null;
  if (YOUTUBE_HOSTNAMES.has(hostname)) {
    platform = "youtube";
  } else if (X_HOSTNAMES.has(hostname)) {
    platform = "x";
  }

  if (!platform) {
    return {
      isValid: false,
      normalizedUrl: null,
      platform: null,
      error: SOURCE_URL_PLATFORM_ERROR,
    };
  }

  return {
    isValid: true,
    normalizedUrl: parsed.toString(),
    platform,
    error: null,
  };
}

/**
 * 入力URLが許可されたプラットフォーム（YouTube / X）として有効な場合のみ
 * 正規化済みURLとプラットフォーム種別を返すヘルパー。
 */
export function getSafeSourceUrl(
  input: string | null | undefined
): { url: string; platform: SourceUrlPlatform } | null {
  const result = validateSourceUrl(input);
  if (!result.isValid || !result.normalizedUrl || !result.platform) {
    return null;
  }
  return {
    url: result.normalizedUrl,
    platform: result.platform,
  };
}
