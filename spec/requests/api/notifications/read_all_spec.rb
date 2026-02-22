require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Notifications::ReadAll', type: :request do
  path '/api/notifications/read_all' do
    post '全通知を一括既読にする' do
      tags 'Notification'

      let(:user) { create(:user) }
      let(:actor) { create(:user) }

      response '204', '一括既読成功' do
        before do
          3.times do
            a = create(:user)
            create(:relationship, follower: a, following: user)
          end
          sign_in user
        end

        run_test! do
          expect(user.notifications.unread.count).to eq(0)
        end
      end

      response '401', '未ログイン' do
        run_test!
      end
    end
  end

  describe 'スコープ制限' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it '他ユーザーの通知は既読にならない' do
      actor = create(:user)
      create(:relationship, follower: actor, following: other_user)

      sign_in user
      post '/api/notifications/read_all'
      expect(other_user.notifications.unread.count).to eq(1)
    end
  end
end
