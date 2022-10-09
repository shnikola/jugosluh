class HomeController < ApplicationController

  def index
    @user_ratings = UserRating.includes(:user, :album).order("created_at DESC").first(10)
  end

end