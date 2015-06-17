class AddTagIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :tag_id, :integer
  end
end
