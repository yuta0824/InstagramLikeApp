# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  bot                    :boolean          default(FALSE), not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  name                   :string           not null
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  uid                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_name                  (name) UNIQUE
#  index_users_on_provider_and_uid      (provider,uid) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Deviseで保存する時' do
    let!(:user) { create(:user) }

    context 'name と email と password が入力されている場合' do
      it 'user を保存できる' do
        expect(user).to be_valid
      end
    end

    context 'name が空の場合' do
      let(:user) { build(:user, name: nil) }

      it 'user を保存できない' do
        expect(user).to be_invalid
      end
    end

    context 'name が空文字の場合' do
      let(:user) { build(:user, name: '') }

      it 'user を保存できない' do
        expect(user).to be_invalid
      end
    end

    context 'name が重複している場合' do
      let!(:user) { create(:user, name: 'tanaka') }
      let(:duplicate_user) { build(:user, name: 'tanaka') }

      it 'user を保存できない' do
        expect(duplicate_user).to be_invalid
      end
    end

    context 'name が20文字を超える場合' do
      let(:user) { build(:user, name: 'a' * 21 ) }

      it 'user を保存できない' do
        expect(user).to be_invalid
      end
    end

    context 'name に無効な文字が含まれる場合' do
      ['john-doe', 'john.doe', 'john@doe', 'john doe', 'user!', '田中太郎'].each do |invalid_name|
        it "#{invalid_name.inspect} は無効" do
          user = build(:user, name: invalid_name)

          expect(user).to be_invalid
          expect(user.errors[:name]).to be_present
        end
      end
    end

    context 'email が空の場合' do
      let(:user) { build(:user, email: nil) }

      it 'user を保存できない' do
        expect(user).to be_invalid
      end
    end

    context 'email が空文字の場合' do
      let(:user) { build(:user, email: '') }

      it 'user を保存できない' do
        expect(user).to be_invalid
      end
    end

    context 'email が重複している場合' do
      let!(:user) { create(:user, email: 'tanaka@gmail.com') }
      let(:duplicate_user) { build(:user, email: 'tanaka@gmail.com') }

      it 'user を保存できない' do
        expect(duplicate_user).to be_invalid
      end
    end

    context 'email のフォーマットが不正な場合' do
      let(:user) { build(:user, email: 'plainaddress') }

      it 'user を保存できない' do
        expect(user).to be_invalid
      end
    end

    context 'password が空の場合' do
      let(:user) { build(:user, password: nil) }

      it 'user を保存できない' do
        expect(user).to be_invalid
      end
    end

    context 'password が空文字の場合' do
      let(:user) { build(:user, password: '') }

      it 'user を保存できない' do
        expect(user).to be_invalid
      end
    end

    context 'password が6文字未満の場合' do
      let(:user) { build(:user, password: '12345' ) }

      it 'user を保存できない' do
        expect(user).to be_invalid
      end
    end
  end

  describe 'OAuthログイン時' do
    def build_auth(email:, uid: 'uid-123')
      OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: uid,
        info: {
          email: email
        }
      )
    end

    it 'provider/uid/email を設定してユーザーを作成する' do
      auth = build_auth(email: 'oauth_user@example.com')
      user = described_class.from_omniauth(auth)

      expect(user).to be_persisted
      expect(user.provider).to eq('google_oauth2')
      expect(user.uid).to eq('uid-123')
      expect(user.email).to eq('oauth_user@example.com')
      expect(user.name).to be_present
    end

    it '既存ユーザーの場合は名前とパスワードを変更しない' do
      existing_user = create(:user, provider: 'google_oauth2', uid: 'uid-123', name: 'existing_user', email: 'existing_user@example.com')
      original_password = existing_user.encrypted_password

      auth = build_auth(email: 'oauth_user@example.com')
      user = described_class.from_omniauth(auth)

      expect(user.id).to eq(existing_user.id)
      expect(user.name).to eq('existing_user')
      expect(user.encrypted_password).to eq(original_password)
    end

    it '同名がある場合は末尾にサフィックスを付ける' do
      create(:user, name: 'oauth_user', email: 'oauth_user_taken@example.com')
      auth = build_auth(email: 'oauth_user@example.com', uid: 'uid-456')
      user = described_class.from_omniauth(auth)

      expect(user.name).to match(/\Aoauth_user_[0-9a-f]{6}\z/)
    end
  end

  context 'name がちょうど20文字の場合' do
    it '保存できる' do
      user = build(:user, name: 'a' * 20)
      expect(user).to be_valid
    end
  end

  context 'name がちょうど1文字の場合' do
    it '保存できる' do
      user = build(:user, name: 'a')
      expect(user).to be_valid
    end
  end

  describe 'dependent: :destroy' do
    let(:user) { create(:user) }

    it 'User削除で posts も削除される' do
      create_list(:post, 2, user: user)
      expect { user.destroy! }.to change(Post, :count).by(-2)
    end

    it 'User削除で likes も削除される' do
      post = create(:post)
      create(:like, user: user, post: post)
      expect { user.destroy! }.to change(Like, :count).by(-1)
    end

    it 'User削除で comments も削除される' do
      post = create(:post)
      create(:comment, user: user, post: post)
      expect { user.destroy! }.to change(Comment, :count).by(-1)
    end

    it 'User削除で relationships（follower/following）も削除される' do
      other = create(:user)
      user.follow!(other)
      other.follow!(user)
      expect { user.destroy! }.to change(Relationship, :count).by(-2)
    end
  end

  describe '.search_by_name' do
    let!(:alice) { create(:user, name: 'alice') }
    let!(:bob) { create(:user, name: 'bob_alice') }
    let!(:charlie) { create(:user, name: 'charlie') }

    it '部分一致検索できる' do
      result = described_class.search_by_name('alice')
      expect(result).to include(alice, bob)
      expect(result).not_to include(charlie)
    end

    it '大文字小文字を区別しない' do
      result = described_class.search_by_name('ALICE')
      expect(result).to include(alice)
    end
  end

  describe '.recently_active' do
    let!(:active_user) { create(:user) }
    let!(:inactive_user) { create(:user) }

    before do
      create(:post, user: active_user, created_at: 1.hour.ago)
      create(:post, user: inactive_user, created_at: 2.days.ago)
    end

    it '期間内に投稿したユーザーを返す' do
      result = described_class.recently_active(within: 24.hours)
      expect(result).to include(active_user)
      expect(result).not_to include(inactive_user)
    end

    it 'limit パラメータを反映する' do
      3.times { create(:post, user: create(:user), created_at: 1.hour.ago) }
      result = described_class.recently_active(limit: 2, within: 24.hours)
      expect(result.to_a.size).to eq(2)
    end
  end

  describe '#follow!' do
    let(:user) { create(:user) }
    let(:target) { create(:user) }

    it 'フォロー関係を作成する' do
      expect { user.follow!(target) }.to change(Relationship, :count).by(1)
      expect(user.followings).to include(target)
    end

    it '既にフォロー済みの場合 例外が発生する' do
      user.follow!(target)
      expect { user.follow!(target) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#unfollow!' do
    let(:user) { create(:user) }
    let(:target) { create(:user) }

    it 'フォロー解除する' do
      user.follow!(target)
      expect { user.unfollow!(target) }.to change(Relationship, :count).by(-1)
    end

    it '未フォロー状態で解除すると RecordNotFound が発生する' do
      expect { user.unfollow!(target) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#avatar_url' do
    let(:user) { create(:user) }

    it 'アバター未添付の場合 nil を返す' do
      expect(user.avatar_url).to be_nil
    end

    it 'アバター添付済みの場合 URL文字列を返す' do
      user.avatar.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/test.jpg')),
        filename: 'test.jpg',
        content_type: 'image/jpeg'
      )
      expect(user.avatar_url).to be_a(String)
      expect(user.avatar_url).to include('test.jpg')
    end
  end

  describe '.build_unique_name' do
    def build_auth(email:)
      OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: SecureRandom.uuid,
        info: { email: email }
      )
    end

    it '特殊文字を _ に置換する' do
      auth = build_auth(email: 'john.doe+test@example.com')
      name = described_class.build_unique_name(auth)
      expect(name).to match(/\A[a-zA-Z0-9_]+\z/)
      expect(name).to include('john_doe_test')
    end

    it '20文字に切り詰める' do
      auth = build_auth(email: 'a' * 30 + '@example.com')
      name = described_class.build_unique_name(auth)
      expect(name.length).to be <= 20
    end
  end
end
