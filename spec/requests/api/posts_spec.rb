require 'rails_helper'
require 'swagger_helper'

POST_DETAIL_PROPERTIES = {
  id: { type: :integer },
  caption: { type: :string, nullable: true },
  imageUrls: { type: :array, items: { type: :string } },
  userName: { type: :string },
  userAvatar: { type: :string, nullable: true },
  likedCount: { type: :integer },
  likesSummary: { type: :string, nullable: true },
  timeAgo: { type: :string },
  isLiked: { type: :boolean },
  isOwn: { type: :boolean },
  mostRecentLikerName: { type: :string },
  comments: {
    type: :array,
    items: {
      type: :object,
      properties: {
        id: { type: :integer },
        content: { type: :string },
        userName: { type: :string },
        userAvatar: { type: :string, nullable: true },
        isOwner: { type: :boolean }
      },
      required: %w[id content userName userAvatar isOwner]
    }
  }
}.freeze

POST_DETAIL_REQUIRED = %w[
  id
  imageUrls
  userName
  userAvatar
  likedCount
  timeAgo
  isLiked
  isOwn
  mostRecentLikerName
  comments
].freeze

RSpec.describe 'Api::Posts', type: :request do
  path '/api/posts' do
    get '投稿一覧を取得する' do
      tags 'Post'
      produces 'application/json'

      let(:user) { create(:user) }
      let!(:posts) { create_list(:post, 2) }

      response '200', '取得成功' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: POST_DETAIL_PROPERTIES,
                 required: POST_DETAIL_REQUIRED
               }

        before { sign_in user }

        run_test! do
          expect(json_response.size).to eq(posts.size)
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
         properties: POST_DETAIL_PROPERTIES,
         required: POST_DETAIL_REQUIRED

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
               properties: POST_DETAIL_PROPERTIES,
               required: POST_DETAIL_REQUIRED

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

    patch '投稿を更新する' do
      tags 'Post'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :post, in: :body, schema: {
        type: :object,
        properties: {
          post: {
            type: :object,
            properties: {
              caption: { type: :string }
            }
          }
        }
      }

      let(:user) { create(:user) }
      let(:target_post) { create(:post, user: user, caption: 'before') }
      let(:id) { target_post.id }
      let(:post) { { post: { caption: 'after' } } }

      response '200', '更新成功' do
        schema type: :object,
         properties: POST_DETAIL_PROPERTIES,
         required: POST_DETAIL_REQUIRED

        before { sign_in user }

        run_test! do
          expect(target_post.reload.caption).to eq('after')
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

    delete '投稿を削除する' do
      tags 'Post'
      produces 'application/json'

      let(:user) { create(:user) }
      let(:target_post) { create(:post, user: user) }
      let(:id) { target_post.id }

      response '204', '削除成功' do
        before { sign_in user }

        run_test! do
          expect(Post.exists?(target_post.id)).to be false
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

  describe '認可・バリデーション' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:owners_post) { create(:post, user: owner) }

    context 'PATCH /api/posts/:id 他人の投稿を更新しようとした場合' do
      before { sign_in other_user }

      it '404を返す' do
        patch "/api/posts/#{owners_post.id}", params: { post: { caption: 'hacked' } }, as: :json
        expect(response).to have_http_status(:not_found)
        expect(owners_post.reload.caption).not_to eq('hacked')
      end
    end

    context 'DELETE /api/posts/:id 他人の投稿を削除しようとした場合' do
      before { sign_in other_user }

      it '404を返す' do
        owners_post # ensure created
        expect {
          delete "/api/posts/#{owners_post.id}"
        }.not_to change(Post, :count)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'PATCH /api/posts/:id 存在しないIDを指定した場合' do
      before { sign_in owner }

      it '404を返す' do
        patch '/api/posts/999999', params: { post: { caption: 'test' } }, as: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'POST /api/posts 画像なしで投稿した場合' do
      before { sign_in owner }

      it '422を返す' do
        post '/api/posts', params: { caption: 'no image' }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'レスポンスフィールド検証' do
    let(:user) { create(:user) }

    context 'GET /api/posts/:id 自分の投稿の場合' do
      let(:my_post) { create(:post, user: user) }

      before { sign_in user }

      it 'isOwn が true を返す' do
        get "/api/posts/#{my_post.id}"
        expect(json_response['isOwn']).to be true
      end
    end

    context 'GET /api/posts/:id いいね済みの投稿の場合' do
      let(:target) { create(:post) }

      before do
        create(:like, user: user, post: target)
        sign_in user
      end

      it 'isLiked が true で likedCount が正しい値を返す' do
        get "/api/posts/#{target.id}"
        expect(json_response['isLiked']).to be true
        expect(json_response['likedCount']).to eq(1)
      end
    end

    context 'GET /api/posts 最大件数制限' do
      before do
        create_list(:post, 25)
        sign_in user
      end

      it '最大20件を返す' do
        get '/api/posts'
        expect(json_response.size).to eq(20)
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
