class SimulatorService
  def self.comment_templates
    @comment_templates ||= YAML.load_file(Rails.root.join('config/simulator/comments.yml'))
  end

  def self.welcome_follow(user)
    return if user.bot?

    random_bots(exclude: user, count: rand(3..5)).each do |bot|
      Relationship.create!(follower: bot, following: user)
    end
  rescue StandardError => e
    Rails.logger.error("[SimulatorService] welcome_follow failed: #{e.message}")
  end

  def self.react_to_post(post)
    return if post.user.bot?

    bots = random_bots(exclude: post.user, count: 4)

    bots.sample(rand(2..4)).each do |bot|
      Like.create!(user: bot, post: post)
    end

    bots.sample(rand(1..2)).each do |bot|
      Comment.create!(user: bot, post: post, content: comment_templates.sample)
    end
  rescue StandardError => e
    Rails.logger.error("[SimulatorService] react_to_post failed: #{e.message}")
  end

  def self.random_bots(exclude:, count:)
    User.bots.where.not(id: exclude.id).order('RANDOM()').limit(count).to_a
  end
  private_class_method :random_bots
end
