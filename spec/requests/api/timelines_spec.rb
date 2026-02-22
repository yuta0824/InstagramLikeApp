require 'rails_helper'
require 'swagger_helper'
require 'support/post_schema_helper'

RSpec.describe 'Api::Timelines', type: :request do
  path '/api/timeline' do
    get 'タイムラインを取得する' do
      tags 'Timeline'
      produces 'application/json'
      parameter name: :cursor, in: :query, type: :string, required: false,
                description: '前回取得した最後の投稿のID'

      let(:user) { create(:user) }
      let(:followed_user) { create(:user) }

      response '200', 'タイムライン取得成功' do
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

        let!(:post_item) { create(:post, user: followed_user) }

        before do
          create(:relationship, follower: user, following: followed_user)
          sign_in user
        end

        run_test!
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
    end
  end

  describe 'タイムライン取得' do
    let(:user) { create(:user) }
    let(:followed_user) { create(:user) }

    before do
      create(:relationship, follower: user, following: followed_user)
      sign_in user
    end

    context 'フォロー中ユーザーと自分の投稿' do
      let!(:followed_post) { create(:post, user: followed_user) }
      let!(:own_post) { create(:post, user: user) }
      let!(:unfollowed_post) { create(:post) }

      it 'フォロー中と自分の投稿のみ含まれる' do
        get '/api/timeline'
        ids = json_response['posts'].map { |p| p['id'] }
        expect(ids).to include(followed_post.id, own_post.id)
        expect(ids).not_to include(unfollowed_post.id)
      end
    end

    context 'フォローなし・自分の投稿もない場合' do
      let(:no_follow_user) { create(:user) }
      let!(:other_post) { create(:post) }

      before { sign_in no_follow_user }

      it '空配列を返す' do
        get '/api/timeline'
        expect(json_response['posts']).to eq([])
        expect(json_response['hasMore']).to be false
        expect(json_response['nextCursor']).to be_nil
      end
    end

    context '投稿の順序' do
      let!(:old_post) { create(:post, user: followed_user) }
      let!(:new_post) { create(:post, user: followed_user) }

      it '新しい投稿が先に並ぶ' do
        get '/api/timeline'
        ids = json_response['posts'].map { |p| p['id'] }
        expect(ids).to eq([new_post.id, old_post.id])
      end
    end

    context '複数ユーザーをフォローしている場合' do
      let(:another_user) { create(:user) }
      let!(:post_a) { create(:post, user: followed_user) }
      let!(:post_b) { create(:post, user: another_user) }
      let!(:post_c) { create(:post, user: followed_user) }

      before { create(:relationship, follower: user, following: another_user) }

      it '全フォローユーザーの投稿がID降順で返る' do
        get '/api/timeline'
        ids = json_response['posts'].map { |p| p['id'] }
        expect(ids).to eq([post_c.id, post_b.id, post_a.id])
      end
    end
  end

  describe 'カーソルベースページネーション' do
    let(:user) { create(:user) }
    let(:followed_user) { create(:user) }

    before do
      create(:relationship, follower: user, following: followed_user)
      sign_in user
    end

    context 'cursorが指定された場合' do
      let!(:older_post) { create(:post, user: followed_user) }
      let!(:newer_post) { create(:post, user: followed_user) }

      it 'cursorより前の投稿のみ返る' do
        get '/api/timeline', params: { cursor: newer_post.id.to_s }
        ids = json_response['posts'].map { |p| p['id'] }
        expect(ids).to include(older_post.id)
        expect(ids).not_to include(newer_post.id)
      end
    end

    context '21件の場合' do
      let!(:posts) { create_list(:post, 21, user: followed_user) }

      it 'hasMoreがtrueで20件返り、nextCursorが最後の投稿IDになる' do
        get '/api/timeline'
        returned_posts = json_response['posts']
        expect(returned_posts.size).to eq(20)
        expect(json_response['hasMore']).to be true
        expect(json_response['nextCursor']).to eq(returned_posts.last['id'].to_s)
      end
    end

    context 'ちょうど20件の場合' do
      let!(:posts) { create_list(:post, 20, user: followed_user) }

      it 'hasMoreがfalseでnextCursorがnilになる' do
        get '/api/timeline'
        expect(json_response['posts'].size).to eq(20)
        expect(json_response['hasMore']).to be false
        expect(json_response['nextCursor']).to be_nil
      end
    end

    context 'nextCursorで2ページ目を取得した場合' do
      let!(:posts) { create_list(:post, 25, user: followed_user) }

      it '重複・欠落がない' do
        get '/api/timeline'
        page1_ids = json_response['posts'].map { |p| p['id'] }
        next_cursor = json_response['nextCursor']

        get '/api/timeline', params: { cursor: next_cursor }
        page2_ids = json_response['posts'].map { |p| p['id'] }

        expect(page1_ids.size).to eq(20)
        expect(page2_ids.size).to eq(5)
        expect(page1_ids & page2_ids).to be_empty
        all_ids = followed_user.posts.pluck(:id).sort.reverse
        expect(page1_ids + page2_ids).to eq(all_ids)
      end
    end

    context '不正なcursor値の場合' do
      it '非数値文字列で400を返す' do
        get '/api/timeline', params: { cursor: 'abc' }
        expect(response).to have_http_status(:bad_request)
        expect(json_response['errors']).to be_present
      end

      it '0で400を返す' do
        get '/api/timeline', params: { cursor: '0' }
        expect(response).to have_http_status(:bad_request)
      end

      it '負数で400を返す' do
        get '/api/timeline', params: { cursor: '-1' }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
