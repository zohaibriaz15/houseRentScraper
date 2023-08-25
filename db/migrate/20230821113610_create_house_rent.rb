class CreateHouseRent < ActiveRecord::Migration[7.0]
  def change
    create_table :house_rents do |t|
      t.integer :price
      t.string :location
      t.float :area
      t.integer :bed
      t.integer :bath
      t.text :description
      t.timestamps
    end
  end
end
