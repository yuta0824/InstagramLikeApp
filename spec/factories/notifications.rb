FactoryBot.define do
  factory :notification do
    association :user
    association :comment
  end
end
