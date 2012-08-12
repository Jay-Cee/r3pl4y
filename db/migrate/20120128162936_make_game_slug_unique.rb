class MakeGameSlugUnique < ActiveRecord::Migration
  def up
		add_index :games, :slug, { :name => 'unique_slug', :unique => true }
  end

  def down
		remove_index :games, :name => 'unique_slug'
  end
end
