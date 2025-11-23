require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Accounts', type: :request do
  path '/api/accounts' do
    get 'アカウント一覧を取得する' do
      tags 'Account'
      produces 'application/json'

      let!(:users) { create_list(:user, 3) }
      before { sign_in users.first }

      response '200', 'アカウント一覧取得成功' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   name: { type: :string },
                   avatarUrl: { type: :string }
                 },
                 required: %w[name avatarUrl]
               }

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(json_response).to be_an(Array)
          expect(json_response.size).to eq(3)
          expect(json_response.first).to have_key('name')
          expect(json_response.first).to have_key('avatarUrl')
        end
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
