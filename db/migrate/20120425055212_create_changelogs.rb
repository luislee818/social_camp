class CreateChangelogs < ActiveRecord::Migration
  def change
    create_table :changelogs do |t|
      t.integer :trackable_id
      t.string :trackable_type
      t.integer :user_id
      t.integer :action_type_id

      t.timestamps
    end
  end
end
