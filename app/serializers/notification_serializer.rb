class NotificationSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :notification_type, :actor_count, :recent_actors,
             :post_id, :post_image_url, :comment_content, :read, :time_ago

  def recent_actors
    users = instance_options[:actors_by_id] || User.where(id: object.recent_actor_ids).index_by(&:id)
    object.recent_actor_ids.filter_map do |actor_id|
      user = users[actor_id]
      next unless user

      { name: user.name, avatarUrl: user.avatar_url }
    end
  end

  def post_id
    object.target_post_id
  end

  def post_image_url
    return nil unless object.target_post&.images&.attached?

    image = object.target_post.images.first
    url_options = ActiveStorage::Current.url_options || {}
    return rails_blob_path(image, only_path: true) unless url_options[:host]

    rails_blob_url(image, url_options)
  end

  def time_ago
    object.time_ago
  end
end
