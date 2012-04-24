class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.string :subject
      t.text :content
      t.integer :user_id

      t.timestamps
    end
  end
end
