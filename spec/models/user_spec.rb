# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  name                   :string           not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_name                  (name) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
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
