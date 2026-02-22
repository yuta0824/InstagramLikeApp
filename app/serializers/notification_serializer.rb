# == Schema Information
#
# Table name: notifications
#
#  id                :bigint           not null, primary key
#  actor_count       :integer          default(1), not null
#  comment_content   :string
#  notifiable_type   :string
#  notification_type :string           not null
#  read              :boolean          default(FALSE), not null
#  recent_actor_ids  :jsonb            not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  latest_actor_id   :bigint
#  notifiable_id     :bigint
#  recipient_id      :bigint           not null
#  target_post_id    :bigint
#
# Indexes
#
#  idx_notifications_liked_unique                            (recipient_id,notification_type,target_post_id) UNIQUE WHERE ((notification_type)::text = 'liked'::text)
#  index_notifications_on_latest_actor_id                    (latest_actor_id)
#  index_notifications_on_notifiable_type_and_notifiable_id  (notifiable_type,notifiable_id)
#  index_notifications_on_recipient_id                       (recipient_id)
#  index_notifications_on_recipient_id_and_read              (recipient_id,read)
#  index_notifications_on_recipient_id_and_updated_at        (recipient_id,updated_at)
#  index_notifications_on_target_post_id                     (target_post_id)
#
# Foreign Keys
#
#  fk_rails_...  (latest_actor_id => users.id) ON DELETE => nullify
#  fk_rails_...  (recipient_id => users.id)
#  fk_rails_...  (target_post_id => posts.id) ON DELETE => nullify
#
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
