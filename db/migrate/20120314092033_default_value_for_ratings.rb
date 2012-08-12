class DefaultValueForRatings < ActiveRecord::Migration
  def up
		change_column :games, :rate_average, :float, :null => false, :default => 0.0
		change_column :games, :rate_quantity, :integer, :null => false, :default => 0
  end

  def down
		change_column :games, :rate_average, :float
		change_column :games, :rate_quantity, :integer
  end
end
