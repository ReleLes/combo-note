<!-- BEGIN:nextjs-agent-rules -->

## This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->

## 厳守ルール（DB保護・機密情報保護・開発方針）

### 1. Supabase データベース保護【最優先・厳禁】
- Supabase 上の既存データ（公開コンボ、テストコンボデータ、ユーザーデータ、技マスタ、管理者テーブル等）の削除・上書き・初期化を禁止する。
- 以下の操作およびコマンドの実行を厳禁とする：
  - `DELETE` / `TRUNCATE` / `DROP` を含む SQL の実行
  - `supabase db reset` などの DB 初期化コマンド
  - `supabase/seed.sql` を含むシードスクリプトの再実行
  - ユーザーの明示的な事前承認なしでのリモート DB へのマイグレーション適用（`supabase db push` 等）
- フロントエンド改修・UI 調整・表示ロジック修正のみの依頼時は、`supabase/` 配下のファイルや DB・SQL に一切触れないこと。
- DB スキーマやマイグレーション変更が本当に必要な場合は、実装前に変更内容と SQL 差分を提示し、ユーザーの承認を得たうえで必ず `--dry-run` 等による事前確認を行うこと。
- Supabase の取得上限（デフォルト 1,000 件）によるデータ欠損を防ぐため、大量レコードを取得する処理では既存の `fetchAllPages()`（`queries.ts`）を維持・活用すること。

### 2. `.env.local`・機密情報の保護【厳禁】
- `.env.local` および `.env*` ファイルの編集・削除・内容の読み上げ（チャットやログへの出力）を禁止する。
- `.env.local` やシークレットキー（`sb_secret_...`、DB パスワード、各種トークン等）をソースコードへ直書きしたり、Git の追跡対象（`git add` / `git commit` / `git push`）に含めたりしないこと。

### 3. リモート運用・Git・実装スコープの安全ルール
- 破壊的な Git 操作（`git push --force`、`git reset --hard`、`git clean -fd` 等）および広範囲のファイル削除（`rm -rf` 等）は実行しないこと。
- 作業は最小限の差分で進め、変更前に対象ファイルと修正方針を簡潔に提示すること。
- 仕様外の機能（SNS フォロー機能、他人のコンボの直接フォーク・コピー機能など）を独断で追加しないこと。

