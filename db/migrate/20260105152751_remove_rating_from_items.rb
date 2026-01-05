class RemoveRatingFromItems < ActiveRecord::Migration[8.1]
  def change
    remove_column :items, :rating, :float
  end
end
