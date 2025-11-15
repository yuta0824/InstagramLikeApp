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
class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many_attached :images
  validates :images, presence: true, length: { minimum: 1, maximum: 3 }
  validates :caption, length: { maximum: 100 }

  def owned_by?(user)
    return false unless user
    user_id == user.id
  end

  def liked_by?(user)
    return false unless user
    likes.exists?(user_id: user.id)
  end

  def liked_user
    likes.last&.user&.name
  end

  def liked_count
    likes.count
  end

  def likes_summary
    return nil if liked_count.zero?
    return "#{liked_user} liked your post" if liked_count == 1

    "#{liked_user} and #{liked_count - 1} other liked your post"
  end

  def time_ago
    seconds_diff = (Time.current - created_at).to_i
    return 'now' if seconds_diff < 60

    minutes = seconds_diff / 60
    return "#{minutes} minutes ago" if minutes < 60

    hours = minutes / 60
    return "#{hours} hours ago" if hours < 24

    created_at.strftime('%Y/%m/%d')
  end
end
