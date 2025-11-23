require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Me::Avatars', type: :request do
  let!(:user) { create(:user) }

  path '/api/me/avatar' do
    patch 'アバター画像を更新する' do
      tags 'User'
      consumes 'multipart/form-data'
      produces 'application/json'
      parameter name: :avatar,
                in: :formData,
                required: true,
                schema: { type: :string, format: :binary }

      let(:avatar) { fixture_file_upload('test.jpg', 'image/jpeg') }
      before { sign_in user }

      response '200', '作成に成功' do
        schema type: :object,
               properties: {
                 avatar_url: { type: :string },
               },
               required: %w[avatar_url]

        run_test! do |response|
          expect(response.status).to eq(200)
          user.reload; expect(user.avatar).to be_attached
        end
      end
    end
  end
end
