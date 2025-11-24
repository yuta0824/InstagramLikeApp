# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  name                   :string           not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_name                  (name) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :name,
            presence: true,
            uniqueness: true,
            length: { maximum: 20 },
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: 'only allows letters, digits, and underscores' }
  has_many :likes, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :following_relationships, foreign_key: 'follower_id', class_name: 'Relationship', dependent: :destroy
  has_many :followings, through: :following_relationships, source: :following
  has_many :follower_relationships, foreign_key: 'following_id', class_name: 'Relationship', dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower

  has_one_attached :avatar

  def avatar_url
    return ActionController::Base.helpers.asset_path('icon_avatar-default.png') unless avatar.attached?
    Rails.application.routes.url_helpers.rails_blob_path(avatar, only_path: true)
  end

  def follow!(target_user)
    following_relationships.create!(following_id: target_user.id)
  end

  def unfollow!(target_user)
    relation = following_relationships.find_by!(following_id: target_user.id)
    relation.destroy!
  end

  def following?(target_user)
    following_relationships.exists?(following_id: target_user.id)
  end

  def last_post_ago
    last_post = posts.order(:created_at).last
    return "Haven't posted yet" unless last_post

    "The last post was #{last_post.time_ago}"
  end
end
