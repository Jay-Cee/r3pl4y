class RemoveMemberTable < ActiveRecord::Migration
  def up
		remove_column :reviews, :member_id
		add_column :reviews, :user_id, :integer, :null => false
  end

  def down
		add_column :reviews, :member_id, :integer
		remove_column :reviews, :user_id
  end
end
