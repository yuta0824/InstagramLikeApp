class SimulatorService
  COMMENT_TEMPLATES = YAML.load_file(Rails.root.join('config/simulator/comments.yml'))

  def self.welcome_follow(user)
    return if user.bot?

    random_bots(exclude: user, count: rand(3..5)).each do |bot|
      Relationship.create!(follower: bot, following: user)
    end
  end

  def self.react_to_post(post)
    return if post.user.bot?

    bots = random_bots(exclude: post.user, count: 4)

    bots.sample(rand(2..4)).each do |bot|
      Like.create!(user: bot, post: post)
    end

    bots.sample(rand(1..2)).each do |bot|
      Comment.create!(user: bot, post: post, content: COMMENT_TEMPLATES.sample)
    end
  end

  def self.delay_react_to_post(post)
    ReactJob.set(wait: 5.seconds).perform_later(post.id)
  end

  def self.random_bots(exclude:, count:)
    User.bots.where.not(id: exclude.id).order('RANDOM()').limit(count).to_a
  end
  private_class_method :random_bots

  class ReactJob < ApplicationJob
    def perform(post_id)
      post = Post.find_by(id: post_id) or return
      SimulatorService.react_to_post(post)
    end
  end
end
