require 'rails_helper'
require 'swagger_helper'
require 'support/notification_schema_helper'

RSpec.describe 'Api::Notifications', type: :request do
  path '/api/notifications' do
    get '通知一覧を取得する' do
      tags 'Notification'
      produces 'application/json'
      parameter name: :page, in: :query, required: false, schema: { type: :integer }

      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      let(:target_post) { create(:post, user: user) }

      response '200', '取得成功' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: NOTIFICATION_PROPERTIES,
                 required: NOTIFICATION_REQUIRED
               }

        before do
          create(:like, user: other_user, post: target_post)
          create(:comment, user: other_user, post: target_post, content: 'great!')
          create(:relationship, follower: other_user, following: user)
          sign_in user
        end

        run_test! do
          expect(json_response.size).to eq(3)

          liked = json_response.find { |n| n['notificationType'] == 'liked' }
          expect(liked['actorCount']).to eq(1)
          expect(liked['recentActors'].first['name']).to eq(other_user.name)
          expect(liked['postId']).to eq(target_post.id)

          commented = json_response.find { |n| n['notificationType'] == 'commented' }
          expect(commented['commentContent']).to eq('great!')

          followed = json_response.find { |n| n['notificationType'] == 'followed' }
          expect(followed['postId']).to be_nil
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

  describe 'ページネーション' do
    let(:user) { create(:user) }

    before do
      25.times do
        actor = create(:user)
        create(:relationship, follower: actor, following: user)
      end
      sign_in user
    end

    it 'ページ1は最大20件を返す' do
      get '/api/notifications', params: { page: 1 }
      expect(json_response.size).to eq(20)
    end

    it 'ページ2は残りを返す' do
      get '/api/notifications', params: { page: 2 }
      expect(json_response.size).to eq(5)
    end
  end

  describe 'スコープ制限' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    before do
      actor = create(:user)
      create(:relationship, follower: actor, following: other_user)
      sign_in user
    end

    it '他ユーザーの通知は取得できない' do
      get '/api/notifications'
      expect(json_response.size).to eq(0)
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
