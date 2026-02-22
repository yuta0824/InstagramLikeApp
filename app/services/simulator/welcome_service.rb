module Simulator
  class WelcomeService < Base
    FOLLOWERS_RANGE = (3..5).freeze
    FOLLOWINGS_RANGE = (2..3).freeze

    def initialize(user:)
      @user = user
    end

    def call
      return unless simulator_enabled?
      return if @user.bot?

      bots_follow_user
      user_follows_bots
    end

    private

    def bots_follow_user
      count = rand(FOLLOWERS_RANGE)
      random_bots(count: count, exclude: [@user]).each do |bot|
        bot.follow!(@user)
        notify_follow(actor: bot, recipient: @user, relationship: bot.following_relationships.last)
      end
    end

    def user_follows_bots
      count = rand(FOLLOWINGS_RANGE)
      random_bots(count: count, exclude: [@user]).each do |bot|
        @user.follow!(bot)
      end
    end

    def notify_follow(actor:, recipient:, relationship:)
      Notification.notify_if_needed(
        actor: actor,
        recipient: recipient,
        notifiable: relationship,
        notification_type: :followed
      )
    end
  end
end
