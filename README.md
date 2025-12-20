# InstagramLikeApp

## 開発環境の起動

### 1. ビルドと起動

```bash
$ docker-compose build
$ docker-compose up
```

### 2. Rails コンテナに入る

```bash
$ docker-compose exec rails bash
```

### 3. 開発用 DB 構築

```bash
$ bin/rails db:create
$ bin/rails db:migrate
$ bin/rails db:seed
```

### 4. RSpec テスト用 DB 構築

```bash
$ RAILS_ENV=test bin/rails db:create
$ RAILS_ENV=test bin/rails db:migrate
```

### 5. 動作確認

以上の作業完了後 `http://localhost:3030` で動作確認可能

## その他、コンテナ内の汎用コマンド

### Rubocop 構文チェック

```bash
$ bundle exec rubocop --auto-correct
```

### RSpec テスト

```bash
$ RAILS_ENV=test bundle exec rspec # 全テスト
$ RAILS_ENV=test bundle exec rspec spec/models # モデルテスト
$ RAILS_ENV=test bundle exec rspec spec/requests # API テスト
```

### OpenAPI(swagger) 生成

```bash
$ RAILS_ENV=test bundle exec rake rswag:specs:swaggerize
```
