class HomeController < ApplicationController
  
  def index
    @stats = { 
      found: Album.of_interest.count,
      downloaded: Album.of_interest.downloaded.count,
      listened: current_user.user_ratings.count
    }
    
    @user_ratings = UserRating.includes(:user, :album).order("created_at DESC").first(10)
  end
  
end