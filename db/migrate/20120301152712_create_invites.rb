class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.primary_key :id
      t.string :email
      t.string :hash
      t.integer :user_id, :null => true

      t.timestamps
    end
  end
end
