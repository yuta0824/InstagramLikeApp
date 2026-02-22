module Simulator
  module Actions
    class LikeAction
      def initialize(bot:, post:)
        @bot = bot
        @post = post
      end

      def call
        return if @post.liked_by?(@bot)

        like = Like.create!(user: @bot, post: @post)
        Notification.notify_if_needed(
          actor: @bot,
          recipient: @post.user,
          notifiable: like,
          notification_type: :liked
        )
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        nil
      end
    end
  end
end
