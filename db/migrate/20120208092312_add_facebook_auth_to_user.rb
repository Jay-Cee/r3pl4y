class AddFacebookAuthToUser < ActiveRecord::Migration
  def change
		add_column :users, :facebook_auth, :string
  end
end
