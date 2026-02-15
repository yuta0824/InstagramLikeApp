RECENT_ACTOR_PROPERTIES = {
  name: { type: :string },
  avatarUrl: { type: :string, nullable: true }
}.freeze

NOTIFICATION_PROPERTIES = {
  id: { type: :integer },
  notificationType: { type: :string, enum: %w[liked commented followed] },
  actorCount: { type: :integer },
  recentActors: {
    type: :array,
    items: {
      type: :object,
      properties: RECENT_ACTOR_PROPERTIES,
      required: %w[name avatarUrl]
    }
  },
  postId: { type: :integer, nullable: true },
  postImageUrl: { type: :string, nullable: true },
  commentContent: { type: :string, nullable: true },
  read: { type: :boolean },
  timeAgo: { type: :string }
}.freeze

NOTIFICATION_REQUIRED = %w[
  id
  notificationType
  actorCount
  recentActors
  read
  timeAgo
].freeze
