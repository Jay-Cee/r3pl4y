class AddFacebookAccessTokenAndExpirationToUser < ActiveRecord::Migration
  def change
		add_column :users, :facebook_access_token, :string
		add_column :users, :facebook_access_token_expires, :datetime
  end
end
