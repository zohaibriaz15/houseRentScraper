class HomeController < ApplicationController
  def index
  end

  def show
    user_min_range = params[:user_min_range].to_i
    user_max_range = params[:user_max_range].to_i
  
    marla_size = params[:marla_size]
    @min_price =  HouseRent.where(area: marla_size).minimum(:price)
    @max_price =  HouseRent.where(area: marla_size).maximum(:price)
    # @scrappers = Scrapper.where(area: marla_size).page(params[:page]).per(9) if marla_size.present?
      # Define a base query to filter by the selected area
    @scrappers = HouseRent.where(area: marla_size)
    
    # Apply additional filtering based on user input
    if user_min_range > user_max_range || user_max_range < user_min_range
      @min_price =  HouseRent.where(area: marla_size).minimum(:price)
      @max_price =  HouseRent.where(area: marla_size).maximum(:price)
    elsif user_min_range > 0 && user_max_range > 0
      @scrappers = @scrappers.where("price >= ? AND price <= ?", user_min_range, user_max_range)
      @min_price =  user_min_range
      @max_price =  user_max_range
    elsif user_min_range > 0
      @scrappers = @scrappers.where("price >= ?", user_min_range)
      @min_price =  user_min_range
    elsif user_max_range > 0
      @scrappers = @scrappers.where("price <= ?", user_max_range)
      @max_price =  user_max_range
    end

    # Pagination logic (you can adjust this as needed)
    @scrappers = @scrappers.page(params[:page]).per(6)
  end


  def description
    @scrapper = HouseRent.find(params[:id])
  end

end
