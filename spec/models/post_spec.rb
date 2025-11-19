# == Schema Information
#
# Table name: posts
#
#  id         :bigint           not null, primary key
#  caption    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_posts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:owner) { create(:user) }

  context '画像が3枚以下の場合' do
    it '保存できる' do
      post = build(:post, user: owner, images_count: 3)
      expect(post).to be_valid
    end
  end

  context '画像が添付されていない場合' do
    it '保存できない' do
      post = build(:post, user: owner, images_count: 0)
      expect(post).to be_invalid
      expect(post.errors[:images]).to include(/can't be blank/i)
    end
  end

  context '画像が4枚の場合' do
    it '保存できない' do
      post = build(:post, user: owner, images_count: 4)
      expect(post).to be_invalid
      expect(post.errors[:images]).not_to be_empty
    end
  end

  context 'キャプションが100文字を超える場合' do
    it '保存できない' do
      post = build(:post, user: owner, caption: 'a' * 101)
      expect(post).to be_invalid
      expect(post.errors[:caption]).to include('is too long (maximum is 100 characters)')
    end
  end
end
