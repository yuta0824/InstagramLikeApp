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
  has_many :comments, -> { order(created_at: :asc) }, dependent: :destroy
  has_many_attached :images

  validates :images, presence: true, length: { minimum: 1, maximum: 3 }
  validates :caption, length: { maximum: 100 }

  after_create_commit :delay_react, unless: -> { user.bot? }

  scope :with_details, -> {
    includes(:user, likes: :user, comments: [user: { avatar_attachment: :blob }])
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

  def likes_summary
    return nil if liked_count.zero?
    return I18n.t('models.post.single_like', name: most_recent_liker_name) if liked_count == 1

    remaining_likes = liked_count - 1
    I18n.t('models.post.multiple_likes', name: most_recent_liker_name, count: remaining_likes)
  end

  def time_ago
    seconds_diff = (Time.current - created_at).to_i
    return I18n.t('models.post.now') if seconds_diff < 60

    minutes = seconds_diff / 60
    return I18n.t('models.post.minutes_ago', count: minutes) if minutes < 60

    hours = minutes / 60
    return I18n.t('models.post.hours_ago', count: hours) if hours < 24

    created_at.strftime('%Y/%m/%d')
  end

  private

  def delay_react
    SimulatorService.delay_react_to_post(self)
  end
end
