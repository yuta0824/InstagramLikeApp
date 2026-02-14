class UserDetailSerializer < UserSerializer
  attributes :followings_count, :followers_count, :posts_count

  def followings_count
    object.followings.count
  end

  def followers_count
    object.followers.count
  end

  def posts_count
    object.posts.count
  end
end
