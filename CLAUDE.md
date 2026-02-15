# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイダンスを提供します。

## 開発環境

APIのみのRailsアプリ。フロントエンドは別リポジトリで、`swagger/swagger.yaml` をAPI仕様の契約として連携している。

Docker ベース。アプリは **localhost:3030** で動作する（デフォルトの3000ではない）。

```bash
docker-compose build && docker-compose up
docker-compose exec rails bash   # コンテナ内でコマンド実行
```

## コマンド（コンテナ内で実行）

```bash
# テスト（RAILS_ENV=test が必要）
RAILS_ENV=test bundle exec rspec
RAILS_ENV=test bundle exec rspec spec/models
RAILS_ENV=test bundle exec rspec spec/requests
RAILS_ENV=test bundle exec rspec spec/requests/api/posts_spec.rb:42  # 行番号指定

# Lint
bundle exec rubocop --auto-correct

# OpenAPI（swagger）再生成（RAILS_ENV=test + rake）
RAILS_ENV=test bundle exec rake rswag:specs:swaggerize
```

実装完了後、コミット前に必ず以下を実行すること:
1. `bundle exec annotate --models`（モデルやマイグレーションに変更がある場合）
2. `bundle exec rubocop --auto-correct`
3. `RAILS_ENV=test bundle exec rake rswag:specs:swaggerize`（APIに変更がある場合）

## Git ルール

- **mainブランチでの作業禁止**: 必ずfeatureブランチを作成して作業すること
- **git push は実行しない**: push はユーザーが手動で行う
- **大きな変更はコミットを分割する**: 1コミットにまとめず、レビューしやすい論理単位で分ける

## コミットメッセージ

- Conventional Commits形式: `fix:`, `feat:`, `refactor:`, `chore:` 等のプレフィックスを使用
- 日本語で簡潔に（1行目は50文字以内目安）
- 変更点だけでなく変更理由も記載

## コード規約

- コントローラはRESTfulな標準7アクション（index/show/create/update/destroy/new/edit）のみ。収まらない場合はコントローラを分割する
- 責務を適切に分離する。コントローラはHTTP関心事のみ、レスポンス整形はシリアライザ、複数の関心事を協調させるユースケースはサービスクラス（`app/services/`）に切り出す
- enumはRails標準の `enum` ではなく `enumerize` gemを使用する
- 文字列はシングルクォート（RuboCopで強制）
- N+1防止のため eager loading を使用（`Post.with_details` など）
- APIレスポンスのキーはActiveModelSerializersにより自動でcamelCaseに変換される（`is_liked` → `isLiked`）。シリアライザやテストで手動変換しないこと
- エラーレスポンス形式: `{ errors: [...] }` + 適切なHTTPステータス
- シリアライザは `scope` として `current_user` を受け取り、`is_liked`・`is_own` 等を算出する

## 認証フロー

全コントローラはデフォルトで認証必須（`before_action :authenticate_user!`）。認証系のみスキップ。

1. `GET /api/auth/login?service=google` → Google OAuthへリダイレクト
2. コールバックでユーザー作成/検索、`auth_code` をRedisに保存（TTL 60秒）
3. `GET /api/auth/token?auth_code=XXX` → AuthorizationヘッダーでJWT返却
4. `DELETE /api/auth/logout` → JWTをJwtDenylistに追加

## テスト

requestスペックでは `sign_in user` で認証。FactoryBotでデータ生成。画像は `fixture_file_upload` を使用。

rswagのメタデータ（`tags`、`summary`、`description`）はそのまま `swagger.yaml` に反映される。FEとの契約なので、既存specの記述スタイルに合わせて簡潔かつ正確に書くこと。
