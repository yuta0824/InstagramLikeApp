require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Notifications::Reads', type: :request do
  path '/api/notifications/{notification_id}/read' do
    parameter name: :notification_id, in: :path, required: true, schema: { type: :integer }

    patch '通知を既読にする' do
      tags 'Notification'

      let(:user) { create(:user) }
      let(:actor) { create(:user) }
      let(:target_post) { create(:post, user: user) }
      let(:notification) do
        like = create(:like, user: actor, post: target_post)
        Notification.notify_if_needed(actor: actor, recipient: user, notifiable: like, notification_type: :liked)
        Notification.last
      end
      let(:notification_id) { notification.id }

      response '204', '既読成功' do
        before { sign_in user }

        run_test! do
          expect(notification.reload.read).to be(true)
        end
      end

      response '401', '未ログイン' do
        run_test!
      end
    end
  end

  describe '認可' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:actor) { create(:user) }

    it '他ユーザーの通知を既読にできない' do
      target_post = create(:post, user: other_user)
      like = create(:like, user: actor, post: target_post)
      Notification.notify_if_needed(actor: actor, recipient: other_user, notifiable: like, notification_type: :liked)
      notification = Notification.last

      sign_in user
      patch "/api/notifications/#{notification.id}/read"
      expect(response).to have_http_status(:not_found)
    end
  end
end
