require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Users::Followers', type: :request do
  path '/api/users/{user_id}/followers' do
    parameter name: :user_id, in: :path, required: true, schema: { type: :integer }

    get '特定ユーザーのフォロワー一覧を取得する' do
      tags 'User Follower'
      produces 'application/json'
      parameter name: :cursor, in: :query, type: :string, required: false,
                description: '前回取得した最後のrelationshipのID'

      let(:user) { create(:user) }
      let(:target_user) { create(:user) }
      let(:user_id) { target_user.id }

      response '200', 'フォロワー一覧取得成功' do
        schema type: :object,
               properties: {
                 followers: {
                   type: :array,
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
                 },
                 nextCursor: { type: :string, nullable: true },
                 hasMore: { type: :boolean }
               },
               required: %w[followers nextCursor hasMore]

        let!(:followers) do
          create_list(:user, 3).each { |f| f.follow!(target_user) }
        end

        before { sign_in user }

        run_test! do
          expect(json_response['followers'].size).to eq(3)
          returned_ids = json_response['followers'].map { |u| u['id'] }
          expect(returned_ids).to match_array(followers.map(&:id))
        end
      end

      response '400', 'cursorが不正' do
        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string } }
               },
               required: %w[errors]

        let(:cursor) { 'invalid' }

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
    let!(:follower_a) { create(:user) }
    let!(:follower_b) { create(:user) }

    before do
      follower_a.follow!(target_user)
      follower_b.follow!(target_user)
      user.follow!(follower_a)
      sign_in user
    end

    it 'ログインユーザーがフォロー済みのユーザーはisFollowing=trueになる' do
      get "/api/users/#{target_user.id}/followers"
      followed = json_response['followers'].find { |u| u['id'] == follower_a.id }
      not_followed = json_response['followers'].find { |u| u['id'] == follower_b.id }
      expect(followed['isFollowing']).to be true
      expect(not_followed['isFollowing']).to be false
    end
  end

  describe 'カーソルベースページネーション' do
    let(:user) { create(:user) }
    let(:target_user) { create(:user) }

    before { sign_in user }

    context '21人のフォロワーがいる場合' do
      let!(:followers) do
        create_list(:user, 21).each { |f| f.follow!(target_user) }
      end

      it 'hasMoreがtrueで20件返り、nextCursorが設定される' do
        get "/api/users/#{target_user.id}/followers"
        expect(json_response['followers'].size).to eq(20)
        expect(json_response['hasMore']).to be true
        expect(json_response['nextCursor']).to be_present
      end
    end

    context 'ちょうど20人のフォロワーがいる場合' do
      let!(:followers) do
        create_list(:user, 20).each { |f| f.follow!(target_user) }
      end

      it 'hasMoreがfalseでnextCursorがnilになる' do
        get "/api/users/#{target_user.id}/followers"
        expect(json_response['followers'].size).to eq(20)
        expect(json_response['hasMore']).to be false
        expect(json_response['nextCursor']).to be_nil
      end
    end

    context 'nextCursorで2ページ目を取得した場合' do
      let!(:followers) do
        create_list(:user, 25).each { |f| f.follow!(target_user) }
      end

      it '重複・欠落がない' do
        get "/api/users/#{target_user.id}/followers"
        page1_ids = json_response['followers'].map { |u| u['id'] }
        next_cursor = json_response['nextCursor']

        get "/api/users/#{target_user.id}/followers", params: { cursor: next_cursor }
        page2_ids = json_response['followers'].map { |u| u['id'] }

        expect(page1_ids.size).to eq(20)
        expect(page2_ids.size).to eq(5)
        expect(page1_ids & page2_ids).to be_empty
        all_ids = target_user.follower_relationships.order(id: :desc).map(&:follower_id)
        expect(page1_ids + page2_ids).to eq(all_ids)
      end
    end

    context '並び順' do
      let!(:first_follower) { create(:user) }
      let!(:second_follower) { create(:user) }

      before do
        first_follower.follow!(target_user)
        second_follower.follow!(target_user)
      end

      it '最近フォローしたユーザーが先に返る' do
        get "/api/users/#{target_user.id}/followers"
        expect(json_response['followers'].first['id']).to eq(second_follower.id)
        expect(json_response['followers'].last['id']).to eq(first_follower.id)
      end
    end

    context '不正なcursor値の場合' do
      it '非数値文字列で400を返す' do
        get "/api/users/#{target_user.id}/followers", params: { cursor: 'abc' }
        expect(response).to have_http_status(:bad_request)
        expect(json_response['errors']).to be_present
      end

      it '0で400を返す' do
        get "/api/users/#{target_user.id}/followers", params: { cursor: '0' }
        expect(response).to have_http_status(:bad_request)
      end

      it '負数で400を返す' do
        get "/api/users/#{target_user.id}/followers", params: { cursor: '-1' }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
