class AddTwitterAuthToUser < ActiveRecord::Migration
  def change
		add_column :users, :twitter_auth, :string
  end
end
