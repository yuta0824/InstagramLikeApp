# == Schema Information
#
# Table name: posts
#
#  id         :bigint           not null, primary key
#  caption    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_posts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:owner) { create(:user) }

  context '画像が3枚以下の場合' do
    it '保存できる' do
      post = build(:post, user: owner, images_count: 3)
      expect(post).to be_valid
    end
  end

  context '画像が添付されていない場合' do
    it '保存できない' do
      post = build(:post, user: owner, images_count: 0)
      expect(post).to be_invalid
      expect(post.errors[:images]).to include(/must be selected/i)
    end
  end

  context '画像が4枚の場合' do
    it '保存できない' do
      post = build(:post, user: owner, images_count: 4)
      expect(post).to be_invalid
      expect(post.errors[:images]).not_to be_empty
    end
  end

  context 'キャプションが100文字を超える場合' do
    it '保存できない' do
      post = build(:post, user: owner, caption: 'a' * 101)
      expect(post).to be_invalid
      expect(post.errors[:caption]).to include('is too long (maximum is 100 characters)')
    end
  end

  context '画像がちょうど1枚の場合' do
    it '保存できる' do
      post = build(:post, user: owner, images_count: 1)
      expect(post).to be_valid
    end
  end

  context 'キャプションが nil の場合' do
    it '保存できる（optional）' do
      post = build(:post, user: owner, caption: nil)
      expect(post).to be_valid
    end
  end

  context 'キャプションがちょうど100文字の場合' do
    it '保存できる' do
      post = build(:post, user: owner, caption: 'a' * 100)
      expect(post).to be_valid
    end
  end

  describe 'dependent: :destroy' do
    it 'Post削除で likes も削除される' do
      post = create(:post, user: owner)
      create_list(:like, 2, post: post)
      expect { post.destroy! }.to change(Like, :count).by(-2)
    end

    it 'Post削除で comments も削除される' do
      post = create(:post, user: owner)
      create_list(:comment, 2, post: post)
      expect { post.destroy! }.to change(Comment, :count).by(-2)
    end
  end

  describe '#owned_by?' do
    let(:post) { create(:post, user: owner) }
    let(:other_user) { create(:user) }

    it 'オーナーの場合 true を返す' do
      expect(post.owned_by?(owner)).to be true
    end

    it '他人の場合 false を返す' do
      expect(post.owned_by?(other_user)).to be false
    end

    it 'nil の場合 false を返す' do
      expect(post.owned_by?(nil)).to be false
    end
  end

  describe '#liked_by?' do
    let(:post) { create(:post, user: owner) }
    let(:liker) { create(:user) }

    it 'いいね済みユーザーの場合 true を返す' do
      create(:like, user: liker, post: post)
      expect(post.liked_by?(liker)).to be true
    end

    it '未いいねユーザーの場合 false を返す' do
      expect(post.liked_by?(liker)).to be false
    end

    it 'nil の場合 false を返す' do
      expect(post.liked_by?(nil)).to be false
    end
  end

  describe '#liked_count' do
    let(:post) { create(:post, user: owner) }

    it 'いいねなしの場合 0 を返す' do
      expect(post.liked_count).to eq(0)
    end

    it '複数いいねの場合 正しいカウントを返す' do
      create_list(:like, 3, post: post)
      expect(post.liked_count).to eq(3)
    end
  end

  describe '#most_recent_liker_name' do
    let(:post) { create(:post, user: owner) }

    it 'いいねありの場合 最新のユーザー名を返す' do
      create(:like, post: post)
      latest_liker = create(:user, name: 'latest_liker')
      create(:like, user: latest_liker, post: post)
      expect(post.most_recent_liker_name).to eq('latest_liker')
    end

    it 'いいねなしの場合 nil を返す' do
      expect(post.most_recent_liker_name).to be_nil
    end
  end

  describe '#likes_summary' do
    let(:post) { create(:post, user: owner) }

    it 'いいねなしの場合 nil を返す' do
      expect(post.likes_summary).to be_nil
    end

    it '1件の場合 single_like メッセージを返す' do
      liker = create(:user, name: 'alice')
      create(:like, user: liker, post: post)
      expect(post.likes_summary).to eq(I18n.t('models.post.single_like', name: 'alice'))
    end

    it '複数件の場合 multiple_likes メッセージを返す' do
      create(:like, post: post)
      latest_liker = create(:user, name: 'bob')
      create(:like, user: latest_liker, post: post)
      expect(post.likes_summary).to eq(I18n.t('models.post.multiple_likes', name: 'bob', count: 1))
    end

    it '3件の場合 count が 2 の multiple_likes メッセージを返す' do
      create_list(:like, 2, post: post)
      last_liker = create(:user, name: 'last_liker')
      create(:like, user: last_liker, post: post)
      expect(post.likes_summary).to eq(I18n.t('models.post.multiple_likes', name: 'last_liker', count: 2))
    end
  end

  describe '#time_ago' do
    include ActiveSupport::Testing::TimeHelpers
    around { |example| freeze_time { example.run } }

    it '60秒未満の場合 "now" を返す' do
      post = create(:post, user: owner, created_at: 30.seconds.ago)
      expect(post.time_ago).to eq(I18n.t('models.post.now'))
    end

    it '1〜59分の場合 分表示を返す' do
      post = create(:post, user: owner, created_at: 5.minutes.ago)
      expect(post.time_ago).to eq(I18n.t('models.post.minutes_ago', count: 5))
    end

    it '1〜23時間の場合 時間表示を返す' do
      post = create(:post, user: owner, created_at: 3.hours.ago)
      expect(post.time_ago).to eq(I18n.t('models.post.hours_ago', count: 3))
    end

    it '24時間以上の場合 日付フォーマットを返す' do
      post = create(:post, user: owner, created_at: 2.days.ago)
      expect(post.time_ago).to eq(2.days.ago.strftime('%Y/%m/%d'))
    end

    it 'ちょうど60秒の場合 分表示に切り替わる' do
      post = create(:post, user: owner, created_at: 60.seconds.ago)
      expect(post.time_ago).to eq(I18n.t('models.post.minutes_ago', count: 1))
    end

    it '23時間59分の場合 時間表示を返す（日付に切り替わらない）' do
      post = create(:post, user: owner, created_at: (23.hours + 59.minutes).ago)
      expect(post.time_ago).to eq(I18n.t('models.post.hours_ago', count: 23))
    end
  end

end
