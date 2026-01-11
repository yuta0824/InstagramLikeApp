require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Me', type: :request do
  let(:user) { create(:user) }

  path '/api/me' do
    get 'ログイン中ユーザーを取得する' do
      tags 'User'
      produces 'application/json'

      response '200', '取得成功' do
        schema type: :object,
               properties: {
                 name: { type: :string },
                 avatarUrl: { type: :string, nullable: true }
               },
               required: %w[name avatarUrl]

        before { sign_in user }

        run_test!
      end

      response '401', '未ログイン' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        run_test!
      end
    end

    patch 'ユーザー情報を更新する' do
      tags 'User'
      consumes 'multipart/form-data'
      produces 'application/json'
      parameter name: :name,
                in: :formData,
                required: false,
                schema: { type: :string }
      parameter name: :avatar,
                in: :formData,
                required: false,
                schema: { type: :string, format: :binary }

      response '200', '更新成功' do
        schema type: :object,
               properties: {
                 name: { type: :string },
                 avatarUrl: { type: :string, nullable: true }
               },
               required: %w[name avatarUrl]

        let(:name) { 'updated_name' }
        let(:avatar) { fixture_file_upload('test.jpg', 'image/jpeg') }
        before { sign_in user }

        run_test!
      end

      response '401', '未ログイン' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        let(:name) { 'updated_name' }

        run_test!
      end
    end
  end
end
