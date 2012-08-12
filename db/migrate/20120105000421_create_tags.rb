class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.primary_key :id
      t.string :name
      t.string :description
      t.string :category

      t.timestamps
    end
  end
end
