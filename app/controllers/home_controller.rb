class HomeController < ApplicationController
  
  def index
    @stats = { 
      listened: current_user.user_ratings.count, 
      downloaded: Album.downloaded.count,
      found: Album.of_interest.count
    }
  end
  
end