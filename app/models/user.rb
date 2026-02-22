# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  bot                    :boolean          default(FALSE), not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  name                   :string           not null
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  uid                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_name                  (name) UNIQUE
#  index_users_on_provider_and_uid      (provider,uid) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :validatable,
         :omniauthable, :jwt_authenticatable,
         omniauth_providers: %i[google_oauth2],
         jwt_revocation_strategy: JwtDenylist

  validates :name,
            presence: true,
            uniqueness: true,
            length: { maximum: 20 },
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: :invalid_format }
  has_many :notifications, foreign_key: 'recipient_id', dependent: :destroy, inverse_of: :recipient
  has_many :likes, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :following_relationships, foreign_key: 'follower_id', class_name: 'Relationship', dependent: :destroy
  has_many :followings, through: :following_relationships, source: :following
  has_many :follower_relationships, foreign_key: 'following_id', class_name: 'Relationship', dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower
  has_one_attached :avatar

  scope :bots, -> { where(bot: true) }

  scope :search_by_name, ->(query) {
    where('LOWER(name) LIKE LOWER(?)', "%#{sanitize_sql_like(query)}%")
  }

  scope :recently_active, ->(limit: 30, within: 24.hours) {
    joins(:posts)
      .where('posts.created_at >= ?', within.ago)
      .select('users.*, MAX(posts.created_at) as latest_post_at')
      .group('users.id')
      .order('latest_post_at DESC')
      .limit(limit)
  }

  def avatar_url
    return nil unless avatar.attached?
    url_options = ActiveStorage::Current.url_options || {}
    return Rails.application.routes.url_helpers.rails_blob_path(avatar, only_path: true) unless url_options[:host]

    Rails.application.routes.url_helpers.rails_blob_url(avatar, url_options)
  end

  def follow!(target_user)
    following_relationships.create!(following_id: target_user.id)
  end

  def unfollow!(target_user)
    relation = following_relationships.find_by!(following_id: target_user.id)
    relation.destroy!
  end

  def self.from_omniauth(auth)
    user = find_or_initialize_by(provider: auth.provider, uid: auth.uid)

    if user.new_record?
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = build_unique_name(auth)
    end

    user.save!
    user
  end

  def self.build_unique_name(auth)
    base = auth.info.email.to_s.split('@').first
    sanitized = base.to_s.gsub(/[^a-zA-Z0-9_]/, '_')[0, 20]
    base_name = sanitized.presence || "user_#{SecureRandom.hex(4)}"
    return base_name unless User.exists?(name: base_name)

    loop do
      suffix = SecureRandom.hex(3)
      prefix_length = 20 - (suffix.length + 1)
      prefix = base_name[0, prefix_length]
      prefix = 'user' if prefix.blank?
      candidate = "#{prefix}_#{suffix}"
      return candidate unless User.exists?(name: candidate)
    end
  end

end
