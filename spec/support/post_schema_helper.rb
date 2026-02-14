POST_DETAIL_PROPERTIES = {
  id: { type: :integer },
  caption: { type: :string, nullable: true },
  imageUrls: { type: :array, items: { type: :string } },
  userName: { type: :string },
  userAvatar: { type: :string, nullable: true },
  likedCount: { type: :integer },
  likesSummary: { type: :string, nullable: true },
  timeAgo: { type: :string },
  isLiked: { type: :boolean },
  isOwn: { type: :boolean },
  mostRecentLikerName: { type: :string },
  comments: {
    type: :array,
    items: {
      type: :object,
      properties: {
        id: { type: :integer },
        content: { type: :string },
        userName: { type: :string },
        userAvatar: { type: :string, nullable: true },
        isOwner: { type: :boolean }
      },
      required: %w[id content userName userAvatar isOwner]
    }
  }
}.freeze

POST_DETAIL_REQUIRED = %w[
  id
  imageUrls
  userName
  userAvatar
  likedCount
  timeAgo
  isLiked
  isOwn
  mostRecentLikerName
  comments
].freeze
