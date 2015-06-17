class AddFavoriteToItems < ActiveRecord::Migration
  def change
    add_column :items, :favorite, :boolean, default: false
  end
end
