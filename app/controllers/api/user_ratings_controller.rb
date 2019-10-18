class Api::UserRatingsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @user_ratings = UserRating.all
    render json: @user_ratings
  end

end
