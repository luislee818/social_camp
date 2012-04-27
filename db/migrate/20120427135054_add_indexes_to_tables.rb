class AddIndexesToTables < ActiveRecord::Migration
  def change
    add_index :events, :user_id
    add_index :events, :start_at
    
    add_index :discussions, :user_id
    
    add_index :comments, :user_id
    add_index :comments, :discussion_id
    
    add_index :changelogs, :user_id
    add_index :changelogs, :trackable_id
    add_index :changelogs, :trackable_type
  end
end
