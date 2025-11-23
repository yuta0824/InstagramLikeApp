require 'rails_helper'

RSpec.describe Relationship, type: :model do
  let(:follower) { create(:user) }
  let(:following) { create(:user) }

  context 'follower_id と following_id の組み合わせが一意の場合' do
    it '保存できる' do
      # TODO: 実装後に追加
    end
  end

  context 'follower_id と following_id の組み合わせが一意ではない場合' do
    it '保存できない' do
      # TODO: 実装後に追加
    end
  end

  context '自分自身をフォローしようとした場合' do
    it '保存できない' do
      # TODO: 実装後に追加
    end
  end

  context 'follower_id または following_id が空の場合' do
    it '保存できない' do
      # TODO: 実装後に追加
    end
  end
end
