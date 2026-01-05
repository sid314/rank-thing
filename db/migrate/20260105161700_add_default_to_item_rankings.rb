class AddDefaultToItemRankings < ActiveRecord::Migration[8.1]
def change
  change_column_default :items, :ranking, 1200

  reversible do |dir|
    dir.up { Item.where(ranking: nil).update_all(ranking: 1200) }
  end
end
end
