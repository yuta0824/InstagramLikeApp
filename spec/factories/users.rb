# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  bot                    :boolean          default(FALSE), not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  guest                  :boolean          default(FALSE), not null
#  name                   :string           not null
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  uid                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_name                  (name) UNIQUE
#  index_users_on_provider_and_uid      (provider,uid) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
FactoryBot.define do
  factory :user do
    provider { 'google_oauth2' }
    sequence(:uid) { |n| "google-uid-#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "user_#{n}" }
    password { Devise.friendly_token[0, 20] }

    trait :bot do
      bot { true }
    end

    trait :guest do
      guest { true }
      provider { nil }
      uid { nil }
    end
  end
end
