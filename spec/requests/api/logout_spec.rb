require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'User Logout API', type: :request do
  let(:user) { create(:user) }

  path '/api/users/logout' do
    delete 'ログアウトする' do
      tags 'User'
      produces 'application/json'
      parameter name: 'Authorization',
                in: :header,
                required: true,
                schema: { type: :string, example: 'Bearer <jwt>' }

      response '204', 'ログアウト成功' do
        let(:jwt) do
          token, = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
          token
        end

        let(:'Authorization') { "Bearer #{jwt}" }

        run_test!
      end

      response '401', '未ログイン' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:'Authorization') { nil }

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
