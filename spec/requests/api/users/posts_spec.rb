require 'rails_helper'
require 'swagger_helper'
require 'support/post_schema_helper'

RSpec.describe 'Api::Users::Posts', type: :request do
  path '/api/users/{user_id}/posts' do
    parameter name: :user_id, in: :path, required: true, schema: { type: :integer }

    get '特定ユーザーの投稿一覧を取得する' do
      tags 'User Post'
      produces 'application/json'
      parameter name: :page, in: :query, required: false, schema: { type: :integer }

      let(:user) { create(:user) }
      let(:target_user) { create(:user) }
      let(:user_id) { target_user.id }

      response '200', '取得成功' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: POST_DETAIL_PROPERTIES,
                 required: POST_DETAIL_REQUIRED
               }

        let!(:target_posts) { create_list(:post, 3, user: target_user) }
        let!(:other_posts) { create_list(:post, 2) }

        before { sign_in user }

        run_test! do
          expect(json_response.size).to eq(3)
          returned_ids = json_response.map { |p| p['id'] }
          expect(returned_ids).to match_array(target_posts.map(&:id))
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

      response '404', '存在しないユーザー' do
        let(:user_id) { 999_999 }

        before { sign_in user }

        run_test!
      end
    end
  end

  describe 'ページネーション' do
    let(:user) { create(:user) }
    let(:target_user) { create(:user) }

    before { sign_in user }

    context '25件の投稿がある場合' do
      let!(:posts) { create_list(:post, 25, user: target_user) }

      it '1ページ目は20件を返す' do
        get "/api/users/#{target_user.id}/posts", params: { page: 1 }
        expect(json_response.size).to eq(20)
      end

      it '2ページ目は残り5件を返す' do
        get "/api/users/#{target_user.id}/posts", params: { page: 2 }
        expect(json_response.size).to eq(5)
      end

      it '3ページ目は空配列を返す' do
        get "/api/users/#{target_user.id}/posts", params: { page: 3 }
        expect(json_response.size).to eq(0)
      end
    end

    context '並び順' do
      let!(:old_post) { create(:post, user: target_user, created_at: 2.days.ago) }
      let!(:new_post) { create(:post, user: target_user, created_at: 1.hour.ago) }

      it '新しい投稿が先に返る' do
        get "/api/users/#{target_user.id}/posts"
        expect(json_response.first['id']).to eq(new_post.id)
        expect(json_response.last['id']).to eq(old_post.id)
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
