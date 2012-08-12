class AddInvitedByToUser < ActiveRecord::Migration
  def change
		add_column :users, :invited_by, :integer, :null => true
  end
end
