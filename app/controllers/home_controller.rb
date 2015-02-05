class HomeController < ApplicationController
  
  def index
    @stats = { 
      listened: current_user.user_ratings.count, 
      downloaded: Album.downloaded.count,
      found: Album.of_interest.count
    }
    
    @user_ratings = UserRating.includes(:user, :album).order("created_at DESC").first(5)
  end
  
end