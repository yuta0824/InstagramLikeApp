require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'User Token Exchange API', type: :request do
  let!(:user) { create(:user) }
  let(:redis_store) { {} }
  let(:redis) { double('redis') }

  before do
    allow(redis).to receive(:get) { |key| redis_store[key] }
    allow(redis).to receive(:del) { |key| redis_store.delete(key) }
    allow(Rails.application.config.x).to receive(:redis).and_return(redis)
  end

  path '/api/auth/token' do
    get '認可コードからJWTを取得する' do
      tags 'Auth'
      produces 'application/json'
      parameter name: :auth_code, in: :query, required: true, schema: { type: :string }

      response '200', '取得成功' do
        schema type: :object,
               properties: {
                 jwt: { type: :string },
                 exp: { type: :integer }
               },
               required: %w[jwt exp]

        let(:auth_code) { 'valid-auth-code' }

        before do
          redis_store["auth_code:#{auth_code}"] = user.id.to_s
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['jwt']).to be_present
          expect(data['exp']).to be_present
        end
      end

      response '401', '認可コードが無効' do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               },
               required: %w[errors]

        let(:auth_code) { 'invalid-auth-code' }

        run_test! do
          expect(json_response['errors']).to be_present
        end
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
