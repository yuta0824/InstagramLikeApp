class NotificationMailer < ApplicationMailer
  def mentioned(notification)
    @mentioned_user_name = notification.user.name
    @comment_content = notification.comment.content
    @mentioning_user_name = notification.comment.user.name
    @post_id = notification.comment.post_id

    mail to: notification.user.email, subject: '【お知らせ】メンション通知'
  end
end
