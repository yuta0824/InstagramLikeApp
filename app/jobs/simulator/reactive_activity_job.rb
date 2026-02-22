module Simulator
  class ReactiveActivityJob < ApplicationJob
    queue_as :default

    def perform(post_id)
      post = Post.find_by(id: post_id)
      return unless post

      ReactiveActivityService.new(post: post).call
    end
  end
end
