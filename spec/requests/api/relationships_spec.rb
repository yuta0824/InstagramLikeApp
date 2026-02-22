require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Relationships', type: :request do
  path '/api/users/{user_id}/relationship' do
    parameter name: :user_id, in: :path, required: true, schema: { type: :integer }

    post 'フォロー関係を作成する' do
      tags 'Relationship'
      consumes 'application/json'
      produces 'application/json'

      let(:target_user) { create(:user) }
      let(:user_id) { target_user.id }

      response '201', 'フォロー成功' do
        let(:current_user) { create(:user) }
        before { sign_in current_user }
        run_test! do
          expect(response).to have_http_status(:created)
          expect(current_user.followings).to include(target_user)
        end
      end

      response '401', '未ログイン' do
        run_test! do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      response '422', '自分自身または重複フォローで失敗' do
        let(:current_user) { create(:user) }
        before do
          sign_in current_user
          create(:relationship, follower: current_user, following: target_user)
        end
        run_test! do
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    delete 'フォロー関係を削除する' do
      tags 'Relationship'
      produces 'application/json'

      let(:target_user) { create(:user) }
      let(:user_id) { target_user.id }

      response '204', 'フォロー削除成功' do
        let(:current_user) { create(:user) }
        before do
          sign_in current_user
          create(:relationship, follower: current_user, following: target_user)
        end
        run_test! do
          expect(response).to have_http_status(:no_content)
        end
      end

      response '401', '未ログイン' do
        run_test! do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      response '404', 'フォローしていない相手を削除しようとした場合' do
        let(:current_user) { create(:user) }
        before { sign_in current_user }
        run_test! do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe '通知' do
    context 'フォロー時' do
      it '相手に通知が作成される' do
        follower = create(:user)
        target = create(:user)
        sign_in follower

        expect {
          post "/api/users/#{target.id}/relationship", as: :json
        }.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.recipient).to eq(target)
        expect(notification.notification_type).to eq('followed')
      end
    end

    context 'フォロー解除時' do
      it '通知も削除される' do
        follower = create(:user)
        target = create(:user)
        create(:relationship, follower: follower, following: target)
        expect(Notification.count).to eq(1)

        sign_in follower
        expect {
          delete "/api/users/#{target.id}/relationship"
        }.to change(Notification, :count).by(-1)
      end
    end
  end

  describe '存在しないユーザーへの操作' do
    let(:current_user) { create(:user) }
    before { sign_in current_user }

    context 'POST /api/users/:user_id/relationship 存在しないuser_idの場合' do
      it '404を返す' do
        post '/api/users/999999/relationship', as: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'DELETE /api/users/:user_id/relationship 存在しないuser_idの場合' do
      it '404を返す' do
        delete '/api/users/999999/relationship'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
