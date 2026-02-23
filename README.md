# InstagramLikeApp

Instagram風のSNSアプリケーション。写真投稿・いいね・コメント・フォロー・通知など、SNSの主要機能をフルスタックで実装したポートフォリオ作品です。

**本番環境**: https://instagram-like-front-end.vercel.app/

## 主な機能と使用技術

| 機能                       | 詳細                                      | 主な技術                                          |
| -------------------------- | ----------------------------------------- | ------------------------------------------------- |
| **認証**                   | Google OAuth2 ログイン / JWT トークン認証 | devise, devise-jwt, omniauth-google-oauth2, Redis |
| **投稿**                   | 画像付き投稿の CRUD（1〜3枚）             | ActiveStorage, Amazon S3, CloudFront              |
| **タイムライン**           | フォロー中ユーザーの投稿フィード          | Cursor Pagination                                 |
| **いいね**                 | 投稿へのいいね / 取り消し                 |                                                   |
| **コメント**               | 投稿へのコメント / 削除                   |                                                   |
| **フォロー**               | ユーザーのフォロー / フォロワー管理       | 自己参照リレーション                              |
| **通知**                   | いいね・コメント・フォローの通知          | 同一投稿のいいね通知を自動集約（JSONB）           |
| **ユーザー検索**           | 名前によるユーザー検索                    |                                                   |
| **ボットシミュレーション** | 新規投稿に自動でいいね・コメント付与      | SimulatorService                                  |
| **API ドキュメント**       | OpenAPI 仕様書の自動生成                  | rswag, Swagger UI                                 |

## 技術スタック

### バックエンド（このリポジトリ）

| カテゴリ     | 技術                                          |
| ------------ | --------------------------------------------- |
| 言語 / FW    | Ruby 3.3.2 / Rails 7.2（API モード）          |
| DB           | PostgreSQL 16                                 |
| KVS          | Redis 7（認証コード・キャッシュ）             |
| ストレージ   | Amazon S3 + CloudFront                        |
| 認証         | Google OAuth2 → JWT（devise-jwt）             |
| シリアライザ | ActiveModelSerializers（自動 camelCase 変換） |
| テスト       | RSpec, FactoryBot, Faker                      |
| Lint         | RuboCop                                       |
| CI/CD        | GitHub Actions（Lint → Test → Swagger 生成）  |
| インフラ     | Docker（開発）/ Heroku（本番）                |

### フロントエンド（[別リポジトリ](https://github.com/yuta0824/InstagramLikeFrontEnd)）

| カテゴリ       | 技術                                                     |
| -------------- | -------------------------------------------------------- |
| フレームワーク | Next.js 16（App Router）/ React 19 / TypeScript 5        |
| スタイリング   | Tailwind CSS v4 / shadcn/ui（Radix UI）                  |
| 状態管理       | TanStack React Query v5 / Jotai v2                       |
| フォーム       | React Hook Form + Zod                                    |
| API連携        | OpenAPI Generator による型安全なHTTPクライアント自動生成 |
| テスト・品質   | ESLint / Prettier / Storybook / Chromatic                |
| デプロイ       | Vercel                                                   |

## アーキテクチャ

### 全体構成

```
[Frontend (Vercel)]  ←── swagger.yaml(API契約) ──→  [Backend API (Heroku)]
        │                                                    │
        │  JWT Bearer Token                                  ├── PostgreSQL
        │  JSON (camelCase)                                  ├── Redis
        └────────────────────────────────────────────────────├── Amazon S3
                                                             └── CloudFront
```

### FE / BE の責務分離

```
┌─────────────────────────────────┐     ┌──────────────────────────────┐
│  Frontend (Next.js)             │     │  Backend (Rails API)         │
│                                 │     │                              │
│  ・UIの描画                　     │────▶│  ・ビジネスロジック             │
│  ・UX目的のバリデーション           │◀────│  ・データバリデーション          │
│  ・状態管理（表示用）     　        │     │  ・認証・認可                  │
│                                 │     │  ・OpenAPI仕様の管理           │
└─────────────────────────────────┘     └──────────────────────────────┘
         ▲                                         ▲
         │    OpenAPI仕様（唯一の契約）               │
         └─────────────────────────────────────────┘
```

### 設計のポイント

- **API-only Rails**: フロントエンドと完全分離。`swagger.yaml` をAPI仕様の契約として連携
- **JWT 認証**: ステートレスな認証でスケーラビリティを確保。ログアウト時は JWT を Denylist に追加
- **カーソルベースページネーション**: 無限スクロールに最適化。タイムライン・投稿・フォロワー一覧で統一
- **通知の集約**: 同一投稿への複数いいねを1通知に集約し、JSONB で最新アクター情報を管理
- **Service 層**: ボットシミュレーション等のビジネスロジックをコントローラから分離

## リポジトリ

|                | リンク                                                                              |
| -------------- | ----------------------------------------------------------------------------------- |
| バックエンド   | [yuta0824/InstagramLikeApp](https://github.com/yuta0824/InstagramLikeApp)           |
| フロントエンド | [yuta0824/InstagramLikeFrontEnd](https://github.com/yuta0824/InstagramLikeFrontEnd) |
| 本番環境       | [instagram-like-front-end.vercel.app](https://instagram-like-front-end.vercel.app/) |
