class UserRatingsController < ApplicationController
  
  def create
    @rating = current_user.user_ratings.create(user_rating_params)
    render nothing: true
  end
  
  def update
    @rating = current_user.user_ratings.find(params[:id])
    @rating.update_attributes(user_rating_params)
    render nothing: true
  end
  
  private
  
  def user_rating_params
    params.require(:user_rating).permit(:album_id, :rating, :comment)
  end 
end