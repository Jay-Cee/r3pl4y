class AddThumbnailAndBackgroundToGame < ActiveRecord::Migration
  def change
		add_column :games, :thumbnail_url, :string
		add_column :games, :background_url, :string
  end
end
