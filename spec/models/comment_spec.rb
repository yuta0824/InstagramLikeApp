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
end
