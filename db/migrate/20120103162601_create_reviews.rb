class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.primary_key :id
      t.integer :rating
      t.text :review
      t.boolean :finished
      t.timestamp :published
      t.integer :game_id
      t.integer :member_id

      t.timestamps
    end
  end
end
