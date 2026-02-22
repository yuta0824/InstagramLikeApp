module Simulator
  module Actions
    class CommentAction
      COMMENTS = YAML.load_file(
        Rails.root.join('config/simulator/comments.yml')
      ).freeze

      def initialize(bot:, post:)
        @bot = bot
        @post = post
      end

      def call
        comment = Comment.create!(
          user: @bot,
          post: @post,
          content: COMMENTS.sample
        )
        Notification.notify_if_needed(
          actor: @bot,
          recipient: @post.user,
          notifiable: comment,
          notification_type: :commented
        )
      end
    end
  end
end
