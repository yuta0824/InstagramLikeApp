# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  content    :string(100)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  post_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_comments_on_post_id  (post_id)
#  index_comments_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (user_id => users.id)
#
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_one :notification, as: :notifiable, dependent: :destroy
  validates :content, presence: true, length: { maximum: 100 }

  after_create_commit :notify_recipient

  private

  def notify_recipient
    Notification.notify_if_needed(actor: user, recipient: post.user, notifiable: self, notification_type: :commented)
  end
end
