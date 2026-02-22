# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  content    :string(100)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  post_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_comments_on_post_id  (post_id)
#  index_comments_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:author) { create(:user) }

  describe 'content のバリデーション' do
    it '空文字の場合 invalid になる' do
      comment = build(:comment, user: author, content: '')
      expect(comment).to be_invalid
      expect(comment.errors[:content]).to be_present
    end
  end

  describe '文字数バリデーション' do
    context 'コメントが100文字以下の場合' do
      it '保存できる' do
        comment = build(:comment, user: author, content: 'a' * 100)
        expect(comment).to be_valid
      end
    end

    context 'コメントが100文字を超える場合' do
      it '保存できない' do
        comment = build(:comment, user: author, content: 'a' * 101)
        expect(comment).to be_invalid
        expect(comment.errors[:content]).to be_present
      end
    end
  end

  describe 'after_create_commit :notify_recipient' do
    let(:post_owner) { create(:user) }
    let(:target_post) { create(:post, user: post_owner) }

    it '投稿者に通知が作成される' do
      expect {
        create(:comment, user: author, post: target_post, content: 'nice!')
      }.to change(Notification, :count).by(1)

      notification = Notification.last
      expect(notification.notification_type).to eq('commented')
      expect(notification.recipient).to eq(post_owner)
      expect(notification.latest_actor_id).to eq(author.id)
      expect(notification.comment_content).to eq('nice!')
    end

    it '自分の投稿への自分のコメントでは通知が作成されない' do
      own_post = create(:post, user: author)
      expect {
        create(:comment, user: author, post: own_post, content: 'memo')
      }.not_to change(Notification, :count)
    end
  end

  describe '通知のカスケード削除' do
    let(:post_owner) { create(:user) }
    let(:target_post) { create(:post, user: post_owner) }

    it 'コメント削除で通知も削除される（dependent: :destroy）' do
      comment = create(:comment, user: author, post: target_post, content: 'hello')
      expect(Notification.count).to eq(1)

      comment.destroy!
      expect(Notification.count).to eq(0)
    end

    it '投稿削除でコメント通知も連鎖削除される' do
      create(:comment, user: author, post: target_post, content: 'hello')
      expect(Notification.count).to eq(1)

      target_post.destroy!
      expect(Notification.count).to eq(0)
    end
  end
end
