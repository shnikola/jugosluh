class Api::UserRatingsController < ApplicationController
  skip_before_filter :authenticate_user!
  
  def index
    @user_ratings = UserRating.all
    render json: @user_ratings
  end

end
