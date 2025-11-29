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
  has_many :comments, dependent: :destroy
  has_many_attached :images
  validates :images, presence: true, length: { minimum: 1, maximum: 3 }
  validates :caption, length: { maximum: 100 }

  scope :by_users, ->(users) { where(user_id: users) }
  scope :recent_within, ->(time) { where('posts.created_at >= ?', Time.current - time) }
  scope :popular, ->(limit: 5) {
    left_joins(:likes)
      .group('posts.id')
      .order('COUNT(likes.id) DESC, posts.created_at DESC')
      .limit(limit)
  }
  scope :with_associations, -> {
    includes(:user, likes: :user)
      .with_attached_images
  }

  def owned_by?(user)
    return false unless user
    user_id == user.id
  end

  def liked_by?(user)
    return false unless user
    likes.exists?(user_id: user.id)
  end

  def most_recent_liker_name
    likes.last&.user&.name
  end

  def liked_count
    likes.count
  end

  # TODO: 多言語対応
  def likes_summary
    return nil if liked_count.zero?
    return "#{most_recent_liker_name} liked your post" if liked_count == 1

    remaining_likes = liked_count - 1
    "#{most_recent_liker_name} and #{remaining_likes} other liked your post"
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
