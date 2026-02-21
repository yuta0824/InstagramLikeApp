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
class Notification < ApplicationRecord
  extend Enumerize

  enumerize :notification_type, in: %i[liked commented followed]

  belongs_to :recipient, class_name: 'User'
  belongs_to :latest_actor, class_name: 'User', optional: true
  belongs_to :notifiable, polymorphic: true, optional: true
  belongs_to :target_post, class_name: 'Post', optional: true

  scope :unread, -> { where(read: false) }
  scope :recent_first, -> { order(updated_at: :desc) }
  scope :with_details, -> { includes(:latest_actor, target_post: { images_attachments: :blob }) }

  MAX_RECENT_ACTORS = 10

  def time_ago
    seconds_diff = (Time.current - updated_at).to_i
    return I18n.t('models.post.now') if seconds_diff < 60

    minutes = seconds_diff / 60
    return I18n.t('models.post.minutes_ago', count: minutes) if minutes < 60

    hours = minutes / 60
    return I18n.t('models.post.hours_ago', count: hours) if hours < 24

    updated_at.strftime('%Y/%m/%d')
  end

  def self.notify_if_needed(actor:, recipient:, notifiable:, notification_type:)
    return if actor.id == recipient.id

    if notification_type.to_s == 'liked'
      upsert_liked(actor: actor, recipient: recipient, notifiable: notifiable)
    else
      create_individual(actor: actor, recipient: recipient, notifiable: notifiable, notification_type: notification_type)
    end
  rescue StandardError => e
    Rails.logger.error("Notification creation failed: #{e.message}")
    nil
  end

  def self.retract_if_needed(actor:, recipient:, target_post_id:)
    notification = find_by(recipient: recipient, notification_type: :liked, target_post_id: target_post_id)
    return unless notification

    if notification.actor_count <= 1
      notification.destroy!
    else
      new_ids = notification.recent_actor_ids - [actor.id]
      notification.update!(
        actor_count: notification.actor_count - 1,
        recent_actor_ids: new_ids,
        latest_actor_id: new_ids.first
      )
    end
  rescue StandardError => e
    Rails.logger.error("Notification retraction failed: #{e.message}")
    nil
  end

  class << self
    private

    def upsert_liked(actor:, recipient:, notifiable:)
      existing = find_by(recipient: recipient, notification_type: :liked, target_post_id: notifiable.post_id)

      if existing
        already_present = existing.recent_actor_ids.include?(actor.id)
        new_ids = ([actor.id] + existing.recent_actor_ids).uniq.first(MAX_RECENT_ACTORS)
        existing.update!(
          latest_actor_id: actor.id,
          recent_actor_ids: new_ids,
          actor_count: already_present ? existing.actor_count : existing.actor_count + 1,
          read: false
        )
      else
        create!(
          recipient: recipient,
          latest_actor_id: actor.id,
          notifiable: notifiable,
          notification_type: :liked,
          target_post_id: notifiable.post_id,
          recent_actor_ids: [actor.id],
          actor_count: 1
        )
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def create_individual(actor:, recipient:, notifiable:, notification_type:)
      attrs = {
        recipient: recipient,
        latest_actor_id: actor.id,
        notifiable: notifiable,
        notification_type: notification_type,
        recent_actor_ids: [actor.id],
        actor_count: 1
      }

      if notification_type.to_s == 'commented'
        attrs[:target_post_id] = notifiable.post_id
        attrs[:comment_content] = notifiable.content
      end

      create!(attrs)
    end
  end
end
