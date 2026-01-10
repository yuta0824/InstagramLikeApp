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
class PostDetailSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :caption, :image_urls, :user_name, :user_avatar, :liked_count, :likes_summary, :time_ago, :is_liked, :is_own, :most_recent_liker_name

  has_many :comments, serializer: CommentSerializer

  def image_urls
    object.images.map { |image| rails_blob_path(image, only_path: true) }
  end

  def user_name
    object.user.name
  end

  def user_avatar
    object.user.avatar_url
  end

  def liked_count
    object.liked_count
  end

  def likes_summary
    object.likes_summary
  end

  def time_ago
    object.time_ago
  end

  def is_liked
    object.liked_by?(scope)
  end

  def is_own
    object.owned_by?(scope)
  end

  def most_recent_liker_name
    object.most_recent_liker_name.to_s
  end

  def comments
    object.comments.order(created_at: :asc)
  end
end
