# == Schema Information
#
# Table name: relationships
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  follower_id  :bigint           not null
#  following_id :bigint           not null
#
# Indexes
#
#  index_relationships_on_follower_id                   (follower_id)
#  index_relationships_on_follower_id_and_following_id  (follower_id,following_id) UNIQUE
#  index_relationships_on_following_id                  (following_id)
#
# Foreign Keys
#
#  fk_rails_...  (follower_id => users.id)
#  fk_rails_...  (following_id => users.id)
#
require 'rails_helper'

RSpec.describe Relationship, type: :model do
  let(:follower) { create(:user) }
  let(:following) { create(:user) }

  context 'follower_id と following_id の組み合わせが一意の場合' do
    it '保存できる' do
      relationship = build(:relationship, follower: follower, following: following)
      expect(relationship).to be_valid
    end
  end

  context 'follower_id と following_id の組み合わせが一意ではない場合' do
    it '保存できない' do
      create(:relationship, follower: follower, following: following)
      duplicate = build(:relationship, follower: follower, following: following)
      expect(duplicate).not_to be_valid
    end
  end

  context '自分自身をフォローしようとした場合' do
    it '保存できない' do
      relationship = build(:relationship, follower: follower, following: follower)
      expect(relationship).not_to be_valid
    end
  end

  context 'follower_id または following_id が空の場合' do
    it '保存できない' do
      expect(build(:relationship, follower: nil)).not_to be_valid
      expect(build(:relationship, following: nil)).not_to be_valid
    end
  end

  describe 'after_create_commit :notify_recipient' do
    it 'フォロー先ユーザーに通知が作成される' do
      expect {
        create(:relationship, follower: follower, following: following)
      }.to change(Notification, :count).by(1)

      notification = Notification.last
      expect(notification.notification_type).to eq('followed')
      expect(notification.recipient).to eq(following)
      expect(notification.latest_actor_id).to eq(follower.id)
    end
  end
end
