class AddThumbnailAndBackgroundPaperclipFieldsToGame < ActiveRecord::Migration
  def change
		add_column :games, :thumbnail_file_name, :string
		add_column :games, :thumbnail_content_type, :string
		add_column :games, :thumbnail_file_size, :integer
		add_column :games, :thumbnail_updated_at, :datetime

		add_column :games, :background_file_name, :string
		add_column :games, :background_content_type, :string
		add_column :games, :background_file_size, :integer
		add_column :games, :background_updated_at, :datetime

  end
end
