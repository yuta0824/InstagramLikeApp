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
class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_one :notification, as: :notifiable, dependent: :nullify
  validates :post_id, uniqueness: { scope: :user_id }

  after_create_commit :notify_recipient
  after_destroy_commit :retract_notification

  private

  def notify_recipient
    Notification.notify_if_needed(actor: user, recipient: post.user, notifiable: self, notification_type: :liked)
  end

  def retract_notification
    Notification.retract_if_needed(actor: user, recipient: post.user, target_post_id: post_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
