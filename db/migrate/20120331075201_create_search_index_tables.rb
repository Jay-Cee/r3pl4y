class CreateSearchIndexTables < ActiveRecord::Migration
  def change
		create_table :words do |t|
		  t.string :word, :null => false
			t.timestamps
		end

		add_index :words, :word

		create_table :game_words do |t|
			t.references :game
			t.references :word
		end
  end

end
