require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Users::Followings', type: :request do
  path '/api/users/{user_id}/followings' do
    parameter name: :user_id, in: :path, required: true, schema: { type: :integer }

    get '特定ユーザーのフォロー中一覧を取得する' do
      tags 'User Following'
      produces 'application/json'
      parameter name: :page, in: :query, required: false, schema: { type: :integer }

      let(:user) { create(:user) }
      let(:target_user) { create(:user) }
      let(:user_id) { target_user.id }

      response '200', 'フォロー中一覧取得成功' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   avatarUrl: { type: :string, nullable: true },
                   isFollowing: { type: :boolean }
                 },
                 required: %w[id name avatarUrl isFollowing]
               }

        let!(:followings) do
          create_list(:user, 3).each { |f| target_user.follow!(f) }
        end

        before { sign_in user }

        run_test! do
          expect(json_response.size).to eq(3)
          returned_ids = json_response.map { |u| u['id'] }
          expect(returned_ids).to match_array(followings.map(&:id))
        end
      end

      response '401', '未ログイン' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        run_test!
      end

      response '404', '存在しないユーザー' do
        let(:user_id) { 999_999 }

        before { sign_in user }

        run_test!
      end
    end
  end

  describe 'isFollowing判定' do
    let(:user) { create(:user) }
    let(:target_user) { create(:user) }
    let!(:following_a) { create(:user) }
    let!(:following_b) { create(:user) }

    before do
      target_user.follow!(following_a)
      target_user.follow!(following_b)
      user.follow!(following_a)
      sign_in user
    end

    it 'ログインユーザーがフォロー済みのユーザーはisFollowing=trueになる' do
      get "/api/users/#{target_user.id}/followings"
      followed = json_response.find { |u| u['id'] == following_a.id }
      not_followed = json_response.find { |u| u['id'] == following_b.id }
      expect(followed['isFollowing']).to be true
      expect(not_followed['isFollowing']).to be false
    end
  end

  describe 'ページネーション' do
    let(:user) { create(:user) }
    let(:target_user) { create(:user) }

    before { sign_in user }

    context '25人をフォローしている場合' do
      let!(:followings) do
        create_list(:user, 25).each { |f| target_user.follow!(f) }
      end

      it '1ページ目は20件を返す' do
        get "/api/users/#{target_user.id}/followings", params: { page: 1 }
        expect(json_response.size).to eq(20)
      end

      it '2ページ目は残り5件を返す' do
        get "/api/users/#{target_user.id}/followings", params: { page: 2 }
        expect(json_response.size).to eq(5)
      end

      it '3ページ目は空配列を返す' do
        get "/api/users/#{target_user.id}/followings", params: { page: 3 }
        expect(json_response.size).to eq(0)
      end
    end

    context '不正なpageパラメータ' do
      let!(:following) { create(:user).tap { |f| target_user.follow!(f) } }

      it 'page=0 は1ページ目として扱う' do
        get "/api/users/#{target_user.id}/followings", params: { page: 0 }
        expect(response).to have_http_status(:ok)
        expect(json_response.size).to eq(1)
      end

      it 'page=-1 は1ページ目として扱う' do
        get "/api/users/#{target_user.id}/followings", params: { page: -1 }
        expect(response).to have_http_status(:ok)
        expect(json_response.size).to eq(1)
      end

      it '非数値のpageは1ページ目として扱う' do
        get "/api/users/#{target_user.id}/followings", params: { page: 'abc' }
        expect(response).to have_http_status(:ok)
        expect(json_response.size).to eq(1)
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
