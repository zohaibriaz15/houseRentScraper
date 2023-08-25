class HouseRent < ApplicationRecord
    validates :price, :location, :area, :bed, :bath, :description, :image, presence: true
end