# == Schema Information
#
# Table name: notifications
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  comment_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_notifications_on_comment_id              (comment_id)
#  index_notifications_on_comment_id_and_user_id  (comment_id,user_id) UNIQUE
#  index_notifications_on_user_id                 (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (comment_id => comments.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :notification do
    association :user
    association :comment
  end
end
