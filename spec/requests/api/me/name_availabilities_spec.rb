require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Me::NameAvailabilities', type: :request do
  let(:user) { create(:user, name: 'current_user') }

  path '/api/me/name_availability' do
    get 'ユーザー名の利用可否を確認する' do
      tags 'User'
      produces 'application/json'
      parameter name: :name,
                in: :query,
                required: true,
                schema: { type: :string },
                description: '確認するユーザー名'

      response '200', '利用可否を返却' do
        schema type: :object,
               properties: {
                 available: { type: :boolean }
               },
               required: %w[available]

        let(:name) { 'unused_name' }
        before { sign_in user }

        run_test! do
          expect(json_response['available']).to be true
        end
      end

      response '400', 'nameパラメータが未指定' do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               },
               required: %w[errors]

        let(:name) { '' }
        before { sign_in user }

        run_test! do
          expect(json_response['errors']).to include('name is required')
        end
      end

      response '401', '未ログイン' do
        let(:name) { 'any_name' }

        run_test!
      end
    end
  end

  describe 'GET /api/me/name_availability' do
    before { sign_in user }

    context '既に使用されている名前の場合' do
      let!(:other_user) { create(:user, name: 'taken_name') }

      it 'falseを返す' do
        get '/api/me/name_availability', params: { name: 'taken_name' }
        expect(response).to have_http_status(:ok)
        expect(json_response['available']).to be false
      end
    end

    context '自分自身の名前の場合' do
      it 'trueを返す（自分は除外される）' do
        get '/api/me/name_availability', params: { name: 'current_user' }
        expect(response).to have_http_status(:ok)
        expect(json_response['available']).to be true
      end
    end

    context '大文字小文字が異なる場合' do
      let!(:other_user) { create(:user, name: 'TakenName') }

      it 'falseを返す（大文字小文字を区別しない）' do
        get '/api/me/name_availability', params: { name: 'takenname' }
        expect(response).to have_http_status(:ok)
        expect(json_response['available']).to be false
      end
    end

    context 'nameパラメータが未指定の場合' do
      it '400を返す' do
        get '/api/me/name_availability'
        expect(response).to have_http_status(:bad_request)
        expect(json_response['errors']).to include('name is required')
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
