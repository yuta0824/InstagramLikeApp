require 'rails_helper'
require 'nokogiri'

RSpec.describe 'Posts', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  describe 'GET /posts' do
    let(:user) { create(:user) }
    let(:followed_user) { create(:user) }
    let(:now) { Time.zone.local(2024, 1, 1, 12, 0, 0) }

    around do |example|
      travel_to(now) { example.run }
    end

    context 'ログインしている場合' do
      before do
        sign_in user
        user.follow!(followed_user)
      end

      it 'フォローしているユーザーの投稿のみ表示される' do
        followed_post = create_post_with_likes(user: followed_user, created_at: 1.hour.ago, likes_count: 10)
        unfollowed_post = create_post_with_likes(user: create(:user), created_at: 1.hour.ago, likes_count: 20)

        get posts_path

        ids = post_ids_from_response
        expect(ids).to include(followed_post.id)
        expect(ids).not_to include(unfollowed_post.id)
      end

      it '24時間以内の投稿のみ表示される（24時間ちょうどは含む）' do
        boundary_post = create_post_with_likes(user: followed_user, created_at: 24.hours.ago, likes_count: 5)
        recent_post = create_post_with_likes(user: followed_user, created_at: 1.hour.ago, likes_count: 4)
        old_post = create_post_with_likes(user: followed_user, created_at: 24.hours.ago - 1.second, likes_count: 10)

        get posts_path

        ids = post_ids_from_response
        expect(ids).to include(boundary_post.id, recent_post.id)
        expect(ids).not_to include(old_post.id)
      end

      it '対象からいいね上位5件だけを表示する' do
        posts = [
          create_post_with_likes(user: followed_user, created_at: 1.hour.ago, likes_count: 1),
          create_post_with_likes(user: followed_user, created_at: 2.hours.ago, likes_count: 2),
          create_post_with_likes(user: followed_user, created_at: 3.hours.ago, likes_count: 3),
          create_post_with_likes(user: followed_user, created_at: 4.hours.ago, likes_count: 4),
          create_post_with_likes(user: followed_user, created_at: 5.hours.ago, likes_count: 5),
          create_post_with_likes(user: followed_user, created_at: 6.hours.ago, likes_count: 100)
        ]

        get posts_path

        ids = post_ids_from_response
        expected_ids = posts.sort_by { |post| [-post.likes.count, post.created_at] }.first(5).map(&:id)
        expect(ids).to match_array(expected_ids)
        expect(ids).not_to include(posts.first.id)
        expect(ids.size).to eq(5)
      end

      it '表示順は新着順（いいね数が多い古い投稿があっても新しい方が先）' do
        older_most_liked = create_post_with_likes(user: followed_user, created_at: 3.hours.ago, likes_count: 100)
        newest_less_liked = create_post_with_likes(user: followed_user, created_at: 1.hour.ago, likes_count: 5)
        middle = create_post_with_likes(user: followed_user, created_at: 2.hours.ago, likes_count: 10)

        get posts_path

        expect(post_ids_from_response).to eq([newest_less_liked.id, middle.id, older_most_liked.id])
      end
    end

    context 'ログインしていない場合' do
      it 'ログイン画面に遷移する' do
        get posts_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  def create_post_with_likes(user:, created_at:, likes_count:)
    create(:post, user: user, created_at: created_at).tap do |post|
      create_list(:like, likes_count, post: post)
    end
  end

  def post_ids_from_response
    Nokogiri::HTML(response.body).css('[data-post-id]').map { |node| node['data-post-id'].to_i }
  end
end
