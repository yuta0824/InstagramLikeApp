class DropNotifications < ActiveRecord::Migration[7.2]
  def change
    drop_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true
      t.timestamps
      t.index [:comment_id, :user_id], unique: true
    end
  end
end
