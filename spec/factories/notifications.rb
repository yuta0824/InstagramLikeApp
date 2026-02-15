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
FactoryBot.define do
  factory :notification do
    association :recipient, factory: :user
    notification_type { :liked }
    recent_actor_ids { [latest_actor_id] }
    actor_count { 1 }
    read { false }

    transient do
      actor { association(:user) }
    end

    after(:build) do |notification, evaluator|
      notification.latest_actor_id = evaluator.actor.id
      notification.recent_actor_ids = [evaluator.actor.id]
    end

    trait :liked do
      notification_type { :liked }
      association :notifiable, factory: :like
      after(:build) do |notification|
        notification.target_post_id = notification.notifiable&.post_id
      end
    end

    trait :commented do
      notification_type { :commented }
      association :notifiable, factory: :comment
      comment_content { 'Test comment' }
      after(:build) do |notification|
        notification.target_post_id = notification.notifiable&.post_id
      end
    end

    trait :followed do
      notification_type { :followed }
      association :notifiable, factory: :relationship
    end
  end
end
