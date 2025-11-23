require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Comments', type: :request do
  path '/api/posts/{post_id}/comment' do
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

        response '200', '成功時' do
          schema type: :object,
                 properties: {
                   content: { type: :string },
                   userName: { type: :string },
                   userAvatar: { type: :string }
                 },
                 required: %w[content userName userAvatar]

          run_test! do
            expect(response).to have_http_status(:ok)
            expect(json_response['content']).to eq('Test comment')
            expect(json_response['userName']).to eq(user.name)
            expect(json_response['userAvatar']).to eq(user.avatar_url)
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
