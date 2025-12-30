# == Schema Information
#
# Table name: jwt_denylists
#
#  id         :bigint           not null, primary key
#  exp        :datetime         not null
#  jti        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_jwt_denylists_on_jti  (jti) UNIQUE
#
require 'rails_helper'

RSpec.describe JwtDenylist, type: :model do
  describe 'factory' do
    it '有効なファクトリである' do
      expect(build(:jwt_denylist)).to be_valid
    end
  end

  describe '.jwt_revoked?' do
    let(:payload) do
      {
        'jti' => 'test-jti',
        'exp' => 1.hour.from_now.to_i
      }
    end

    it 'denylist に存在しない jti なら false を返す' do
      expect(described_class.jwt_revoked?(payload, nil)).to be(false)
    end

    it 'denylist に存在する jti なら true を返す' do
      create(:jwt_denylist, jti: payload['jti'], exp: Time.at(payload['exp']))

      expect(described_class.jwt_revoked?(payload, nil)).to be(true)
    end
  end

  describe '.revoke_jwt' do
    let(:payload) do
      {
        'jti' => 'revoke-jti',
        'exp' => 1.hour.from_now.to_i
      }
    end

    it 'jti と exp を持つ denylist レコードを作成する' do
      expect { described_class.revoke_jwt(payload, nil) }
        .to change(described_class, :count).by(1)

      record = described_class.last
      expect(record.jti).to eq(payload['jti'])
      expect(record.exp.to_i).to eq(payload['exp'])
    end
  end
end
