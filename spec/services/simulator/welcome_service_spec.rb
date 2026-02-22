require 'rails_helper'

RSpec.describe Simulator::WelcomeService do
  let!(:bots) { create_list(:user, 5, :bot) }

  before do
    allow_any_instance_of(User).to receive(:run_welcome_simulation)
  end

  describe '#call' do
    context 'シミュレーターが有効の場合' do
      let(:user) { create(:user) }

      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('SIMULATOR_ENABLED', 'true').and_return('true')
      end

      it 'botがユーザーをフォローする' do
        described_class.new(user: user).call
        expect(user.followers.where(bot: true).count).to be_between(3, 5)
      end

      it 'ユーザーがbotをフォローする' do
        described_class.new(user: user).call
        expect(user.followings.where(bot: true).count).to be_between(2, 3)
      end

      it 'フォロー通知が生成される' do
        expect {
          described_class.new(user: user).call
        }.to change(Notification, :count)

        notifications = Notification.where(recipient: user, notification_type: :followed)
        expect(notifications.count).to be_between(3, 5)
      end
    end

    context 'シミュレーターが無効の場合' do
      let(:user) { create(:user) }

      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('SIMULATOR_ENABLED', 'true').and_return('false')
      end

      it '何もしない' do
        expect {
          described_class.new(user: user).call
        }.not_to change(Relationship, :count)
      end
    end

    context 'botユーザーの場合' do
      let(:bot_user) { create(:user, :bot) }

      it '何もしない' do
        expect {
          described_class.new(user: bot_user).call
        }.not_to change(Relationship, :count)
      end
    end
  end
end
