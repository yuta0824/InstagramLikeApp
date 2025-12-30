# == Schema Information
#
# Table name: jwt_denylists
#
#  id         :bigint           not null, primary key
#  exp        :datetime         not null
#  jti        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_jwt_denylists_on_jti  (jti) UNIQUE
#
FactoryBot.define do
  factory :jwt_denylist do
    sequence(:jti) { |n| "jwt-jti-#{n}" }
    exp { '2025-12-20 10:54:20' }
  end
end
