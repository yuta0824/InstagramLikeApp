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

  describe '異常系' do
    let(:user) { create(:user) }

    context 'POST /api/posts/:post_id/like 既にいいね済みの場合' do
      let(:target) { create(:post) }
      before do
        create(:like, user: user, post: target)
        sign_in user
      end

      it '422を返す' do
        post "/api/posts/#{target.id}/like", as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'DELETE /api/posts/:post_id/like 未いいね状態で解除しようとした場合' do
      let(:target) { create(:post) }
      before { sign_in user }

      it '404を返す' do
        delete "/api/posts/#{target.id}/like"
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'POST /api/posts/:post_id/like 存在しないpost_idの場合' do
      before { sign_in user }

      it '404を返す' do
        post '/api/posts/999999/like', as: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
