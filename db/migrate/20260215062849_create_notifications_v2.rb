class CreateNotificationsV2 < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications do |t|
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.string :notification_type, null: false
      t.string :notifiable_type
      t.bigint :notifiable_id
      t.references :target_post, foreign_key: { to_table: :posts, on_delete: :nullify }
      t.references :latest_actor, foreign_key: { to_table: :users, on_delete: :nullify }
      t.jsonb :recent_actor_ids, null: false, default: []
      t.integer :actor_count, null: false, default: 1
      t.string :comment_content
      t.boolean :read, null: false, default: false

      t.timestamps
    end

    add_index :notifications, %i[recipient_id read]
    add_index :notifications, %i[recipient_id updated_at]
    add_index :notifications, %i[notifiable_type notifiable_id]
    add_index :notifications,
              %i[recipient_id notification_type target_post_id],
              unique: true,
              where: "notification_type = 'liked'",
              name: 'idx_notifications_liked_unique'
  end
end
