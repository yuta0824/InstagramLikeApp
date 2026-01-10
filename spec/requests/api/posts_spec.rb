require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Api::Posts', type: :request do
  path '/api/posts' do
    post '投稿を作成する' do
      tags 'Post'
      consumes 'multipart/form-data'
      produces 'application/json'

      parameter name: :caption,
                in: :formData,
                required: false,
                schema: { type: :string }
      parameter name: :images,
                in: :formData,
                required: true,
                schema: { type: :array, items: { type: :string, format: :binary } }

      let(:user) { create(:user) }
      let(:caption) { 'Hello world' }
      let(:images) { [fixture_file_upload('test.jpg', 'image/jpeg')] }

      response '201', '作成成功' do
        schema type: :object,
               properties: {
                 id: { type: :integer }
               },
               required: %w[id]

        let!(:posts_count_before) { Post.count }

        before { sign_in user }

        run_test! do
          expect(Post.count).to eq(posts_count_before + 1)
          expect(json_response['id']).to be_a(Integer)

          post = Post.find(json_response['id'])
          expect(post.user_id).to eq(user.id)
          expect(post.caption).to eq(caption)
          expect(post.images).to be_attached
          expect(post.images.size).to eq(images.size)
        end
      end

      response '401', '未ログイン' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               },
               required: %w[error]
        run_test!
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
