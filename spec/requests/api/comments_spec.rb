require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Comments', type: :request do
  path '/api/posts/{post_id}/comments' do
    parameter name: :post_id, in: :path, required: true, schema: { type: :integer }

    post 'コメントを作成する' do
      tags 'Comment'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :comment, in: :body, schema: {
        type: :object,
        properties: {
          comment: {
            type: :object,
            properties: {
              content: { type: :string }
            },
            required: %w[content]
          }
        },
        required: %w[comment]
      }

      let!(:user) { create(:user) }
      let!(:target_post) { create(:post) }
      let(:post_id) { target_post.id }
      let(:comment) { { content: 'Test comment' } }

      context '認証済みユーザー' do
        before { sign_in user }

        response '201', '作成成功' do
          schema type: :object,
                 properties: {
                   id: { type: :integer },
                   content: { type: :string },
                 },
                 required: %w[id content]

          run_test! do
            expect(response).to have_http_status(:created)
            expect(json_response['content']).to eq('Test comment')
          end
        end
      end

      context '未ログイン' do
        response '401', '未認証' do
          run_test! do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end
  end

  path '/api/posts/{post_id}/comments/{id}' do
    parameter name: :post_id, in: :path, required: true, schema: { type: :integer }
    parameter name: :id, in: :path, required: true, schema: { type: :integer }

    delete 'コメントを削除する' do
      tags 'Comment'
      produces 'application/json'

      let!(:user) { create(:user) }
      let!(:target_post) { create(:post) }
      let!(:comment) { create(:comment, user: user, post: target_post) }
      let(:post_id) { target_post.id }
      let(:id) { comment.id }

      context '認証済みユーザー' do
        before { sign_in user }

        response '204', '削除成功' do
          run_test! do
            expect(Comment.exists?(comment.id)).to be false
            expect(response).to have_http_status(:no_content)
          end
        end
      end

      context '未ログイン' do
        response '401', '未認証' do
          run_test! do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end
  end

  describe '認可・バリデーション' do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:target_post) { create(:post) }

    context 'DELETE /api/posts/:post_id/comments/:id 他人のコメントを削除しようとした場合' do
      let!(:others_comment) { create(:comment, user: other_user, post: target_post) }

      before { sign_in user }

      it '404を返す' do
        expect {
          delete "/api/posts/#{target_post.id}/comments/#{others_comment.id}"
        }.not_to change(Comment, :count)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'POST /api/posts/:post_id/comments 存在しないpost_idの場合' do
      before { sign_in user }

      it '404を返す' do
        post '/api/posts/999999/comments', params: { comment: { content: 'test' } }, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'POST /api/posts/:post_id/comments 空のcontentの場合' do
      before { sign_in user }

      it '422を返す' do
        post "/api/posts/#{target_post.id}/comments", params: { comment: { content: '' } }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
