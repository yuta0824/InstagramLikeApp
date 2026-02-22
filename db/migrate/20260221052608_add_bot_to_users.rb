class AddBotToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :bot, :boolean, default: false, null: false
  end
end
