require 'rails_helper'

RSpec.describe SimulatorService do
  describe '.welcome_follow' do
    let!(:bots) { create_list(:user, 5, :bot) }
    let(:user) { build(:user) }

    context 'botでないユーザーの場合' do
      it 'botがユーザーをフォローする（3〜5人）' do
        user.save!
        follower_count = user.followers.count
        expect(follower_count).to be_between(3, 5)
        expect(user.followers).to all(satisfy(&:bot?))
      end

      it 'フォロー通知が生成される' do
        expect {
          user.save!
        }.to change(Notification, :count)
      end
    end

    context 'botユーザーの場合' do
      it '何もしない' do
        expect {
          create(:user, :bot)
        }.not_to change(Relationship, :count)
      end
    end

    context 'botが存在しない場合' do
      before { User.where(bot: true).destroy_all }

      it 'エラーにならず何もしない' do
        expect {
          create(:user)
        }.not_to change(Relationship, :count)
      end
    end

    context 'エラーが発生した場合' do
      it 'エラーを握りつぶしてログに記録する' do
        allow(Relationship).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
        user.save!

        expect(user.followers.count).to eq(0)
      end
    end
  end

  describe '.react_to_post' do
    let!(:bots) { create_list(:user, 5, :bot) }

    context '通常のユーザーの投稿の場合' do
      let(:author) { create(:user) }
      let(:post) { create(:post, user: author) }

      it 'いいねが2〜4件生成される' do
        SimulatorService.react_to_post(post)

        like_count = post.likes.count
        expect(like_count).to be_between(2, 4)
        expect(post.likes.map(&:user)).to all(satisfy(&:bot?))
      end

      it 'コメントが1〜2件生成される' do
        SimulatorService.react_to_post(post)

        comment_count = post.comments.count
        expect(comment_count).to be_between(1, 2)
        expect(post.comments.map(&:user)).to all(satisfy(&:bot?))
      end

      it 'コメント内容がテンプレートから選ばれる' do
        SimulatorService.react_to_post(post)

        post.comments.each do |comment|
          expect(SimulatorService.comment_templates).to include(comment.content)
        end
      end
    end

    context 'bot投稿の場合' do
      let(:bot_author) { bots.first }
      let(:bot_post) { create(:post, user: bot_author) }

      it 'いいねを生成しない' do
        expect {
          SimulatorService.react_to_post(bot_post)
        }.not_to change(Like, :count)
      end

      it 'コメントも生成しない' do
        expect {
          SimulatorService.react_to_post(bot_post)
        }.not_to change(Comment, :count)
      end
    end

    context 'エラーが発生した場合' do
      let(:author) { create(:user) }
      let(:post) { create(:post, user: author) }

      it 'エラーを握りつぶしてログに記録する' do
        allow(Like).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)

        expect {
          SimulatorService.react_to_post(post)
        }.not_to raise_error
      end
    end
  end

  describe '.delay_react_to_post' do
    let(:post) { create(:post) }

    it 'ReactJobを5秒後にエンキューする' do
      expect {
        SimulatorService.delay_react_to_post(post)
      }.to have_enqueued_job(SimulatorService::ReactJob)
        .with(post.id)
        .at(a_value_within(1.second).of(5.seconds.from_now))
    end
  end

  describe SimulatorService::ReactJob do
    let!(:bots) { create_list(:user, 5, :bot) }
    let(:author) { create(:user) }
    let(:post) { create(:post, user: author) }

    it 'SimulatorService.react_to_postを呼び出す' do
      allow(SimulatorService).to receive(:react_to_post)

      described_class.perform_now(post.id)

      expect(SimulatorService).to have_received(:react_to_post).with(post)
    end

    it '削除済み投稿はスキップする' do
      post_id = post.id
      post.destroy!

      expect {
        described_class.perform_now(post_id)
      }.not_to change(Like, :count)
    end
  end
end
