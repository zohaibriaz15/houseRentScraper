class AddImageToHouseRents < ActiveRecord::Migration[7.0]
  def change
    add_column :house_rents, :image, :string
  end
end
