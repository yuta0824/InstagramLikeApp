module Simulator
  class ReactiveActivityService < Base
    LIKES_RANGE = (2..4).freeze
    COMMENTS_RANGE = (1..2).freeze

    def initialize(post:)
      @post = post
    end

    def call
      return unless simulator_enabled?
      return if @post.user.bot?

      simulate_likes
      simulate_comments
    end

    private

    def simulate_likes
      count = rand(LIKES_RANGE)
      random_bots(count: count, exclude: [@post.user]).each do |bot|
        Actions::LikeAction.new(bot: bot, post: @post).call
      end
    end

    def simulate_comments
      count = rand(COMMENTS_RANGE)
      random_bots(count: count, exclude: [@post.user]).each do |bot|
        Actions::CommentAction.new(bot: bot, post: @post).call
      end
    end
  end
end
