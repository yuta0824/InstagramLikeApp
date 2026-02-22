require 'rails_helper'

RSpec.describe Simulator::ReactiveActivityJob, type: :job do
  let!(:bots) { create_list(:user, 5, :bot) }
  let(:user) { create(:user) }
  let(:post_record) { create(:post, user: user) }

  describe '#perform' do
    it 'ReactiveActivityServiceを呼び出す' do
      service = instance_double(Simulator::ReactiveActivityService)
      allow(Simulator::ReactiveActivityService).to receive(:new).with(post: post_record).and_return(service)
      allow(service).to receive(:call)

      described_class.new.perform(post_record.id)

      expect(service).to have_received(:call)
    end

    it '削除済みの投稿はスキップする' do
      post_id = post_record.id
      post_record.destroy!

      expect {
        described_class.new.perform(post_id)
      }.not_to raise_error
    end
  end

  describe 'ジョブのエンキュー' do
    it '5秒後に実行されるようにスケジュールされる' do
      expect {
        described_class.set(wait: 5.seconds).perform_later(post_record.id)
      }.to have_enqueued_job(described_class).with(post_record.id)
    end
  end
end
