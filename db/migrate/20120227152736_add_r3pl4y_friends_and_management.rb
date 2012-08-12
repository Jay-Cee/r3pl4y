class AddR3pl4yFriendsAndManagement < ActiveRecord::Migration
  def change
		add_column :friends, :r3pl4y_uid, :integer, :null => true
  end
end
