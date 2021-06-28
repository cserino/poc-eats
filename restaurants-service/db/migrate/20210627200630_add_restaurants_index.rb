class AddRestaurantsIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :restaurants, :uuid, unique: true
  end
end
