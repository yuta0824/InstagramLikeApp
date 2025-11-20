class CommentSerializer < ActiveModel::Serializer
  attributes :content, :user_name, :user_avatar

  def user_name
    object.user.name
  end

  def user_avatar
    object.user.avatar_url
  end
end
