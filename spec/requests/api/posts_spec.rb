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

   path '/api/posts/{id}' do
    parameter name: :id, in: :path, required: true, schema: { type: :integer }

    get '投稿詳細を取得する' do
      tags 'Post'
      produces 'application/json'

      let(:target_post) { create(:post) }
      let(:id) { target_post.id }
      let(:user) { create(:user) }

      response '200', '取得成功' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 caption: { type: :string, nullable: true },
                 imageUrls: { type: :array, items: { type: :string } },
                 userName: { type: :string },
                 userAvatar: { type: :string },
                 likedCount: { type: :integer },
                 likesSummary: { type: :string, nullable: true },
                 timeAgo: { type: :string },
                 isLiked: { type: :boolean },
                 comments: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       content: { type: :string },
                       userName: { type: :string },
                       userAvatar: { type: :string }
                     },
                     required: %w[content userName userAvatar]
                   }
                 }
               },
               required: %w[id imageUrls userName userAvatar likedCount timeAgo isLiked comments]

        before { sign_in user }

        run_test!
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
