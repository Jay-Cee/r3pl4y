class CreateSuggestions < ActiveRecord::Migration
  def change
    create_table :suggestions do |t|
      t.text :description, :null => false
      t.boolean :accepted, :null => false, :default => false
      t.references :game, :null => false
      t.references :user, :null => false

      t.timestamps
    end
    add_index :suggestions, :game_id
    add_index :suggestions, :user_id
  end
end
