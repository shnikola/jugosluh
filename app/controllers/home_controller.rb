class HomeController < ApplicationController
  
  def index
    @stats = { 
      found: Album.of_interest.count,
      uploaded: Album.of_interest.uploaded.count,
      listened: current_user.user_ratings.count
    }
    
    @user_ratings = UserRating.includes(:user, :album).order("created_at DESC").first(10)
  end
  
end