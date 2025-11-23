require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Relationships', type: :request do
  path '/api/users/{user_id}/relationship' do
    parameter name: :user_id, in: :path, required: true, schema: { type: :integer }

    post 'フォロー関係を作成する' do
      tags 'Relationship'
      consumes 'application/json'
      produces 'application/json'

      let(:user_id) { 0 } # TODO: 実装後に適切な値に置き換え

      response '200', 'フォロー成功' do
        # TODO: 実装後に追加
      end

      response '401', '未ログイン' do
        # TODO: 実装後に追加
      end

      response '422', '自分自身または重複フォローで失敗' do
        # TODO: 実装後に追加
      end
    end

    delete 'フォロー関係を削除する' do
      tags 'Relationship'
      produces 'application/json'

      let(:user_id) { 0 } # TODO: 実装後に適切な値に置き換え

      response '200', 'フォロー削除成功' do
        # TODO: 実装後に追加
      end

      response '401', '未ログイン' do
        # TODO: 実装後に追加
      end

      response '422', 'フォローしていない相手を削除しようとした場合' do
        # TODO: 実装後に追加
      end
    end
  end
end
