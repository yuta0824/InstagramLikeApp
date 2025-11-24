require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Relationships', type: :request do
  path '/api/accounts/{account_id}/relationship' do
    parameter name: :account_id, in: :path, required: true, schema: { type: :integer }

    post 'フォロー関係を作成する' do
      tags 'Relationship'
      consumes 'application/json'
      produces 'application/json'

      let(:account) { create(:user) }
      let(:account_id) { account.id }

      response '201', 'フォロー成功' do
        let(:current_user) { create(:user) }
        before { sign_in current_user }
        run_test! do
          expect(response).to have_http_status(:created)
          expect(current_user.followings).to include(account)
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
          create(:relationship, follower: current_user, following: account)
        end
        run_test! do
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    delete 'フォロー関係を削除する' do
      tags 'Relationship'
      produces 'application/json'

      let(:account) { create(:user) }
      let(:account_id) { account.id }

      response '204', 'フォロー削除成功' do
        let(:current_user) { create(:user) }
        before do
          sign_in current_user
          create(:relationship, follower: current_user, following: account)
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
end
