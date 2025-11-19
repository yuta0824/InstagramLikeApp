# == Schema Information
#
# Table name: posts
#
#  id         :bigint           not null, primary key
#  caption    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_posts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :post do
    association :user
    caption { Faker::Lorem.sentence(word_count: 5) }

    transient do
      images_count { 1 }
    end

    after(:build) do |post, evaluator|
      next if evaluator.images_count.zero?

      evaluator.images_count.times do
        post.images.attach(
          io: File.open(Rails.root.join('spec/fixtures/files/test.jpg')),
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
  end
end
