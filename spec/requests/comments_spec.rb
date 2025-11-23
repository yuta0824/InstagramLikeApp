require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  describe 'GET /posts/:post_id/comments' do
    let(:user) { create(:user) }
    let(:post) { create(:post) }
    let!(:comment) { create(:comment, post: post, content: 'hello') }

    context 'ログインしている場合' do
      before { sign_in user }

      it '200ステータスが返ってくる' do
        get post_comments_path(post)
        expect(response).to have_http_status(:ok)
      end

      it '指定した投稿のコメントが表示される' do
        other_comment = create(:comment, post: create(:post), content: 'should not show')
        get post_comments_path(post)
        expect(response.body).to include('hello')
        expect(response.body).not_to include('should not show')
      end

      it '古い順で並んでいる' do
        old = create(:comment, post: post, content: 'old', created_at: 1.day.ago)
        recent = create(:comment, post: post, content: 'recent', created_at: Time.current)
        get post_comments_path(post)
        expect(response.body.index('old')).to be < response.body.index('recent')
      end
    end

    context 'ログインしていない場合' do
      it 'ログイン画面に遷移する' do
        get post_comments_path(post)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
