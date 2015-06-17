class AddTitleToItems < ActiveRecord::Migration
  def change
    add_column :items, :title, :string
    add_column :items, :description, :string
    add_column :items, :image, :string
  end
end
