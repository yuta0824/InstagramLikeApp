# == Schema Information
#
# Table name: likes
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  post_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_likes_on_post_id              (post_id)
#  index_likes_on_user_id              (user_id)
#  index_likes_on_user_id_and_post_id  (user_id,post_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Like, type: :model do
  let(:post) { create(:post) }
  let(:user) { create(:user) }

  context 'user と post の組み合わせが一意の場合' do
    it '保存できる' do
      expect(build(:like, user: user, post: post)).to be_valid
    end
  end

  context 'user と post の組み合わせが一意ではない場合' do
    it '保存できない' do
      create(:like, user: user, post: post)
      duplicate = build(:like, user: user, post: post)
      expect(duplicate).to be_invalid
      expect(duplicate.errors[:post_id]).to include('has already been taken').or include('is invalid')
    end
  end
end
