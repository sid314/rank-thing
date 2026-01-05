class ChangeRankingToFloatInItems < ActiveRecord::Migration[8.1]
  def change
    change_column :items, :ranking, :float
  end
end
