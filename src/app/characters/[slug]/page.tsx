import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { getCharacterBySlug, getSituationsForCharacter } from "@/data/seed";
import {
  buildMoveMap,
  fetchActiveCharacters,
  fetchCharacterBySlug,
  fetchCombosByCharacter,
  fetchGameVersions,
  fetchMovesForCharacter,
} from "@/lib/supabase/queries";
import type { Character, Combo, GameVersion, Move } from "@/types/combo";
import { CharacterComboListClient } from "@/components/CharacterComboListClient";
import { DataErrorBanner } from "@/components/DataErrorBanner";

export const dynamic = "force-dynamic";

interface CharacterPageProps {
  params: Promise<{ slug: string }>;
  searchParams: Promise<{ combo?: string | string[] }>;
}

export async function generateMetadata({
  params,
}: Pick<CharacterPageProps, "params">): Promise<Metadata> {
  const { slug } = await params;
  let character: Character | null = getCharacterBySlug(slug) ?? null;

  if (!character) {
    try {
      character = await fetchCharacterBySlug(slug);
    } catch {
      character = null;
    }
  }

  if (!character) {
    return {
      title: "キャラクターが見つかりません",
    };
  }

  const pageTitle = `${character.nameJa}（${character.nameEn}）のコンボ一覧`;
  const fullTitle = `${pageTitle} | コンボノート`;
  const description = `ストリートファイター6（SF6）${character.nameJa}（${character.nameEn}）のクラシック／モダン両対応コンボ一覧。状況別フィルタ・テンキー／コマンド／技名の3表記ワンタップ切替に対応。`;

  return {
    title: pageTitle,
    description,
    openGraph: {
      type: "website",
      locale: "ja_JP",
      siteName: "コンボノート",
      url: `/characters/${character.slug}`,
      title: fullTitle,
      description,
      images: [
        {
          url: "/og-image.png",
          width: 1200,
          height: 630,
          alt: fullTitle,
        },
      ],
    },
    twitter: {
      card: "summary_large_image",
      title: fullTitle,
      description,
      images: ["/og-image.png"],
    },
  };
}

export default async function CharacterPage({
  params,
  searchParams,
}: CharacterPageProps) {
  const [{ slug }, resolvedSearchParams] = await Promise.all([
    params,
    searchParams,
  ]);
  const initialComboId =
    typeof resolvedSearchParams.combo === "string"
      ? resolvedSearchParams.combo
      : undefined;

  let character: Character | null = null;
  let errorMessage: string | null = null;

  try {
    character = await fetchCharacterBySlug(slug);
  } catch (error) {
    errorMessage =
      error instanceof Error
        ? error.message
        : "データベースからの読み込み中にエラーが発生しました。";
  }

  if (errorMessage) {
    return (
      <DataErrorBanner
        title="キャラクター情報を読み込めませんでした"
        message={errorMessage}
      />
    );
  }

  if (!character) {
    notFound();
  }

  let allCharacters: Character[] = [];
  let combos: Combo[] = [];
  let moves: Move[] = [];
  let versions: GameVersion[] = [];

  try {
    [allCharacters, combos, moves, versions] = await Promise.all([
      fetchActiveCharacters(),
      fetchCombosByCharacter(character.id),
      fetchMovesForCharacter(character.id),
      fetchGameVersions(),
    ]);
  } catch (error) {
    errorMessage =
      error instanceof Error
        ? error.message
        : "データベースからの読み込み中にエラーが発生しました。";
  }

  if (errorMessage) {
    return (
      <DataErrorBanner
        title="コンボ一覧を読み込めませんでした"
        message={errorMessage}
      />
    );
  }

  const moveMap = buildMoveMap(moves);
  const situations = getSituationsForCharacter(character.id);

  return (
    <CharacterComboListClient
      character={character}
      allCharacters={allCharacters}
      combos={combos}
      moveMap={moveMap}
      situations={situations}
      versions={versions}
      initialComboId={initialComboId}
    />
  );
}
