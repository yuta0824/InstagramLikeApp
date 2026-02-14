require 'rails_helper'

RSpec.describe NotificationMailer, type: :mailer do
  describe '#mentioned' do
    let(:mentioned_user) { create(:user, name: 'mentioned_user', email: 'mentioned@example.com') }
    let(:mentioning_user) { create(:user, name: 'mentioning_user') }
    let(:post) { create(:post, user: mentioning_user) }
    let(:comment) { create(:comment, user: mentioning_user, post: post, content: 'hello world') }
    let(:notification) { create(:notification, user: mentioned_user, comment: comment) }
    let(:mail) { described_class.mentioned(notification) }

    it '正しい宛先に送信する' do
      expect(mail.to).to eq(['mentioned@example.com'])
    end

    it '件名にメンション通知が含まれる' do
      expect(mail.subject).to eq('【お知らせ】メンション通知')
    end

    it '本文にコメント内容が含まれる' do
      expect(mail.body.encoded).to include('hello world')
    end
  end
end
