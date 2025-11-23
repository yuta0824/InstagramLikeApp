require 'rails_helper'

RSpec.describe 'Followings', type: :request do
  let(:user) { create(:user) }

  describe 'GET /accounts/:account_username/followings' do
    context 'ログインしている場合' do
      before { sign_in user }

      it '200ステータスが返ってくる' do
      end

      context 'フォローが存在しない場合' do
        it '空のリストを返す' do
          # TODO: 実装後に追加
        end
      end

      context 'フォローが存在する場合' do
        it 'フォロー一覧を返す' do
          # TODO: 実装後に追加
        end
      end
    end

    context 'ログインしていない場合' do
      it 'ログイン画面に遷移する' do
      end
    end
  end
end
