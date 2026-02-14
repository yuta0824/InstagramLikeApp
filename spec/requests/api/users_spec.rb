require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Users', type: :request do
  path '/api/users' do
    get 'ユーザー一覧を取得する' do
      tags 'User'
      produces 'application/json'
      parameter name: :q, in: :query, type: :string, required: false, description: '名前で検索'

      let!(:users) { create_list(:user, 3) }
      before { sign_in users.first }

      response '200', 'ユーザー一覧取得成功' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   name: { type: :string },
                   avatarUrl: { type: :string, nullable: true }
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

      response '200', '新しい順にソートされる' do
        run_test! do
          names = json_response.map { |u| u['name'] }
          expected = User.order(created_at: :desc).limit(100).pluck(:name)
          expect(names).to eq(expected)
        end
      end

      response '200', 'qパラメータで名前を検索できる' do
        let!(:target_user) { create(:user, name: 'SearchTarget') }
        let(:q) { 'SearchTarget' }

        run_test! do
          expect(json_response.size).to eq(1)
          expect(json_response.first['name']).to eq('SearchTarget')
        end
      end

      response '200', 'qパラメータの部分一致検索' do
        let!(:target_user) { create(:user, name: 'TestUser123') }
        let(:q) { 'TestUser' }

        run_test! do
          names = json_response.map { |u| u['name'] }
          expect(names).to include('TestUser123')
        end
      end

      response '200', '大文字小文字を区別せず検索できる' do
        let!(:target_user) { create(:user, name: 'MyName') }
        let(:q) { 'myname' }

        run_test! do
          names = json_response.map { |u| u['name'] }
          expect(names).to include('MyName')
        end
      end

      response '200', '最大100件まで取得できる' do
        let!(:many_users) { create_list(:user, 105) }

        run_test! do
          expect(json_response.size).to be <= 100
        end
      end

      response '200', '検索結果が0件の場合は空配列を返す' do
        let(:q) { 'NonExistentUser' }

        run_test! do
          expect(json_response).to eq([])
        end
      end

      response '200', 'パスワードやメールアドレスが含まれない' do
        run_test! do
          json_response.each do |user|
            expect(user.keys).not_to include('email', 'encryptedPassword', 'password')
          end
        end
      end

    end

    get '未ログインではアクセスできない' do
      tags 'User'
      produces 'application/json'

      response '401', '未ログイン' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        run_test!
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
