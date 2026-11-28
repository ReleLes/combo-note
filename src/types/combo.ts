export type ControlType = "classic" | "modern";

export type MoveControlType = "classic" | "modern" | "both";

export type MoveCategory =
  | "normal"
  | "unique"
  | "special"
  | "super"
  | "throw"
  | "system";

export type NotationMode = "numpad" | "command" | "name";

export type ComboCategory = "beginner" | "standard" | "optimal" | "fun";

export type CommonSituationKey =
  | "midscreen"
  | "corner"
  | "di_hit"
  | "di_wall_splat"
  | "counter"
  | "punish_counter"
  | "anti_air"
  | "stun"
  | "lethal"
  | "corner_carry"
  | "drive_recovery"
  | "burnout"
  | "setplay";

export type CharacterSituationKey =
  | "juri_feng_shui"
  | "juri_fuha_stock"
  | "juri_fuha_gain"
  | "c_viper_feint"
  | "ingrid_sun_install"
  | "ingrid_sun_symbol"
  | "ingrid_sun_symbol_gain"
  | "mai_flame_stock"
  | "mai_flame_gain"
  | "ryu_denjin"
  | "ryu_denjin_gain"
  | "guile_solid_puncher"
  | "vega_mine_plant"
  | "vega_mine_detonate"
  | "rashid_air_set"
  | "rashid_air_boost"
  | "aki_poison_inflict"
  | "aki_poison_state"
  | "alex_back_turned"
  | "yasmine_bayani"
  | "yasmine_nakatagong_lakas"
  | "arjun_giant_rock"
  | "jamie_drink_lv1"
  | "jamie_drink_lv2"
  | "jamie_drink_lv3"
  | "jamie_drink_lv4"
  | "jamie_drink_gain"
  | "kimberly_shuriken"
  | "kimberly_shuriken_gain"
  | "manon_medal_gain"
  | "blanka_lightning_beast"
  | "ehonda_sumo_spirit"
  | "ehonda_sumo_spirit_gain"
  | "lily_windclad"
  | "lily_windclad_gain";

export type LegacySituationKey =
  | "jamie_drink_level"
  | "manon_medal"
  | "aki_poison"
  | "vega_psycho_mine"
  | "rashid_air_current";

export type SituationKey =
  | CommonSituationKey
  | CharacterSituationKey
  | (string & {});

/**
 * 状況タグの表示グループ区分：
 * - "basic": 基本状況（位置・始動条件）
 * - "purpose": 実戦目的・状態（リーサル、運び、Dゲージ回復、自分BO中）
 * - "character": キャラクター固有状況
 */
export type SituationGroup = "basic" | "purpose" | "character";

export interface SituationDefinition {
  key: SituationKey;
  label: string;
  badgeClassName: string;
  /** null の場合は全キャラ共通状況。キャラID指定時はそのキャラ固有状況 */
  characterId: string | null;
  /** UI側でグルーピング表示するための区分 */
  group: SituationGroup;
  /** タグの用途・意味の説明（任意） */
  description?: string;
  sortOrder: number;
}

export interface ComboCategoryDefinition {
  key: ComboCategory;
  label: string;
  sortOrder: number;
}

export interface CharacterStockMeta {
  label: string;
  shortLabel: string;
  maxCount: number;
  /** 獲得数として選べる値（未指定時は 0..maxCount すべて） */
  gainOptions?: number[];
  /** 獲得数の補足説明（投稿フォームに表示） */
  gainHint?: string;
}

export interface Character {
  id: string;
  slug: string;
  nameJa: string;
  nameEn: string;
  sortOrder: number;
  isActive: boolean;
  stockMeta?: CharacterStockMeta;
}

export interface Move {
  id: string;
  /** null の場合は全キャラ共通のシステムパーツ */
  characterId: string | null;
  controlType: MoveControlType;
  category: MoveCategory;
  notationNumpad: string;
  notationCommand: string;
  notationName: string;
  sortOrder: number;
  /** 将来拡張（フレーム検証用） */
  startupFrames?: number | null;
  hitAdvantage?: number | null;
  cancelTypes?: string[] | null;
}

export interface GameVersion {
  id: string;
  label: string;
  releasedAt: string;
}

export interface Combo {
  id: string;
  authorId: string;
  authorName?: string;
  characterId: string;
  controlType: ControlType;
  /** コンボの任意タイトル（未設定時は null / undefined） */
  title?: string | null;
  moveIds: string[];
  recipeSignature: string;
  situations: SituationKey[];
  category: ComboCategory;
  damage: number | null;
  driveCost: number;
  saCost: 0 | 1 | 2 | 3;
  /** 消費するキャラ固有ストック数 */
  stockCost?: number;
  /** このコンボで獲得できるキャラ固有ストック数 */
  stockGain?: number;
  hasOki: boolean;
  note: string;
  /** 参考動画・投稿URL（YouTube / X のみ許可、未設定時は null / undefined） */
  sourceUrl?: string | null;
  versionId: string;
  likesCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface CharacterSeedData {
  moves: Move[];
  combos: Combo[];
}

/** LocalStorage: combonote_v1_preferences */
export interface UserPreferences {
  notationMode: NotationMode;
  controlType: ControlType;
}

/** LocalStorage: combonote_v1_private_notes */
export interface PrivateNote {
  id: string;
  characterId: string;
  controlType?: ControlType;
  situation: string;
  recipeText: string;
  /** 技ボタン選択で組み立てた場合の技ID配列（任意・3表記切替に対応） */
  moveIds?: string[];
  note: string;
  createdAt: string;
  updatedAt: string;
}
