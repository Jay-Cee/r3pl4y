class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.primary_key :id
      t.string :title
      t.string :slug
      t.text :description
      t.timestamp :released
      t.float :rate_average
      t.integer :rate_quantity

      t.timestamps
    end
  end
end
