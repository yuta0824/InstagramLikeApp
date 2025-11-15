require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Likes', type: :request do
  let(:post_owner) { create(:user) }
  let(:target_post) { create(:post, user: post_owner) }
  let(:liker) { create(:user) }

  path '/api/posts/{post_id}/like' do
    parameter name: :post_id, in: :path, required: true, schema: { type: :integer }

    post 'いいねを作成する' do
      tags 'Like'
      consumes 'application/json'
      produces 'application/json'

      let(:post_id) { target_post.id }

      response '200', 'いいね完了' do
        schema type: :object,
               properties: {
                 isLiked: { type: :boolean }
               },
               required: %w[isLiked]

        before { sign_in liker }

        run_test! do
          expect(target_post.reload.likes.exists?(user: liker)).to be true
          expect(json_response['isLiked']).to eq(true)
        end
      end

      response '401', '未ログイン' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        run_test! do
          expect(response).to have_http_status(:unauthorized)
          expect(json_response['error']).to be_present
        end
      end
    end

    delete 'いいねを削除する' do
      tags 'Like'
      produces 'application/json'

      let(:post_id) { target_post.id }

      response '200', 'いいね解除' do
        schema type: :object,
               properties: {
                 isLiked: { type: :boolean }
               },
               required: %w[isLiked]

        before do
          create(:like, user: liker, post: target_post)
          sign_in liker
        end

        run_test! do
          expect(target_post.reload.likes.exists?(user: liker)).to be false
          expect(json_response['isLiked']).to eq(false)
        end
      end

      response '401', '未ログイン' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        before do
          create(:like, user: liker, post: target_post)
        end

        run_test! do
          expect(response).to have_http_status(:unauthorized)
          expect(json_response['error']).to be_present
        end
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
