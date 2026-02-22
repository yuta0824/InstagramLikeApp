require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Notifications::UnreadCounts', type: :request do
  path '/api/notifications/unread_count' do
    get '未読通知数を取得する' do
      tags 'Notification'
      produces 'application/json'

      let(:user) { create(:user) }

      response '200', '取得成功' do
        schema type: :object,
               properties: {
                 unreadCount: { type: :integer }
               },
               required: %w[unreadCount]

        before do
          2.times do
            actor = create(:user)
            create(:relationship, follower: actor, following: user)
          end
          # 1件は既読にする
          user.notifications.first.update!(read: true)
          sign_in user
        end

        run_test! do
          expect(json_response['unreadCount']).to eq(1)
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
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
