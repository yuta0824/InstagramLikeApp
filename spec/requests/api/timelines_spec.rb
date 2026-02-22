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

      response '200', 'フォロー中ユーザーと自分の投稿が返る' do
        let(:followed_user) { create(:user) }
        let!(:followed_post) { create(:post, user: followed_user) }
        let!(:own_post) { create(:post, user: user) }
        let!(:unfollowed_post) { create(:post) }

        before do
          create(:relationship, follower: user, following: followed_user)
          sign_in user
        end

        run_test! do
          posts = json_response['posts']
          ids = posts.map { |p| p['id'] }
          expect(ids).to include(followed_post.id, own_post.id)
          expect(ids).not_to include(unfollowed_post.id)
        end
      end

      response '200', 'フォローなし・自分の投稿もない場合は空配列' do
        let!(:other_post) { create(:post) }

        before { sign_in user }

        run_test! do
          expect(json_response['posts']).to eq([])
          expect(json_response['hasMore']).to be false
          expect(json_response['nextCursor']).to be_nil
        end
      end

      response '200', '新しい投稿が先に並ぶ' do
        let(:followed_user) { create(:user) }
        let!(:old_post) { create(:post, user: followed_user) }
        let!(:new_post) { create(:post, user: followed_user) }

        before do
          create(:relationship, follower: user, following: followed_user)
          sign_in user
        end

        run_test! do
          ids = json_response['posts'].map { |p| p['id'] }
          expect(ids).to eq([new_post.id, old_post.id])
        end
      end

      response '200', 'cursorより前の投稿のみ返る' do
        let(:followed_user) { create(:user) }
        let!(:older_post) { create(:post, user: followed_user) }
        let!(:newer_post) { create(:post, user: followed_user) }
        let(:cursor) { newer_post.id.to_s }

        before do
          create(:relationship, follower: user, following: followed_user)
          sign_in user
        end

        run_test! do
          ids = json_response['posts'].map { |p| p['id'] }
          expect(ids).to include(older_post.id)
          expect(ids).not_to include(newer_post.id)
        end
      end

      response '200', 'nextCursorが最後の投稿のIDを返す' do
        let(:followed_user) { create(:user) }
        let!(:posts) { create_list(:post, 21, user: followed_user) }

        before do
          create(:relationship, follower: user, following: followed_user)
          sign_in user
        end

        run_test! do
          returned_posts = json_response['posts']
          expect(json_response['nextCursor']).to eq(returned_posts.last['id'].to_s)
        end
      end

      response '200', 'nextCursorで2ページ目を取得すると重複・欠落がない' do
        let(:followed_user) { create(:user) }
        let!(:posts) { create_list(:post, 25, user: followed_user) }

        before do
          create(:relationship, follower: user, following: followed_user)
          sign_in user
        end

        run_test! do
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

      response '200', 'ちょうど20件の場合はhasMoreがfalseになる' do
        let(:followed_user) { create(:user) }
        let!(:posts) { create_list(:post, 20, user: followed_user) }

        before do
          create(:relationship, follower: user, following: followed_user)
          sign_in user
        end

        run_test! do
          expect(json_response['posts'].size).to eq(20)
          expect(json_response['hasMore']).to be false
          expect(json_response['nextCursor']).to be_nil
        end
      end

      response '200', '21件の場合はhasMoreがtrueで20件返る' do
        let(:followed_user) { create(:user) }
        let!(:posts) { create_list(:post, 21, user: followed_user) }

        before do
          create(:relationship, follower: user, following: followed_user)
          sign_in user
        end

        run_test! do
          expect(json_response['posts'].size).to eq(20)
          expect(json_response['hasMore']).to be true
          expect(json_response['nextCursor']).to be_present
        end
      end

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
               required: %w[posts hasMore]

        let(:followed_user) { create(:user) }
        let!(:post_item) { create(:post, user: followed_user) }

        before do
          create(:relationship, follower: user, following: followed_user)
          sign_in user
        end

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(json_response).to have_key('posts')
          expect(json_response).to have_key('hasMore')
          expect(json_response).to have_key('nextCursor')
          expect(json_response['posts']).to be_an(Array)
        end
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

  def json_response
    JSON.parse(response.body)
  end
end
