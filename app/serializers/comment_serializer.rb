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
class CommentSerializer < ActiveModel::Serializer
  attributes :id, :content, :user_name, :user_avatar, :is_owner

  def user_name
    object.user.name
  end

  def user_avatar
    object.user.avatar_url
  end

  def is_owner
    scope&.id == object.user_id
  end
end
