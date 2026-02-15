# == Schema Information
#
# Table name: notifications
#
#  id                :bigint           not null, primary key
#  actor_count       :integer          default(1), not null
#  comment_content   :string
#  notifiable_type   :string
#  notification_type :string           not null
#  read              :boolean          default(FALSE), not null
#  recent_actor_ids  :jsonb            not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  latest_actor_id   :bigint
#  notifiable_id     :bigint
#  recipient_id      :bigint           not null
#  target_post_id    :bigint
#
# Indexes
#
#  idx_notifications_liked_unique                            (recipient_id,notification_type,target_post_id) UNIQUE WHERE ((notification_type)::text = 'liked'::text)
#  index_notifications_on_latest_actor_id                    (latest_actor_id)
#  index_notifications_on_notifiable_type_and_notifiable_id  (notifiable_type,notifiable_id)
#  index_notifications_on_recipient_id                       (recipient_id)
#  index_notifications_on_recipient_id_and_read              (recipient_id,read)
#  index_notifications_on_recipient_id_and_updated_at        (recipient_id,updated_at)
#  index_notifications_on_target_post_id                     (target_post_id)
#
# Foreign Keys
#
#  fk_rails_...  (latest_actor_id => users.id) ON DELETE => nullify
#  fk_rails_...  (recipient_id => users.id)
#  fk_rails_...  (target_post_id => posts.id) ON DELETE => nullify
#
require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:actor) { create(:user) }
  let(:recipient) { create(:user) }
  let(:post_record) { create(:post, user: recipient) }

  describe '.notify_if_needed' do
    context 'liked' do
      let(:like) { create(:like, user: actor, post: post_record) }

      it '通知を作成する' do
        expect {
          described_class.notify_if_needed(actor: actor, recipient: recipient, notifiable: like, notification_type: :liked)
        }.to change(described_class, :count).by(1)

        notification = described_class.last
        expect(notification.notification_type).to eq('liked')
        expect(notification.recipient).to eq(recipient)
        expect(notification.latest_actor_id).to eq(actor.id)
        expect(notification.target_post_id).to eq(post_record.id)
        expect(notification.actor_count).to eq(1)
        expect(notification.recent_actor_ids).to eq([actor.id])
      end

      it '同じ投稿への2回目のいいねは既存行を更新する' do
        first_like = create(:like, user: actor, post: post_record)
        described_class.notify_if_needed(actor: actor, recipient: recipient, notifiable: first_like, notification_type: :liked)

        second_actor = create(:user)
        second_like = create(:like, user: second_actor, post: post_record)

        expect {
          described_class.notify_if_needed(actor: second_actor, recipient: recipient, notifiable: second_like, notification_type: :liked)
        }.not_to change(described_class, :count)

        notification = described_class.last
        expect(notification.actor_count).to eq(2)
        expect(notification.latest_actor_id).to eq(second_actor.id)
        expect(notification.recent_actor_ids).to eq([second_actor.id, actor.id])
        expect(notification.read).to be(false)
      end

      it '既読済み通知に新しいいいねが来たら未読に戻す' do
        first_like = create(:like, user: actor, post: post_record)
        described_class.notify_if_needed(actor: actor, recipient: recipient, notifiable: first_like, notification_type: :liked)
        described_class.last.update!(read: true)

        second_actor = create(:user)
        second_like = create(:like, user: second_actor, post: post_record)
        described_class.notify_if_needed(actor: second_actor, recipient: recipient, notifiable: second_like, notification_type: :liked)

        expect(described_class.last.read).to be(false)
      end
    end

    context 'commented' do
      let(:comment) { create(:comment, user: actor, post: post_record) }

      it '通知を作成する' do
        expect {
          described_class.notify_if_needed(actor: actor, recipient: recipient, notifiable: comment, notification_type: :commented)
        }.to change(described_class, :count).by(1)

        notification = described_class.last
        expect(notification.notification_type).to eq('commented')
        expect(notification.comment_content).to eq(comment.content)
        expect(notification.target_post_id).to eq(post_record.id)
      end

      it '同じ投稿への2回目のコメントでも新しい通知行を作成する' do
        first_comment = create(:comment, user: actor, post: post_record, content: 'first')
        described_class.notify_if_needed(actor: actor, recipient: recipient, notifiable: first_comment, notification_type: :commented)

        second_comment = create(:comment, user: actor, post: post_record, content: 'second')

        expect {
          described_class.notify_if_needed(actor: actor, recipient: recipient, notifiable: second_comment, notification_type: :commented)
        }.to change(described_class, :count).by(1)
      end
    end

    context 'followed' do
      let(:relationship) { create(:relationship, follower: actor, following: recipient) }

      it '通知を作成する' do
        expect {
          described_class.notify_if_needed(actor: actor, recipient: recipient, notifiable: relationship, notification_type: :followed)
        }.to change(described_class, :count).by(1)

        notification = described_class.last
        expect(notification.notification_type).to eq('followed')
        expect(notification.target_post_id).to be_nil
      end
    end

    context '自己アクション' do
      it '自分自身への通知はスキップされる' do
        like = create(:like, user: recipient, post: post_record)

        expect {
          described_class.notify_if_needed(actor: recipient, recipient: recipient, notifiable: like, notification_type: :liked)
        }.not_to change(described_class, :count)
      end
    end
  end

  describe '.retract_if_needed' do
    it 'actor_countが1の場合は通知を削除する' do
      like = create(:like, user: actor, post: post_record)
      described_class.notify_if_needed(actor: actor, recipient: recipient, notifiable: like, notification_type: :liked)

      expect {
        described_class.retract_if_needed(actor: actor, recipient: recipient, target_post_id: post_record.id)
      }.to change(described_class, :count).by(-1)
    end

    it 'actor_countが2以上の場合はcountを減算する' do
      first_like = create(:like, user: actor, post: post_record)
      described_class.notify_if_needed(actor: actor, recipient: recipient, notifiable: first_like, notification_type: :liked)

      second_actor = create(:user)
      second_like = create(:like, user: second_actor, post: post_record)
      described_class.notify_if_needed(actor: second_actor, recipient: recipient, notifiable: second_like, notification_type: :liked)

      expect {
        described_class.retract_if_needed(actor: actor, recipient: recipient, target_post_id: post_record.id)
      }.not_to change(described_class, :count)

      notification = described_class.last
      expect(notification.actor_count).to eq(1)
      expect(notification.recent_actor_ids).to eq([second_actor.id])
    end

    it '該当する通知がない場合は何もしない' do
      expect {
        described_class.retract_if_needed(actor: actor, recipient: recipient, target_post_id: 999)
      }.not_to change(described_class, :count)
    end

    it 'latest_actorを取消した場合、次のアクターに更新される' do
      first_like = create(:like, user: actor, post: post_record)
      described_class.notify_if_needed(actor: actor, recipient: recipient, notifiable: first_like, notification_type: :liked)

      second_actor = create(:user)
      second_like = create(:like, user: second_actor, post: post_record)
      described_class.notify_if_needed(actor: second_actor, recipient: recipient, notifiable: second_like, notification_type: :liked)

      described_class.retract_if_needed(actor: second_actor, recipient: recipient, target_post_id: post_record.id)

      notification = described_class.last
      expect(notification.latest_actor_id).to eq(actor.id)
    end
  end

  describe 'エラー耐性' do
    it 'notify_if_neededで例外が発生しても呼び出し元にraiseしない' do
      allow(described_class).to receive(:upsert_liked).and_raise(StandardError, 'DB error')
      like = create(:like, user: actor, post: post_record)

      expect {
        described_class.notify_if_needed(actor: actor, recipient: recipient, notifiable: like, notification_type: :liked)
      }.not_to raise_error
    end

    it 'retract_if_neededで例外が発生しても呼び出し元にraiseしない' do
      like = create(:like, user: actor, post: post_record)
      described_class.notify_if_needed(actor: actor, recipient: recipient, notifiable: like, notification_type: :liked)

      allow(described_class).to receive(:find_by).and_raise(StandardError, 'DB error')

      expect {
        described_class.retract_if_needed(actor: actor, recipient: recipient, target_post_id: post_record.id)
      }.not_to raise_error
    end
  end

  describe 'actor_count重複防止' do
    it '同じアクターが再度いいねしてもactor_countが増加しない' do
      like = create(:like, user: actor, post: post_record)
      described_class.notify_if_needed(actor: actor, recipient: recipient, notifiable: like, notification_type: :liked)

      second_actor = create(:user)
      second_like = create(:like, user: second_actor, post: post_record)
      described_class.notify_if_needed(actor: second_actor, recipient: recipient, notifiable: second_like, notification_type: :liked)

      # actorが再度recent_actor_idsに含まれる状態でupsertされた場合
      notification = described_class.last
      expect(notification.actor_count).to eq(2)

      # 同じactorで再度notify（recent_actor_idsに既に存在）
      third_like = build(:like, user: actor, post: post_record)
      allow(third_like).to receive(:post_id).and_return(post_record.id)
      described_class.send(:upsert_liked, actor: actor, recipient: recipient, notifiable: third_like)

      notification.reload
      expect(notification.actor_count).to eq(2)
      expect(notification.recent_actor_ids).to eq([actor.id, second_actor.id])
    end
  end
end
