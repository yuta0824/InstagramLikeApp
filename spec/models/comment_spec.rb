require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:author) { create(:user) }

  describe 'メンション通知' do
    subject(:save_comment) { comment.save! }

    context 'コメントにメンションが含まれない場合' do
      let!(:comment) { build(:comment, user: author, content: 'hello world') }

      it '通知を作成しない' do
        expect { save_comment }
          .not_to change(Notification, :count)
      end
    end

    context '存在しないユーザー名をメンションした場合' do
      let!(:comment) { build(:comment, user: author, content: 'hi @nobody') }

      it '通知を作成しない' do
        expect { save_comment }
          .not_to change(Notification, :count)
      end
    end

    context 'コメントに既存ユーザーへのメンションが含まれる場合' do
      let!(:mentioned_user) { create(:user, name: 'alice') }
      let!(:comment) { build(:comment, user: author, content: 'hi @alice') }

      it 'メンション先のユーザーに通知を作成する' do
        expect { save_comment }
          .to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.user).to eq(mentioned_user)
        expect(notification.comment).to eq(comment)
      end
    end

    context '複数ユーザーをメンションした場合' do
      let!(:alice) { create(:user, name: 'alice') }
      let!(:bob) { create(:user, name: 'bob') }
      let(:comment) { build(:comment, user: author, content: '@alice hi @bob') }

      it 'メンションされた人数分の通知を作成する' do
        expect { save_comment }
          .to change(Notification, :count).by(2)

        expect(Notification.pluck(:user_id)).to match_array([alice.id, bob.id])
      end
    end

    context '同一ユーザーを複数回メンションした場合' do
      let!(:alice) { create(:user, name: 'alice') }
      let(:comment) { build(:comment, user: author, content: '@alice @alice hi') }

      it '重複しないよう通知を1件だけ作成する' do
        expect { save_comment }
          .to change(Notification, :count).by(1)
      end
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
