class AddActionTypes < ActiveRecord::Migration
  def change
    create_table :action_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
