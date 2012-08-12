class MakeEmailAndPasswordOptional < ActiveRecord::Migration
  def up
		change_column :users, :email, :string, { :unique => false, :null => true }
		change_column :users, :encrypted_password, :string, { :null => true }
  end

	def down
		change_column :users, :email, :string, { :unique => true, :null => false }
		change_column :users, :encrypted_password, :string, { :null => false }
	end
end
