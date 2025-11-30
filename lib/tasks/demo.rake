namespace :demo do
  desc "Reset all demo data"
  task reset_all: :environment do
    Notification.delete_all
    Comment.delete_all
    Like.delete_all
    Relationship.delete_all
    Post.delete_all
    User.delete_all
    Rake::Task['db:seed'].invoke
  end
end
