class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.integer :id
      t.references :user
      t.string :twitter_uid
      t.string :facebook_uid
      t.string :steam_uid

      t.timestamps
    end
    add_index :friends, :user_id
  end
end
