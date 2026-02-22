require 'rails_helper'
require 'swagger_helper'
require 'support/post_schema_helper'

RSpec.describe 'Api::Users::Posts', type: :request do
  path '/api/users/{user_id}/posts' do
    parameter name: :user_id, in: :path, required: true, schema: { type: :integer }

    get '特定ユーザーの投稿一覧を取得する' do
      tags 'User Post'
      produces 'application/json'
      parameter name: :cursor, in: :query, type: :string, required: false,
                description: '前回取得した最後の投稿のID'

      let(:user) { create(:user) }
      let(:target_user) { create(:user) }
      let(:user_id) { target_user.id }

      response '200', '取得成功' do
        schema type: :object,
               properties: {
                 posts: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: POST_LIST_PROPERTIES,
                     required: POST_LIST_REQUIRED
                   }
                 },
                 nextCursor: { type: :string, nullable: true },
                 hasMore: { type: :boolean }
               },
               required: %w[posts nextCursor hasMore]

        let!(:target_posts) { create_list(:post, 3, user: target_user) }
        let!(:other_posts) { create_list(:post, 2) }

        before { sign_in user }

        run_test! do
          expect(json_response['posts'].size).to eq(3)
          returned_ids = json_response['posts'].map { |p| p['id'] }
          expect(returned_ids).to match_array(target_posts.map(&:id))
        end
      end

      response '400', 'cursorが不正' do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               },
               required: %w[errors]

        let(:cursor) { 'invalid' }

        before { sign_in user }

        run_test!
      end

      response '401', '未ログイン' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        run_test!
      end

      response '404', '存在しないユーザー' do
        let(:user_id) { 999_999 }

        before { sign_in user }

        run_test!
      end
    end
  end

  describe 'カーソルベースページネーション' do
    let(:user) { create(:user) }
    let(:target_user) { create(:user) }

    before { sign_in user }

    context '21件の投稿がある場合' do
      let!(:posts) { create_list(:post, 21, user: target_user) }

      it 'hasMoreがtrueで20件返り、nextCursorが最後の投稿IDになる' do
        get "/api/users/#{target_user.id}/posts"
        returned_posts = json_response['posts']
        expect(returned_posts.size).to eq(20)
        expect(json_response['hasMore']).to be true
        expect(json_response['nextCursor']).to eq(returned_posts.last['id'].to_s)
      end
    end

    context 'ちょうど20件の場合' do
      let!(:posts) { create_list(:post, 20, user: target_user) }

      it 'hasMoreがfalseでnextCursorがnilになる' do
        get "/api/users/#{target_user.id}/posts"
        expect(json_response['posts'].size).to eq(20)
        expect(json_response['hasMore']).to be false
        expect(json_response['nextCursor']).to be_nil
      end
    end

    context 'nextCursorで2ページ目を取得した場合' do
      let!(:posts) { create_list(:post, 25, user: target_user) }

      it '重複・欠落がない' do
        get "/api/users/#{target_user.id}/posts"
        page1_ids = json_response['posts'].map { |p| p['id'] }
        next_cursor = json_response['nextCursor']

        get "/api/users/#{target_user.id}/posts", params: { cursor: next_cursor }
        page2_ids = json_response['posts'].map { |p| p['id'] }

        expect(page1_ids.size).to eq(20)
        expect(page2_ids.size).to eq(5)
        expect(page1_ids & page2_ids).to be_empty
        all_ids = target_user.posts.pluck(:id).sort.reverse
        expect(page1_ids + page2_ids).to eq(all_ids)
      end
    end

    context '不正なcursor値の場合' do
      it '非数値文字列で400を返す' do
        get "/api/users/#{target_user.id}/posts", params: { cursor: 'abc' }
        expect(response).to have_http_status(:bad_request)
        expect(json_response['errors']).to be_present
      end

      it '0で400を返す' do
        get "/api/users/#{target_user.id}/posts", params: { cursor: '0' }
        expect(response).to have_http_status(:bad_request)
      end

      it '負数で400を返す' do
        get "/api/users/#{target_user.id}/posts", params: { cursor: '-1' }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'レスポンスフィールド検証' do
    let(:user) { create(:user) }
    let(:target_user) { create(:user) }

    before { sign_in user }

    context '他ユーザーの投稿を閲覧した場合' do
      let!(:post) { create(:post, user: target_user) }

      it 'isOwn が false を返す' do
        get "/api/users/#{target_user.id}/posts"
        expect(json_response['posts'].first['isOwn']).to be false
      end
    end

    context '自分の投稿を閲覧した場合' do
      let!(:post) { create(:post, user: user) }

      it 'isOwn が true を返す' do
        get "/api/users/#{user.id}/posts"
        expect(json_response['posts'].first['isOwn']).to be true
      end
    end

    context 'いいね済みの投稿がある場合' do
      let!(:post) { create(:post, user: target_user) }

      before { create(:like, user: user, post: post) }

      it 'isLiked が true で likedCount が正しい値を返す' do
        get "/api/users/#{target_user.id}/posts"
        expect(json_response['posts'].first['isLiked']).to be true
        expect(json_response['posts'].first['likedCount']).to eq(1)
      end
    end

    context '一覧レスポンスの形式' do
      let!(:post) { create(:post, user: target_user) }

      before { create_list(:comment, 2, post: post) }

      it 'commentsCount が正しい値を返し comments キーが含まれない' do
        get "/api/users/#{target_user.id}/posts"
        expect(json_response['posts'].first['commentsCount']).to eq(2)
        expect(json_response['posts'].first).not_to have_key('comments')
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
