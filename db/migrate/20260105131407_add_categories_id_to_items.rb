class AddCategoriesIdToItems < ActiveRecord::Migration[8.1]
  def change
    add_reference :items, :category, null: false, foreign_key: true
  end
end
