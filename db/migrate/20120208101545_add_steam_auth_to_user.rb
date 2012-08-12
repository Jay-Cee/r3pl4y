class AddSteamAuthToUser < ActiveRecord::Migration
  def change
		add_column :users, :steam_auth, :string
  end
end
