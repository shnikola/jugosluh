class UserRatingsController < ApplicationController
  before_action :authenticate_user!, raise: false

  def create
    @rating = current_user.user_ratings.create(user_rating_params)
    @rating.album.calculate_average_rating
    redirect_to album_url(@rating.album_id)
  end

  def edit
    @rating = current_user.user_ratings.find(params[:id])
  end

  def update
    @rating = current_user.user_ratings.find(params[:id])
    @rating.update_attributes(user_rating_params)
    @rating.album.calculate_average_rating
    redirect_to album_url(@rating.album_id)
  end

  def destroy
    @rating = current_user.user_ratings.find(params[:id])
    @rating.destroy
    @rating.album.calculate_average_rating
    redirect_to album_url(@rating.album_id)
  end

  private

  def user_rating_params
    params.require(:user_rating).permit(:album_id, :rating, :comment)
  end
end