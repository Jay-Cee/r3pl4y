class CreateGameTags < ActiveRecord::Migration
  def change
    create_table :game_tags do |t|
      t.primary_key :id
      t.references :game
      t.references :tag

      t.timestamps
    end
    add_index :game_tags, :game_id
    add_index :game_tags, :tag_id
  end
end
