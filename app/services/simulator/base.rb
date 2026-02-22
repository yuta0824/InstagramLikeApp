module Simulator
  class Base
    private

    def simulator_enabled?
      ENV.fetch('SIMULATOR_ENABLED', 'true') == 'true'
    end

    def bot_users
      User.bots
    end

    def random_bots(count:, exclude: [])
      exclude_ids = Array(exclude).map { |u| u.is_a?(User) ? u.id : u }
      bot_users.where.not(id: exclude_ids).order('RANDOM()').limit(count)
    end
  end
end
