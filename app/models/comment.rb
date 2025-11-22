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
  has_many :notifications, dependent: :destroy
  validates :content, presence: true, length: { maximum: 100 }
  after_create :create_mention_notifications

  private
  def create_mention_notifications
    extract_mentioned_usernames.each do |username|
      user = User.find_by(name: username)
      next unless user
      Notification.create!(user: user, comment: self)
    end
  end

  def extract_mentioned_usernames
    content.to_s.scan(/@([a-zA-Z0-9_]+)/).flatten.uniq
  end
end
