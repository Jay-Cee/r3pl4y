class DeleteThumbnailAndBackgroundUrls < ActiveRecord::Migration
  def up
		remove_column :games, :thumbnail_url
		remove_column :games, :background_url
  end

  def down
		add_column :games, :thumbnail_url, :string
		add_column :games, :background_url, :string
  end
end
