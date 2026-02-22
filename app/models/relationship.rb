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
class Relationship < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :following, class_name: 'User'
  has_one :notification, as: :notifiable, dependent: :destroy

  validates :follower_id, uniqueness: { scope: :following_id }
  validate :cannot_follow_self

  after_create_commit :notify_recipient

  private

  def notify_recipient
    Notification.notify_if_needed(actor: follower, recipient: following, notifiable: self, notification_type: :followed)
  end

  def cannot_follow_self
    errors.add(:following_id, 'cannot follow yourself') if follower_id == following_id
  end
end
