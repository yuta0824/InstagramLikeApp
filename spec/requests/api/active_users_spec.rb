require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::ActiveUsers', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  path '/api/active_users' do
    get '未ログインではアクセスできない' do
      tags 'ActiveUser'
      produces 'application/json'

      response '401', '未ログイン' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]

        run_test!
      end
    end

    get 'アクティブユーザー一覧を取得する' do
      tags 'ActiveUser'
      produces 'application/json'
      parameter name: :limit, in: :query, type: :integer, required: false, description: '取得件数（最大30）'

      let!(:active_user) { create(:user, name: 'ActiveUser') }
      let!(:inactive_user) { create(:user, name: 'InactiveUser') }
      let!(:expired_user) { create(:user, name: 'ExpiredUser') }
      before do
        create(:post, user: active_user, created_at: 1.hour.ago)
        create(:post, user: expired_user, created_at: (24.hours + 1.minute).ago)
        sign_in active_user
      end

      response '200', '投稿が24時間以降のユーザーは含まれない' do
        run_test! do
          names = json_response.map { |u| u['name'] }
          expect(names).not_to include('ExpiredUser')
        end
      end

      response '200', '投稿が24時間以内のユーザーは含まれる' do
        run_test! do
          names = json_response.map { |u| u['name'] }
          expect(names).to include('ActiveUser')
        end
      end

      response '200', 'ちょうど24時間前の投稿のユーザーは含まれる' do
        let!(:boundary_user) { create(:user, name: 'BoundaryUser') }
        before do
          freeze_time
          create(:post, user: boundary_user, created_at: 24.hours.ago)
        end
        after { travel_back }

        run_test! do
          names = json_response.map { |u| u['name'] }
          expect(names).to include('BoundaryUser')
        end
      end

      response '200', '投稿がないユーザーは含まれない' do
        run_test! do
          names = json_response.map { |u| u['name'] }
          expect(names).not_to include('InactiveUser')
        end
      end

      response '200', '最新の投稿順にソートされる' do
        let!(:recent_poster) { create(:user, name: 'RecentPoster') }
        let!(:older_poster) { create(:user, name: 'OlderPoster') }
        before do
          create(:post, user: older_poster, created_at: 12.hours.ago)
          create(:post, user: recent_poster, created_at: 10.minutes.ago)
        end

        run_test! do
          names = json_response.map { |u| u['name'] }
          expect(names.index('RecentPoster')).to be < names.index('OlderPoster')
        end
      end

      response '200', '複数投稿しても同じユーザーは重複しない' do
        before do
          3.times { create(:post, user: active_user, created_at: 1.hour.ago) }
        end

        run_test! do
          names = json_response.map { |u| u['name'] }
          expect(names.count('ActiveUser')).to eq(1)
        end
      end

      response '200', 'limitパラメータで取得件数を指定できる' do
        let!(:active_users) do
          create_list(:user, 10).each do |user|
            create(:post, user: user, created_at: 1.hour.ago)
          end
        end
        let(:limit) { 5 }

        run_test! do
          expect(json_response.size).to eq(5)
        end
      end

      response '200', 'limitが30を超えても30件までに制限される' do
        let!(:many_active_users) do
          create_list(:user, 35).each do |user|
            create(:post, user: user, created_at: 1.hour.ago)
          end
        end
        let(:limit) { 50 }

        run_test! do
          expect(json_response.size).to eq(30)
        end
      end

      response '200', 'limitが0以下の場合は1件以上返る' do
        let(:limit) { -1 }

        run_test! do
          expect(json_response.size).to be >= 1
        end
      end

      response '200', 'フォロー中ユーザーのisFollowingがtrueになる' do
        let!(:another_active_user) { create(:user, name: 'FollowedActive') }
        before do
          create(:post, user: another_active_user, created_at: 1.hour.ago)
          active_user.follow!(another_active_user)
        end

        run_test! do
          followed = json_response.find { |u| u['name'] == 'FollowedActive' }
          expect(followed['isFollowing']).to be true
        end
      end

      response '200', 'パスワードやメールアドレスが含まれない' do
        run_test! do
          json_response.each do |user|
            expect(user.keys).not_to include('email', 'encryptedPassword', 'password')
          end
        end
      end

      response '200', 'アクティブユーザー一覧取得成功' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   name: { type: :string },
                   avatarUrl: { type: :string, nullable: true },
                   isFollowing: { type: :boolean }
                 },
                 required: %w[name avatarUrl isFollowing]
               }

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(json_response).to be_an(Array)
          expect(json_response.first).to have_key('name')
          expect(json_response.first).to have_key('avatarUrl')
          expect(json_response.first).to have_key('isFollowing')
        end
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
