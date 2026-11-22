# 【コンボノート】Antigravity 開発作業指示書（MVP フェーズ1）

- **作成日**: 2026年11月21日
- **対象アプリ**: コンボノート（仮） ― ストリートファイター6（SF6）向けコンボ管理・共有Webアプリ
- **開発手法**: Antigravity を用いたAIバイブコーディング（段階的実装）
- **初期ゴール**: 初期対応4キャラクター（豪鬼、ジュリ、イングリッド、C.ヴァイパー）に対応し、開発者本人と身内が使える形で無料枠（0円）にてWeb公開する

---

## 1. AIエージェント（Antigravity）への開発ルール・前提指示

- 本ドキュメントを「単一の信頼できる情報源（Single Source of Truth）」として実装を進めること。
- 一気に全機能を作らず、セクション7の「段階的実装ロードマップ（Phase 1〜5）」の順に1フェーズずつ実装・動作確認を行うこと。
- 勝手に仕様外の機能（SNS風フォロー機能、複雑な管理画面、他人のコンボのフォーク／コピー機能など）を追加しないこと。
- モバイルファースト（スマホ画面390px前後で崩れず片手でサッと操作できること）かつPCブラウザでも快適に閲覧できるレスポンシブデザインを徹底すること。
- 将来の拡張（全キャラ追加、ログイン時マイノートクラウド同期、技フレームによる嘘コンボ検証、GIF添付）を阻害しない疎結合なデータ構造を維持すること。

---

## 2. 推奨技術スタック（無料枠・0円運用前提）

- **フロントエンド / フルスタック**: Next.js（App Router） + TypeScript
- **スタイリング**: Tailwind CSS + Lucide React（アイコン）
- **バックエンド / DB / 認証**: Supabase（PostgreSQL + Supabase Auth、無料枠）
- **認証方式**: Googleログイン（またはメール＋パスワード。初期導入は設定がシンプルな方を選択し、後から追加可能とする）
- **ブラウザローカル保存**: LocalStorage（マイノート・非公開メモ用）
- **ホスティング**: Vercel（無料枠）
- **補足**: 初期のUI・動作プロトタイプ確認（Phase 1〜2）はモック／シードデータで完結させ、Phase 3以降でSupabaseへ接続する手順を推奨。

---

## 3. UI/UX・デザインガイドライン（案A：シンプル実用メモ風）

### 3-1. トーン＆マナー

- **基本コンセプト**: 「練習中や対戦の合間に、迷わず0.5秒で必要なコンボを見つけられるシンプル＆高視認性の実用メモ」
- **ベース配色（ライトモード基調）**:
  - 背景色: オフホワイト〜ごく薄いグレー（`#F8FAFC` / `bg-slate-50`）
  - カード背景: ピュアホワイト（`#FFFFFF`）＋繊細なボーダー（`#E2E8F0`）＋控えめなシャドウ
  - メイン文字色: ダークスレート（`#0F172A`）、補助文字色: ミディアムグレー（`#64748B`）
  - メインアクセント: 視認性の高いブルー／インディゴ系（`#2563EB`）
- **状況バッジの視認性ルール（最優先事項）**:
  - 各コンボカードの最上部・最も目立つ位置に「どういう状況で使うコンボか」を示す状況バッジを配置する。
  - 状況ごとに直感的な色分けを行う。

| 状況（Situation） | 表示ラベル | スタイル指定（Tailwind） |
| --- | --- | --- |
| 中央・基本 | 中央・基本 | `bg-blue-100 text-blue-700` |
| 画面端 | 画面端 | `bg-amber-100 text-amber-700` |
| DIヒット | DIヒット | `bg-purple-100 text-purple-700` |
| DIガード壁ドン | 壁ドン | `bg-fuchsia-100 text-fuchsia-700` |
| パニッシュカウンター | パニカン | `bg-rose-100 text-rose-700` |
| 対空 | 対空 | `bg-emerald-100 text-emerald-700` |
| スタン | スタン | `bg-yellow-100 text-yellow-800` |
| キャラ固有状態（例：風水エンジン） | 風水エンジン 等 | `bg-pink-100 text-pink-700` |

- キャラ固有の特殊状態やリソース条件（例：ジュリのSA2「風水エンジン」発動中・風破ストックあり等）は、共通状況と同じバッジ領域にキャラ固有バッジとして表示・絞り込み可能とすること。また、風水エンジンのチェーンコンボ等のように技パーツが多くなる長尺コンボでもスマホ幅で崩れず読みやすく折り返されるレイアウトにすること。
- **操作タイプ・表記切り替えの常時アクセス**:
  - 一覧画面の上部に**「クラシック / モダン」切替と「テンキー / コマンドアイコン / 技名」3モード表記切替**を配置し、ワンタップで全カードのレシピ表示がリアルタイムに切り替わること。
  - ユーザーが選択した操作タイプと表記モードはLocalStorageに記憶し、次回アクセス時も引き継ぐこと。

### 3-2. コンボカードの標準レイアウト（1件あたり）

- **ヘッダー行**: 【最重要】状況バッジ（複数可）＋ カテゴリラベル（初心者向け／基本・定番／ネタコン等）＋ マイノート保存ボタン（☆／★）
- **レシピ表示エリア**: 選択中の表記モード（テンキー／コマンドアイコン／技名）で技パーツをチップまたは連結形式で明確に表示（パーツ間は `>` や矢印で区切る）
- **メタ情報バー**: ダメージ数値、消費Dゲージ（視覚的なブロック表現または数値）、消費SAゲージ、キャラ固有ストック増減（消費ストック数／獲得ストック数、該当キャラ・コンボのみ）、起き攻めの有無、投稿バージョン（例: Year 2 / Ver.◯◯）、いいね数
- **補足メモプレビュー**: 1〜2行の要約表示（タップで詳細モーダル／詳細画面を開き、全文の補足メモやコツを確認可能）

---

## 4. 画面一覧と機能仕様（MVP）

### 4-1. トップ／キャラクター選択画面（`/`）

- 登録済みキャラクターをカード形式で一覧表示（初期は数キャラのみ）。
- ヘッダーから「マイノート」「公開コンボを投稿」「ログイン／ログアウト」へアクセス可能。
- キャラ選択後、そのキャラのコンボ一覧画面へ遷移。

### 4-2. キャラクター別コンボ一覧・検索画面（`/characters/[slug]`）

- ログイン不要で閲覧可能。
- **上部コントロールバー**:
  - キャラ切り替えドロップダウン（または戻るリンク）
  - 操作タイプ切替タブ: クラシック / モダン
  - 表記モード切替セグメント: テンキー / コマンド / 技名
- **検索・絞り込み機能**:
  - 状況フィルタチップ（ワンタップで複数選択または単一選択：中央・基本、画面端、DIヒット、DIガード壁ドン、パニッシュカウンター、対空、スタン等）
  - カテゴリフィルタ（すべて／初心者向け／基本・定番／高火力／ネタコン）
  - 詳細条件フィルタ（折りたたみ式）：消費Dゲージ上限、消費SAゲージ（0/1/2/3）、起き攻めありのみ
  - 並び替え：人気順（いいね／保存数）、新着順、ダメージ高い順
- **インタラクション**:
  - カードの「☆」タップでマイノート（LocalStorage）へ保存／解除。
  - いいねボタン（ログイン済みユーザーはDB反映、または未ログイン時の挙動を明確に制御）。
  - カードタップでコンボ詳細モーダル（または詳細ページ）を開き、補足メモ全文・バージョン・作成者名などを確認。

### 4-3. 公開コンボ投稿画面（`/combos/new`）

- ログイン必須（未ログイン時はログインモーダルまたはログインページへ誘導）。
- **入力項目**:
  - 対象キャラクター選択
  - 操作タイプ選択（クラシック / モダン）
  - **技ボタン選択式コンボビルダー**:
    - 選んだキャラ＆操作タイプに応じた技マスタをカテゴリ別タブ（通常技／特殊技／必殺技／SA／投げ／システム〔DR・生ラッシュ・キャンセルラッシュ・DI・前ステ・ディレイ等〕）でボタン表示。
    - ボタンを押すとレシピ列の末尾に追加。1つ戻す・全消去・並び替え（または個別削除）が可能。
    - リアルタイムプレビュー（テンキー／コマンド／技名の3表記すべてを確認できる）。
  - **重複コンボ自動チェック**:
    - 組み立てた技ID配列（正規化ハッシュ）＋キャラ＋操作タイプが既存公開コンボと一致する場合、投稿ボタン付近に「同じレシピが既に登録されています（既存コンボを確認）」と警告を表示する。
  - 状況タグ選択（必須・複数選択可）
  - コンボタイトル（任意・短い見出し）
  - カテゴリ選択（必須：初心者向け／基本・定番／高火力／ネタコン）
  - 数値・属性入力：ダメージ（任意・数値）、消費Dゲージ（0〜6）、消費SAゲージ（0〜3）、起き攻めの有無（あり／なし）
  - 補足メモ欄（必須）: タイミングのコツ、距離限定、起き攻めのフレーム状況などを自由記述。
  - **ゲームバージョン自動付与**:
    - 投稿時の現在日時をもとに `game_versions` マスタから該当バージョンを自動判定し、コンボに紐付けて保存する。

### 4-4. マイノート画面（`/my-note`）

- **ログイン不要・ブラウザ保存（LocalStorage）**で動作。
- キャラクター別タブで整理して表示。
- 各キャラタブ内に以下の2セクション（または切り替えタブ）を配置：
  - **保存した公開コンボ（カンペ一覧）**: お気に入り保存した公開コンボを一覧表示。表記切り替え・状況フィルタも利用可能。解除ボタンあり。
  - **自分用非公開メモ**: 完全に自分のブラウザ内だけに保存されるメモ。
    - 作成・編集・削除が可能。
    - 入力項目：キャラ選択、操作タイプ（任意）、状況タグ（自由選択またはテキスト）、コンボレシピ（自由テキスト入力で手軽に記入可能）、補足メモ欄（必須または標準欄）。
- ブラウザのデータ消去や端末変更に備え、画面下部に「データのJSONエクスポート／インポート」ボタンを補助機能として用意しておくと安心（任意・余力があればMVPに組み込み）。

---

## 5. データモデル・DB設計

### 5-1. Supabase（PostgreSQL）テーブル定義方針

- **キャラ固有パーツ・状態の扱い**:
  - `moves` テーブルの `character_id` にキャラIDを指定し `category = 'system'`（または `unique`）とすることで、特定キャラ専用の補助・派生パーツ（例：ジュリの風水エンジン発動・空中チェーン用のジャンプキャンセル／前J、C.ヴァイパーのフェイント・ハイジャンプキャンセル等）を登録可能とする。
  - `combos.situations` には共通状況キーに加え、キャラ固有状況キー（例：`juri_feng_shui`、`juri_fuha_stock` 等）を格納できるようにし、該当キャラの一覧・投稿画面でのみ選択肢として表示する。

```sql
-- 1. キャラクターマスタ
create table public.characters (
  id text primary key,
  slug text unique not null,
  name_ja text not null,
  name_en text not null,
  sort_order int default 0,
  is_active boolean default true
);

-- 2. 技マスタ
create table public.moves (
  id text primary key,
  character_id text references public.characters(id) on delete cascade,
  control_type text check (control_type in ('classic', 'modern', 'both')),
  category text check (category in ('normal', 'unique', 'special', 'super', 'throw', 'system')),
  notation_numpad text not null,
  notation_command text not null,
  notation_name text not null,
  sort_order int default 0,
  startup_frames int,
  hit_advantage int,
  cancel_types text[]
);

-- 3. バージョンマスタ
create table public.game_versions (
  id text primary key,
  label text not null,
  released_at timestamptz not null
);

-- 4. 公開コンボ
create table public.combos (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references auth.users(id) on delete cascade not null,
  character_id text references public.characters(id) on delete cascade not null,
  control_type text check (control_type in ('classic', 'modern')) not null,
  title text,
  move_ids jsonb not null,
  recipe_signature text not null,
  situations text[] not null,
  category text check (category in ('beginner', 'standard', 'optimal', 'fun')) not null,
  damage int,
  drive_cost numeric(3,1) check (drive_cost >= 0 and drive_cost <= 6),
  sa_cost int check (sa_cost >= 0 and sa_cost <= 3),
  stock_cost int default 0 check (stock_cost >= 0),
  stock_gain int default 0 check (stock_gain >= 0),
  has_oki boolean default false,
  note text not null,
  version_id text references public.game_versions(id) not null,
  likes_count int default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 5. いいね履歴
create table public.combo_likes (
  user_id uuid references auth.users(id) on delete cascade,
  combo_id uuid references public.combos(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (user_id, combo_id)
);
```

### 5-2. LocalStorage スキーマ（ブラウザ保存）

**設定情報 (`combonote_v1_preferences`)**:

```json
{
  "notationMode": "numpad",
  "controlType": "classic"
}
```

**保存済みコンボID一覧 (`combonote_v1_saved_combos`)**:

```json
["combo-uuid-1", "combo-uuid-2"]
```

**非公開メモ (`combonote_v1_private_notes`)**:

```json
[
  {
    "id": "memo-uuid-123",
    "characterId": "ryu",
    "controlType": "classic",
    "situation": "画面端パニカン",
    "recipeText": "2中K > DR > 5大P > 236大P",
    "note": "大インパクト確定時に狙う。引きつけ気味に打つこと。",
    "createdAt": "2026-11-21T10:00:00Z",
    "updatedAt": "2026-11-21T10:00:00Z"
  }
]
```

### 5-3. セキュリティ（Supabase RLS）

- `characters`, `moves`, `game_versions`, `combos`: 全ユーザー（未ログイン含む）に SELECT 許可。
- `combos`: 認証済みユーザー（`auth.uid() = author_id`）のみ INSERT / UPDATE / DELETE 許可。
- `combo_likes`: 認証済みユーザー自身のレコードのみ INSERT / DELETE 許可。

---

## 6. 初期データ（シードデータ）仕様

- **初期対応キャラクター（MVP確定・4体）**:
  - 豪鬼 (`id: "akuma"`, `slug: "akuma"`, `name_en: "Akuma"`)
  - ジュリ (`id: "juri"`, `slug: "juri"`, `name_en: "Juri"`)
  - イングリッド (`id: "ingrid"`, `slug: "ingrid"`, `name_en: "Ingrid"`)
  - C.ヴァイパー (`id: "c-viper"`, `slug: "c-viper"`, `name_en: "C. Viper"`)
- **シードデータ管理方針**:
  - 技マスタおよび初期定番コンボは `src/data/seed/` 配下にキャラクター単位の型安全なJSON／TSファイルとして分離管理し（例：`src/data/seed/characters/juri.ts` 等）、Supabaseへの投入スクリプト（またはSQLシード）を用意する。
  - 後から他キャラクターを追加する際は、同じフォーマットのファイルを追加してシード投入するだけで対応できる構造とする。
- **システム共通パーツ（全キャラ共通で再利用、`character_id: null`）**:
  - DR（キャンセルラッシュ）、生ラッシュ（ドライブラッシュ）、DI（ドライブインパクト）、微歩き、前ステ、ディレイ、J（ジャンプ）、前J（前ジャンプ）、jc（ジャンプキャンセル）
- **キャラ固有の検証観点（MVPシードで意識するポイント）**:
  - ジュリ: SA2「風水エンジン」絡みの多段・長尺コンボレシピを複数登録し、3表記切り替え時の折り返し・視認性や「風水エンジン」状況フィルタの使い勝手を検証する。
  - 豪鬼 / イングリッド / C.ヴァイパー: 通常コンボ・画面端・パニカン・DI系に加え、各キャラ固有のキャンセルや派生ルート（空中派生やキャンセルパーツ等）が技ボタンビルダーでストレスなく組めることを検証する。

---

## 7. 段階的実装ロードマップ（Antigravity 作業ステップ）

Antigravityには以下の順番で1フェーズずつ指示を出し、各フェーズの完了条件を確認してから次へ進むこと。

### Phase 1：プロジェクト初期化＆UIモック構築（DB未接続・ローカル完結）
- Next.js + TypeScript + Tailwind CSS のセットアップ。
- 初期数キャラ分の技マスタ・サンプルコンボのモックデータ作成。
- トップ画面・キャラ別コンボ一覧画面（案Aデザイン）・クラシック／モダン切替・3表記切替・状況フィルタ・詳細モーダルを実装。
- **完了条件**: スマホ幅・PC幅の両方で、状況が一目で分かり、表記切り替えと絞り込みがサクサク動くこと。

### Phase 2：マイノート＆非公開メモ機能（LocalStorage実装）
- コンボカードからのマイノート保存／解除機能。
- マイノート画面（キャラ別タブ、保存済みコンボ一覧、自由テキスト非公開メモのCRUD機能）を実装。
- **完了条件**: ページをリロードしてもマイノートと非公開メモが保持され、キャラ別に整理して閲覧できること。

### Phase 3：Supabase接続・認証・公開コンボ読み書き
- Supabaseプロジェクト作成、テーブル作成（DDL）、RLSポリシー適用、シードデータ投入。
- モックデータ参照をSupabaseからの取得に切り替え。
- ログイン／ログアウト機能（Supabase Auth）の実装。
- いいね機能のDB連携。
- **完了条件**: 未ログインで閲覧＆マイノート利用ができ、ログイン状態の保持が正常に動くこと。

### Phase 4：公開コンボ投稿画面（技ボタンビルダー＆重複チェック）
- 技ボタン選択式ビルダーUI＋3表記リアルタイムプレビューの実装。
- `recipe_signature` による重複コンボ自動チェック＆警告表示の実装。
- 投稿日時からの `game_versions` 自動紐付けと、必須補足メモ欄のバリデーション実装。
- **完了条件**: ログインユーザーがボタン選択だけで公開コンボを投稿でき、重複時に警告が出て、一覧へ即反映されること。

### Phase 5：仕上げ・無料デプロイ（Vercel公開）＆身内テスト
- エラーハンドリング、ローディング表示、スマホ操作感の微調整。
- GitHubリポジトリ連携 → Vercelへデプロイ（環境変数の設定）。
- 身内ユーザーによる実機（スマホ・PC）テストとフィードバック反映。

---

## 8. 将来拡張に向けた設計メモ（フェーズ2以降・今回は実装しない）

- **マイノートのクラウド同期**: LocalStorageのデータ構造をそのままDBテーブル（`user_saved_combos`, `user_private_notes`）へ移行・マージできるキー設計にしておく。
- **嘘コンボ判別（フレーム検証）**: `moves` テーブルの予約カラム（発生・ヒット硬直差・キャンセル属性）にデータを入れ、投稿時に前の技と次の技の繋がりをチェックするバリデーション関数を差し込めるようにしておく。
- **コンボ映像（GIF／短尺動画）**: ストレージコストを抑えるため、初期検討としてはYouTube／X等の外部埋め込みURL、または軽量GIFの外部ストレージ連携を前提に `combos` テーブルへ `media_url` カラムを追加する形を想定。
