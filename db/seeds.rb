original_queue_adapter = ActiveJob::Base.queue_adapter
ActiveJob::Base.queue_adapter = :inline # Seed 時は同期実行に切り替えて Redis を使わない

begin
  Notification.delete_all
  Comment.delete_all
  Like.delete_all
  Relationship.delete_all
  Post.delete_all
  User.delete_all

  demo_users_list = []

  demo_users_data = [
    { name: 'sakura', email: 'sakura@example.com', avatar_idx: 1 },
    { name: 'kaito',   email: 'kaito@example.com',  avatar_idx: 2 },
    { name: 'yui',      email: 'yui@example.com',    avatar_idx: 3 },
    { name: 'ren',    email: 'ren@example.com',    avatar_idx: 4 },
    { name: 'mei',    email: 'mei@example.com',    avatar_idx: 5 },
    { name: 'haruto',   email: 'haruto@example.com', avatar_idx: 6 },
    { name: 'hina',       email: 'hina@example.com',   avatar_idx: 7 }
  ]

  demo_users_data.each_with_index do |u, index|
    password = Devise.friendly_token[0, 20]
    user = User.create!(
      email: u[:email],
      name: u[:name],
      provider: 'google_oauth2',
      uid: "seed-google-#{index + 1}",
      password: password,
      password_confirmation: password,
      bot: true
    )

    avatar_path = Rails.root.join("app/assets/images/icon_avatar#{u[:avatar_idx]}.webp")
    user.avatar.attach(io: File.open(avatar_path), filename: "icon_avatar#{u[:avatar_idx]}.webp") if File.exist?(avatar_path)
    demo_users_list << user
  end

  guest_password = Devise.friendly_token[0, 20]
  guest_user = User.create!(
    email: 'guest@example.com',
    name: 'guest',
    provider: 'google_oauth2',
    uid: 'seed-google-guest',
    password: guest_password,
    password_confirmation: guest_password
  )

  default_avatar_path = Rails.root.join('app/assets/images/icon_avatar-default.png')
  guest_user.avatar.attach(io: File.open(default_avatar_path), filename: 'icon_avatar-default.png') if File.exist?(default_avatar_path)

  captions = [
    '海に行きました', 'カフェに行きました', '紅葉を見に行きました', 'お寺に行きました', '山に登りました',
    'スポーツを観戦にきました', '新しいレシピに挑戦しました', '友達とランチを楽しみました', '自宅で映画鑑賞をしました', 'ペットと散歩に行きました',
    '美術館でアートに触れました', '人気のラーメン店に並びました', '夜景が綺麗な場所を見つけました', 'ドライブで遠出をしました', '読書に没頭する週末でした',
    'ガーデニングで花を植えました', '可愛い雑貨を購入しました', '地元の隠れ家的なバーを発見', '早朝ランニングで汗を流しました', '久しぶりに自炊をしました',
    'キャンプで自然を満喫しました', 'ボードゲームで盛り上がりました', '誕生日のサプライズをしました', '仕事の後のビールが最高です', '旅行の計画を立てています',
    '星空の写真を撮りました', 'フリマアプリで不要なものを出品', '新しい趣味を見つけました', '美味しいパン屋さんのパン', '友達の結婚式に出席しました',
    'DIYで家具を作りました', 'テイクアウトでピクニック気分', 'ゲームセンターでUFOキャッチャー', 'パーソナルトレーニングを開始', 'イルミネーションを見に行きました',
    '季節限定のスイーツを堪能', '古い写真を見返して懐かしむ', 'ボランティア活動に参加しました', '家族と水族館に行きました', '自宅の模様替えをしました',
    'ショッピングで衝動買い', 'スパでリラックスタイム', '音楽フェスで大熱狂', '地元の祭りに参加しました', '英語の勉強を始めました',
    '久しぶりに実家に帰省', '友人とオンラインゲーム', '車の洗車をしました', 'ベランダで日光浴', '手作りのアクセサリー',
    '健康診断の結果に一喜一憂', '新しいヘアスタイルに挑戦', 'お気に入りのコスメを紹介', '雨の日の過ごし方', '温泉で癒されました',
    'サウナで「ととのう」体験', 'デパ地下で高級食材を購入', '自転車で街を散策', '好きなアーティストのライブ映像', '初めてのふるさと納税',
    'マットレスを新調しました', '仕事中に食べた美味しいお菓子', '次の休みの予定を考える', 'ベランダ菜園の収穫', '資格取得の勉強中です',
    'お気に入りの香水を紹介', '朝ごはんを丁寧に作りました', '可愛い猫カフェに行きました', '写真展を見に行きました', '友達とカラオケに行きました',
    '家電製品の買い替え', '雨上がりの虹を見ました', '夕焼けがとても綺麗でした', '地元の図書館で本を借りました', 'ロードバイクでロングライド',
    '観葉植物を増やしました', '映画館で新作を鑑賞', '手芸に夢中な一日', '近所の公園でリフレッシュ', '冷凍食品のストックを紹介',
    '大掃除を頑張りました', '友人へのプレゼント選び', '美味しいコーヒー豆を見つけました', 'アロマキャンドルで癒される', '子どもと公園で遊びました',
    '新しいスニーカーを購入', '朝焼けの美しさに感動', 'パーキングエリアのグルメ', '郷土料理に挑戦しました', '週末はだらだら過ごしました',
    '株や投資の勉強を始めました', 'デジタルデトックス中', '友人と飲みに行きました', 'お洒落な花屋を見つけました', '新しいPCソフトを導入',
    '手帳をカスタマイズ', 'ネットフリックスで一気見', 'ふるさと納税の返礼品が届いた', '懐かしいアニメを見返す', '健康のためにスムージーを作った',
    '旅行先のお土産を紹介'
  ]

  all_posts_data = captions.each_with_index.map do |caption, i|
    {
      user: demo_users_list[i % demo_users_list.count],
      caption: caption,
      post_number: i + 1
    }
  end

  # created_at を先に割り振り、昇順でinsertすることでID順 = 時系列順を保証
  all_posts_data.sort_by! { |p| p[:user].id }

  now = Time.current
  hours_elapsed_today = [((now - now.beginning_of_day) / 1.hour).to_i, 1].max
  user_post_counts = Hash.new(0)

  all_posts_data.each do |post_data|
    user = post_data[:user]
    created_at = user_post_counts[user.id] == 0 ? now - rand(1..hours_elapsed_today).hours : now - rand(1..720).hours
    user_post_counts[user.id] += 1
    post_data[:created_at] = created_at
  end

  all_posts_data.sort_by! { |p| p[:created_at] }

  all_posts_data.each do |post_data|
    user = post_data[:user]
    post = user.posts.build(caption: post_data[:caption], created_at: post_data[:created_at], updated_at: post_data[:created_at])

    attached_count = 0
    (1..3).each do |img_suffix|
      path = Rails.root.join("db/seeds/images/posts/img_post#{post_data[:post_number]}-#{img_suffix}.jpg")
      if File.exist?(path)
        post.images.attach(io: File.open(path), filename: "img_post#{post_data[:post_number]}-#{img_suffix}.jpg")
        attached_count += 1
      end
    end

    if attached_count == 0
      (1..9).map { |i| "img_post#{i}.webp" }.sample(rand(1..3)).each do |img_filename|
        img_path = Rails.root.join("app/assets/images/#{img_filename}")
        post.images.attach(io: File.open(img_path), filename: img_filename) if File.exist?(img_path)
      end
    end

    post.save!
  end

  demo_users_list.each do |user|
    demo_users_list.reject { |u| u == user }.sample(rand(2..5)).each { |followed_user| user.follow!(followed_user) }
  end

  comments_list = YAML.safe_load_file(Rails.root.join('config/simulator/comments.yml'))

  Post.all.each do |post|
    if rand < 0.7
      rand(2..5).times do
        commenter = demo_users_list.reject { |u| u == post.user }.sample
        content = comments_list.sample
        post.comments.create!(user: commenter, content: content)
      end
    end
  end

  Post.all.each do |post|
    demo_users_list.reject { |u| u == post.user }.sample(rand(0..4)).each { |liker| post.likes.create!(user: liker) }
  end

ensure
  ActiveJob::Base.queue_adapter = original_queue_adapter
end
