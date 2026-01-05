class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.string :name
      t.integer :ranking, default: 1

      t.timestamps
    end
  end
end
