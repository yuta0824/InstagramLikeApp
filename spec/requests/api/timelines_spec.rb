require 'rails_helper'
require 'swagger_helper'
require 'support/post_schema_helper'

RSpec.describe 'Api::Timelines', type: :request do
  path '/api/timeline' do
    get 'タイムラインを取得する' do
      tags 'Timeline'
      produces 'application/json'

      let(:user) { create(:user) }

      response '200', '取得成功' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: POST_LIST_PROPERTIES,
                 required: POST_LIST_REQUIRED
               }

        context 'フォロー中ユーザーと自分の投稿が返る' do
          let(:followed_user) { create(:user) }
          let!(:followed_post) { create(:post, user: followed_user) }
          let!(:own_post) { create(:post, user: user) }
          let!(:unfollowed_post) { create(:post) }

          before do
            create(:relationship, follower: user, following: followed_user)
            sign_in user
          end

          run_test! do
            ids = json_response.map { |p| p['id'] }
            expect(ids).to include(followed_post.id, own_post.id)
            expect(ids).not_to include(unfollowed_post.id)
          end
        end

        context 'フォローなし・自分の投稿もない場合は空配列' do
          let!(:other_post) { create(:post) }

          before { sign_in user }

          run_test! do
            expect(json_response).to eq([])
          end
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
