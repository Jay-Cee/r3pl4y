class AddPublicColumnToGames < ActiveRecord::Migration
  def change
		add_column :games, :is_public, :boolean, :default => false
  end
end
