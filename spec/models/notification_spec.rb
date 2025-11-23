require 'rails_helper'

RSpec.describe Notification, type: :model do
  include ActiveJob::TestHelper

  describe '一意バリデーション' do
    context 'user_idとcomment_idの組み合わせが一意の場合' do
      it '保存できる' do
        notification = build(:notification)

        expect(notification).to be_valid
        expect { notification.save! }.to change(Notification, :count).by(1)
      end
    end

    context 'user_idとcomment_idの組み合わせが一意ではない場合' do
      it '保存できない' do
        existing = create(:notification)
        duplicate = build(:notification, user: existing.user, comment: existing.comment)

        expect(duplicate).to be_invalid
        expect(duplicate.errors[:user_id]).to include('has already been taken')
      end
    end
  end

  describe 'メール送信' do
    around do |example|
      original_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :test
      clear_enqueued_jobs
      clear_performed_jobs
      ActionMailer::Base.deliveries.clear

      example.run
    ensure
      clear_enqueued_jobs
      clear_performed_jobs
      ActionMailer::Base.deliveries.clear
      ActiveJob::Base.queue_adapter = original_adapter
    end

    context 'Notificationが保存された場合' do
      it 'メールが送付される' do
        perform_enqueued_jobs do
          expect { create(:notification) }
            .to change { ActionMailer::Base.deliveries.size }.by(1)
        end
      end
    end
  end
end
