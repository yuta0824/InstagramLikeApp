require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Guest Session API', type: :request do
  path '/api/auth/guest_session' do
    post 'ゲストログインする' do
      tags 'Auth'
      produces 'application/json'

      response '201', 'ゲストユーザー作成・JWT発行' do
        schema type: :object,
               properties: {
                 jwt: { type: :string },
                 exp: { type: :integer }
               },
               required: %w[jwt exp]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['jwt']).to be_present
          expect(data['exp']).to be_present
        end
      end
    end
  end

  describe '機能テスト' do
    it '毎回異なるゲストユーザーが作成される' do
      post '/api/auth/guest_session'
      first_jwt = JSON.parse(response.body)['jwt']

      post '/api/auth/guest_session'
      second_jwt = JSON.parse(response.body)['jwt']

      expect(first_jwt).not_to eq(second_jwt)
      expect(User.guests.count).to eq(2)
    end

    it 'ゲストユーザーのnameが規約に準拠している' do
      post '/api/auth/guest_session'
      guest = User.guests.last
      expect(guest.name).to match(/\Aguest_[a-f0-9]{8}\z/)
      expect(guest.name.length).to be <= 20
    end
  end
end
