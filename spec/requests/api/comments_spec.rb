require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Comments', type: :request do
  path '/api/posts/{post_id}/comments' do
    parameter name: :post_id, in: :path, required: true, schema: { type: :integer }

    post 'コメントを保存できる' do
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

    delete 'コメントを削除できる' do
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

  def json_response
    JSON.parse(response.body)
  end
end
