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
