class NotificationMailer < ApplicationMailer
  def mentioned(notification)
    post_id = notification.comment.post_id
    @mentioned_user_name = notification.user.name
    @comment_content = notification.comment.content
    @post_comments_url = post_comments_url(post_id)
    @mentioning_user_name = notification.comment.user.name

    mail to: notification.user.email, subject: '【お知らせ】メンション通知'
  end
end
