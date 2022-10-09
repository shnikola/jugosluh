class Api::UserRatingsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def index
    @user_ratings = UserRating.all
    render json: @user_ratings
  end

end
