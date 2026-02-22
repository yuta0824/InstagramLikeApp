require 'rails_helper'

RSpec.describe Simulator::ReactiveActivityService do
  let!(:bots) { create_list(:user, 5, :bot) }
  let(:user) { create(:user) }
  let(:post_record) { create(:post, user: user) }

  describe '#call' do
    context 'シミュレーターが有効の場合' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('SIMULATOR_ENABLED', 'true').and_return('true')
      end

      it 'botによるいいねが生成される' do
        expect {
          described_class.new(post: post_record).call
        }.to change(Like, :count).by_at_least(2)

        expect(post_record.likes.joins(:user).where(users: { bot: true }).count).to be_between(2, 4)
      end

      it 'botによるコメントが生成される' do
        expect {
          described_class.new(post: post_record).call
        }.to change(Comment, :count).by_at_least(1)

        expect(post_record.comments.joins(:user).where(users: { bot: true }).count).to be_between(1, 2)
      end

      it 'いいね通知が生成される' do
        described_class.new(post: post_record).call

        liked_notifications = Notification.where(
          recipient: user,
          notification_type: :liked,
          target_post_id: post_record.id
        )
        expect(liked_notifications.count).to eq(1)
      end

      it 'コメント通知が生成される' do
        described_class.new(post: post_record).call

        commented_notifications = Notification.where(
          recipient: user,
          notification_type: :commented,
          target_post_id: post_record.id
        )
        expect(commented_notifications.count).to be_between(1, 2)
      end

      it '投稿者自身にはいいね・コメントしない' do
        described_class.new(post: post_record).call

        expect(post_record.likes.where(user: user)).to be_empty
        expect(post_record.comments.where(user: user)).to be_empty
      end
    end

    context 'シミュレーターが無効の場合' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('SIMULATOR_ENABLED', 'true').and_return('false')
      end

      it '何もしない' do
        expect {
          described_class.new(post: post_record).call
        }.not_to change(Like, :count)
      end
    end

    context 'botユーザーの投稿の場合' do
      let(:bot_user) { create(:user, :bot) }
      let(:bot_post) { create(:post, user: bot_user) }

      it '何もしない' do
        expect {
          described_class.new(post: bot_post).call
        }.not_to change(Like, :count)
      end
    end
  end
end
