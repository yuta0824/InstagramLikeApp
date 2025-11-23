class AddNameFormatConstraintToUsers < ActiveRecord::Migration[7.2]
  def up
    add_check_constraint :users,
                         "name ~ '^[a-zA-Z0-9_]+$'",
                         name: 'users_name_format'
  end

  def down
    remove_check_constraint :users, name: 'users_name_format'
  end
end
