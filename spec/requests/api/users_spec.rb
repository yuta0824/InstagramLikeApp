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

      response '200', 'フォロー中ユーザーのisFollowingがtrueになる' do
        before { users.first.follow!(users.second) }

        run_test! do
          followed_user = json_response.find { |u| u['name'] == users.second.name }
          unfollowed_user = json_response.find { |u| u['name'] == users.third.name }
          expect(followed_user['isFollowing']).to be true
          expect(unfollowed_user['isFollowing']).to be false
        end
      end

      response '200', '新しい順にソートされる' do
        let!(:old_user) { create(:user, name: 'OldUser', created_at: 3.days.ago) }
        let!(:new_user) { create(:user, name: 'NewUser', created_at: 1.hour.ago) }

        run_test! do
          names = json_response.map { |u| u['name'] }
          expect(names.index(new_user.name)).to be < names.index(old_user.name)
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

      response '200', 'LIKEワイルドカード文字がエスケープされる' do
        let!(:user_with_underscore) { create(:user, name: 'foo_bar') }
        let!(:user_without_underscore) { create(:user, name: 'fooXbar') }
        let(:q) { '_' }

        run_test! do
          names = json_response.map { |u| u['name'] }
          expect(names).to include('foo_bar')
          expect(names).not_to include('fooXbar')
        end
      end

      response '200', 'パスワードやメールアドレスが含まれない' do
        run_test! do
          json_response.each do |user|
            expect(user.keys).not_to include('email', 'encryptedPassword', 'password')
          end
        end
      end

      response '200', 'ユーザー一覧取得成功' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   name: { type: :string },
                   avatarUrl: { type: :string, nullable: true },
                   isFollowing: { type: :boolean }
                 },
                 required: %w[name avatarUrl isFollowing]
               }

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(json_response).to be_an(Array)
          expect(json_response.size).to eq(3)
          expect(json_response.first).to have_key('name')
          expect(json_response.first).to have_key('avatarUrl')
          expect(json_response.first).to have_key('isFollowing')
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

  path '/api/users/{id}' do
    get 'ユーザー詳細を取得する' do
      tags 'User'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true, description: 'ユーザーID'

      let!(:current_user) { create(:user) }
      let!(:target_user) { create(:user) }
      before { sign_in current_user }

      response '200', 'フォロー中ユーザーはisFollowingがtrue' do
        let(:id) { target_user.id }
        before { current_user.follow!(target_user) }

        run_test! do
          expect(json_response['isFollowing']).to be true
        end
      end

      response '200', '未フォローユーザーはisFollowingがfalse' do
        let(:id) { target_user.id }

        run_test! do
          expect(json_response['isFollowing']).to be false
        end
      end

      response '200', '自分自身はisFollowingがfalse' do
        let(:id) { current_user.id }

        run_test! do
          expect(json_response['isFollowing']).to be false
        end
      end

      response '200', 'フォロー数・フォロワー数・投稿数が正しい' do
        let(:id) { target_user.id }
        let!(:other_user) { create(:user) }
        before do
          target_user.follow!(other_user)
          current_user.follow!(target_user)
          create_list(:post, 3, user: target_user)
        end

        run_test! do
          expect(json_response['followingsCount']).to eq(1)
          expect(json_response['followersCount']).to eq(1)
          expect(json_response['postsCount']).to eq(3)
        end
      end

      response '200', 'パスワードやメールアドレスが含まれない' do
        let(:id) { target_user.id }

        run_test! do
          expect(json_response.keys).not_to include('email', 'encryptedPassword', 'password')
        end
      end

      response '200', 'ユーザー詳細取得成功' do
        schema type: :object,
               properties: {
                 name: { type: :string },
                 avatarUrl: { type: :string, nullable: true },
                 isFollowing: { type: :boolean },
                 followingsCount: { type: :integer },
                 followersCount: { type: :integer },
                 postsCount: { type: :integer }
               },
               required: %w[name avatarUrl isFollowing followingsCount followersCount postsCount]

        let(:id) { target_user.id }

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(json_response).to have_key('name')
          expect(json_response).to have_key('avatarUrl')
          expect(json_response).to have_key('isFollowing')
          expect(json_response).to have_key('followingsCount')
          expect(json_response).to have_key('followersCount')
          expect(json_response).to have_key('postsCount')
        end
      end

      response '404', '存在しないユーザー' do
        let(:id) { 0 }

        run_test! do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    get '未ログインではユーザー詳細にアクセスできない' do
      tags 'User'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true, description: 'ユーザーID'

      response '401', '未ログイン' do
        let(:id) { create(:user).id }

        run_test!
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
