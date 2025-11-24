require 'rails_helper'

RSpec.describe 'Followers', type: :request do
  let(:user) { create(:user) }

  describe 'GET /accounts/:account_username/followers' do
    context 'ログインしている場合' do
      before { sign_in user }

      it '200ステータスが返ってくる' do
        get account_followers_path(account_username: user.name)
        expect(response).to have_http_status(:ok)
      end

      context 'フォロワーが存在しない場合' do
        it '空のリストを返す' do
          get account_followers_path(account_username: user.name)
          expect(response).to have_http_status(:ok)
          other_user = create(:user)
          expect(response.body).not_to include(other_user.name)
        end
      end

      context 'フォロワーが存在する場合' do
        it 'フォロワー一覧を返す' do
          follower = create(:user)
          target = create(:user)
          create(:relationship, follower:, following: target)
          get account_followers_path(account_username: target.name)
          expect(response.body).to include(follower.name)
        end
      end
    end

    context 'ログインしていない場合' do
      it 'ログイン画面に遷移する' do
        get account_followers_path(account_username: user.name)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
