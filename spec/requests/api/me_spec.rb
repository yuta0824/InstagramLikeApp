require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Me', type: :request do
  let(:user) { create(:user) }

  path '/api/me' do
    get 'ログイン中ユーザーを取得する' do
      tags 'User'
      produces 'application/json'

      response '200', 'isFollowingは常にfalse' do
        before { sign_in user }

        run_test! do
          expect(json_response['isFollowing']).to be false
        end
      end

      response '200', 'カウント値が正しい' do
        let!(:other_user) { create(:user) }
        before do
          sign_in user
          user.follow!(other_user)
          create_list(:post, 2, user: user)
        end

        run_test! do
          expect(json_response['followingsCount']).to eq(1)
          expect(json_response['followersCount']).to eq(0)
          expect(json_response['postsCount']).to eq(2)
        end
      end

      response '200', '取得成功' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 avatarUrl: { type: :string, nullable: true },
                 isFollowing: { type: :boolean },
                 followingsCount: { type: :integer },
                 followersCount: { type: :integer },
                 postsCount: { type: :integer }
               },
               required: %w[id name avatarUrl isFollowing followingsCount followersCount postsCount]

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
      parameter name: :remove_avatar,
                in: :formData,
                required: false,
                schema: { type: :boolean },
                description: 'trueでアバターを削除'

      response '200', '更新後のレスポンスにカウント値とisFollowingが含まれる' do
        let(:name) { 'updated_name' }
        let!(:other_user) { create(:user) }
        before do
          sign_in user
          user.follow!(other_user)
          create_list(:post, 2, user: user)
        end

        run_test! do
          expect(json_response['isFollowing']).to be false
          expect(json_response['followingsCount']).to eq(1)
          expect(json_response['followersCount']).to eq(0)
          expect(json_response['postsCount']).to eq(2)
          expect(json_response['name']).to eq('updated_name')
        end
      end

      response '200', '更新成功' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 avatarUrl: { type: :string, nullable: true },
                 isFollowing: { type: :boolean },
                 followingsCount: { type: :integer },
                 followersCount: { type: :integer },
                 postsCount: { type: :integer }
               },
               required: %w[id name avatarUrl isFollowing followingsCount followersCount postsCount]

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

  describe 'PATCH /api/me バリデーション失敗' do
    let(:user) { create(:user) }
    before { sign_in user }

    context '無効な名前（20文字超）の場合' do
      it '422を返す' do
        patch '/api/me', params: { name: 'a' * 21 }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context '無効な名前フォーマット（特殊文字）の場合' do
      it '422を返す' do
        patch '/api/me', params: { name: 'invalid@name!' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context '重複する名前の場合' do
      let!(:other_user) { create(:user, name: 'taken_name') }

      it '422を返す' do
        patch '/api/me', params: { name: 'taken_name' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /api/me エッジケース' do
    let(:user) { create(:user, name: 'original_name') }
    before { sign_in user }

    context 'パラメータなしで更新した場合' do
      it '変更なしで成功する' do
        patch '/api/me'
        expect(response).to have_http_status(:ok)
        expect(user.reload.name).to eq('original_name')
      end
    end

    context 'アバターのみ更新した場合' do
      it '成功する' do
        patch '/api/me', params: { avatar: fixture_file_upload('test.jpg', 'image/jpeg') }
        expect(response).to have_http_status(:ok)
        expect(user.reload.avatar).to be_attached
      end
    end

    context 'remove_avatar=trueの場合' do
      before { user.avatar.attach(fixture_file_upload('test.jpg', 'image/jpeg')) }

      it 'アバターが削除されavatarUrlがnilになる' do
        patch '/api/me', params: { remove_avatar: true }
        expect(response).to have_http_status(:ok)
        expect(user.reload.avatar).not_to be_attached
        expect(json_response['avatarUrl']).to be_nil
      end
    end

    context 'remove_avatar=trueと名前変更を同時に送った場合' do
      before { user.avatar.attach(fixture_file_upload('test.jpg', 'image/jpeg')) }

      it 'アバター削除と名前変更が両方反映される' do
        patch '/api/me', params: { name: 'new_name', remove_avatar: true }
        expect(response).to have_http_status(:ok)
        expect(user.reload.name).to eq('new_name')
        expect(user.avatar).not_to be_attached
      end
    end

    context 'アバター未設定でremove_avatar=trueの場合' do
      it '冪等に成功する' do
        patch '/api/me', params: { remove_avatar: true }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
