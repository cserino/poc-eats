class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :name
      t.string :uuid
      t.string :restaurant_uuid

      t.timestamps
    end

    add_foreign_key :items, :restaurants, column: :restaurant_uuid, primary_key: :uuid
    add_index :items, :restaurant_uuid
  end
end
